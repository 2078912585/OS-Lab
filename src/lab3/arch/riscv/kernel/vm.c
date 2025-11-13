#include "defs.h"
#include "mm.h"
#include "string.h"

#define PTE_V (1L << 0) // Valid
#define PTE_R (1L << 1) // Read
#define PTE_W (1L << 2) // Write
#define PTE_X (1L << 3) // Execute

extern char _stext[], _etext[];
extern char _srodata[], _erodata[];
extern char _sdata[], _edata[];
extern char _sbss[], _ebss[];
extern char _ekernel[];

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
    /* 
     * 1. 由于是进行 1GiB 的映射，这里不需要使用多级页表 
     * 2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
   uint64_t pa=0x80000000;
   uint64_t va_eq=pa;
   uint64_t va_direct=pa+PA2VA_OFFSET;

   uint64_t perm = PTE_V|PTE_R|PTE_W|PTE_X; // V | R | W | X
    //中间 9 bit 作为 early_pgtbl 的 index
   uint64_t idx_eq=(va_eq>>30)&0x1ff; 
   uint64_t idx_direct=(va_direct>>30)&0x1ff;

    early_pgtbl[idx_eq]= (pa>>12)<<10 | perm;       //等值映射
    early_pgtbl[idx_direct]= (pa>>12)<<10 | perm;   //直接映射

    // printk("setup_vm: early_pgtbl at %p\n", early_pgtbl);
    // printk("setup_vm: mapping PA 0x%lx to VA 0x%lx (index %lu)\n", 
    //       pa, va_eq, idx_eq);
    // printk("setup_vm: mapping PA 0x%lx to VA 0x%lx (index %lu)\n", 
    //        pa, va_direct, idx_direct);

}

void setup_vm_neq(){

}

/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
    /*
     * pgtbl 为根页表的基地址
     * va, pa 为需要映射的虚拟地址、物理地址
     * sz 为映射的大小，单位为字节
     * perm 为映射的权限（即页表项的低 8 位）
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    uint64_t va_curr=va;
    uint64_t pa_curr=pa;
    uint64_t va_end=va+sz;

    while(va_curr<va_end){
        uint64_t vpn2=(va_curr>>30)&0x1ff;  //VA[39:30]
        uint64_t vpn1=(va_curr>>21)&0x1ff;  //VA[29:21]
        uint64_t vpn0=(va_curr>>12)&0x1ff;  //VA[20:12]

        
        if(!(pgtbl[vpn2]&PTE_V)){
            //分配新的二级页表
            uint64_t *patbl2=(uint64_t *)kalloc();
            memset(patbl2,0,PGSIZE);
            //转化物理地址
            uint64_t patbl2_pa=(uint64_t)patbl2-PA2VA_OFFSET;
            pgtbl[vpn2]=((uint64_t)patbl2_pa>>12)<<10|PTE_V;
        }
        //二级页表物理地址
        uint64_t patbl2_pa=(uint64_t *)((pgtbl[vpn2]>>10)<<12); 
        uint64_t *patbl2=(uint64_t *)(patbl2_pa+PA2VA_OFFSET);              

        if(!(patbl2[vpn1]&PTE_V)){
            uint64_t *patbl1=(uint64_t *)kalloc();
            memset(patbl1,0,PGSIZE);
            uint64_t patbl1_pa=(uint64_t)patbl1-PA2VA_OFFSET;
            patbl2[vpn1]=((uint64_t)patbl1_pa>>12)<<10|PTE_V;
        }
        //三级页表物理地址
        uint64_t patbl1_pa=(uint64_t *)((patbl2[vpn1]>>10)<<12); 
        uint64_t *patbl1=(uint64_t *)(patbl1_pa+PA2VA_OFFSET);
        //最终页表项
        patbl1[vpn0]=(pa_curr>>12)<<10|perm;

        va_curr+=PGSIZE;
        pa_curr+=PGSIZE;
    }
}

/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm_final() {
    memset(swapper_pg_dir, 0x0, PGSIZE);

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_stext,(uint64_t)(_stext-PA2VA_OFFSET),
                   (uint64_t)(_etext - _stext),PTE_X|PTE_R|PTE_V);
    printk("setup_vm_final: mapping kernel text done!\n");

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_srodata,(uint64_t)(_srodata-PA2VA_OFFSET),
                   (uint64_t)(_erodata - _srodata),PTE_R|PTE_V);
    printk("setup_vm_final: mapping kernel rodata done!\n");

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir,(uint64_t)_sdata,(uint64_t)(_sdata-PA2VA_OFFSET),
                   (uint64_t)(PHY_END-((uint64_t)_sdata-PA2VA_OFFSET)),PTE_W|PTE_R|PTE_V);
    printk("setup_vm_final: mapping other memory done!\n");

    // set satp with swapper_pg_dir
    uint64_t satp_val=0;
    satp_val|=(8ULL<<60);                          // MODE=8 Sv39
    satp_val|=(((uint64_t)swapper_pg_dir-PA2VA_OFFSET)>>12);   // PPN
    csr_write(satp,satp_val);

    // flush TLB
    asm volatile("sfence.vma zero, zero");
    return;
}



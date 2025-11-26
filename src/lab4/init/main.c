#include "printk.h"
#include "defs.h"
#include "proc.h"

extern void test();

extern char _stext[];
extern char _etext[];
extern char _srodata[];
extern char _erodata[];

void test_rw(){
    printk("stext read:%lx\n",&_stext);
    printk("srodata read:%lx\n",&_srodata);

    //  *_stext=0x1;
    // if(*_stext==0x1){
    //     printk("stext write: success\n");
    // }
    // *_srodata=0x1;
    // if(*_srodata==0x1){
    //     printk("srodata write: success\n");
    // }
}

void test_exe(){
    typedef void (*func_ptr)(void);

    func_ptr func = (func_ptr)_srodata;
    func();
    printk("execute stext success\n");

}

int start_kernel() {
    printk("2024");
    printk(" ZJU Operating System\n");
    schedule();
    // printk("The original value of ssratch: 0x%lx\n", csr_read(sscratch));
    // csr_write(sscratch, 0xdeadbeef);
    // printk("After  csr_write(sscratch, 0xdeadbeef): 0x%lx\n", csr_read(sscratch));
    test();
    return 0;
}

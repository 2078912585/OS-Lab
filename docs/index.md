# 浙江大学25年操作系统实验

本[仓库](https://git.zju.edu.cn/zju-os-sld/os-25fall)是浙江大学25年秋**操作系统**课程的教学仓库

<!-- 包含所有实验文档和公开代码。目录结构：

```bash
├── README.md
├── docs/       # 实验文档   
├── mkdocs.yml
└── src/        # 公开代码
``` -->

实验文档已经部署在了[zju-git pages](https://zju-os-sld.pages.zjusct.io/os-25fall)上，方便大家阅读。


## 实验任务与要求

- 请各位同学独立完成作业，任何抄袭行为都将使本次作业判为0分。
- 在学在浙大中提交 pdf 格式的实验报告：
    - 记录实验过程并截图，并对每一步的命令以及结果进行必要的解释；
    - 记录遇到的问题和心得体会；
    - 完成思考题。

!!! tip "关于实验报告内容要求，可见：[常见问题及解答 - 实验提交要求](faq.md#_2)"

## 本地渲染文档

文档采用了 [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) 工具构建和部署。如果想在本地渲染：

```bash
$ pip3 install mkdocs-material                      # 安装 mkdocs-material
$ git clone https://git.zju.edu.cn/zju-os-sld/os-25fall # clone 本 repo
$ mkdocs serve                                      # 本地渲染
INFO     -  Building documentation...
INFO     -  Cleaning site directory
...
INFO     -  [11:45:14] Serving on http://127.0.0.1:8000/os-25fall
```


## 致谢

感谢以下各位老师和助教的辛勤付出！

[申文博](https://wenboshen.org/)、[周亚金](https://yajin.org/)、徐金焱、周侠、管章辉、张文龙、刘强、孙家栋、周天昱、庄阿得、王琨、沈韬立、王星宇、朱璟森、谢洵、[潘子曰](https://pan-ziyue.github.io/)、朱若凡、季高强、郭若容、杜云潇、吴逸飞、李程浩、朱家迅、王行楷、陈淦豪、赵紫宸、[王鹤翔](https://tonycrane.cc)、许昊瑞、[朱宝林](https://github.com/bowling233)、[张恒斌](https://github.com/hharryz)。



## 最优质的链接

[季江明、王海帅班课程实验 (TA:朱宝林、张恒斌)](https://zju-os.github.io/doc/)

[NJU蒋炎炎OS实验](https://jyywiki.cn/OS/2025/)

(下面这俩有兴趣的自己做就好了，别跟老师提这玩意)

[助教私藏的OS2024全套实验](https://github.com/JuniorSNy/zju-os-sld)

[助教私藏的OS2023全套实验](https://github.com/JuniorSNy/os24fall-stu-full)

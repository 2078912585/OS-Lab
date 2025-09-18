# 使用Docker运行实验(beta)

## Docker简介

与基于CPU虚拟化指令集实现的虚拟机不同，Docker是一种基于内核命名空间的虚拟化方案，属于操作系统层面的虚拟化技术，使用隔离的进程独立于宿主和其它的隔离的进程，也称其为容器。容器与宿主机共用一个内核，有自己独立的文件系统映射。相比需要启动整套内核以及文件系统的虚拟机，Docker有更快的启动速度和更小的资源开销，在个人开发者中十分流行

关于如何入门Docker，[优质链接](https://yeasy.gitbook.io/docker_practice)

## 如何使用Docker部署实验

<!-- 在安装完 docker 后，可以使用 docker 官方提供的 -->

容器镜像 `git.zju.edu.cn:5050/os/tool`，内含：

- 全套实验所需工具链：QEMU、RISC-V 交叉编译工具链、OpenSBI、Spike 等
- `/zju-os/linux-source-*`：Linux 源码
- `/zju-os/src`：挂载的实验 `src` 目录

进入 `src` 目录：

- 拉起容器：

    ```bash
    docker compose up -d
    ```

- 打开终端：

    ```bash
    docker exec -it zju-os-sld /usr/bin/fish
    ```

- 关闭并删除容器：

    ```bash
    docker compose down
    ```

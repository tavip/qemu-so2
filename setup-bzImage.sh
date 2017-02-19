#!/bin/bash

SO2_KERNEL=linux-4.9.11
SO2_KERNEL_PATH=../$SO2_KERNEL

if ! [ -d $SO2_KERNEL_PATH ]; then
    if ! [ -e $SO2_KERNEL.tar.xz ]; then
	wget https://cdn.kernel.org/pub/linux/kernel/v4.x/$(SO2_KERNEL).tar.xz;
    fi
    tar -C $(shell dirname $(SO2_KERNEL_PATH)) -xJf $(SO2_KERNEL).tar.xz;
fi

if ! [ -e $SO2_KERNEL_PATH/.config ]; then
    cp kernel_config $SO2_KERNEL_PATH/.config
    make -C $SO2_KERNEL_PATH olddefconfig
fi

if ! [ -e $SO2_KERNEL_PATH/arch/x86/boot/bzImage ]; then
    make -C $SO2_KERNEL_PATH -j$(grep processor /proc/cpuinfo | wc -l)
fi

if ! [ -e bzImage ]; then
    ln -s $SO2_KERNEL_PATH/arch/x86/boot/bzImage bzImage;
fi

if ! [ -e vmlinux ]; then
    ln -s $SO2_KERNEL_PATH/vmlinunx vmlinux
fi

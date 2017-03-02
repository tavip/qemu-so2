QEMU_DISPLAY ?= sdl

run: initrd.cpio.gz bzImage pipe1.in pipe1.out pipe2.in pipe2.out disk1.img disk2.img tap0 tap1 nttcp-run
	qemu-system-i386 -initrd $< -kernel bzImage \
		-device virtio-serial \
		-chardev pty,id=virtiocon0 -device virtconsole,chardev=virtiocon0 \
		-serial pipe:pipe1 -serial pipe:pipe2 \
		-drive file=disk1.img,if=virtio,format=raw \
		-drive file=disk2.img,if=virtio,format=raw \
		-net nic,model=virtio,vlan=0 -net tap,ifname=tap0,vlan=0,script=no,downscript=no \
		-net nic,model=i82559er,vlan=1 -net tap,ifname=tap1,vlan=1,script=no,downscript=no \
		--append "root=/dev/ram console=tty0 console=hvc0" \
		--display $(QEMU_DISPLAY) -s

fsimg/bin/busybox:
	@echo "Please install statically compiled busybox image to fsimg/bin/busybox"
	@false

bzImage: 
	@echo "Please link bzImage from $$KERNEL/arch/x86/boot/bzImage"
	@false

setup-bzImage:
	./setup-bzImage.sh

initrd.cpio: $(shell find fsimg) fsimg/bin/busybox
	cd fsimg && find . ! -name .gitignore | cpio -o -H newc > ../$@

initrd.cpio.gz: initrd.cpio
	gzip -k -f $<

tap0:
	./create_net.sh $@
tap1:
	./create_net.sh $@

pipe1.in:
	mkfifo $@
pipe1.out:
	mkfifo $@
pipe2.in: pipe1.out
	ln $< $@
pipe2.out: pipe2.in
	ln $< $@

nttcp-run: nttcp tap0
	./nttcp -v -i &

disk1.img:
	qemu-img create -f raw $@ 100M
disk2.img:
	qemu-img create -f raw $@ 100M

gdb:
	gdb vmlinux -x gdb_remote

.PHONY: run clean gdb tap0

clean:
	rm -f initrd.cpio.gz initrd.cpio pipe1.in pipe1.out pipe2.in pipe2.out disk1.img disk2.img

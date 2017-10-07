# qemu-so2

* Minimal QEMU dev environment, Vlad Dogaru, 21.01.2014
* Slightly modified from an earlier version by Octavian Purdilă.
* (19.02.2017) tavi: get rid of the ISO dependencies and switch to using Virtio for infrastructure stuff (console, block, net) to free the emulation ports for development (e.g. 8250 serial ports, e100).
* Dev environment is 32 bit, even if host machine is 64 bit.

# Setting up the dev environment

You need a bzImage link in the current directory as well as a few binaries (like busybox) that are already provided. Use `make setup-bzImage` to automate the steps of downloading the kernel, building bzImage and creating the required link. Example:

```sh
$ git clone git@github.com:tavip/qemu-so2.git
# Download and compile the Linux kernel in the parent directory.
$ cd qemu-so2 && make setup-bzImage
# Create a symbolic link in /usr/src (needed to compile the kernel modules).
$ sudo ln -s ../linux-x.y.z /usr/src/linux-so2
```

Now you cam use `make` to run the VM. Use `root` to login.

# Consoles

There are two consoles activated:
* One in the default SDL display. To disable the SDL mode run as `QEMU_DISPLAY=none make`. In this case you can connect to the VM via the PTY port described below.
* One spawned as a PTY. Look for messages like `char device redirected to /dev/pts/20 (label virtiocon0)` to determine the PTY path and then you can use minicom or screen to connect to it: `minicom -D /dev/pts/20`.

# Rebuilding busybox

Grab busybox_config, stick it in a busybox config, and run `LDFLAGS=-m32 make`. There is an extra LDFLAGS option in busybox, but it does not seem to work.

# Putting files in the VM

Best stick anything you need (modules and test programs) in `fsimg/root`. You will need to statically link non-trivial programs. Additionally, make sure you specify `-m32` when compiling everything except modules (kernel build system takes care of that).

# Building homework modules

Grab kernel_config, stick it in a kernel tree, and run `make olddefconfig`. Modules should then have the following line at the top `KDIR=/usr/src/linux-so2` to save students from the burden of having a full kernel tree on their disk. Of course, if you have such a tree (e.g. you compiled a bzImage earlier), you can use that one. But you might get in trouble if your tree is not at the exact version students should use (currently tentatively set at `4.9.11` at the time of this writing).

# Common set-up issues

When running `make setup-bzImage`, the kernel may fail to compile with GCC 7.x.x with the following error:
```sh
kernel/built-in.o: In function `update_wall_time':
~/git/linux-4.9.11/kernel/time/timekeeping.c:2079: undefined reference to `____ilog2_NaN'
make[1]: *** [Makefile:969: vmlinux] Error 1
```

Workaround:
* Delete the kernel tree: `rm -rf /path/to/linux-x.y.z`.
* Open `setup-bzImage.sh` and comment the lines that compile the kernel (i.e. 21-33).
* Run `make setup-bzImage` to only download the kernel code.
* Apply the patch from [here](https://lkml.org/lkml/2017/2/25/27), i.e. replace all occurrences of `____ilog2_NaN` in `/path/to/linux-x.y.z/include/linux/log2.h` with `0`.
* Open `setup-bzImage.sh` and uncomment the previously commented lines.
* Run `make setup-bzImage` and the kernel will now compile successfully.

# Additional info

Direct all questions to the mailing list.

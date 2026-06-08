# Openwifi packages feed for openwrt

This repository contains a set of packages to enable openwifi support in openwrt.

## Overview:
| path | function                                                               |
|------|------------------------------------------------------------------------|
| boot/xlnx_soc-prebuild-firmware | Generate Power Management Unit Firmware (pmufw.bin) for ZynqMP targets |
| kernel/linux/adi_non-mainline_common | ADI specific external kernel modules from ADI Linux kernel             |
| kernel/openwifi | Openwifi kernel module and userspace utilities                         |
| kernel/xilinx-vdma | KernelPackage for xilinx-vdma                                          |
| tools/microblaze_binutils | Compile binutils for microblaze, used by xlnx_soc-prebuild-firmware    |
| web/webfsd | Package for webfsd, webserver used by openwifi                         |
| firmware/openwifi-hw-img | Openwifi hardware components |
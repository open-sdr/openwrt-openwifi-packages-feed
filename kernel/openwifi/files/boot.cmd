# Program openwifi bitstream
setenv bit_file bitstream.bit
setenv bit_loadaddr 0x03000000
setenv program_openwifi_bitstream "load ${devtype} ${bootpart} ${bit_loadaddr} ${bit_file};fpga loadb 0 ${bit_loadaddr} ${filesize};"
run program_openwifi_bitstream

# Extract default device_tree
load ${devtype} ${bootpart} 0x04000000 fit.itb
bootm start 0x04000000

setenv fdt_copy_addr 0x03000000

# Tweaking device tree
cp.b ${fdtaddr} ${fdt_copy_addr} ${filesize}
fdt addr ${fdt_copy_addr}

# Apply common openwifi hardware
load ${devtype} ${bootpart} 0x1000000 openwifi_overlay_filename
fdt resize ${filesize}
fdt apply 0x1000000

# Apply openwifi board specific hardware
load ${devtype} ${bootpart} 0x2000000 openwifi_board_overlay_filename
fdt resize ${filesize}
fdt apply 0x2000000

# Start kernel with tweaked device tree
bootm 0x04000000 - ${fdt_copy_addr}
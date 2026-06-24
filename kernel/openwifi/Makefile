include $(TOPDIR)/rules.mk

PKG_NAME:=openwifi
PKG_RELEASE:=1

PKG_LICENSE:=AGPLv3
PKG_LICENSE_FILES:=

PKG_MAINTAINER:=Robbe Gaeremynck <robbe.gaeremynck@outlook.com>
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

OPENWIFI_BRANCH:=master
OPENWIFI_REVISION:=3f26eb0e # Latest known working commit (must be length eight)
OPENWIFI_GITHUB_REPO:= https://github.com/open-sdr/openwifi.git


OPENWIFI_DIR:=$(PKG_BUILD_DIR)/$(PKG_NAME)

# Openwifi driver path
DRIVER_DIR:=$(OPENWIFI_DIR)/driver

# Device tree directory
DT_DIR:=$(OPENWIFI_DIR)/kernel_boot/boards

# Directory to the adi_non-mainline_common dependency
ADI_NAME:=adi_non-mainline_common
ADI_NON-MAINLINE_DIR:=$(STAGING_DIR)/$(ADI_NAME)

# incl_fix_path fixes the include structure that is different
incl_fix_path:=$(ADI_NON-MAINLINE_DIR)/drivers/include_fix

define KernelPackage/openwifi
	SUBMENU:=Wireless Drivers
	TITLE:=Driver for openwifi
	KCONFIG:= \
		CONFIG_OF_OVERLAY=y \
		CONFIG_CONFIGFS_FS=y \
		CONFIG_OF_FPGA_REGION=y \
		CONFIG_FPGA_MGR_ZYNQ_FPGA=y \
		CONFIG_FPGA_MGR_ZYNQMP_FPGA=y \
		CONFIG_STAGING=y \
		CONFIG_XILINX_FCLK=y
	DEPENDS:= \
		+kmod-mac80211 \
		+kmod-ad9361 \
		+kmod-cf_axi_dds \
		+wget-ssl \
		+kmod-xilinx-vdma \
		+hostapd \
		+webfsd \
		+uboot-envtools \
		+libnl \
		+libpcap \
		+openwifi-hw-img \
		+sudo \
		+bash \
		+dnsmasq
	FILES:=\
		$(DRIVER_DIR)/openofdm_tx/openofdm_tx.ko \
		$(DRIVER_DIR)/openofdm_rx/openofdm_rx.ko \
		$(DRIVER_DIR)/tx_intf/tx_intf.ko \
		$(DRIVER_DIR)/rx_intf/rx_intf.ko \
		$(DRIVER_DIR)/xpu/xpu.ko \
		$(DRIVER_DIR)/side_ch/side_ch.ko \
		$(DRIVER_DIR)/sdr.ko
	MENU:=1
endef

define Package/sdrctl
	SECTION:=tools
	CATEGORY:=Tools
	TITLE:=sdrctl tool for OpenWiFi
	DEPENDS:=kmod-openwifi +libnl
endef

define Package/inject_80211
	SECTION:=tools
	CATEGORY:=Tools
	TITLE:=inject80211 tool for OpenWiFi
	DEPENDS:=kmod-openwifi +libpcap
endef

define Package/side_ch_ctl
	SECTION:=tools
	CATEGORY:=Tools
	TITLE:=side_ch_ctl tool for OpenWiFi
	DEPENDS:=kmod-openwifi
endef


define KernelPackage/openwifi/config
	select PACKAGE_CFG80211_TESTMODE
	select HAS_OVERLAYS_BOOTFS
	select ZYNQ_BITSTREAM_BOOTFS
	select ZYNQMP_BITSTREAM_BOOTFS
	source "$(SOURCE)/Config.in"
endef

CT_MAKEDEFS:=

# Include preprocessor definitions
NOSTDINC_FLAGS := \
	$(KERNEL_NOSTDINC_FLAGS) \
	-I$(incl_fix_path) \
	-I$(PKG_BUILD_DIR) \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-include backport/autoconf.h \
	-include backport/backport.h \
	-include$(LINUX_DIR)/include/net/sock.h \
	-DCPTCFG_NL80211_TESTMODE \
	-DOPENWRT

ifdef CONFIG_PACKAGE_MAC80211_DEBUGFS
	NOSTDINC_FLAGS += -DCPTCFG_MAC80211_DEBUGFS
endif


FOSDEM_VIDEO_URL:= \
https://github.com/open-sdr/openwifi-hw-img/raw/master/openwifi-low-aac.mp4

define Build/Prepare
	# Clone the openwifi repository
	cd $(PKG_BUILD_DIR) && \
	git clone --branch $(OPENWIFI_BRANCH) $(OPENWIFI_GITHUB_REPO) $(PKG_NAME)
	cd $(OPENWIFI_DIR) && \
	git checkout $(OPENWIFI_REVISION)

	mkdir -p $(incl_fix_path)
	touch $(DRIVER_DIR)/pre_def.h
	cd $(DRIVER_DIR) && \
	echo "#define GIT_REV 0x$(OPENWIFI_REVISION)" > git_rev.h

	# Download the OpenWiFi webserver video
	cd $(OPENWIFI_DIR)/user_space/webserver && \
	wget $(FOSDEM_VIDEO_URL)
endef

ifneq ($(findstring c,$(OPENWRT_VERBOSE)),)
	CT_MAKEDEFS += V=1
endif

KBUILD_EXTRA_SYMBOLS:= \
	$(KERNEL_BUILD_DIR)/symvers/mac80211.symvers \
	$(KERNEL_BUILD_DIR)/symvers/adi_non-mainline_common.symvers

FLAGS := \
	KBUILD_EXTRA_SYMBOLS="$(KBUILD_EXTRA_SYMBOLS)" \
	NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \

define Build/Compile/sdr
	+$(KERNEL_MAKE) $(CT_MAKEDEFS) $(PKG_JOBS) M="$(DRIVER_DIR)/openofdm_tx" $(FLAGS) modules
	+$(KERNEL_MAKE) $(CT_MAKEDEFS) $(PKG_JOBS) M="$(DRIVER_DIR)/openofdm_rx" $(FLAGS) modules
	+$(KERNEL_MAKE) $(CT_MAKEDEFS) $(PKG_JOBS) M="$(DRIVER_DIR)/tx_intf" $(FLAGS) modules
	+$(KERNEL_MAKE) $(CT_MAKEDEFS) $(PKG_JOBS) M="$(DRIVER_DIR)/rx_intf" $(FLAGS) modules
	+$(KERNEL_MAKE) $(CT_MAKEDEFS) $(PKG_JOBS) M="$(DRIVER_DIR)/xpu" $(FLAGS) modules
	+$(KERNEL_MAKE) $(CT_MAKEDEFS) $(PKG_JOBS) M="$(DRIVER_DIR)/side_ch" $(FLAGS) modules
	+$(KERNEL_MAKE) $(CT_MAKEDEFS) $(PKG_JOBS) M="$(DRIVER_DIR)" $(FLAGS) modules
	cp -f $(DRIVER_DIR)/Module.symvers $(PKG_BUILD_DIR)/Module.symvers
endef

SDRCTL_P:=user_space/sdrctl_src
define Build/Compile/sdrctl
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) \
	-C $(OPENWIFI_DIR)/$(SDRCTL_P) \
	$(MAKE_FLAGS)
endef

INJECT_80211_P:=user_space/inject_80211
define Build/Compile/inject_80211
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) \
	-C $(OPENWIFI_DIR)/$(INJECT_80211_P) \
	$(MAKE_FLAGS) INC_FLAGS="-I$(STAGING_DIR)/usr/include"
endef

SIDE_CH_CTL_P:=user_space/side_ch_ctl_src
define Build/Compile/side_ch_ctl
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) \
	-C $(OPENWIFI_DIR)/$(SIDE_CH_CTL_P) \
	$(MAKE_FLAGS)
endef

# Compile the sdr + selected user space packages
user_space-$(CONFIG_PACKAGE_sdrctl)+= Build/Compile/sdrctl
user_space-$(CONFIG_PACKAGE_inject_80211)+= Build/Compile/inject_80211
user_space-$(CONFIG_PACKAGE_side_ch_ctl)+= Build/Compile/side_ch_ctl
define Build/Compile
	$(call Build/Compile/sdr)
	$(foreach cc,$(user_space-y), \
		$(newline)$(call $(cc)) \
	)
endef

# Generate overlays, as we do not require the full device tree, only board name required
define Build/GenerateOverlays
	cd $(DT_DIR) && \
	./construct_device_tree.sh $(CONFIG_OPENWIFI_BOARD_NAME) $(if $(findstring zcu102,$(CONFIG_OPENWIFI_BOARD_NAME)),64,32)
endef

# Copy openwifi bitstream to staging dir
# Modify bootcmd to openwifi its will
BUILD_DEVICE:=$(subst DEVICE_,,$(PROFILE))
define Build/InstallDev
	mkdir -p $(STAGING_DIR_IMAGE)/overlays
	$(call Build/GenerateOverlays)
	$(CP) $(DT_DIR)/openwifi.dtbo $(STAGING_DIR_IMAGE)/overlays/openwifi.dtbo
	$(CP) $(DT_DIR)/$(CONFIG_OPENWIFI_BOARD_NAME)/$(CONFIG_OPENWIFI_BOARD_NAME).dtbo $(STAGING_DIR_IMAGE)/overlays/openwifi_board.dtbo

	if [ ! -f $(STAGING_DIR_IMAGE)/.patched_bootcmd ]; then \
	tac $(STAGING_DIR_IMAGE)/$(BUILD_DEVICE)-boot.cmd | sed '0,/boot/s/boot//' | tac > tmpfile && mv tmpfile $(STAGING_DIR_IMAGE)/$(BUILD_DEVICE)-boot.cmd \
	&& sed -e 's/openwifi_overlay_filename/openwifi.dtbo/g' \
		-e 's/openwifi_board_overlay_filename/openwifi_board.dtbo/g' \
		./files/boot.cmd >> $(STAGING_DIR_IMAGE)/$(BUILD_DEVICE)-boot.cmd \
	; fi
	touch $(STAGING_DIR_IMAGE)/.patched_bootcmd
endef

# Copy the openwifi sources to the board
# Since user_space scripts necessary to play with the sdr
OPENWIFI_BOARD_DIR=/root/openwifi
define KernelPackage/openwifi/install
	$(INSTALL_DIR) $(1)$(OPENWIFI_BOARD_DIR)
	$(CP) $(OPENWIFI_DIR)/user_space/* $(1)$(OPENWIFI_BOARD_DIR)

	$(INSTALL_DATA) ./files/mime.types $(1)$(OPENWIFI_BOARD_DIR)/webserver

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/openwifi_service $(1)/etc/init.d/openwifi
	$(INSTALL_BIN) ./files/openwifi_post_service $(1)/etc/init.d/openwifi_post

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/openwifi_uci $(1)/etc/uci-defaults/99_openwifi
endef

define Package/sdrctl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(OPENWIFI_DIR)/$(SDRCTL_P)/sdrctl $(1)/usr/bin
endef

define Package/inject_80211/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(OPENWIFI_DIR)/$(INJECT_80211_P)/inject_80211 $(1)/usr/bin
	$(INSTALL_BIN) $(OPENWIFI_DIR)/$(INJECT_80211_P)/analyze_80211 $(1)/usr/bin
endef

define Package/side_ch_ctl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(OPENWIFI_DIR)/$(SIDE_CH_CTL_P)/side_ch_ctl $(1)/usr/bin
endef


$(eval $(call BuildPackage,sdrctl))
$(eval $(call BuildPackage,inject_80211))
$(eval $(call BuildPackage,side_ch_ctl))
$(eval $(call KernelPackage,openwifi))

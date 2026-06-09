include $(TOPDIR)/rules.mk

PKG_NAME:=openwifi-hw-img
PKG_RELEASE:=1

PKG_LICENSE:=AGPLv3
PKG_LICENSE_FILES:=

PKG_MAINTAINER:=Robbe Gaeremynck <robbe.gaeremynck@outlook.com>
PKG_BUILD_PARALLEL:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/open-sdr/openwifi-hw-img.git
PKG_SOURCE_VERSION:=0db5ed8f82ff03f4fb12926fb916957b8e972fc1
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/openwifi-hw-img
	SECTION:=firmware
	CATEGORY:=Firmware
	TITLE:=OpenWifi hardware images (FPGA bitfiles, ps init files)
	URL:=https://github.com/open-sdr/openwifi-hw
endef

define Package/openwifi-hw-img/description
	Shared hardware image repository for the OpenWifi project.
	Provides FPGA bitfiles, and ps init files used by uboot-zynq, and the target build.
endef

# Patches are per architecture and only apply after decompressing .xsa file
define Build/Patch
endef

XSA_FOLDER:=$(PKG_BUILD_DIR)/boards/$(CONFIG_OPENWIFI_BOARD_NAME)/sdk
define Build/Compile
	cd $(XSA_FOLDER) && unzip ./system_top.xsa
	$(if $(CONFIG_TARGET_zynqmp), \
		cd $(XSA_FOLDER) && patch -N -p1 < $(PATCH_DIR)/000-Add-arguments-to-function-declarations-in-psu_init_g.patch \
	)
endef

# Export ps7_init_gpl files for use by uboot-zynq package
# Export bitstream to be placed into the image
PS_INIT_FILENAME := $(if $(CONFIG_TARGET_zynq),ps7_init_gpl,psu_init_gpl)
define Build/InstallDev
	$(INSTALL_DIR) $(1)/openwifi-hw-img
	$(CP) $(XSA_FOLDER)/$(PS_INIT_FILENAME).* $(1)/openwifi-hw-img

	mkdir -p $(STAGING_DIR_IMAGE)
	$(CP) $(XSA_FOLDER)/system_top.bit $(STAGING_DIR_IMAGE)
endef

define Package/openwifi-hw-img/install
#	FPGA loading from Linux userspace not yet supported, requires Xilinx kernel (or preferred method is patch for OpenWrt)
#	$(INSTALL_DIR) $(1)/lib/firmware
#	$(INSTALL_DATA) $(BITSTREAM_PATH) $(1)/lib/firmware/openwifi_bitstream.bit
endef

$(eval $(call BuildPackage,openwifi-hw-img))
include $(TOPDIR)/rules.mk

PKG_NAME:=binutils
PKG_VERSION:=2.45

PKG_MAINTAINER:=Robbe Gaeremynck <robbe.gaeremynck@outlook.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.zst
PKG_SOURCE_URL:=https://ftp.belnet.be/mirrors/ftp.gnu.org/gnu/$(PKG_NAME)
PKG_HASH:=7f288c9a869582d53dc645bf1b9e90cc5123f6862738850472ddbca69def47a3

include $(INCLUDE_DIR)/host-build.mk
PKG_BUILD_DIR:=$(HOST_BUILD_DIR)
include $(INCLUDE_DIR)/package.mk

define Package/microblaze_binutils
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=Binutils for microblaze
  MAINTAINER:=Robbe Gaeremynck <robbe.gaeremynck@outlook.com>
endef

TARGET:=microblaze-xilinx-elf
MB_BUILD_PREFIX=$(STAGING_DIR)/../toolchain-microblaze

# Overwrite default flags by rules.mk, since we are compiling for microblaze
MB_CPPFLAGS:=-I$(STAGING_DIR_HOST)/include $(if $(IS_PACKAGE_BUILD),-I$(STAGING_DIR_HOSTPKG)/include)
MB_CFLAGS:=-O2 $(MB_CPPFLAGS)
MB_CXXFLAGS:=
MB_LDFLAGS:=-L$(STAGING_DIR_HOST)/lib $(if $(IS_PACKAGE_BUILD),-L$(STAGING_DIR_HOSTPKG)/lib)

HOST_CPPFLAGS:=$(MB_CPPFLAGS)
HOST_CFLAGS:=$(MB_CFLAGS)
HOST_CXXFLAGS:=$(MB_CXXFLAGS)
HOST_LDFLAGS:=$(MB_LDFLAGS)

HOST = $(GNU_HOST_NAME)
BUILD = $(GNU_HOST_NAME)
HOST_CONFIGURE_ARGS = \
	--target=$(TARGET) \
	--host=$(HOST) \
	--build=$(BUILD) \
	--disable-dependency-tracking \
	--program-suffix="" \
	--prefix=$(MB_BUILD_PREFIX) \
	--exec-prefix=$(MB_BUILD_PREFIX) \
	--sysconfdir=$(MB_BUILD_PREFIX)/etc \
	--localstatedir=$(MB_BUILD_PREFIX)/var \
	--sbindir=$(MB_BUILD_PREFIX)/bin

define Build/Configure
	:
endef

define Build/Compile
	mkdir -p $(MB_BUILD_PREFIX)
	$(call Host/Configure/Default, \
	--disable-gprof \
	--disable-shared \
	--enable-lto \
	--disable-initfini-array \
	--disable-multilib \
	--disable-werror \
	--program-prefix=$(TARGET)- \
	,,)
	$(call Host/Compile/Default,,)
	$(call Host/Compile/Default,install,)
endef

define Build/Clean
	rm -rf $(PKG_BUILD_DIR)
	rm -rf $(MB_BUILD_PREFIX)
endef


define Package/microblaze_binutils/install
	:
endef

$(eval $(call BuildPackage,microblaze_binutils))
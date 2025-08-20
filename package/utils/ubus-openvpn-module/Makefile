include $(TOPDIR)/rules.mk

PKG_NAME:=ubus-openvpn-module
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://84.15.161.187/matbin/ubus-openvpn-module
PKG_SOURCE_VERSION:=a591230c15d55eeb0132a836279835a5c1e632e6

include $(INCLUDE_DIR)/package.mk

define Package/ubus-openvpn-module
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=OpenVPN module for ubus
  DEPENDS:=+lua +libubus +libubox +libuci
endef

define Package/ubus-openvpn-module/description
	Allows you to send commands to OpenVPN instances over ubus
endef

define Package/ubus-openvpn-module/install
  $(INSTALL_DIR) $(1)/usr/bin
  $(INSTALL_BIN) $(PKG_BUILD_DIR)/uovpn.lua $(1)/usr/bin/

  $(INSTALL_DIR) $(1)/usr/lib/lua/ubus_openvpn_module
  $(INSTALL_DATA) $(PKG_BUILD_DIR)/lib/*.lua $(1)/usr/lib/lua/ubus_openvpn_module/
endef

$(eval $(call BuildPackage,ubus-openvpn-module))

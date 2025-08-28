include $(TOPDIR)/rules.mk

PKG_NAME:=ubus-openvpn-module
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=http://84.15.161.187/matbin/ubus-openvpn-module
PKG_SOURCE_VERSION:=3fd87f2aac04cf7c36611d4b7c0c55f0c12a97ab

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

define Build/Compile
	true
endef

define Package/ubus-openvpn-module/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/uovpn.lua $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ubus-openvpn-module.init $(1)/etc/init.d/ubus-openvpn-module
endef

$(eval $(call BuildPackage,ubus-openvpn-module))

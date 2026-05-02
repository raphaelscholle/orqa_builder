SUMMARY = "OpenHD system utilities daemon"
DESCRIPTION = "OpenHD SysUtils daemon providing the sysutils Unix socket and platform, wifi, camera, update, and control helpers"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://inc/sysutil_debug.h;beginline=1;endline=21;md5=cc659a5f9c4e00330d0f09b939df1415"

SRC_URI = "git://github.com/OpenHD/OpenHD-SysUtils.git;protocol=https;branch=main"
SRCREV = "${AUTOREV}"

PV = "main+git${SRCPV}"
S = "${WORKDIR}/git"

inherit cmake pkgconfig systemd

DEPENDS += "virtual/libc"

RPROVIDES:${PN} += "openhd_sysutils"

SYSTEMD_SERVICE:${PN} = "openhd-sys-utils.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_configure:prepend() {
    export HOST_CXX="/usr/bin/g++"
}

do_install:append() {
    rm -f ${D}/lib/systemd/system/openhd-sys-utils.service
    rmdir --ignore-fail-on-non-empty ${D}/lib/systemd/system || true
    rmdir --ignore-fail-on-non-empty ${D}/lib/systemd || true
    rmdir --ignore-fail-on-non-empty ${D}/lib || true

    install -d ${D}${systemd_unitdir}/system
    install -d ${D}/usr/local/share/OpenHD/SysUtils
    install -d ${D}/boot/openhd
    install -d ${D}/boot/openhd/scripts
    install -d ${D}/boot/openhd/settings
    install -d ${D}/usr/local/share/openhd
    install -d ${D}/usr/local/share/openhd/settings
    install -d ${D}/usr/local/share/openhd/interface
    install -d ${D}/usr/local/share/openhd/telemetry
    install -d ${D}/usr/local/share/openhd/video
    install -d ${D}/usr/share/openhd

    install -m 0644 ${S}/systemd/openhd-sys-utils.service ${D}${systemd_unitdir}/system/openhd-sys-utils.service
    install -m 0644 ${S}/misc/wifi_cards.json ${D}/usr/local/share/OpenHD/SysUtils/wifi_cards.json
    touch ${D}/usr/local/share/OpenHD/SysUtils/config.json
    touch ${D}/usr/local/share/OpenHD/SysUtils/wifi_overrides.conf
    touch ${D}/usr/local/share/OpenHD/SysUtils/wifi_txpower.conf
    touch ${D}/boot/openhd/ground.txt
    touch ${D}/boot/openhd_version.txt
}

FILES:${PN} += " \
    /usr/local/bin/openhd_sys_utils \
    /usr/local/share/OpenHD/SysUtils \
    /usr/local/share/OpenHD/SysUtils/config.json \
    /usr/local/share/OpenHD/SysUtils/wifi_cards.json \
    /usr/local/share/OpenHD/SysUtils/wifi_overrides.conf \
    /usr/local/share/OpenHD/SysUtils/wifi_txpower.conf \
    /boot/openhd \
    /boot/openhd/ground.txt \
    /boot/openhd/scripts \
    /boot/openhd/settings \
    /boot/openhd_version.txt \
    /usr/local/share/openhd \
    /usr/local/share/openhd/settings \
    /usr/local/share/openhd/interface \
    /usr/local/share/openhd/telemetry \
    /usr/local/share/openhd/video \
    /usr/share/openhd \
"

SRC_URI = " \
    git://github.com/openhd/OpenHD.git;protocol=https;branch=openhd-3.0;name=openhd;destsuffix=git \
    git://github.com/nlohmann/json.git;protocol=https;name=json;nobranch=1;destsuffix=git/OpenHD/ohd_common/lib/json \
    git://github.com/gabime/spdlog.git;protocol=https;name=spdlog;nobranch=1;destsuffix=git/OpenHD/ohd_common/lib/spdlog \
    git://github.com/OpenHD/mavlink-headers.git;protocol=https;name=mavlink;nobranch=1;destsuffix=git/OpenHD/ohd_telemetry/lib/mavlink-headers \
    git://github.com/OpenHD/wifibroadcast.git;protocol=https;name=wifibroadcast;nobranch=1;destsuffix=git/OpenHD/ohd_interface/lib/wifibroadcast \
"
SRCREV_openhd = "OPENHD_OPENHD_SRCREV_PLACEHOLDER"
SRCREV_json = "904592d2a86bae5d9c191cdcb8f8fd9b136f71fa"
SRCREV_spdlog = "fc7e9c8721b95661cc40e2d1d2329677d2a21387"
SRCREV_mavlink = "b131206ee2f90c563506ed74017c1da57210cca9"
SRCREV_wifibroadcast = "b17b37bc6d585073f63f11f618af11903442036a"
SRCREV_FORMAT = "openhd_json_spdlog_mavlink_wifibroadcast"
PV = "openhd-3.0+git${SRCPV}"

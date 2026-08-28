#!/usr/bin/env bash

# 1.1.2 260827

set -euo pipefail
IFS=$'\n\t'

# $4 = Profile URL ("vpn.corporate.net") - will convert a / to - in filename and add .xml
# $5 = Profile Display Name ("Corporate_VPN")

# validate parameters
[[ -z "${4:-}" ]] && {
    echo "ERROR: No host address specified." >&2
    exit 1
}

[[ -z "${5:-}" ]] && {
    echo "ERROR: No host name specified." >&2
    exit 1
}

# check if URL doesnt contain .xml
if [[ "$4" != *".xml"* ]]; then
    profile="${4}.xml"
fi

# sanitize the profile name to include full string
# 4="${4//\//-}"
profile="${4//\//-}"
# echo $4

profileDir="/opt/cisco/secureclient/vpn/profile"
# profile="$(basename -- "$4")"
hostAddress="$4"
hostName="$5"

timestamp="$(date +%Y%m%d%H%M%S)"
profilePath="${profileDir}/${profile}"
backupPath="${profilePath}.bak.${timestamp}"
tmpfile=""

cleanup() {
    if [[ -n "${tmpfile}" && -f "${tmpfile}" ]]; then
        rm -f -- "${tmpfile}"
    fi
}
trap cleanup EXIT

# must run as root to write under /opt
if [[ "$(id -u)" -ne 0 ]]; then
    echo "ERROR: this script must be run as root" >&2
    exit 2
fi

# validate profile filename
[[ "$profile" =~ ^[A-Za-z0-9._-]+$ ]] || {
    echo "ERROR: Invalid profile filename: ${profile}" >&2
    exit 3
}

# ensure directory exists and is writable
mkdir -p -- "${profileDir}"

if [[ ! -w "${profileDir}" ]]; then
    echo "ERROR: ${profileDir} is not writable" >&2
    exit 4
fi

# create temp file in target directory so final move is atomic
tmpfile="$(mktemp "${profileDir}/${profile}.XXXXXXXX")" || {
    echo "ERROR: mktemp failed" >&2
    exit 5
}

cat > "${tmpfile}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<AnyConnectProfile xmlns="http://schemas.xmlsoap.org/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.xmlsoap.org/encoding/ AnyConnectProfile.xsd">
    <ClientInitialization>
        <UseStartBeforeLogon UserControllable="true">true</UseStartBeforeLogon>
        <AutomaticCertSelection UserControllable="true">false</AutomaticCertSelection>
        <ShowPreConnectMessage>false</ShowPreConnectMessage>
        <CertificateStore>All</CertificateStore>
        <CertificateStoreMac>All</CertificateStoreMac>
        <CertificateStoreOverride>false</CertificateStoreOverride>
        <ProxySettings>IgnoreProxy</ProxySettings>
        <AllowLocalProxyConnections>true</AllowLocalProxyConnections>
        <AuthenticationTimeout>30</AuthenticationTimeout>
        <AutoConnectOnStart UserControllable="true">false</AutoConnectOnStart>
        <MinimizeOnConnect UserControllable="true">true</MinimizeOnConnect>
        <LocalLanAccess UserControllable="true">false</LocalLanAccess>
        <DisableCaptivePortalDetection UserControllable="true">false</DisableCaptivePortalDetection>
        <ClearSmartcardPin UserControllable="true">true</ClearSmartcardPin>
        <IPProtocolSupport>IPv4,IPv6</IPProtocolSupport>
        <AutoReconnect UserControllable="false">true
            <AutoReconnectBehavior UserControllable="false">DisconnectOnSuspend</AutoReconnectBehavior>
        </AutoReconnect>
        <SuspendOnConnectedStandby>false</SuspendOnConnectedStandby>
        <AutoUpdate UserControllable="false">true</AutoUpdate>
        <RSASecurIDIntegration UserControllable="false">Automatic</RSASecurIDIntegration>
        <WindowsLogonEnforcement>SingleLocalLogon</WindowsLogonEnforcement>
        <LinuxLogonEnforcement>SingleLocalLogon</LinuxLogonEnforcement>
        <WindowsVPNEstablishment>LocalUsersOnly</WindowsVPNEstablishment>
        <LinuxVPNEstablishment>LocalUsersOnly</LinuxVPNEstablishment>
        <AutomaticVPNPolicy>true
            <TrustedDNSDomains>hcscint.net,fyiblue.com,adhcscint.net,prd.hcscad.net</TrustedDNSDomains>
            <TrustedDNSServers>10.139.244.35,10.69.244.35</TrustedDNSServers>
            <TrustedNetworkPolicy>Disconnect</TrustedNetworkPolicy>
            <UntrustedNetworkPolicy>DoNothing</UntrustedNetworkPolicy>
            <BypassConnectUponSessionTimeout>false</BypassConnectUponSessionTimeout>
            <AlwaysOn>false</AlwaysOn>
        </AutomaticVPNPolicy>
        <PPPExclusion UserControllable="false">Disable
            <PPPExclusionServerIP UserControllable="false"></PPPExclusionServerIP>
        </PPPExclusion>
        <EnableScripting UserControllable="false">true
            <TerminateScriptOnNextEvent>true</TerminateScriptOnNextEvent>
            <EnablePostSBLOnConnectScript>false</EnablePostSBLOnConnectScript>
        </EnableScripting>
        <EnableAutomaticServerSelection UserControllable="false">false
            <AutoServerSelectionImprovement>20</AutoServerSelectionImprovement>
            <AutoServerSelectionSuspendTime>4</AutoServerSelectionSuspendTime>
        </EnableAutomaticServerSelection>
        <RetainVpnOnLogoff>false</RetainVpnOnLogoff>
        <AllowManualHostInput>true</AllowManualHostInput>
    </ClientInitialization>
    <ServerList>
        <HostEntry>
            <HostName>${hostName}</HostName>
            <HostAddress>${hostAddress}</HostAddress>
            <UserGroup>prd-anyvpn</UserGroup>
        </HostEntry>
    </ServerList>
</AnyConnectProfile>
EOF

# validate generated XML if xmllint is available
if command -v xmllint >/dev/null 2>&1; then
    xmllint --noout "${tmpfile}" || {
        echo "ERROR: Invalid XML generated" >&2
        exit 6
    }
fi

chmod 0644 "${tmpfile}"

# nothing changed, skip install
if [[ -f "${profilePath}" ]] && cmp -s "${tmpfile}" "${profilePath}"; then
    tmpfile=""
    exit 0
fi

# rotate existing file
if [[ -e "${profilePath}" ]]; then
    if ! mv -- "${profilePath}" "${backupPath}"; then
        echo "ERROR: Failed to rotate existing profile" >&2
        exit 7
    fi
fi

# remove backups older than 30 days
find "${profileDir}" \
    -name "${profile}.bak.*" \
    -type f \
    -mtime +30 \
    -delete 2>/dev/null || true

# atomic replacement
mv -f -- "${tmpfile}" "${profilePath}"

chown root:wheel "${profilePath}"
chmod 0644 "${profilePath}"

# prevent trap from removing newly-installed file
tmpfile=""

exit 0

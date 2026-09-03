#!/usr/bin/env bash

# 1.1.2 260827 does not alter or remove any existing profiles.

set -euo pipefail
IFS=$'\n\t'

# parameters
# $4 = Profile URL ("vpn.company.tld")
# $5 = Profile Display Name ("Company_VPN")

# validate
[[ -z "${4:-}" ]] && {
    echo "ERROR: No host address specified." >&2
    exit 1
}

[[ -z "${5:-}" ]] && {
    echo "ERROR: No host name specified." >&2
    exit 1
}

# check if Profile URL doesnt contain .xml
# remember that we're doing this in bash, won't work in zsh
if [[ "$4" != *".xml"* ]]; then
    profile="${4}.xml"
fi

# Profile URL becomes profile.xml name
# sanitize the profile name to include full string since real URL might include /
#      in:  vpn.company.tld/vpn-north 
#     out:  vpn.company.tld-vpn-north.xml
# 4="${4//\//-}"
profile="${4//\//-}"

profileDir="/opt/cisco/secureclient/vpn/profile"
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

# your options may (will) vary
cat > "${tmpfile}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- ${profile}-${timestamp} -->
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
            <TrustedDNSDomains>domain1.company.tld,domain2.company.tld</TrustedDNSDomains>
            <TrustedDNSServers>10.0.0.1,10.1.1.1</TrustedDNSServers>
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
            <UserGroup>some_vpn_group</UserGroup>
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

#!/usr/bin/env bash
# Safer, atomic writer for the AnyConnect profile
set -euo pipefail
IFS=$'\n\t'

profileDir="/opt/cisco/secureclient/vpn/profile"
profile="prod-anyvpn-profile.xml"
timestamp="$(date +%Y%m%d%H%M%S)"
tmpfile=""

cleanup() {
  # remove temp file if it still exists
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

# ensure directory exists and is writable
mkdir -p -- "${profileDir}"
if [[ ! -w "${profileDir}" ]]; then
  echo "ERROR: ${profileDir} is not writable" >&2
  exit 3
fi

# rotate existing file (timestamped to avoid clobbering previous backups)
if [[ -e "${profileDir}/${profile}" ]]; then
  mv -v -- "${profileDir}/${profile}" "${profileDir}/${profile}.bak.${timestamp}"
fi

# create a temp file in the target directory (ensures same filesystem, so mv is atomic)
tmpfile="$(mktemp "${profileDir}/${profile}.XXXXXXXX")" || { echo "ERROR: mktemp failed" >&2; exit 4; }

# Use a single-quoted here-doc to avoid accidental variable expansion
cat > "${tmpfile}" <<'EOF'
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
			<AlwaysOn>false
			</AlwaysOn>
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
		<RetainVpnOnLogoff>false
		</RetainVpnOnLogoff>
		<AllowManualHostInput>true</AllowManualHostInput>
	</ClientInitialization>
	<ServerList>
		<HostEntry>
			<HostName>HCSC_AnyplaceVPN</HostName>
			<HostAddress>anyplacevpn.hcsc.net</HostAddress>
			<UserGroup>prd-anyvpn</UserGroup>
		</HostEntry>
	</ServerList>
</AnyConnectProfile>
EOF

# set safe permissions (adjust as appropriate for your environment)
chmod 0644 -- "${tmpfile}"

# move into place atomically
mv -f -- "${tmpfile}" "${profileDir}/${profile}"
# prevent cleanup removing the real file
tmpfile=""

echo "WROTE: ${profileDir}/${profile}"
exit 0

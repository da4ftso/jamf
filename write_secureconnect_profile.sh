#!/bin/bash

# cat out this VPN profile
# instead of packaging

# profile location
profileDir="/opt/cisco/secureclient/vpn/profile"
profile="prod-anyvpn-profile.xml"

if [[ -e "${profileDir}" ] ; then
  if [[ -e "${profileDir}"/"${profile}" ]] ; then
    mv "${profileDir}"/"${profile}" "${profileDir}"/"${profile}.bak"
  fi
# write XML

/bin/cat > "${profileDir}"/"${profile}" << EOF

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

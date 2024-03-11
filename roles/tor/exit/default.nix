{ ... }: {
  imports = [
    ../relay.nix
  ];

  services.tor = {
    relay = {
      enable = true;
      role = "exit";
    };
    settings.ExitPolicy = map (range: "accept *:${range}") [
      "20-21" # FTP
      "22" # SSH
      "23" # Telnet
      "43" # WHOIS
      "53" # DNS
      "79" # finger
      "80-81" # HTTP
      "88" # kerberos
      "110" # POP3
      "143" # IMAP
      "194" # IRC
      "220" # IMAP3
      "389" # LDAP
      "443" # HTTPS
      "464" # kpasswd
      "465" # URD for SSM (more often: an alternative SUBMISSION port, see 587)
      "531" # IRC/AIM
      "543-544" # Kerberos
      "554" # RTSP
      "563" # NNTP over SSL
      "636" # LDAP over SSL
      "706" # SILC
      "749" # kerberos 
      "853" # DNS over TLS
      "873" # rsync
      "902-904" # VMware
      "981" # Remote HTTPS management for firewall
      "989-990" # FTP over SSL
      "991" # Netnews Administration System
      "992" # TELNETS
      "993" # IMAP over SSL
      "994" # IRCS
      "995" # POP3 over SSL
      "1194" # OpenVPN
      "1220" # QT Server Admin
      "1293" # PKT-KRB-IPSec
      "1500" # VLSI License Manager
      "1533" # Sametime
      "1677" # GroupWise
      "1723" # PPTP
      "1755" # RTSP
      "1863" # MSNP
      "2082" # Infowave Mobility Server
      "2083" # Secure Radius Service (radsec)
      "2086-2087" # GNUnet, ELI
      "2095-2096" # NBX
      "2102-2104" # Zephyr
      "3128" # SQUID
      "3389" # MS WBT
      "3690" # SVN
      "4321" # RWHOIS
      "4643" # Virtuozzo
      "5050" # MMCC
      "5190" # ICQ
      "5222-5223" # XMPP, XMPP over SSL
      "5228" # Android Market
      "5900" # VNC
      "6660-6669" # IRC
      "6679" # IRC SSL  
      "6697" # IRC SSL  
      "8000" # iRDMI
      "8008" # HTTP alternate
      "8074" # Gadu-Gadu
      "8080" # HTTP Proxies
      "8082" # HTTPS Electrum Bitcoin port
      "8087-8088" # Simplify Media SPP Protocol, Radan HTTP
      "8232-8233" # Zcash
      "8332-8333" # Bitcoin
      "8443" # PCsync HTTPS
      "8888" # HTTP Proxies, NewsEDGE
      "9418" # git
      "9999" # distinct
      "10000" # Network Data Management Protocol
      "11371" # OpenPGP hkp (http keyserver protocol)
      "19294" # Google Voice TCP
      "19638" # Ensim control panel
      "50002" # Electrum Bitcoin SSL
      "64738" # Mumble
    ] ++ [ "reject *:*" ];
  };
}

echo ''
echo 'NuoDB - Configure firewall...'
echo -e "\tDelete all existing iptables rules"
iptables -F
echo -e "\tSet default chain policies, drop all packets by default."
iptables -P INPUT DROP
#iptables -P FORWARD DROP
#iptables -P OUTPUT DROP
echo -e "\tAllow incoming SSH"
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT -m recent --set --name SSH
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT -m recent --set --name SSH
echo -e "\tAllow outgoing HTTP (for yum updates)"
iptables -A OUTPUT -o eth0 -p tcp --dport 80 -m tcp -m state --state NEW -j ACCEPT
echo -e "\tAllow ESTABLISHED,RELATED connections"
iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
echo -e "\tNuoDB Console data on port 8080"
iptables -A INPUT -i eth0 -p tcp --dport 8080 -m state --state NEW,ESTABLISHED -j ACCEPT -m recent --set --name HTTP
iptables -A OUTPUT -o eth0 -p tcp --sport 8080 -m state --state RELATED,ESTABLISHED -j ACCEPT -m recent --set --name HTTP
echo -e "\tAllow HTTPS data on port 443"
iptables -A INPUT -i eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT -m recent --set --name HTTPS
iptables -A OUTPUT -o eth0 -p tcp --sport 443 -m state --state RELATED,ESTABLISHED -j ACCEPT -m recent --set --name HTTPS
echo -e "\tNuoDB Automation Console - TCP 8888"
iptables -A INPUT -i eth0 -p tcp --dport 8888 -m state --state NEW,ESTABLISHED -j ACCEPT -m recent --set --name HTTPS
iptables -A OUTPUT -o eth0 -p tcp --sport 8888 -m state --state RELATED,ESTABLISHED -j ACCEPT -m recent --set --name HTTPS
echo -e "\tNuoDB Automation Console - TCP 8889"
iptables -A INPUT -i eth0 -p tcp --dport 8889 -m state --state NEW,ESTABLISHED -j ACCEPT -m recent --set --name HTTPS
iptables -A OUTPUT -o eth0 -p tcp --sport 8889 -m state --state RELATED,ESTABLISHED -j ACCEPT -m recent --set --name HTTPS
echo -e "\tNuoDB Broker/Agent Port - TCP 48004"
iptables -A INPUT -i eth0 -p tcp --dport 48004 -m state --state NEW,ESTABLISHED -j ACCEPT -m recent --set --name HTTPS
iptables -A OUTPUT -o eth0 -p tcp --sport 48004 -m state --state RELATED,ESTABLISHED -j ACCEPT -m recent --set --name HTTPS
echo -e "\tNuoDB Storage Manager and Transaction Engine Ports - TCP 48005:48025"
iptables -A INPUT -i eth0 -p tcp --dport 48005:48025 -m state --state NEW,ESTABLISHED -j ACCEPT -m recent --set --name HTTPS
iptables -A OUTPUT -o eth0 -p tcp --sport 48005:48025 -m state --state RELATED,ESTABLISHED -j ACCEPT -m recent --set --name HTTPS
echo -e "\tAllow allow outside users to be able to ping the server"
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
# Testcase ping $IP
echo -e "\tAllow ping from inside to outside"
iptables -A OUTPUT -o eth0 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i eth0 -p icmp --icmp-type echo-reply -j ACCEPT
# Testcase ping mwgwinvtdc01.internal.mywebgrocer.com
echo -e "\tAllow local loopback access"
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
echo -e "\tAllow outbound DNS"
iptables -A OUTPUT -p udp -o eth0 --dport 53 -j ACCEPT
iptables -A INPUT -p udp -i eth0 --sport 53 -j ACCEPT
# Testcase ping mwgwinvtdc01.internal.mywebgrocer.com
echo -e "\tAllow Sendmail or Postfix Traffic"
# iptables -A INPUT -i eth0 -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 25 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 25 -m state --state ESTABLISHED -j ACCEPT
# Testcase
echo Save the iptables settings
service iptables save
# list the active rules
iptables -L -n -v --line-numbers
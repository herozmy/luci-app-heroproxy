#!/bin/sh

# 删除 NAT 表中的规则
iptables -t nat -D PREROUTING -p tcp -m set --match-set singboxset dst -j NAT_PREROUTING 2>/dev/null
ip6tables -t nat -D PREROUTING -p tcp -m set --match-set singboxset6 dst -j NAT_PREROUTING 2>/dev/null
iptables -t nat -D OUTPUT -p tcp -m set --match-set routerproxy dst -j NAT_OUTPUT 2>/dev/null
ip6tables -t nat -D OUTPUT -p tcp -m set --match-set routerproxyv6 dst -j NAT_OUTPUT 2>/dev/null

# 删除 NAT 表中的自定义链
iptables -t nat -F NAT_PREROUTING 2>/dev/null
ip6tables -t nat -F NAT_PREROUTING 2>/dev/null
iptables -t nat -F NAT_OUTPUT 2>/dev/null
ip6tables -t nat -F NAT_OUTPUT 2>/dev/null
iptables -t nat -X NAT_PREROUTING 2>/dev/null
ip6tables -t nat -X NAT_PREROUTING 2>/dev/null
iptables -t nat -X NAT_OUTPUT 2>/dev/null
ip6tables -t nat -X NAT_OUTPUT 2>/dev/null

# 删除 mangle 表中的规则
iptables -t mangle -D PREROUTING -p udp -m set --match-set singboxset dst -j SING_BOX 2>/dev/null
ip6tables -t mangle -D PREROUTING -p udp -m set --match-set singboxset6 dst -j SING_BOX_V6 2>/dev/null
iptables -t mangle -D OUTPUT -p udp -m set --match-set routerproxy dst -j ROUTER_PROXY_IPV4 2>/dev/null
ip6tables -t mangle -D OUTPUT -p udp -m set --match-set routerproxyv6 dst -j ROUTER_PROXY_IPV6 2>/dev/null

# 删除 mangle 表中的自定义链
iptables -t mangle -F SING_BOX 2>/dev/null
ip6tables -t mangle -F SING_BOX_V6 2>/dev/null
iptables -t mangle -F ROUTER_PROXY_IPV4 2>/dev/null
ip6tables -t mangle -F ROUTER_PROXY_IPV6 2>/dev/null
iptables -t mangle -X SING_BOX 2>/dev/null
ip6tables -t mangle -X SING_BOX_V6 2>/dev/null
iptables -t mangle -X ROUTER_PROXY_IPV4 2>/dev/null
ip6tables -t mangle -X ROUTER_PROXY_IPV6 2>/dev/null

# 删除 ipset 规则集
ipset destroy singboxset 2>/dev/null
ipset destroy singboxset6 2>/dev/null
ipset destroy routerproxy 2>/dev/null
ipset destroy routerproxyv6 2>/dev/null

# 删除 NTP 重定向规则
iptables -t nat -D PREROUTING -p udp --dport 123 -j REDIRECT --to-ports 123 2>/dev/null 
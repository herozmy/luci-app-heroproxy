iptables -t nat -A PREROUTING -p udp --dport 123 -j REDIRECT --to-ports 123
# 恢复ipset
ipset list singboxset >/dev/null 2>&1 || ipset restore -f /etc/heroproxy/iptables/ipset.singboxset
ipset list singboxset6 >/dev/null 2>&1 || ipset restore -f /etc/heroproxy/iptables/ipset.singboxset6
ipset list routerproxy >/dev/null 2>&1 || ipset restore -f /etc/heroproxy/iptables/ipset.routerproxy
ipset list routerproxyv6 >/dev/null 2>&1 || ipset restore -f /etc/heroproxy/iptables/ipset.routerproxyv6

# 检查自定义的链与规则是否存在，不存时创建链，并添加规则 IPV4
iptables -t mangle -L SING_BOX >/dev/null 2>&1 || iptables -t mangle -N SING_BOX
iptables -t mangle -C SING_BOX -p udp -j TPROXY --tproxy-mark 1 --on-ip 127.0.0.1 --on-port 7896 >/dev/null 2>&1 || iptables -t mangle -A SING_BOX -p udp -j TPROXY --tproxy-mark 1 --on-ip 127.0.0.1 --on-port 7896

# 检查自定义的链与规则是否存在，不存时创建链，并添加规则 IPV6
ip6tables -t mangle -L SING_BOX_V6 >/dev/null 2>&1 || ip6tables -t mangle -N SING_BOX_V6
ip6tables -t mangle -C SING_BOX_V6 -p udp -j TPROXY --on-port 7896 --on-ip ::1 --tproxy-mark 1 >/dev/null 2>&1 || ip6tables -t mangle -A SING_BOX_V6 -p udp -j TPROXY --on-port 7896 --on-ip ::1 --tproxy-mark 1

# 主路由科学能力添加，检查自定义的链与规则是否存在，不存时创建链，并添加规则 IPV4
iptables -t mangle -L ROUTER_PROXY_IPV4 >/dev/null 2>&1 || iptables -t mangle -N ROUTER_PROXY_IPV4
iptables -t mangle -C ROUTER_PROXY_IPV4 -j MARK --set-mark 1 >/dev/null 2>&1 || iptables -t mangle -A ROUTER_PROXY_IPV4 -j MARK --set-mark 1

# 主路由科学能力添加，检查自定义的链与规则是否存在，不存时创建链，并添加规则 IPV6
ip6tables -t mangle -L ROUTER_PROXY_IPV6 >/dev/null 2>&1 || ip6tables -t mangle -N ROUTER_PROXY_IPV6
ip6tables -t mangle -C ROUTER_PROXY_IPV6 -j MARK --set-mark 1 >/dev/null 2>&1 || ip6tables -t mangle -A ROUTER_PROXY_IPV6 -j MARK --set-mark 1

# 在标准链PREROUTING和OUTPUT中劫持fakeip段、奈飞IP段、电报IP段、国外DNS IP至相应的自定义链，OUTPUT链只劫持fakeip段、国外DNS IP
iptables -t mangle -C PREROUTING -p udp -m set --match-set singboxset dst -j SING_BOX >/dev/null 2>&1 || iptables -t mangle -A PREROUTING -p udp -m set --match-set singboxset dst -j SING_BOX
ip6tables -t mangle -C PREROUTING -p udp -m set --match-set singboxset6 dst -j SING_BOX_V6 >/dev/null 2>&1 || ip6tables -t mangle -A PREROUTING -p udp -m set --match-set singboxset6 dst -j SING_BOX_V6
iptables -t mangle -C OUTPUT -p udp -m set --match-set routerproxy dst -j ROUTER_PROXY_IPV4 >/dev/null 2>&1 || iptables -t mangle -A OUTPUT -p udp -m set --match-set routerproxy dst -j ROUTER_PROXY_IPV4
ip6tables -t mangle -C OUTPUT -p udp -m set --match-set routerproxyv6 dst -j ROUTER_PROXY_IPV6 >/dev/null 2>&1 || ip6tables -t mangle -A OUTPUT -p udp -m set --match-set routerproxyv6 dst -j ROUTER_PROXY_IPV6

# 创建并添加重定向规则
iptables -t nat -L NAT_PREROUTING >/dev/null 2>&1 || iptables -t nat -N NAT_PREROUTING
ip6tables -t nat -L NAT_PREROUTING >/dev/null 2>&1 || ip6tables -t nat -N NAT_PREROUTING
iptables -t nat -L NAT_OUTPUT >/dev/null 2>&1 || iptables -t nat -N NAT_OUTPUT
ip6tables -t nat -L NAT_OUTPUT >/dev/null 2>&1 || ip6tables -t nat -N NAT_OUTPUT

iptables -t nat -C PREROUTING -p tcp -m set --match-set singboxset dst -j NAT_PREROUTING >/dev/null 2>&1 || iptables -t nat -A PREROUTING -p tcp -m set --match-set singboxset dst -j NAT_PREROUTING
ip6tables -t nat -C PREROUTING -p tcp -m set --match-set singboxset6 dst -j NAT_PREROUTING >/dev/null 2>&1 || ip6tables -t nat -A PREROUTING -p tcp -m set --match-set singboxset6 dst -j NAT_PREROUTING
iptables -t nat -C OUTPUT -p tcp -m set --match-set routerproxy dst -j NAT_OUTPUT >/dev/null 2>&1 || iptables -t nat -A OUTPUT -p tcp -m set --match-set routerproxy dst -j NAT_OUTPUT
ip6tables -t nat -C OUTPUT -p tcp -m set --match-set routerproxyv6 dst -j NAT_OUTPUT >/dev/null 2>&1 || ip6tables -t nat -A OUTPUT -p tcp -m set --match-set routerproxyv6 dst -j NAT_OUTPUT

iptables -t nat -C NAT_PREROUTING -p tcp -j REDIRECT --to-port 7899 >/dev/null 2>&1 || iptables -t nat -A NAT_PREROUTING -p tcp -j REDIRECT --to-port 7899
ip6tables -t nat -C NAT_PREROUTING -p tcp -j REDIRECT --to-port 7899 >/dev/null 2>&1 || ip6tables -t nat -A NAT_PREROUTING -p tcp -j REDIRECT --to-port 7899
iptables -t nat -C NAT_OUTPUT -p tcp -j REDIRECT --to-port 7899 >/dev/null 2>&1 || iptables -t nat -A NAT_OUTPUT -p tcp -j REDIRECT --to-port 7899
ip6tables -t nat -C NAT_OUTPUT -p tcp -j REDIRECT --to-port 7899 >/dev/null 2>&1 || ip6tables -t nat -A NAT_OUTPUT -p tcp -j REDIRECT --to-port 7899
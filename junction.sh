#!/bin/bash

#set -x

IPTABLES=/sbin/iptables

threshold=200
port_std=2200
port_byp=2300
#num_msgs=`postqueue -p | tail -n 1 | awk '{print $5}'`
num_msgs=100
rule_prfx="ACCEPT\s* tcp\s --\s 0.0.0.0/0\s*0.0.0.0/0\s*tcp\sdpt:"
# Example output of what we are trying to parse in the following, three, lines.
# 32   ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:2200
#rule=`$IPTABLES -L INPUT -n | tail -n +3 | egrep -n "2200|2300"`
rule=`$IPTABLES -n -L INPUT --line-numbers | egrep "$rule_prfx($port_std|$port_byp)"`
rule_num=`echo $rule | awk '{print $1}'`
rule_port=`echo $rule | awk -F':' '{print $2}'`

# echo $rule
# echo $rule_num
#c echo $rule_port


# above threshold and rule listening on std port
if [ "$num_msgs" -ge "$threshold" ] && [ "$rule_port" -eq "$port_std" ] ; then
    $IPTABLES -R INPUT $rule_num -p tcp -m tcp --dport $port_byp -j ACCEPT
fi

# below threshold and rule listening on bypass port
if [ "$num_msgs" -lt "$threshold" ] && [ "$rule_port" -eq "$port_byp" ] ; then
    $IPTABLES -R INPUT $rule_num -p tcp -m tcp --dport $port_std -j ACCEPT
fi

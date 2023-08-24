#!/bin/bash

 for ip_f2basterisktcp in $(iptables -L f2b-asterisk-tcp -n | awk '{print $4}' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}");
 do
  arr_f2basterisktcp+=("$ip_f2basterisktcp");
 done
 for ip_mess in $(cat /var/log/asterisk/messages | grep Wrong | awk '{print $(NF-3)}' | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"); 
  do
   arr_mess+=("$ip_mess");
  done

unset dupes 
declare -A dupes

for i in "${arr_f2basterisktcp[@]}"; do
    if [[ -z ${dupes[$i]} ]]; then
        arr_f2basterisktcp2+=("$i")
    fi
    dupes["$i"]=1
done

for j in "${arr_mess[@]}"; do
    if [[ -z ${dupes[$j]} ]]; then
        arr_mess2+=("$j")
    fi
    dupes["$j"]=1
done

unset dupes 

for ((j=0; j<${#arr_mess2[@]}; j++));
 do
  for ((i=0; i<${#arr_f2basterisktcp2[@]}; i++));
     do
      if [[ ${arr_f2basterisktcp2[$i]} == ${arr_mess2[$j]} ]];then
       echo "!";
      else
       if [ $(echo "${arr_mess2[$j]}" | cut -f1 -d.) != 10 ]&&[ $(echo "${arr_mess2[$j]}" | cut -f1,2 -d.) != 192.168 ]; then
        echo "${arr_mess2[$j]}" Banned!;
        iptables -I f2b-asterisk-udp 1 -s ${arr_mess2[$j]} -j DROP;
        iptables -I f2b-asterisk-tcp 1 -s ${arr_mess2[$j]} -j DROP;
       fi
      fi
     break;
    done
 done

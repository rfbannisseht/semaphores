#!/usr/bin/env bash

#
#check in pg hoe groot onderstaande is 
#shared_buffers = x
#effective_cache_size = x
nrTot=`ps -ef |wc -l` 

_real_mem_ () { 

export r_m=$(( $(getconf PAGE_SIZE) * $(getconf _PHYS_PAGES)))
echo real mem is $r_m

} 

_used_mem_ () { 

export U_M="`ps -eo size --sort -size|awk -v c=$nrTot '{ nT=$1 ; printf("%20.0f MB ",nT)} {for (c;c<=NF;c++) {printf("%s ",$c) } print "" }'|awk '{t=t + $1} END {print t}'`"
echo " Total used by process ${U_M} in Bytes "

}

_calc_it_ () { 

p_s=`getconf PAGE_SIZE`
p_p=`getconf _PHYS_PAGES`

if [ ! -z "$p_p" ] || [ ! -z "$p_s" ];
then
	shmall=$((2*$p_p/3))
	#shmall=$(($p_p / 2 ))
	m_f=`expr ${r_m} - ${U_M}`
	shmmax=`expr $shmall \* $p_s` 
	#echo kernel.shmmax = $m_f
	if test ! -f /etc/sysctl.con 
	then
		echo kernel.shmall = $shmall
		echo kernel.shmax = $shmmax
	fi
else
	echo "Error: Unable to  determine page_size/phys_page_size  size" 
fi

}


#Main Run 
_real_mem_
_used_mem_
_calc_it_
#Write 2 sysctl.conf
#
#sysctl -w kernel.shmall=$shmal
#sysctl -w kernel.shmmax=$shmmax

if [  -d /etc/sysctl.d/088_test.conf ]
then
	rm -f /etc/sysctl.d/088_test.conf
else
	echo "kernel.shmall=$shmall " >> /etc/sysctl.d/088_test.conf
	echo "kernel.shmmax=$shmmax " >> /etc/sysctl.d/088_test.conf
/usr/sbin/sysctl -p 
fi

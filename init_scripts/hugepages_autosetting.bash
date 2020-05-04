#!/bin/bash

# Auto-config for HugePages. Default 80%. Exasol.
if [ -z $1 ]; then PCT_FOR_HUGEPAGES=0.8; else PCT_FOR_HUGEPAGES=$1; fi

function hugepages_monitor() {

while true; do
 for i in $(grep ^Huge /proc/meminfo | head -3 | awk '{print $2}'); do
  echo -n "$i "
 done
 echo ""
 sleep 5
done

}

function calc() {

# Check for the kernel version
KERN=`uname -r | awk -F. '{ printf("%d.%d\n",$1,$2); }'`
# Find out the HugePage size
HPG_SZ=`grep Hugepagesize /proc/meminfo | awk '{print $2}'`
if [ -z "$HPG_SZ" ];then echo "The hugepages may not be supported."; exit 1; fi

TOTAL_RAM_BYTES=`free -wt --bytes | grep "Total:" | grep -v grep | awk '{print $2}'`
HP_RAM_BYTES=`echo "$PCT_FOR_HUGEPAGES * $TOTAL_RAM_BYTES" | bc -q`
MIN_PG=`echo "$HP_RAM_BYTES/($HPG_SZ*1024)" | bc -q`
NUM_PG=`echo "$MIN_PG+1" | bc -q`

RES_BYTES=`echo "$NUM_PG * $HPG_SZ * 1024" | bc -q`

# If less than 100MB does not make sense
if [ $RES_BYTES -lt 100000000 ];then echo "Not big enough" && exit 1; fi

ID_TIBERO=`id -u tibero`
SHM_GROUP="vm.hugetlb_shm_group=$ID_TIBERO"



# Finish with results
case $KERN in
    2.4)
	HUGETLB_POOL=`echo "$NUM_PG*$HPG_SZ/1024" | bc -q`;
    echo "Recommended setting:
	vm.hugetlb_pool=$HUGETLB_POOL" ;;
    2.6)
	echo "Recommended setting:
	vm.nr_hugepages=$NUM_PG
	$SHM_GROUP
	" ;;
    3*|4.*)
	echo "Recommended setting:
	vm.nr_hugepages=$NUM_PG
	$SHM_GROUP
	" ;;
    *) echo "Kernel version $KERN is not supported by this script (yet). Exiting." ;;
esac

function sysctl_set() {

echo "#Tibero Specific - Hugepages autosetting" >> /etc/sysctl.conf

sed -i "/$1/d" /etc/sysctl.conf
echo "$1 = $2" >> /etc/sysctl.conf

}

sysctl_set "vm.nr_hugepages" "$NUM_PG"
sysctl_set "vm.hugetlb_shm_group" "$ID_TIBERO"
sysctl -p

}

case $1 in
	0.*)
		calc $1
	;;
	monitor)
		hugepages_monitor
	;;
	*)
		calc
	;;
esac


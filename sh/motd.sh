#!/bin/sh
############################################################################
# TITLE       : System Tools
# PROJECT     : MOTD
# ENGINEER    : waveclaw
# PROGRAM     : Messages of the Day
# FILE        : motd.sh 
# CREATED     : 11-JUN-2012 waveclaw
# DESCRIPTION : Bash Shell script to write the message of the day
# ASSUMPTIONS : Familiarity with bash 2.0
############################################################################
#                          RELEASE LISCENSE              
#
#       This file is available under copyright 2012. 
#       For internal use only, keep out of young children. 
#                                                                        
#       Other Copyrights to their respective owners.                           
#                                                                        
#  Current version : 0.1
#  Latest version  : 0.1
#  Bugs, Comments  : waveclaw@waveclaw.net
############################################################################
#                          RELEVANT DOCUMENTS
#                           (REFERENCES)
#
#  Name                            Comment
#  ------------------------------- -------------------------------------
#  Shellfiles in a Nutshell         primary Shell File resource          
#  VMware.com                       vmware dmidecode decode
#  UNIX Manpage for uname, dmidecode
# 
############################################################################

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/sbin

LOCKFILE="/var/run/${0}.lock"
trap "rm ${LOCKFILE}" EXIT

quit() {
echo "Another instance maybe already running."
trap - EXIT
exit 1
}

if [ -x `which lockfile` ]
then
 if lockfile -r 0 ${LOCKFILE} 1>/dev/null 2>&1
 then
  :
 else
  echo "Unable to create $LOCKFILE"
  quit
 fi
else
 if [ -f $LOCKFILE ]
 then
  echo "Lockfile $LOCKFILE found. Aborting"
  quit
 else
  touch $LOCKFILE
 fi
fi

MOTD=/etc/motd
host=`hostname`
if [ -e /etc/SuSE-release ]
then
OS=`head -1 /etc/SuSE-release`
elif [ -e /etc/Redhat-release ]
then 
OS=`head -1 /etc/Redhat-release`
elif [ -e /etc/debian_version ]
then
VERSION=`cat /etc/debian_version`
OS="Debian $VERSION"
elif [ -e /etc/lsb-release ]
then
OS=`grep 'DISTRIB_DESCRIPTION' /etc/lsb-release | cut -d= -f2 | sed -e 's/"//g'`
else
OS=`uname -s; uname -r`
fi

/usr/sbin/dmidecode > /tmp/dmidecode.junk.$$
manufacturer=`grep 'Manufacturer:' /tmp/dmidecode.junk.$$ | head -1 | awk '{ print $2 }'`
if echo $manufacturer | grep 'VMware*' 
then
manufacturer='' # contained in $product
fi
product=`grep 'Product Name:' /tmp/dmidecode.junk.$$ | sed -e 's/.*Product Name: \(.*\)/\1/g'| head -1`
rm /tmp/dmidecode.junk.$$

chassis="$manufacturer $product"
memory=`free | grep 'Mem:' | awk '{ print $2 }'`
memory=`echo "scale = 0; $memory / 1024" | bc -l`
memory="$memory MiB"
cputype=`grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2`
cpucount=`grep 'physical id' /proc/cpuinfo | cut -d: -f2 | sort | tail -1 | bc`
cpucount=`echo $cpucount + 1 | bc` # 0 indexed
cpucores=`grep 'cpu cores' /proc/cpuinfo | head -1 | cut -d: -f2 | bc`
if [ $cpucore -eq 0 ]
then
cpucores=1 # VMware reports no cores.
fi

cp $MOTD ${MOTD}.old
cat <<EOMOTD > $MOTD
*************************************************************************
 Hostname:$host OS:$OS Chassis:$chassis 
 MemorySize:$memory PhysicalCPUs:$cpucount Total Num CPU Cores:$cpucores                   
 CPU:$cputype 
*************************************************************************
EOMOTD

#! /bin/bash

##############################################################
# check_bandwidth_report
#
# Simple Nagios check script to monitor and record daily, weekly and monthly bandwidth, using vnstat.
# By Ahmed M. AbouZaid, 4/3/2014, under BSD license.
# 
##############################################################

#Check if vnstat state installed and cofiguerd.
if [[ -z /usr/bin/vnstat ]] || [[ -z /usr/sbin/vnstat.cron ]]
then
    echo "Please install "vnstat" first."
    exit 2
fi

#Array have Day, Received, Downloaded, Total, Avarege.
LAST_BANDWIDTH=($(vnstat -d | grep "`date "+%m/%d/%y"`" | awk '{print  $1,"|",$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}'))

#LAST_BANDWIDTH, Array output.
#02/01/14 | 839 KiB | 16.66 MiB | 17.48 MiB | 8.14 kbit/s
#02/01/14 | 440.58 MiB | 6.27 GiB | 6.70 GiB |  2.47 Mbit/s
#0        1 2      3   4 5    6   7 8    9   10 11   12

BW_DAY=$(echo ${LAST_BANDWIDTH[0]})
RX_VALUE=$(echo ${LAST_BANDWIDTH[2]})
RX_UNIT=$(echo ${LAST_BANDWIDTH[3]})
TX_VALUE=$(echo ${LAST_BANDWIDTH[5]})
TX_UNIT=$(echo ${LAST_BANDWIDTH[6]})
TOTAL_VALUE=$(echo ${LAST_BANDWIDTH[8]})
TOTAL_UNIT=$(echo ${LAST_BANDWIDTH[9]})
AVG_VALUE=$(echo ${LAST_BANDWIDTH[11]})
AVG_UNIT=$(echo ${LAST_BANDWIDTH[12]})


##############################################################
# Daily Bandwidth Report
##############################################################

#Convert rx to MiB.
case "$RX_UNIT" in
    "TiB")
	MRX_VALUE=`echo "$RX_VALUE * 1024^2" | bc`
	;;
    "GiB")
	MRX_VALUE=`echo "$RX_VALUE * 1024" | bc`
	;;
    "KiB")
	MRX_VALUE=`echo "$RX_VALUE / 1024" | bc`
	;;
    *)
	MRX_VALUE=`echo "$RX_VALUE"`
	;;
esac

#Convert tx to MiB.
case "$TX_UNIT" in
    "TiB")
	MTX_VALUE=`echo "$TX_VALUE * 1024^2" | bc`
	;;
    "GiB")
	MTX_VALUE=`echo "$TX_VALUE * 1024" | bc`
	;;
    "KiB")
	MTX_VALUE=`echo "$TX_VALUE / 1024" | bc`
	;;
    *)
	MTX_VALUE=`echo "$TX_VALUE"`
	;;
esac

#Convert total bandwidth to MiB.
case "$TOTAL_UNIT" in
    "TiB")
	MTOTAL_VALUE=`echo "$TOTAL_VALUE * 1024^2" | bc`
	;;
    "GiB")
	MTOTAL_VALUE=`echo "$TOTAL_VALUE * 1024" | bc`
	;;
    "KiB")
	MTOTAL_VALUE=`echo "$TOTAL_VALUE / 1024" | bc`
	;;
    *)
	MTOTAL_VALUE=`echo "$TOTAL_VALUE"`
	;;
esac


##############################################################
# Weekly Bandwidth Report
##############################################################

#LAST_WEEK_EXEC=$(date -d "$LAST_EXEC" +%d)
TOTAL_WEEKLY_BANDWIDTH_VALUE=$(vnstat -w | grep "current week" | tr -d '|' | awk '{print $7}')
TOTAL_WEEKLY_BANDWIDTH_UNIT=$(vnstat -w | grep "current week" | tr -d '|' | awk '{print $8}')

#Convert total weekly bandwidth to MiB.
case "$TOTAL_WEEKLY_BANDWIDTH_UNIT" in
    "TiB")
	MTOTAL_WEEKLY_BANDWIDTH_VALUE=`echo "$TOTAL_WEEKLY_BANDWIDTH_VALUE * 1024^2" | bc`
	;;
    "GiB")
	MTOTAL_WEEKLY_BANDWIDTH_VALUE=`echo "$TOTAL_WEEKLY_BANDWIDTH_VALUE * 1024" | bc`
	;;
    "KiB")
	MTOTAL_WEEKLY_BANDWIDTH_VALUE=`echo "$TOTAL_WEEKLY_BANDWIDTH_VALUE / 1024" | bc`
	;;
    *)
	MTOTAL_WEEKLY_BANDWIDTH_VALUE=`echo "$TOTAL_WEEKLY_BANDWIDTH_VALUE"`
	;;
esac


##############################################################
# Monthly Bandwidth Report
##############################################################

TOTAL_MONTHLY_BANDWIDTH_VALUE=$(vnstat -m | grep `date +%b..%y` | tr -d '|' | awk '{print $7}')
TOTAL_MONTHLY_BANDWIDTH_UNIT=$(vnstat -m | grep `date +%b..%y` | tr -d '|' | awk '{print $8}')

#Convert total monthly bandwidth to MiB.
     case "$TOTAL_MONTHLY_BANDWIDTH_UNIT" in
      "TiB")
	MTOTAL_MONTHLY_BANDWIDTH_VALUE=`echo "$TOTAL_MONTHLY_BANDWIDTH_VALUE * 1024^2" | bc`
      ;;
      "GiB")
	MTOTAL_MONTHLY_BANDWIDTH_VALUE=`echo "$TOTAL_MONTHLY_BANDWIDTH_VALUE * 1024" | bc`
      ;;
      "KiB")
	MTOTAL_MONTHLY_BANDWIDTH_VALUE=`echo "$TOTAL_MONTHLY_BANDWIDTH_VALUE / 1024" | bc`
      ;;
      *)
	MTOTAL_MONTHLY_BANDWIDTH_VALUE=`echo "$TOTAL_MONTHLY_BANDWIDTH_VALUE"`
      ;;
    esac


##############################################################
# Final result.
##############################################################

echo "Received: $RX_VALUE $RX_UNIT, Downloaded: $TX_VALUE $TX_UNIT, Total: $TOTAL_VALUE $TOTAL_UNIT, Avarege: $AVG_VALUE $AVG_UNIT This week: $TOTAL_WEEKLY_BANDWIDTH_VALUE $TOTAL_WEEKLY_BANDWIDTH_UNIT This Month: $TOTAL_MONTHLY_BANDWIDTH_VALUE $TOTAL_MONTHLY_BANDWIDTH_UNIT | 'received_daily'=$MRX_VALUE 'downloaded_daily'=$MTX_VALUE 'total_daily'=$MTOTAL_VALUE 'avarege_daily'=$MTOTAL_VALUE 'total_week'=$MTOTAL_WEEKLY_BANDWIDTH_VALUE 'total_month'=$MTOTAL_MONTHLY_BANDWIDTH_VALUE"

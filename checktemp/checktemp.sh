#!/bin/bash

# file checktemp.sh

# check last temperature from log file last line
# if temperature is higher than TEMPWARNING send a warning message
# if temperature is higher than TEMPCRITICAL send a critical message
# if temperature is older than 10 minutess send a warning message

# 2019.07.10 first version

# configurable

TEMPWARNING="10"
TEMPCRITICAL="15"

PROGRAM="checktemp"
LOGFILE="checktemp.log"
TSOURCE="/var/log/temperatures.log"

# movistar SMS service
SMS_LOGIN=6YZXYZXYZ
SMS_PASSWD=grSuperCCJPasswordaFt
SMS_TO="XXXXXXXXX"

# Load checktemp user configuration to override default configuration.
CHECKTEMP_CONFIG="./checktemp.conf"
[ -f "$CHECKTEMP_CONFIG" ] && . "$CHECKTEMP_CONFIG"

# other values

LASTTEMPFILE="checktemp.lasttemp"
# crear el fichero $LASTTEMPFILE si no existe
test -f $LASTTEMPFILE || echo "5" > $LASTTEMPFILE
LASTTEMP=$(cat $LASTTEMPFILE 2>&1)

LASTSTATUSFILE="checktemp.last"
# crear el fichero $LASTSTATUSFILE si no existe
test -f $LASTSTATUSFILE || echo "OK" > $LASTSTATUSFILE
LASTSTATUS=$(cat $LASTSTATUSFILE 2>&1)

msg () {
 echo "[`date +%Y-%m-%d_%T` $PROGRAM] $@"
}

log () {
 echo "[`date +%Y-%m-%d_%T` $PROGRAM] $@" >> $LOGFILE
}

log_msg () {
 echo "[`date +%Y-%m-%d_%T` $PROGRAM] $@"
 echo "[`date +%Y-%m-%d_%T` $PROGRAM] $@" >> $LOGFILE
}

set_status() {
 echo "$@" > $LASTSTATUSFILE
}

set_temp() {
 echo "$@" > $LASTTEMPFILE
}

# old URL movistar SMS: http://open.movilforum.com/wiki/index.php/Portada
# new URL movistar SMS https://enviamensajes.movistar.es/EnviaMensajes/
send_SMS () {
 local cout cret
 local smstext="$@"
 #cambiar espacios por el signo mas (urlencoded)
 smstext=$(echo "$smstext" | sed 's/ /\+/g')
 # TODO SMS_TO can be a list of phone numbers (loop needed)
 cout=$(/usr/bin/curl -m 20 -s -S -k -d "TM_ACTION=AUTHENTICATE&TM_LOGIN=${SMS_LOGIN}&TM_PASSWORD=${SMS_PASSWD}&to=${SMS_TO}&message=$smstext" https://opensms.movistar.es/aplicacionpost/loginEnvio.jsp 2>&1)
 cret="$?"
 if [ "x$cret" != "x0" -o "A$cout" != "AOK" ];  then
   log_msg "SMS ERROR could not be sent: $cout"
 else
   log "SMS OK msg sent: $smstext"
 fi
}

# check TSOURCE (temperature source file) exists
if [ ! -f "$TSOURCE" ]; then # if TSOURCE file doesn't exists
    if [ "A$LASTSTATUS" != "AERROR" ] ; then
     set_status "ERROR"
     send_SMS "Nevera temperature file not found"
     log_msg "ERROR temperature file $TSOURCE not found"
    else
     log "ERROR temperature file $TSOURCE not found"
    fi
    exit 2
fi

LASTSTATUS=$(cat $LASTSTATUSFILE 2>&1)

TSOURCE_LAST_LINE=$(tail -n 1 $TSOURCE)

# take temperature (8.18*C) from a line like this "2019-07-10 20:46.03;20190710204603;2019.07.10T20.46.03;8.18"
TEMPERATURE=$(echo "$TSOURCE_LAST_LINE" | cut -d";" -f 4)
TEMPERATUREDATE=$(echo "$TSOURCE_LAST_LINE" | cut -d";" -f 3)

floatre='^[0-9]+([.][0-9]+)?$'
numberre='^[0-9]+$'

if ! [[ $TEMPERATURE =~ $floatre ]] ; then # if TEMPERATURE is not a number
        if [ "A$LASTSTATUS" != "AUNKNOWN" ] ; then
         set_status "UNKNOWN"
         send_SMS "Nevera temperature not a number"
         log_msg "UNKNOWN Temp: ${TEMPERATURE}C"
        else
         log "UNKNOWN Temp: ${TEMPERATURE}C"
        fi
        exit 1
fi

# check if temperature date is more than 10 minutes old
# be sure both systems use same timezone and use ntp or similar

# get date number (YYYYmmddHHMMSS) from a line like this "2019-07-10 20:46.03;20190710204603;2019.07.10T20.46.03;8.18"
temperaturenumber=$(echo "$TSOURCE_LAST_LINE" | cut -d";" -f 2 | cut -c -12 ) # remove last two digits from second field
datere='^[0-9]{12}$' # date in YYYYmmddHHMM

if ! [[ $temperaturenumber =~ $datere ]] ; then # if temperaturenumber is not a date
        if [ "A$LASTSTATUS" != "AUNKNOWN" ] ; then
         set_status "UNKNOWN"
         send_SMS "Nevera temperature date is not a valid date"
         log_msg "UNKNOWN Temp date ${TEMPERATUREDATE}"
        else
         log "UNKNOWN Temp date ${TEMPERATUREDATE}"
        fi
        exit 2
fi

datenow=$(date +%Y%m%d%H%M) # now in YYYYmmddHHMM format (minutes, not seconds)
datediff=`expr $datenow - $temperaturenumber`

if [ "$datediff" -gt 10 ]; then # ten minutes 10
        if [ "A$LASTSTATUS" != "AWARNING" ] ; then
         set_status "WARNING"
         set_temp "$TEMPERATURE"
         send_SMS "WARNING Nevera temperature date old ${TEMPERATURE}C $TEMPERATUREDATE"
         log_msg "WARNING Nevera temperature date old ${TEMPERATURE}C $TEMPERATUREDATE"
        elif [ "A$TEMPERATURE" != "A$LASTTEMP" ] ;  then
         set_temp "$TEMPERATURE"
         log_msg "WARNING Nevera temperature date old ${TEMPERATURE}C $TEMPERATUREDATE"
        else
         log "WARNING Nevera temperature date old ${TEMPERATURE}C $TEMPERATUREDATE"
        fi
        exit 0
fi

TEMPERATURE=$(printf "%.0f" "$TEMPERATURE")

if [ $TEMPERATURE -ge $TEMPCRITICAL ]; then
        if [ "A$LASTSTATUS" != "ACRITICAL" ] ; then
         set_status "CRITICAL"
         set_temp "$TEMPERATURE"
         send_SMS "CRITICAL Nevera ${TEMPERATURE}C  $TEMPERATUREDATE"
         log_msg "CRITICAL Nevera ${TEMPERATURE}C  $TEMPERATUREDATE"
        elif [ "A$TEMPERATURE" != "A$LASTTEMP" ] ;  then
         set_temp "$TEMPERATURE"
         log_msg "CRITICAL Nevera ${TEMPERATURE}C $TEMPERATUREDATE"
        else
         log "CRITICAL Nevera ${TEMPERATURE}C $TEMPERATUREDATE"
        fi
        exit 0
elif [ $TEMPERATURE -ge $TEMPWARNING ]; then
        if [ "A$LASTSTATUS" != "AWARNING" ] ; then
         set_status "WARNING"
         set_temp "$TEMPERATURE"
         send_SMS "WARNING Nevera ${TEMPERATURE}C $TEMPERATUREDATE"
         log_msg "WARNING Nevera ${TEMPERATURE}C $TEMPERATUREDATE"
        elif [ "A$TEMPERATURE" != "A$LASTTEMP" ] ;  then
         set_temp "$TEMPERATURE"
         log_msg "WARNING Nevera ${TEMPERATURE}C $TEMPERATUREDATE"
        else
         log "WARNING Nevera ${TEMPERATURE}C $TEMPERATUREDATE"
        fi
        exit 0
fi

if [ "B$LASTSTATUS" != "BOK" ] ; then
    set_status "OK"
    set_temp "$TEMPERATURE"
    send_SMS "OK Nevera ${TEMPERATURE}C $TEMPERATUREDATE"
    log_msg "OK Nevera ${TEMPERATURE}C $TEMPERATUREDATE"
else
    log "OK Nevera ${TEMPERATURE}C $TEMPERATUREDATE"
fi

exit 0


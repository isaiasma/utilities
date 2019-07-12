# checktemp.sh

check last temperature from log file, from the last line

* if temperature is higher than TEMPWARNING send a warning message
* if temperature is higher than TEMPCRITICAL send a critical message
* if temperature is older than 10 minutes send a warning message

## Getting Started

With a raspberry pi, with a SHT15 temperature and humidity sensor, wirte dates and temperatures to a log file using this format:

```
2019-07-10 20:46.03;20190710204603;2019.07.10T20.46.03;8.18
```

it is:

```
date_format1;date_format2;date_format2;temperature_celsius
```

The script get temperature (8.18*C) and date (2019-07-10 20:46.03) from a line like this "2019-07-10 20:46.03;20190710204603;2019.07.10T20.46.03;8.18"

### Prerequisitee

A program to read temperatures from sensor to send those temperatures to a log file.

This script read the last line of a log file with dates and temperatures and send SMS email with warnings if necesary.

### Installing

Clone this project.

Rename checktemp.conf.example to checktemp.conf and change configuration

cron run the script every 5 minutes:

```
$ cat /etc/cron.d/checktemp
# /etc/cron.d/checktemp

#SHELL=/bin/bash
#PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# checktemp.sh every 5 minutes
*/5 * * * * username cd /home/username/checktemp && ./checktemp.sh
```

## Authors

* **Isaías M. A.** - *Initial work*

## License

This project is licensed under the BSD License

## Acknowledgments

* linux community
* raspberry pi
* etc


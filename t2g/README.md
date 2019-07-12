# t2g.sh

Temperature 2 Graph

Read dates and temperatures from a CSV file creating a PNG image file with a time / temperature graph

## Getting Started

With a raspberry pi, with a SHT15 temperature and humidity sensor, wirte dates and temperatures to a log file using this format:

```
2019-07-10 20:46.03;20190710204603;2019.07.10T20.46.03;8.18
```

it is:

```
date_format1;date_format2;date_format2;temperature_celsius
```

The script get temperatures (8.18*C) and dates (2019-07-10 20:46.03) from lines like this "2019-07-10 20:46.03;20190710204603;2019.07.10T20.46.03;8.18"

### Prerequisitee

A program to read temperatures from sensor to send those temperatures to a log file.

The gnuplot command installed.

This script read the today and yesterday temperatures from the log file generating a graph with both days temperatures.

### Installing

Clone this project.

Rename t2g.conf.example to t2g.conf and change configuration.

Run the script to generate the graph.

## Authors

* **Isaías M. A.** - *Initial work*

## License

This project is licensed under the BSD License

## Acknowledgments

* linux community
* gnuplot
* raspberry pi
* etc


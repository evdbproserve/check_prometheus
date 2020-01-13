# check_prometheus

Nagios/Icinga check voor Prometheus

check_prometheus is a Nagios/Icinga script which will check the readyness and the health of Prometheus.

**Requirements**

* curl
* nc (if you want to check if your home is up, before checking readyness/health)

**Installation**

Copy check_prometheus.sh to you Nagios/Icinga nrpe directory, make it executable (chmod +x) and run it.
Without any paramenters, it will give you the usage text.

`./check_prometheus.sh`

**Usage**

`./check_prometheus.sh -c -h myprometheus.server.nl -p 80`

-c tells the sccript that you want to check the availablilty of your Prometheus host before continuing with the readyness and health-check. If you do not use -c, the availibility check will not take place.

-h Hostmake of IP-address. You can you http:// or https:// in front, but is not neccesary. This is required.

-p Portnumber. It can be 9090 or an other port. But define it here. This is required.
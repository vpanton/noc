#!/bin/bash
/etc/init.d/postgresql start
/etc/init.d/mongodb start
/etc/init.d/noc-launcher start
/etc/init.d/nginx start
tail -f /srv/noc/log/noc-launcher.log

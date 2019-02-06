#!/bin/bash
systemctl restart redis-server-goo.service
systemctl restart redis-server-http.service
systemctl restart memcached.service

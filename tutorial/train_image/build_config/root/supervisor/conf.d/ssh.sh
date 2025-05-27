#!/bin/bash

/etc/supervisor/conf.d/user_chpasswd.sh

/usr/sbin/sshd -D

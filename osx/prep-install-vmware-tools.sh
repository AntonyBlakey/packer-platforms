#!/bin/sh

nvram boot-args=rootless=0

# If I don't do it like this then the sleep command throws an exception on 10.8

( shutdown -r now )&
/bin/sleep 60

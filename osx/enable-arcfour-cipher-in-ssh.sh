#!/bin/bash

# re-enable a cipher (arcfour) that the vagrant client uses
if [ -e /etc/ssh/sshd_config ]; then
   echo "Ciphers arcfour,aes128-ctr,aes192-ctr,aes256-ctr" >> /etc/ssh/sshd_config
else
   echo "Ciphers arcfour,aes128-ctr,aes192-ctr,aes256-ctr" >> /etc/sshd_config
fi

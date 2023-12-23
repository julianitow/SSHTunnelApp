#!/bin/sh

#  expect_ssh_password_atuthent.sh
#  SSHTunneling
#
#  Created by Julien Guillan on 04/10/2023.
#  
/usr/bin/expect <<EOF
set timeout -1
spawn ssh -oStrictHostKeyChecking=no -oConnectTimeout=10 $1@$2 -N -L 127.0.0.1:$4:127.0.0.1:$3 2>&1
expect {
    "password:" {
        send $5\n
        expect {
            "Permission denied" {
                exit 1;
            }
            "denied" {
                exit 2;
            }
            "already in use" {
                exit 4;
            }
            eof {
              interact
            }
        }
    }
    "refused" {
        exit 3;
    }
}
EOF

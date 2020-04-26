#!/usr/bin/env python3

import sys
import os

if __name__ == "__main__":

    if len(sys.argv) != 3:
        print("Usage: %s <SSID> <passwd>" % sys.argv[0])
        exit(1)

    os.system("nmcli con delete %s" % sys.argv[1])
    os.system("nmcli device wifi connect %s password %s" % (sys.argv[1], sys.argv[2]))



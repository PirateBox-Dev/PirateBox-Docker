#!/bin/sh

echo "Starting PirateBox...."

/opt/piratebox/init.d/piratebox_alt start

echo "Printing share folder"
while true ; do
    date
    ls -1 /opt/piratebox/share/Shared
    sleep 60
    echo "


    "
done

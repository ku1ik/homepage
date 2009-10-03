#!/bin/sh

cd output
adsf -p 4000 &
cd ..
firefox http://localhost:4000/
lessc -w assets/css/master.less


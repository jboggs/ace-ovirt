#!/bin/bash
for i in `seq $1 $2` ; do echo $3.$i node$i.$4 >> /etc/hosts; done

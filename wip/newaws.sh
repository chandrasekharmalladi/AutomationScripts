#!/bin/bash
export PATH=$PATH:/usr/local/bin

#if [ -f  /tmp/aws-warn.json ]
#then
#   sudo rm -f  /tmp/aws-warn.jsonl
#fi
#sudo touch  /tmp/aws-warn.json
#sudo chmod 777  /tmp/aws-warn.json


#    sudo curl -s "https://nibiru-prod.prsn.us/api/instances/" -H 'Authorization: Basic VVhVOTlGUjpGZWlsaW5nMTYwMkF1ZyE=' > /tmp/aws-warn.json
flname='/tmp/aws-warn.json'

while read p; 
do
   if [[  $p == *"warnings"* ]]
   then
      echo p
   fi
done < $flname

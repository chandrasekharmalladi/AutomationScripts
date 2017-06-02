#!/bin/bash
export PATH=$PATH:/usr/local/bin
set 
set -x
homeDir="/home/ubuntu/env"
 
TEAMS="42 47 87"

getname()
{
if [ -f  /tmp/deploy-iname.json ]
then
   sudo rm -f  /tmp/deploy-name.json
fi
sudo touch  /tmp/deploy-name.json
sudo chmod 777  /tmp/deploy-name.json


sudo curl -s "https://nibiru-prod.prsn.us/api/users/$1" -H 'Authorization: Basic VVhVOTlGUjpGZWlsaW5nMTYwMkF1ZyE=' > /tmp/deploy-name.json
namedet=`cat /tmp/deploy-name.json`
nameres=`echo $namedet|jsawk "return this.name"`
nameres=`echo $nameres | cut -d '"' -f2 | sed 's/,/ /g'`
}


getdet()
{
    str1="curl -s 'https://nemesis.dev-openclass.com/api/task/getall?page=$2'"
    str2=" -H 'Authorization: Basic VVhVOTlGUjpGZWlsaW5nMTYwMkF1ZyE=' -H 'Content-Type: application/json; charset=UTF-8' -H \"user.team:$1\""
    str3=" --data-binary '{\"dateTo\":\"$3\",\"dateFrom\":\"$4\",\"taskName\":\"Deploy New Application\"}' --compressed > /tmp/deploy-$1.json "
    gurl=$str1$str2$str3
    eval $gurl


    depdet=`cat /tmp/deploy-$1.json`

    declare -a depdate
    declare -a mdepuser
    declare -a mapp
    declare -a menv
    declare -a mver

    res=`echo $depdet|jsawk "return this.items"`
    res=`echo $res|jsawk "if (this.taskName != 'Deploy New Application') return null"`
    res=`echo $res|jsawk "if (this.status != 'Completed') return null"`

    depdate=`echo $res|jsawk "return this.startTime"`
    depdate=`echo $depdate | cut -d '[' -f2 | cut -d ']' -f1 | sed 's/"//g'`
    depdesc=`echo $res|jsawk "return this.description"`
    depdesc=`echo $depdesc | cut -d '[' -f2 | cut -d ']' -f1 | sed 's/ /#/g'| sed 's/"//g'`
    depuser=`echo $res|jsawk "return this.initiatedBy"`
    depuser=`echo $depuser | cut -d '[' -f2 | cut -d ']' -f1 | sed 's/"//g'`


    cnt=0
    for i in ${depdate//,/ }
    do
        mdepdate[$cnt]=`echo $i | cut -d"T" -f1`
        cnt=$[ cnt + 1 ]
    done

    cnt=0
    for i in ${depuser//,/ }
    do
        getname $i
        flname=`echo $nameres | awk '{s=$1;$1=$NF;$NF=s}1'`
        mdepuser[$cnt]=$flname
        cnt=$[ cnt + 1 ]
    done

    cnt=0
    for i in ${depdesc//,/ }
    do
        mapp[$cnt]=`echo $i | cut -d"#" -f1`
        mver[$cnt]=`echo $i | cut -d"#" -f2`
        menv[$cnt]=`echo $i | cut -d"#" -f4`
        cnt=$[ cnt + 1 ]
    done

    cnt=0
    for i in ${mdepdate[@]}
    do
        if [ ! -z ${menv[$cnt]} ]
        then
           echo "Writing to deploy-repo file" 
           sudo echo ${mdepdate[$cnt]} ' ' ${menv[$cnt]} ' '  ${mapp[$cnt]} ' ' ${mver[$cnt]} ' ' ${mdepuser[$cnt]} >>  /tmp/deploy-rep.txt
        fi
        cnt=$[ cnt + 1 ]
    done

}


setpage()
{

if [ -f  /tmp/deploy-rep-sort.txt ]
then
   sudo rm -f  /tmp/deploy-rep-sort.txt
fi
sudo touch  /tmp/deploy-rep-sort.txt
sudo chmod 777 /tmp/deploy-rep-sort.txt

if [ -f  /tmp/dailydeploy.html ]
then
   sudo rm -f  /tmp/dailydeploy.html
fi
sudo touch  /tmp/dailydeploy.html
sudo chmod 777  /tmp/dailydeploy.html

#header

echo '<title>Daily Deployment Dashboard</title>' >>  /tmp/dailydeploy.html
echo '<table border=1>' >>  /tmp/dailydeploy.html
echo '<td bgcolor=AQUA>Date</td>' >>  /tmp/dailydeploy.html
echo '<td bgcolor=AQUA>Environment</td>' >>  /tmp/dailydeploy.html
echo '<td bgcolor=AQUA>Application</td>' >>  /tmp/dailydeploy.html
echo '<td bgcolor=AQUA>Version</td>' >>  /tmp/dailydeploy.html
echo '<td bgcolor=AQUA>Deployed By</td>' >>  /tmp/dailydeploy.html
echo '</tr>' >>  /tmp/dailydeploy.html
echo '<tr>' >>  /tmp/dailydeploy.html


cat /tmp/deploy-rep.txt | sort -k1,1r -k2,2 >>  /tmp/deploy-rep-sort.txt

cat /tmp/deploy-rep-sort.txt | while read line
do
   cntr=1
   flname=`echo $line | cut -d" " -f 5-`
   for i in $line
   do
     if [ $cntr -le 4 ]
     then
       echo -n '<td>'$i'</td> ' >>  /tmp/dailydeploy.html
     elif [ $cntr -eq 5 ]
     then
        echo -n '<td>'$flname'</td>'  >>  /tmp/dailydeploy.html
     fi
     cntr=$[ cntr + 1 ]
   done
   echo ' ' >>  /tmp/dailydeploy.html
   echo -n '</tr> ' >>  /tmp/dailydeploy.html
done

echo "</table>"  >>  /tmp/dailydeploy.html
echo "<font size=-1>Last updated at `date`</font>"}  >>  /tmp/dailydeploy.html
}


if [ -f  /tmp/deploy-rep.txt ]
then
   sudo rm -f  /tmp/deploy-rep.txt
fi
sudo touch  /tmp/deploy-rep.txt
sudo chmod 777 /tmp/deploy-rep.txt


for TEAM in ${TEAMS}; do
    now="$(date +"%Y-%m-%d")"T23:00:00.000Z
    pastdate="$(date +"%Y-%m-%d" -d "7 days ago")"T23:00:00.000Z

    curl -s 'https://nemesis.dev-openclass.com/api/task/getall?page=1' -H 'Authorization: Basic VVhVOTlGUjpGZWlsaW5nMTYwMkF1ZyE=' -H 'Content-Type: application/json; charset=UTF-8' -H "user.team:$TEAM" --data-binary "{\"dateTo\":\"$now\",\"dateFrom\":\"$pastdate\",\"taskName\":\"Deploy New Application\"}" --compressed > /tmp/deploy-$TEAM.json

    depdet=`cat /tmp/deploy-$TEAM.json`
    res=`echo $depdet|jsawk "return this.items"`
    totcnt=`echo $depdet|jsawk "return this.totalCount"`
    totloop=$((totcnt / 10 ))
    if [ $totcnt % 10 != 0  ]
    then
        totloop=$((totloop + 1))
    fi
    mst=1
    p=$mst
    while [[ $p -le $totloop ]]
    do
          getdet $TEAM $p $now $pastdate
          p=$[ p + 1 ]
    done
done
setpage
cpcmd="sudo cp /tmp/dailydeploy.html /usr/share/nginx/www"
eval $cpcmd


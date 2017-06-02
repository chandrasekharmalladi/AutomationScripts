#!/bin/bash
export PATH=$PATH:/usr/local/bin
set 
set -x
homeDir="/home/ubuntu/env"
 


#sudo curl -s "https://nibiru-prod.prsn.us/api/instances/" -H 'Authorization: Basic VVhVOTlGUjpGZWlsaW5nMTYwMkF1ZyE='



getdet()
{
  
if [ -f  /tmp/aws-warn.txt ]
then
   sudo rm -f  /tmp/aws-warn.txtl
fi
sudo touch  /tmp/aws-warn.txt
sudo chmod 777  /tmp/aws-warn.txt


    sudo curl -s "https://nibiru-prod.prsn.us/api/instances/" -H 'Authorization: Basic VVhVOTlGUjpGZWlsaW5nMTYwMkF1ZyE=' > /tmp/aws-warn.json


    instdet=`cat /tmp/aws-warn.json`


    declare -a instapp
    declare -a instlabel
    declare -a instid
    declare -a instip
    declare -a instloc
    declare -a instwarn

    res=`echo $instdet|jsawk "return this._embedded"`
    res=`echo $res|jsawk "return this.instances"`
    res=`echo $res|jsawk "if ( this.warnings == "" ) return null"`
#    res=`echo $res|jsawk "return this.warnings"`
#     res=`echo $res|jsawk "if this.warnings"`
    echo '77777777777777777777777777777777777777777777777777777777777777'
    echo $res
    
    echo '@&$^&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
#    echo $res
#    res=`echo $res|jsawk "return this.puppet.size"`
#    echo $res
    echo '@&$^&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'



        if [ ! -z ${menv[$cnt]} ]
        then
           echo "Writing to aws warning file" 
#           sudo echo ${instapp} ' ' ${instlabel} ' '  ${instid} ' ' ${instip} ' ' ${instloc}  ' ' ${instwarn} >>  /tmp/aws-warn.txt
        fi

}


setpage()
{

if [ -f  /tmp/aws-warn.html ]
then
   sudo rm -f  /tmp/aws-warn.html
fi
sudo touch  /tmp/aws-warn.html
sudo chmod 777  /tmp/aws-warn.html


#header

echo '<title>Daily Report of Deprcated AWS instances>' >>  /tmp/aws-warn.html
echo '<table border=1>' >>  /tmp/aws-warn.html
echo '<td bgcolor=AQUA>Application</td>' >>  /tmp/aws-warn.html
echo '<td bgcolor=AQUA>Environment</td>' >>  /tmp/aws-warn.html
echo '<td bgcolor=AQUA>Instance ID</td>' >>  /tmp/aws-warn.html
echo '<td bgcolor=AQUA>Instance IP</td>' >>  /tmp/aws-warn.html
echo '<td bgcolor=AQUA>Instance Location</td>' >>  /tmp/aws-warn.html
echo '<td bgcolor=AQUA>Warning</td>' >>  /tmp/aws-warn.html
echo '</tr>' >>  /tmp/aws-warn.html
echo '<tr>' >>  /tmp/aws-warn.html


cat /tmp/aws-warn.txt | while read line
do
   cntr=1
   flname=`echo $line | cut -d" " -f 5-`
   for i in $line
   do
     if [ $cntr -le 4 ]
     then
       echo -n '<td>'$i'</td> ' >>  /tmp/aws-warn.html
     elif [ $cntr -eq 5 ]
     then
        echo -n '<td>'$flname'</td>'  >>  /tmp/aws-warn.html
     fi
     cntr=$[ cntr + 1 ]
   done
   echo ' ' >>  /tmp/aws-warn.html
   echo -n '</tr> ' >>  /tmp/aws-warn.html
done

echo "</table>"  >>  /tmp/aws-warn.html
echo "<font size=-1>Last updated at `date`</font>"}  >>  /tmp/aws-warn.html
}

if [ -f  /tmp/aws-warn.txt ]
then
   sudo rm -f  /tmp/aws-warn.txtl
fi
sudo touch  /tmp/aws-warn.txt
sudo chmod 777  /tmp/aws-warn.txt


getdet
setpage
cpcmd="sudo cp /tmp/aws-warn.html /usr/share/nginx/www"
eval $cpcmd


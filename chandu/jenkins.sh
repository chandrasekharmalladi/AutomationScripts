#!/bin/bash


env_array=()
x=true;
i=1;

while $x;  do
 curl "https://nemesis.dev-openclass.com/api/task/getall?page=$i" -H 'Authorization: Basic VU1BTExDMTpNY3NANDQ4MQ==' -H 'Origin: https://nemesis.dev-openclass.com' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36' -H 'Content-Type: application/json; charset=UTF-8' -H 'x-use-backend-b: 1' -H 'Accept: */*' -H 'Referer: https://nemesis.dev-openclass.com/tasks' -H 'X-Requested-With: XMLHttpRequest' -H 'Cookie: _ga=GA1.2.1405982798.1493675531; PLAY_SESSION="2e06b37ea397acb19aa52526bed9d0c7ca3b7c8d-user.team=42&user.authenticated=true&user.id=UMALLC1&user.teams=25%2C42%2C47%2C87&user.token=3aae85b2-c358-4ecc-92cc-03b7afc43787"' -H 'Connection: keep-alive' --data-binary '{}' --compressed > file.json

	jsonfile=`sudo cat file.json`

	y=true;
	j=0;

	while $y; do
	itemsarray=`echo $jsonfile | jsawk -n "out (this.items[$j])"`
	name=`echo $itemsarray | jsawk -n "out (this.taskName)"`
        timecheck=`echo $itemsarray | jsawk -n "out (this.endTime)"`

	if [ $timecheck!="null" ]; then
	subtime=`(echo $timecheck| cut -d'T' -f 2)`
	propertime=`(echo $subtime| cut -d'.' -f 1)`
	properdate=`(echo $timecheck| cut -d'T' -f 1)`
	timedatestring="$properdate $propertime"
	t1=`date --date="$timedatestring" +%s`
	dt2=`date -u +%Y-%m-%d\ %H:%M:%S`
	t2=`date --date="$dt2" +%s`
	DIFFSEC=`expr ${t2} - ${t1}`
#	echo this is loop 2
	if [ $DIFFSEC -gt "1800" ]; then
	x=false
	y=false
	#echo fail jenkins job
	elif [ "$name" == "Activate App" ]; then

		stats=`echo $itemsarray | jsawk -n "out (this.status)"`
			if [ "$stats" == "Completed" ]; then
			description=`echo $itemsarray | jsawk -n "out (this.description)"`
			stringarray=($description)
			appname=${stringarray[0]}
				 if [ "$appname" == "las" -o "$appname" == "amservices" ]; then
				 env=${stringarray[3]}
                        	 versiondeployed=${stringarray[1]}
				 endtimestamp=`echo $itemsarray | jsawk -n "out (this.endTime)"`
				 if [[ " ${env_array[*]} " != *" $env "* ]]; then
				 #echo $appname
				 #echo $env
				 #echo $versiondeployed
				 env_array+=("$env")
				 echo ${env_array[@]}

					if [ "$env" == "qad" ]; then
                                	wget --auth-no-challenge --http-user=admin --http-password=admin http://10.199.253.221:8080/job/testjob1/build?token=trialtoken
                                 	elif [ "$env" == "qac" ]; then
                                 	wget --auth-no-challenge --http-user=admin --http-password=admin http://10.199.253.221:8080/job/testjob2/build?token=trial2
					elif [ "$env" == "dev" ]; then
					wget --auth-no-challenge --http-user=admin --http-password=admin http://10.199.253.221:8080/job/testjob3/build?token=trial3
                                 	fi
				 fi
				 
				# echo $endtimestamp	
		# array to store envs, if env exists, skip and go to next item		 
				# y=false;
               			 #x=false;
				
				fi

			fi
	fi
	fi
	j=$(($j+1));
	if [ $j -eq "10" ]; then
		y=false;
	fi
	done
i=$(($i+1));
done

#!/bin/bash
homeDir="/home/ubuntu/env"
#homeDir="/Users/uxu99fr/workspace/env2
script="df -h"
username="ubuntu"
val=75
val2=85
ROOM=3880584
TOKEN=kAC2lD6a5cGAy9l528kI3533XrQLExzoe7Nxt2ka
declare -A APPS_MAP
APPS_MAP=(["las"]="LAS" ["amservices"]="AMS" ["interactivelearning"]="GreenHorn" ["gbcalculationsconvergence"]="GB Calcs" ["gbservicesconvergence"]="GB Services" ["gbcomposite"]="GB Composite" ["assignmentcontents"]="Assignment Contents" ["itemrepo"]="Item Repo" ["mxladmin"]="MXL Admin" ["mxlprocessor"]="MXL Processor" ["scoringengine"]="Scoring Engine" ["settings"]="Settings")
APPS="las amservices interactivelearning gbcalculationsconvergence gbcomposite gbservicesconvergence assignmentcontents itemrepo mxladmin mxlprocessor scoringengine settings"

declare -A ENVS_MAP
ENVS_MAP=(["ppe"]="PPE" ["cert"]="STG" ["stgb"]="STGB" ["stgc"]="STGC" ["stgd"]="STGD")

ENVS="ppe cert stgb stgc stgd" #display table in this order

TEAMS="42 47 87"

declare -A APP_TEAM_MAP
APP_TEAM_MAP=(["adminconsole"]="47" ["gbcalculationsconvergence"]="47" ["gbcomposite"]="47" ["gbservicesconvergence"]="47" ["assignmentcontents"]="87" ["interactivelearning"]="87" ["itemrepo"]="87" ["mxladmin"]="87" ["mxlprocessor"]="87" ["scoringengine"]="87" ["settings"]="87" ["amservices"]="42")

declare -A OUTLINERVERS
#OUTLINERVERS=(["amservices-prd"]="3.2.0*" ["gbcomposite-prd"]="1.2.69*")

getTeam() {
  	env=$1
	app=$2
if [ "$app" == "las" ]
then
	echo "42"
else
        team=${APP_TEAM_MAP[$app]}
        if [ "$team" == "47" ]
        then echo $team
        else
                if [ "$env" == "prd" ]
                then echo "42"
                else
                echo ${APP_TEAM_MAP[$app]}
                fi
        fi
fi
}

getOutlinerVer() {
env=$1
app=$2
echo ${OUTLINERVERS[$app-$env]}
}

for TEAM in ${TEAMS}; do
	curl -s 'https://nemesis.dev-openclass.com/api/applications?refresh=false'  -H 'Authorization: Basic VVhVOTlGUjpGZWlsaW5nMTYwMkF1ZyE=' -H "user.team:$TEAM" > /tmp/diskspace-$TEAM.json
done

#echo "<title>Unused Server List</title>" > /tmp/unusedserverlist.html
#echo "<table border=1>" >> /tmp/unusedserverlist.html
#echo "<tr bgcolor=ORANGE/>Unused Server List" >> /tmp/unusedserverlist.html
#echo "<tr><td bgcolor=AQUA>App</td>" >> /tmp/unusedserverlist.html
 
#for ENV in ${ENVS}; do
#	echo "<td bgcolor=AQUA>${ENVS_MAP[$ENV]}</td>" >> /tmp/unusedserverlist.html
#done

#echo "</tr>" >> /tmp/unusedserverlist.html
for APP in ${APPS}; do
#	echo entered first level
	#echo "<tr><td>${APPS_MAP[$APP]}</td>" >> /tmp/unusedserverlist.html
	for ENV in ${ENVS}; do
		team=$(getTeam "$ENV" "$APP" )
#	echo entered second level
		outliner=$(getOutlinerVer "$ENV" "$APP")
		if [ -z "$outliner" ]; then
			version=`$homeDir/diskspacechecker/diskchecker.sh -e=$ENV -s=$APP -t=$team 2> /dev/null`
		else
			version=$outliner
		fi
		#echo "$version"
		#echo $version
		IPString=`echo ${version::-1}`
		#echo $IPString
		#echo $IPString
		IFS='$' read -ra IPAddresses <<< "$IPString"

		if [ "$APP" == "las" -o "$APP" == "amservices" ]; then
			key=sanvan_nibiruv2.pem 
		elif [ "$APP" == "gbcalculationsconvergence" -o "$APP" == "gbservicesconvergence" -o "$APP" == "gbcomposite" ]; then
			key=47.pem
		elif [ "$APP" == "itemrepo" -o "$APP" == "settings" -o "$APP" == "scoringengine" -o "$APP" == "interactivelearning" -o "$APP" == "mxlprocessor" -o "$APP" == "mxladmin" -o "$APP" == "assignmentcontents" ]; then
                        key=87.pem
		fi
			for i in "${IPAddresses[@]}"; do
   				# if [ "$APP" == "las" -o "$APP" == "amservices" ]; then
					echo $APP
					echo $i
					cmd=`ssh -o StrictHostKeyChecking=no -i $key ${username}@${i} "${script}"`
					percentvalue=`echo "$cmd" | awk '$NF=="/"{sub(/%/,"",$5);print $5}'`
					#exit
					echo $percentvalue
						if [ "$percentvalue" -gt "$val" ]; then
					curl -H "Content-Type: application/json" -X POST -d "{\"color\": \"yellow\", \"message_format\": \"text\", \"message\": \"WARNING: "$i" of "${APPS_MAP[$APP]}" in "${ENVS_MAP[$ENV]}" has "$percentvalue"% usage\"}" https://api.hipchat.com/v2/room/$ROOM/notification?auth_token=$TOKEN		
						 elif [ "$percentvalue" -gt "$val2" ]; then
                                        curl -H "Content-Type: application/json" -X POST -d "{\"color\": \"red\", \"message_format\": \"text\", \"message\": \"CRITICAL: "$i" of "${APPS_MAP[$APP]}" in "${ENVS_MAP[$ENV]}" has "$percentvalue"% usage\"}" https://api.hipchat.com/v2/room/$ROOM/notification?auth_token=$TOKEN
						fi
				 #fi
				#doallhere
			done
		
	done
	#echo "</tr>" >> /tmp/unusedserverlist.html
done

#echo $version
#echo "</table>" >> /tmp/unusedserverlist.html
#echo "<font size=-1>Last updated at `date`</font>" >> /tmp/unusedserverlist.html
#cpcmd="sudo cp /tmp/unusedserverlist.html /usr/share/nginx/www"
#eval $cpcmd

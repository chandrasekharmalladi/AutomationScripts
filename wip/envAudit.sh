#!/bin/bash
homeDir="/home/ubuntu/env/wip"
#homeDir="/Users/uxu99fr/workspace/env2"
 
declare -A APPS_MAP
APPS_MAP=(["las"]="LAS" ["amservices"]="AMS" ["interactivelearning"]="GreenHorn" ["gbcalculationsconvergence"]="GB Calcs" ["gbservicesconvergence"]="GB Services" ["gbcomposite"]="GB Composite" ["assignmentcontents"]="Assignment Contents" ["itemrepo"]="Item Repo" ["mxladmin"]="MXL Admin" ["mxlprocessor"]="MXL Processor" ["scoringengine"]="Scoring Engine" ["settings"]="Settings")
APPS="las amservices interactivelearning gbcalculationsconvergence gbcomposite gbservicesconvergence assignmentcontents itemrepo mxladmin mxlprocessor scoringengine settings"

declare -A ENVS_MAP
ENVS_MAP=(["prd"]="Production" ["ppe"]="PPE" ["snapshot"]="DEV" ["dev"]="QA-INT" ["cert"]="STG" ["qab"]="QAB" ["stgb"]="STGB" ["qac"]="QAC" ["stgc"]="STGC" ["qad"]="QAD" ["stgd"]="STGD")

ENVS="prd ppe snapshot dev cert qab stgb qac stgc qad stgd" #display table in this order

TEAMS="42 47 87"

declare -A APP_TEAM_MAP
APP_TEAM_MAP=(["adminconsole"]="47" ["gbcalculationsconvergence"]="47" ["gbcomposite"]="47" ["gbservicesconvergence"]="47" ["assignmentcontents"]="87" ["interactivelearning"]="87" ["itemrepo"]="87" ["mxladmin"]="87" ["mxlprocessor"]="87" ["scoringengine"]="87" ["settings"]="87" ["amservices"]="42")

declare -A OUTLINERVERS
OUTLINERVERS=(["amservices-prd"]="3.2.0*" ["gbcomposite-prd"]="1.2.69*")

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
	curl -s 'https://nemesis.dev-openclass.com/api/applications?refresh=false'  -H 'Authorization: Basic VVhVOTlGUjpGZWlsaW5nMTYwMk1heSE=' -H "user.team:$TEAM" > /tmp/apps-$TEAM.json
done

echo "<title>Environment Auditing Dashboard</title>"
echo "<table border=1>"

echo "<tr><td bgcolor=AQUA>App</td>"
 
for ENV in ${ENVS}; do
	echo "<td bgcolor=AQUA>${ENVS_MAP[$ENV]}</td>" 
done

echo "</tr>"
for APP in ${APPS}; do
	echo "<tr><td>${APPS_MAP[$APP]}</td>"
	for ENV in ${ENVS}; do
		team=$(getTeam "$ENV" "$APP" )
		outliner=$(getOutlinerVer "$ENV" "$APP")
		if [ -z "$outliner" ]; then
			version=`$homeDir/env.sh -e=$ENV -s=$APP -t=$team 2> /dev/null`
		else
			version=$outliner
		fi
		echo "<td>$version</td>" 
	done
	echo "</tr>"
done
echo "</table>"
echo "<font size=-1>* Non-compliance release methodology. Compliance coming soon. Resistance is futile.</font><p>"
echo "<font size=-1>Last updated at `date`</font>"

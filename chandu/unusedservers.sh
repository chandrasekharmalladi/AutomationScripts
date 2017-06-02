#!/bin/bash

if [ $# != 3 ]
then
        echo env.sh -e=env -s=service -t=team
        exit
fi
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
	-s| --service)
	   service=$VALUE
	   ;;
	-e| --env)
	   env=$VALUE
	   ;;
	-t| --team)
	   team=$VALUE
	   ;;
    esac
    shift
done

getEnv() 
{
	envs=`echo $1|jsawk "if (this.name != \"$2\" ) return null"|jsawk "return (this.environments)"`
	envs=`echo "${envs%?}"`
	envs=`echo "${envs:1}"`
	envs=`echo $envs|jsawk "if (this.env != \"$3\") return null"`
	envs=`echo "${envs%?}"`
	envs=`echo "${envs:1}"`
	echo $envs
 #       echo $envs > checker.json
}

PATH="/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

apps=`cat /tmp/apps-$team.json`
result=$(getEnv "$apps" "$service" "$env")
echo $result > check.json 

if [ -z "$result" ]; then
    echo "<font color=\"red\">N/A</font>"
else    

        versionsfile=`echo $result|jsawk -n "out (this.versions)"`
	versionarray=`echo $versionsfile|jsawk -n "out (this.version)"`
	elements=( $versionarray )
	arraylength=${#elements[@]}
	version=`echo $result|jsawk -n "out (this.activeVersion.version)"`
	for (( i=0; i<${arraylength}; i++ ));
	do
	version1=`echo $result|jsawk -n "out (this.versions[$i].version)"`
 #	echo $version1
#	echo $version
	appServercount=`echo $result|jsawk -n "out (this.versions[$i].total)"`
 #      echo $appServercount
  #     echo above is app server count
		if [ $version != $version1 ]; then
			echo "$version1"
			
			for ((j=0; j<${appServercount}; j++));
			do
                	hostname=`echo $result|jsawk -n "out (this.versions[$i].appServers[$j].hostname)"`
			IP=`echo $result|jsawk -n "out (this.versions[$i].appServers[$j].ipAddress)"`
			versionx="$version1 - $IP"
			echo $hostname
			echo $IP
			echo $versionx
			done	
		fi
	done
fi


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
}

PATH="/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

apps=`cat /tmp/apps-$team.json`
result=$(getEnv "$apps" "$service" "$env")
#echo $result
if [ -z "$result" ]; then
    echo "<font color=\"red\">N/A</font>"
else       
	version=`echo $result|jsawk -n "out(this.activeVersion.version)"`
	if [ -z "$version" ]; then
    	echo "<font color=\"red\">N/A</font>"
    else
    	echo $version
    fi
    
fi

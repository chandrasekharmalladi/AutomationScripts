completed=`cat /tmp/blah.json|jsawk "return this.items"|jsawk  "if (this.status != \"Completed\" ) return null"`
#echo $completed
#desc=`echo $completed|jsawk "return this.description"`
#echo $desc
desc=`echo $completed|jsawk 'return (this.initiatedBy)'`
echo $desc
readarray -t array <<<"$(jq -r '.[]' <<<"`echo $completed|jsawk 'return (this.initiatedBy)'`")"
# get length of an array
arraylength=${#array[@]}

# use for loop to read all values and indexes
for (( i=1; i<${arraylength}+1; i++ ));
do
  echo $i " / " ${arraylength} " : " ${array[$i-1]}
done

deployInfo=`echo $completed|jsawk -n "out(this.endTime,this.initiatedBy,this.description)"`
echo $deployInfo
exit;
endTime=`echo $completed|jsawk "return this.endTime"`
startBy=`echo $completed|jsawk "return this.initiatedBy"`

arraylength=${#desc[@]}

# use for loop to read all values and indexes
for (( i=1; i<${arraylength}+1; i++ ));
do
  echo $i " / " ${arraylength} " : " ${desc[$i-1]} ${endTime[$i-1]} ${startBy[$i-1]}
done

#cat ~/tmp/blah.json|jsawk "return this.items"|jsawk  "if (this.status != \"Completed\" ) return null"|jsawk "return this.description this.endTime this.initiatedBy"

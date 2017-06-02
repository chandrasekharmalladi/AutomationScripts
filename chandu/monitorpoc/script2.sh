array1=(a b)
array2=(c d)

array=(${array1[@]} ${array2[@]})


for i in ${array[@]}
do
	echo $i
done

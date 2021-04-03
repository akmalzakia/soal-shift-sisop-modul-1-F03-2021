#!/bin/bash

size=23
for(( i=1 ; i<=size; i++ ))
do
	wget -O "Koleksi_$i" -a "Foto.log" https://loremflickr.com/320/240/kitten
	for (( j=1 ; j<i ; j++ ))
	do
		if [[ j -lt 10 ]]
		then
			if cmp -s "Koleksi_$i" "Koleksi_0$j"
			then
				rm "Koleksi_$i"
				(( i-- ))
				(( size-- ))
			fi
		else
			if cmp -s "Koleksi_$i" "Koleksi_$j"
			then
				rm "Koleksi_$i"
				(( i-- ))
				(( size-- ))
				break
			fi
		fi
	done

	#Pakai AWK
	# cachefile=($(awk 'BEGIN{n=0}{if (NR - n == 6){n +=15; {print $3}}}' Foto.log))
	# cachefilesize=(${#cachefile[@]})

	# for(( j=0 ; j < $cachefilesize - 1; j++))
	# do
	# 	if [ "${cachefile[j]}" == "${cachefile[$(($cachefilesize - 1))]}" ]
	# 	then
	# 		# echo "hapus"
	# 		rm "Koleksi_$j"
	# 		(( i-- ))
	# 		(( size-- ))
	# 		break
	# 	fi
	# done

	if [[ i -lt 10 ]]
	then
		mv "Koleksi_$i" "Koleksi_0$i"
	fi
done

# files=$(find -regextype posix-extended -regex 'Koleksi_[0-9]$')
# counter=0
# for image in $files
# do
# 	if [[ counter -lt 10 ]]
# 	then
# 		mv $image "Koleksi_0$counter"
# 	else
# 		mv $image "Koleksi_$counter"
# 	fi
# 	(( counter++ ))
# done

# check_pic(){
# 	dledpic=$1
# 	pic=$2
# 	for i in {1..$1
# 	do 
# }

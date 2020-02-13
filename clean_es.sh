#!/bin/bash
temp_file=$(mktemp)
curl -s -X GET "https://vpc-k8s-dev.us-east-1.es.amazonaws.com/_cat/shards" > $temp_file
processing_date=$(date --date="60 days ago" +%s)

for i in $(awk {'print $1'} $temp_file | grep -Po '.+?(?=-\d{4})' | sort -u | grep -v '^\.')
do
  echo $i
	for j in $(grep $i $temp_file | awk {'print $1'} | sort -u)
	do
	  j_date=$(echo ${j} | sed "s/$i-//g" | sed 's/\./-/g')
		if [[ $(date --date="$j_date" +%s) -lt "$processing_date" ]]
		then
			echo "$j_date for $i is older than 60 days ago"
			curl -X DELETE "https://vpc-k8s-dev.us-east-1.es.amazonaws.com/$j"
		fi
	done
done
rm $temp_file

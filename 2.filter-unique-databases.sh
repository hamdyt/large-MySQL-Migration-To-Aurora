#!/bin/bash
#Created by: futuralis.com
IFS=$'\n' read -d '' -r -a list1 < ./prepared/unwanted.dbs
IFS=$'\n' read -d '' -r -a list2 < raw.dbs

echo cleaning raw.dbs and removing unwanted.dbs...

printf '%s\n' "${list1[@]}" | sort >./tmp/list1.sorted
printf '%s\n' "${list2[@]}" | sort >./tmp/list2.sorted
IFS=$'\n' read -d '' -r -a list1s < ./tmp/list1.sorted
IFS=$'\n' read -d '' -r -a list2s < ./tmp/list2.sorted

rm cleaned.dbs

grep -v -F -x -f ./tmp/list1.sorted ./tmp/list2.sorted >> cleaned.dbs
#INFO: remove any database manually from processing at this step.

grep -v "^information_schema$\|^mysql$\|^performance_schema$\|^Database$" cleaned.dbs > cleaned_tmp.dbs
mv cleaned_tmp.dbs cleaned.dbs

echo File cleaned: cleaned.dbs..
echo clean records:
cat ./cleaned.dbs | wc -l
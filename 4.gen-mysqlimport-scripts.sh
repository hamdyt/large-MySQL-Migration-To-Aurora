#!/bin/bash
#Created by: futuralis.com

#INFO: Pass on the credentials of the target database here.

host=""
user=""
pass=""

mkdir -p kuk
mkdir -p kuk/sql
mkdir -p kuk/out

awk '{print "mysql -h "host" -u "user" -p\x27"pass"\x27 < ./sql/"$0".sql"}' host="${host}" user="${user}" pass="${pass}" cleaned.dbs > dbimport-commands.sql
echo How many parallel threads you want to run?
read n

dbscount=`wc -l dbimport-commands.sql |  awk '{print $1}'`
echo Found total $dbscount databases.

portion=$((dbscount/n))
leftover=$((dbscount%n))

echo Each portion would contain $portion
echo Left over after complete portion are $leftover

declare -i startV=1;
declare -i endV=$portion
rm ./kuk/import_executer.sh
echo "echo StartDate:\`date\`" >> ./kuk/import_executer.sh
for i in $(seq 1 $n);
do

   echo Loop:$i : $startV, $endV ;
   sudo sed -n "${startV},${endV} p" dbimport-commands.sql > ./kuk/${i}_import.sh
   echo "echo Completed-${i}" >> ./kuk/${i}_import.sh
   echo "nohup sh ./${i}_import.sh > ./out/${i}_import.out &" >> ./kuk/import_executer.sh
   sudo chmod +x ./kuk/${i}_import.sh

   startV=`expr $endV + 1`;
   endV=`expr $endV + $portion`;

done
#INFO: Handle leftover records
endV=`expr $startV + $leftover`;
echo left over endV $endV
declare -i leftover;
leftover=`expr $n + 1`;
echo Loop:$leftover : $startV, $endV ;

#INFO:Put the heavy database here manually in the script so that separate thread can take over it.
echo "mysql -h $host -u $user -p'${pass}' < ./sql/heavy.sql" > ./kuk/${leftover}_import.sh
sudo sed -n "${startV},${endV} p" dbimport-commands.sql >> ./kuk/${leftover}_import.sh
echo "echo Completed-${leftover}" >> ./kuk/${leftover}_import.sh
echo "nohup sh ./${leftover}_import.sh > ./out/${leftover}_import.out &" >> ./kuk/import_executer.sh

sudo chmod +x ./kuk/${leftover}_import.sh

chmod +x ./kuk/import_executer.sh
echo "echo wait-start" >> ./kuk/import_executer.sh
echo "wait" >> ./kuk/import_executer.sh
echo "echo wait-end" >> ./kuk/import_executer.sh
echo "echo EndDate:\`date\`"  >> ./kuk/import_executer.sh

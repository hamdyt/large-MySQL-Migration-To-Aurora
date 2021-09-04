#!/bin/bash

#Created by: futuralis.com

#INFO: we create some directories for files segregation. kuk is root directory for files generation. where in further we will keep sql and output files under kuk.
mkdir -p kuk
mkdir -p kuk/sql
mkdir -p kuk/out
host=""
user=""
pass=""

awk '{print "mysqldump -h "host" --skip-add-locks -u "user" -p\x27"pass"\x27 --databases " $0 " --result-file=./sql/"$0".sql"}' host="${host}" user="${user}" pass="${pass}" cleaned.dbs > dbdump-commands.sql
echo How many parallel threads you want to run?
read n

dbscount=`wc -l dbdump-commands.sql |  awk '{print $1}'`
echo Found total $dbscount databases.

portion=$((dbscount/n))
leftover=$((dbscount%n))

echo Each portion would contain $portion
echo Left over after complete portion are $leftover

declare -i startV=1;
declare -i endV=$portion
rm ./kuk/dump_executer.sh
echo "echo StartDate:\`date\`" >> ./kuk/dump_executer.sh
for i in $(seq 1 $n);
do

   echo Loop:$i : $startV, $endV ;
   sudo sed -n "${startV},${endV} p" dbdump-commands.sql > ./kuk/${i}_dump.sh
   echo "echo Completed-${i}" >> ./kuk/${i}_dump.sh
   echo "nohup sh ./${i}_dump.sh > ./out/${i}_dump.out &" >> ./kuk/dump_executer.sh
   sudo chmod +x ./kuk/${i}_dump.sh

   startV=`expr $endV + 1`;
   endV=`expr $endV + $portion`;

done

#INFO: Handle leftover records
endV=`expr $startV + $leftover`;
echo left over endV $endV
declare -i leftover;
leftover=`expr $n + 1`;
echo Loop:$leftover : $startV, $endV ;

#INFO: Push heavy database in the begining of a separate thread
echo "mysqldump -h $host --skip-add-locks -u $user -p'${pass}' --databases heavy  --result-file=./sql/heavy.sql" > ./kuk/${leftover}_dump.sh
sudo sed -n "${startV},${endV} p" dbdump-commands.sql >> ./kuk/${leftover}_dump.sh
echo "echo Completed-${leftover}" >> ./kuk/${leftover}_dump.sh
echo "nohup sh ./${leftover}_dump.sh > ./out/${leftover}_dump.out &" >> ./kuk/dump_executer.sh

sudo chmod +x ./kuk/${leftover}_dump.sh

chmod +x ./kuk/dump_executer.sh
echo "echo wait-start" >> ./kuk/dump_executer.sh
echo "wait" >> ./kuk/dump_executer.sh
echo "echo wait-end" >> ./kuk/dump_executer.sh
echo "echo EndDate:\`date\`"  >> ./kuk/dump_executer.sh
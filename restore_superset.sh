#!/bin/sh
# @param $1 이관하고자하는 superset db 컨테이너명
# @param $2 백업 대상 파일명

DIR="$( cd "$( dirname "$0" )" && pwd -P )"
echo $DIR
cd $DIR

bucket_name=tidesquare-dp # 버킷 이름
folder_path=superset/backup # 버킷 내 폴더 경로
file_name=$2

if [ ! $1 ]
then
    echo "restore db container name empty!!!"
elif [ ! $2 ]
then
    echo "backup file name empty!!!"
else
    echo "
===============================================================================================================================================                                                                                                                                                    
 ######  ##   ##  ######   #######  ######    ######  #######  #######           ######   #######   ######  #######   #####   ######   #######  
##       ##   ##  ##   ##  ##       ##   ##  ##       ##          ##             ##   ##  ##       ##          ##    ##   ##  ##   ##  ##       
 #####   ##   ##  ######   ######   ######    #####   ######      ##             ######   ######    #####      ##    ##   ##  ######   ######   
     ##  ##   ##  ##       ##       ##  ##        ##  ##          ##             ##  ##   ##            ##     ##    ##   ##  ##  ##   ##       
######    #####   ##       #######  ##   ##  ######   #######     ##             ##   ##  #######  ######      ##     #####   ##   ##  #######  
"
    echo "... get $2 from s3"
    aws s3 cp s3://$bucket_name/$folder_path/$file_name $DIR/sql/

    # dump file copy to superset db container
    echo "... copy init_db.sql"
    docker cp $DIR/sql/init_db.sql $1:/var/lib/postgresql/data

    echo "... copy $2"
    docker cp $DIR/sql/$2 $1:/var/lib/postgresql/data

    echo "... copy update_db.sql"
    docker cp $DIR/sql/update_db.sql $1:/var/lib/postgresql/data

    # start dump file 
    echo "... start init_db.sql"
    docker exec $1 psql -U superset -d superset -f /var/lib/postgresql/data/init_db.sql
    docker exec $1 rm /var/lib/postgresql/data/init_db.sql

    echo "... start dump_db.sql"
    docker exec $1 psql -U superset -d superset -f /var/lib/postgresql/data/$2
    docker exec $1 rm /var/lib/postgresql/data/$2
    rm $DIR/sql/$2
    
    echo "... start update_db.sql"
    docker exec $1 psql -U superset -d superset -f /var/lib/postgresql/data/update_db.sql
    docker exec $1 rm /var/lib/postgresql/data/update_db.sql

    echo "... $1 restore end  
===============================================================================================================================================                                                                                                                                                    
    "
fi
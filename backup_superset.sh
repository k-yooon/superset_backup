#!/bin/sh
# @param $1 백업하고자하는 superset db 컨테이너명

DIR="$( cd "$( dirname "$0" )" && pwd -P )"
echo $DIR
cd $DIR

today=`date +%Y%m%d`

bucket_name=tidesquare-dp # 버킷 이름
folder_path=superset/backup # 버킷 내 폴더 경로
count=3 #파일 몇 개만 남길 것인지

if [ ! $1 ]
then
    echo "backup db container name empty!!!"
else
    echo "
======================================================================================================================================
 ######  ##   ##  ######   #######  ######    ######  #######  #######           ######    #####    ######  ##   ##  ##   ##  ######   
##       ##   ##  ##   ##  ##       ##   ##  ##       ##          ##             ##   ##  ##   ##  ###      ##  ##   ##   ##  ##   ##  
 #####   ##   ##  ######   ######   ######    #####   ######      ##             ######   #######  ##       ######   ##   ##  ######   
     ##  ##   ##  ##       ##       ##  ##        ##  ##          ##             ##   ##  ##   ##  ###      ##   ##  ##   ##  ##       
######    #####   ##       #######  ##   ##  ######   #######     ##             ######   ##   ##   ######  ##   ##   #####   ##       
    "
    echo "... dump postgres"
    docker exec $1 pg_dump -U superset -d superset > $DIR/sql/dump_db_$today.sql

    echo "... upload to s3"
    aws s3 cp $DIR/sql/dump_db_$today.sql s3://tidesquare-dp/superset/backup/
    rm $DIR/sql/dump_db_$today.sql

    echo "... delete backup file in s3"
    files=($(aws s3api list-objects --bucket $bucket_name --prefix $folder_path --query 'reverse(sort_by(Contents,&Key))[].Key' --output text))

    for (( i=$count; i<${#files[@]}; i++ )); do
        echo ${files[i]}
        aws s3 rm s3://$bucket_name/${files[i]}
    done

    echo "... $1 backup end   
========================================================================================================================================
    "
fi

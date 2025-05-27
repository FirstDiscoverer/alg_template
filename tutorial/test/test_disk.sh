#!/bin/bash
# Test disk write speed with dd, with different bs , 2GB data
 
# [Linux测试硬盘性能的脚本](https://blog.csdn.net/Ronixon/article/details/131243621)
# nohup ./test_disk.sh >> test_disk.log 2>&1 &

BS=(512 1k 2k 4k 8k 16k 32k 64k 128k 256k 512k 1M 2M 4M 8M 12M 16M 24M 32M 48M 64M)
#COUNT_2G=(4000000 2000000 1000000 500000 250000 125000 62500 31250 15625 7813 3907 1954 977 489 245 163 123 82 62 41 31)
# reduce count for small BS < 4k
COUNT_2G=(400000  200000  100000  500000 250000 125000 62500 31250 15625 7813 3907 1954 977 489 245 163 123 82 62 41 31)

FILE=/home/test/file.tst
echo $FILE
 
while true
do
    for id in $(seq ${#BS[*]}) ; do
        rm -rf $FILE 2>1 1>/dev/null
        sleep 3 
        
        idx=`expr $id - 1`
        echo ---- $id: bs=${BS[$idx]},  ${COUNT_2G[$idx]}  --------
        dd if=/dev/zero of=$FILE bs=${BS[$idx]} count=${COUNT_2G[$idx]} oflag=direct
    done
done

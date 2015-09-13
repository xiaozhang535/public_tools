#!/bin/sh

#使用方法: 
# dir_util="/usr/local/avs/public_tools/"
# source $dir_util/oneprocess.sh > /dev/null 2>&1
# fun_runone $0 > /dev/null 2>&1 
#保证只有一个进程
fun_runone()
{
    pids=$(ps -ef);
    local shell="$1"
    #echo "$pids" > /tmp/tmp_runone.txt
    count=$(echo "$pids" | egrep "$shell\b" | awk 'BEGIN{f=0;count=0;}{if($3!=f) {count++;echo $0;}f=$2;}END{printf count}')
    echo `date +"%Y%m%d %T"`" $shell[$count]";
    if(($count>1));then
        #echo `date +"%Y%m%d %T"`" $shell[$count] exist";
        exit;
    fi
}

fun_process_count()
{
    pids=$(ps -ef);
    local shell="$1"
    count=$(echo "$pids" | grep "$shell\b" | awk 'BEGIN{f=0;count=0;}{if($3!=f) {count++;echo $0;}f=$2;}END{printf count}')
    #echo `date +"%Y%m%d %T"`" $shell[$count]";
    echo -n "$count";
}

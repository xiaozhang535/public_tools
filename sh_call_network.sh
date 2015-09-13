#!/bin/bash

<<COMMENT
@author: ginozhang
@date: 2012-10-17
@description: 
COMMENT

dir_tools='/usr/local/avs/public_tools'
PATH="$dir_tools/lib:$PATH"
source $dir_tools/lib/lbf_init.sh

cmd=""
cmd_files=""
files=""
dir=""
user=""
passwd=""
type=""
function usage()
{
    echo "" 
    echo "Usage: $0"
    echo        
    echo "  -i  <ip[,ip...]>        no default[$ips]. 目标机器ips"
    echo "  -u  <user>              no default[$user]. 登陆用户名"
    echo "  -p  <passwd>            no default[$passwd]. 登陆密码"
    echo "  -c  <cmd>               no default[$cmd]. 目标机器执行的命令"
    #echo "  -f  <file[,file...]>    no default[$files]. 传送文件的原文件(绝对路径)"
    echo "  -f  <file[,file...]>    no default[$files]. 传送文件的原文件(相对或者绝对路径)"
    echo "  -d  <dir>               default[$dir]. 传送文件的目标目录,如果为空则默认同file相同目录"
    echo "  -t  <type>              no default[$type]. 传送文件的方向: push<推送>,pull<接收>"
    echo "  -h  <help>              display this help and exit"
    echo        
}
while getopts ":i:u:p:c:f:d:t:h" optname
do
	case "$optname" in
	"i") ips="$OPTARG" ;;
	"u") user="$OPTARG" ;;
	"p") passwd="$OPTARG" ;;
	"c") cmd="$OPTARG" ;;
    "f") files="$OPTARG" ;;
	"d") dir="$OPTARG" ;;
	"t") type="$OPTARG" ;;
	"h") usage; exit ;;
	"?") echo "Unknown option $OPTARG" ;;
	":") echo "No argument value for option $OPTARG" ;;
	*)
	# Should not occur
		echo "Unknown error while processing options" ;;
	esac
done
#echo "ips: $ips user: $user passwd: $passwd cmd: $cmd files: $files dir: $dir "

if [ "$ips" == "" ] || [ "$user" == "" ] || [ "$passwd" == "" ] ;then
    usage;
    exit;
fi
if [ "$cmd" == "" ] && ( [ "$files" == "" ] || ( [ "$type" != "pull" ] && [ "$type" != "push" ] ) );then
    usage;
    echo "cmd, files(type)必须有一个"
    exit;
fi

shell="$0"
dir_cur=$(pwd)
#dir_shell=$(echo "$shell" | awk -F "/" '{if($1 ~ /^.$/){ printf "'"$dir_cur"'";}  for(idx=2;idx<NF;idx++){ printf "/"$idx;} }')
shellpath=$(readlink -f $shell );
dir_shell=$(dirname $shellpath);
#echo "shell: $shell dir_cur: $dir_cur dir_shell: $dir_shell"

#cd $dir_shell

ips=`echo $ips |sed "s/,/ /g"`;
for ip in $ips
do  
    if [ "$files" != "" ] && ( [ "$type" == "pull" ] || [ "$type" == "push" ] );then
        files=`echo $files |sed "s/,/ /g"`;
        for file in $files;do
            dir_real="$dir"
            #echo "ip: $ip file: $file dir_real: $dir_real"
            #file=$(readlink -f "$dir_cur/$file")
            file=$(readlink -f $file)
            if [ "$dir_real" == "" ];then
                #dir_real=$(echo "$file" | awk -F "/" '{for(idx=1;idx<NF;idx++) {printf $idx"/";}}');
                dir_real=$(dirname $file);
            fi
            #echo "file:::$file $dir_real $type" >> $file_config_abs
            #echo "ip: $ip file: $file dir_real: $dir_real"
            if [ "$type" == "push" ];then
                network::ssh_copy "$passwd" 36000 $file $user@$ip:$dir_real
            else
                network::ssh_copy "$passwd" 36000 $user@$ip:$file $dir_real
            fi
        done
    fi
    if [ "$cmd" != "" ];then
        #echo "ip: $ip"
        network::ssh_do "$passwd" 36000 $user@$ip "$cmd" 
    fi
done

#!/bin/bash

#
# marc, 2011-2-25
#

if [ $# -ne 2 ] || [ ! -f "$1" ] || [ "$1" == "-h" ]; then
    echo "Usage: $0 conf_template output_conf"
    echo "
替换配置文件模板中的参数，方便自动配置

支持的替换变量:
    <PAR_PWD>       当前路径
    <PAR_PRJ_DIR>   项目路径，同 PAR_PWD，一般同脚本 install.sh 所在目录
    <PAR_LOCALIP>   私网 ip
"
    exit 0
fi

path=`dirname $0`

function do_rep()
{
    template="$1"
    output="$2"

    cp -fv "$template" "$output"

    par_localip=`$path/getprivateip.pl`
    sed -r -i "s/<PAR_LOCALIP>/$par_localip/" "$output"

    par_pwd=`pwd`
    sed -r -i "s#<PAR_PWD>#$par_pwd#" "$output"
    sed -r -i "s#<PAR_PRJ_DIR>#$par_pwd#" "$output"
}

do_rep "$1" "$2"



#!/bin/bash

#
# marc, 2011-2-25
#

if [ $# -ne 2 ] || [ ! -f "$1" ] || [ "$1" == "-h" ]; then
    echo "Usage: $0 conf_template output_conf"
    echo "
�滻�����ļ�ģ���еĲ����������Զ�����

֧�ֵ��滻����:
    <PAR_PWD>       ��ǰ·��
    <PAR_PRJ_DIR>   ��Ŀ·����ͬ PAR_PWD��һ��ͬ�ű� install.sh ����Ŀ¼
    <PAR_LOCALIP>   ˽�� ip
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



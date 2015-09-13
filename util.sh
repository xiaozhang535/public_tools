#!/bin/sh

# shell 脚本工具函数.
# fun_tcp 模拟telnet tcp发包回包函数
# io::red .. 颜色工具

#source /usr/local/avs/public_tools/util.sh;fun_tcp 172.25.32.42 22222 "cache dump syn" "dump cache successful"

############################################################
# misc functions
############################################################
function util::is_empty {
  [ -z "$1" ] && return 0 || return 1
}
############################################################
# color functions
############################################################
function io::red {
  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [content..]" && return 1
  io::color red "$@"
}

function io::green {
  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [content..]" && return 1
  io::color green "$@"
}

function io::yellow {
  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [content..]" && return 1
  io::color yellow "$@"
}

function io::blue {
  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [content..]" && return 1
  io::color blue "$@"
}

function io::purple {
  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [content..]" && return 1
  io::color purple "$@"
}

function io::white {
  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [content..]" && return 1
  io::color white "$@"
}
function io::color {
  local _var_color_red="\e[1m\e[31m"
  local _var_color_green="\e[1m\e[32m"
  local _var_color_yellow="\e[1m\e[33m"
  local _var_color_blue="\e[1m\e[34m"
  local _var_color_purple="\e[1m\e[35m"
  local _var_color_white="\e[1m\e[37m"
  local _var_color_end="\e[m"

  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [red|green|yellow|blue|purple|white] [content..]" && return 1
  case "$1" in
    "red")    echo -ne ${_var_color_red}    ;;
    "green")  echo -ne ${_var_color_green}  ;;
    "yellow") echo -ne ${_var_color_yellow} ;;
    "blue")   echo -ne ${_var_color_blue}   ;;
    "purple") echo -ne ${_var_color_purple} ;;
    "white")  echo -ne ${_var_color_white}  ;;
    *)        echo "Unkown color: $1" && return 1 ;;
  esac

  shift && echo -ne "$@"$_var_color_end
}

function fun_tcp()
{
    if [ $# -lt 4 ];then
        echo "usage: $0 ip port send end";
        return;
    fi
    local ip="$1"
    local port="$2"
    local send="$3"
    local end="$4"
    #echo "ip: $ip port: $port send: $send end: $end";
    #return;
    exec 4<>/dev/tcp/$ip/${port}
    local length=`echo "$end" | awk '{printf length($0)}'`
    echo -e "${send}\r\n" >&4
    while read -u4 i && [ "${i/$'\r'/}" != "" ]; do
        echo "$i" ;
        local last=`echo "$i" | awk '{len=strtonum("'"$length"'");last=substr($0, length($0)-len+1, len); printf last;}'`
        #echo "length: $length last: $last end: $end"
        if [ "$last" == "$end" ];then
            break;
        fi
    done      
    exec 4>&- 
}
#fun_tcp 172.16.82.179 13161 "cache dump syn" "dump cache successful"

#!/bin/bash
#===============================================================================
#      FILENAME: lbf_util.sh
#
#   DESCRIPTION: ---
#         NOTES: ---
#        AUTHOR: leoxiang, leoxiang@tencent.com
#       COMPANY: Tencent Co.Ltd
#      REVISION: 2011-12-19 by leoxiang
#===============================================================================

function util::help {
  io::red "This is the help for LBF \"util\" lib: \n"
  io::red "See more help by call function with no args: \n"
  echo ""
  printf "%-40s %s\n" $(io::yellow "util::is_empty")    "return whether a string is empty"
  printf "%-40s %s\n" $(io::yellow "util::to_hex")      "convert oct, decimal, hex to hex number"
  printf "%-40s %s\n" $(io::yellow "util::to_oct")      "convert oct, decimal, hex to oct number"
  printf "%-40s %s\n" $(io::yellow "util::to_dec")      "convert oct, decimal, hex to dec number"
  printf "%-40s %s\n" $(io::yellow "util::check_bin")   "check whether a binary is exist"
  printf "%-40s %s\n" $(io::yellow "util::find_script") "find script in server locations"
}

############################################################
# misc functions
############################################################
function util::is_empty {
  [ -z "$1" ] && return 0 || return 1
}

function util::to_hex {
  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [number]" && return 1
  printf "%x\n" $1
}

function util::to_oct {
  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [number]" && return 1
  printf "%o\n" $1
}

function util::to_dec {
  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [number]" && return 1
  printf "%d\n" $1
}

function util::check_bin {
  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [bin]" && return 1

  # find bin path
  command -v "$1" &>/dev/null && return 0
  # sometime /sbin is not include in bin path, so find it again
  command -v "/sbin/$1" &>/dev/null && PATH="/sbin:$PATH" && return 0
  # cant find, return error
  echo "Error: Cant find binary \"$1\"" && return 1
}

function util::find_script {
  util::is_empty "$1" && echo "Usage: ${FUNCNAME} [script]" && return 1

  # try find in in $PATH
  which $1 &>/dev/null    && which $1                     && return 0
  # try find in $HOME/bin
  [ -f "${HOME}/bin/$1" ] && readlink -f "${HOME}/bin/$1" && return 0
  # try find in /bin path
  [ -f "/bin/$1" ]        && readlink -f "/bin/$1"        && return 0
  # try find in current bin path
  [ -f "./bin/$1" ]       && readlink -f "./bin/$1"       && return 0
  # try find in current path
  [ -f "$1" ]             && readlink -f "$1"             && return 0
  # cant find, return error
  return 1
}

#function lbf_split {
  #util::is_empty "$2" && echo "Usage: ${FUNCNAME} [string] [array_name] [delimit(opt)]" && return 1
  #eval $2="($(echo $1 | tr "${3:- }" "\n"))"
#}

#function util::rm {
  #return 0

#}

#function string::get_col {
  #if util::is_empty "$2"; then
    #echo "Usage: ${FUNCNAME} [string] [col_desc] [delimiter(opt)]" 
    #echo ""
    #echo "[col_desc] can be:  N  N-  N-M  -M"
    #return 1
  #fi
  #local _delimiter=" "
  #! util::is_empty "$3" && _delimiter="$3"
  #echo $1 | eval cut -f$2 -d\'${_delimiter}\'
#}

############################################################
# Init and Check, Do Not Modify
############################################################
util::check_bin printf
util::check_bin test
util::check_bin echo
util::check_bin readlink
util::check_bin command

# vim:ts=2:sw=2:et:ft=sh:


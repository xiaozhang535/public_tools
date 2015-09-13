#!/bin/bash

<<COMMENT
@author: ginozhang
@date: 2013-11-20
@description: 用于svn merge中的MINE和THEIRS版本的文件比较，由~/.subversion/config中的merge-tool-cmd指定
COMMENT

#使用方法见
#http://www.scootersoftware.com/support.php?zz=kb_vcs

#原理以及参数见
#http://svnbook.red-bean.com/en/1.7/svn.advanced.externaldifftools.html
#BASE   = sys.argv[1]
#THEIRS = sys.argv[2]
#MINE   = sys.argv[3]
#MERGED = sys.argv[4]
#WCPATH = sys.argv[5]
vimdiff $3 $2 

#!/bin/bash

<<COMMENT
@author: ginozhang
@date: 2013-11-20
@description: 用于svn diff中的文件比较，由~/.subversion/config中的diff-cmd指定
COMMENT

#使用方法见
#http://www.scootersoftware.com/support.php?zz=kb_vcs

#原理以及参数见
#http://svnbook.red-bean.com/en/1.7/svn.advanced.externaldifftools.html

vimdiff $6 $7

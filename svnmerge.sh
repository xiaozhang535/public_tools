#!/bin/bash

<<COMMENT
@author: ginozhang
@date: 2013-11-20
@description: ����svn merge�е�MINE��THEIRS�汾���ļ��Ƚϣ���~/.subversion/config�е�merge-tool-cmdָ��
COMMENT

#ʹ�÷�����
#http://www.scootersoftware.com/support.php?zz=kb_vcs

#ԭ���Լ�������
#http://svnbook.red-bean.com/en/1.7/svn.advanced.externaldifftools.html
#BASE   = sys.argv[1]
#THEIRS = sys.argv[2]
#MINE   = sys.argv[3]
#MERGED = sys.argv[4]
#WCPATH = sys.argv[5]
vimdiff $3 $2 

#!/bin/bash

<<COMMENT
@author: ginozhang
@date: 2013-11-20
@description: ����svn diff�е��ļ��Ƚϣ���~/.subversion/config�е�diff-cmdָ��
COMMENT

#ʹ�÷�����
#http://www.scootersoftware.com/support.php?zz=kb_vcs

#ԭ���Լ�������
#http://svnbook.red-bean.com/en/1.7/svn.advanced.externaldifftools.html

vimdiff $6 $7

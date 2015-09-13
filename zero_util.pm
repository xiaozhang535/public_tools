#!/usr/bin/perl

#ginozhang 2011-06-27 
#       add: 添加大数字用逗号分割
#
package zero_util;
use Time::Local;
# use URI::Escape;
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(zTimeCompare zGetLocalip zGetOuterip zIpCompare zGetDomain zTimeCalc zUnixTime zGetLocalTime zAddUser zCheckUser zCheckGroup zGetUserId zGetGroupId zLoadConf zInvalidUrl zWriteConf zPrase2Html zPrase2Sql zUrlEncode zUrlDecode zAddCrontab InistanceCount Commify);

#bugs:在zGetLocalip中由于调用了系统函数,有时会卡死,原因末知

#比较两个时间的差值,时间格式如:2008-09-05 22:05:11 
#参数列表:
#       localtime1 : 第一个时间
#       localtime2 : 第二个时间
#返回值:
#       返回两个时间差
sub zTimeCompare{
    (my $localtime1 ,my $localtime2) = @_;

    my $time1 = 0;
    my $time2 = 0;

    my ($y,$m,$d,$h,$mi,$s) = split(/[\-  :]/,$localtime1);
    $time1 = timelocal($s, $mi, $h, $d, $m-1, $y-1900);

    ($y,$m,$d,$h,$mi,$s) = split(/[\-  :]/,$localtime2);
    $time2 = timelocal($s, $mi, $h, $d, $m-1, $y-1900);

    return $time1-$time2;
}

#时间计算
#参数列表:
#       time : 原始时间
#       split : 时间间隔
#       opt : 操作类型 add,sub
#返回值:
#       返回计算结果
sub zTimeCalc{
    my ($time,$split,$opt) = @_;

    my $unixtime;
    my ($y,$m,$d,$h,$mi,$s) = split(/[\-  :]/,$time);
    $unixtime = timelocal($s, $mi, $h, $d, $m-1, $y-1900);

    if($opt eq "add"){
        $unixtime += $split;
    }else{
        $unixtime -= $split;
    }

    ($s,$mi,$h,$d,$m,$y) = localtime($unixtime);
    $y += 1900;
    $m += 1;
    return "$y-$m-$d $h:$mi:$s";
}

#得到unix时间
#参数列表:
#       time : 要转换的时间,如:2011-11-11 11:11:11
#       或 没有参数则返回系统当前时间
#返回值:
#       传入参数的unix时间或当前的系统时间
sub zUnixTime{
    if(scalar(@_)>0){
        my $time = shift @_;
        my ($y,$m,$d,$h,$mi,$s) = split(/[\-  :]/,$time);
        return timelocal($s, $mi, $h, $d, $m-1, $y-1900);
    }else{
        return time();    
    }
}

#得到机器的内网IP
#参数列表:  无
#返回值:
#       成功返回得到第一个本机的内网ip
#       失败返回undef
sub zGetLocalip{
    my $ip;
    my @allip = `/sbin/ifconfig | awk '/inet\ addr/{print \$2}' | awk -F":" '{print \$2}'`;
    foreach $ip (@allip){
        chomp $ip;
        #print "$ip\n";
        my ($range1,$range2) = (split(/\./,$ip))[0,1]; 
        #print "$range1,$range2\n";
        #if(($range1 == 192 && $range2 == 168) || ($range1 == 172 && $range2 >= 16 && $range2 <= 31) || $range1 == 10)
        if($range1!=127 && $range2!=0)
        {
            #print $ip;
            return $ip;
        } 
    }
    @allip = `/sbin/ifconfig | awk '/inet\ /{print \$2}' `;
    foreach $ip (@allip){
        chomp $ip;
        #print "$ip\n";
        my ($range1,$range2) = (split(/\./,$ip))[0,1]; 
        #print "$range1,$range2\n";
        #if(($range1 == 192 && $range2 == 168) || ($range1 == 172 && $range2 >= 16 && $range2 <= 31) || $range1 == 10)
        if($range1!=127 && $range2!=0)
        {
            #print $ip;
            return $ip;
        } 
    }
    return undef;
}


#得到机器的外网IP
#参数列表:  无
#返回值:
#       成功返回得到外网ip
#       失败返回undef
sub zGetOuterip{
    my $ip;
    my @allip = `/sbin/ifconfig | awk '/inet\ addr/{print \$2}' | awk -F":" '{print \$2}'`;
    foreach $ip (@allip){
        chomp $ip;
        my ($range1,$range2) = (split(/\./,$ip))[0,1]; 
        if(!(($range1 == 192 && $range2 == 168) || ($range1 == 172 && $range2 >= 16 && $range2 <= 31) || $range1 == 10)){
            return $ip;
        } 
    }
    return undef;
}

#比较IP的大小
#参数列表:
#       ip1 : 第一个ip
#       ip2 : 第二个ip
#返回值:
#       ip1 > ip2返回1,ip1 < ip2返回-1,ip1 == ip2返回0
sub zIpCompare{
    (my $ip1, my $ip2) = @_;
    my @ip1 = split(/\./, $ip1);
    my @ip2 = split(/\./, $ip2);

    for(my $i = 0; $i < 4; $i++){
        if($ip1[$i] > $ip2[$i]){
            return 1;
        }elsif($ip1[$i] < $ip2[$i]){
            return -1;
        }else{
            next;
        }
    }
    return 0;
}

#得到一个url的域名
#参数列表:
#           url : 要得到域名的url
#返回值:    
#           成功返回 domain,失败返回 invalid url
sub zGetDomain{
    my $url = shift @_;
    if($url =~ /^http[s]{0,1}:\/\/([0-9a-zA-Z\.-]+)/){
        return $1;
    }
	return "invalid url";
}

#判断一个url是否合法,现在只是匹配以下形式 http://或https://
#参数列表:
#           url : 要判断的url
#返回值:    
#          不合法返回1,合法返回0 
sub zInvalidUrl{
	my $url = shift @_;
	if($url =~ /^https?:\/\/.+/){
		return 0;
	}
	return 1;
}

#得到当前系统时间
#参数列表:
#           无
#返回值:
#           当前时间,如:1984-12-08 11:11:11
sub zGetLocalTime{
    my $t = shift @_;
    if(!defined $t){
        $t = time();
    }
    my ($sec, $min, $hour, $mday, $mon, $year, $day, $yday, $isdst) = localtime($t);
    $mon = $mon + 1;
    if($mon < 10){
        $mon = "0".$mon;
    }
    if($mday < 10){
        $mday = "0".$mday;
    }
    if($hour < 10){
        $hour = "0".$hour;
    }
    if($min < 10){
        $min = "0".$min;
    }
    if($sec < 10){
        $sec = "0".$sec;
    }
    return ($year+1900)."-$mon-$mday $hour:$min:$sec";
}

#添加一个用户
#参数列表:
#           name : 用户名
#           pass : 密码
#返回值:
#           添加成功返回ok,失败返回错误原因 
sub zAddUser{
    my $uid = `id -u`;
    chomp $uid;
    if($uid != 0){
        return "you must run this script with root\n";
    }
    my ($name,$pass,$grp) = @_;

    if(&zCheckUser($name) > 0){
        return"the user has exist\n";
    }
    if(&zCheckGroup($grp) <= 0){
        return "the group don't exist\n";
    }
    `useradd $name -g$grp -M`;
    if(&zCheckUser($name) < 0){
        return "some errors,can't add the user\n";
    }
    my $p = &CreatePass($pass);
    my $now = `date +"%F_%H_%M_%S"`;
    chomp $now;
    `cp /etc/shadow /etc/shadow.$now`;
    `sed -i "s/^$name:/$name:$p/" /etc/shadow`;
    return "ok";
}

#检查一个用户是否存在
#参数列表:
#           name : 用户名
#返回值:
#           存在返回 1
#           不存在返回 0
sub zCheckUser{
    my $name = shift @_;
    my $count = `grep "^$name:" /etc/passwd | wc -l`;
    chomp $count;
    return $count;
}

#检查一个用户组是否存在
#参数列表:
#           grpname : 用户组
#返回值:
#           存在返回 1
#           不存在返回 0
sub zCheckGroup{
    my $grp = shift @_;
    my $count = `grep "^$grp:" /etc/group | wc -l`;
    chomp $count;
    return $count;
}

#得到一个用户的uid
#参数列表:
#           name : 用户名
#返回值:
#           存在返回uid
#           不存在返回-1
sub zGetUserId{
    my $name = shift @_;
    my $line = `cat /etc/passwd | grep "^$name:"`;
    my @userinfo = split(/:/,$line);
    if(scalar(@userinfo) < 4){
        return -1;
    }
    return $userinfo[2];
}

#得到一个用户组的uid
#参数列表:
#           name : 用户组名
#返回值:
#           存在返回grpid
#           不存在返回-1
sub zGetGroupId{
    my $grp = shift @_;
    my $line = `cat /etc/group | grep "^$grp:"`;
    my @grpinfo = split(/:/,$line);
    if(scalar(@grpinfo) < 3){
        return "-1";
    }
    return $grpinfo[2];
}

#生成加密密码
#参数列表:
#           pass : 密码
#返回值:
#           返回加密密码
sub CreatePass{
    my $pass = shift @_;
    srand(time());
    my $randletter = "(int(rand(26))+(int(rand(1)+0.5)%2?65:97))";
    my $salt = sprintf("%c%c",eval($randletter), eval($randletter));
    return crypt($pass, $salt);
}

#从文件读取配置信息,配置信息格式如 name:sdfsdf
# 注释以"#"开头
# 名称和内容中不能有分隔符
#参数列表:
#           filename : 配置文件名
#           conf : 要返回的配置信息
#           sp : 分隔符,不能是 "#"
#返回值:
#           成功返回ok
#           失败返回错误原因
sub zLoadConf{
    my $file = shift @_;
    my $conf = shift @_;
    my $sp = shift @_;

    if(!defined($sp)){
        $sp = ":";
    }
    if($sp =~ /#/){
        return "invalid spliter include '#'";
    }

    %$conf = ();
    my $H_CONF;
    open($H_CONF, "<$file") or return "can't open the file $file";
    while(my $line = <$H_CONF>){
        $line =~ s/^\s*//g;
        $line =~ s/\s*$//g;
        if($line =~ /^#/){
            $line =~ s/^#//;
            next;
        }

        $line = (split /#/, $line)[0];
        my @temp = split(/$sp/, $line);
        if(scalar(@temp) != 2){
            return "invalid : $line";
        }
        my ($name, $info) = (split /$sp/, $line)[0,1];
        $name =~ s/^\s*//g;
        $name =~ s/\s*$//g;
        $info =~ s/^\s*//g;
        $info =~ s/\s*$//g;
        $$conf{$name} = $info;
    }
    close $H_CONF;
    return "ok";
}

#把配置信息写入文件,配置信息文件格式如 name:sdfsdf
#参数列表:
#           filename : 配置文件名
#           conf : 要写入的配置信息,名称和内容中不能有分隔符
#           conf 如: $conf{"name"} = value
#           sp : 分隔符,不能是 "#"
#返回值:
#           成功返回ok
#           失败返回错误原因
sub zWriteConf{
    my $file = shift @_;
    my $conf = shift @_;
    my $sp = shift @_;

    if(!defined($sp)){
        $sp = ":";
    }
    if($sp =~ /#/){
        return "invalid spliter include '#'";
    }

    my $H_CONF;
    open($H_CONF, ">$file") or return "can't open the file $file";
    foreach my $item (keys %$conf){
        print $H_CONF $item."$sp".$$conf{$item}."\n";
    }
    close $H_CONF;
    return "ok";
}

#html转换
#参数列表:
#           html : 要转换的html文本
#返回值:
#           成功返回转换后的文本
sub zPrase2Html{
    my $html = shift @_;
    $html =~ s/&/&apt;/g;
    $html =~ s/</&lt;/g;
    $html =~ s/>/&gt;/g;
    $html =~ s/"/&quot;/g;
    return $html;
}

#sql转换
#参数列表:
#           sql : 要转换的sql文本
#返回值:
#           成功返回转换后的文本
sub zPrase2Sql{
    my $sql = shift @_;
    $sql =~ s/\\/\\\\/g;
    $sql =~ s/'/\\'/g;
    $sql =~ s/;/\\;/g;
    $sql =~ s/`/\\`/g;
    $sql =~ s/"/\\"/g;
    return $sql;
}

#url encode
sub zUrlEncode{
    my $url = shift @_;
    return uri_escape($url);
}

#url decode
sub zUrlDecode{
    my $url = shift @_;
    return uri_unescape($url);
}

#添加crontab,会删除自己旧的crontab
#参数列表:
#           crontab : 要添加的crontab
#           my %crontab = ();
#           $crontab{"downloader"}{"1"}{"context"} = "* * * * * cd  $cur_path;./start.sh $count >> ./start.sh.log 2>&1";
#           $crontab{"downloader"}{"1"}{"comment"} = "check the program stats";
sub zAddCrontab{
    my $crontab = shift @_;

    #保存旧的crontab
    `crontab -l > crontab.old`;
    `cp crontab.old crontab.temp`;
    `echo "" > crontab.new`;

    foreach my $mod (keys %$crontab){
        my $pre_fix = "^#!!!$mod####";
        my $H_FILE;
        my $H_NEWFILE;
        if(!open($H_FILE, "<crontab.temp")){
            return "error:can't open crontab.temp";
        }
        if(!open($H_NEWFILE, ">crontab.new")){
            return "error:can't open crontab.new";
        }
        my $i = 0;
        my $inline = 0;
        while(my $line = <$H_FILE>){
            chomp $line;
            $i++;
            #没有crontab
            if($line =~ /^no crontab for/){
                `echo "" > crontab.temp`;
                last;
            }
            #跳过前三行注释
            if($i <= 3 && $line =~ /^#/){
                next;
            }
            #删除旧注释
            if($line =~ /$pre_fix/){
                if($inline == 0){
                    $inline = 1;
                }else{
                    $inline = 0; 
                }
                next;
            }
            if($inline == 1){
                next;
            }

            #其它程序的注释,保留
            print $H_NEWFILE $line."\n";
        }
        close($H_FILE);
        close($H_NEWFILE);
        
        `cp crontab.new crontab.temp`;
    }

    #添加新crontab
    foreach my $mod (keys %$crontab){
        my $pre_fix = "#!!!$mod################################################################";

        my $H_NEWFILE;
        if(!open($H_NEWFILE, ">>crontab.new")){
            return "error:can't open crontab.new";
        }
        print $H_NEWFILE "\n$pre_fix add by install for $mod\n";
        foreach my $item (keys %{$$crontab{$mod}}){
            if(defined($$crontab{$mod}{$item}{"comment"})
                           && length($$crontab{$mod}{$item}{"comment"}) > 0){
                print $H_NEWFILE "#$$crontab{$mod}{$item}{'comment'}\n";
            }
            print $H_NEWFILE "$$crontab{$mod}{$item}{'context'}\n";
        }
        print $H_NEWFILE "$pre_fix end######################################################\n\n";
        close($H_NEWFILE);
    }

    `crontab crontab.new`;
}

#author: ginozhang 20110425
#返回指定脚本的进程个数
#参数列表:
#       procName : 进程名称
#返回值:
#       进程个数
sub InistanceCount{
    my $procName = shift @_;
    my $count=`pids=\$(ps -ef);echo "\$pids" | grep "$procName" | awk 'BEGIN{f=0;count=0;}{if(\$3!=f) {count++;echo \$0;}f=\$2;}END{printf count}'`;
    chomp $count;
    return $count;
}

#author: ginozhang 2011-06-27
#返回用逗号分割大数字
#参数列表:
#       procName : 进程名称
#返回值:
#       进程个数
sub Commify {
    local $_  = shift;
    1 while s/^(-?\d+)(\d{3})/$1,$2/;
    return $_;
}

1;


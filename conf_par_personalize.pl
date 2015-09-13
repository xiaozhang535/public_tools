#!/usr/bin/perl -w

=pod
@mod 2013-09-24 ginozhang
    增加最原始配置文件的支持
    配置文件raw.conf内容如：
            LogsrvNum 3
            LogsrvPort1 10101
            LogsrvIp1 10.208.143.46
            LogsrvPort2 10102
            LogsrvIp2 10.208.143.46

@author: ginozhang
@date: 2012-02-21
@description: 根据服务器个性化配置文件，修改该文件中涉及到的配置文件(支持xml和非xml格式)某些项的值
    输入参数个性化配置文件的格式:
    #ip[,ip] 配置文件名(与个性化配置文件相同目录,文件格式采用xml) 配置项目录(支持多级例如: Main/sub) 配置项     配置项值 备注信息
    172.16.82.179 test.conf.template BuHarmMark/test1/test2                    item       34       测试

    非xml格式如interface.conf文件
    [LOCAL_SERVER]
    ListenIP        = 0.0.0.0 #10.166.138.224
    Port            = 18891
    PortName        = 1
=cut

use strict;
use Getopt::Long qw(:config pass_through);
use File::Basename;
use lib '/usr/local/avs/public_tools/';
use zero_util;

my $programName = basename($0);
my $usage = <<EOF;

Usage: $programName [options] file_personalconfig(个性化配置文件,可使用相对路径)
  --help                            Show this help message
  --noxml                           文件格式非xml,例如interface.conf. default(xml)
  --raw                            最原始的文件格式,例如raw.conf. default(xml)

EOF

my ($showHelp, $noXml, $raw)=(0,0);
my %options = ( 
        'help' => \$showHelp,
        'noxml' => \$noXml,
        'raw' => \$raw,
    );
GetOptions(%options);
if ($showHelp) {
    print STDERR $usage;
    exit 1;
}
my $file_personalconf=shift @ARGV||die "$usage\n";
if(! -e $file_personalconf)
{
    die "file($file_personalconf) no exist\n";
}
my $dir_conf=`shellpath=\$(readlink -f $file_personalconf ); dirname \$shellpath`;
chomp $dir_conf;
print "file_personalconf: $file_personalconf dir_conf: $dir_conf\n";
#exit;

my $LocalIP = &zGetLocalip();
#读取个性化配置文件
my $H_FILE;
if(!open($H_FILE, "<$file_personalconf")){
    die "can't open $file_personalconf !";
}
while(my $line=<$H_FILE>){
    chomp $line;
    #print "$line\n";
    #ip[,ip]    配置文件名      配置项目录(支持多级例如: Main/sub) 配置项     配置项值 备注信息
    my ($ips,$file_conf,$dir_item,$item,$value,$back);
    if($line =~ /^([^#\s]+)\s+([^\s]+)\s+([^\s]+)\s+("|')([^"']+)("|')\s+([^\s]+)\s+([^\s]*)/)
    {
        ($ips,$file_conf,$dir_item,$item,$value,$back)=($1, $2, $3, "$5", $7, $8);
    }
    elsif($line =~ /^([^#\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+("|')([^"']+)("|')\s+([^\s]*)/)
    {
        ($ips,$file_conf,$dir_item,$item,$value,$back)=($1, $2, $3, $4, "$6", $8);
    }
    elsif($line =~ /^([^#\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]*)/)
    {
        ($ips,$file_conf,$dir_item,$item,$value,$back)=($1, $2, $3, $4, $5, $6);
    }
    else
    {
        next;
    }
    #syswrite( STDOUT, "item: $item value: $value\n");
    $file_conf="$dir_conf/$file_conf";
    print "$ips,$file_conf,$dir_item,$item,$value,$back \n";
    #LocalIP是否在ips列表中
    if($ips !~ /$LocalIP/){
        next;
    }
    #读取file_conf
    my $file_conf_tmp="${file_conf}.tmp";

    my ($H_FILE_CONF, $H_FILE_CONF_TMP);
    if(!open($H_FILE_CONF, "<$file_conf")){
        die "can't open $file_conf !";
    }
    if(!open($H_FILE_CONF_TMP, ">$file_conf_tmp")){
        die "can't open $file_conf_tmp !";
    }
    #my $content_new="";
    my @dirs=split(/\//, $dir_item);
    if($noXml){
        &noxmlreplace(\@dirs, $H_FILE_CONF, $H_FILE_CONF_TMP, $item, $value);
    }
    elsif($raw){
        &rawreplace(\@dirs, $H_FILE_CONF, $H_FILE_CONF_TMP, $item, $value);
    }
    else{
        &xmlreplace(\@dirs, $H_FILE_CONF, $H_FILE_CONF_TMP, $item, $value);
    }
=pod
    my ($idx, $len, $brange)=(0, scalar(@dirs), 0);
    while(my $line_conf=<$H_FILE_CONF>){
        chomp $line_conf;
        if($idx<$len && $line_conf =~ /<$dirs[$idx]>/){
            #print "hit dir: $dirs[$idx]. $line_conf\n";
            $idx++;
            if($idx==$len){
                $brange=1;
            }
        }
        if($line_conf =~ /<\/$dirs[$len-1]>/){
            $brange=0;
            #print "hit re dir: $dirs[$len-1]. $line_conf\n";
        }
        if(1==$brange && $line_conf =~ /^(\s*\b$item\b\s*=)\s*[^\s#]+\s*(#.*)/){
            #print "hit item: $item. $line_conf. $1\n";
            #$content_new="$content_new$1 $value\n";
            syswrite( $H_FILE_CONF_TMP, "$1 $value $2\n");
        }
        else{
            #$content_new="$content_new$line_conf\n";
            syswrite( $H_FILE_CONF_TMP, "$line_conf\n");
        }
    }
=cut
    close($H_FILE_CONF);
    close($H_FILE_CONF_TMP);
    my $diff=`cp $file_conf $file_conf.bak;mv $file_conf_tmp $file_conf;diff $file_conf $file_conf.bak`;
    chown $diff;
    print "=========================diff:\n$diff\n";

    #print "=========================new content:\n$content_new";
    #`echo "$content_new" > ./tmp.conf`;
     
}
sub noxmlreplace()
{
    my ($dirs_arr, $H_FILE_CONF, $H_FILE_CONF_TMP, $item, $value)=@_;
    my ($idx, $len, $brange)=(0, scalar(@$dirs_arr), 0);
    while(my $line_conf=<$H_FILE_CONF>){
        chomp $line_conf;
        if($idx<$len && $line_conf =~ /\[$$dirs_arr[$idx]\]/){
            #print "hit dir: $$dirs_arr[$idx]. $line_conf\n";
            $idx++;
            if($idx==$len){
                $brange=1;
            }
        }
        elsif($line_conf =~ /^\[/){
            $brange=0;
            #print "hit re dir: $$dirs_arr[$len-1]. $line_conf\n";
        }
        if(1==$brange && $line_conf =~ /^(\s*\b$item\b\s*=)\s*[^\s]*\s*([#]*.*)/){
            #print "hit item: $item. $line_conf. $1\n";
            #$content_new="$content_new$1 $value\n";
            syswrite( $H_FILE_CONF_TMP, "$1 $value $2\n");
        }
        else{
            #$content_new="$content_new$line_conf\n";
            syswrite( $H_FILE_CONF_TMP, "$line_conf\n");
        }
    }
}
sub xmlreplace()
{
    my ($dirs_arr, $H_FILE_CONF, $H_FILE_CONF_TMP, $item, $value)=@_;
    my ($idx, $len, $brange)=(0, scalar(@$dirs_arr), 0);
    while(my $line_conf=<$H_FILE_CONF>){
        chomp $line_conf;
        if($idx<$len && $line_conf =~ /<$$dirs_arr[$idx]>/){
            #print "hit dir: $$dirs_arr[$idx]. $line_conf\n";
            $idx++;
            if($idx==$len){
                $brange=1;
            }
        }
        if($line_conf =~ /<\/$$dirs_arr[$len-1]>/){
            $brange=0;
            #print "hit re dir: $$dirs_arr[$len-1]. $line_conf\n";
        }
        if(1==$brange && $line_conf =~ /^(\s*\b$item\b\s*=)\s*[^\s#]*\s*([#]*.*)/){
            #print "hit item: $item. $line_conf. $1\n";
            #$content_new="$content_new$1 $value\n";
            syswrite( $H_FILE_CONF_TMP, "$1 $value $2\n");
        }
        else{
            #$content_new="$content_new$line_conf\n";
            syswrite( $H_FILE_CONF_TMP, "$line_conf\n");
        }
    }
}
sub rawreplace()
{
    my ($dirs_arr, $H_FILE_CONF, $H_FILE_CONF_TMP, $item, $value)=@_;
    while(my $line_conf=<$H_FILE_CONF>){
        chomp $line_conf;
        if($line_conf =~ /^(\s*\b$item\b)\s*[^\s#]*\s*([#]*.*)/){
            #print "hit item: $item. $line_conf. $1\n";
            #$content_new="$content_new$1 $value\n";
            #syswrite( $H_FILE_CONF_TMP, "$1 $value $2\n");
            #
            syswrite( $H_FILE_CONF_TMP, "$1 $value\n");
        }
        else{
            #$content_new="$content_new$line_conf\n";
            syswrite( $H_FILE_CONF_TMP, "$line_conf\n");
        }
    }
}
close($H_FILE);

#zeroshen 得到机器的内网IP
#参数列表:  无
#返回值:
#       成功返回得到第一个本机的内网ip
#       失败返回undef
=pod
sub zGetLocalip{
    my $ip;
    my @allip = `/sbin/ifconfig | awk '/inet\ addr/{print \$2}' | awk -F":" '{print \$2}'`;
    foreach $ip (@allip){
        chomp $ip;
        my ($range1,$range2) = (split(/\./,$ip))[0,1]; 
        if(($range1 == 192 && $range2 == 168) || ($range1 == 172 && $range2 >= 16 && $range2 <= 31) || $range1 == 10){
            #对于这两台上海金桥的机器，取值不一样 ginozhang 2014.12.16
            if("$ip" eq "10.238.140.223" || "$ip" eq "10.238.139.221")
            {
                next;
            }
            return $ip;
        } 
    }
    return undef;
}
=cut

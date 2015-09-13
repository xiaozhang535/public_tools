#!/usr/bin/perl
####################################
# 2011.04.25 created by ginozhang 
#   added: udp client
####################################

package util_sock;
use strict;
use Socket;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(InitUdpClientSock Send2UdpSrv Recv4UdpSrv);

#初始化udp客户端socket
#参数列表:
#       sock    : 传引用
#       address : 传引用
#       ip:
#       port:
#       timeout : 超时时间
#返回值: 
#       0 : success
#       !0: fail
sub InitUdpClientSock{
    my ($out_sock, $out_address, $ip, $port, $timeout)=@_ ;
    defined($timeout) or $timeout=10;
    my $proto = getprotobyname('udp');    
    socket($$out_sock, PF_INET, SOCK_DGRAM, $proto)
        or return -1; #die "socket: $!";    

    setsockopt($$out_sock, SOL_SOCKET, SO_SNDTIMEO, pack('L!L!', $timeout, 0) ) or die $!;
    setsockopt($$out_sock, SOL_SOCKET, SO_RCVTIMEO, pack('L!L!', $timeout, 0) ) or die $!;
    $$out_address = sockaddr_in($port,inet_aton($ip));
    return 0;
}
#发送udp包
#参数列表:
#       sock    : 
#       address : 
#       msg:
#返回值: 
#       >0 : success
#       <=0: fail
sub Send2UdpSrv{
    my ($sock, $address, $msg)=@_ ;
    if(!defined($sock) || !defined($address) || !defined($msg)){
        return -1;
    }
    my $rnt=send($sock, "$msg", 0, $address);
    if(!defined($rnt) || $rnt <= 0){
        return -3;
    }

    return $rnt;
}

#发送udp包
#参数列表:
#       sock    : 
#返回值: 
#       非空 : 收到的数据包
#       空   : fail
sub Recv4UdpSrv{
    my $sock=shift @_ ;
    if(!defined($sock) ){
        syswrite(STDERR, "error: sock or msg nodefined\n");
        return "";
    }
    my $szRcvBuf;
    my $MAX_LEN_BUFFER=40960;
    recv($sock, $szRcvBuf, $MAX_LEN_BUFFER, MSG_WAITALL);
    if(!defined($szRcvBuf)){
        return "";
    }
    return $szRcvBuf;
}

%========初始化区域=========
clear;
close all;
%========================

%=========用户参数设定区==========
%-------------地理蜂窝设定区----------------
true_length=500;%真实地理区域设定，单位m
axis_bs_loop=2;%从零开始，蜂窝网络圈数确定
axis_bs_num=6;%从零开始，每圈蜂窝网络完整度，上限6
%--------------------------------------------

%--------------ms设定区-------------------
ms_pernum=1000;%每个蜂窝小区中用户数量
%------------------------------------------

%----------------基础设定区---------------
bs_power=40;%基站发射总功率，单位W
bs_SINR=3;%区分基站中心边缘，单位dB
bs_connect_SINR=-30;%确立连接的SINR值
%------------------------------------------

%----------------资源块设定区---------------
bs_bandwidth=10;%MHz
tape_allnum=50;%50个资源块
tape_slot=12;%包含12个子载波
tape_time=1;%ms
tape_alltime=1000;%ms
tape_do_num=tape_alltime/tape_time;
tpf=20;
%--------------------------------------------
%============================

%====================地理蜂窝构建及用户撒布区========================
%--------------------重要参数区----------------------------------
bs_coordinate=0;%返回基站坐标
ms_coordinate=0;%返回用户坐标
ms_allnum=0;
%-----------------------------------------------------------------

%--------------------变量创建区----------------------------------
A=pi/3*[0:6];%创建边缘蜂窝6个点角度相对坐标
At=-pi/2-pi/3*[0:6];%6个小区包围1个
aa=linspace(0,pi*2,80);%创建边缘
bs_border_r=true_length;
bs_num=1;
bottle_bs_coordinate=0;
bottle_ms_num=1;
%-----------------------------------------------------------------

%-----------------------创建区------------------------------------
%蜂窝小区基站坐标创建
for k=1:axis_bs_loop
    bottle_bs_coordinate=bottle_bs_coordinate+sqrt(3)*bs_border_r*exp(i*pi/6);
    for pp=1:axis_bs_num
        for p=1:k
            bs_num=bs_num+1;
            bs_coordinate(1,bs_num)=bottle_bs_coordinate;
            bottle_bs_coordinate=bottle_bs_coordinate+sqrt(3)*bs_border_r*exp(i*At(pp));
        end
    end
end

%用户坐标创建
for k=1:bs_num
    ms_coordinate(1,bottle_ms_num:bottle_ms_num+ms_pernum-1)=bs_coordinate(1,k)+putuser(ms_pernum,bs_border_r);
    bottle_ms_num=bottle_ms_num+ms_pernum;
    ms_allnum=bottle_ms_num-1;
end
%-------------------------------------------------------------------
%===========================================================

%==================用户覆盖功率计算及连接判断========================
%设计概想为发射测试信号，取覆盖概率最大者建立连接。因只需考虑最中心小区用户，多余数据不予储存
%-------------------重要参数区------------------------
ms_test_coordinate=0;%保存测试ms坐标信息
ms_test_power=0;%保存测试ms在不同bs覆盖下的功率值，列为不同基站
ms_test_distance=0;%保存测试ms距不同基站的距离，列为不同基站
ms_test_SINR=0;%保存测试ms的SINR
ms_test_num=0;
ms_test_loss=0;
ms_distance=0;
ms_power=0;
ms_loss=0;
ms_test_center_SINR=0;%小区中心用户信息
ms_test_center_power=0;
ms_test_center_loss=0;
ms_test_center_distance=0;
ms_test_border_SINR=0;%小区边缘用户信息
ms_test_border_power=0;
ms_test_border_loss=0;
ms_test_border_distance=0;
ms_test_center_num=0;
ms_test_border_num=0;
%------------------------------------------------------

%---------------------变量创建区----------------------
bs_dbm=ptodbm(bs_power);
min_ms_power=0;
bottle_ms_test_coordinate=0;
bottle_ms_test_SINR=0;
bottle_ms_test_power=0;
bottle_ms_test_distance=0;
test_rc=0;
test_bc=0;
%------------------------------------------------------

%------------------------RB分配区--------------------------------
ms_test_tape_power=bs_power/tape_allnum;%单位W
ms_test_tape_dbm=ptodbm(ms_test_tape_power);
ms_test_tape_num=tape_allnum;
%------------------------------------------------------------------

%----------------------测试信号覆盖运算区------------------------
for k=1:ms_allnum
    ms_x=real(ms_coordinate(k));
    ms_y=imag(ms_coordinate(k));
    for p=1:bs_num
        bs_x=real(bs_coordinate(p));
        bs_y=imag(bs_coordinate(p));
        ms_distance(p,k)=distance(ms_x,ms_y,bs_x,bs_y);%单位m
        ms_loss(p,k)=loss(ms_distance(p,k));
        ms_power(p,k)=ms_test_tape_dbm-loss(ms_distance(p,k));%单位dBm
    end
end
%-------------------------------------------------------------------

%------------------------初次确立连接区-----------------------------
[max_ms_power,max_ms_index]=max(ms_power);
for k=1:ms_allnum
    if max_ms_index(k)==1
        ms_test_num=ms_test_num+1;
        ms_test_coordinate(1,ms_test_num)=ms_coordinate(k);
        ms_test_loss(1:bs_num,ms_test_num)=ms_loss(1:bs_num,k);
        ms_test_power(1:bs_num,ms_test_num)=ms_power(1:bs_num,k);
        ms_test_distance(1:bs_num,ms_test_num)=ms_distance(1:bs_num,k);
    end
end
%plot(ms_test_coordinate,'*');
%--------------------------------------------------------------------

%-------------------------SINR计算区-------------------------------
for k=1:length(ms_test_coordinate)
    ms_test_SINR(1,k)=sinr(ms_test_power(1:bs_num,k));
end
%--------------------------------------------------------------------

%---------------------------二次连接确立区--------------------------
%bottle_ms_test_num=0;
%for k=1:length(ms_test_coordinate)
%  if ms_test_SINR(1,k)>=bs_connect_SINR
%        bottle_ms_test_num=bottle_ms_test_num+1;
%        bottle_ms_test_coordinate(1,bottle_ms_test_num)=ms_test_coordinate(1,k);
%        bottle_ms_test_loss(1:bs_num,bottle_ms_test_num)=ms_test_loss(1:bs_num,k);
%        bottle_ms_test_power(1:bs_num,bottle_ms_test_num)=ms_test_power(1:bs_num,k);
%        bottle_ms_test_distance(1:bs_num,bottle_ms_test_num)=ms_test_distance(1:bs_num,k);
%        bottle_ms_test_SINR(1,bottle_ms_test_num)=ms_test_SINR(1,k);
%    end
%end
%ms_test_coordinate=bottle_ms_test_coordinate;
%ms_test_loss=bottle_ms_test_loss;
%ms_test_power=bottle_ms_test_power;
%ms_test_distance=bottle_ms_test_distance;
%ms_test_SINR=bottle_ms_test_SINR;
%--------------------------------------------------------------------

%--------------------------------RR分配区----------------------------------------------
ms_test_rr_num(1,1:ms_test_num)=0;
bottle_test_rr_num=0;
if ms_test_num>=ms_test_tape_num
    for k=1:tape_do_num
        for p=1:ms_test_tape_num
            bottle_test_rr_num=bottle_test_rr_num+1;
            ms_test_rr_num(1,bottle_test_rr_num)=ms_test_rr_num(1,bottle_test_rr_num)+1;
            if bottle_test_rr_num==ms_test_num
                bottle_test_rr_num=0;
            end
        end
    end
else
    for k=1:tape_do_num
        for p=1:ms_test_num
            ms_test_rr_num(1,p)=ms_test_rr_num(1,p)+1;
        end
    end
end
%---------------------------------------------------------------------------------------

%------------------------------PF分配区--------------------------------
ms_test_pf_num(1,1:ms_test_num)=0;
bottle_test_pf_tout(1,1:ms_test_num)=0;
for k=1:ms_test_num
    bottle_test_pf_tout(1,k)=throughout(ms_test_SINR(1,k),tape_slot,tape_time);
end
ms_test_pf_level(1,1:ms_test_num)=(1-1/tpf)*sum(bottle_test_pf_tout(1,:))/length(bottle_test_pf_tout(1,:));
if ms_test_num>=ms_test_tape_num
    for k=1:tape_do_num
        ms_test_pf_level(2,1:ms_test_num)=0;
        for p=1:ms_test_tape_num
            bottle_index=findpf(ms_test_pf_num,ms_test_pf_level,bottle_test_pf_tout,tpf);
            ms_test_pf_num=bottle_index(1,:);
            ms_test_pf_level=bottle_index(2:3,:);
        end
    end
else
    for k=1:tape_do_num
        ms_test_pf_level(2,1:ms_test_num)=0;
        for p=1:ms_test_num
            bottle_index=findpf(ms_test_pf_num,ms_test_pf_level,bottle_test_pf_tout,tpf);
            ms_test_pf_num=bottle_index(1,:);
            ms_test_pf_level=bottle_index(2:3,:);
        end
    end
end
%-----------------------------------------------------------------------

%--------------------------------MCI分配区-------------------------------------
if ms_test_num>=round(ms_test_tape_num/10)
    ms_test_mci_position=findmci(ms_test_SINR,round(ms_test_tape_num/10));
else
    ms_test_mci_position=findmci(ms_test_SINR,ms_test_num);
end
ms_test_mci_num(1,1:ms_test_num)=0;
ms_test_mci_num(1,ms_test_mci_position(:))=tape_do_num;
%--------------------------------------------------------------------------------

%----------------------------中心边缘用户划分区------------------------------
for k=1:length(ms_test_SINR)
    if ms_test_SINR(k)>=bs_SINR
        ms_test_center_num=ms_test_center_num+1;
        ms_test_center_SINR(1,ms_test_center_num)=ms_test_SINR(1,k);
        ms_test_center_loss(1:bs_num,ms_test_center_num)=ms_test_loss(1:bs_num,k);
        ms_test_center_power(1:bs_num,ms_test_center_num)=ms_test_power(1:bs_num,k);
        ms_test_center_distance(1:bs_num,ms_test_center_num)=ms_test_distance(1:bs_num,k);
    else
        ms_test_border_num=ms_test_border_num+1;
        ms_test_border_SINR(1,ms_test_border_num)=ms_test_SINR(1,k);
        ms_test_border_loss(1:bs_num,ms_test_border_num)=ms_test_loss(1:bs_num,k);
        ms_test_border_power(1:bs_num,ms_test_border_num)=ms_test_power(1:bs_num,k);
        ms_test_border_rr_num(1,ms_test_border_num)=ms_test_rr_num(1,k);
        ms_test_border_pf_num(1,ms_test_border_num)=ms_test_pf_num(1,k);
        ms_test_border_mci_num(1,ms_test_border_num)=ms_test_mci_num(1,k);
    end
end
%test_rc=max(ms_test_center_distance(1,:));
%------------------------------------------------------------------------------

%---------------------------------吞吐量计算区------------------------------------
%RR
ms_test_rr_tout(1,1:ms_test_num)=0;
for k=1:ms_test_num
    ms_test_rr_tout(1,k)=throughout(ms_test_SINR(1,k),tape_slot,tape_time)*ms_test_rr_num(1,k);
end
for k=1:ms_test_border_num
    ms_test_border_rr_tout(1,k)=throughout(ms_test_border_SINR(1,k),tape_slot,tape_time)*ms_test_border_rr_num(1,k);
end
test_rr_tout=sum(ms_test_rr_tout(:));%/ms_test_num;
test_border_rr_tout=sum(ms_test_border_rr_tout(:));%/ms_test_border_num;
test_rr_efficiency=test_rr_tout/ms_test_tape_num;
test_rr_cover=cover(ms_test_rr_tout);
ms_test_rr_fair=fair(ms_test_rr_tout);

%PF
ms_test_pf_tout(1,1:ms_test_num)=0;
for k=1:ms_test_num
    ms_test_pf_tout(1,k)=throughout(ms_test_SINR(1,k),tape_slot,tape_time)*ms_test_pf_num(1,k);
end
for k=1:ms_test_border_num
    ms_test_border_pf_tout(1,k)=throughout(ms_test_border_SINR(1,k),tape_slot,tape_time)*ms_test_border_pf_num(1,k);
end
test_pf_tout=sum(ms_test_pf_tout(:));
test_border_pf_tout=sum(ms_test_border_pf_tout(:));
test_pf_efficiency=test_pf_tout/ms_test_tape_num;
test_pf_cover=cover(ms_test_pf_tout);
ms_test_pf_fair=fair(ms_test_pf_tout);

%Max C/I
ms_test_mci_tout(1,1:ms_test_num)=0;
for k=1:ms_test_num
    ms_test_mci_tout(1,k)=throughout(ms_test_SINR(1,k),tape_slot,tape_time)*ms_test_mci_num(1,k);
end
for k=1:ms_test_border_num
    ms_test_border_mci_tout(1,k)=throughout(ms_test_border_SINR(1,k),tape_slot,tape_time)*ms_test_border_mci_num(1,k);
end
test_mci_tout=sum(ms_test_mci_tout(:));
test_border_mci_tout=sum(ms_test_border_mci_tout(:));
test_mci_efficiency=test_mci_tout/round(ms_test_tape_num/10);
test_mci_cover=cover(ms_test_mci_tout);
ms_test_mci_fair=fair(ms_test_mci_tout);
%-----------------------------------------------------------------------------------
%===========================================================

%======================FFR3区================================
%目的为配置采用FFR，复用因子为3的蜂窝小区
%-----------------------重要参数区------------------------
%因为采用复用因子为3的FFR，所以最精简且完善情况为
%19个蜂窝小区组成的蜂窝簇
ms_ffr3_center_loss=ms_test_center_loss;
ms_ffr3_border_loss=ms_test_border_loss(1,:);
ms_ffr3_center_SINR=0;
ms_ffr3_border_SINR=0;
%----------------------------------------------------------

%-------------------------变量创建区---------------------------

%---------------------------------------------------------------

%-----------------------------RB配置区----------------------------------
ms_ffr3_tape_border_num=round(tape_allnum/6);
ms_ffr3_tape_center_num=tape_allnum-3*ms_ffr3_tape_border_num;
ms_ffr3_tape_power=bs_power/(ms_ffr3_tape_center_num+ms_ffr3_tape_border_num);
ms_ffr3_tape_dbm=ptodbm(ms_ffr3_tape_power);
%-------------------------------------------------------------------------

%--------------------------接收功率计算区--------------------------------
for k=1:6
    ms_ffr3_border_loss(k+1,1:ms_test_border_num)=ms_test_border_loss(7+2*k,:);
end
ms_ffr3_center_power=ms_ffr3_tape_dbm-ms_ffr3_center_loss;
ms_ffr3_border_power=ms_ffr3_tape_dbm-ms_ffr3_border_loss;
%-------------------------------------------------------------------------

%----------------------------SINR计算区-----------------------------------
for k=1:ms_test_center_num
    ms_ffr3_center_SINR(1,k)=sinr(ms_ffr3_center_power(:,k));
end
for k=1:ms_test_border_num
    ms_ffr3_border_SINR(1,k)=sinr(ms_ffr3_border_power(1:7,k));
end
ms_ffr3_SINR=[ms_ffr3_center_SINR,ms_ffr3_border_SINR];
%---------------------------------------------------------------------------

%-----------------------------RR分配区-----------------------------------
ms_ffr3_center_rr_num(1,1:ms_test_center_num)=0;
ms_ffr3_border_rr_num(1,1:ms_test_border_num)=0;
bottle_ffr3_center_rr_num=0;
bottle_ffr3_border_rr_num=0;
if ms_test_center_num>=ms_ffr3_tape_center_num
    for k=1:tape_do_num
        for p=1:ms_ffr3_tape_center_num
            bottle_ffr3_center_rr_num=bottle_ffr3_center_rr_num+1;
            ms_ffr3_center_rr_num(1,bottle_ffr3_center_rr_num)=ms_ffr3_center_rr_num(1,bottle_ffr3_center_rr_num)+1;
            if bottle_ffr3_center_rr_num==ms_test_center_num
                bottle_ffr3_center_rr_num=0;
            end
        end
    end
else
    for k=1:tape_do_num
        for p=1:ms_test_center_num
            ms_ffr3_center_rr_num(1,p)=ms_ffr3_center_rr_num(1,p)+1;
        end
    end
end

if ms_test_border_num>=ms_ffr3_tape_border_num
    for k=1:tape_do_num
        for p=1:ms_ffr3_tape_border_num
            bottle_ffr3_border_rr_num=bottle_ffr3_border_rr_num+1;
            ms_ffr3_border_rr_num(1, bottle_ffr3_border_rr_num)=ms_ffr3_border_rr_num(1, bottle_ffr3_border_rr_num)+1;
            if bottle_ffr3_border_rr_num==ms_test_border_num
                bottle_ffr3_border_rr_num=0;
            end
        end
    end
else
    for k=1:tape_do_num
        for p=1:ms_test_border_num
            ms_ffr3_border_rr_num(1,p)=ms_ffr3_border_rr_num(1,p)+1;
        end
    end
end
ms_ffr3_rr_num=[ms_ffr3_center_rr_num,ms_ffr3_border_rr_num];
%-------------------------------------------------------------------------

%------------------------------PF分配区--------------------------------
ms_ffr3_center_pf_num(1,1:ms_test_center_num)=0;
bottle_ffr3_center_pf_tout(1,1:ms_test_center_num)=0;
for k=1:ms_test_center_num
    bottle_ffr3_center_pf_tout(1,k)=throughout(ms_ffr3_center_SINR(1,k),tape_slot,tape_time);
end
ms_ffr3_center_pf_level(1,1:ms_test_center_num)=(1-1/tpf)*sum(bottle_ffr3_center_pf_tout(1,:))/ms_test_center_num;
if ms_test_center_num>=ms_ffr3_tape_center_num
    for k=1:tape_do_num
        ms_ffr3_center_pf_level(2,1:ms_test_center_num)=0;
        for p=1:ms_ffr3_tape_center_num
            bottle_index=findpf(ms_ffr3_center_pf_num,ms_ffr3_center_pf_level,bottle_ffr3_center_pf_tout,tpf);
            ms_ffr3_center_pf_num=bottle_index(1,:);
            ms_ffr3_center_pf_level=bottle_index(2:3,:);
        end
    end
else
    for k=1:tape_do_num
        ms_ffr3_center_pf_level(2,1:ms_test_center_num)=0;
        for p=1:ms_test_center_num
            bottle_index=findpf(ms_ffr3_center_pf_num,ms_ffr3_center_pf_level,bottle_ffr3_center_pf_tout,tpf);
            ms_ffr3_center_pf_num=bottle_index(1,:);
            ms_ffr3_center_pf_level=bottle_index(2:3,:);
        end
    end
end

ms_ffr3_border_pf_num(1,1:ms_test_border_num)=0;
bottle_ffr3_border_pf_tout(1,1:ms_test_border_num)=0;
for k=1:ms_test_border_num
    bottle_ffr3_border_pf_tout(1,k)=throughout(ms_ffr3_border_SINR(1,k),tape_slot,tape_time);
end
ms_ffr3_border_pf_level(1,1:ms_test_border_num)=(1-1/tpf)*sum(bottle_ffr3_border_pf_tout(1,:))/ms_test_border_num;
if ms_test_border_num>=ms_ffr3_tape_border_num
    for k=1:tape_do_num
        ms_ffr3_border_pf_level(2,1:ms_test_border_num)=0;
        for p=1:ms_ffr3_tape_border_num
            bottle_index=findpf(ms_ffr3_border_pf_num,ms_ffr3_border_pf_level,bottle_ffr3_border_pf_tout,tpf);
            ms_ffr3_border_pf_num=bottle_index(1,:);
            ms_ffr3_border_pf_level=bottle_index(2:3,:);
        end
    end
else
    for k=1:tape_do_num
        ms_ffr3_border_pf_level(2,1:ms_test_border_num)=0;
        for p=1:ms_test_border_num
            bottle_index=findpf(ms_ffr3_border_pf_num,ms_ffr3_border_pf_level,bottle_ffr3_border_pf_tout,tpf);
            ms_ffr3_border_pf_num=bottle_index(1,:);
            ms_ffr3_border_pf_level=bottle_index(2:3,:);
        end
    end
end
ms_ffr3_pf_num=[ms_ffr3_center_pf_num,ms_ffr3_border_pf_num];
%-----------------------------------------------------------------------

%--------------------------------MCI分配区-------------------------------------
ffr3_mci_tape_num=ms_ffr3_tape_center_num+ms_ffr3_tape_border_num;
if ms_test_num>=round(ffr3_mci_tape_num/10)
    ms_ffr3_mci_position=findmci(ms_ffr3_SINR,round(ffr3_mci_tape_num/10));
else
    ms_ffr3_mci_position=findmci(ms_ffr3_SINR,ms_test_num);
end
ms_ffr3_mci_num(1,1:ms_test_num)=0;
ms_ffr3_mci_num(1,ms_ffr3_mci_position(:))=tape_do_num;
%--------------------------------------------------------------------------------

%----------------------------------吞吐量计算区------------------------------------
%RR
ms_ffr3_center_rr_tout(1,1:ms_test_center_num)=0;
ms_ffr3_border_rr_tout(1,1:ms_test_border_num)=0;
for k=1:ms_test_center_num
    ms_ffr3_center_rr_tout(1,k)=throughout(ms_ffr3_center_SINR(1,k),tape_slot,tape_time)*ms_ffr3_center_rr_num(1,k);
end
for k=1:ms_test_border_num
    ms_ffr3_border_rr_tout(1,k)=throughout(ms_ffr3_border_SINR(1,k),tape_slot,tape_time)*ms_ffr3_border_rr_num(1,k);
end
ms_ffr3_rr_tout=[ms_ffr3_center_rr_tout,ms_ffr3_border_rr_tout];
ffr3_rr_tout=sum(ms_ffr3_rr_tout(:));%/ms_test_num;
ffr3_border_rr_tout=sum(ms_ffr3_border_rr_tout(:));%/ms_test_border_num;
ffr3_rr_efficiency=ffr3_rr_tout/(ms_ffr3_tape_center_num+ms_ffr3_tape_border_num);
ffr3_rr_cover=cover(ms_ffr3_rr_tout);
ms_ffr3_rr_fair=fair(ms_ffr3_rr_tout);

%PF
ms_ffr3_center_pf_tout(1,1:ms_test_center_num)=0;
ms_ffr3_border_pf_tout(1,1:ms_test_border_num)=0;
for k=1:ms_test_center_num
    ms_ffr3_center_pf_tout(1,k)=throughout(ms_ffr3_center_SINR(1,k),tape_slot,tape_time)*ms_ffr3_center_pf_num(1,k);
end
for k=1:ms_test_border_num
    ms_ffr3_border_pf_tout(1,k)=throughout(ms_ffr3_border_SINR(1,k),tape_slot,tape_time)*ms_ffr3_border_pf_num(1,k);
end
ms_ffr3_pf_tout=[ms_ffr3_center_pf_tout,ms_ffr3_border_pf_tout];
ffr3_pf_tout=sum(ms_ffr3_pf_tout(:));%/ms_test_num;
ffr3_border_pf_tout=sum(ms_ffr3_border_pf_tout(:));%/ms_test_border_num;
ffr3_pf_efficiency=ffr3_pf_tout/(ms_ffr3_tape_center_num+ms_ffr3_tape_border_num);
ffr3_pf_cover=cover(ms_ffr3_pf_tout);
ms_ffr3_pf_fair=fair(ms_ffr3_pf_tout);

%Mac C/I
ms_ffr3_mci_tout(1,1:ms_test_num)=0;
for k=1:ms_test_num
    ms_ffr3_mci_tout(1,k)=throughout(ms_ffr3_SINR(1,k),tape_slot,tape_time)*ms_ffr3_mci_num(1,k);
end
ms_ffr3_border_mci_tout=ms_ffr3_mci_tout(1,ms_test_center_num+1:end);
ffr3_mci_tout=sum(ms_ffr3_mci_tout(:));
ffr3_border_mci_tout=sum(ms_ffr3_border_mci_tout(:));
ffr3_mci_efficiency=ffr3_mci_tout/round(ffr3_mci_tape_num/10);
ffr3_mci_cover=cover(ms_ffr3_mci_tout);
ms_ffr3_mci_fair=fair(ms_ffr3_mci_tout);
%------------------------------------------------------------------------------------
%===========================================================

%============================SFR3区==========================
%--------------------------重要参数区--------------------------------
ms_sfr3_center_power=0;
ms_sfr3_border_power=0;
ms_sfr3_center_SINR=0;
ms_sfr3_border_SINR=0;
%---------------------------------------------------------------------

%----------------------------变量创建区---------------------------------
ms_sfr3_center_loss=ms_test_center_loss;
ms_sfr3_border_loss=ms_test_border_loss;
%------------------------------------------------------------------------

%----------------------------RB分配区-------------------------------
ms_sfr3_tape_center_num=round(2*tape_allnum/3);
ms_sfr3_tape_border_num=tape_allnum-ms_sfr3_tape_center_num;
ms_sfr3_tape_center_power=bs_power/(ms_sfr3_tape_center_num+2*ms_sfr3_tape_border_num);
ms_sfr3_tape_border_power=(bs_power-ms_sfr3_tape_center_power*ms_sfr3_tape_center_num)/ms_sfr3_tape_border_num;
ms_sfr3_tape_center_dbm(1:bs_num,1)=ptodbm(ms_sfr3_tape_border_power);%有深意，非错误
ms_sfr3_tape_border_dbm(1:bs_num,1)=ptodbm(ms_sfr3_tape_center_power);%
%---------------------------------------------------------------------

%-------------------------用户功率计算区----------------------------
for k=1:2:19
    ms_sfr3_tape_center_dbm(k,1)=ptodbm(ms_sfr3_tape_center_power);
end
for k=8:4:16
    ms_sfr3_tape_center_dbm(k,1)=ptodbm(ms_sfr3_tape_center_power);
end
ms_sfr3_tape_border_dbm(1,1)=ptodbm(ms_sfr3_tape_border_power);
for k=9:2:19
    ms_sfr3_tape_border_dbm(k,1)=ptodbm(ms_sfr3_tape_border_power);
end
for k=1:ms_test_center_num
    ms_sfr3_center_power(1:bs_num,k)=ms_sfr3_tape_center_dbm(:,1)-ms_sfr3_center_loss(:,k);
end
for k=1:ms_test_border_num
    ms_sfr3_border_power(1:bs_num,k)=ms_sfr3_tape_border_dbm(:,1)-ms_sfr3_border_loss(:,k);
end
%--------------------------------------------------------------------

%----------------------------用户SINR计算区------------------------------
for k=1:ms_test_center_num
    ms_sfr3_center_SINR(1,k)=sinr(ms_sfr3_center_power(:,k));
end
for k=1:ms_test_border_num
    ms_sfr3_border_SINR(1,k)=sinr(ms_sfr3_border_power(:,k));
end
ms_sfr3_SINR=[ms_sfr3_center_SINR,ms_sfr3_border_SINR];
%---------------------------------------------------------------------------

%-----------------------------RR分配区-----------------------------------
ms_sfr3_center_rr_num(1,1:ms_test_center_num)=0;
ms_sfr3_border_rr_num(1,1:ms_test_border_num)=0;
bottle_sfr3_center_rr_num=0;
bottle_sfr3_border_rr_num=0;
if ms_test_center_num>=ms_sfr3_tape_center_num
    for k=1:tape_do_num
        for p=1:ms_sfr3_tape_center_num
            bottle_sfr3_center_rr_num=bottle_sfr3_center_rr_num+1;
            ms_sfr3_center_rr_num(1,bottle_sfr3_center_rr_num)=ms_sfr3_center_rr_num(1,bottle_sfr3_center_rr_num)+1;
            if bottle_sfr3_center_rr_num==ms_test_center_num
                bottle_sfr3_center_rr_num=0;
            end
        end
    end
else
    for k=1:tape_do_num
        for p=1:ms_test_center_num
            ms_sfr3_center_rr_num(1,p)=ms_sfr3_center_rr_num(1,p)+1;
        end
    end
end

if ms_test_border_num>=ms_sfr3_tape_border_num
    for k=1:tape_do_num
        for p=1:ms_sfr3_tape_border_num
            bottle_sfr3_border_rr_num=bottle_sfr3_border_rr_num+1;
            ms_sfr3_border_rr_num(1, bottle_sfr3_border_rr_num)=ms_sfr3_border_rr_num(1, bottle_sfr3_border_rr_num)+1;
            if bottle_sfr3_border_rr_num==ms_test_border_num
                bottle_sfr3_border_rr_num=0;
            end
        end
    end
else
    for k=1:tape_do_num
        for p=1:ms_test_border_num
            ms_sfr3_border_rr_num(1,p)=ms_sfr3_border_rr_num(1,p)+1;
        end
    end
end
ms_sfr3_rr_num=[ms_sfr3_center_rr_num,ms_sfr3_border_rr_num];
%-------------------------------------------------------------------------

%------------------------------PF分配区--------------------------------
ms_sfr3_center_pf_num(1,1:ms_test_center_num)=0;
bottle_sfr3_center_pf_tout(1,1:ms_test_center_num)=0;
for k=1:ms_test_center_num
    bottle_sfr3_center_pf_tout(1,k)=throughout(ms_sfr3_center_SINR(1,k),tape_slot,tape_time);
end
ms_sfr3_center_pf_level(1,1:ms_test_center_num)=(1-1/tpf)*sum(bottle_sfr3_center_pf_tout(1,:))/ms_test_center_num;
if ms_test_center_num>=ms_sfr3_tape_center_num
    for k=1:tape_do_num
        ms_sfr3_center_pf_level(2,1:ms_test_center_num)=0;
        for p=1:ms_sfr3_tape_center_num
            bottle_index=findpf(ms_sfr3_center_pf_num,ms_sfr3_center_pf_level,bottle_sfr3_center_pf_tout,tpf);
            ms_sfr3_center_pf_num=bottle_index(1,:);
            ms_sfr3_center_pf_level=bottle_index(2:3,:);
        end
    end
else
    for k=1:tape_do_num
        ms_sfr3_center_pf_level(2,1:ms_test_center_num)=0;
        for p=1:ms_test_center_num
            bottle_index=findpf(ms_sfr3_center_pf_num,ms_sfr3_center_pf_level,bottle_sfr3_center_pf_tout,tpf);
            ms_sfr3_center_pf_num=bottle_index(1,:);
            ms_sfr3_center_pf_level=bottle_index(2:3,:);
        end
    end
end

ms_sfr3_border_pf_num(1,1:ms_test_border_num)=0;
bottle_sfr3_border_pf_tout(1,1:ms_test_border_num)=0;
for k=1:ms_test_border_num
    bottle_sfr3_border_pf_tout(1,k)=throughout(ms_sfr3_border_SINR(1,k),tape_slot,tape_time);
end
ms_sfr3_border_pf_level(1,1:ms_test_border_num)=(1-1/tpf)*sum(bottle_sfr3_border_pf_tout(1,:))/ms_test_border_num;
if ms_test_border_num>=ms_sfr3_tape_border_num
    for k=1:tape_do_num
        ms_sfr3_border_pf_level(2,1:ms_test_border_num)=0;
        for p=1:ms_sfr3_tape_border_num
            bottle_index=findpf(ms_sfr3_border_pf_num,ms_sfr3_border_pf_level,bottle_sfr3_border_pf_tout,tpf);
            ms_sfr3_border_pf_num=bottle_index(1,:);
            ms_sfr3_border_pf_level=bottle_index(2:3,:);
        end
    end
else
    for k=1:tape_do_num
        ms_sfr3_border_pf_level(2,1:ms_test_border_num)=0;
        for p=1:ms_test_border_num
            bottle_index=findpf(ms_sfr3_border_pf_num,ms_sfr3_border_pf_level,bottle_sfr3_border_pf_tout,tpf);
            ms_sfr3_border_pf_num=bottle_index(1,:);
            ms_sfr3_border_pf_level=bottle_index(2:3,:);
        end
    end
end
ms_sfr3_pf_num=[ms_sfr3_center_pf_num,ms_sfr3_border_pf_num];
%-----------------------------------------------------------------------

%--------------------------------MCI分配区-------------------------------------
sfr3_mci_tape_num=ms_sfr3_tape_center_num+ms_sfr3_tape_border_num;
if ms_test_num>=round(sfr3_mci_tape_num/10)
    ms_sfr3_mci_position=findmci(ms_sfr3_SINR,round(sfr3_mci_tape_num/10));
else
    ms_sfr3_mci_position=findmci(ms_sfr3_SINR,ms_test_num);
end
ms_sfr3_mci_num(1,1:ms_test_num)=0;
ms_sfr3_mci_num(1,ms_sfr3_mci_position(:))=tape_do_num;
%--------------------------------------------------------------------------------

%----------------------------------吞吐量计算区------------------------------------
%RR
ms_sfr3_center_rr_tout(1,1:ms_test_center_num)=0;
ms_sfr3_border_rr_tout(1,1:ms_test_border_num)=0;
for k=1:ms_test_center_num
    ms_sfr3_center_rr_tout(1,k)=throughout(ms_sfr3_center_SINR(1,k),tape_slot,tape_time)*ms_sfr3_center_rr_num(1,k);
end
for k=1:ms_test_border_num
    ms_sfr3_border_rr_tout(1,k)=throughout(ms_sfr3_border_SINR(1,k),tape_slot,tape_time)*ms_sfr3_border_rr_num(1,k);
end
ms_sfr3_rr_tout=[ms_sfr3_center_rr_tout,ms_sfr3_border_rr_tout];
sfr3_rr_tout=sum(ms_sfr3_rr_tout(:));
sfr3_border_rr_tout=sum(ms_sfr3_border_rr_tout(:));
sfr3_rr_efficiency=sfr3_rr_tout/(ms_sfr3_tape_center_num+ms_sfr3_tape_border_num);
sfr3_rr_cover=cover(ms_sfr3_rr_tout);
ms_sfr3_rr_fair=fair(ms_sfr3_rr_tout);

%PF
ms_sfr3_center_pf_tout(1,1:ms_test_center_num)=0;
ms_sfr3_border_pf_tout(1,1:ms_test_border_num)=0;
for k=1:ms_test_center_num
    ms_sfr3_center_pf_tout(1,k)=throughout(ms_sfr3_center_SINR(1,k),tape_slot,tape_time)*ms_sfr3_center_pf_num(1,k);
end
for k=1:ms_test_border_num
    ms_sfr3_border_pf_tout(1,k)=throughout(ms_sfr3_border_SINR(1,k),tape_slot,tape_time)*ms_sfr3_border_pf_num(1,k);
end
ms_sfr3_pf_tout=[ms_sfr3_center_pf_tout,ms_sfr3_border_pf_tout];
%ms_sfr3_pf_num=[ms_sfr3_center
sfr3_pf_tout=sum(ms_sfr3_pf_tout(:));%/ms_test_num;%Mbps
sfr3_border_pf_tout=sum(ms_sfr3_border_pf_tout(:));%/ms_test_border_num;
sfr3_pf_efficiency=sfr3_pf_tout/(ms_sfr3_tape_center_num+ms_sfr3_tape_border_num);
sfr3_pf_cover=cover(ms_sfr3_pf_tout);
ms_sfr3_pf_fair=fair(ms_sfr3_pf_tout);

%Max C/I
ms_sfr3_mci_tout(1,1:ms_test_num)=0;
for k=1:ms_test_num
    ms_sfr3_mci_tout(1,k)=throughout(ms_sfr3_SINR(1,k),tape_slot,tape_time)*ms_sfr3_mci_num(1,k);
end
ms_sfr3_border_mci_tout=ms_sfr3_mci_tout(1,ms_test_center_num+1:end);
sfr3_mci_tout=sum(ms_sfr3_mci_tout(:));
sfr3_border_mci_tout=sum(ms_sfr3_border_mci_tout(:));
sfr3_mci_efficiency=sfr3_mci_tout/round(sfr3_mci_tape_num/10);
sfr3_mci_cover=cover(ms_sfr3_mci_tout);
ms_sfr3_mci_fair=fair(ms_sfr3_mci_tout);
%------------------------------------------------------------------------------------
%===========================================================

%==========================图像反馈区===========================
%-----------------蜂窝小区绘图区----------------------
figure;
hold on;
axis square;
plot(bs_border_r*exp(i*A),'k','linewidth',2);
for k=1:bs_num
    zp=bs_coordinate(1,k)+bs_border_r*exp(i*A);
    g1=fill(real(zp),imag(zp),'k');
    set(g1,'FaceColor',[1,0.5,0],'edgecolor',[1,0,0]);
    text(real(bs_coordinate(1,k)),imag(bs_coordinate(1,k)),num2str(k),'fontsize',10);
end
%test_rc=500*0.7;
%zr=test_rc*exp(i*aa);
%g2=fill(real(zr),imag(zr),'k');
%set(g2,'FaceColor',[1,0.5,0],'edgecolor',[1,0.5,0],'EraseMode','xor');
%------------------------------------------------------

%-----------------用户撒布绘图区------------------------
plot(ms_test_coordinate,'*');
%--------------------------------------------------------

%-------------------用户SINR比较区----------------------
figure;
hold on;
grid on;
%复用因子为1，普通全部
ms_test_SINR_cdf=cdf(ms_test_SINR);
cdf_x=ms_test_SINR_cdf(1,:);
cdf_y=ms_test_SINR_cdf(3,:);
plot(cdf_x,cdf_y,'b-^','LineWidth',1.3);
%复用因子为3，普通全部
%ms_nor3_SINR_cdf=cdf(ms_nor3_SINR);
%cdf_x=ms_nor3_SINR_cdf(1,:);
%cdf_y=ms_nor3_SINR_cdf(3,:);
%plot(cdf_x,cdf_y,'m:>');
%复用因子为3，ffr3全部
ms_ffr3_SINR_cdf=cdf(ms_ffr3_SINR);
cdf_x=ms_ffr3_SINR_cdf(1,:);
cdf_y=ms_ffr3_SINR_cdf(3,:);
plot(cdf_x,cdf_y,'r:x','LineWidth',1.3);
%复用因子为3,sfr3全部
ms_sfr3_SINR_cdf=cdf(ms_sfr3_SINR);
cdf_x=ms_sfr3_SINR_cdf(1,:);
cdf_y=ms_sfr3_SINR_cdf(3,:);
plot(cdf_x,cdf_y,'k-.v','LineWidth',1.3);
xlabel('用户平均SINR值(db)');
ylabel('统计水平');
title('单个小区全部用户SINR值统计');
legend('复用因子为1,普通','复用因子为3,FFR','复用因子为3,SFR',4);

figure;
hold on;
grid on;
axis([-10 20 0 1]);
%复用因子为1，普通边缘
ms_test_border_SINR_cdf=cdf(ms_test_border_SINR);
cdf_x=ms_test_border_SINR_cdf(1,:);
cdf_y=ms_test_border_SINR_cdf(3,:);
plot(cdf_x,cdf_y,'b-^','LineWidth',1.3);
%复用因子为3，普通边缘
%ms_nor3_border_SINR_cdf=cdf(ms_nor3_border_SINR);
%cdf_x=ms_nor3_border_SINR_cdf(1,:);
%cdf_y=ms_nor3_border_SINR_cdf(3,:);
%plot(cdf_x,cdf_y,'m:>');
%复用因子为3，ffr3边缘
ms_ffr3_border_SINR_cdf=cdf(ms_ffr3_border_SINR);
cdf_x=ms_ffr3_border_SINR_cdf(1,:);
cdf_y=ms_ffr3_border_SINR_cdf(3,:);
plot(cdf_x,cdf_y,'r:x','LineWidth',1.3);
%复用因子为3,sfr3边缘
ms_sfr3_border_SINR_cdf=cdf(ms_sfr3_border_SINR);
cdf_x=ms_sfr3_border_SINR_cdf(1,:);
cdf_y=ms_sfr3_border_SINR_cdf(3,:);
plot(cdf_x,cdf_y,'k-.v','LineWidth',1.3);
xlabel('用户平均SINR值(db)');
ylabel('统计水平');
title('单个小区边缘用户SINR值统计');
legend('复用因子为1,普通','复用因子为3,FFR','复用因子为3,SFR',4);
%------------------------------------------------------------

%-----------------------吞吐量比较区--------------------------
figure;
all_tout_bar=[test_rr_tout,ffr3_rr_tout,sfr3_rr_tout;
    test_pf_tout,ffr3_pf_tout,sfr3_pf_tout;
    test_mci_tout,ffr3_mci_tout,sfr3_mci_tout];
bar(all_tout_bar,1);
set(gca,'xticklabel',{'RR','PF','MAX C/I'},'Xgrid','off','Ygrid','on');
xlabel('资源调度方式');
ylabel('总吞吐量(Mbps)');
title('小区用户总吞吐量统计');
legend('复用因子为1,普通','复用因子为3,FFR','复用因子为3,SFR',0);

figure;
border_tout_bar=[test_border_rr_tout,ffr3_border_rr_tout,sfr3_border_rr_tout;
    test_border_pf_tout,ffr3_border_pf_tout,sfr3_border_pf_tout;
    test_border_mci_tout,ffr3_border_mci_tout,sfr3_border_mci_tout];
bar(border_tout_bar,1);
set(gca,'xticklabel',{'RR','PF','MAX C/I'},'Xgrid','off','Ygrid','on');
xlabel('资源调度方式');
ylabel('总吞吐量(Mbps)');
title('小区边缘用户总吞吐量统计');
legend('复用因子为1,普通','复用因子为3,FFR','复用因子为3,SFR',0);
%--------------------------------------------------------------

%----------------------------公平性比较区--------------------------------
figure;
fair1_bar=[ms_test_rr_fair,ms_test_pf_fair,ms_test_mci_fair;
    ms_ffr3_rr_fair,ms_ffr3_pf_fair,ms_ffr3_mci_fair;
    ms_sfr3_rr_fair,ms_sfr3_pf_fair,ms_sfr3_mci_fair];
bar(fair1_bar,1);
set(gca,'xticklabel',{'COM1','FFR3','SFR3'},'Xgrid','off','Ygrid','on');
xlabel('干扰协调方式');
ylabel('公平性');
title('小区用户公平性比较');
legend('RR','PF','MAX C/I',0);

figure;
fair2_bar=[ms_test_rr_fair,ms_ffr3_rr_fair,ms_sfr3_rr_fair;
    ms_test_pf_fair,ms_ffr3_pf_fair,ms_sfr3_pf_fair;
    ms_test_mci_fair,ms_ffr3_mci_fair,ms_sfr3_mci_fair];
bar(fair2_bar,1);
set(gca,'xticklabel',{'RR','PF','MAX C/I'},'Xgrid','off','Ygrid','on');
xlabel('资源调度方式');
ylabel('公平性');
title('小区用户公平性比较');
legend('复用因子为1,普通','复用因子为3,FFR','复用因子为3,SFR',0);
%-------------------------------------------------------------------------

%-----------------------------频谱效率比较区-------------------------------
figure;
effi1_bar=[test_rr_efficiency,test_pf_efficiency,test_mci_efficiency;
    ffr3_rr_efficiency,ffr3_pf_efficiency,ffr3_mci_efficiency;
    sfr3_rr_efficiency,sfr3_pf_efficiency,sfr3_mci_efficiency];
bar(effi1_bar,1);
set(gca,'xticklabel',{'COM1','FFR3','SFR3'},'Xgrid','off','Ygrid','on');
xlabel('干扰协调方式');
ylabel('频谱效率');
title('小区用户频谱效率比较');
legend('RR','PF','MAX C/I',0);

figure;
effi2_bar=effi1_bar';
bar(effi2_bar,1);
set(gca,'xticklabel',{'RR','PF','MAX C/I'},'Xgrid','off','Ygrid','on');
xlabel('资源调度方式');
ylabel('频谱效率');
title('小区用户频谱效率比较');
legend('复用因子为1,普通','复用因子为3,FFR','复用因子为3,SFR',0);
%---------------------------------------------------------------------------

%-------------------------------覆盖率反馈区---------------------------------
figure;
pe_cover=[test_rr_cover,test_pf_cover,test_mci_cover,ffr3_rr_cover,ffr3_pf_cover,ffr3_mci_cover,sfr3_rr_cover,sfr3_pf_cover,sfr3_mci_cover];
pe_t={'COM1,RR','COM1,PF','COM1,MAX C/I','FFR3,RR','FFR3,PF','FFR3,MAX C/I','SFR3,RR','SFR3,PF','SFR3,MAX C/I'};
for k=1:9
    subplot(3,3,k)
    pie(pe_cover(1,k));
    title(pe_t(k));
end
%-----------------------------------------------------------------------------
%============================================================
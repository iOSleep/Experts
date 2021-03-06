//+------------------------------------------------------------------+
//|                                                       PubVar.mqh |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#ifndef _PUB_VAR_H
#define _PUB_VAR_H

#define EA_VERSION "V3.12"

#ifdef SHOW_COMMENT

input int MagicNum = 6666;
input int TimeFrame = PERIOD_M5; //时间周期
input int Passcode = 0; // 启动口令

input bool EnableTradingDate = false; //是否启用开仓起止日期
input datetime OpenOrderStartDate = ""; //开仓起始时间，为格林威治时间
input datetime OpenOrderEndDate = ""; //开仓截止时间，为格林威治时间

input bool EnableTradingTime = false; //是否启用开仓起止时段
input string OpenOrderStartTime = "00:00"; //开仓起始时间，为格林威治时间，格式"hh:mm", 如："00:01"
input string OpenOrderEndTime = "09:30"; //开仓截止时间，为格林威治时间，格式"hh:mm", 如："09:30"

input bool EnablePriceLimitForShortSideMin = false; //是否启用开空单价格低限
input double PriceLimitForShortSideMin = 0.017; //空单价格低限（高于此价格才开空单）
input bool EnablePriceLimitForLongSideMax = false; //是否启用开多单价格高限
input double PriceLimitForLongSideMax = 0.012; //多单价格高限（低于此价格才开多单）

input bool EnablePriceLimitForShortSideMax = false; //是否启用开空单价格高限
input double PriceLimitForShortSideMax = 0.017; //空单价格高限（低于此价格才开空单）
input bool EnablePriceLimitForLongSideMin = false; //是否启用开多单价格低限
input double PriceLimitForLongSideMin = 0.012; //多单价格低限（高于此价格才开多单）

input bool BaseOpenLotsInLoop = true; // 中间轮数是否开基础仓
input bool StopShortSide = false;// 是否停止空方开仓
input bool StopLongSide = false; // 是否停止多方开仓
input int StageMax = 5; // 最大加仓阶段数

input string Stage1 = "-----";  //阶段一:-----   
input double BaseOpenLots1 = 0.01;  //阶段一基础开仓手数
input double Multiple1 = 2.0;//阶段一加仓倍数
input double MulipleFactorForAppend1 = 1.0; //阶段一加仓倍数调整系数
input int AppendMax1 = 3;          // 阶段一最大加仓次数
input double PointOffsetForStage1 = 0.001; //阶段一加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend1 = 0.003; //阶段一加仓条件：本阶段内最低价格差变化幅度
input double AppendBackword1 = 0.1; // 阶段一加仓条件：加仓回调系数
input double PointOffsetFactorForAppend1 = 1.0; //阶段一加仓条件：最低价格差变化的调整系数
input double TakeProfitsPerLot1 = 20; //阶段一平仓条件：每手止盈获利金额
input double TakeProfitsFacor1 = 1.2; // 阶段一平仓条件：动态计算止盈金额调整系数
input double Backword1 = 0.1; // 阶段一平仓条件：移动止盈回调系数

input string Stage2 = "-----";  //阶段二:-----    
input double BaseOpenLots2 = 0.01;  //阶段二基础开仓手数
input double Multiple2 = 2.0;//阶段二加仓倍数
input double MulipleFactorForAppend2 = 1.0; //阶段二加仓倍数调整系数
input int AppendMax2 = 3;          // 阶段二最大加仓次数
input double PointOffsetForStage2 = 0.001; //阶段二加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend2 = 0.003; //阶段二加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend2 = 1.0; //阶段二加仓条件：最低价格差变化的调整系数
input double AppendBackword2 = 0.1; // 阶段二加仓条件：加仓回调系数
input double TakeProfitsPerLot2 = 20; //阶段二平仓条件：每手止盈获利金额
input double TakeProfitsFacor2 = 0.6; // 阶段二平仓条件：动态计算止盈金额调整系数
input double Backword2 = 0.1; // 阶段二平仓条件：移动止盈回调系数

input string Stage3 = "-----";  //阶段三:-----    
input double BaseOpenLots3 = 0.01;  //阶段三基础开仓手数
input double Multiple3 = 2.0;//阶段三加仓倍数
input double MulipleFactorForAppend3 = 1.0; //阶段三加仓倍数调整系数
input int AppendMax3 = 3;          // 阶段三最大加仓次数
input double PointOffsetForStage3 = 0.001; //阶段三加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend3 = 0.003; //阶段三加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend3 = 1.0; //阶段三加仓条件：最低价格差变化的调整系数
input double AppendBackword3 = 0.1; // 阶段三加仓条件：加仓回调系数
input double TakeProfitsPerLot3 = 20; //阶段三平仓条件：每手止盈获利金额
input double TakeProfitsFacor3 = 0.6; // 阶段三平仓条件：动态计算止盈金额调整系数
input double Backword3 = 0.1; // 阶段三平仓条件：移动止盈回调系数

input string Stage4 = "-----";  //阶段四:-----    
input double BaseOpenLots4 = 0.01;  //阶段四基础开仓手数
input double Multiple4 = 2.0;//阶段四加仓倍数
input double MulipleFactorForAppend4 = 1.0; //阶段四加仓倍数调整系数
input int AppendMax4 = 3;          // 阶段四最大加仓次数
input double PointOffsetForStage4 = 0.001; //阶段四加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend4 = 0.003; //阶段四加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend4 = 1.0; //阶段四加仓条件：最低价格差变化的调整系数
input double AppendBackword4 = 0.1; // 阶段四加仓条件：加仓回调系数
input double TakeProfitsPerLot4 = 20; //阶段四平仓条件：每手止盈获利金额
input double TakeProfitsFacor4 = 0.6; // 阶段四平仓条件：动态计算止盈金额调整系数
input double Backword4 = 0.1; // 阶段四平仓条件：移动止盈回调系数

input string Stage5 = "-----";  //阶段五:-----    
input double BaseOpenLots5 = 0.01;  //阶段五基础开仓手数
input double Multiple5 = 2.0;//阶段五加仓倍数
input double MulipleFactorForAppend5 = 1.0; //阶段五加仓倍数调整系数
input int AppendMax5 = 3;          // 阶段五最大加仓次数
input double PointOffsetForStage5 = 0.001; //阶段五加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend5 = 0.003; //阶段五加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend5 = 1.0; //阶段五加仓条件：最低价格差变化的调整系数
input double AppendBackword5 = 0.1; // 阶段五加仓条件：加仓回调系数
input double TakeProfitsPerLot5 = 20; //阶段五平仓条件：每手止盈获利金额
input double TakeProfitsFacor5 = 0.6; // 阶段五平仓条件：动态计算止盈金额调整系数
input double Backword5 = 0.1; // 阶段五平仓条件：移动止盈回调系数

input string Stage6 = "-----";  //阶段六:-----    
input double BaseOpenLots6 = 0.01;  //阶段六基础开仓手数
input double Multiple6 = 2.0;//阶段六加仓倍数
input double MulipleFactorForAppend6 = 1.0; //阶段六加仓倍数调整系数
input int AppendMax6 = 3;          // 阶段六最大加仓次数
input double PointOffsetForStage6 = 0.001; //阶段六加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend6 = 0.003; //阶段六加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend6 = 1.0; //阶段六加仓条件：最低价格差变化的调整系数
input double AppendBackword6 = 0.1; // 阶段六加仓条件：加仓回调系数
input double TakeProfitsPerLot6 = 20; //阶段六平仓条件：每手止盈获利金额
input double TakeProfitsFacor6 = 0.6; // 阶段六平仓条件：动态计算止盈金额调整系数
input double Backword6 = 0.1; // 阶段六平仓条件：移动止盈回调系数

input string Stage7 = "-----";  //阶段七:-----    
input double BaseOpenLots7 = 0.01;  //阶段七基础开仓手数
input double Multiple7 = 2.0;//阶段七加仓倍数
input double MulipleFactorForAppend7 = 1.0; //阶段七加仓倍数调整系数
input int AppendMax7 = 3;          // 阶段七最大加仓次数
input double PointOffsetForStage7 = 0.001; //阶段七加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend7 = 0.003; //阶段七加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend7 = 1.0; //阶段七加仓条件：最低价格差变化的调整系数
input double AppendBackword7 = 0.1; // 阶段七加仓条件：加仓回调系数
input double TakeProfitsPerLot7 = 20; //阶段七平仓条件：每手止盈获利金额
input double TakeProfitsFacor7 = 0.6; // 阶段七平仓条件：动态计算止盈金额调整系数
input double Backword7 = 0.1; // 阶段七平仓条件：移动止盈回调系数


input string Stage8 = "-----";  //阶段八:-----    
input double BaseOpenLots8 = 0.01;  //阶段八基础开仓手数
input double Multiple8 = 2.0;//阶段八加仓倍数
input double MulipleFactorForAppend8 = 1.0; //阶段八加仓倍数调整系数
input int AppendMax8 = 3;          // 阶段八最大加仓次数
input double PointOffsetForStage8 = 0.001; //阶段八加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend8 = 0.003; //阶段八加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend8 = 1.0; //阶段八加仓条件：最低价格差变化的调整系数
input double AppendBackword8 = 0.1; // 阶段八加仓条件：加仓回调系数
input double TakeProfitsPerLot8 = 20; //阶段八平仓条件：每手止盈获利金额
input double TakeProfitsFacor8 = 0.6; // 阶段八平仓条件：动态计算止盈金额调整系数
input double Backword8 = 0.1; // 阶段八平仓条件：移动止盈回调系数

input double PointOffsetForProfit = 0.001; //平仓条件：最小价格差变化幅度
input bool CheckFreeMargin = true;// 是否检查预付款比例

input double AdvanceRate = 1000;// 预付款百分比，低于此值将不再加仓
input double SpreadMax = 0.0005;  // 要求最小点差

input bool EnableStopLoss = false; //止损条件：是否启用自动止损
input double StopLossRate = 0.3;// 止损条件：止损比例

input bool EnableAutoCloseAll = false; // 是否启用自动清仓
input double BaseEquity = 1000;       // 基础本金数
input double TotalProfitRate = 0.5;         // 利润率
input double BackwordForClose = 0.05;  // 自动清仓回转比例

input bool EnableAutoCloseAllForStopLoss = false; // 是否启用自动止损清仓
input double TargetLossAmout = 3000;       // 浮亏金额

#else 

input int MagicNum = 6666;
input int TimeFrame = PERIOD_M5;
input int Passcode = 0; 


input bool EnableTradingDate = false;
input datetime OpenOrderStartDate = "";
input datetime OpenOrderEndDate = "";

input bool EnableTradingTime = true;
input string OpenOrderStartTime = "00:00"; 
input string OpenOrderEndTime = "09:30"; 

input bool EnablePriceLimitForShortSideMin = false;
input double PriceLimitForShortSideMin = 0.017;
input bool EnablePriceLimitForLongSideMax = false;
input double PriceLimitForLongSideMax = 0.012;

input bool EnablePriceLimitForShortSideMax = false;
input double PriceLimitForShortSideMax = 0.017;
input bool EnablePriceLimitForLongSideMin = false;
input double PriceLimitForLongSideMin = 0.012;

input bool BaseOpenLotsInLoop = true; 
input bool StopShortSide = false;
input bool StopLongSide = false; 
input int StageMax = 5;

input string Stage1 = "-----"; 
input double BaseOpenLots1 = 0.01;  
input double Multiple1 = 2.0;
input double MulipleFactorForAppend1 = 1.0; 
input int AppendMax1 = 3;          
input double PointOffsetForStage1 = 0.001; 
input double PointOffsetForAppend1 = 0.003;
input double PointOffsetFactorForAppend1 = 1.0; 
input double AppendBackword1 = 0.1; 
input double TakeProfitsPerLot1 = 20; 
input double TakeProfitsFacor1 = 1.2; 
input double Backword1 = 0.1;

input string Stage2 = "-----"; 
input double BaseOpenLots2 = 0.01; 
input double Multiple2 = 2.0;
input double MulipleFactorForAppend2 = 1.0; 
input int AppendMax2 = 3;          
input double PointOffsetForStage2 = 0.001; 
input double PointOffsetForAppend2 = 0.003;
input double PointOffsetFactorForAppend2 = 1.0; 
input double AppendBackword2 = 0.1; 
input double TakeProfitsPerLot2 = 20; 
input double TakeProfitsFacor2 = 0.6;
input double Backword2 = 0.1; 

input string Stage3 = "-----"; 
input double BaseOpenLots3 = 0.01; 
input double Multiple3 = 2.0;
input double MulipleFactorForAppend3 = 1.0;
input int AppendMax3 = 3;         
input double PointOffsetForStage3 = 0.001;
input double PointOffsetForAppend3 = 0.003; 
input double PointOffsetFactorForAppend3 = 1.0; 
input double AppendBackword3 = 0.1; 
input double TakeProfitsPerLot3 = 20; 
input double TakeProfitsFacor3 = 0.6;
input double Backword3 = 0.1; 

input string Stage4 = "-----";     
input double BaseOpenLots4 = 0.01; 
input double Multiple4 = 2.0;
input double MulipleFactorForAppend4 = 1.0;
input int AppendMax4 = 3;          
input double PointOffsetForStage4 = 0.001; 
input double PointOffsetForAppend4 = 0.003; 
input double PointOffsetFactorForAppend4 = 1.0; 
input double AppendBackword4 = 0.1; 
input double TakeProfitsPerLot4 = 20;
input double TakeProfitsFacor4 = 0.6; 
input double Backword4 = 0.1; 

input string Stage5 = "-----";     
input double BaseOpenLots5 = 0.01; 
input double Multiple5 = 2.0;
input double MulipleFactorForAppend5 = 1.0;
input int AppendMax5 = 3;          
input double PointOffsetForStage5 = 0.001; 
input double PointOffsetForAppend5 = 0.003; 
input double PointOffsetFactorForAppend5 = 1.0; 
input double AppendBackword5 = 0.1; 
input double TakeProfitsPerLot5 = 20;
input double TakeProfitsFacor5 = 0.6; 
input double Backword5 = 0.1; 


input string Stage6 = "-----";  
input double BaseOpenLots6 = 0.01;
input double Multiple6 = 2.0;
input double MulipleFactorForAppend6 = 1.0;
input int AppendMax6 = 3;        
input double PointOffsetForStage6 = 0.001;
input double PointOffsetForAppend6 = 0.003;
input double PointOffsetFactorForAppend6 = 1.0;
input double AppendBackword6 = 0.1; 
input double TakeProfitsPerLot6 = 20; 
input double TakeProfitsFacor6 = 0.6; 
input double Backword6 = 0.1; 

input string Stage7 = "-----";
input double BaseOpenLots7 = 0.01;
input double Multiple7 = 2.0;
input double MulipleFactorForAppend7 = 1.0;
input int AppendMax7 = 3;          
input double PointOffsetForStage7 = 0.001;
input double PointOffsetForAppend7 = 0.003;
input double PointOffsetFactorForAppend7 = 1.0;
input double AppendBackword7 = 0.1;
input double TakeProfitsPerLot7 = 20;
input double TakeProfitsFacor7 = 0.6; 
input double Backword7 = 0.1; 


input string Stage8 = "-----";  //阶段八:-----    
input double BaseOpenLots8 = 0.01;  //阶段八基础开仓手数
input double Multiple8 = 2.0;//阶段八加仓倍数
input double MulipleFactorForAppend8 = 1.0; //阶段八加仓倍数调整系数
input int AppendMax8 = 3;          // 阶段八最大加仓次数
input double PointOffsetForStage8 = 0.001; //阶段八加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend8 = 0.003; //阶段八加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend8 = 1.0; //阶段八加仓条件：最低价格差变化的调整系数
input double AppendBackword8 = 0.1; // 阶段八加仓条件：加仓回调系数
input double TakeProfitsPerLot8 = 20; //阶段八平仓条件：每手止盈获利金额
input double TakeProfitsFacor8 = 0.6; // 阶段八平仓条件：动态计算止盈金额调整系数
input double Backword8 = 0.1; // 阶段八平仓条件：移动止盈回调系数

input double PointOffsetForProfit = 0.001;
input bool CheckFreeMargin = true;

input double AdvanceRate = 1000;
input double SpreadMax = 0.0005;

input bool EnableStopLoss = false;
input double StopLossRate = 0.3;

input bool EnableAutoCloseAll = false; 
input double BaseEquity = 1000;
input double TotalProfitRate = 0.5;
input double BackwordForClose = 0.05;

input bool EnableAutoCloseAllForStopLoss = false;
input double TargetLossAmout = 3000;


#endif

int gTickCount = 0;
bool gIsNewBar = false;

bool gbShowText = false;
bool gbShowComment = false;

#endif



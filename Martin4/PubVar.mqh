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

#define EA_VERSION "V3.11"

#ifdef SHOW_COMMENT

input int MagicNum = 6666;
input int TimeFrame = PERIOD_M5; //时间周期
input int Passcode = 0; // 启动口令
input bool BaseOpenLotsInLoop = true; // 中间轮数是否开基础仓
input bool StopShortSide = false;// 是否停止空方开仓
input bool StopLongSide = false; // 是否停止多方开仓
input int StageMax = 5; // 最大加仓阶段数

input string Stage1Long = "-----";  //阶段一(多方）:-----   
input double BaseOpenLots1Long = 0.01;  //阶段一基础开仓手数
input double Multiple1Long = 2.0;//阶段一加仓倍数
input double MulipleFactorForAppend1Long = 1.0; //阶段一加仓倍数调整系数
input int AppendMax1Long = 3;          // 阶段一最大加仓次数
input double PointOffsetForStage1Long = 0.001; //阶段一加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend1Long = 0.003; //阶段一加仓条件：本阶段内最低价格差变化幅度
input double AppendBackword1Long = 0.1; // 阶段一加仓条件：加仓回调系数
input double PointOffsetFactorForAppend1Long = 1.0; //阶段一加仓条件：最低价格差变化的调整系数
input double TakeProfitsPerLot1Long = 20; //阶段一平仓条件：每手止盈获利金额
input double TakeProfitsFacor1Long = 1.2; // 阶段一平仓条件：动态计算止盈金额调整系数
input double Backword1Long = 0.1; // 阶段一平仓条件：移动止盈回调系数

input string Stage1Short = "-----";  //阶段一(空方）:-----   
input double BaseOpenLots1Short = 0.01;  //阶段一基础开仓手数
input double Multiple1Short = 2.0;//阶段一加仓倍数
input double MulipleFactorForAppend1Short = 1.0; //阶段一加仓倍数调整系数
input int AppendMax1Short = 3;          // 阶段一最大加仓次数
input double PointOffsetForStage1Short = 0.001; //阶段一加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend1Short = 0.003; //阶段一加仓条件：本阶段内最低价格差变化幅度
input double AppendBackword1Short = 0.1; // 阶段一加仓条件：加仓回调系数
input double PointOffsetFactorForAppend1Short = 1.0; //阶段一加仓条件：最低价格差变化的调整系数
input double TakeProfitsPerLot1Short = 20; //阶段一平仓条件：每手止盈获利金额
input double TakeProfitsFacor1Short = 1.2; // 阶段一平仓条件：动态计算止盈金额调整系数
input double Backword1Short = 0.1; // 阶段一平仓条件：移动止盈回调系数


input string Stage2Long = "-----";  //阶段二(多方）:-----    
input double BaseOpenLots2Long = 0.01;  //阶段二基础开仓手数
input double Multiple2Long = 2.0;//阶段二加仓倍数
input double MulipleFactorForAppend2Long = 1.0; //阶段二加仓倍数调整系数
input int AppendMax2Long = 3;          // 阶段二最大加仓次数
input double PointOffsetForStage2Long = 0.001; //阶段二加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend2Long = 0.003; //阶段二加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend2Long = 1.0; //阶段二加仓条件：最低价格差变化的调整系数
input double AppendBackword2Long = 0.1; // 阶段二加仓条件：加仓回调系数
input double TakeProfitsPerLot2Long = 20; //阶段二平仓条件：每手止盈获利金额
input double TakeProfitsFacor2Long = 0.6; // 阶段二平仓条件：动态计算止盈金额调整系数
input double Backword2Long = 0.1; // 阶段二平仓条件：移动止盈回调系数

input string Stage2Short = "-----";  //阶段二(空方）:-----    
input double BaseOpenLots2Short = 0.01;  //阶段二基础开仓手数
input double Multiple2Short = 2.0;//阶段二加仓倍数
input double MulipleFactorForAppend2Short = 1.0; //阶段二加仓倍数调整系数
input int AppendMax2Short = 3;          // 阶段二最大加仓次数
input double PointOffsetForStage2Short = 0.001; //阶段二加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend2Short = 0.003; //阶段二加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend2Short = 1.0; //阶段二加仓条件：最低价格差变化的调整系数
input double AppendBackword2Short = 0.1; // 阶段二加仓条件：加仓回调系数
input double TakeProfitsPerLot2Short = 20; //阶段二平仓条件：每手止盈获利金额
input double TakeProfitsFacor2Short = 0.6; // 阶段二平仓条件：动态计算止盈金额调整系数
input double Backword2Short = 0.1; // 阶段二平仓条件：移动止盈回调系数

input string Stage3Long = "-----";  //阶段三(多方）:-----    
input double BaseOpenLots3Long = 0.01;  //阶段三基础开仓手数
input double Multiple3Long = 2.0;//阶段三加仓倍数
input double MulipleFactorForAppend3Long = 1.0; //阶段三加仓倍数调整系数
input int AppendMax3Long = 3;          // 阶段三最大加仓次数
input double PointOffsetForStage3Long = 0.001; //阶段三加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend3Long = 0.003; //阶段三加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend3Long = 1.0; //阶段三加仓条件：最低价格差变化的调整系数
input double AppendBackword3Long = 0.1; // 阶段三加仓条件：加仓回调系数
input double TakeProfitsPerLot3Long = 20; //阶段三平仓条件：每手止盈获利金额
input double TakeProfitsFacor3Long = 0.6; // 阶段三平仓条件：动态计算止盈金额调整系数
input double Backword3Long = 0.1; // 阶段三平仓条件：移动止盈回调系数


input string Stage3Short = "-----";  //阶段三(空方）:-----    
input double BaseOpenLots3Short = 0.01;  //阶段三基础开仓手数
input double Multiple3Short = 2.0;//阶段三加仓倍数
input double MulipleFactorForAppend3Short = 1.0; //阶段三加仓倍数调整系数
input int AppendMax3Short = 3;          // 阶段三最大加仓次数
input double PointOffsetForStage3Short = 0.001; //阶段三加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend3Short = 0.003; //阶段三加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend3Short = 1.0; //阶段三加仓条件：最低价格差变化的调整系数
input double AppendBackword3Short = 0.1; // 阶段三加仓条件：加仓回调系数
input double TakeProfitsPerLot3Short = 20; //阶段三平仓条件：每手止盈获利金额
input double TakeProfitsFacor3Short = 0.6; // 阶段三平仓条件：动态计算止盈金额调整系数
input double Backword3Short = 0.1; // 阶段三平仓条件：移动止盈回调系数

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
input bool BaseOpenLotsInLoop = true; 
input bool StopShortSide = false;
input bool StopLongSide = false; 
input int StageMax = 5;


input string Stage1Long = "-----";  //阶段一(多方）:-----   
input double BaseOpenLots1Long = 0.01;  //阶段一基础开仓手数
input double Multiple1Long = 2.0;//阶段一加仓倍数
input double MulipleFactorForAppend1Long = 1.0; //阶段一加仓倍数调整系数
input int AppendMax1Long = 3;          // 阶段一最大加仓次数
input double PointOffsetForStage1Long = 0.001; //阶段一加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend1Long = 0.003; //阶段一加仓条件：本阶段内最低价格差变化幅度
input double AppendBackword1Long = 0.1; // 阶段一加仓条件：加仓回调系数
input double PointOffsetFactorForAppend1Long = 1.0; //阶段一加仓条件：最低价格差变化的调整系数
input double TakeProfitsPerLot1Long = 20; //阶段一平仓条件：每手止盈获利金额
input double TakeProfitsFacor1Long = 1.2; // 阶段一平仓条件：动态计算止盈金额调整系数
input double Backword1Long = 0.1; // 阶段一平仓条件：移动止盈回调系数

input string Stage1Short = "-----";  //阶段一(空方）:-----   
input double BaseOpenLots1Short = 0.01;  //阶段一基础开仓手数
input double Multiple1Short = 2.0;//阶段一加仓倍数
input double MulipleFactorForAppend1Short = 1.0; //阶段一加仓倍数调整系数
input int AppendMax1Short = 3;          // 阶段一最大加仓次数
input double PointOffsetForStage1Short = 0.001; //阶段一加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend1Short = 0.003; //阶段一加仓条件：本阶段内最低价格差变化幅度
input double AppendBackword1Short = 0.1; // 阶段一加仓条件：加仓回调系数
input double PointOffsetFactorForAppend1Short = 1.0; //阶段一加仓条件：最低价格差变化的调整系数
input double TakeProfitsPerLot1Short = 20; //阶段一平仓条件：每手止盈获利金额
input double TakeProfitsFacor1Short = 1.2; // 阶段一平仓条件：动态计算止盈金额调整系数
input double Backword1Short = 0.1; // 阶段一平仓条件：移动止盈回调系数


input string Stage2Long = "-----";  //阶段二(多方）:-----    
input double BaseOpenLots2Long = 0.01;  //阶段二基础开仓手数
input double Multiple2Long = 2.0;//阶段二加仓倍数
input double MulipleFactorForAppend2Long = 1.0; //阶段二加仓倍数调整系数
input int AppendMax2Long = 3;          // 阶段二最大加仓次数
input double PointOffsetForStage2Long = 0.001; //阶段二加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend2Long = 0.003; //阶段二加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend2Long = 1.0; //阶段二加仓条件：最低价格差变化的调整系数
input double AppendBackword2Long = 0.1; // 阶段二加仓条件：加仓回调系数
input double TakeProfitsPerLot2Long = 20; //阶段二平仓条件：每手止盈获利金额
input double TakeProfitsFacor2Long = 0.6; // 阶段二平仓条件：动态计算止盈金额调整系数
input double Backword2Long = 0.1; // 阶段二平仓条件：移动止盈回调系数

input string Stage2Short = "-----";  //阶段二(空方）:-----    
input double BaseOpenLots2Short = 0.01;  //阶段二基础开仓手数
input double Multiple2Short = 2.0;//阶段二加仓倍数
input double MulipleFactorForAppend2Short = 1.0; //阶段二加仓倍数调整系数
input int AppendMax2Short = 3;          // 阶段二最大加仓次数
input double PointOffsetForStage2Short = 0.001; //阶段二加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend2Short = 0.003; //阶段二加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend2Short = 1.0; //阶段二加仓条件：最低价格差变化的调整系数
input double AppendBackword2Short = 0.1; // 阶段二加仓条件：加仓回调系数
input double TakeProfitsPerLot2Short = 20; //阶段二平仓条件：每手止盈获利金额
input double TakeProfitsFacor2Short = 0.6; // 阶段二平仓条件：动态计算止盈金额调整系数
input double Backword2Short = 0.1; // 阶段二平仓条件：移动止盈回调系数

input string Stage3Long = "-----";  //阶段三(多方）:-----    
input double BaseOpenLots3Long = 0.01;  //阶段三基础开仓手数
input double Multiple3Long = 2.0;//阶段三加仓倍数
input double MulipleFactorForAppend3Long = 1.0; //阶段三加仓倍数调整系数
input int AppendMax3Long = 3;          // 阶段三最大加仓次数
input double PointOffsetForStage3Long = 0.001; //阶段三加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend3Long = 0.003; //阶段三加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend3Long = 1.0; //阶段三加仓条件：最低价格差变化的调整系数
input double AppendBackword3Long = 0.1; // 阶段三加仓条件：加仓回调系数
input double TakeProfitsPerLot3Long = 20; //阶段三平仓条件：每手止盈获利金额
input double TakeProfitsFacor3Long = 0.6; // 阶段三平仓条件：动态计算止盈金额调整系数
input double Backword3Long = 0.1; // 阶段三平仓条件：移动止盈回调系数


input string Stage3Short = "-----";  //阶段三(空方）:-----    
input double BaseOpenLots3Short = 0.01;  //阶段三基础开仓手数
input double Multiple3Short = 2.0;//阶段三加仓倍数
input double MulipleFactorForAppend3Short = 1.0; //阶段三加仓倍数调整系数
input int AppendMax3Short = 3;          // 阶段三最大加仓次数
input double PointOffsetForStage3Short = 0.001; //阶段三加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend3Short = 0.003; //阶段三加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend3Short = 1.0; //阶段三加仓条件：最低价格差变化的调整系数
input double AppendBackword3Short = 0.1; // 阶段三加仓条件：加仓回调系数
input double TakeProfitsPerLot3Short = 20; //阶段三平仓条件：每手止盈获利金额
input double TakeProfitsFacor3Short = 0.6; // 阶段三平仓条件：动态计算止盈金额调整系数
input double Backword3Short = 0.1; // 阶段三平仓条件：移动止盈回调系数

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



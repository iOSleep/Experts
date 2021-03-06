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

#define EA_VERSION "V2.6"

input int MagicNum = 80000;
input int TimeFrame = PERIOD_M5; //时间周期
input bool BaseOpenLotsInLoop = true; // 中间轮数是否开基础仓
input bool StopShortSide = false;// 是否停止空方开仓
input bool StopLongSide = false; // 是否停止多方开仓

input string Stage1 = "-----";  //阶段一:-----   
input double BaseOpenLots1 = 0.01;  //阶段一基础开仓手数
input double Multiple1 = 1.5;//阶段一加仓倍数
input double MulipleFactorForAppend1 = 1.0; //阶段一加仓倍数调整系数
input int AppendMax1 = 5;          // 阶段一最大加仓次数
input double PointOffsetForStage1 = 0.005; //阶段一加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend1 = 0.003; //阶段一加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend1 = 1.0; //阶段一加仓条件：最低价格差变化的调整系数
input double AppendBackword1 = 0.1; // 阶段一加仓条件：加仓回调系数
input double TakeProfitsPerLot1 = 15; //阶段一平仓条件：每手止盈获利金额
input double TakeProfitsFacor1 = 1.0; // 阶段一平仓条件：动态计算止盈金额调整系数
input double Backword1 = 0.05; // 阶段一平仓条件：移动止盈回调系数

input string Stage2 = "-----";  //阶段二:-----    
input double BaseOpenLots2 = 0.02;  //阶段二基础开仓手数
input double Multiple2 = 2.0;//阶段二加仓倍数
input double MulipleFactorForAppend2 = 1.0; //阶段二加仓倍数调整系数
input int AppendMax2 = 5;          // 阶段二最大加仓次数
input double PointOffsetForStage2 = 0.005; //阶段二加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend2 = 0.003; //阶段二加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend2 = 1.0; //阶段二加仓条件：最低价格差变化的调整系数
input double AppendBackword2 = 0.1; // 阶段二加仓条件：加仓回调系数
input double TakeProfitsPerLot2 = 15; //阶段二平仓条件：每手止盈获利金额
input double TakeProfitsFacor2 = 1.0; // 阶段二平仓条件：动态计算止盈金额调整系数
input double Backword2 = 0.05; // 阶段二平仓条件：移动止盈回调系数

input string Stage3 = "-----";  //阶段三:-----    
input double BaseOpenLots3 = 0.03;  //阶段三基础开仓手数
input double Multiple3 = 2.5;//阶段三加仓倍数
input double MulipleFactorForAppend3 = 1.0; //阶段三加仓倍数调整系数
input int AppendMax3 = 5;          // 阶段三最大加仓次数
input double PointOffsetForStage3 = 0.005; //阶段三加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend3 = 0.003; //阶段三加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend3 = 1.0; //阶段三加仓条件：最低价格差变化的调整系数
input double AppendBackword3 = 0.1; // 阶段三加仓条件：加仓回调系数
input double TakeProfitsPerLot3 = 15; //阶段三平仓条件：每手止盈获利金额
input double TakeProfitsFacor3 = 1.0; // 阶段三平仓条件：动态计算止盈金额调整系数
input double Backword3 = 0.05; // 阶段三平仓条件：移动止盈回调系数

input string Stage4 = "-----";  //阶段四:-----    
input double BaseOpenLots4 = 0.03;  //阶段四基础开仓手数
input double Multiple4 = 2.5;//阶段四加仓倍数
input double MulipleFactorForAppend4 = 1.0; //阶段四加仓倍数调整系数
input int AppendMax4 = 5;          // 阶段四最大加仓次数
input double PointOffsetForStage4 = 0.005; //阶段四加仓条件：与下阶段相比最低价格差变化幅度
input double PointOffsetForAppend4 = 0.003; //阶段四加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend4 = 1.0; //阶段四加仓条件：最低价格差变化的调整系数
input double AppendBackword4 = 0.1; // 阶段四加仓条件：加仓回调系数
input double TakeProfitsPerLot4 = 15; //阶段四平仓条件：每手止盈获利金额
input double TakeProfitsFacor4 = 1.0; // 阶段四平仓条件：动态计算止盈金额调整系数
input double Backword4 = 0.05; // 阶段四平仓条件：移动止盈回调系数

input double PointOffsetForProfit = 0.001; //平仓条件：最小价格差变化幅度
input bool CheckFreeMargin = true;// 是否检查预付款比例

input double AdvanceRate = 1000;// 预付款百分比，低于此值将不再加仓
input double SpreadMax = 0.0005;

int gTickCount = 0;
bool gIsNewBar = false;
#endif



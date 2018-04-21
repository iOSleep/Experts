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

#define EA_VERSION "V0.1"

input int TimeFrame = PERIOD_M15; //时间周期
input string SYMBOL1 = "EURUSD"  ;   //货币对1(字符完全对应)
input string SYMBOL2 = "GBPUSD"  ;   //货币对2(字符完全对应)
input double MaxHoldingLots = 5.0; //最多持仓手数
input double BaseOpenLots = 0.1;  //基础开仓手数
input double Overweight_Multiple = 2;//加仓倍数
input int OrderMax = 5;          // 最大加仓次数
input double PointOffsetForAppend = 0.005; //加仓条件：最低价格差变化幅度
input double FactorForAppend = 1.1; //加仓条件：最低价格差变化的调整系数
input double DeficitForAppend = 100; //加仓条件：最低亏损金额
input double PointOffsetForProfit = 0.002; //平仓条件：最小价格差变化幅度
input double TakeProfits = 100; //平仓条件：基础固定止盈获利金额
input double Backword = 0.1; // 平仓条件：移动止盈回调系数

int gTickCount = 0;
#endif



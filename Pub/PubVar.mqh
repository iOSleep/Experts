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
input string PRD1 = "EURUSD"  ;   //货币对1(字符完全对应)
input string PRD2 = "GBPUSD"  ;   //货币对2(字符完全对应)
input double MaxHoldingLots = 5.0; //最多持仓手数
input double BaseOpenLots = 0.1;  //基础开单手数
input double Overweight_Multiple = 2;//追加单倍数
input int AppendOrderInterval = 3;// 追加订单最小间隔周期
input bool CheckFreeMargin = false;
input int OrderMax = 5;          // 最大持有订单数量
input string BuyComment = "HedgingBuy"; // 买单注释
input string SellComment = "HedgingSell"; // 卖单注释
input bool DynamicCalcTotalProfits = true; // 是否动态计算总获利止盈标准
input double CalcFactor = 90; // 动态计算总获利止盈系数
input int Retracement = 20; // 获利后回调比例
input int TotalProfits = 100; // 总获利止盈标准
// input int TrailingProfits = 20; // 移动止盈标准



bool gIsNewBar = false;
double gPreTotalProfits = 0;
double gMostProfits = 0;
int gTickCount = 0;
string OpName [] = 
{
   "买单",
   "卖单"
};



#endif



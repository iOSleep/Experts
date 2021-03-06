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

input int MAGIC_NUM = 9000;
input int TimeFrame = PERIOD_M5; //时间周期
input double BASE_OPEN_LOTS = 0.1; // 基础开仓手数
input double HEAVY_PROFITS_SETP = 0.001; // 重仓盈利条件：最小价格波动值
input double HEAVY_TO_LIGHT_MIN_OFFSET = 0.006; // 重仓轻：重仓可以转轻仓的与对侧订单的最小价格差
input double HEAVY_TO_LIGHT_ROLLBACK = 0.0005; // 重转轻：价格反转条件：最小价格波动值
input double BACKWORD_PROFITS = 0.05; //  重转轻：获利回调系数

input double LIGHT_TO_HEAVY_ROLLBACK = 0.0005; // 轻转重：价格反转条件：最小价格波动值
input double LIGHT_STOPLOSS_STEP = 0.0005; //  轻转轻：止损条件：最小价格波动值
input double BACKWORD_STOPLOSS = 0.05; //  轻转重：条件：止损回调系数
input double PRICE_ROLLBACK_RATE = 0.6; //平所有仓条件，价格回归比例

input double MULTIPLE_FOR_LOOP = 1.0; //轮动的加仓倍数

int gTickCount = 0;
bool gIsNewBar = false;
#endif



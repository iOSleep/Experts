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

#define EA_VERSION "V1.19"

#ifdef SHOW_COMMENT

input int MagicNum = 1000; // 订单魔法值
input int TimeFrame = PERIOD_M5; //时间周期
input int Passcode = 0; // 启动口令

input bool EA1_Enable = true; // 是否启用1号程序

input bool EnableTradingDate = false; //是否启用开仓起止日期
input datetime OpenOrderStartDate = ""; //开仓起始时间，为格林威治时间
input datetime OpenOrderEndDate = ""; //开仓截止时间，为格林威治时间

input bool EnableTradingTime = false; //是否启用开仓起止时段
input string OpenOrderStartTime = "00:00"; //开仓起始时间，为格林威治时间，格式"hh:mm", 如："00:01"
input string OpenOrderEndTime = "09:30"; //开仓截止时间，为格林威治时间，格式"hh:mm", 如："09:30"

input bool EnableLongShortRateForAppend = false; //是否启用加仓时判断多空比例
input double EnableLongShortRateLotsForAppend = 0.1; // 启用加仓时判断用多空比例的起始手数（单方向）

input bool EnableLongShortRateForClose = false; //是否启用平仓时判断用多空比例
input double EnableLongShortRateLotsForClose = 0.1; // 启用平仓时判断用多空比例的起始手数（单方向）


input double MinOpenLots = 0.01;    //最小手数
input double BaseOpenLots = 0.01;   //基础开仓手数
input double AppendStep = 0.001;    //加仓间距
input double RevertAppendStep = 0.002;    //反向单加仓间距

input double PointOffsetForMovableTakeProfitLots = 0.02;  // 单笔订单移动止盈最小价格差加倍起始手数

input double PointOffsetForStopLossForLong = 0; //多单止损点数
input double PointOffsetForTakeProfitForLong = 0; //多单止盈点数
input double PointOffsetForMovableTakeProfitForLong = 0.003; //多单移动止盈最小价格差
input double PointOffsetForMovableTakeProfitForLongFactor = 2.0; //多单移动止盈调整倍数
input double BackwardForLong = 0.1;           //多单移动止盈回调比例

input double PointOffsetForStopLossForShort = 0; //空单止损点数
input double PointOffsetForTakeProfitForShort = 0; //空单止盈点数
input double PointOffsetForMovableTakeProfitForShort = 0.003; //空单移动止盈最小价格差
input double PointOffsetForMovableTakeProfitForShortFactor = 2.0; //空单移动止盈调整倍数
input double BackwardForShort = 0.1;           //空单移动止盈回调比例

/*
input bool EnableLongShortWholeClose = false; // 是否启用多空双方整体平仓
input double BuyLotsForWholeClose = 1.0;  // 整体平仓多方最低手数
input double SellLotsForWholeClose = 1.0;  // 整体平仓空方最低手数
input double ProfitsWholeClose = 0.0; // 多空双方整体平仓盈利金额
input double EnableMovableForWholeClose = false; // 是否启用整体平仓移动止盈
input double BackwardForWholeClose = 0.1; //多空整体移动止盈回调比例
*/

input bool EnableLongShortUnbalance = false; // 是否启用多空失衡暂停平仓
input double UnbalanceRate = 0.2;  // 多空失衡比例
input double LotsForUnbalance = 1.0;  // 多空失衡比例最低手数

input double SpreadMax = 0.0005; // 要求最大点差  

input bool EnableAutoCloseAll = false; // 是否启用盈利自动平所有仓
input double BaseEquity = 1000;  // 基础净值（本金）
input double TotalProfitRate = 0.5; // 总盈利比率
input double BackwardForClose = 0.05; //总净值回撤比率
input bool EnableAutoCloseOtherOrder = false;  // 是否启用平掉其他订单仓位

input bool EnableAutoCloseAllForStopLoss = false; // 是否启用自动止损清仓
input double AutoCloseAllForStopLossRate = 0.3;       // 自动止损比例
input bool ContinueOpenAfterCloseAllForStopLoss = true; // 自动整体止损后，是否继续开仓

input double MaxHandlingLots = 1.0; //单方向持仓最大手数

#else 

input int MagicNum = 1000;
input int TimeFrame = PERIOD_M5;
input int Passcode = 0; 

input bool EA1_Enable = true;

input bool EnableTradingDate = false; 
input datetime OpenOrderStartDate = "";
input datetime OpenOrderEndDate = "";

input bool EnableTradingTime = false;
input string OpenOrderStartTime = "00:00";
input string OpenOrderEndTime = "09:30";

input bool EnableLongShortRateForAppend = false;
input double EnableLongShortRateLotsForAppend = 0.1; 

input bool EnableLongShortRateForClose = false;
input double EnableLongShortRateLotsForClose = 0.1; 

input double MinOpenLots = 0.01;
input double BaseOpenLots = 0.01; 
input double AppendStep = 0.001;
input double RevertAppendStep = 0.002;

input double PointOffsetForMovableTakeProfitLots = 0.02;

input double PointOffsetForStopLossForLong = 0; 
input double PointOffsetForTakeProfitForLong = 0; 
input double PointOffsetForMovableTakeProfitForLong = 0.003; 
input double PointOffsetForMovableTakeProfitForLongFactor = 1.0; 
input double BackwardForLong = 0.1;          


input double PointOffsetForStopLossForShort = 0; 
input double PointOffsetForTakeProfitForShort = 0; 
input double PointOffsetForMovableTakeProfitForShort = 0.003;
input double PointOffsetForMovableTakeProfitForShortFactor = 1.0;
input double BackwardForShort = 0.1;

/*
input bool EnableLongShortWholeClose = false; 
input double BuyLotsForWholeClose = 1.0; 
input double SellLotsForWholeClose = 1.0;
input double ProfitsWholeClose = 0.0; 
input double EnableMovableForWholeClose = false;
input double BackwardForWholeClose = 0.1;
*/

input bool EnableLongShortUnbalance = false;
input double UnbalanceRate = 0.2;
input double LotsForUnbalance = 1.0;

input double SpreadMax = 0.0005;

input bool EnableAutoCloseAll = false; 
input double BaseEquity = 1000; 
input double TotalProfitRate = 0.5;
input double BackwardForClose = 0.05;
input bool EnableAutoCloseOtherOrder = false;

input double MaxHandlingLots = 1.0; 

input bool EnableAutoCloseAllForStopLoss = false;
input double AutoCloseAllForStopLossRate = 0.3;  
input bool ContinueOpenAfterCloseAllForStopLoss = true; 

#endif

bool gIsNewBar = false;
bool gbShowText = false;
bool gbShowComment = false;

#endif



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

#define EA_VERSION "V2.17"

#ifdef SHOW_COMMENT

input int MagicNum = 2000;
input int TimeFrame = PERIOD_M5; //时间周期
input int Passcode = 0; // 启动口令

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

input bool EnableCheckOppositeOrderCount = false; //是否启用开仓时判断对侧订单数量
input int OppositeOrderCount = 6; // 对侧马丁单订单数量, 等于或多于此数量时，不再开仓



input double MinOpenLots = 0.01;    //最小手数
input double OffsetForBuySellStop = 0.001;     //开挂单价格差
input double BaseOpenLots = 0.01;   //基础开仓手数
input double AppendStep = 0.001;    //盈利加仓间距

input double BackwordForAppendLongMartin = 0.1;           //多单加马丁仓回撤比例
input double RevertAppendStepForLong1 = 0.003;    //多方回撤加仓间距1
input double RevertAppendLotsForLong1 = 0.02;    //多方回撤加仓手数1
input double RevertAppendStepForLong2 = 0.003;    //多方回撤加仓间距2
input double RevertAppendLotsForLong2 = 0.02;    //多方回撤加仓手数2
input double RevertAppendStepForLong3 = 0.003;    //多方回撤加仓间距3
input double RevertAppendLotsForLong3 = 0.02;    //多方回撤加仓手数3
input double RevertAppendStepForLong4 = 0.003;    //多方回撤加仓间距4
input double RevertAppendLotsForLong4 = 0.02;    //多方回撤加仓手数4
input double RevertAppendStepForLong5 = 0.003;    //多方回撤加仓间距5
input double RevertAppendLotsForLong5 = 0.02;    //多方回撤加仓手数5
input double RevertAppendStepForLong6 = 0.003;    //多方回撤加仓间距6
input double RevertAppendLotsForLong6 = 0.02;    //多方回撤加仓手数6
input double RevertAppendStepForLong7 = 0.003;    //多方回撤加仓间距7
input double RevertAppendLotsForLong7 = 0.02;    //多方回撤加仓手数7
input double RevertAppendStepForLong8 = 0.003;    //多方回撤加仓间距8
input double RevertAppendLotsForLong8 = 0.02;    //多方回撤加仓手数8
input double RevertAppendStepForLong9 = 0.003;    //多方回撤加仓间距9
input double RevertAppendLotsForLong9 = 0.02;    //多方回撤加仓手数9
input double RevertAppendStepForLong10 = 0.003;    //多方回撤加仓间距10
input double RevertAppendLotsForLong10 = 0.02;    //多方回撤加仓手数10

input double BackwordForAppendShortMartin = 0.1;    //空方加马丁仓回撤比例
input double RevertAppendStepForShort1 = 0.003;    //空方回撤加仓间距1
input double RevertAppendLotsForShort1 = 0.02;    //空方回撤加仓手数1
input double RevertAppendStepForShort2 = 0.003;    //空方回撤加仓间距2
input double RevertAppendLotsForShort2 = 0.02;    //空方回撤加仓手数2
input double RevertAppendStepForShort3 = 0.003;    //空方回撤加仓间距3
input double RevertAppendLotsForShort3 = 0.02;    //空方回撤加仓手数3
input double RevertAppendStepForShort4 = 0.003;    //空方回撤加仓间距4
input double RevertAppendLotsForShort4 = 0.02;    //空方回撤加仓手数4
input double RevertAppendStepForShort5 = 0.003;    //空方回撤加仓间距5
input double RevertAppendLotsForShort5 = 0.02;    //空方回撤加仓手数5
input double RevertAppendStepForShort6 = 0.003;    //空方回撤加仓间距6
input double RevertAppendLotsForShort6 = 0.02;    //空方回撤加仓手数6
input double RevertAppendStepForShort7 = 0.003;    //空方回撤加仓间距7
input double RevertAppendLotsForShort7 = 0.02;    //空方回撤加仓手数7
input double RevertAppendStepForShort8 = 0.003;    //空方回撤加仓间距8
input double RevertAppendLotsForShort8 = 0.02;    //空方回撤加仓手数8
input double RevertAppendStepForShort9 = 0.003;    //空方回撤加仓间距9
input double RevertAppendLotsForShort9 = 0.02;    //空方回撤加仓手数9
input double RevertAppendStepForShort10 = 0.003;    //空方回撤加仓间距10
input double RevertAppendLotsForShort10 = 0.02;    //空方回撤加仓手数10

input double PointOffsetForStopLossForLong = 0; //多单止损点数
input double PointOffsetForTakeProfitForLong = 0; //多单止盈点数
input double PointOffsetForMovableTakeProfitForLong = 0.003; //多单移动止盈最小价格差
input double BackwordForLong = 0.1;           //多单移动止盈回调比例

input double PointOffsetForStopLossForShort = 0; //空单止损点数
input double PointOffsetForTakeProfitForShort = 0; //空单止盈点数
input double PointOffsetForMovableTakeProfitForShort = 0.003; //空单移动止盈最小价格差
input double BackwordForShort = 0.1;           //空单移动止盈回调比例

input double PointOffsetForStopLossForLongMartin = 0; //马丁多单止损点数
input double PointOffsetForTakeProfitForLongMartin = 0; //马丁多单止盈点数
input double TakeProfitsFacorForLongMartin = 0.6; //马丁多单移动止盈调整系数
input double BackwordForLongMartin = 0.1;    //马丁多单移动止盈回调比例

input int    EnableStage2CountForLongMartin2 = 3;    // 马丁多单启动二阶段平仓规则的订单数
input double TakeProfitsFacorForLongMartin2 = 0.6; //马丁多单移动止盈调整系数（二阶段）
input double BackwordForLongMartin2 = 0.1;    //马丁多单移动止盈回调比例（二阶段）
input int CheckLastNForLong = 2;  //马丁多单平仓时顺带平掉最近几笔顺势单（二阶段）  

input int    EnableStage3CountForLongMartin3 = 6;    // 马丁多单启动三阶段平仓规则的订单数
input double TakeProfitsForLongMartin3 = 20; //马丁多单每手止盈金额（三阶段）

input double PointOffsetForStopLossForShortMartin = 0; //马丁空单止损点数
input double PointOffsetForTakeProfitForShortMartin = 0; //马丁空单止盈点数
input double TakeProfitsFacorForShortMartin = 0.6; //马丁空单移动止盈调整系数
input double BackwordForShortMartin = 0.1;   //马丁空单移动止盈回调比例

input int    EnableStage2CountForShortMartin2 = 3;    // 马丁空单启动二阶段平仓规则的订单数
input double TakeProfitsFacorForShortMartin2 = 0.6; //马丁空单移动止盈调整系数（二阶段）
input double BackwordForShortMartin2 = 0.1;   //马丁空单移动止盈回调比例（二阶段）
input int CheckLastNForShort = 2;  //马丁空单平仓时顺带平掉最近几笔顺势单（二阶段）  

input int    EnableStage3CountForShortMartin3 = 6;    // 马丁空单启动三阶段平仓规则的订单数
input double TakeProfitsForShortMartin3 = 20; //马丁空单每手止盈金额（三阶段）


input bool EnableLongShortWholeClose = false; // 是否启用多空双方整体平仓
input double BuyLotsForWholeClose = 1.0;  // 整体平仓多方最低手数
input double SellLotsForWholeClose = 1.0;  // 整体平仓空方最低手数
input double ProfitsWholeClose = 0.0; // 多空双方整体平仓盈利金额
input bool EnableMovableForWholeClose = false; // 是否启用整体平仓移动止盈
input double BackwardForWholeClose = 0.1; //多空整体移动止盈回调比例

input double SpreadMax = 0.0005; // 要求最大点差  

input bool EnableAutoCloseAll = true; // 是否启用自动平所有仓
input double BaseEquity = 1000;  // 基础净值（本金）
input double TotalProfitRate = 0.1; // 总盈利比率
input double BackwordForClose = 0.005; //总净值回撤比率

input double MaxHandlingLots = 1.0; //单方向持仓最大手数

input bool EnableAutoCloseAllForStopLoss = false; // 是否启用自动止损清仓
input double AutoCloseAllForStopLossRate = 0.3;       // 自动止损比例
input bool ContinueOpenAfterCloseAllForStopLoss = true; // 自动整体止损后，是否继续开仓

#else 

input int MagicNum = 1000;
input int TimeFrame = PERIOD_M5;
input int Passcode = 0; 

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
input double OffsetForBuySellStop = 0.003;
input double BaseOpenLots = 0.01; 
input double AppendStep = 0.001;
input double RevertAppendStep = 0.003;

input bool EnableCheckOppositeOrderCount = false;
input int OppositeOrderCount = 6;

input double BackwordForAppendLongMartin = 0.1;  
input double RevertAppendStepForLong1 = 0.003;   
input double RevertAppendLotsForLong1 = 0.02;   
input double RevertAppendStepForLong2 = 0.003;  
input double RevertAppendLotsForLong2 = 0.02;   
input double RevertAppendStepForLong3 = 0.003;  
input double RevertAppendLotsForLong3 = 0.02;   
input double RevertAppendStepForLong4 = 0.003;   
input double RevertAppendLotsForLong4 = 0.02;   
input double RevertAppendStepForLong5 = 0.003;   
input double RevertAppendLotsForLong5 = 0.02;  
input double RevertAppendStepForLong6 = 0.003;  
input double RevertAppendLotsForLong6 = 0.02;    
input double RevertAppendStepForLong7 = 0.003;  
input double RevertAppendLotsForLong7 = 0.02;    
input double RevertAppendStepForLong8 = 0.003;  
input double RevertAppendLotsForLong8 = 0.02;    
input double RevertAppendStepForLong9 = 0.003;  
input double RevertAppendLotsForLong9 = 0.02;    
input double RevertAppendStepForLong10 = 0.003;  
input double RevertAppendLotsForLong10 = 0.02;  

input double BackwordForAppendShortMartin = 0.1;  
input double RevertAppendStepForShort1 = 0.003; 
input double RevertAppendLotsForShort1 = 0.02;   
input double RevertAppendStepForShort2 = 0.003; 
input double RevertAppendLotsForShort2 = 0.02;   
input double RevertAppendStepForShort3 = 0.003;  
input double RevertAppendLotsForShort3 = 0.02;  
input double RevertAppendStepForShort4 = 0.003;  
input double RevertAppendLotsForShort4 = 0.02; 
input double RevertAppendStepForShort5 = 0.003;   
input double RevertAppendLotsForShort5 = 0.02;   
input double RevertAppendStepForShort6 = 0.003;  
input double RevertAppendLotsForShort6 = 0.02;   
input double RevertAppendStepForShort7 = 0.003;  
input double RevertAppendLotsForShort7 = 0.02;   
input double RevertAppendStepForShort8 = 0.003;  
input double RevertAppendLotsForShort8 = 0.02;    
input double RevertAppendStepForShort9 = 0.003;  
input double RevertAppendLotsForShort9 = 0.02;    
input double RevertAppendStepForShort10 = 0.003;  
input double RevertAppendLotsForShort10 = 0.02;  

input double PointOffsetForStopLossForLong = 0;
input double PointOffsetForTakeProfitForLong = 0;
input double PointOffsetForMovableTakeProfitForLong = 0.003;
input double BackwordForLong = 0.1;           

input double PointOffsetForStopLossForShort = 0;
input double PointOffsetForTakeProfitForShort = 0;
input double PointOffsetForMovableTakeProfitForShort = 0.003;
input double BackwordForShort = 0.1; 

input double PointOffsetForStopLossForLongMartin = 0;
input double PointOffsetForTakeProfitForLongMartin = 0;
input double TakeProfitsFacorForLongMartin = 0.6;
input double BackwordForLongMartin = 0.1;
input int CheckLastNForLong = 2; 

input int    EnableStage3CountForLongMartin3 = 6;
input double TakeProfitsForLongMartin3 = 20;

input int    EnableStage2CountForLongMartin2 = 3; 
input double TakeProfitsFacorForLongMartin2 = 0.6;
input double BackwordForLongMartin2 = 0.1;                      

input double PointOffsetForStopLossForShortMartin = 0;
input double PointOffsetForTakeProfitForShortMartin = 0;
input double TakeProfitsFacorForShortMartin = 0.6;
input double BackwordForShortMartin = 0.1; 
 
input int    EnableStage2CountForShortMartin2 = 3; 
input double TakeProfitsFacorForShortMartin2 = 0.6;
input double BackwordForShortMartin2 = 0.1; 
input int CheckLastNForShort = 2;

input int    EnableStage3CountForShortMartin3 = 6;
input double TakeProfitsForShortMartin3 = 20;


input bool EnableLongShortWholeClose = false;
input double BuyLotsForWholeClose = 1.0;
input double SellLotsForWholeClose = 1.0;
input double ProfitsWholeClose = 0.0;
input bool EnableMovableForWholeClose = false;
input double BackwardForWholeClose = 0.1;      

input double SpreadMax = 0.0005;

input bool EnableAutoCloseAll = true; 
input double BaseEquity = 1000; 
input double TotalProfitRate = 0.1;
input double BackwordForClose = 0.005;

input double MaxHandlingLots = 1.0; 

input bool EnableAutoCloseAllForStopLoss = false;
input double AutoCloseAllForStopLossRate = 0.3;
input bool ContinueOpenAfterCloseAllForStopLoss = true;

#endif

bool gIsNewBar = false;
bool gbShowText = false;
bool gbShowComment = false;

#endif



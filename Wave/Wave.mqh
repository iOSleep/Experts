//+------------------------------------------------------------------+
//|                                                    OneDirect.mqh |
//|                                                          Cuilong |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "http://www.mql4.com"
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
#include "PubVar.mqh"
#include "PubVar2.mqh"
#include "ClUtil.mqh"
#include "WaveOrder.mqh"
#include "Wave2Order.mqh"

bool PassOK = false;

bool gDisableOpen = false;

double mostEquity = 0;
double preEquity = 0;
double gBaseEquity = BaseEquity;

int gBuyStopCount = 0;
int gSellStopCount = 0;

double gStopCloseByUnbalance = false; // 因多空比例失衡导致暂停平仓

CWaveOrder * pWave = NULL;
CWave2Order * pWave2 = NULL;

int gBuyMartinCloseCount = 0;
int gSellMartinCloseCount = 0;

bool IsDataAndTimeAllowed() {
   if(EnableTradingDate && !IsBetweenDate(OpenOrderStartDate, OpenOrderEndDate)) {
      return false;
   }
   
   if(EnableTradingTime && !IsBetweenTime(OpenOrderStartTime, OpenOrderEndTime)) {
      return false;
   }
   return true; 
}

void Main() {
   if(EA1_Enable) {
      EA1_Main();
   }
   
   if(EA2_Enable) {
      EA2_Main();
   }
   
   double currentEquity = AccountEquity(); // 净值
   if(currentEquity > mostEquity) {
      mostEquity = currentEquity;
   }
   
   // 整体移动止盈
   double baseTargetEquity = gBaseEquity * (1 + TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - BackwardForClose));
   if(EnableAutoCloseAll) {
       bool bClose = false;
       
       if((pWave && pWave.CheckForAutoCloseAll(gBaseEquity, preEquity, mostEquity, realTargetEquity))
         || (pWave2 && pWave2.CheckForAutoCloseAll(gBaseEquity, preEquity, mostEquity, realTargetEquity)) ) {
         
         if(pWave) {
            pWave.CloseAllBuyOrders();
            pWave.CloseAllSellOrders();
            pWave.CleanAllOrders();
         }
         
         if(pWave2) {
            pWave2.CloseAllOrders();
            pWave2.CleanAllOrders();
         }
         gBaseEquity =  AccountEquity();
       }
   }  
    
   
   // 整体移动止损
   double targetStopLossEquity = gBaseEquity * (1 - AutoCloseAllForStopLossRate);
   if(EnableAutoCloseAllForStopLoss) {
      // 启用了整体止损
       if((pWave && pWave.CheckForAutoStopLossAll(targetStopLossEquity))
         || (pWave2 && pWave2.CheckForAutoStopLossAll(targetStopLossEquity))) {
         if(pWave) {
            pWave.CloseAllBuyOrders();
            pWave.CloseAllSellOrders();
            pWave.CleanAllOrders();
         }
         
         if(pWave2) {
            pWave2.CloseAllOrders();
            pWave2.CleanAllOrders();
         }
         
         gBaseEquity =  AccountEquity();
         
         if(!ContinueOpenAfterCloseAllForStopLoss) {
            gDisableOpen = true;
         }
      }
   }
   
   preEquity = currentEquity;
}

void EA1_Main()
{
   string logMsg;
   string symbol = Symbol();
   if(!pWave) {
      pWave = new CWaveOrder(symbol, MagicNum);
      pWave.LoadAllOrders();
   }
   
   pWave.HeartBeat();
   
   if(pWave.GetBuyOrderCnt() == 0 && IsDataAndTimeAllowed()) {
      OptParam param;
      param.m_BaseOpenLots = MinOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLossForLong;
      param.m_TakeProfitPoint = PointOffsetForTakeProfitForLong;
      pWave.OpenBuyOrders(param);
      return;
   }
   
   if(pWave.GetSellOrderCnt() == 0 && IsDataAndTimeAllowed()) {
      OptParam param;
      param.m_BaseOpenLots = MinOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLossForShort;
      param.m_TakeProfitPoint = PointOffsetForTakeProfitForShort;
      pWave.OpenSellOrders(param);
      return;
   }
   
   bool bAppendOrderInHole = true;;
   if(gStopCloseByUnbalance) {
      bAppendOrderInHole = false;
   }
   
   if(IsDataAndTimeAllowed() 
      && pWave.CheckForAppendBuyOrder(AppendStep, RevertAppendStep, SpreadMax,
                                       EnableLongShortRateForAppend, EnableLongShortRateLotsForAppend, MaxHandlingLots,
                                       bAppendOrderInHole)) {
      OptParam param;
      param.m_BaseOpenLots = BaseOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLossForLong;
      param.m_TakeProfitPoint = PointOffsetForTakeProfitForLong;
      pWave.OpenBuyOrders(param);
   }
   
   if(IsDataAndTimeAllowed() 
      && pWave.CheckForAppendSellOrder(AppendStep, RevertAppendStep, SpreadMax,
                                       EnableLongShortRateForAppend, EnableLongShortRateLotsForAppend, MaxHandlingLots,
                                       bAppendOrderInHole)) {
      OptParam param;
      param.m_BaseOpenLots = BaseOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLossForShort;
      param.m_TakeProfitPoint = PointOffsetForTakeProfitForShort;
      pWave.OpenSellOrders(param);
   }
   
   /*
   if(EnableLongShortWholeClose 
      && pWave.GetBuyLots() >= BuyLotsForWholeClose
      && pWave.GetSellLots() >= SellLotsForWholeClose) {
      
      if(pWave.CheckForWholeCloseOrders(ProfitsWholeClose, EnableMovableForWholeClose, BackwardForWholeClose)) {
         pWave.CloseAllSellOrders();
         pWave.CloseAllBuyOrders();
      }
      
   } else {
      pWave.CheckForCloseBuyOrders(PointOffsetForMovableTakeProfitForLong, BackwardForLong,
                                 EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
      pWave.CheckForCloseSellOrders(PointOffsetForMovableTakeProfitForShort, BackwardForShort,
                                EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
   }
   */
   
   if(!gStopCloseByUnbalance) {
      double dBuyLots = pWave.GetBuyLots();
      double dSellLots = pWave.GetSellLots();
      if(EnableLongShortUnbalance && dBuyLots > 0 && dSellLots > 0) {
         if(dBuyLots >= LotsForUnbalance || dSellLots >= LotsForUnbalance) {
            if(dBuyLots / dSellLots <= UnbalanceRate || dSellLots / dBuyLots <= UnbalanceRate) {
               logMsg = StringFormat("StopClose enabled: dBuyLots=%s, dSellLots=%s",
                                  DoubleToString(dBuyLots, 2), 
                                  DoubleToString(dSellLots, 2));
               LogInfo(logMsg); 
               gStopCloseByUnbalance = true;
            }
         }
      }
   }
   
   if(!gStopCloseByUnbalance) {
      double dBuyLots = pWave.GetBuyLots();
      double dSellLots = pWave.GetSellLots();
      
      double dPointOffsetForMovableTakeProfitForLong = PointOffsetForMovableTakeProfitForLong; 
      if(dBuyLots >= PointOffsetForMovableTakeProfitLots 
         || dSellLots >= PointOffsetForMovableTakeProfitLots) {
         dPointOffsetForMovableTakeProfitForLong = PointOffsetForMovableTakeProfitForLong * PointOffsetForMovableTakeProfitForLongFactor;
      }
      pWave.CheckForCloseBuyOrders(dPointOffsetForMovableTakeProfitForLong, BackwardForLong,
                                    EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
                                    
      double dPointOffsetForMovableTakeProfitForShort = PointOffsetForMovableTakeProfitForShort;
     if(dBuyLots >= PointOffsetForMovableTakeProfitLots 
         || dSellLots >= PointOffsetForMovableTakeProfitLots) {
         dPointOffsetForMovableTakeProfitForShort = PointOffsetForMovableTakeProfitForShort * PointOffsetForMovableTakeProfitForShortFactor;
      }
      pWave.CheckForCloseSellOrders(dPointOffsetForMovableTakeProfitForShort, BackwardForShort,
                                   EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
   }   

   /*                                 
   double currentEquity = AccountEquity(); // 净值
   if(currentEquity > mostEquity) {
      mostEquity = currentEquity;
   }
   
   double baseTargetEquity = gBaseEquity * (1 + TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - BackwardForClose));
   logMsg = StringFormat("gBaseEquity=%s,baseTargetEquity=%s, mostEquity=%s, realTargetEquity=%s",
                                  DoubleToString(gBaseEquity, 2), 
                                  DoubleToString(baseTargetEquity, 2),
                                  DoubleToString(mostEquity, 2),
                                  DoubleToString(realTargetEquity, 2));
   // LogInfo(logMsg); 
   if(EnableAutoCloseAll) {
       if(pWave.CheckForAutoCloseAll(gBaseEquity, preEquity, mostEquity, realTargetEquity)) {
         pWave.CloseAllSellOrders();
         pWave.CloseAllBuyOrders();
         pWave.CleanAllOrders();
         
         if(EnableAutoCloseOtherOrder && pWave2 != NULL) {
            pWave2.CloseAllOrders();
            pWave2.CleanAllOrders();
         }
          
         gBaseEquity =  AccountEquity();
         gStopCloseByUnbalance = false;
           
       }
   } 
   preEquity = currentEquity;  
   */
}

void EA2_Main()
{
   string logMsg = "";
   string symbol = Symbol();
   if(!pWave2) {
      pWave2 = new CWave2Order(symbol, EA2_MagicNum); 
      pWave2.LoadAllOrders();
   }
      
   pWave2.HeartBeat();
   
   pWave2.LoadBuyStopOrders();
   pWave2.LoadSellStopOrders();
   
   int nBuyStopCount = pWave2.GetBuyStopOrderCnt();
   if(nBuyStopCount != gBuyStopCount) {
      logMsg = StringFormat("BuyStopCount changed: %d -> %d",
                                     gBuyStopCount, nBuyStopCount);
      LogInfo(logMsg);
   
      gBuyStopCount = nBuyStopCount;
      
      // 当多方挂单数量变化时，重新装载多方订单
      pWave2.LoadBuyOrders();
      
   }
   
   int nSellStopCount = pWave2.GetSellStopOrderCnt();
   if(nSellStopCount != gSellStopCount) {
      logMsg = StringFormat("SellStopCount changed: %d -> %d",
                                     gSellStopCount, nSellStopCount);
      LogInfo(logMsg);
      gSellStopCount = nSellStopCount;
      
      // 当空方挂单数量变化时，重新装载空方订单
      pWave2.LoadSellOrders();
   }
   
   int nBuyOrderCnt = pWave2.GetBuyOrderCnt();
   int nSellOrderCnt = pWave2.GetSellOrderCnt();
   
   logMsg = StringFormat("New tickcount(%s): nBuyOrderCnt = %d, nBuyStopCount = %d, nSellOrderCnt = %d, nSellStopCount = %d ",
                                     symbol,nBuyOrderCnt, 
                                     nBuyStopCount, nSellOrderCnt, nSellStopCount);
   LogInfo(logMsg);
         
   
   
   if(IsDataAndTimeAllowed()) {
      if(pWave2.GetBuyOrderCnt() == 0) {
         // 尚未开任何多单
         if(pWave2.GetBuyStopOrderCnt() == 0) 
         {
            // 尚未开任何挂单，则开挂单
            OptParam param;
            param.m_BaseOpenLots = EA2_MinOpenLots;
            param.m_StopLossPoint = EA2_PointOffsetForStopLossForLong;
            param.m_TakeProfitPoint = EA2_PointOffsetForTakeProfitForLong;
            param.m_OffsetForBuySellStop = EA2_OffsetForBuySellStop;
            pWave2.OpenBuyStopOrders(param);
            // pWave2.OpenBuyOrders(param);
            return;
         }
      }
   }
   
   if(IsDataAndTimeAllowed()) {
      if(pWave2.GetSellOrderCnt() == 0) {
         // 尚未开任何空单
         if(pWave2.GetSellStopOrderCnt() == 0) 
         {
            // 尚未开任何挂单，则开挂单
            OptParam param;
            param.m_BaseOpenLots = EA2_MinOpenLots;
            param.m_StopLossPoint = EA2_PointOffsetForStopLossForShort;
            param.m_TakeProfitPoint = EA2_PointOffsetForTakeProfitForShort;
            param.m_OffsetForBuySellStop = EA2_OffsetForBuySellStop;
            pWave2.OpenSellStopOrders(param);
            // pWave2.OpenSellOrders(param);
            return;
         }
      }
   }
  
   
   if(IsDataAndTimeAllowed()) {
      // 检查多方的轮转订单
      if(pWave2.CheckForAppendBuyOrder(EA2_AppendStep, EA2_SpreadMax,
                                       EA2_EnableLongShortRateForAppend, EA2_EnableLongShortRateLotsForAppend, EA2_MaxHandlingLots)) {
         OptParam param;
         param.m_BaseOpenLots = EA2_BaseOpenLots;
         param.m_StopLossPoint = EA2_PointOffsetForStopLossForLong;
         param.m_TakeProfitPoint = EA2_PointOffsetForTakeProfitForLong;
         pWave2.OpenBuyOrders(param);
      }
      // 检查空方的轮转订单
      if(pWave2.CheckForAppendSellOrder(EA2_AppendStep, EA2_SpreadMax,
                                       EA2_EnableLongShortRateForAppend, EA2_EnableLongShortRateLotsForAppend, EA2_MaxHandlingLots)) {
         OptParam param;
         param.m_BaseOpenLots = EA2_BaseOpenLots;
         param.m_StopLossPoint = EA2_PointOffsetForStopLossForShort;
         param.m_TakeProfitPoint = EA2_PointOffsetForTakeProfitForShort;
         pWave2.OpenSellOrders(param);
      }
      
      double dRevertAppendStepsForLong[MARTIN_APPEND_MAX];
      dRevertAppendStepsForLong[0] = EA2_RevertAppendStepForLong1;
      dRevertAppendStepsForLong[1] = EA2_RevertAppendStepForLong2;
      dRevertAppendStepsForLong[2] = EA2_RevertAppendStepForLong3;
      dRevertAppendStepsForLong[3] = EA2_RevertAppendStepForLong4;
      dRevertAppendStepsForLong[4] = EA2_RevertAppendStepForLong5;
      dRevertAppendStepsForLong[5] = EA2_RevertAppendStepForLong6;
      dRevertAppendStepsForLong[6] = EA2_RevertAppendStepForLong7;
      dRevertAppendStepsForLong[7] = EA2_RevertAppendStepForLong8;
      
      double dRevertAppendLotsForLong[MARTIN_APPEND_MAX];
      dRevertAppendLotsForLong[0] = EA2_RevertAppendLotsForLong1;
      dRevertAppendLotsForLong[1] = EA2_RevertAppendLotsForLong2;
      dRevertAppendLotsForLong[2] = EA2_RevertAppendLotsForLong3;
      dRevertAppendLotsForLong[3] = EA2_RevertAppendLotsForLong4;
      dRevertAppendLotsForLong[4] = EA2_RevertAppendLotsForLong5;
      dRevertAppendLotsForLong[5] = EA2_RevertAppendLotsForLong6;
      dRevertAppendLotsForLong[6] = EA2_RevertAppendLotsForLong7;
      dRevertAppendLotsForLong[7] = EA2_RevertAppendLotsForLong8;
      
      // 检查多方的马丁加仓订单
      if(pWave2.CheckForAppendBuyMartinOrder(dRevertAppendStepsForLong, EA2_SpreadMax,
                                          EA2_MaxHandlingLots, EA2_BackwordForAppendLongMartin)) {
           // 多方马丁加仓
           int nBuyMartinCount = pWave2.GetBuyMartinOrderCnt();
           if(nBuyMartinCount < MARTIN_APPEND_MAX) {
              OptParam param;
              param.m_BaseOpenLots = dRevertAppendLotsForLong[nBuyMartinCount];
              param.m_StopLossPoint = EA2_PointOffsetForStopLossForLongMartin;
              param.m_TakeProfitPoint = EA2_PointOffsetForTakeProfitForLongMartin;
              pWave2.OpenBuyMartinOrders(param);
              pWave2.CloseAllSellStopOrders();
              pWave2.LoadSellStopOrders();
           }    
      }
      
      double dRevertAppendStepsForShort[MARTIN_APPEND_MAX];
      dRevertAppendStepsForShort[0] = EA2_RevertAppendStepForShort1;
      dRevertAppendStepsForShort[1] = EA2_RevertAppendStepForShort2;
      dRevertAppendStepsForShort[2] = EA2_RevertAppendStepForShort3;
      dRevertAppendStepsForShort[3] = EA2_RevertAppendStepForShort4;
      dRevertAppendStepsForShort[4] = EA2_RevertAppendStepForShort5;
      dRevertAppendStepsForShort[5] = EA2_RevertAppendStepForShort6;
      dRevertAppendStepsForShort[6] = EA2_RevertAppendStepForShort7;
      dRevertAppendStepsForShort[7] = EA2_RevertAppendStepForShort8;
      
      double dRevertAppendLotsForShort[MARTIN_APPEND_MAX];
      dRevertAppendLotsForShort[0] = EA2_RevertAppendLotsForShort1;
      dRevertAppendLotsForShort[1] = EA2_RevertAppendLotsForShort2;
      dRevertAppendLotsForShort[2] = EA2_RevertAppendLotsForShort3;
      dRevertAppendLotsForShort[3] = EA2_RevertAppendLotsForShort4;
      dRevertAppendLotsForShort[4] = EA2_RevertAppendLotsForShort5;
      dRevertAppendLotsForShort[5] = EA2_RevertAppendLotsForShort6;
      dRevertAppendLotsForShort[6] = EA2_RevertAppendLotsForShort7;
      dRevertAppendLotsForShort[7] = EA2_RevertAppendLotsForShort8;
      
      // 检查空方的马丁加仓订单
      if(pWave2.CheckForAppendSellMartinOrder(dRevertAppendStepsForShort, EA2_SpreadMax,
                                          EA2_MaxHandlingLots, EA2_BackwordForAppendShortMartin)) {
         // 空方马丁加仓
         int nSellMartinCount = pWave2.GetSellMartinOrderCnt();
         if(nSellMartinCount < MARTIN_APPEND_MAX) {
            OptParam param;
            param.m_BaseOpenLots = dRevertAppendLotsForShort[nSellMartinCount];
            param.m_StopLossPoint = EA2_PointOffsetForStopLossForShortMartin;
            param.m_TakeProfitPoint = EA2_PointOffsetForTakeProfitForShortMartin;
            pWave2.OpenSellMartinOrders(param);
            pWave2.CloseAllBuyStopOrders();
            pWave2.LoadBuyStopOrders();
         }
        
      }
   }
   
   if(EA2_EnableLongShortWholeClose 
      && pWave2.GetAllBuyLots() >= EA2_BuyLotsForWholeClose
      && pWave2.GetAllSellLots() >= EA2_SellLotsForWholeClose) {
      // 已经持有马丁多单，走马丁平仓判断流程
         LogInfo("============ 整体止盈判断流程 =================");
      if(pWave2.CheckForWholeCloseOrders(EA2_ProfitsWholeClose, EA2_EnableMovableForWholeClose, EA2_BackwardForWholeClose)) {
         pWave2.CloseAllOrders();
         pWave2.CleanAllOrders();
      }
      
   }else {
   
      int nBuyMartinCount = pWave2.GetBuyMartinOrderCnt();
      int nSellMartinCount = pWave2.GetSellMartinOrderCnt();
      
      if(nBuyMartinCount > 0) {
         if(nBuyMartinCount < EA2_EnableStage2CountForLongMartin2) {
            // 已经持有马丁多单，走马丁平仓判断流程
            LogInfo("============ 多单马丁平仓判断流程 =================");
            double highestBuyPrice = pWave2.GetHighestBuyOrderPrice();
            double lowestBuyMartinPrice = pWave2.GetLowestBuyMartinOrderPrice();
            double dPriceDiff = highestBuyPrice - lowestBuyMartinPrice;
            double dBuyLots = pWave2.GetAllBuyLots();
              
            double dTakeProfitsBuy = (dPriceDiff / Point) * dBuyLots * EA2_TakeProfitsFacorForLongMartin;
            pWave2.CheckForCloseBuyMartinOrders(dTakeProfitsBuy, EA2_BackwordForLongMartin);
         }else {
             // 已经持有马丁多单，走马丁平仓判断流程
            LogInfo("============ 多单马丁平仓判断流程(二阶段) =================");
            double highestBuyPrice = pWave2.GetHighestBuyMartinOrderPrice();
            double lowestBuyMartinPrice = pWave2.GetLowestBuyMartinOrderPrice();
            double dPriceDiff = highestBuyPrice - lowestBuyMartinPrice;
            double dBuyLots = pWave2.GetMartinBuyLotsForStage2();
              
            double dTakeProfitsBuy = (dPriceDiff / Point) * dBuyLots * EA2_TakeProfitsFacorForLongMartin2;
            pWave2.CheckForCloseBuyMartinOrdersStage2(dTakeProfitsBuy, EA2_BackwordForLongMartin2, EA2_CheckLastNForLong);
         }
      }else {
         LogInfo("============ 多单普通轮转的平仓判断流程 =================");
         // 没有持有马丁多单，走普通轮转的平仓判断流程
         pWave2.CheckForCloseBuyOrders(EA2_PointOffsetForMovableTakeProfitForLong, EA2_BackwordForLong,
                                    EA2_EnableLongShortRateForClose, EA2_EnableLongShortRateLotsForClose);
      }
      
      if(nSellMartinCount > 0) {
         if(nSellMartinCount < EA2_EnableStage2CountForShortMartin2) {
            // 已经持有马丁多单，走马丁平仓判断流程
            LogInfo("============ 空单马丁平仓判断流程 =================");
            double lowestSellPrice = pWave2.GetLowestSellOrderPrice();
            double highestSellMartinPrice = pWave2.GetHighestSellMartinOrderPrice();
            double dPriceDiff = highestSellMartinPrice - lowestSellPrice;
            double dSellLots = pWave2.GetAllSellLots();
              
            double dTakeProfitsSell = (dPriceDiff / Point) * dSellLots * EA2_TakeProfitsFacorForShortMartin;
            pWave2.CheckForCloseSellMartinOrders(dTakeProfitsSell, EA2_BackwordForShortMartin);
         } else {
            // 已经持有马丁多单，走马丁平仓判断流程
            LogInfo("============ 空单马丁平仓判断流程(阶段二) =================");
            double lowestSellPrice = pWave2.GetLowestSellMartinOrderPrice();
            double highestSellMartinPrice = pWave2.GetHighestSellMartinOrderPrice();
            double dPriceDiff = highestSellMartinPrice - lowestSellPrice;
            double dSellLots = pWave2.GetMartinSellLotsForStage2();
              
            double dTakeProfitsSell = (dPriceDiff / Point) * dSellLots * EA2_TakeProfitsFacorForShortMartin2;
            pWave2.CheckForCloseSellMartinOrdersStage2(dTakeProfitsSell, EA2_BackwordForShortMartin2, EA2_CheckLastNForShort);
         }
      }else {
         LogInfo("============ 空单普通轮转的平仓判断流程 =================");
         pWave2.CheckForCloseSellOrders(EA2_PointOffsetForMovableTakeProfitForShort, EA2_BackwordForShort,
                                    EA2_EnableLongShortRateForClose, EA2_EnableLongShortRateLotsForClose);
      }
   }
   
   if(gBuyMartinCloseCount + gSellMartinCloseCount >= EA2_MartinCloseMaxTimes + 1) {
      gBuyMartinCloseCount = 0;
      gSellMartinCloseCount = 0;
   }
                                
   //double currentEquity = AccountEquity(); // 净值
   //if(currentEquity > mostEquity) {
   //   mostEquity = currentEquity;
   //}
   
   double baseTargetEquity = gBaseEquity * (1 + EA2_TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - EA2_BackwordForClose));
   if(EA2_EnableAutoCloseAll) {
       if(pWave2.CheckForAutoCloseAll(gBaseEquity, preEquity, mostEquity, realTargetEquity)) {
         pWave2.CloseAllOrders();
         pWave2.CleanAllOrders();
         gBaseEquity =  AccountEquity();
       }
   }   
   //preEquity = currentEquity;  
  
}

void Destroy()
{
   if(pWave) {
      delete pWave; 
      pWave = NULL;
   }
   
   if(pWave2) {
      delete pWave2; 
      pWave2 = NULL;
   }
}
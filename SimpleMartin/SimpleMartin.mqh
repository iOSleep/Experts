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
#include "ClUtil.mqh"
#include "WaveOrder.mqh"



bool PassOK = false;

bool gDisableOpen = false;

double mostEquity = 0;
double leastEquity = 0;
double preEquity = 0;
double gBaseEquity = BaseEquity;

CWaveOrder * pWave = NULL;

bool IsDataAndTimeAllowed() {
   if(EnableTradingDate && !IsBetweenDate(OpenOrderStartDate, OpenOrderEndDate)) {
      return false;
   }
   
   if(EnableTradingTime && !IsBetweenTime(OpenOrderStartTime, OpenOrderEndTime)) {
      return false;
   }
   return true; 
}

void Main()
{
   string logMsg = "";
   string symbol = Symbol();
   
   if(gDisableOpen) return;
   
   if(!pWave) {
      pWave = new CWaveOrder(symbol, MagicNum); 
      pWave.LoadAllOrders();
   }
      
   pWave.HeartBeat();
   
   int nBuyOrderCnt = pWave.GetBuyOrderCnt();
   int nSellOrderCnt = pWave.GetSellOrderCnt();
   
   logMsg = StringFormat("New tickcount(%s): nBuyOrderCnt = %d, nSellOrderCnt = %d",
                                     symbol,nBuyOrderCnt, 
                                     nSellOrderCnt);
   LogInfo(logMsg);
    
   if(IsDataAndTimeAllowed()) {
      if(pWave.GetBuyOrderCnt() == 0) {
         // 尚未开任何多单
         bool bNeedOpen = true;
         if(gDisableOpen) {
            bNeedOpen = false;
         }
                  
         if(bNeedOpen && !StopLongSide) {
           
            OptParam param;
            param.m_BaseOpenLots = BaseOpenBuyLots;
            param.m_StopLossPoint = 0;
            param.m_TakeProfitPoint = 0;
            // param.m_OffsetForBuySellStop = OffsetForBuySellStop;
            // 尚未开任何挂单，则开挂单
            // pWave.OpenBuyStopOrders(param);
            
            // 尚未开任何多单，则开多单
            pWave.OpenBuyOrders(param);  
            return;
         }
      }
   }
   
   if(IsDataAndTimeAllowed()) {
      if(pWave.GetSellOrderCnt() == 0) {
         // 尚未开任何空单
         
         bool bNeedOpen = true;
         if(gDisableOpen) {
            bNeedOpen = false;
         }
         
         if(bNeedOpen && !StopShortSide) {
            OptParam param;
            param.m_BaseOpenLots = BaseOpenSellLots;
            param.m_StopLossPoint = 0;
            param.m_TakeProfitPoint = 0;
            // param.m_OffsetForBuySellStop = OffsetForBuySellStop;
            // 尚未开任何挂单，则开挂单
            // pWave.OpenSellStopOrders(param);
            
            // 尚未开任何空单，则开空单
            pWave.OpenSellOrders(param);
            return;
         }
      }
   }
  
   
   //if(IsDataAndTimeAllowed()) 
   {
        
      double dRevertAppendStepsForLong = RevertAppendStepForLong1_5;
      if(nBuyOrderCnt >= 6 && nBuyOrderCnt <= 10) 
         dRevertAppendStepsForLong = RevertAppendStepForLong6_10;
      if(nBuyOrderCnt >= 11 && nBuyOrderCnt <= 15) 
         dRevertAppendStepsForLong = RevertAppendStepForLong11_15;
      if(nBuyOrderCnt >= 16 && nBuyOrderCnt <= 20) 
         dRevertAppendStepsForLong = RevertAppendStepForLong16_20;
      if(nBuyOrderCnt >= 21 && nBuyOrderCnt <= 25) 
         dRevertAppendStepsForLong = RevertAppendStepForLong21_25;
      if(nBuyOrderCnt >= 26 && nBuyOrderCnt <= 30) 
         dRevertAppendStepsForLong = RevertAppendStepForLong26_30;
      if(nBuyOrderCnt >= 31 && nBuyOrderCnt <= 35) 
         dRevertAppendStepsForLong = RevertAppendStepForLong31_35;
      if(nBuyOrderCnt >= 36 && nBuyOrderCnt <= 40) 
         dRevertAppendStepsForLong = RevertAppendStepForLong36_40;
      
      
      double dRevertAppendStepsForShort = RevertAppendStepForShort1_5;
      if(nSellOrderCnt >= 6 && nSellOrderCnt <= 10) 
         dRevertAppendStepsForShort = RevertAppendStepForShort6_10;
      if(nSellOrderCnt >= 11 && nSellOrderCnt <= 15) 
         dRevertAppendStepsForShort = RevertAppendStepForShort11_15;
      if(nSellOrderCnt >= 16 && nSellOrderCnt <= 20) 
         dRevertAppendStepsForShort = RevertAppendStepForShort16_20;
      if(nSellOrderCnt >= 21 && nSellOrderCnt <= 25) 
         dRevertAppendStepsForShort = RevertAppendStepForShort21_25;
      if(nSellOrderCnt >= 26 && nSellOrderCnt <= 30) 
         dRevertAppendStepsForShort = RevertAppendStepForShort26_30;
      if(nSellOrderCnt >= 31 && nSellOrderCnt <= 35) 
         dRevertAppendStepsForShort = RevertAppendStepForShort31_35;
      if(nSellOrderCnt >= 36 && nSellOrderCnt <= 40) 
         dRevertAppendStepsForShort = RevertAppendStepForShort36_40;
      
      // 检查多方的马丁加仓订单
      if(pWave.CheckForAppendBuyMartinOrder(dRevertAppendStepsForLong, SpreadMax,
                                          MaxHandlingLots, BackwordForAppendLongMartin)) {
           // 多方马丁加仓
           int nBuyCount = pWave.GetBuyOrderCnt();
           if(nBuyCount < MARTIN_APPEND_MAX) {
              OptParam param;
              param.m_BaseOpenLots = BaseOpenBuyLots * (nBuyCount + 1);
              param.m_StopLossPoint = 0;
              param.m_TakeProfitPoint = 0;
              pWave.OpenBuyOrders(param);
           }    
      }
      
           
      // 检查空方的马丁加仓订单
      if(pWave.CheckForAppendSellMartinOrder(dRevertAppendStepsForShort, SpreadMax,
                                          MaxHandlingLots, BackwordForAppendShortMartin)) {
         // 空方马丁加仓
         int nSellCount = pWave.GetSellOrderCnt();
         if(nSellCount < MARTIN_APPEND_MAX) {
            OptParam param;
            param.m_BaseOpenLots = BaseOpenSellLots * (nSellCount + 1);
            param.m_StopLossPoint = 0;
            param.m_TakeProfitPoint = 0;
            pWave.OpenSellOrders(param);
         }
        
      }
   }
   
   if(EnableLongShortWholeClose 
      && pWave.GetAllBuyLots() >= BuyLotsForWholeClose
      && pWave.GetAllSellLots() >= SellLotsForWholeClose) {
      // 已经持有马丁多单，走马丁平仓判断流程
         LogInfo("============ 整体止盈判断流程 =================");
      if(pWave.CheckForWholeCloseOrders(ProfitsWholeClose, EnableMovableForWholeClose, BackwardForWholeClose)) {
         pWave.CloseAllOrders();
         pWave.CleanAllOrders();
      }
      
   }else {
   
      int nBuyCount = pWave.GetBuyOrderCnt();
      if(nBuyCount > 1) {
             // 已经持有马丁多单，走马丁平仓判断流程
            LogInfo("============ 多单马丁平仓判断流程=================");
            double highestBuyPrice = pWave.GetHighestBuyOrderPrice();
            double lowestBuyMartinPrice = pWave.GetLowestBuyOrderPrice();
            double dPriceDiff = highestBuyPrice - lowestBuyMartinPrice;
            double dBuyLots = pWave.GetMartinBuyLotsForStage2();
            
            if(EnableMovableTakeProfitForLong) {
               double dTakeProfitsBuy = (dPriceDiff / Point) * dBuyLots * TakeProfitsFacorForLongMartin;
               pWave.CheckForCloseBuyMartinOrdersStage2(dTakeProfitsBuy, BackwordForLongMartin);
            } else {
               double dTakeProfitsBuy = FixedTakeProfitsForLong;
               pWave.CheckForCloseBuyMartinOrdersStage(dTakeProfitsBuy);
            }
         
      }else {
         LogInfo("============ 多单普通轮转的平仓判断流程 =================");
         // 没有持有马丁多单，走普通轮转的平仓判断流程
         pWave.CheckForCloseBuyOrders(PointOffsetForMovableTakeProfitForLong, BackwordForLong);
      }
      
      int nSellCount = pWave.GetSellOrderCnt();
      if(nSellCount > 1) {
            // 已经持有马丁多单，走马丁平仓判断流程
            LogInfo("============ 空单马丁平仓判断流程 =================");
            double lowestSellPrice = pWave.GetLowestSellOrderPrice();
            double highestSellMartinPrice = pWave.GetHighestSellOrderPrice();
            double dPriceDiff = highestSellMartinPrice - lowestSellPrice;
            double dSellLots = pWave.GetMartinSellLotsForStage2();
            if(EnableMovableTakeProfitForShort) {
               double dTakeProfitsSell = (dPriceDiff / Point) * dSellLots * TakeProfitsFacorForShortMartin;
               pWave.CheckForCloseSellMartinOrdersStage2(dTakeProfitsSell, BackwordForShortMartin);
            } else {
               double dTakeProfitsSell = FixedTakeProfitsForShort;
               pWave.CheckForCloseSellMartinOrdersStage(dTakeProfitsSell);
            }
      }else {
         LogInfo("============ 空单普通轮转的平仓判断流程 =================");
         pWave.CheckForCloseSellOrders(PointOffsetForMovableTakeProfitForShort, BackwordForShort);
      }
   }
                                
   double currentEquity = AccountEquity(); // 净值
   if(currentEquity > mostEquity) {
      mostEquity = currentEquity;
   }
   
   if(currentEquity < leastEquity) {
      leastEquity = currentEquity;
   }
   
   // 整体移动止盈
   double baseTargetEquity = gBaseEquity * (1 + TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - BackwordForClose));
   if(EnableAutoCloseAll) {
       if(pWave.CheckForAutoCloseAll(gBaseEquity, preEquity, leastEquity, mostEquity, realTargetEquity)) {
         pWave.CloseAllOrders();
         pWave.CleanAllOrders();
         gBaseEquity =  AccountEquity();
       }
   }  
    
   // 整体移动止损
   double targetStopLossEquity = gBaseEquity * (1 - AutoCloseAllForStopLossRate);
   if(EnableAutoCloseAllForStopLoss) {
      // 启用了整体止损
      if(pWave.CheckForAutoStopLossAll(targetStopLossEquity)) {
         pWave.CloseAllOrders();
         pWave.CleanAllOrders();
         gBaseEquity =  AccountEquity();
         if(!ContinueOpenAfterCloseAllForStopLoss) {
            gDisableOpen = true;
         }
      }
      
   }
   preEquity = currentEquity;  
  
}

void Destroy()
{
   if(pWave) {
      delete pWave; 
      pWave = NULL;
   }
}
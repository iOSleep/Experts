//+------------------------------------------------------------------+
//|                                                MartinHedging.mqh |
//|                                                          Cuilong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "https://www.mql5.com"
#property strict

#include "PubVar.mqh"
#include "ClUtil.mqh"
#include "MartinOrder.mqh"
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

#define STAGE_MAX 20

bool PassOK = false;

CMartinOrder * pMoBuy = NULL;
CMartinOrder * pMoSell = NULL;

double mostEquity = 0;
double preEquity = 0;
double gBaseEquity = BaseEquity;
double gPreLoss = 0;
bool gDisableOpen = false;
   
void Main()
{  
   if(gDisableOpen) return;

    if(!PassOK) {
      PassOK = CheckPasscode(Passcode);
      return;
   }
   
   if(!PassOK) return;
   
   bool bIsNewBar = IsNewBar();
   if(!gIsNewBar && bIsNewBar)
   {
      gIsNewBar = bIsNewBar;
   }else
   {
      gIsNewBar = false;
   }
   
   if(gIsNewBar) {
      LogInfo("--------------- New Bar -----------------");
   }
   
   OptParam optParamLong[STAGE_MAX];
   OptParam optParamShort[STAGE_MAX];
   optParamLong[0].m_BaseOpenLots = BaseOpenLots1Long;
   optParamLong[0].m_MultipleForAppend = Multiple1Long;
   optParamLong[0].m_MulipleFactorForAppend = MulipleFactorForAppend1Long;
   optParamLong[0].m_AppendMax = AppendMax1Long;
   optParamLong[0].m_PointOffsetForStage = PointOffsetForStage1Long;
   optParamLong[0].m_PointOffsetForAppend = PointOffsetForAppend1Long;
   optParamLong[0].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend1Long;
   optParamLong[0].m_AppendBackword = AppendBackword1Long;
   optParamLong[0].m_TakeProfitsPerLot = TakeProfitsPerLot1Long;
   optParamLong[0].m_TakeProfitsFacor = TakeProfitsFacor1Long;
   optParamLong[0].m_Backword = Backword1Long;
   
   optParamShort[0].m_BaseOpenLots = BaseOpenLots1Short;
   optParamShort[0].m_MultipleForAppend = Multiple1Short;
   optParamShort[0].m_MulipleFactorForAppend = MulipleFactorForAppend1Short;
   optParamShort[0].m_AppendMax = AppendMax1Short;
   optParamShort[0].m_PointOffsetForStage = PointOffsetForStage1Short;
   optParamShort[0].m_PointOffsetForAppend = PointOffsetForAppend1Short;
   optParamShort[0].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend1Short;
   optParamShort[0].m_AppendBackword = AppendBackword1Short;
   optParamShort[0].m_TakeProfitsPerLot = TakeProfitsPerLot1Short;
   optParamShort[0].m_TakeProfitsFacor = TakeProfitsFacor1Short;
   optParamShort[0].m_Backword = Backword1Short; 
   
   optParamLong[1].m_BaseOpenLots = BaseOpenLots2Long;
   optParamLong[1].m_MultipleForAppend = Multiple2Long;
   optParamLong[1].m_MulipleFactorForAppend = MulipleFactorForAppend2Long;
   optParamLong[1].m_AppendMax = AppendMax2Long;
   optParamLong[1].m_PointOffsetForStage = PointOffsetForStage2Long;
   optParamLong[1].m_PointOffsetForAppend = PointOffsetForAppend2Long;
   optParamLong[1].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend2Long;
   optParamLong[1].m_AppendBackword = AppendBackword2Long;
   optParamLong[1].m_TakeProfitsPerLot = TakeProfitsPerLot2Long;
   optParamLong[1].m_TakeProfitsFacor = TakeProfitsFacor2Long;
   optParamLong[1].m_Backword = Backword2Long;
   
   optParamShort[1].m_BaseOpenLots = BaseOpenLots2Short;
   optParamShort[1].m_MultipleForAppend = Multiple2Short;
   optParamShort[1].m_MulipleFactorForAppend = MulipleFactorForAppend2Short;
   optParamShort[1].m_AppendMax = AppendMax2Short;
   optParamShort[1].m_PointOffsetForStage = PointOffsetForStage2Short;
   optParamShort[1].m_PointOffsetForAppend = PointOffsetForAppend2Short;
   optParamShort[1].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend2Short;
   optParamShort[1].m_AppendBackword = AppendBackword2Short;
   optParamShort[1].m_TakeProfitsPerLot = TakeProfitsPerLot2Short;
   optParamShort[1].m_TakeProfitsFacor = TakeProfitsFacor2Short;
   optParamShort[1].m_Backword = Backword2Short; 
   
   
   for(int i = 2; i < STAGE_MAX - 1; i++){
      optParamLong[i].m_BaseOpenLots = BaseOpenLots3Long;
      optParamLong[i].m_MultipleForAppend = Multiple3Long;
      optParamLong[i].m_MulipleFactorForAppend = MulipleFactorForAppend3Long;
      optParamLong[i].m_AppendMax = AppendMax3Long;
      optParamLong[i].m_PointOffsetForStage = PointOffsetForStage3Long;
      optParamLong[i].m_PointOffsetForAppend = PointOffsetForAppend3Long;
      optParamLong[i].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend3Long;
      optParamLong[i].m_AppendBackword = AppendBackword3Long;
      optParamLong[i].m_TakeProfitsPerLot = TakeProfitsPerLot3Long;
      optParamLong[i].m_TakeProfitsFacor = TakeProfitsFacor3Long;
      optParamLong[i].m_Backword = Backword3Long;
      
      optParamShort[i].m_BaseOpenLots = BaseOpenLots3Short;
      optParamShort[i].m_MultipleForAppend = Multiple3Short;
      optParamShort[i].m_MulipleFactorForAppend = MulipleFactorForAppend3Short;
      optParamShort[i].m_AppendMax = AppendMax3Short;
      optParamShort[i].m_PointOffsetForStage = PointOffsetForStage3Short;
      optParamShort[i].m_PointOffsetForAppend = PointOffsetForAppend3Short;
      optParamShort[i].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend3Short;
      optParamShort[i].m_AppendBackword = AppendBackword3Short;
      optParamShort[i].m_TakeProfitsPerLot = TakeProfitsPerLot3Short;
      optParamShort[i].m_TakeProfitsFacor = TakeProfitsFacor3Short;
      optParamShort[i].m_Backword = Backword3Short;
   }
   
   string symbol = Symbol();
   // 1. 检查持仓情况
   if(!pMoBuy) {
      pMoBuy = new CMartinOrder(symbol, OP_BUY, MagicNum);
   }
   
   if(!pMoSell) {
      pMoSell = new CMartinOrder(symbol, OP_SELL, MagicNum);
   }
   int nBuyOrderCnt = pMoBuy.LoadAllOrders(optParamLong, StageMax);
   int nSellOrderCnt = pMoSell.LoadAllOrders(optParamShort, StageMax);
   
   int nStageBuy = pMoBuy.CalcStageNumber(nBuyOrderCnt, optParamLong, StageMax);
   int nAppendNumberBuy = pMoBuy.CalcAppendNumber(nStageBuy, nBuyOrderCnt, optParamLong, StageMax);
   
   int nStageSell = pMoSell.CalcStageNumber(nSellOrderCnt, optParamShort, StageMax);
   int nAppendNumberSell = pMoSell.CalcAppendNumber(nStageSell, nSellOrderCnt, optParamShort, StageMax);   

   double dBuyLots = pMoBuy.m_dLots;
   double dSellLots = pMoSell.m_dLots;
   
   if(nBuyOrderCnt == 0)
   {
      if(!StopLongSide) {
         pMoBuy.OpenOrders(optParamLong, StageMax);
      }
     
   }
   
   if(nSellOrderCnt == 0)
   {
      if(!StopShortSide) {
           pMoSell.OpenOrders(optParamShort, StageMax);
      }
   }
   
   
   // 2. 检查平仓条件            
   double dPriceDiff = 0;
   double dBuyLotsStage = 0;
   // if(nStageBuy == 0 || nStageBuy == STAGE_MAX - 1) {
      // 获取总价格差和总手数
   //    dPriceDiff = pMoBuy.GetPriceDiff();
   //    dBuyLotsStage = pMoBuy.m_dLots;      
   // }else {
      // 仅仅获取本间断的价格差和本阶段的总手数
   //    dPriceDiff = pMoBuy.GetPriceDiff(nAppendNumberBuy);
   //    dBuyLotsStage = pMoBuy.GetLots(nAppendNumberBuy);
   // }
   
   // 仅仅获取本间断的价格差和本阶段的总手数
   dPriceDiff = pMoBuy.GetPriceDiff(nAppendNumberBuy);
   dBuyLotsStage = pMoBuy.GetLots(nAppendNumberBuy);
     
   double dTakeProfitsBuy = 0;   
   if(nBuyOrderCnt > 1) {      
      dTakeProfitsBuy = (dPriceDiff / Point) * (dBuyLotsStage) * optParamLong[nStageBuy].m_TakeProfitsFacor;
   }else {
      dTakeProfitsBuy = (PointOffsetForProfit / Point) * dBuyLotsStage;
      if(dTakeProfitsBuy == 1) {
         dTakeProfitsBuy = 0;
      }
   }
  
   if(pMoBuy.CheckForClose(PointOffsetForProfit,  dTakeProfitsBuy, 
                              optParamLong[nStageBuy].m_Backword))
   {
      // 满足平仓条件，平掉本方向的订单
      if(nStageBuy == 0) {
         // 第一阶段或最后一个阶段，平全部订单
         // pMoBuy.CloseOrders();
         if(nAppendNumberBuy <= 1) {
            pMoBuy.CloseOrders(1);
         }else {
            pMoBuy.CloseOrders(nAppendNumberBuy - 1);
         }
      }else {
         // 其余阶段，仅平掉本阶段的订单，但剩余第一轮的订单 
         if(nAppendNumberBuy <= 1) {
            pMoBuy.CloseOrders(1);
         }else {
            pMoBuy.CloseOrders(nAppendNumberBuy - 1);
         }
      }
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      if(nStageBuy < StageMax) {
            OptParam param = optParamLong[nStageBuy];
            double dOffset = param.m_PointOffsetForAppend;
            double factor = param.m_PointOffsetFactorForAppend;
            bool bFactor = true;
            if(nAppendNumberBuy >= param.m_AppendMax) {
               dOffset = param.m_PointOffsetForStage;
               factor = 1.0;
               bFactor = false;
            }  
            
            if(nAppendNumberBuy == 1) {
               bFactor = false;
            }
                      
            if(pMoBuy.CheckForAppend(dOffset, factor, param.m_AppendBackword, nAppendNumberBuy, bFactor))
            {
               LogInfo("+++++++++++++++ Buy Append ++++++++++++++++++++++++++++++++++");
               string logMsg = StringFormat("多方加仓：offset = %s, Stage = %d, AppendNumber = %d.", 
                        DoubleToString(dOffset, 4),
                        nStageBuy + 1, nAppendNumberBuy); 
               LogInfo(logMsg);
               if(!StopLongSide) {
                  pMoBuy.OpenOrders(optParamLong, StageMax);
               }
                        
            }
      }
   }
     
   dPriceDiff = 0;
   double dSellLotsStage = 0;
   //if(nStageSell == 0 || nStageSell == STAGE_MAX - 1) {
      // 获取总价格差和总手数
   //   dPriceDiff = pMoSell.GetPriceDiff();
   //   dSellLotsStage = pMoSell.m_dLots;      
   //}else {
      // 仅仅获取本间断的价格差和本阶段的总手数
   //   dPriceDiff = pMoSell.GetPriceDiff(nAppendNumberSell);
   //   dSellLotsStage = pMoSell.GetLots(nAppendNumberSell);
   //}
   
   // 仅仅获取本间断的价格差和本阶段的总手数
   dPriceDiff = pMoSell.GetPriceDiff(nAppendNumberSell);
   dSellLotsStage = pMoSell.GetLots(nAppendNumberSell);
   double dTakeProfitsSell = 0;   
   if(nSellOrderCnt > 1) {      
      dTakeProfitsSell = (dPriceDiff / Point ) * (dSellLotsStage) * optParamShort[nStageSell].m_TakeProfitsFacor;
   }else {
      
      dTakeProfitsSell = (PointOffsetForProfit / Point) * dSellLotsStage;
      if(nAppendNumberSell == 1) {
         dTakeProfitsSell = 0;
      }
   }
   
   if(pMoSell.CheckForClose(PointOffsetForProfit,dTakeProfitsSell, 
                              optParamShort[nStageSell].m_Backword)) {
                               // 满足平仓条件，平掉本方向的订单
      if(nStageSell == 0) {
         // 第一阶段或最后一个阶段，平全部订单
         // pMoSell.CloseOrders();
         
         if(nAppendNumberSell <= 1) {
            pMoSell.CloseOrders(1);
         }else {
            // 其余阶段，仅平掉本阶段的订单，但剩余第一轮的订单           
            pMoSell.CloseOrders(nAppendNumberSell - 1);
         }
      }else {
         if(nAppendNumberSell == 1) {
            pMoSell.CloseOrders(nAppendNumberSell);
         }else {
            // 其余阶段，仅平掉本阶段的订单，但剩余第一轮的订单           
            pMoSell.CloseOrders(nAppendNumberSell - 1);
         }
      }
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
       if(nStageSell < StageMax) {
            OptParam param = optParamShort[nStageSell];
            double dOffset = param.m_PointOffsetForAppend;
            double factor = param.m_PointOffsetFactorForAppend;
            bool  bFactor = true;
            if(nAppendNumberSell >= param.m_AppendMax) {
               dOffset = param.m_PointOffsetForStage;
               factor = 1.0;
               bFactor = false;
            }
            
            if(nAppendNumberSell == 1) {
               bFactor = false;
            }
              
         if(pMoSell.CheckForAppend(dOffset, factor, param.m_AppendBackword, nAppendNumberSell, bFactor))
         {
              LogInfo("+++++++++++++++ Buy Append ++++++++++++++++++++++++++++++++++");
               string logMsg = StringFormat("空方加仓：offset = %s, Stage = %d, AppendNumber = %d.", 
                        DoubleToString(dOffset, 4),
                        nStageSell + 1, nAppendNumberSell); 
               LogInfo(logMsg);
               if(!StopShortSide) {
                  pMoSell.OpenOrders(optParamShort, StageMax);
               }             
         }
      }
    
   }
   
   double currentEquity = AccountEquity(); // 净值
   if(currentEquity > mostEquity) {
      mostEquity = currentEquity;
   }     
   
   if(EnableAutoCloseAllForStopLoss) {
      double currentLoss = pMoSell.CalsUnrealizedLoss();
      if(gPreLoss > 0) {
         if(gPreLoss > TargetLossAmout && currentLoss < TargetLossAmout) {
            string logMsg = StringFormat("浮亏达到清仓标准：%s --> %s.", 
                        DoubleToString(gPreLoss, 2),DoubleToString(currentLoss, 2));
            LogInfo(logMsg);
            pMoSell.CloseOrders();
            pMoBuy.CloseOrders();
            gDisableOpen = true;
         }
      }
      gPreLoss = currentLoss;
   }
   
   double baseTargetEquity = gBaseEquity * (1 + TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - BackwordForClose));
   if(EnableAutoCloseAll) {
       if(pMoSell.CheckForAutoCloseAll(gBaseEquity, preEquity, mostEquity, realTargetEquity)) {
         pMoSell.CloseOrders();
         pMoBuy.CloseOrders();
         gBaseEquity =  AccountEquity();
       }
   }
   
    // 检查止损条件
   if(EnableStopLoss) {   
      if(nSellOrderCnt > nBuyOrderCnt) {
         if(pMoSell.CheckStopLoss(StopLossRate)) {
            pMoSell.CloseOrders();
         }
      }
      
      if(nBuyOrderCnt > nSellOrderCnt) {
         if(pMoBuy.CheckStopLoss(StopLossRate)) {
            pMoBuy.CloseOrders();
         }
      } 
   }
   
   preEquity = currentEquity;  
   
   gTickCount++;
}

void Destroy()
{
   if(pMoBuy) {
      delete pMoBuy; 
      pMoBuy = NULL;
   }
   
   if(pMoSell) {
       delete pMoSell;
       pMoSell = NULL;
   }
}
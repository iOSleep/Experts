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

#define STAGE_MAX 5

bool PassOK = false;

CMartinOrder * pMoBuy = NULL;
CMartinOrder * pMoSell = NULL;

double mostEquity = 0;
double preEquity = 0;
double gBaseBalance = BaseBalance;
   
void Main()
{  

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
   
   OptParam optParam[STAGE_MAX];
   optParam[0].m_BaseOpenLots = BaseOpenLots1;
   optParam[0].m_MultipleForAppend = Multiple1;
   optParam[0].m_MulipleFactorForAppend = MulipleFactorForAppend1;
   optParam[0].m_AppendMax = AppendMax1;
   optParam[0].m_PointOffsetForStage = PointOffsetForStage1;
   optParam[0].m_PointOffsetForAppend = PointOffsetForAppend1;
   optParam[0].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend1;
   optParam[0].m_AppendBackword = AppendBackword1;
   optParam[0].m_TakeProfitsPerLot = TakeProfitsPerLot1;
   optParam[0].m_TakeProfitsFacor = TakeProfitsFacor1;
   optParam[0].m_Backword = Backword1; 
   
   optParam[1].m_BaseOpenLots = BaseOpenLots2;
   optParam[1].m_MultipleForAppend = Multiple2;
   optParam[1].m_MulipleFactorForAppend = MulipleFactorForAppend2;
   optParam[1].m_AppendMax = AppendMax2;
   optParam[1].m_PointOffsetForStage = PointOffsetForStage2;
   optParam[1].m_PointOffsetForAppend = PointOffsetForAppend2;
   optParam[1].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend2;
   optParam[1].m_AppendBackword = AppendBackword2;
   optParam[1].m_TakeProfitsPerLot = TakeProfitsPerLot2;
   optParam[1].m_TakeProfitsFacor = TakeProfitsFacor2;
   optParam[1].m_Backword = Backword2;
   
   optParam[2].m_BaseOpenLots = BaseOpenLots3;
   optParam[2].m_MultipleForAppend = Multiple3;
   optParam[2].m_MulipleFactorForAppend = MulipleFactorForAppend3;
   optParam[2].m_AppendMax = AppendMax3;
   optParam[2].m_PointOffsetForStage = PointOffsetForStage3;
   optParam[2].m_PointOffsetForAppend = PointOffsetForAppend3;
   optParam[2].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend3;
   optParam[2].m_AppendBackword = AppendBackword3;
   optParam[2].m_TakeProfitsPerLot = TakeProfitsPerLot3;
   optParam[2].m_TakeProfitsFacor = TakeProfitsFacor3;
   optParam[2].m_Backword = Backword3;
   
   optParam[3].m_BaseOpenLots = BaseOpenLots4;
   optParam[3].m_MultipleForAppend = Multiple4;
   optParam[3].m_MulipleFactorForAppend = MulipleFactorForAppend4;
   optParam[3].m_AppendMax = AppendMax4;
   optParam[3].m_PointOffsetForStage = PointOffsetForStage4;
   optParam[3].m_PointOffsetForAppend = PointOffsetForAppend4;
   optParam[3].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend4;
   optParam[3].m_AppendBackword = AppendBackword4;
   optParam[3].m_TakeProfitsPerLot = TakeProfitsPerLot4;
   optParam[3].m_TakeProfitsFacor = TakeProfitsFacor4;
   optParam[3].m_Backword = Backword4;
   
   optParam[4].m_BaseOpenLots = BaseOpenLots5;
   optParam[4].m_MultipleForAppend = Multiple5;
   optParam[4].m_MulipleFactorForAppend = MulipleFactorForAppend5;
   optParam[4].m_AppendMax = AppendMax5;
   optParam[4].m_PointOffsetForStage = PointOffsetForStage5;
   optParam[4].m_PointOffsetForAppend = PointOffsetForAppend5;
   optParam[4].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend5;
   optParam[4].m_AppendBackword = AppendBackword5;
   optParam[4].m_TakeProfitsPerLot = TakeProfitsPerLot5;
   optParam[4].m_TakeProfitsFacor = TakeProfitsFacor5;
   optParam[4].m_Backword = Backword5;
   
   string symbol = Symbol();
   // 1. 检查持仓情况
   if(!pMoBuy) {
      pMoBuy = new CMartinOrder(symbol, OP_BUY);
   }
   
   if(!pMoSell) {
      pMoSell = new CMartinOrder(symbol, OP_SELL);
   }
   int nBuyOrderCnt = pMoBuy.LoadAllOrders(optParam, StageMax);
   int nSellOrderCnt = pMoSell.LoadAllOrders(optParam, StageMax);
   
   int nStageBuy = pMoBuy.CalcStageNumber(nBuyOrderCnt, optParam, StageMax);
   int nAppendNumberBuy = pMoBuy.CalcAppendNumber(nStageBuy, nBuyOrderCnt, optParam, StageMax);
   
   int nStageSell = pMoSell.CalcStageNumber(nSellOrderCnt, optParam, StageMax);
   int nAppendNumberSell = pMoSell.CalcAppendNumber(nStageSell, nSellOrderCnt, optParam, StageMax);   

   double dBuyLots = pMoBuy.m_dLots;
   double dSellLots = pMoSell.m_dLots;
   
   if(nBuyOrderCnt == 0 && nSellOrderCnt == 0) {
       pMoBuy.OpenOrdersMicro(optParam, StageMax);
       pMoSell.OpenOrdersMicro(optParam, StageMax);
   }else {
      if(nBuyOrderCnt == 0)
      {
         if(!StopLongSide) {
            if(BaseOpenLotsInLoop && nAppendNumberSell == 2) {
               pMoBuy.OpenOrders(optParam, StageMax);
            } else {
               pMoBuy.OpenOrdersMicro(optParam, StageMax);
            }
         }
        
      }
      
      if(nSellOrderCnt == 0)
      {
         if(!StopShortSide) {
            if(BaseOpenLotsInLoop && nAppendNumberBuy == 2) {
               pMoSell.OpenOrders(optParam, StageMax);
            } else {
               pMoSell.OpenOrdersMicro(optParam, StageMax);
            }
         }
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
      dTakeProfitsBuy = (dPriceDiff / 0.0001) * 10 * (dBuyLotsStage) * optParam[nStageBuy].m_TakeProfitsFacor;
   }else {
      dTakeProfitsBuy = (PointOffsetForProfit / 0.0001) * 10 * dBuyLotsStage;
      if(dTakeProfitsBuy == 1) {
         dTakeProfitsBuy = 0;
      }
   }
  
   if(pMoBuy.CheckForClose(PointOffsetForProfit,  dTakeProfitsBuy, 
                              optParam[nStageBuy].m_Backword))
   {
      // 满足平仓条件，平掉本方向的订单
      if(nStageBuy == 0) {
         // 第一阶段或最后一个阶段，平全部订单
         pMoBuy.CloseOrders();
      }else {
         // 其余阶段，仅平掉本阶段的订单            
         pMoBuy.CloseOrders(nAppendNumberBuy);
      }
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      if(nStageBuy < StageMax) {
            OptParam param = optParam[nStageBuy];
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
                  pMoBuy.OpenOrders(optParam, StageMax);
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
      dTakeProfitsSell = (dPriceDiff / 0.0001) * 10 * (dSellLotsStage) * optParam[nStageSell].m_TakeProfitsFacor;
   }else {
      
      dTakeProfitsSell = (PointOffsetForProfit / 0.0001) * 10 * dSellLotsStage;
      if(nAppendNumberSell == 1) {
         dTakeProfitsSell = 0;
      }
   }
   
   if(pMoSell.CheckForClose(PointOffsetForProfit,dTakeProfitsSell, 
                              optParam[nStageSell].m_Backword)) {
                               // 满足平仓条件，平掉本方向的订单
      if(nStageSell == 0) {
         // 第一阶段或最后一个阶段，平全部订单
         pMoSell.CloseOrders();
      }else {
         // 其余阶段，仅平掉本阶段的订单            
         pMoSell.CloseOrders(nAppendNumberSell);
      }
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
       if(nStageSell < StageMax) {
            OptParam param = optParam[nStageSell];
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
                  pMoSell.OpenOrders(optParam, StageMax);
               }             
         }
      }
    
   }
   
   double currentEquity = AccountEquity(); // 净值
   if(currentEquity > mostEquity) {
      mostEquity = currentEquity;
   }     
   
   double baseTargetEquity = gBaseBalance * (1 + TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - BackwordForClose));
   if(EnableAutoCloseAll) {
       if(pMoSell.CheckForAutoCloseAll(gBaseBalance, preEquity, mostEquity, realTargetEquity)) {
         pMoSell.CloseOrders();
         pMoBuy.CloseOrders();
         gBaseBalance =  AccountEquity();
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
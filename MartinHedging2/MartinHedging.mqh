//+------------------------------------------------------------------+
//|                                                MartinHedging.mqh |
//|                                                          Cuilong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "https://www.mql5.com"
#property strict

#include "PubVar.mqh"
#include "MartinOrder.mqh"
#include "CheckZigZag.mqh"
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

CMartinOrder * pMoBuy = NULL;
CMartinOrder * pMoSell = NULL;

#define STAGE_MAX 5
bool PassOK = false;
   
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
   optParam[0].m_TakeProfitsPerOrder = TakeProfitsPerOrder1;
   optParam[0].m_TakeProfitsFacor = TakeProfitsFacor1;
   optParam[0].m_Backword = Backword1; 
   
   optParam[1].m_BaseOpenLots = BaseOpenLots2;
   optParam[1].m_MultipleForAppend = Multiple2;
   optParam[1].m_MulipleFactorForAppend = MulipleFactorForAppend2;
   optParam[1].m_AppendMax = AppendMax2;
   optParam[1].m_PointOffsetForStage = PointOffsetForStage2;
   optParam[1].m_PointOffsetForAppend = PointOffsetForAppend2;
   optParam[1].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend2;
   optParam[1].m_TakeProfitsPerOrder = TakeProfitsPerOrder2;
   optParam[1].m_TakeProfitsFacor = TakeProfitsFacor2;
   optParam[1].m_Backword = Backword2;
   
   optParam[2].m_BaseOpenLots = BaseOpenLots3;
   optParam[2].m_MultipleForAppend = Multiple3;
   optParam[2].m_MulipleFactorForAppend = MulipleFactorForAppend3;
   optParam[2].m_AppendMax = AppendMax3;
   optParam[2].m_PointOffsetForStage = PointOffsetForStage3;
   optParam[2].m_PointOffsetForAppend = PointOffsetForAppend3;
   optParam[2].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend3;
   optParam[2].m_TakeProfitsPerOrder = TakeProfitsPerOrder3;
   optParam[2].m_TakeProfitsFacor = TakeProfitsFacor3;
   optParam[2].m_Backword = Backword3;
   
   optParam[3].m_BaseOpenLots = BaseOpenLots4;
   optParam[3].m_MultipleForAppend = Multiple4;
   optParam[3].m_MulipleFactorForAppend = MulipleFactorForAppend4;
   optParam[3].m_AppendMax = AppendMax4;
   optParam[3].m_PointOffsetForStage = PointOffsetForStage4;
   optParam[3].m_PointOffsetForAppend = PointOffsetForAppend4;
   optParam[3].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend4;
   optParam[3].m_TakeProfitsPerOrder = TakeProfitsPerOrder4;
   optParam[3].m_TakeProfitsFacor = TakeProfitsFacor4;
   optParam[3].m_Backword = Backword4;
   
   optParam[4].m_BaseOpenLots = BaseOpenLots5;
   optParam[4].m_MultipleForAppend = Multiple5;
   optParam[4].m_MulipleFactorForAppend = MulipleFactorForAppend5;
   optParam[4].m_AppendMax = AppendMax5;
   optParam[4].m_PointOffsetForStage = PointOffsetForStage5;
   optParam[4].m_PointOffsetForAppend = PointOffsetForAppend5;
   optParam[4].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend5;
   optParam[4].m_TakeProfitsPerOrder = TakeProfitsPerOrder5;
   optParam[4].m_TakeProfitsFacor = TakeProfitsFacor5;
   optParam[4].m_Backword = Backword5;
   
   // 1. 检查持仓情况
   if(!pMoBuy) {
      pMoBuy = new CMartinOrder(SYMBOL1, SYMBOL2, OP_BUY, TimeFrame, optParam);
   }
   
   if(!pMoSell) {
      pMoSell = new CMartinOrder(SYMBOL1, SYMBOL2, OP_SELL, TimeFrame, optParam);
   }
   int nBuyOrderCnt = pMoBuy.LoadAllOrders(optParam, StageMax);
   int nSellOrderCnt = pMoSell.LoadAllOrders(optParam, StageMax);

   if(nBuyOrderCnt == 0)
   {
      if(!StopLongSide) {
         if(EnableTradingTime) {
            if(IsBetweenTime(OpenOrderStartTime, OpenOrderEndTime)) {
               if(BaseOpenCheckReversOrder && nSellOrderCnt == 2) 
               {
                  int nOrderCnt = 1; // MathMax(1, (OrderMax - nSellOrderCnt) / 2);
                  //pMoBuy.OpenOrders(nOrderCnt);
                  pMoBuy.OpenOrders(nOrderCnt, optParam, StageMax);
               } else 
               {  
                  pMoBuy.OpenOrdersEx(OpenMicroLots, optParam, StageMax);
               }
            }
         }else {
            if(BaseOpenCheckReversOrder && nSellOrderCnt == 2) 
            {
               int nOrderCnt = 1; // MathMax(1, (OrderMax - nSellOrderCnt) / 2);
               //pMoBuy.OpenOrders(nOrderCnt);
               pMoBuy.OpenOrders(nOrderCnt, optParam, StageMax);
            } else 
            {  
               pMoBuy.OpenOrdersEx(OpenMicroLots, optParam, StageMax);
            }
         }
      }
   }
   if(nSellOrderCnt == 0)
   {
      if(!StopShortSide) {
         if(EnableTradingTime) {
            if(IsBetweenTime(OpenOrderStartTime, OpenOrderEndTime)) {
               if(BaseOpenCheckReversOrder && nBuyOrderCnt == 2) 
               {
                  int nOrderCnt = 1; //MathMax(1, (OrderMax - nBuyOrderCnt) / 2);
                  // pMoSell.OpenOrders(nOrderCnt);
                  pMoSell.OpenOrders(nOrderCnt, optParam, StageMax);
               } else 
               {
                  pMoSell.OpenOrdersEx(OpenMicroLots, optParam, StageMax);
               }
            }
         }else {
            if(BaseOpenCheckReversOrder && nBuyOrderCnt == 2) 
            {
               int nOrderCnt = 1; //MathMax(1, (OrderMax - nBuyOrderCnt) / 2);
               // pMoSell.OpenOrders(nOrderCnt);
               pMoSell.OpenOrders(nOrderCnt, optParam, StageMax);
            } else 
            {
               pMoSell.OpenOrdersEx(OpenMicroLots, optParam, StageMax);
            }
         }
      }
   }
   // 2. 检查平仓条件
   if(nBuyOrderCnt > 0) {   
      int nStageBuy = pMoBuy.CalcStageNumber(nBuyOrderCnt, optParam, StageMax);
      int nAppendNumberBuy = pMoBuy.CalcAppendNumber(nStageBuy, nBuyOrderCnt, optParam, StageMax);
      double dTakeProfitsBuy = 0;
      if(nStageBuy == 0 || (CheckAllOrdersInLastStage && nStageBuy == StageMax - 1)) {
           dTakeProfitsBuy = optParam[nStageBuy].m_TakeProfitsPerOrder * nBuyOrderCnt * optParam[nStageBuy].m_TakeProfitsFacor;
           if(nStageBuy == 0 && nAppendNumberBuy == 1) {
               dTakeProfitsBuy = 0;
           }
      }else {
           dTakeProfitsBuy = optParam[nStageBuy].m_TakeProfitsPerOrder * nAppendNumberBuy * optParam[nStageBuy].m_TakeProfitsFacor;
           if(nAppendNumberBuy == 1) {
               dTakeProfitsBuy = 0;
           }
      }
      
      if(pMoBuy.CheckForClose1(PointOffsetForProfit, 
                                 dTakeProfitsBuy, 
                                 optParam[nStageBuy].m_Backword))
       {
            // 满足平仓条件，平掉本方向的订单
            if(nStageBuy == 0 || (CheckAllOrdersInLastStage && nStageBuy == StageMax - 1)) {
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
               if(pMoBuy.CheckForAppend(dOffset, factor, param.m_Backword, nAppendNumberBuy, bFactor))
               //if(pMoBuy.CheckForAppendByOffset(PointOffsetForAppend))
               {
                  LogInfo("+++++++++++++++ Buy Append ++++++++++++++++++++++++++++++++++");
                  string logMsg = StringFormat("多方加仓：offset = %s, Stage = %d, AppendNumber = %d.", 
                           DoubleToString(dOffset, 4),
                           nStageBuy + 1, nAppendNumberBuy); 
                  PrintFormat(logMsg);
                   // 5. 满足加仓条件，则加仓
                    pMoBuy.OpenOrdersEx(false, optParam, StageMax);
               }
            }     
      }     
   
   }
   
   if(nSellOrderCnt > 0) {
      int nStageSell = pMoSell.CalcStageNumber(nSellOrderCnt, optParam, StageMax);
      int nAppendNumberSell = pMoSell.CalcAppendNumber(nStageSell, nSellOrderCnt, optParam, StageMax);
      double dTakeProfitsSell = optParam[nStageSell].m_TakeProfitsPerOrder * nSellOrderCnt * optParam[nStageSell].m_TakeProfitsFacor;
      if(nStageSell == 0 || (CheckAllOrdersInLastStage && nStageSell == StageMax - 1)) {
         dTakeProfitsSell = optParam[nStageSell].m_TakeProfitsPerOrder * nSellOrderCnt * optParam[nStageSell].m_TakeProfitsFacor;
          if(nStageSell == 0 && nAppendNumberSell == 1) {
               dTakeProfitsSell = 0;
          }
      }else {
         dTakeProfitsSell = optParam[nStageSell].m_TakeProfitsPerOrder * nAppendNumberSell * optParam[nStageSell].m_TakeProfitsFacor;
         if(nAppendNumberSell == 1) {
               dTakeProfitsSell = 0;
         }
      }
         
      if(pMoSell.CheckForClose1(PointOffsetForProfit, 
                                 dTakeProfitsSell, 
                                 optParam[nStageSell].m_Backword))
      {
         if(nStageSell == 0 || (CheckAllOrdersInLastStage && nStageSell == StageMax - 1)) {
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
            bool bFactor = true;
            if(nAppendNumberSell >= param.m_AppendMax) {
               dOffset = param.m_PointOffsetForStage;
               factor = 1.0;
               bFactor = false;
            }  
            if(nAppendNumberSell == 1) {
               bFactor = false;
            }
                   
            if(pMoSell.CheckForAppend(dOffset, factor, param.m_Backword, nAppendNumberSell, bFactor))
            //if(pMoSell.CheckForAppendByOffset(PointOffsetForAppend))//, DeficitForAppend, Backword))
            {
                  LogInfo("+++++++++++++++ Sell Append ++++++++++++++++++++++++++++++++++");
                  string logMsg = StringFormat("空方加仓：offset = %s, Stage = %d, AppendNumber = %d.", 
                           DoubleToString(dOffset, 4),
                           nStageSell + 1, nAppendNumberSell); 
                  PrintFormat(logMsg);
                // 5. 满足加仓条件，则加仓
                 pMoSell.OpenOrdersEx(false, optParam, StageMax);
            }
         }
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
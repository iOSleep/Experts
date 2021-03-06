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
   
   // 1. 检查持仓情况
   if(!pMoBuy) {
      pMoBuy = new CMartinOrder(SYMBOL1, SYMBOL2, OP_BUY, TimeFrame, BaseOpenLots, Overweight_Multiple, 
                     MulipleFactorForAppend, 
                     Overweight_MultipleManual,  MulipleFactorForAppendManual,
                     OrderMax, OrderMaxAuto, LotsForAppendManual);
   }
   
   if(!pMoSell) {
      pMoSell = new CMartinOrder(SYMBOL1, SYMBOL2, OP_SELL, TimeFrame, BaseOpenLots, Overweight_Multiple,
                      MulipleFactorForAppend, 
                      Overweight_MultipleManual,  MulipleFactorForAppendManual,
                      OrderMax, OrderMaxAuto, LotsForAppendManual);
   }
   int nBuyOrderCnt = pMoBuy.LoadAllOrders();
   int nSellOrderCnt = pMoSell.LoadAllOrders();

   if(nBuyOrderCnt == 0)
   {
      if(!StopLongSide) {
         if(EnableTradingTime) {
            if(IsBetweenTime(OpenOrderStartTime, OpenOrderEndTime)) {
               if(BaseOpenCheckReversOrder && nSellOrderCnt == 2) 
               {
                  int nOrderCnt = 1; // MathMax(1, (OrderMax - nSellOrderCnt) / 2);
                  //pMoBuy.OpenOrders(nOrderCnt);
                  pMoBuy.OpenOrders(nOrderCnt);
               } else 
               {  
                  pMoBuy.OpenOrders(OpenMicroLots);
               }
            }
         }else {
            if(BaseOpenCheckReversOrder && nSellOrderCnt == 2) 
            {
               int nOrderCnt = 1; // MathMax(1, (OrderMax - nSellOrderCnt) / 2);
               //pMoBuy.OpenOrders(nOrderCnt);
               pMoBuy.OpenOrders(nOrderCnt);
            } else 
            {  
               pMoBuy.OpenOrders(OpenMicroLots);
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
                  pMoSell.OpenOrders(nOrderCnt);
               } else 
               {
                  pMoSell.OpenOrders(OpenMicroLots);
               }
            }
         }else {
            if(BaseOpenCheckReversOrder && nBuyOrderCnt == 2) 
            {
               int nOrderCnt = 1; //MathMax(1, (OrderMax - nBuyOrderCnt) / 2);
               // pMoSell.OpenOrders(nOrderCnt);
               pMoSell.OpenOrders(nOrderCnt);
            } else 
            {
               pMoSell.OpenOrders(OpenMicroLots);
            }
         }
      }
   }
   // 2. 检查平仓条件
   double dTakeProfits = TakeProfits;
   if(DynamicTakeProfits) {
      dTakeProfits = TakeProfitsPerOrder * nBuyOrderCnt * TakeProfitsFacor;
   }
   
   if(pMoBuy.CheckForClose1(PointOffsetForProfit, dTakeProfits, Backword))
   {
      // 满足平仓条件，平掉本方向的订单
      pMoBuy.CloseOrders();
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      double dPointOffsetForAppend = PointOffsetForAppend;
      double dFactorForAppend = FactorForAppend;
      
      if(nBuyOrderCnt >= OrderMaxAuto) {
         dPointOffsetForAppend = PointOffsetForAppendManual;
         dFactorForAppend = 1.0;
      }
      
      if(pMoBuy.CheckForAppend(dPointOffsetForAppend, dFactorForAppend, Backword))
      //if(pMoBuy.CheckForAppendByOffset(PointOffsetForAppend))
      {
          // 5. 满足加仓条件，则加仓
           pMoBuy.OpenOrders(false);
      }
   
     
   }
   
   dTakeProfits = TakeProfits;
   if(DynamicTakeProfits) {
      dTakeProfits = TakeProfitsPerOrder * nSellOrderCnt * TakeProfitsFacor;
   }
   
   if(pMoSell.CheckForClose1(PointOffsetForProfit, dTakeProfits, Backword))
   {
      pMoSell.CloseOrders();
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      double dPointOffsetForAppend = PointOffsetForAppend;
      double dFactorForAppend = FactorForAppend;
      
      if(nSellOrderCnt >= OrderMaxAuto) {
         dPointOffsetForAppend = PointOffsetForAppendManual;
         dFactorForAppend = 1.0;
      }
      if(pMoSell.CheckForAppend(dPointOffsetForAppend, dFactorForAppend, Backword))
      //if(pMoSell.CheckForAppendByOffset(PointOffsetForAppend))//, DeficitForAppend, Backword))
      {
          // 5. 满足加仓条件，则加仓
           pMoSell.OpenOrders(false);
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
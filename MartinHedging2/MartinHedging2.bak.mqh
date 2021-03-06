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
   
void Main()
{
   if(IsExpired()) {
      return;
   }
   
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
      pMoBuy = new CMartinOrder(SYMBOL1, SYMBOL2, OP_BUY, TimeFrame, BaseOpenLots, Overweight_Multiple, MulipleFactorForAppend, OrderMax);
   }
   
   if(!pMoSell) {
      pMoSell = new CMartinOrder(SYMBOL1, SYMBOL2, OP_SELL, TimeFrame, BaseOpenLots, Overweight_Multiple, MulipleFactorForAppend, OrderMax);
   }
   int nBuyOrderCnt = pMoBuy.LoadAllOrders();
   int nSellOrderCnt = pMoSell.LoadAllOrders();
   int nTrend = CheckTrend(gPreTrend, SYMBOL1, SYMBOL2);
   
   if(nBuyOrderCnt == 0 || nSellOrderCnt == 0) {
      int nDirect = CheckForOpen(gPreTrend, nTrend, SYMBOL1, SYMBOL2);
     
      if(nBuyOrderCnt == 0 && nDirect == OP_BUY)
      {     
        pMoBuy.OpenOrders();
      }
      
      if(nSellOrderCnt == 0 && nDirect == OP_SELL) {
        pMoSell.OpenOrders();
      }
   }
   
   if(nBuyOrderCnt > 0) {
   
      // 2. 检查平仓条件
      // 以下为根据zigzag指标 + 获利回调的平仓条件
      //bool bClose = pMoBuy.CheckForCloseByOffset(PointOffsetForProfit);
      //pMoBuy.CheckForCloseByProfits(TakeProfits, Backword);
      //if(bClose && OP_BUY == CheckForClose(gPreTrend, nTrend, SYMBOL1, SYMBOL2))
      
      // 以下为根据点数 + 获利回调的平仓条件
      bool bClose1 = pMoBuy.CheckForClose(PointOffsetForProfit, TakeProfits, Backword);
      bool bClose2 = (OP_BUY == CheckForClose(gPreTrend, nTrend, SYMBOL1, SYMBOL2));
      if(bClose1 && bClose2)
      {
         pMoBuy.CloseOrders();
      }else
      {
         // 4. 不满足平仓条件，则检查加仓条件
         bool bAppend = pMoBuy.CheckForAppend(PointOffsetForAppend, FactorForAppend, Backword);
         //if(pMoBuy.CheckForAppendByOffset(PointOffsetForAppend))
         if(pMoBuy.CheckForAppendEx(PointOffsetForAppend, FactorForAppend) 
               && OP_BUY == CheckForOpen(gPreTrend, nTrend, SYMBOL1, SYMBOL2)
               )
         {
             // 5. 满足加仓条件，则加仓
              pMoBuy.OpenOrders();
         }
      }
   } 
   
   if(nSellOrderCnt > 0) { 
      // 以下为根据zigzag指标 + 获利回调的平仓条件  
      //bool bClose = pMoSell.CheckForCloseByOffset(PointOffsetForProfit);
      //pMoSell.CheckForCloseByProfits(TakeProfits, Backword);
      //if(bClose && OP_SELL == CheckForClose(gPreTrend, nTrend, SYMBOL1, SYMBOL2))
      
      // 以下为根据点数 + 获利回调 + zigzag 的平仓条件
      bool bClose1 = pMoSell.CheckForClose(PointOffsetForProfit, TakeProfits, Backword);
      bool bClose2 = (OP_SELL == CheckForClose(gPreTrend, nTrend, SYMBOL1, SYMBOL2));
      if(bClose1 && bClose2)
      {
         pMoSell.CloseOrders();
      }else
      {
         // 4. 不满足平仓条件，则检查加仓条件
         bool bAppend = pMoSell.CheckForAppend(PointOffsetForAppend, FactorForAppend, Backword);
         //if(pMoSell.CheckForAppendByOffset(PointOffsetForAppend))//, DeficitForAppend, Backword))
         if(pMoSell.CheckForAppendEx(PointOffsetForAppend, FactorForAppend) 
               && OP_SELL == CheckForOpen(gPreTrend, nTrend, SYMBOL1, SYMBOL2)
            )
         {
             // 5. 满足加仓条件，则加仓
              pMoSell.OpenOrders();
         }
      }
   }
   
   gPreTrend = nTrend; 
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
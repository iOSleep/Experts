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
   if(nBuyOrderCnt == 0)
   {
      pMoBuy.OpenOrders();
   }
   
   if(nSellOrderCnt == 0)
   {
      pMoSell.OpenOrders();
   }
   // 2. 检查平仓条件
   if(pMoBuy.CheckForClose(PointOffsetForProfit, TakeProfits, Backword))
   {
      pMoBuy.CloseOrders();
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      if(pMoBuy.CheckForAppend(PointOffsetForAppend, FactorForAppend, Backword))
      //if(pMoBuy.CheckForAppendByOffset(PointOffsetForAppend))
      {
          // 5. 满足加仓条件，则加仓
           pMoBuy.OpenOrders();
      }
   
     
   }
   
   if(pMoSell.CheckForClose(PointOffsetForProfit, TakeProfits, Backword))
   {
      pMoSell.CloseOrders();
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      if(pMoSell.CheckForAppend(PointOffsetForAppend, FactorForAppend, Backword))
      //if(pMoSell.CheckForAppendByOffset(PointOffsetForAppend))//, DeficitForAppend, Backword))
      {
          // 5. 满足加仓条件，则加仓
           pMoSell.OpenOrders();
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
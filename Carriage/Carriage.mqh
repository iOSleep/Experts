//+------------------------------------------------------------------+
//|                                                MartinHedging.mqh |
//|                                                          Cuilong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "https://www.mql5.com"
#property strict

#include "PubVar.mqh"
#include "CarriageOrder.mqh"
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

CCarriageOrder * pBuyCarriage = NULL;
CCarriageOrder * pSellCarriage = NULL;
   
void Main()
{  
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
   
   string symbol = Symbol();
   // 1. 检查持仓情况
   if(!pBuyCarriage) {
      pBuyCarriage = new CCarriageOrder(symbol, OP_BUY, MAGIC_NUM, BASE_OPEN_LOTS);
   }
   
   if(!pSellCarriage) {
      pSellCarriage = new CCarriageOrder(symbol, OP_SELL, MAGIC_NUM, BASE_OPEN_LOTS);
   }
   
   // 装入当前持仓
   pBuyCarriage.LoadAllOrders();
   pSellCarriage.LoadAllOrders();
    
   if(!pBuyCarriage.hasOrder()) {
       // 还没有开仓，开轻仓
       pBuyCarriage.OpenOrder(true);
   }else {
       double dLots = pBuyCarriage.m_orderInfo.m_Lots;
       double dTakeProfits = (OFFSET_HEAVY_PROFIT / 0.0001) * 10 * dLots;
       pBuyCarriage.ProcessOrder(OFFSET_HEAVY_TO_LIGHT, OFFSET_LIGHT_TO_HEAVY, OFFSET_HEAVY_PROFIT, BASE_CLOSE_BACKWORD, dTakeProfits);
   }
   
   if(!pSellCarriage.hasOrder()) {
      pSellCarriage.OpenOrder(true);
   }   
   else {
      double dLots = pSellCarriage.m_orderInfo.m_Lots;
      double dTakeProfits = (OFFSET_HEAVY_PROFIT / 0.0001) * 10 * dLots;
      pSellCarriage.ProcessOrder(OFFSET_HEAVY_TO_LIGHT, OFFSET_LIGHT_TO_HEAVY, OFFSET_HEAVY_PROFIT, BASE_CLOSE_BACKWORD, dTakeProfits);
   }

   gTickCount++;
}

void Destroy()
{
   if(pBuyCarriage) {
      delete pBuyCarriage; 
      pBuyCarriage = NULL;
   }
   
    if(pSellCarriage) {
       delete pSellCarriage;
       pSellCarriage = NULL;
   }
}
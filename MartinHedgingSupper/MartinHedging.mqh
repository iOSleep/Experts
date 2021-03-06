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
      pMoBuy = new CMartinOrder(SYMBOL1, SYMBOL2, OP_BUY, TimeFrame, BaseOpenLots, Overweight_Multiple, MulipleFactorForAppend, OrderMax);
   }
   
   if(!pMoSell) {
      pMoSell = new CMartinOrder(SYMBOL1, SYMBOL2, OP_SELL, TimeFrame, BaseOpenLots, Overweight_Multiple, MulipleFactorForAppend, OrderMax);
   }
   int nBuyOrderCnt = pMoBuy.LoadAllOrders();
   int nSellOrderCnt = pMoSell.LoadAllOrders();
   double dBuyLots = pMoBuy.m_dLots2;
   double dSellLots = pMoSell.m_dLots2;

   if(nBuyOrderCnt == 0 && nSellOrderCnt == 0)
   {
      pMoBuy.OpenOrdersMicro();
      pMoSell.OpenOrdersMicro();
   }else {
      if(nBuyOrderCnt == 0) {
           double dLastSellPrice = pMoSell.GetPriceLastOrder();
           RefreshRates();
           // 此时需要获取两种货币对的买价          
           double dAskPrice1 = MarketInfo(SYMBOL1, MODE_ASK);
           double dAskPrice2 = MarketInfo(SYMBOL2, MODE_ASK);
           double dCurrentPrice =  dAskPrice2 - dAskPrice1;
         
            if(dCurrentPrice > dLastSellPrice) {
               // 如果当前价格比空单的最近一次的价格还要高，则开微手0.01手的单
               pMoBuy.OpenOrdersMicro();
            }else {
               // pMoBuy.OpenOrders();
               pMoBuy.OpenOrdersMicro();
            }
      }
      
      if(nSellOrderCnt == 0)
      {
           double dLastSellPrice = pMoBuy.GetPriceLastOrder();
           RefreshRates();
           // 此时需要获取两种货币对的卖价          
           double dBidPrice1 = MarketInfo(SYMBOL1, MODE_BID);
           double dBidPrice2 = MarketInfo(SYMBOL2, MODE_BID);
           double dCurrentPrice =  dBidPrice2 - dBidPrice1;
         
            if(dCurrentPrice < dLastSellPrice) {
               // 如果当前价格比多单的最近一次的价格还要低，则开微手0.01手的单
               pMoSell.OpenOrdersMicro();
            }else {
               // pMoSell.OpenOrders();
               pMoSell.OpenOrdersMicro();
            }
      }
   }
   // 2. 检查平仓条件
   double dTakeProfits = TakeProfits;
   if(DynamicTakeProfits) {
      if(nBuyOrderCnt > 1) {
         double dPriceDiff = PointOffsetForAppend * (nBuyOrderCnt - 1);
         dTakeProfits = (dPriceDiff / 0.0001) * 10 * dBuyLots * TakeProfitsFacor;
      }else {
         dTakeProfits = (PointOffsetForProfit / 0.0001) * 10 * dBuyLots;
      }
   }
   
   if(pMoBuy.CheckForClose1(PointOffsetForProfit, dTakeProfits, BackwordForProfits))
   {
      // 满足平仓条件，平掉本方向的订单
      pMoBuy.CloseOrders();
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      if(pMoBuy.CheckForAppend(PointOffsetForAppend, FactorForAppend, BackwordForAppend))
      //if(pMoBuy.CheckForAppendByOffset(PointOffsetForAppend))
      {
          // 5. 满足加仓条件，则加仓
           pMoBuy.OpenOrders();
      }
   }
   
   dTakeProfits = TakeProfits;
   if(DynamicTakeProfits) {
      if(nSellOrderCnt > 1) {
         double dPriceDiff = PointOffsetForAppend * (nSellOrderCnt - 1);
         dTakeProfits = (dPriceDiff / 0.0001) * 10 * dSellLots * TakeProfitsFacor;
      }else {
         dTakeProfits = (PointOffsetForProfit / 0.0001) * 10 * dSellLots;
      }
      
   }
   
   if(pMoSell.CheckForClose1(PointOffsetForProfit, dTakeProfits, BackwordForProfits))
   {
      pMoSell.CloseOrders();
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      if(pMoSell.CheckForAppend(PointOffsetForAppend, FactorForAppend, BackwordForAppend))
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
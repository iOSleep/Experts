//+------------------------------------------------------------------+
//|                                                    OrderUtil.mqh |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
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
#include "OrderInfo.mqh"
#include "3MAUtil.mqh"
#include "3MAPubVar.mqh"

#define MAX_ORDER_COUNT 20

input int BuyMagic = 10000;
input int SellMagic = 20000;

int gBuyOrdersCount = 0;
COrderInfo buyOrders[MAX_ORDER_COUNT];
datetime  gLastBuyOrderTime = 0;
double gBuyTotalLots = 0;

// Sell orders data
int gSellOrdersCount = 0;
COrderInfo sellOrders[MAX_ORDER_COUNT];
datetime  gLastSellOrderTime = 0;
double gSellTotalLots = 0;

int QueryCurrentOrders(int orderType)
{
   int nOrdersCnt = 0;
   
   if(orderType == OP_BUY)
   {
       CleanBuyOrdersCache(); 
   }
   
   if(orderType == OP_SELL)
   {
      CleanSellOrdersCache(); 
   }
   
   int nBuyMagic = BuyMagic + TimeFrame;
   int nSellMagic = SellMagic + TimeFrame;
    
   int nOrdersTotalCnt = OrdersTotal();
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() 
            && (OrderMagicNumber() == nBuyMagic || OrderMagicNumber() == nSellMagic)
            && OrderType() == orderType)
         {
            switch(orderType)
            {
            case OP_BUY: 
               buyOrders[gBuyOrdersCount].m_Ticket = OrderTicket(); 
               buyOrders[gBuyOrdersCount].m_Prices = OrderClosePrice();
               buyOrders[gBuyOrdersCount].m_Lots = OrderLots();
               buyOrders[gBuyOrdersCount].m_Comment = OrderComment();
               buyOrders[gBuyOrdersCount].m_OrderType = orderType;
               buyOrders[gBuyOrdersCount].m_TradeTime = OrderOpenTime();
               if(gLastBuyOrderTime < OrderOpenTime())
               {
                  gLastBuyOrderTime = OrderOpenTime();
               }
               gBuyTotalLots += OrderLots();
               gBuyOrdersCount++;
               nOrdersCnt++;
               break;
            case OP_SELL:
               sellOrders[gSellOrdersCount].m_Ticket = OrderTicket();
               sellOrders[gSellOrdersCount].m_Prices = OrderClosePrice();
               sellOrders[gSellOrdersCount].m_Lots = OrderLots();
               sellOrders[gSellOrdersCount].m_Comment = OrderComment();
               sellOrders[gSellOrdersCount].m_OrderType = orderType;
               sellOrders[gSellOrdersCount].m_TradeTime = OrderOpenTime();
               if(gLastSellOrderTime < OrderOpenTime())
               {
                  gLastSellOrderTime = OrderOpenTime();
               }
               gSellTotalLots += OrderLots();
               gSellOrdersCount++;
               nOrdersCnt++;
               break;             
            }
         }
      }
   }
   return nOrdersCnt;
}

void CleanBuyOrdersCache() 
{
   int i = 0;
   for(i = 0; i < gBuyOrdersCount; i++)
   {
      buyOrders[i].clear();
   }
   gBuyOrdersCount = 0;
   gLastBuyOrderTime = 0;
   gBuyTotalLots = 0;
}

void CleanSellOrdersCache() 
{
   int i = 0;
   for(i = 0; i < gSellOrdersCount; i++)
   {
      sellOrders[i].clear();
   }
   gSellOrdersCount = 0;
   gLastSellOrderTime = 0;
   gSellTotalLots = 0;
}

void CleanOrdersCache() 
{
   CleanBuyOrdersCache(); 
   CleanSellOrdersCache();
}

int OpenOrder(int orderType)
{
   int ret = 0;
   string logMsg;
   
   double accMargin = AccountMargin();
   double freeMargin = AccountFreeMargin();
   
   int nBuyMagic = BuyMagic + TimeFrame;
   int nSellMagic = SellMagic + TimeFrame;
   
   if(CheckFreeMargin && accMargin / freeMargin > 0.3) {
        logMsg = StringFormat("%s => Free margin not enouth: margin = %s, free margin = %s.",
                        __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(freeMargin,3));
        LogWarn(logMsg); 
        return -1; 
   }
   
   datetime now = iTime(Symbol(), TimeFrame, 0);
   RefreshRates();
   switch(orderType)
   {
   case OP_BUY:
      if(gBuyOrdersCount < OrderMax 
            && now > gLastBuyOrderTime
            && gBuyTotalLots <= MaxHoldingLots)
      {
         // Open buy order
         double lots = BaseOpenLots;
         if(gBuyOrdersCount > 0)
         {
            lots = NormalizeDouble(BaseOpenLots * MathPow(Overweight_Multiple, gBuyOrdersCount), 2);
         }
         while(true)
         {
            RefreshRates();
            int ticket = OrderSend(Symbol(), OP_BUY, lots, Ask, 3, 0, 0, "SimpleEA order", nBuyMagic, 0, clrGreenYellow); 
            if(ticket > 0)
            {
               logMsg = __FUNCTION__ + ": type = OP_BUY"
                           + ", price = " + DoubleToString(Ask) 
                           + ", lots = " + DoubleToString(lots);
               LogInfo(logMsg);
               break;
            }else 
            { 
               int nErr = GetLastError(); 
               logMsg = StringFormat("%s => Open buy order Error: %d.", __FUNCTION__, nErr);
               LogInfo(logMsg);
               if(IsFatalError(nErr))
               {  
                  ret = nErr;
                  break;
               } 
            }
         }
         
      }
      break;
   case OP_SELL:
      if(gSellOrdersCount < OrderMax 
            && now > gLastSellOrderTime
            && gSellTotalLots <= MaxHoldingLots)
      {
         // Open sell order
         double lots = BaseOpenLots;
         if(gSellOrdersCount > 0)
         {
            lots = NormalizeDouble(BaseOpenLots * MathPow(Overweight_Multiple, gSellOrdersCount), 2);
         }
         
         while(true)
         {
            RefreshRates();
            int ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, 3, 0, 0, "SimpleEA order", nSellMagic, 0, clrRed); 
            if(ticket > 0) 
            {
                logMsg = __FUNCTION__ + ": type = OP_SELL"
                           + ", price = " + DoubleToString(Bid) 
                           + ", lots = " + DoubleToString(lots);
                LogInfo(logMsg);
                break;
            }else
            { 
               int nErr = GetLastError(); 
               logMsg = StringFormat("%s => Open sell order Error: %d.", __FUNCTION__, nErr);
               LogInfo(logMsg);
               if(IsFatalError(nErr))
               {  
                  ret = nErr;
                  break;
               } 
            } 
         }
         
      }
      break;
   }
   return ret;
}

int CloseOrders(int orderType)
{
   int ret = 0;
   string logMsg;
   if(orderType == OP_BUY)
   {
      for(int i = 0; i < gBuyOrdersCount;i++)
      {
         double lots = buyOrders[i].m_Lots;
         int ticket = buyOrders[i].m_Ticket;
         if(ticket > 0)
         {
            while(true)
            {
               RefreshRates();
               if(OrderClose(ticket, lots, Bid, 3, clrGainsboro))
               {
                  logMsg = __FUNCTION__ + ": ticket = " + IntegerToString(ticket) 
                           + ", type = OP_BUY"
                           + ", price = " + DoubleToString(Bid) 
                           + ", lots = " + DoubleToString(lots);
                  LogInfo(logMsg);
                  break;
            
               } else
               {
                  int nErr = GetLastError(); // 平仓失败 :( 
                  logMsg = StringFormat("%s => Close buy order Error: %d.", __FUNCTION__, nErr);
                  LogInfo(logMsg);
                  if(IsFatalError(nErr))
                  {  
                     ret = nErr;
                     break;
                  }                   
              }
            }  
         }
       }  
   }
   
   if(orderType == OP_SELL)
   {
      for(int i = 0; i < gSellOrdersCount; i++)
      {
         double lots = sellOrders[i].m_Lots;
         int ticket = sellOrders[i].m_Ticket;
         if(ticket > 0)
         {
            while(true)
            {
               RefreshRates();
               if(OrderClose(ticket, lots, Ask, 3, clrRed))
               {
                  logMsg = __FUNCTION__ + ": ticket = " + IntegerToString(ticket) 
                           + ", type = OP_BUY"
                           + ", price = " + DoubleToString(Ask) 
                           + ", lots = " + DoubleToString(lots);
                  LogInfo(logMsg);
                  break;
               } else
               {
                  int nErr = GetLastError(); // 平仓失败 :( 
                  logMsg = StringFormat("%s => Close buy order Error: %d.", __FUNCTION__, nErr);
                  LogInfo(logMsg);
                  if(IsFatalError(nErr))
                  {  
                     ret = nErr;
                     break;
                  }                   
              }
            }            
         }
      }
   }
   return ret;
}
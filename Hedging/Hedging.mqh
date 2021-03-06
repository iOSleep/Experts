//+------------------------------------------------------------------+
//|                                                      hedging.mqh |
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

#include "CheckZigZag.mqh"
#include "OrderUtil.mqh"

void Main()
{
   if(IsExpired()) 
   {
      return;
   }
   
   gTickCount++;
   bool bIsNewBar = IsNewBar();
   if(!gIsNewBar && bIsNewBar)
   {
      gIsNewBar = bIsNewBar;
   }else
   {
      gIsNewBar = false;
   }
   
   int nTrend = CheckTrend(gPreTrend);
   
   string logMsg;
   
   // 1. orders accounting
   int buyOrdersCnt = 0;
   int sellOrdersCnt = 0;
   int nMainDirect = -1;
   
   // 以货币对2作为主货币对，考虑其买卖单的方向
   // 先查询货币对2的所有买单
   buyOrdersCnt = QueryCurrentOrders(PRD2, OP_BUY);
   if(buyOrdersCnt > 0)
   {
      // 如果货币对2有买单，那么查询货币对1的卖单
      nMainDirect = OP_BUY;
      sellOrdersCnt = QueryCurrentOrders(PRD1, OP_SELL);
   }else 
   {
      // 如果货币对2没有买单，那么查询货币对2的卖单
      sellOrdersCnt = QueryCurrentOrders(PRD2, OP_SELL);
      if(sellOrdersCnt > 0)
      {
         nMainDirect = OP_SELL;
         // 如果货币对2有卖单，那么查询货币对1的买单
         buyOrdersCnt = QueryCurrentOrders(PRD1, OP_BUY);
      }
   }
      
   if(nMainDirect == -1)
   {
      int nDirect = CheckForOpenEx(gPreTrend, nTrend);
      if(nDirect == OP_BUY)
      {
         // Open buy order
         double dLots = BaseOpenLots;
         if(buyOrdersCnt > 0)
         {
            dLots = NormalizeDouble(BaseOpenLots * MathPow(Overweight_Multiple, buyOrdersCnt), 2);
         }
         double fPrice2 = MarketInfo(PRD2, MODE_ASK);
         double fPrice1 = MarketInfo(PRD1, MODE_BID);
         
         logMsg = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> BUY >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
         LogInfo(logMsg); 
         
         logMsg = StringFormat("Prepare to open buy order ==> buyOrdersCnt = %d, Lots = %s, Price2 = %s, Price1 = %s, Offset = %s", 
                     buyOrdersCnt, DoubleToString(dLots, 2), 
                     DoubleToString(fPrice2, 4), DoubleToString(fPrice1, 4), 
                     DoubleToString(fPrice2 - fPrice1, 4));
         LogInfo(logMsg); 
         OpenOrder(PRD2, OP_BUY, BuyComment, dLots);
         OpenOrder(PRD1, OP_SELL, BuyComment, dLots);
      } 
      
      if(nDirect == OP_SELL)
      {
         // Open sell order
         double dLots = BaseOpenLots;
         if(sellOrdersCnt > 0)
         {
            dLots = NormalizeDouble(BaseOpenLots * MathPow(Overweight_Multiple, sellOrdersCnt), 2);
         }
         
         double fPrice2 = MarketInfo(PRD2, MODE_BID);
         double fPrice1 = MarketInfo(PRD1, MODE_ASK);
         logMsg = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SELL >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
         LogInfo(logMsg); 
         
         logMsg = StringFormat("Prepare to open sell order ==> sellOrdersCnt = %d, Lots = %s, Price2 = %s, Price1 = %s, Offset = %s", 
                     sellOrdersCnt, DoubleToString(dLots, 2), 
                     DoubleToString(fPrice2, 4), DoubleToString(fPrice1, 4), 
                     DoubleToString(fPrice2 - fPrice1, 4));
         LogInfo(logMsg); 
         
         OpenOrder(PRD2, OP_SELL, SellComment, dLots);
         OpenOrder(PRD1, OP_BUY, SellComment, dLots);
      }
   }else
   {
      if(nMainDirect == OP_BUY)
      {
         // 如果货币对2存在买单，那么判断是否满足平仓条件
         string comment = BuyComment;
         bool bCloseBuy = CheckForClose(PRD1, PRD2, nMainDirect, comment);
         if(bCloseBuy)
         {
            // 满足平仓条件，平掉两个货币对所有的单子
            double fPrice2 = MarketInfo(PRD2, MODE_BID);
            double fPrice1 = MarketInfo(PRD1, MODE_ASK);
            
            logMsg = "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< BUY <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<";
            LogInfo(logMsg);
            logMsg = StringFormat("Prepare to close buy order ==> buyOrdersCnt = %d, Price2 = %s, Price1 = %s, Offset = %s", 
                        buyOrdersCnt, 
                        DoubleToString(fPrice2, 4), DoubleToString(fPrice1, 4), 
                        DoubleToString(fPrice2 - fPrice1, 4));
            LogInfo(logMsg); 
            
            CloseOrders(OP_BUY);
            CloseOrders(OP_SELL);
            gMostProfits = 0;
            nMainDirect = -1;
         }else
         {
            // 不满足平仓条件，那么判断是否满足开多单条件
            int nDirect = CheckForOpenEx(gPreTrend, nTrend);
            if(nDirect == OP_BUY)
            {
               // Open buy order
               double dLots = BaseOpenLots;
               if(buyOrdersCnt > 0)
               {
                  dLots = NormalizeDouble(BaseOpenLots * MathPow(Overweight_Multiple, buyOrdersCnt), 2);
               }
               
               double fPrice2 = MarketInfo(PRD2, MODE_ASK);
               double fPrice1 = MarketInfo(PRD1, MODE_BID);
               logMsg = "============================ BUY ==================================";
               LogInfo(logMsg); 
               logMsg = StringFormat("Prepare to append buy order ==> buyOrdersCnt = %d, Lots = %s, Price2 = %s, Price1 = %s, Offset = %s", 
                           buyOrdersCnt, DoubleToString(dLots, 2), 
                           DoubleToString(fPrice2, 4), DoubleToString(fPrice1, 4), 
                           DoubleToString(fPrice2 - fPrice1, 4));
               LogInfo(logMsg); 
               OpenOrder(PRD2, OP_BUY, BuyComment, dLots);
               OpenOrder(PRD1, OP_SELL, BuyComment, dLots);
            }
         }
      }else if(nMainDirect == OP_SELL)
      {
         // 如果货币对2存在卖单，那么判断是否满足平仓条件
         string comment = SellComment;
         bool bCloseSell = CheckForClose(PRD1, PRD2, nMainDirect, comment);
         if(bCloseSell)
         {
            // 满足平仓条件，平掉两个货币对所有的单子
            double fPrice2 = MarketInfo(PRD2, MODE_BID);
            double fPrice1 = MarketInfo(PRD1, MODE_ASK);
            
            logMsg = "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SELL <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<";
            LogInfo(logMsg);
            logMsg = StringFormat("Prepare to close sell order ==> sellOrdersCnt = %d, Price2 = %s, Price1 = %s, Offset = %s", 
                        sellOrdersCnt, 
                        DoubleToString(fPrice2, 4), DoubleToString(fPrice1, 4), 
                        DoubleToString(fPrice2 - fPrice1, 4));
            LogInfo(logMsg); 
            
            CloseOrders(OP_SELL);
            CloseOrders(OP_BUY);
            gMostProfits = 0;
            nMainDirect = -1;
         }else
         {
            // 不满足平仓条件，那么判断是否满足开空单条件
            int nDirect = CheckForOpenEx(gPreTrend, nTrend);
            if(nDirect == OP_SELL)
            {
               // 满足开多单空件，追加空单
               double dLots = BaseOpenLots;
               if(sellOrdersCnt > 0)
               {
                  dLots = NormalizeDouble(BaseOpenLots * MathPow(Overweight_Multiple, sellOrdersCnt), 2);
               }
               double fPrice2 = MarketInfo(PRD2, MODE_BID);
               double fPrice1 = MarketInfo(PRD1, MODE_ASK);
               
               logMsg = "============================ SELL ==================================";
               LogInfo(logMsg); 
               
               logMsg = StringFormat("Prepare to append sell order ==> sellOrdersCnt = %d, Lots = %s, Price2 = %s, Price1 = %s, Offset = %s", 
                           buyOrdersCnt, DoubleToString(dLots, 2), 
                           DoubleToString(fPrice2, 4), DoubleToString(fPrice1, 4), 
                           DoubleToString(fPrice2 - fPrice1, 4));
               LogInfo(logMsg); 
               OpenOrder(PRD2, OP_SELL, SellComment, dLots);
               OpenOrder(PRD1, OP_BUY, SellComment, dLots);
            }
         }
         
      }
   } 
   gPreTrend = nTrend; 
}

void TestOpenOrders()
{
   int buyOrdersCnt = QueryCurrentOrders(PRD2, OP_BUY);
   int sellOrdersCnt = QueryCurrentOrders(PRD2, OP_SELL);
   double dLots = BaseOpenLots;
   if(buyOrdersCnt > 0)
   {
      dLots = NormalizeDouble(BaseOpenLots * MathPow(Overweight_Multiple, buyOrdersCnt), 2);
   }
   
   OpenOrder(PRD2, OP_BUY, BuyComment, dLots);
   OpenOrder(PRD1, OP_SELL, BuyComment, dLots);
}
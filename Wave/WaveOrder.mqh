//+------------------------------------------------------------------+
//|                                                      ODOrder.mqh |
//|                                                          Cuilong |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "http://www.mql4.com"
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
#include "ClUtil.mqh"
#include "../Pub/OrderInfo.mqh"

#define MAX_ORDER_COUNT 200

class CWaveOrder
{
private:
   string m_symbol;
   int m_nMagicNum;
   int m_nBuyOrderCount;
   int m_nSellOrderCount;
   double m_dBuyLots;
   double m_dSellLots;
   string m_buyComment;
   string m_sellComment;
   COrderInfo m_buyOrder[MAX_ORDER_COUNT];
   COrderInfo m_sellOrder[MAX_ORDER_COUNT];
   
   double m_dBuyMostProfits;
   double m_dBuyLeastProfits;
   double m_dBuyPreProfits;
   double m_dBuyCurrentProfits;
   
   double m_dSellMostProfits;
   double m_dSellLeastProfits;
   double m_dSellPreProfits;
   double m_dSellCurrentProfits;
   
   double m_dWholePreProfits;
   double m_dWholeCurrentProfits;
   double m_dWholeMostProfits;   
   
   int m_xBuyBasePos;
   int m_yBuyBasePos;
   int m_xSellBasePos;
   int m_ySellBasePos;
   bool m_bShowText;
   bool m_bShowComment;
   
   long m_nTick;
   
private:
   void CleanOrders(COrderInfo & orders [] , int cnt) 
   {
      int i = 0;
      for(i = 0; i < cnt; i++)
      {
         orders[i].clear();
      }
   }
   
   int LoadOrders(string symbol, int nDirect, string comment, int nMagicNum, 
                  COrderInfo & orderInfo[], int & count, double & lots)
   {
      int nOrdersCnt = 0;
      int nOrdersTotalCnt = OrdersTotal();
      double dLots = 0;
      for(int i = 0; i < nOrdersTotalCnt; i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            if(OrderSymbol() == symbol 
               && OrderMagicNumber() == nMagicNum
               && OrderType() == nDirect)
            {
                  orderInfo[nOrdersCnt].m_Symbol = symbol;
                  orderInfo[nOrdersCnt].m_Ticket = OrderTicket(); 
                  orderInfo[nOrdersCnt].m_Prices = OrderOpenPrice();
                  orderInfo[nOrdersCnt].m_Lots = OrderLots();
                  orderInfo[nOrdersCnt].m_Comment = OrderComment();
                  orderInfo[nOrdersCnt].m_OrderType = nDirect;
                  orderInfo[nOrdersCnt].m_TradeTime = OrderOpenTime();
                  double commission = OrderCommission();
                  double swap = OrderSwap();
                  
                  string logMsg;
                  logMsg = StringFormat("commission = %s, swap = %d", 
                           DoubleToString(commission, 2), DoubleToString(swap, 2));    
                  // LogInfo(logMsg);             
                  orderInfo[nOrdersCnt].m_Profits = OrderProfit() + commission + swap;
                  nOrdersCnt++; 
                  dLots +=  OrderLots();
            }
         }
      }
      
      count = nOrdersCnt;
      lots = dLots;
      return nOrdersCnt;
   }
   
   int OpenOrder(string symbol, int orderType, double dLots, string comment, int nMagicNum,
                  double pointForStoploss, double pointForTakeprofit)
   {
      int ret = 0;
      string logMsg;
      logMsg = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OPEN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
      LogInfo(logMsg); 
      logMsg = StringFormat("%s => Symbol = %s, orderType = %d, Lots = %s, magic = %d, comment = %s,  ",
                                  __FUNCTION__, symbol, orderType,
                                  DoubleToString(dLots, 2), nMagicNum, comment);
      LogInfo(logMsg);
      
      RefreshRates();
      switch(orderType)
      {
      case OP_BUY:
         {
            // Open buy order
            double lots = dLots;
            while(true)
            {
               RefreshRates();
               double fAskPrice = MarketInfo(symbol, MODE_ASK);
               double fBidPrice = MarketInfo(symbol, MODE_BID);
               double minstoplevel = MarketInfo(Symbol(),MODE_STOPLEVEL); 
               
               int ticket = OrderSend(symbol, OP_BUY, lots, fAskPrice, 3, 0, 0, comment, nMagicNum, 0, clrRed);                
               if(ticket > 0 && (pointForStoploss > 0 || pointForTakeprofit > 0)) { 
                  int nAddStops = AddLiteralStopsByPips(ticket, OP_BUY, pointForStoploss, pointForTakeprofit); 
                  logMsg = StringFormat("Symbol: %s,  ticket: %d, AddStops result: %d",
                                  symbol, ticket, nAddStops);
                  LogInfo(logMsg);   
               }
               
               if(ticket > 0)
               {
                  logMsg = StringFormat("%s => Open buy order: Symbol = %s, Price = %s, Lots = %s",
                                  __FUNCTION__, symbol, 
                                  DoubleToString(fAskPrice, 5), DoubleToString(lots, 2));
                  LogInfo(logMsg);
                  break;
               }else 
               { 
                  int nErr = GetLastError(); 
                  logMsg = StringFormat("%s => Open buy order Error: %d.", __FUNCTION__, nErr);
                  LogError(logMsg);
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
         {
            // Open sell order
            double lots = dLots;
            while(true)
            {
               RefreshRates();
               double fAskPrice = MarketInfo(symbol, MODE_ASK);
               double fBidPrice = MarketInfo(symbol, MODE_BID);
               double minstoplevel = MarketInfo(Symbol(),MODE_STOPLEVEL); 
                         
               int ticket = OrderSend(symbol, OP_SELL, lots, fBidPrice, 3, 0, 0, comment, nMagicNum, 0, clrGreen);
               if(ticket > 0 && (pointForStoploss > 0 || pointForTakeprofit > 0)) { 
                  int nAddStops = AddLiteralStopsByPips(ticket, OP_SELL, pointForStoploss, pointForTakeprofit); 
                  logMsg = StringFormat("Symbol: %s,  ticket: %d, AddStops result: %d",
                                  symbol, ticket, nAddStops);
                  LogInfo(logMsg);   
               }
               if(ticket > 0) 
               {
                   logMsg = StringFormat("%s => Open sell order: Symbol = %s, Price = %s, Lots = %s",
                                  __FUNCTION__, symbol, 
                                  DoubleToString(fBidPrice, 5), DoubleToString(lots, 2));
                   LogInfo(logMsg);
                   break;
               }else
               { 
                  int nErr = GetLastError(); 
                  logMsg = StringFormat("%s => Open sell order Error: %d.", __FUNCTION__, nErr);
                  LogError(logMsg);
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
   
   int AddLiteralStopsByPips(int iTicketToGo, int iType, double iSL, double iTP)
   {
     int iDigits, iNumRetries, iError;
     double dAsk, dBid, dSL, dTP;
     
     iDigits = MarketInfo(Symbol(), MODE_DIGITS);
   
     if(OrderSelect(iTicketToGo, SELECT_BY_TICKET)==true) // SELECT_BY_TICKET
       {
          // is server or context busy - try n times to submit the order
          iNumRetries = 12;
         
          while(iNumRetries > 0)    // Retries Block  
             {
                if (!IsTradeAllowed()) {
                     Sleep(500);
                }
                RefreshRates();
                  
                if (iType == OP_BUY)
                {
                   dAsk = MarketInfo(Symbol(), MODE_ASK);
                   dBid = MarketInfo(Symbol(), MODE_BID);
                   
                   dSL = NormalizeDouble(dBid - iSL, iDigits);
                   dTP = NormalizeDouble(dBid + iTP, iDigits);
                }
   
                  if (iType == OP_SELL)
                    {
                      dAsk = MarketInfo(Symbol(), MODE_ASK);
                      dBid = MarketInfo(Symbol(), MODE_BID);
                      
                      dSL = NormalizeDouble(dAsk + iSL, iDigits);
                      dTP = NormalizeDouble(dAsk - iTP, iDigits);
                    }
                             
                 OrderModify(OrderTicket(), OrderOpenPrice(), dSL, dTP, 0);
                   
                 iError = GetLastError();
                     
                 if (iError==0) {
                     iNumRetries = 0;
                     return 0;
                 }
                 else  // retry if error is "busy", otherwise give up
                    {            
                        if(iError==ERR_SERVER_BUSY || iError==ERR_TRADE_CONTEXT_BUSY || iError==ERR_BROKER_BUSY || iError==ERR_NO_CONNECTION || iError == ERR_COMMON_ERROR
                          || iError==ERR_TRADE_TIMEOUT || iError==ERR_INVALID_PRICE || iError==ERR_OFF_QUOTES || iError==ERR_PRICE_CHANGED || iError==ERR_REQUOTE)
                           { 
                              Print("ECN Stops Not Added Error: ", iError);
                              Sleep(500);
                              iNumRetries--;
                           }
                         else
                           {
                              iNumRetries = 0;
                              Print("ECN Stops Not Added Error: ", iError);
                              // Alert("ECN Stops Not Added Error: ", iError);
                              return -2;
                           }
                    }
                    
            }   // Retries Block 
         
   
       } // SELECT_BY_TICKET
     else
      {
        Print("ECN Stops Invalid Ticket: ", iTicketToGo);
        // Alert("ECN Stops Invalid Ticket: ", iTicketToGo);   
        return -1;
      }  
      return 0;     
   }
   
   int CloseOrder(COrderInfo & orderInfo)
   {
      int ret = 0;
      double lots = orderInfo.m_Lots;
      int ticket = orderInfo.m_Ticket;
      string symbol = orderInfo.m_Symbol;
      int orderType = orderInfo.m_OrderType;
      
      string logMsg;  
      
      logMsg = "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  CLOSE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<";
      LogInfo(logMsg); 
      logMsg = StringFormat("%s => Symbol = %s, orderType = %d, Lots = %s, ticket = %d",
                                  __FUNCTION__, symbol, orderType,
                                  DoubleToString(lots, 2), ticket);
      LogImportant(logMsg);    
         
     
      if(ticket > 0)
      {
         while(true)
         {
            RefreshRates();
            double fPrice = 0;
            color clr = clrRed;
            if(orderType == OP_BUY)
            {
               clr = clrRed;
               fPrice = MarketInfo(symbol, MODE_BID);
            }else
            {
               clr = clrGreen;
               fPrice = MarketInfo(symbol, MODE_ASK);
            }
            logMsg = StringFormat("%s: ticket = %d, type = %d, price = %s, lots = %s",
                         __FUNCTION__, ticket, orderType, DoubleToString(fPrice, 5),DoubleToString(lots, 2));
            LogImportant(logMsg);
            if(OrderClose(ticket, lots, fPrice, 3, clr))
            {                 
               break;
         
            } else
            {
               int nErr = GetLastError(); // 平仓失败 :( 
               logMsg = StringFormat("%s => Close buy order Error: %d, ticket = %d.",
                         __FUNCTION__, nErr, ticket);
               LogError(logMsg);
               if(IsFatalError(nErr))
               {  
                  ret = nErr;
                  break;
               }                   
           }
         }  
      }
          
      return ret;
   }
   
   double GetSpread(string symbol) {
      RefreshRates();
      double dBid = MarketInfo(Symbol(), MODE_BID);
      double dAsk = MarketInfo(Symbol(), MODE_ASK);
  
      double dSpread =  dAsk - dBid;
      return dSpread;
   }
   
   double CalcTotalProfits(const COrderInfo & orderInfo [], int orderCnt)
   {
      double fProfits = 0;
      for(int i = 0; i < orderCnt; i++)
      {
         fProfits += orderInfo[i].m_Profits;
      }         
         
      return fProfits;
   }
   
   void ShowVersion(string label, string text, color clr, int x, int y)
   {
      if(m_nTick % 4 == 0) {
         DisplayText(label, text, clr, x, y);
      }
   }
   
   void ShowText(string label, string text, color clr, int x, int y)
   {
      string labelInternal = StringFormat("%s-%d", label, m_nMagicNum);
      if(m_bShowText && m_nTick % 4 == 0) {
         DisplayText(labelInternal, text, clr, x, y);
      }
   }
   
public:
   CWaveOrder(string symbol, int magicNum) {
      m_symbol = symbol;
      m_nMagicNum = magicNum;
      m_nBuyOrderCount = 0;
      m_nSellOrderCount = 0;
      m_dBuyLots = 0.0;
      m_dSellLots = 0.0;
      m_buyComment = "WBuy";
      m_sellComment = "WSell";
      
      m_dBuyMostProfits = 0.0;
      m_dBuyLeastProfits = 0.0;
      m_dBuyPreProfits = 0.0;
      m_dBuyCurrentProfits = 0.0;      
      m_dSellMostProfits = 0.0;
      m_dSellLeastProfits = 0.0;
      m_dSellPreProfits = 0.0;
      m_dSellCurrentProfits = 0.0; 
      
      m_dWholePreProfits = 0.0;
      m_dWholeCurrentProfits = 0.0;  
      m_dWholeMostProfits = 0.0; 
        
      m_xBuyBasePos = 0;
      m_yBuyBasePos = 0;
      m_xSellBasePos = 0;
      m_ySellBasePos = 4;
      
      m_nTick = 0;
      m_bShowComment = gbShowComment;
      m_bShowText = gbShowText;
   }
   
   void HeartBeat() {
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos;
      string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, m_nTick++);
      ShowVersion("Version", strVersion, clrYellow, xPos, yPos);
      
      yPos++;
      string strOrders = StringFormat("【多方】订单数：%d，手数：%s", 
                     m_nBuyOrderCount, DoubleToString(m_dBuyLots, 2));
      ShowText("OrderStatisticsBuy", strOrders, clrYellow, xPos, yPos);
      
      yPos++;
      string strProfits = StringFormat("获利：当前 %s， 最高 %s, 移动止盈 %s", 
                           DoubleToString(m_dBuyCurrentProfits, 2),DoubleToString(m_dBuyMostProfits, 2), 
                           DoubleToString(m_dBuyMostProfits * (1 - BackwardForLong), 2));
      ShowText("ProfitsBuy", strProfits, clrYellow, xPos, yPos); 
      
      yPos++;   
      strOrders = StringFormat("【空方】订单数：%d，手数：%s", 
                     m_nSellOrderCount, DoubleToString(m_dSellLots, 2));
      ShowText("OrderStatisticsSell", strOrders, clrYellow, xPos, yPos);
      
      yPos++;  
      strProfits = StringFormat("获利：当前 %s， 最高 %s, 移动止盈 %s", 
                           DoubleToString(m_dSellCurrentProfits, 2),DoubleToString(m_dSellMostProfits, 2), 
                           DoubleToString(m_dSellMostProfits * (1 - BackwardForShort), 2));
      ShowText("ProfitsSell", strProfits, clrYellow, xPos, yPos); 
   }
   int GetBuyOrderCnt() {
      return m_nBuyOrderCount;
   }

   int GetSellOrderCnt() {
      return m_nSellOrderCount;
   }
   
   double GetBuyLots() {
      return m_dBuyLots;
   }
   
    double GetSellLots() {
      return m_dSellLots;
   }
      
   void CleanBuyOrders() 
   {
      CleanOrders(m_buyOrder, m_nBuyOrderCount);
      m_nBuyOrderCount = 0;
      m_dBuyLots = 0;
      m_dBuyMostProfits = 0;
      m_dBuyLeastProfits = 0;
      m_dBuyPreProfits = 0;
      m_dBuyCurrentProfits = 0; 
      m_dWholePreProfits = 0.0; 
      m_dWholeMostProfits = 0.0;  
   }

   void CleanSellOrders() 
   {
      CleanOrders(m_sellOrder, m_nSellOrderCount);
      m_nSellOrderCount = 0;
      m_dSellLots = 0;
      m_dSellMostProfits = 0;
      m_dSellLeastProfits = 0;
      m_dSellPreProfits = 0;
      m_dSellCurrentProfits = 0;
      m_dWholePreProfits = 0.0; 
      m_dWholeMostProfits = 0.0; 
   }
   
   void CleanAllOrders() {
      CleanBuyOrders();
      CleanSellOrders();
   }
   
   int LoadAllOrders() {
      int buyCnt = LoadBuyOrders();
      int sellCnt = LoadSellOrders();
      return buyCnt + sellCnt;
   }
   
   int LoadBuyOrders()
   {
      string logMsg;
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos;
      // string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, gTickCount);
      // ShowVersion("Version", strVersion, clrYellow, xPos, yPos);
                
      CleanBuyOrders();
      
      m_nBuyOrderCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNum, 
                                       m_buyOrder, m_nBuyOrderCount, m_dBuyLots );
                                       
      if(m_nBuyOrderCount > 0)
      {
         logMsg = StringFormat("%s => Symbo = %s, Buy, comment = %s, orderCount = %d, Lots = %s ",
                                  __FUNCTION__, m_symbol,
                                  m_buyComment, m_nBuyOrderCount, DoubleToString(m_dBuyLots, 2));
         //OutputLog(logMsg);
         
            
         logMsg = StringFormat("%s => SubSymbo = %s, lastOrderPrice = %s, lastLots = %s ",
                                     __FUNCTION__, m_symbol, DoubleToString(m_buyOrder[m_nBuyOrderCount - 1].m_Prices, 5), 
                                     DoubleToString(m_buyOrder[m_nBuyOrderCount - 1].m_Lots, 2));
         //OutputLog(logMsg);
         double  dProfits = CalcTotalProfits(m_buyOrder, m_nBuyOrderCount);
         
         m_dBuyPreProfits = m_dBuyCurrentProfits;
         m_dBuyCurrentProfits = dProfits;
         if(m_dBuyCurrentProfits > m_dBuyMostProfits) 
         {
            m_dBuyMostProfits = m_dBuyCurrentProfits;
         }
         
         if(m_dBuyCurrentProfits < m_dBuyLeastProfits) 
         {
            m_dBuyLeastProfits = m_dBuyCurrentProfits;
         }          
                        
         yPos++;
         string strProfits = StringFormat("【多方】订单数：%d，手数：%s", 
                     m_nBuyOrderCount, DoubleToString(m_dBuyLots, 2));
         ShowText("OrderStatisticsBuy", strProfits, clrYellow, xPos, yPos);
                        
      }
      return m_nBuyOrderCount;
   }
   
   int LoadSellOrders()
   {
      string logMsg;
      int xPos = m_xSellBasePos;
      int yPos = m_ySellBasePos;
               
      CleanSellOrders();
      
      m_nSellOrderCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNum, 
                                       m_sellOrder, m_nSellOrderCount, m_dSellLots );
                                       
      if(m_nSellOrderCount > 0)
      {
         logMsg = StringFormat("%s => Symbo = %s, Sell, comment = %s, orderCount = %d, Lots = %s ",
                                  __FUNCTION__, m_symbol,
                                  m_sellComment, m_nSellOrderCount, DoubleToString(m_dSellLots, 2));
         //OutputLog(logMsg);
         
            
         logMsg = StringFormat("%s => SubSymbo = %s, lastOrderPrice = %s, lastLots = %s ",
                                     __FUNCTION__, m_symbol, DoubleToString(m_sellOrder[m_nSellOrderCount - 1].m_Prices, 5), 
                                     DoubleToString(m_sellOrder[m_nSellOrderCount - 1].m_Lots, 2));
         //OutputLog(logMsg);
         double  dProfits = CalcTotalProfits(m_sellOrder, m_nSellOrderCount);
         
         m_dSellPreProfits = m_dSellCurrentProfits;
         m_dSellCurrentProfits = dProfits;
         if(m_dSellCurrentProfits > m_dSellMostProfits) 
         {
            m_dSellMostProfits = m_dSellCurrentProfits;
         }
         
         if(m_dSellCurrentProfits < m_dSellLeastProfits) 
         {
            m_dSellLeastProfits = m_dSellCurrentProfits;
         }          
                        
         yPos++;
         string strProfits = StringFormat("【空方】订单数：%d，手数：%s", 
                     m_nSellOrderCount, DoubleToString(m_dSellLots, 2));
         ShowText("OrderStatisticsSell", strProfits, clrYellow, xPos, yPos);
                        
      }
      return m_nSellOrderCount;
   }
   
   int OpenBuyOrders(OptParam & optParam)
   {
      // string comment = StringFormat("S%d-%s(%s)", nStage + 1, m_comment, DoubleToString(dCurrentPrice, 4));
      string comment = ""; 
      int nDirct = OP_BUY;           
      if(m_bShowComment) {
         comment = StringFormat("%s(%d)-%d", m_buyComment, m_nMagicNum, m_nBuyOrderCount + 1);   
      }
      OpenOrder(m_symbol, nDirct, optParam.m_BaseOpenLots, comment, m_nMagicNum,
                optParam.m_StopLossPoint, optParam.m_TakeProfitPoint);
      
      // 重新装载多方订单
      LoadBuyOrders();
      return 0;
   }
   
   int OpenSellOrders(OptParam & optParam)
   {
      // string comment = StringFormat("S%d-%s(%s)", nStage + 1, m_comment, DoubleToString(dCurrentPrice, 4));
      string comment = ""; 
      int nDirct = OP_SELL;           
      if(m_bShowComment) {
         comment = StringFormat("%s(%d)-%d", m_sellComment, m_nMagicNum, m_nSellOrderCount + 1);   
      }
      OpenOrder(m_symbol, nDirct, optParam.m_BaseOpenLots, comment, m_nMagicNum,
                optParam.m_StopLossPoint, optParam.m_TakeProfitPoint);
      
      // 重新装载空方订单
      LoadSellOrders();
      return 0;
   }
   
   double GetHighestPriceFromOrders(COrderInfo & orders [], int nCnt) {
      double price = 0;
      int i = 0;
      for(i = 0; i < nCnt; i++)
      {
         if(i == 0) {
            price = orders[i].m_Prices;
         }
         
         if(orders[i].m_Prices > price) {
            price = orders[i].m_Prices;
         }
      }
      return price;
   }
   
   double GetLowestPriceFromOrders(COrderInfo & orders [], int nCnt) {
      double price = 0;
      int i = 0;
      for(i = 0; i < nCnt; i++)
      {
         if(i == 0) {
            price = orders[i].m_Prices;
         }
         
         if(orders[i].m_Prices < price) {
            price = orders[i].m_Prices;
         }
      }
      return price;
   }
   
   bool HasHoleInOrders(COrderInfo & orders [], int nCnt, double dPriceDiff, int nDirect) {
      bool bHasHole = true;
      RefreshRates();
      double fPrice = 0;
      if(nDirect == OP_BUY) {
         fPrice = MarketInfo(m_symbol, MODE_ASK);
      }else {
         fPrice = MarketInfo(m_symbol, MODE_BID);
      }
      int i = 0;
      for(i = 0; i < nCnt; i++)
      {
         if(MathAbs(fPrice - orders[i].m_Prices) < dPriceDiff) {
            bHasHole = false;
            break;
         }
      }
      return bHasHole;
   }
   
   bool CheckForAppendBuyOrder(double dPriceDiff, double dRevertAppendStep, double dSpreadMax,
                               bool bEnableLongShortRateForAppend, double dEnableLongShortRateLotsForAppend,
                               double dMaxHandlingLots, bool bAppendOrderInHole) {
      string logMsg;
      double dSpread = GetSpread(m_symbol);
      if(dSpread >= dSpreadMax) {
         logMsg = StringFormat("CheckForAppendBuyOrder(%s), spread out of range.(%s)",
                                  m_symbol, DoubleToString(dSpread, 4));
            LogInfo(logMsg);
         return false;
      }
      
      if(m_dBuyLots > dMaxHandlingLots) {
         return false;
      }
      
      bool checkLongShortRate = true;
      if(bEnableLongShortRateForAppend){
         if(m_dBuyLots >= dEnableLongShortRateLotsForAppend || m_dSellLots >= dEnableLongShortRateLotsForAppend) {
            // 多方或空方的任意一方的手数大于等于设置的手数, 继续判断多空双发的比例关系
            if(m_dBuyLots <= m_dSellLots) {
               // 多方的总手数小于等于空方的总手数，允许加仓
               checkLongShortRate = true;
            }else {
               // 否则，不允许加仓
               checkLongShortRate = false;
            }
            
         }else {
            // 多方或空方的任意一方的手数均小于于设置的手数，允许加仓
            checkLongShortRate = true;
         }         
      }
      
      if(!checkLongShortRate) {
         return false;
      }
      
      double highestBuyPrice = GetHighestPriceFromOrders(m_buyOrder, m_nBuyOrderCount);
      RefreshRates(); 
      double fAskPrice = MarketInfo(m_symbol, MODE_ASK);
      if(fAskPrice - highestBuyPrice > dPriceDiff) {
         return true;
      }
      
      if(bAppendOrderInHole) {
         bool bHasHole = HasHoleInOrders( m_buyOrder, m_nBuyOrderCount, dPriceDiff, OP_BUY); 
         if(bHasHole) { 
            double lowestSellPrice = GetLowestPriceFromOrders(m_sellOrder, m_nSellOrderCount);                 
            if(fAskPrice - lowestSellPrice > dRevertAppendStep) {
               return true;
            }   
         }
      }
      
      return false;
   }
   
   bool CheckForAppendSellOrder(double dPriceDiff, double dRevertAppendStep, double dSpreadMax,
                                 bool bEnableLongShortRateForAppend, double dEnableLongShortRateLotsForAppend,
                                  double dMaxHandlingLots, bool bAppendOrderInHole) {
      string logMsg;
      double dSpread = GetSpread(m_symbol);
      if(dSpread >= dSpreadMax) {
         logMsg = StringFormat("CheckForAppendSellOrder(%s), spread out of range.(%s)",
                                  m_symbol, DoubleToString(dSpread, 4));
            LogInfo(logMsg);
         return false;
      }
      
      if(m_dSellLots > dMaxHandlingLots) {
         return false;
      }
      
      bool checkLongShortRate = true;
      if(bEnableLongShortRateForAppend){
         if(m_dBuyLots >= dEnableLongShortRateLotsForAppend || m_dSellLots >= dEnableLongShortRateLotsForAppend) {
            // 多方或空方的任意一方的手数大于等于设置的手数, 继续判断多空双发的比例关系
            if(m_dSellLots <= m_dBuyLots) {
               // 空方的总手数小于等于多方的总手数，允许加仓
               checkLongShortRate = true;
            }else {
               // 否则，不允许加仓
               checkLongShortRate = false;
            }
            
         }else {
            // 多方或空方的任意一方的手数均小于于设置的手数，允许加仓
            checkLongShortRate = true;
         }         
      }
      
      if(!checkLongShortRate) {
         return false;
      }
   
      double lowestSellPrice = GetLowestPriceFromOrders(m_sellOrder, m_nSellOrderCount);
      RefreshRates();
      double fBidPrice = MarketInfo(m_symbol, MODE_BID);
      if(lowestSellPrice - fBidPrice > dPriceDiff) {
         // 价格持续下行时的情况
         return true;
      }
      
      if(bAppendOrderInHole) {
         bool bHasHole = HasHoleInOrders( m_sellOrder, m_nSellOrderCount, dPriceDiff, OP_SELL);
         if(bHasHole) {
            // 获取买单中的最高价格
            double highestBuyPrice = GetHighestPriceFromOrders(m_buyOrder, m_nBuyOrderCount);
            if(highestBuyPrice - fBidPrice > dRevertAppendStep) {
               // 当前价格比买单中的最高价格还低时，返回ture
               return true;
            }  
         }               
      }
      return false;
   }
   
   double GetProfitByTicket(int nTicket, COrderInfo & orders [], int nCnt) {
      double profit = 0;
      int i =0;
      for(i = 0; i < nCnt; i++) {
         if(orders[i].m_Ticket == nTicket) {
            profit = orders[i].m_Profits;
            break;
         }
      }
      return profit;
  
   }
   
   void CheckForCloseBuyOrders(double minPriceDiff, double dBackward,
                                bool bEnableLongShortRateForClose, double dEnableLongShortRateLotsForClose) {
      string logMsg;
      
      bool checkLongShortRate = true;
      if(bEnableLongShortRateForClose){
         if(m_dBuyLots >= dEnableLongShortRateLotsForClose || m_dSellLots >= dEnableLongShortRateLotsForClose) {
            // 多方或空方的任意一方的手数大于等于设置的手数, 继续判断多空双方的比例关系
            if(m_dBuyLots >= m_dSellLots) {
               // 多方的总手数大于等于空方的总手数，允许平仓
               checkLongShortRate = true;
            }else {
               // 否则，不允许平仓
               checkLongShortRate = false;
            }
            
         }else {
            // 多方或空方的任意一方的手数均小于于设置的手数，允许平仓
            checkLongShortRate = true;
         }         
      }
      
      if(!checkLongShortRate) {
         return;
      }
      
      COrderInfo buyOrders[MAX_ORDER_COUNT];
      int nBuyOrderCount = 0;
      double dBuyLots = 0;
      bool bNeedReloadBuyOrders = false;
      nBuyOrderCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNum, 
                                       buyOrders, nBuyOrderCount, dBuyLots);
      RefreshRates();                                 
      double fPrice = MarketInfo(m_symbol, MODE_BID);
      int i =0;
      m_dBuyCurrentProfits = 0;
      m_dBuyMostProfits = 0;
      for(i = 0; i < m_nBuyOrderCount; i++) {
         double profits = GetProfitByTicket(m_buyOrder[i].m_Ticket,
                  buyOrders, nBuyOrderCount);
         
         double movableProfits = m_buyOrder[i].m_MostProfits * (1 - dBackward);
         double priceDiff = fPrice - m_buyOrder[i].m_Prices;
         if(priceDiff > minPriceDiff
            && profits < movableProfits
            && m_buyOrder[i].m_Profits > profits){
            logMsg = StringFormat("Buy order close(%s, %d), pre: %s, current: %s, most: %s, movable: %s, priceDiff: %s",
                                  m_symbol, m_buyOrder[i].m_Ticket,
                                  DoubleToString(m_buyOrder[i].m_Profits, 2), 
                                  DoubleToString(profits, 2),
                                  DoubleToString(m_buyOrder[i].m_MostProfits, 2),
                                  DoubleToString(movableProfits, 2),
                                  DoubleToString(priceDiff, 4));
            LogInfo(logMsg);
            
            CloseOrder(m_buyOrder[i]);
            bNeedReloadBuyOrders = true;
         }else {
            logMsg = StringFormat("Buy order profits(%s, %d), pre: %s, current: %s, most: %s,  movable: %s, priceDiff: %s",
                                  m_symbol, m_buyOrder[i].m_Ticket,
                                  DoubleToString(m_buyOrder[i].m_Profits, 2), 
                                  DoubleToString(profits, 2),
                                  DoubleToString(m_buyOrder[i].m_MostProfits, 2),
                                  DoubleToString(movableProfits, 2),
                                  DoubleToString(priceDiff, 4));
            LogInfo(logMsg);         
            m_buyOrder[i].m_Profits = profits;
            if(profits > m_buyOrder[i].m_MostProfits) {
               m_buyOrder[i].m_MostProfits = profits;
            }
            m_dBuyCurrentProfits += profits;
            m_dBuyMostProfits += m_buyOrder[i].m_MostProfits;
            
         }
      }
      
      if(bNeedReloadBuyOrders) {
         LoadBuyOrders();
      }
   }
   
   void CheckForCloseSellOrders(double minPriceDiff, double dBackward ,
                                 bool bEnableLongShortRateForClose, double dEnableLongShortRateLotsForClose) {
      string logMsg;
      
      bool checkLongShortRate = true;
      if(bEnableLongShortRateForClose){
         if(m_dBuyLots >= dEnableLongShortRateLotsForClose || m_dSellLots >= dEnableLongShortRateLotsForClose) {
            // 多方或空方的任意一方的手数大于等于设置的手数, 继续判断多空双方的比例关系
            if(m_dSellLots >= m_dBuyLots) {
               // 空方的总手数大于等于多方的总手数，允许平仓
               checkLongShortRate = true;
            }else {
               // 否则，不允许平仓
               checkLongShortRate = false;
            }
            
         }else {
            // 多方或空方的任意一方的手数均小于于设置的手数，允许平仓
            checkLongShortRate = true;
         }         
      }
      
      if(!checkLongShortRate) {
         return;
      }
      
      COrderInfo sellOrders[MAX_ORDER_COUNT];
      int nSellOrderCount = 0;
      double dSellLots = 0;
      bool bNeedReloadSellOrders = false;
      nSellOrderCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNum, 
                                       sellOrders, nSellOrderCount, dSellLots);
      RefreshRates();                                 
      double fPrice = MarketInfo(m_symbol, MODE_ASK);
      int i =0;
      m_dSellCurrentProfits = 0;
      m_dSellMostProfits = 0;
      for(i = 0; i < m_nSellOrderCount; i++) {
         double profits = GetProfitByTicket(m_sellOrder[i].m_Ticket,
                  sellOrders, nSellOrderCount);
         
         double movableProfits = m_sellOrder[i].m_MostProfits * (1 - dBackward);
         double priceDiff = m_sellOrder[i].m_Prices - fPrice;
         if(priceDiff > minPriceDiff 
            && profits < movableProfits 
            && m_sellOrder[i].m_Profits > profits){
            logMsg = StringFormat("Sell order close(%s, %d), pre: %s, current: %s, most: %s, movable: %s, priceDiff: %s",
                                  m_symbol, m_sellOrder[i].m_Ticket,
                                  DoubleToString(m_sellOrder[i].m_Profits, 2), 
                                  DoubleToString(profits, 2),
                                  DoubleToString(m_sellOrder[i].m_MostProfits, 2),
                                  DoubleToString(movableProfits, 2),
                                  DoubleToString(priceDiff, 4));
            LogInfo(logMsg); 
            CloseOrder(m_sellOrder[i]);
            bNeedReloadSellOrders = true;
         }else {
            logMsg = StringFormat("Sell order profits(%s, %d), pre: %s, current: %s, most: %s, movable: %s, priceDiff: %s",
                                  m_symbol, m_sellOrder[i].m_Ticket,
                                  DoubleToString(m_sellOrder[i].m_Profits, 2), 
                                  DoubleToString(profits, 2),
                                  DoubleToString(m_sellOrder[i].m_MostProfits, 2),
                                  DoubleToString(movableProfits, 2),
                                  DoubleToString(priceDiff, 4));
            LogInfo(logMsg); 
            m_sellOrder[i].m_Profits = profits;
            if(profits > m_sellOrder[i].m_MostProfits) {
               m_sellOrder[i].m_MostProfits = profits;
            }
            m_dSellCurrentProfits += profits;
            m_dSellMostProfits += m_sellOrder[i].m_MostProfits;
         }
      }
      
      if(bNeedReloadSellOrders) {
         LoadSellOrders();
      }
   }
   
   bool CheckForWholeCloseOrders(double minProfits, bool enableMovableProfit, double dBackward) {
   
      m_dWholePreProfits = m_dWholeCurrentProfits;
           
      //  计算所有多单的盈利情况
      COrderInfo buyOrders[MAX_ORDER_COUNT];
      int nBuyOrderCount = 0;
      double dBuyLots = 0;
      bool bNeedReloadBuyOrders = false;
      nBuyOrderCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNum, 
                                       buyOrders, nBuyOrderCount, dBuyLots);
      int i =0;
      m_dBuyCurrentProfits = 0;
      m_dBuyMostProfits = 0;
      for(i = 0; i < m_nBuyOrderCount; i++) {
         double profits = GetProfitByTicket(m_buyOrder[i].m_Ticket,
                  buyOrders, nBuyOrderCount);
         m_buyOrder[i].m_Profits = profits;
         if(profits > m_buyOrder[i].m_MostProfits) {
            m_buyOrder[i].m_MostProfits = profits;
         }
         m_dBuyCurrentProfits += profits;
         m_dBuyMostProfits += m_buyOrder[i].m_MostProfits;
      }
      
      //计算所有空单的盈利情况
      COrderInfo sellOrders[MAX_ORDER_COUNT];
      int nSellOrderCount = 0;
      double dSellLots = 0;
      bool bNeedReloadSellOrders = false;
      nSellOrderCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNum, 
                                       sellOrders, nSellOrderCount, dSellLots);
      m_dSellCurrentProfits = 0;
      m_dSellMostProfits = 0;
      for(i = 0; i < m_nSellOrderCount; i++) {
         double profits = GetProfitByTicket(m_sellOrder[i].m_Ticket,
                  sellOrders, nSellOrderCount);
         m_sellOrder[i].m_Profits = profits;
         if(profits > m_sellOrder[i].m_MostProfits) {
            m_sellOrder[i].m_MostProfits = profits;
         }
         m_dSellCurrentProfits += profits;
         m_dSellMostProfits += m_sellOrder[i].m_MostProfits;   
      }
      
      m_dWholeCurrentProfits = m_dBuyCurrentProfits + m_dSellCurrentProfits;
      if(m_dWholeCurrentProfits > m_dWholeMostProfits) {
         m_dWholeMostProfits = m_dWholeCurrentProfits;
      }
      double movableProfits = m_dWholeMostProfits * (1 - dBackward);
      string logMsg = StringFormat("CheckForWholeCloseOrders(%s): movable: %d, pre: %s, current: %s, most: %s, movable: %s",
                                  m_symbol, enableMovableProfit,
                                  DoubleToString(m_dWholePreProfits, 2), 
                                  DoubleToString(m_dWholeCurrentProfits, 2),
                                  DoubleToString(m_dWholeMostProfits, 2),
                                  DoubleToString(movableProfits, 2));
      LogInfo(logMsg); 
            
      if(enableMovableProfit) {
         if(m_dWholeCurrentProfits >= minProfits 
            && m_dWholePreProfits > movableProfits
            && m_dWholeCurrentProfits < movableProfits) {
               return true;
            }
            
      } else {
         if(m_dWholeCurrentProfits >= minProfits) {
            return true;
         }
      }
      
      return false;
   }
   bool CheckForAutoCloseAll(double baseBalance, double preEquity, double mostEquity, double realTargetEquity) {
      double currentEquity = AccountEquity(); // 净值
      int xPos = m_xSellBasePos;
      int yPos = m_ySellBasePos + 1;
      string strAutoCloseAll = StringFormat("净值:本金:%s,当前:%s,最大:%s,止盈:%s", 
               DoubleToString(baseBalance, 2),
               DoubleToString(currentEquity, 2),
               DoubleToString(mostEquity, 2),
               DoubleToString(realTargetEquity, 2));
      ShowText("AutoCloseAll", strAutoCloseAll, clrYellow, xPos, yPos);
      LogInfo(strAutoCloseAll);    
           
      if(currentEquity > baseBalance && preEquity > realTargetEquity && currentEquity <= realTargetEquity) {
         strAutoCloseAll = "CheckForAutoCloseAll, --------------- Whole Close --------------";
         LogInfo(strAutoCloseAll);    
         return true;
      }
      return false;
    }
    
    int CloseAllBuyOrders()
    {
      int nRet = 0;
      for(int i = m_nBuyOrderCount - 1; i >= 0; i--)
      {
         CloseOrder(m_buyOrder[i]);
      }
      
      m_dBuyMostProfits = 0.0;
      m_dBuyLeastProfits = 0.0;
      m_dBuyPreProfits = 0;
      m_dBuyCurrentProfits = 0;
      
      return nRet;
    }
    
    int CloseAllSellOrders()
    {
      int nRet = 0;
      for(int i = m_nSellOrderCount - 1; i >= 0; i--)
      {
         CloseOrder(m_sellOrder[i]);
      }
      
      m_dSellMostProfits = 0.0;
      m_dSellLeastProfits = 0.0;
      m_dSellPreProfits = 0;
      m_dSellCurrentProfits = 0;
      
      return nRet;
    }
    
     bool CheckForAutoStopLossAll(double realTargetEquity) {
      double currentEquity = AccountEquity(); // 净值
           
      if(currentEquity < realTargetEquity) {
         return true;
      }
      return false;
    }
};
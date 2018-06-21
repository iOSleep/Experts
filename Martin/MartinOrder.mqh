//+------------------------------------------------------------------+
//|                                                  MartinOrder.mqh |
//|                                                          Cuilong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "https://www.mql5.com"
#property strict

#include "ClUtil.mqh"
#include "../Pub/OrderInfo.mqh"

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
#define MAX_ORDER_COUNT 20

string OpName [] = 
{
   "买单",
   "卖单"
};

enum { PM_HEAVY = 0, PM_LIGHT = 1};

#define LIGHT_LOTS 0.01

class CMartinOrder
{
public:
   int m_nTimeFrame;
   int m_nDirect;
   string m_strDirect;
   int m_nOrderCount;
   double m_dLots;
   string m_symbol; 
   string m_comment;
   int m_nMagicNum;
   double m_dBaseOpenLots;
   double m_dMultiple;
   double m_dMultipleFactor;
   int m_nMaxOrderCount;
   
   double m_dMostProfits;
   double m_dPreProfits;
   double m_dCurrentProfits;
   
   double m_dLeastProfits;
   
   int m_nLoopCount;
   
   COrderInfo m_orderInfo[MAX_ORDER_COUNT];
   
   bool m_bExistOrderProtecting;
   COrderInfo m_orderProtecting;
   string m_commentProtecting;
   double m_dPriceProtectingLine;
   double m_dPrePriceAfterProtecting;
   double m_dHiPriceAfterProtecting;
   double m_dLoPriceAfterProtecting;
   int m_nHtoLCount;
   int m_nProtectingMode;
   double m_dProtectingMostProfits;
   double m_dProtectingLeastProfits;
   double m_dPreProtectingProfits;
   double m_dProtectingMultiple;
   bool m_bProtectingAlreaTakeProfits;
     
private:
   int m_xBasePos;
   int m_yBasePos;
   
public:
   CMartinOrder(string symbol, int nDirect, 
               int nTimeFrame, double dBaseOpenLots, double dMultiple, 
               double dMultipleFactor, int nMaxOrderCount, int nMagicNum, double dProtectingMultiple) 
   {
      m_nDirect = nDirect;
      m_nOrderCount = 0;
      m_dLots = 0.0;
      m_symbol = symbol;
      m_nTimeFrame = nTimeFrame;
      m_dBaseOpenLots = dBaseOpenLots;
      m_dMultiple = dMultiple;
      m_dMultipleFactor = dMultipleFactor;
      m_nMaxOrderCount = nMaxOrderCount;
      m_dMostProfits = 0.0;
      m_dLeastProfits = 0.0;
      m_dPreProfits = 0;
      m_dCurrentProfits = 0;
      m_nLoopCount = 0;
      m_dPriceProtectingLine = 0;
      m_dPrePriceAfterProtecting = 0;
      m_bExistOrderProtecting = false;
      m_nHtoLCount = 0;
      m_nProtectingMode = PM_HEAVY;
      m_dProtectingMostProfits = 0;
      m_dProtectingLeastProfits = 0;
      m_dPreProtectingProfits = 0;
      m_dProtectingMultiple = dProtectingMultiple;
      m_bProtectingAlreaTakeProfits = false;
           
      if(nDirect == OP_BUY)
      {
         m_comment = "MBuy";
         m_commentProtecting = "MBuyP";
         m_strDirect = "MBuy";
         m_nMagicNum = nMagicNum;
         m_xBasePos = 0;
         m_yBasePos = 0;
      }else
      {
         m_comment = "MSell";
         m_commentProtecting = "MSellP";
         m_strDirect = "MSell";
         m_nMagicNum = nMagicNum + 1;
         m_xBasePos = 0;
         m_yBasePos = 7;
      }
   }
   
   void CleanOrders() 
   {
      int i = 0;
      for(i = 0; i < m_nOrderCount; i++)
      {
         m_orderInfo[i].clear();
      }
      m_nOrderCount = 0;
   }
   
   int GetLoopCount() {
      return m_nLoopCount;
   }
   
   int LoadAllOrders()
   {
      string logMsg;
      int xPos = m_xBasePos;
      int yPos = m_yBasePos;
      if(m_nDirect == OP_BUY) {
         string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, gTickCount);
         ShowText("Version", strVersion, clrYellow, xPos, yPos);
      }
          
      CleanOrders();
        
      m_nOrderCount = LoadOrders(m_symbol, m_nDirect, m_comment, m_nMagicNum, 
                                       m_orderInfo, m_nOrderCount, m_dLots );
      if(m_nOrderCount > 0)
      {
         logMsg = StringFormat("%s => Symbo = %s, orderType = %d(%s), comment = %s, orderCount = %d, Lots = %s ",
                                  __FUNCTION__, m_symbol, m_nDirect, m_strDirect,
                                  m_comment, m_nOrderCount, DoubleToString(m_dLots, 2));
         //OutputLog(logMsg);
         
            
         logMsg = StringFormat("%s => SubSymbo = %s, lastOrderPrice = %s, lastLots = %s ",
                                     __FUNCTION__, m_symbol, DoubleToString(m_orderInfo[m_nOrderCount - 1].m_Prices, 5), 
                                     DoubleToString(m_orderInfo[m_nOrderCount - 1].m_Lots, 2));
         //OutputLog(logMsg);
         double  dProfits = CalcTotalProfits(m_orderInfo, m_nOrderCount);
         
         m_dPreProfits = m_dCurrentProfits;
         m_dCurrentProfits = dProfits;
         if(m_dCurrentProfits > m_dMostProfits) 
         {
            m_dMostProfits = m_dCurrentProfits;
         }
         
         if(m_dCurrentProfits < m_dLeastProfits) 
         {
            m_dLeastProfits = m_dCurrentProfits;
         }  
           
         // 获取保护仓订单信息
         COrderInfo orderInfo[MAX_ORDER_COUNT];
         int nDirect = GetProtectingOrderDirect();
         int nOrderCount = 0;
         double lots = 0;
         int nProtectingOrderCount = 0;
         nProtectingOrderCount = LoadOrders(m_symbol, nDirect, m_comment, m_nMagicNum, 
                                          orderInfo, nProtectingOrderCount, lots );
         if(nProtectingOrderCount > 0) {
             m_bExistOrderProtecting = true;
             m_orderProtecting.m_Symbol = orderInfo[0].m_Symbol;
             m_orderProtecting.m_Ticket =orderInfo[0].m_Ticket;
             m_orderProtecting.m_OrderType = orderInfo[0].m_OrderType;
             m_orderProtecting.m_Lots = orderInfo[0].m_Lots;
             m_orderProtecting.m_Prices = orderInfo[0].m_Prices;
             m_orderProtecting.m_StopLoss = orderInfo[0].m_StopLoss;
             m_orderProtecting.m_TakeProfit = orderInfo[0].m_TakeProfit;
             m_orderProtecting.m_Comment = orderInfo[0].m_Comment;
             m_orderProtecting.m_Magic = orderInfo[0].m_Magic;
             m_orderProtecting.m_TradeTime = orderInfo[0].m_Magic;
             m_orderProtecting.m_Profits = orderInfo[0].m_Profits;
             
             if(m_orderProtecting.m_Lots > 0 && m_orderProtecting.m_Lots <= LIGHT_LOTS) {
               m_nProtectingMode = PM_LIGHT;
             }else {
               m_nProtectingMode = PM_HEAVY;
             }
             
             m_dProtectingMostProfits = MathMax(m_dProtectingMostProfits, m_orderProtecting.m_Profits);
             m_dProtectingLeastProfits = MathMin(m_dProtectingLeastProfits, m_orderProtecting.m_Profits);
         }
                
         yPos++;
         string strProfits;
         if(m_nDirect == OP_BUY)
         {
            strProfits = StringFormat("【多方】订单数：%d，手数：%s，轮数：%d", 
                     m_nOrderCount, DoubleToString(m_dLots, 2), m_nLoopCount);
            ShowText("OrderStatisticsBuy", strProfits, clrYellow, xPos, yPos);
            
            yPos += 4;
            strProfits = StringFormat("【保护】手数：%s, 价格：%s，获利：%s，次数：%d",
                     DoubleToString(m_orderProtecting.m_Lots, 2),
                     DoubleToString(m_orderProtecting.m_Prices, 2),
                     DoubleToString(m_orderProtecting.m_Profits, 2),
                     m_nHtoLCount);
            ShowText("OrderStatisticsBuyProtecting", strProfits, clrYellow, xPos, yPos);
         }else
         {
            strProfits = StringFormat("【空方】订单数：%d，手数：%s，轮数：%d", 
                     m_nOrderCount, DoubleToString(m_dLots, 2), m_nLoopCount);
            ShowText("OrderStatisticsSell", strProfits, clrYellow, xPos, yPos);
            
            yPos += 4;
            strProfits = StringFormat("【保护】手数：%s, 价格：%s，获利：%s，次数：%d",
                     DoubleToString(m_orderProtecting.m_Lots, 2),
                     DoubleToString(m_orderProtecting.m_Prices, 4),
                     DoubleToString(m_orderProtecting.m_Profits, 2),
                     m_nHtoLCount);
            ShowText("OrderStatisticsSellProtecting", strProfits, clrYellow, xPos, yPos);
          }
                 
      }
      return m_nOrderCount;
   }
   
   bool hasProtectingOrder() {
      return m_bExistOrderProtecting;
   }
   
   int Fib(int n)
   {
      return n < 2 ? 1 : (Fib(n-1) + Fib(n-2));
   }
   
   int OpenOrdersMicro()
   {
       double accMargin =  AccountMargin();//AccountMargin();
       double equity = AccountEquity();
         
       if(CheckFreeMargin && accMargin != 0 && (equity / accMargin) < (AdvanceRate / 100) ) {
              string logMsg = StringFormat("%s => Free margin not enouth: margin = %s, equity = %s.",
                              __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(equity,3));
              LogWarn(logMsg); 
              return -1; 
       }
       
       double dLots = 0.01;//NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, nOrderCnt) * MathPow(m_dMultipleFactor, nOrderCnt), 2);
                 
      double dCurrentPrice = 0;
      RefreshRates();
      if(m_nDirect == OP_BUY)
      {
         dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
      } else {
         dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
      }
      string comment = StringFormat("%s(%s)", m_comment, DoubleToString(dCurrentPrice, 4));
      OpenOrder(m_symbol, m_nDirect, dLots, comment, m_nMagicNum);
      
      return 0;
   }
   
   int OpenOrders()
   {
      double accMargin = AccountMargin();
      double equity = AccountEquity();
      if(CheckFreeMargin && accMargin != 0 && (equity / accMargin) < (AdvanceRate / 100) ) {
              string logMsg = StringFormat("%s => Free margin not enouth: margin = %s, equity = %s.",
                              __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(equity,3));
              LogWarn(logMsg); 
              return -1; 
       }
       
      if(m_nOrderCount < m_nMaxOrderCount)
      {
         int fib = Fib(m_nOrderCount + 1);
         double dLots = NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, m_nOrderCount) * MathPow(m_dMultipleFactor, m_nOrderCount), 2);
         
         // 当现有的订单数超过保护起点时，不在做指数级加仓，仅仅做等量加仓
         if(m_nOrderCount > m_nMaxOrderCount - 1) {
            dLots = NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, m_nOrderCount - 1) * MathPow(m_dMultipleFactor, m_nOrderCount - 1), 2);
         }
         
         if(m_nOrderCount > 0)
         {
           string logMsg = StringFormat("Append: Direct = %s, lots = %s",
                               OpName[m_nDirect], DoubleToString(dLots, 2));
            LogInfo(logMsg);
         }else 
         {
            string logMsg = StringFormat("New: Direct = %s, lots = %s",
                               OpName[m_nDirect], DoubleToString(dLots, 2));
            LogInfo(logMsg);
         }
         
         double dCurrentPrice = 0;
         RefreshRates();
         if(m_nDirect == OP_BUY)
         {
           // 此时需要获取两种货币对的卖价          
           dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
         }else {
            // 此时需要获取两种货币对的卖价          
           dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
         }
         string comment = StringFormat("%s(%s)", m_comment, DoubleToString(dCurrentPrice, 4));
         OpenOrder(m_symbol, m_nDirect, dLots, comment, m_nMagicNum);
         
      }
      return 0;
   }

   
   
   // 双向套利平仓条件
   bool CheckForClose(double dOffset, double dProfitsSetting, double dBackword)
   {
      if(m_nOrderCount <= 1)
      {
         // return CheckForCloseByOffset(dOffset) && CheckForCloseByProfits(0, dBackword);
         // 单笔订单，只检查价格差
         // CheckForCloseByProfits(0, dBackword);
         
         // 2018-06-11, 改为既检查价格差，也检查获利情况 
         // return CheckForCloseByOffset(dOffset)
         return CheckForCloseByOffset(dOffset) && CheckForCloseByProfits(0, dBackword);
      }else
      {
         return  CheckForCloseByProfits(dProfitsSetting, dBackword);
      }
      
   }
   
   bool CheckForCloseByProfits(double dProfitsSetting, double dBackword)
   {
      bool bRet = false;
      double dRealStandardProfits = MathMax(dProfitsSetting, m_dMostProfits * (1 - dBackword));
      int xPos = m_xBasePos;
      int yPos = m_yBasePos + 2;
      string strPriceDiff = StringFormat("获利：当前 %s， 最高 %s, 移动止盈 %s", 
                           DoubleToString(m_dCurrentProfits, 2),DoubleToString(m_dMostProfits, 2), 
                           DoubleToString(dRealStandardProfits, 2));
      if(m_nDirect == OP_BUY) {
         ShowText("ProfitsBuy", strPriceDiff, clrYellow, xPos, yPos); 
      }else
      {
         ShowText("ProfitsSell", strPriceDiff, clrYellow, xPos, yPos);  
      }
      if(m_dCurrentProfits > dProfitsSetting)
      {        
         if(m_dPreProfits > dRealStandardProfits && m_dCurrentProfits <= dRealStandardProfits)
         {
            string logMsg = StringFormat("CheckForCloseByProfits：standard = %s, Pre = %s, Current = %s", 
                     DoubleToString(dRealStandardProfits, 2), DoubleToString(m_dPreProfits, 2), 
                     DoubleToString(m_dCurrentProfits, 2) );
            LogInfo(logMsg);
            bRet = true;
         }          
      }     
           
      return bRet;
   }
   
   double GetPriceLastOrder() {
      double dPriceLastOrder = 0;
      if(m_nOrderCount > 0) {
         // 获取最近一次订单的货币对的价格
         dPriceLastOrder = m_orderInfo[m_nOrderCount - 1].m_Prices;
      }
      return dPriceLastOrder;
   }
   
   bool CheckForCloseByOffset(double dOffset)
   {
      bool bRet = false;
      string logMsg;
      int xPos = m_xBasePos;
      int yPos = m_yBasePos + 2;
      
      string strPriceDiff = StringFormat("获利：当前 %s， 最高 %s", 
                           DoubleToString(m_dCurrentProfits, 2),DoubleToString(m_dMostProfits, 2));
      if(m_nDirect == OP_BUY) {
         ShowText("ProfitsBuy", strPriceDiff, clrYellow, xPos, yPos); 
      }else
      {
         ShowText("ProfitsSell", strPriceDiff, clrYellow, xPos, yPos);  
      }
      
      if(m_nOrderCount > 0)
      {
         // 获取最近一次订单的货币对的价格
         double dPriceLastOrder = m_orderInfo[m_nOrderCount - 1].m_Prices;
         if(m_nDirect == OP_BUY)
         {
           // 此时需要获取本种货币对的卖价
           RefreshRates();
           double dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
           
           
           // 用现在的价格减去以前的价格，看差值是否超过设置的点位
           double dCurrentOffset = dCurrentPrice - dPriceLastOrder;
           if(dCurrentOffset >= dOffset)
           {
              // 如果当前的价格差扩大到大于设置的获利点位，则满足平仓条件
              LogInfo("====================== Close Buy Orders Condition OK ===========================");
              logMsg = StringFormat("Direct = %d, Offset = %s, Order Price = %s, Current Price = %s",
                               m_nDirect, DoubleToString(dCurrentOffset, 4),  
                               DoubleToString(dPriceLastOrder, 5), DoubleToString(dCurrentPrice, 5));
              LogInfo(logMsg);
              
              double  dProfits = CalcTotalProfits(m_orderInfo, m_nOrderCount);
              logMsg = StringFormat("Profits: %s->%s, Most: %s", 
                        m_symbol, DoubleToString(dProfits, 2), DoubleToString(m_dMostProfits, 2));
              LogInfo(logMsg);
              bRet = true;
           }
             
         }else
         {
           // 此时需要获取两种货币对的买价
           RefreshRates();
           double dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
                     
           // 用以前的价格差减去现在的价格差，看缩小的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPrice - dPriceLastOrder;
           if(dCurrentOffset < 0 &&  MathAbs(dCurrentOffset) >= dOffset)
           {
              // 如果当前的价格缩小到小于设置的获利点位，则满足平仓条件
              LogInfo("====================== Close Sell Orders Condition OK ===========================");
              logMsg = StringFormat("Direct = %d, Offset = %s, Order Price = %s, Current Price = %s",
                               m_nDirect, DoubleToString(dCurrentOffset, 4),  
                               DoubleToString(dPriceLastOrder, 5), DoubleToString(dCurrentPrice, 5));
              LogInfo(logMsg);
                               
              double  dProfits = CalcTotalProfits(m_orderInfo, m_nOrderCount);
              logMsg = StringFormat("Profits: %s->%s, Most: %s", 
                        m_symbol, DoubleToString(dProfits, 2), DoubleToString(m_dMostProfits, 2));
              LogInfo(logMsg);
              bRet = true;
           }
         }
      }
      
      return bRet;
   }
   
   int CloseOrders()
   {
      int nRet = 0;
      if(!m_bExistOrderProtecting) {
         // 当有保护仓时，先平掉保护仓
         CloseProtectingOrder();
      }    
      // 只有当没有保存仓时，才可以平仓 
      for(int i = m_nOrderCount - 1; i >= 0; i--)
      {
         CloseOrder(m_orderInfo[i]);
        
      }
      
      if(m_nOrderCount == 1) {
         m_nLoopCount++;
      } else {
         m_nLoopCount = -1;
      }
      
      m_dMostProfits = 0.0;
      m_dLeastProfits = 0.0;
      m_dPreProfits = 0;
      m_dCurrentProfits = 0;
      
      m_dPriceProtectingLine = 0;
      m_nHtoLCount = 0;
      
         
      return nRet;
   }
   
    bool CheckForAppend(double dOffset, double dFactor, double dBackword)
    {
       // 检查亏损值是否达到最大并反弹10%
       bool bByDeficit = CheckForAppendByDeficit(dBackword);
        
       // 检查点位差是否超过预设的值（如0.003）
       // 第一次加仓条件是基础加仓价格差，如果已有订单，后面的加仓条件以此累加       
       double dOffsetAdjust = dOffset;
       if(m_nOrderCount > 0) {
            //  dOffsetAdjust = dOffset + dFactor * (m_nSymbol2OrderCount - 1);
            
            // 2018-05-20, 重新改回按比例计算加仓价格差
            dOffsetAdjust = dOffset * MathPow(dFactor, m_nOrderCount - 1);
       } 
       
       
       
       bool bByOffset = CheckForAppendByOffset(dOffsetAdjust);
       return bByDeficit && bByOffset;
    }
    
    bool CheckForAppendByDeficit(double dBackword)
    {
      bool bRet = false;
      // double dRealAppendLevel = MathMin(-MathAbs(dDeficitSetting), m_dLeastProfits * (1 - dBackword));
      double dRealAppendLevel = m_dLeastProfits * (1 - dBackword);
      
      if(dRealAppendLevel < 0) {      
         int xPos = m_xBasePos;
         int yPos = m_yBasePos + 4;
         string strPriceDiff = StringFormat("亏损：当前 %s， 最低 %s, 移动加仓 %s", 
                              DoubleToString(m_dCurrentProfits, 2),DoubleToString(m_dLeastProfits, 2), 
                              DoubleToString(dRealAppendLevel, 2));
         if(m_nDirect == OP_BUY) {
            ShowText("DeficitBuy", strPriceDiff, clrYellow, xPos, yPos); 
         }else
         {
            ShowText("DeficitSell", strPriceDiff, clrYellow, xPos, yPos);  
         }
         
         if(m_dPreProfits < dRealAppendLevel && m_dCurrentProfits >= dRealAppendLevel)
         {
            LogInfo("++++++++++++++++++++++ CheckForAppendByDeficit Condition1 OK ++++++++++++++++++++++++++++++");
            LogInfo(strPriceDiff);
            bRet = true;
         }
      }
         
      return bRet;
    }
    
    bool CheckForAppendByOffset(double dOffset)
    {
      bool bRet = false;
      string logMsg;
 
      if(m_nOrderCount > 0)
      {
         // 获取最近一次订单的货币对的价格
         double dPriceLastOrder = m_orderInfo[m_nOrderCount - 1].m_Prices;
        
         if(m_nDirect == OP_BUY)
         {
           // 此时需要获取两种货币对的卖价
           RefreshRates();
           double dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
                     
           // 用现在的价格差减去以前的价格差，看扩大的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPrice - dPriceLastOrder;
           logMsg = StringFormat("Direct = %d, Offset = %s, Order Price = %s, Current Price = %s",
                               m_nDirect, DoubleToString(dCurrentOffset, 4), 
                               DoubleToString(dPriceLastOrder, 5), DoubleToString(dCurrentPrice, 5));    
           //OutputLog(logMsg); 
           int xPos = m_xBasePos;
           int yPos = m_yBasePos + 3;
           string strPriceDiff = StringFormat("价格差：%s - %s = %s", 
                                 DoubleToString(dCurrentPrice, 4),DoubleToString(dPriceLastOrder, 4), 
                                 DoubleToString(dCurrentOffset, 4));
           ShowText("PriceDiffBuy", strPriceDiff, clrYellow, xPos, yPos);     
           if(dCurrentOffset < 0 &&  MathAbs(dCurrentOffset) > dOffset)
           {
              // 如果当前的价格跌了，并且跌的幅度超过设置的点位，则满足加仓条件
              LogInfo("++++++++++++++++++++++ CheckForAppendByOffset Condition2 OK ++++++++++++++++++++++++++++++");
              LogInfo(logMsg);
              bRet = true;
           }
             
         }else
         {
           // 此时需要获取两种货币对的买价
           RefreshRates();
           double  dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
          
                 
           // 用以前的价格差减去现在的价格差，看缩小的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPrice - dPriceLastOrder;
          logMsg = StringFormat("Direct = %d, Offset = %s, Order Price = %s, Current Price = %s",
                               m_nDirect, DoubleToString(dCurrentOffset, 4),
                               DoubleToString(dPriceLastOrder, 5), DoubleToString(dCurrentPrice, 5));     
           //OutputLog(logMsg);
           int xPos = m_xBasePos;
           int yPos = m_yBasePos + 3;
           string strPriceDiff = StringFormat("价格差：%s - %s = %s", 
                                 DoubleToString(dCurrentPrice, 4),DoubleToString(dPriceLastOrder, 4), 
                                 DoubleToString(dCurrentOffset, 4));
           ShowText("PriceDiffSell", strPriceDiff, clrYellow, xPos, yPos);    
           if(dCurrentOffset >= dOffset)
           {
              // 如果当前的价格缩小到小于设置的获利点位，则满足平仓条件
              LogInfo("++++++++++++++++++++++ CheckForAppendByOffset Condition2 OK ++++++++++++++++++++++++++++++");
              LogInfo(logMsg);
              bRet = true;
           }
         }
       }
       return bRet;
    }
    
    bool CheckForOpenProtecting(double dOffset) {
      bool bRet = false;
      if(!m_bExistOrderProtecting) {
         if(m_nOrderCount >= m_nMaxOrderCount) {
            double dPriceLastOrder = GetPriceLastOrder();
            double dCurrentPrice = Close[0];
            if(m_nDirect == OP_BUY) {
               if(dPriceLastOrder - dCurrentPrice > dOffset) {
                  bRet = true;
               }
            }else {
               if(dCurrentPrice - dPriceLastOrder > dOffset) {
                   bRet = true;
               }
            }
         }
      }
      return bRet;
    }
    
    int GetProtectingOrderDirect() {
         int nDirect = OP_BUY;
         if(m_nDirect == OP_BUY)
         {
           nDirect = OP_SELL;
         }
         return nDirect;
    }
    
    void OpenProtectingOrder(bool bLight) {      
         // 启动保护仓模式
         int nDirect = GetProtectingOrderDirect();
         double dCurrentPrice = 0;            
         if(nDirect == OP_BUY)
         {
            // 此时需要获取货币对的买价          
            dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
         }else {
            // 此时需要获取货币对的卖价          
            dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
         }
         m_dPrePriceAfterProtecting = dCurrentPrice;
                    
         string comment = StringFormat("%s(%s)", m_commentProtecting, DoubleToString(dCurrentPrice, 4));
         double dLots = m_dLots * m_dProtectingMultiple;
         if(bLight) {
            dLots = LIGHT_LOTS;
         }
         OpenOrder(m_symbol, nDirect, dLots, comment, m_nMagicNum);
         m_bExistOrderProtecting = true; 
        
         m_dProtectingMostProfits = 0;
         m_dProtectingLeastProfits = 0;
         m_dPrePriceAfterProtecting = 0;
         
         string logMsg;
         LogInfo("PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP");  
         logMsg = StringFormat("[%s]Price = %s, dir = %d, lots = %s, Cnt = %d", 
                  __FUNCTION__, DoubleToString(dCurrentPrice, 4), 
                  nDirect, DoubleToString(dLots, 2), m_nHtoLCount);
         LogInfo(logMsg);      
   }
   
   bool CheckForCloseProtectingOrder(double dOffset) {
      bool bRet = false;
      if(m_bExistOrderProtecting) {
         double dPriceLastOrder = m_orderProtecting.m_Prices;
         double dCurrentPrice = Close[0];
         if(m_nDirect == OP_BUY) {
            if(dCurrentPrice - dPriceLastOrder > dOffset) {
               bRet = true;
            }
         }else {
            if(dPriceLastOrder - dCurrentPrice > dOffset) {
                bRet = true;
            }
         }
      }
      return bRet;
   }
   
   void CloseProtectingOrder() {
      CloseOrder(m_orderProtecting);
      m_bExistOrderProtecting = false;    
   }
   
    // 检查重仓->轻仓的转化条件，以跨越保护仓的价格为标准
   bool CheckForHeavyToLightByCrossOver(double dMinOffset)
   {
      bool bRet = false;
      if(m_bExistOrderProtecting)
      {
         // 注：重仓亏损时才转化为轻仓
         int nDirect = GetProtectingOrderDirect();
         double dProtectingPrice = m_orderProtecting.m_Prices;
         double dCurrentPrice = Close[0];
         int xPos = m_xBasePos;
         int yPos = m_yBasePos + 6;
         string strPriceDiff = StringFormat("价格差：%s - %s = %s", 
                              DoubleToString(dCurrentPrice, 4),DoubleToString(dProtectingPrice, 4), 
                              DoubleToString(dCurrentPrice - dProtectingPrice, 4));
         if(nDirect == OP_BUY) {
            ShowText("PriceDiffBuyProtect", strPriceDiff, clrYellow, xPos, yPos);            
            if(dProtectingPrice - dCurrentPrice > dMinOffset) {
               bRet = true;
            }
         }else {
            ShowText("PriceDiffSellProtect", strPriceDiff, clrYellow, xPos, yPos);
             if(dCurrentPrice - dProtectingPrice > dMinOffset) {
                bRet = true;
             }
         }
        
      }
      return bRet;
   }
   
   // 检查重仓->轻仓的转化条件，以价格差为标准
   bool CheckForHeavyToLightByOffset(double dMinOffset)
   {
      bool bRet = false;
      if(m_bExistOrderProtecting)
      {
         int nDirect = GetProtectingOrderDirect();
         double dProtectingPrice = m_orderProtecting.m_Prices;
         double dCurrentPrice = Close[0];
         string logMsg;
         logMsg = StringFormat("[%s]OrderPrice = %s, CurrentPrice = %d, lots = %s, Cnt = %d", 
                  __FUNCTION__, DoubleToString(dProtectingPrice, 4), 
                  DoubleToString(dCurrentPrice, 2), 
                  DoubleToString(m_orderProtecting.m_Lots, 2),
                  m_nHtoLCount);
         //LogInfo(logMsg); 
         
         if(nDirect == OP_BUY)
         {
           if(dCurrentPrice - dProtectingPrice > dMinOffset) {
               bRet = true;
           }
         }else
         {
           if(dProtectingPrice - dCurrentPrice > dMinOffset) {
               bRet = true;
           }
         }         
       }
       return bRet;
   }
   
   // 检查重仓->轻仓的转化条件，以获利金额为标准
   bool CheckForHeavyToLightByProfits(double dTakeProfits, double dBackword)
   {
      bool bRet = false;
      if(m_bExistOrderProtecting)
      {
         double dCurrentProfits =  m_orderProtecting.m_Profits;
         double dRealStandardProfits = m_dProtectingMostProfits * (1 - dBackword);
         string strPriceDiff = StringFormat("当前：%s，最高：%s，移动止盈：%s", 
                              DoubleToString(dCurrentProfits, 2),
                              DoubleToString(m_dProtectingMostProfits, 2),
                              DoubleToString(dRealStandardProfits, 2));
                              
         int xPos = m_xBasePos;
         int yPos = m_yBasePos + 7;
         int nDirect = GetProtectingOrderDirect();
         if(nDirect == OP_BUY) {
            ShowText("ProfitsForBuyProtect", strPriceDiff, clrYellow, xPos, yPos); 
         }else {
            ShowText("ProfitsForSellrotect", strPriceDiff, clrYellow, xPos, yPos); 
         }  
         if(dCurrentProfits > dTakeProfits) {
            if(m_dPreProtectingProfits > dRealStandardProfits && dCurrentProfits <= dRealStandardProfits)
            {
               bRet = true;
            }             
         }         
       }
       m_dPreProtectingProfits = m_orderProtecting.m_Profits;
       return bRet;
   }
   
  
   
   // 检查轻仓->重仓的转化条件，以价格差为标准
   bool CheckForLightToHeavyByOffset(double dOffset)
   {
      bool bRet = false;
      if(m_bExistOrderProtecting)
      {
         // 注：轻仓亏损时才转化为重仓
         int nDirect = GetProtectingOrderDirect();
         double dProtectingPrice = m_orderProtecting.m_Prices;
         double dCurrentPrice = Close[0];
         string logMsg;
         logMsg = StringFormat("[%s]OrderPrice = %s, CurrentPrice = %d, lots = %s, Cnt = %d", 
                  __FUNCTION__, DoubleToString(dProtectingPrice, 4), 
                  DoubleToString(dCurrentPrice, 2), 
                  DoubleToString(m_orderProtecting.m_Lots, 2),
                  m_nHtoLCount);
         //LogInfo(logMsg);       
         if(nDirect == OP_BUY) {            
            if(dProtectingPrice - dCurrentPrice > dOffset) {
               bRet = true;
            }
         }else {
            if(dCurrentPrice - dProtectingPrice > dOffset) {
                bRet = true;
            }
         }
      }
      return bRet;
   }
   
   // 检查轻仓->的重仓转化条件，以获利金额为标准
   bool CheckForLightToHeavyByProfits(double dBackword)
   {
      bool bRet = false;
      if(m_bExistOrderProtecting)
      {
         double dCurrentProfits =  m_orderProtecting.m_Profits;
         if(dCurrentProfits < 0 && m_dProtectingLeastProfits < 0) {
            // 当亏损缩小时，需要转为重仓
            double dRealStandardProfits = m_dProtectingLeastProfits * (1 - dBackword);
            if(m_dPreProtectingProfits < dRealStandardProfits && dCurrentProfits >= dRealStandardProfits)
            {
               bRet = true;
            }             
         }         
       }
       m_dPreProtectingProfits = m_orderProtecting.m_Profits;
       return bRet;
   }
   
   // 检查轻仓->重仓的转化条件，以跨越保护仓的价格为标准
   bool CheckForLightToHeavyByCrossOver(double dMinOffset)
   {
      bool bRet = false;
      if(m_bExistOrderProtecting)
      {
         int nDirect = GetProtectingOrderDirect();
         double dProtectingPrice = m_orderProtecting.m_Prices;
         double dCurrentPrice = Close[0];  
         int xPos = m_xBasePos;
         int yPos = m_yBasePos + 6;
         string strPriceDiff = StringFormat("价格差：%s - %s = %s", 
                              DoubleToString(dCurrentPrice, 4),DoubleToString(dProtectingPrice, 4), 
                              DoubleToString(dCurrentPrice - dProtectingPrice, 4));    
         if(nDirect == OP_BUY) { 
            ShowText("PriceDiffBuyProtect", strPriceDiff, clrYellow, xPos, yPos);             
            if(dCurrentPrice - dProtectingPrice > dMinOffset) {
               bRet = true;
            }
         }else {
             ShowText("PriceDiffSellProtect", strPriceDiff, clrYellow, xPos, yPos);
             if(dProtectingPrice - dCurrentPrice > dMinOffset) {
                bRet = true;
             }
         }
      }
      return bRet;
   }
   
   void ProcessProtectingOrder(double dH2LProfits,  // 重转轻：盈利条件1：最小价格波动值
                     double dH2LProfits2, // 重转轻：盈利条件2：最小价格波动值，再次平仓时使用 
                     double dH2LRollback, // 重转轻：价格反转条件：最小价格波动值
                     int nH2LMax,         // 重转轻：条件：最大次数限制
                     double dH2LBackword, // 重转轻：条件：获利回调系数
                     double dTakeProfits, // 重转轻：条件：最少获利金额
                     double dL2HStoploss, // 轻转重：止损条件：最小价格波动值
                     double dL2HRollback, // 轻转重：价格反转条件：最小价格波动值
                     double dL2HBackword //  重转轻：条件：止损回调系数
                     ) {
     if(m_nProtectingMode == PM_HEAVY) {
         if(CheckForHeavyToLightByCrossOver(dH2LRollback))  {
            // 当前价格反转造成的重变轻
            string logMsg;
            LogInfo("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");  
            logMsg = ("Heavy -> Light, Cross over.");
            if(m_bProtectingAlreaTakeProfits) {
               // 重仓已经获利了，可以转轻仓
               LogInfo(logMsg);
               CloseOrder(m_orderProtecting);
               OpenProtectingOrder(true);
               m_nHtoLCount++;
            }
         }else {   
            double dOffsetToCheck = dH2LProfits;
            if(m_bProtectingAlreaTakeProfits) {
               dOffsetToCheck = dH2LProfits2;
            }        
            bool bOffset = CheckForHeavyToLightByOffset(dOffsetToCheck);
            bool bProfits = CheckForHeavyToLightByProfits(dTakeProfits, dH2LBackword);
            if(bOffset && bProfits) {
               string logMsg;
               LogInfo("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");   
               logMsg = ("Heavy -> Light, Take profits.");
               LogInfo(logMsg);
                // 满足重仓转轻仓的条件，平掉重仓，开轻仓
                // 重仓获利后，转为轻仓
               CloseOrder(m_orderProtecting);
               OpenProtectingOrder(true);
               m_bProtectingAlreaTakeProfits = true; // 重仓获利了结，转轻仓
               m_nHtoLCount = 0; 
            }
         }
      }else if(m_nProtectingMode == PM_LIGHT) {
         if(CheckForLightToHeavyByCrossOver(dL2HRollback)) {
            string logMsg;
            LogInfo("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");    
            logMsg = ("Light -> Heavy , Cross over.");
            LogInfo(logMsg);
             // 当前价格跨过了轻仓的价格，需要转为重仓
            CloseOrder(m_orderProtecting);
            OpenProtectingOrder(false);
         }else {
            bool bOffset = CheckForLightToHeavyByOffset(dL2HStoploss);
            bool bProfits = CheckForLightToHeavyByProfits(dL2HBackword);
            if(bOffset && bProfits) {
               string logMsg;
               LogInfo("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");   
               logMsg = ("Light -> Heavy , Stop loss.");
               LogInfo(logMsg);
               // 满足重仓转轻仓的条件，平掉重仓，开轻仓
               // 持有轻仓时，持续亏损，当亏损从最大有所缩小时，转为重
               CloseOrder(m_orderProtecting);
               OpenProtectingOrder(false);
               m_bProtectingAlreaTakeProfits = false;
               m_nHtoLCount = 0;
            }
         }
      }
   }
   
private:
   void OutputLog(string msg)
   {
      //if(gTickCount % 20 == 0)
      if(gIsNewBar)
      {
            LogInfo(msg);
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
   
   int OpenOrder(string symbol, int orderType, double dLots, string comment, int nMagicNum)
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
               int ticket = OrderSend(symbol, OP_BUY, lots, fAskPrice, 3, 0, 0, comment, nMagicNum, 0, clrRed); 
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
         {
            // Open sell order
            double lots = dLots;
            while(true)
            {
               RefreshRates();
               double fBidPrice = MarketInfo(symbol, MODE_BID);
               int ticket = OrderSend(symbol, OP_SELL, lots, fBidPrice, 3, 0, 0, comment, nMagicNum, 0, clrGreen); 
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
      LogInfo(logMsg);   
         
     
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
            LogInfo(logMsg);
            if(OrderClose(ticket, lots, fPrice, 3, clr))
            {                 
               break;
         
            } else
            {
               int nErr = GetLastError(); // 平仓失败 :( 
               logMsg = StringFormat("%s => Close buy order Error: %d, ticket = %d.",
                         __FUNCTION__, nErr, ticket);
               LogInfo(logMsg);
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
   
   double CalcTotalProfits(const COrderInfo & orderInfo [], int orderCnt)
   {
      double fProfits = 0;
      for(int i = 0; i < orderCnt; i++)
      {
         fProfits += orderInfo[i].m_Profits;
      }         
         
      return fProfits;
   }
   
   void ShowText(string label, string text, color clr, int x, int y)
   {
      if(gTickCount % 4 == 0) {
            string labelWithPrefix = IntegerToString(m_nMagicNum) + label;
            DisplayText(labelWithPrefix, text, clr, x, y);
      }
   }
   
};

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

#define LIGHT_LOTS 0.01

string OpName [] = 
{
   "买单",
   "卖单"
};

class CMartinOrder
{
public:
   int m_nTimeFrame;
   
   int m_nMainDirect;
   int m_nSubDirect;
   
   string m_strMainDirect;
   string m_strSubDirect;
   
   int m_nSymbol1OrderCount;
   int m_nSymbol2OrderCount;
   double m_dLots2;
   double m_dLots1;
   
   string m_symbol1;
   string m_symbol2;
   
   string m_comment;
   int m_nMagicNum;
   double m_dBaseOpenLots;
   double m_dMultiple;
   double m_dMultipleFactor;
   int m_nMaxOrderCount;
   
   double m_dMultipleManual;
   double m_dMultipleFactorManual;
   
   double m_dMostProfits;
   double m_dPreProfits;
   double m_dCurrentProfits;
   
   double m_dLeastProfits;
   
   COrderInfo m_orderInfo2[MAX_ORDER_COUNT];
   COrderInfo m_orderInfo1[MAX_ORDER_COUNT];
   
   bool m_bShowText;
   
   double m_dLotsForAppendManual;
   int m_nMaxOrderCountForAuto;
   
private:
   int m_xBasePos;
   int m_yBasePos;
   
public:
   CMartinOrder(string symbol1, string symbol2, int nDirect, 
               int nTimeFrame, double dBaseOpenLots, double dMultiple, double dMultipleFactor,
               double dMultipleManual, double dMultipleFactorManual,
               int nMaxOrderCount, int nMaxOrderCountForAuto, double dLotsForAppendManual) 
   {
      m_bShowText = true;
      m_nMainDirect = nDirect;
      m_nSymbol1OrderCount = 0;
      m_nSymbol2OrderCount = 0;
      m_dLots2 = 0.0;
      m_dLots1 = 0.0;
      m_symbol1 = symbol1;
      m_symbol2 = symbol2;
      m_nTimeFrame = nTimeFrame;
      m_dBaseOpenLots = dBaseOpenLots;
      m_dMultiple = dMultiple;
      m_dMultipleFactor = dMultipleFactor;
      m_nMaxOrderCount = nMaxOrderCount;
      m_dMostProfits = 0.0;
      m_dLeastProfits = 0.0;
      m_dPreProfits = 0;
      m_dCurrentProfits = 0;
      m_dLotsForAppendManual = dLotsForAppendManual;
      m_nMaxOrderCountForAuto = nMaxOrderCountForAuto;
      
      m_dMultipleManual = dMultipleManual;
      m_dMultipleFactorManual = dMultipleFactorManual;
      
      if(nDirect == OP_BUY)
      {
         m_comment = "Buy";
         m_nSubDirect = OP_SELL;
         m_strMainDirect = "Buy";
         m_strSubDirect = "Sell";
         m_nMagicNum = 10000;
         m_xBasePos = 0;
         m_yBasePos = 0;
      }else
      {
         m_comment = "Sell";
         m_nSubDirect = OP_BUY;
         m_strMainDirect = "Sell";
         m_strSubDirect = "Buy";
         m_nMagicNum = 20000;
         m_xBasePos = 0;
         m_yBasePos = 4;
      }
   }
   
   void CleanOrders() 
   {
      int i = 0;
      for(i = 0; i < m_nSymbol1OrderCount; i++)
      {
         m_orderInfo1[i].clear();
      }
      m_nSymbol1OrderCount = 0;
      for(i = 0; i < m_nSymbol2OrderCount; i++)
      {
         m_orderInfo2[i].clear();
      }
      m_nSymbol2OrderCount = 0;
   }
   
   int LoadAllOrders()
   {
      string logMsg;
      int xPos = m_xBasePos;
      int yPos = m_yBasePos;
      if(m_nMainDirect == OP_BUY) {
         string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, gTickCount);
         ShowText("Version", strVersion, clrYellow, xPos, yPos);
      }
          
      CleanOrders();
        
      m_nSymbol2OrderCount = LoadOrders(m_symbol2, m_nMainDirect, m_comment, m_nMagicNum, 
                                       m_orderInfo2, m_nSymbol2OrderCount, m_dLots2 );
      m_nSymbol1OrderCount = LoadOrders(m_symbol1,  m_nSubDirect, m_comment, m_nMagicNum, 
                                          m_orderInfo1, m_nSymbol1OrderCount, m_dLots1);
      if(m_nSymbol2OrderCount > 0)
      {
         logMsg = StringFormat("%s => MainSymbol = %s, orderType = %d(%s), comment = %s, orderCount = %d, Lots = %s ",
                                  __FUNCTION__, m_symbol2, m_nMainDirect, m_strMainDirect,
                                  m_comment, m_nSymbol2OrderCount, DoubleToString(m_dLots2, 2));
         //OutputLog(logMsg);
         
         logMsg = StringFormat("%s => MainSymbol = %s, lastOrderPrice = %s, lastLots = %s ",
                                  __FUNCTION__, m_symbol2, DoubleToString(m_orderInfo2[m_nSymbol2OrderCount - 1].m_Prices, 5), 
                                  DoubleToString(m_orderInfo2[m_nSymbol2OrderCount - 1].m_Lots, 2));
         //OutputLog(logMsg);
         
         if(m_nSymbol1OrderCount > 0)
         {
            logMsg = StringFormat("%s => SubSymbol = %s, orderType = %d(%s), comment = %s, orderCount = %d, Lots = %s ",
                                     __FUNCTION__, m_symbol1, m_nSubDirect, m_strSubDirect,
                                    m_comment, m_nSymbol1OrderCount, DoubleToString(m_dLots1, 2));
            //OutputLog(logMsg);
            
            logMsg = StringFormat("%s => SubSymbol = %s, lastOrderPrice = %s, lastLots = %s ",
                                     __FUNCTION__, m_symbol1, DoubleToString(m_orderInfo1[m_nSymbol1OrderCount - 1].m_Prices, 5), 
                                     DoubleToString(m_orderInfo1[m_nSymbol1OrderCount - 1].m_Lots, 2));
            //OutputLog(logMsg);
            double  dProfits2 = CalcTotalProfits(m_orderInfo2, m_nSymbol2OrderCount);
            double  dProfits1 = CalcTotalProfits(m_orderInfo1, m_nSymbol1OrderCount);
       
            m_dPreProfits = m_dCurrentProfits;
            m_dCurrentProfits = dProfits2 + dProfits1;
            if(m_dCurrentProfits > m_dMostProfits) 
            {
               m_dMostProfits = m_dCurrentProfits;
            }
            
            if(m_dCurrentProfits < m_dLeastProfits) 
            {
               m_dLeastProfits = m_dCurrentProfits;
            }            
                        
            yPos++;
            string strProfits;
            if(m_nMainDirect == OP_BUY)
            {
               strProfits = StringFormat("【多方】订单数：%d，手数：%s", 
                        m_nSymbol2OrderCount, DoubleToString(m_dLots2, 2));
               ShowText("OrderStatisticsBuy", strProfits, clrYellow, xPos, yPos);
            }else
            {
               strProfits = StringFormat("【空方】订单数：%d，手数：%s", 
                        m_nSymbol2OrderCount, DoubleToString(m_dLots2, 2));
               ShowText("OrderStatisticsSell", strProfits, clrYellow, xPos, yPos);
             }
         }         
      }      
      return m_nSymbol2OrderCount;
   }
   
   int OpenOrders(int nOrderCnt)
   {
       double accMargin =  AccountMargin();//AccountMargin();
       double equity = AccountEquity();
         
       if(CheckFreeMargin && accMargin != 0 && (equity / accMargin) < (AdvanceRate / 100) ) {
              string logMsg = StringFormat("%s => Free margin not enouth: margin = %s, equity = %s.",
                              __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(equity,3));
              LogWarn(logMsg); 
              return -1; 
       }
   
      if(nOrderCnt < m_nMaxOrderCount)
      {
         double dLots = NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, nOrderCnt) * MathPow(m_dMultipleFactor, nOrderCnt), 2);
                 
         // 当现有的订单数超过5时，不在做指数级加仓，仅仅做等量加仓
         if(nOrderCnt >= m_nMaxOrderCountForAuto) {
            if(m_dLotsForAppendManual > 0) {
               dLots = m_dLotsForAppendManual;
            }else {
               dLots = NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, m_nMaxOrderCountForAuto) * MathPow(m_dMultipleFactor, m_nMaxOrderCountForAuto), 2);
            }
         }
         
         if(nOrderCnt > 0)
         {
            string logMsg = StringFormat("Append: MainDirect = %s, lots = %s",
                               OpName[m_nMainDirect], DoubleToString(dLots, 2));
            LogInfo(logMsg);
         }else 
         {
            string logMsg = StringFormat("New: MainDirect = %s, lots = %s",
                               OpName[m_nMainDirect], DoubleToString(dLots, 2));
            LogInfo(logMsg);
         }
         
         double dCurrentPriceDiff = 0;
         RefreshRates();
         if(m_nMainDirect == OP_BUY)
         {
           // 此时需要获取两种货币对的卖价          
           double dBidPrice1 = MarketInfo(m_symbol1, MODE_ASK);
           double dBidPrice2 = MarketInfo(m_symbol2, MODE_ASK);
           dCurrentPriceDiff = dBidPrice2 - dBidPrice1;
         }else {
            // 此时需要获取两种货币对的卖价          
           double dBidPrice1 = MarketInfo(m_symbol1, MODE_BID);
           double dBidPrice2 = MarketInfo(m_symbol2, MODE_BID);
           dCurrentPriceDiff = dBidPrice2 - dBidPrice1;
         }
         string comment = StringFormat("%s(%s)", m_comment, DoubleToString(dCurrentPriceDiff, 5));
         OpenOrder(m_symbol2, m_nMainDirect, dLots, comment, m_nMagicNum);
         OpenOrder(m_symbol1, m_nSubDirect, dLots, comment, m_nMagicNum);
      }
      return 0;
   }
   
   int OpenOrders(bool bMicroLots)
   {
      double accMargin = AccountMargin();
      double equity = AccountEquity();
      if(CheckFreeMargin && accMargin != 0 && (equity / accMargin) < (AdvanceRate / 100) ) {
              string logMsg = StringFormat("%s => Free margin not enouth: margin = %s, equity = %s.",
                              __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(equity,3));
              LogWarn(logMsg); 
              return -1; 
       }
       
      if(m_nSymbol2OrderCount < m_nMaxOrderCount)
      {
         double dLots = NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, m_nSymbol2OrderCount) * MathPow(m_dMultipleFactor, m_nSymbol2OrderCount), 2);
         
         // 当现有的订单数超过2时，不在做指数级加仓，仅仅做等量加仓
         if(m_nSymbol2OrderCount >= m_nMaxOrderCountForAuto) {
            if(m_dLotsForAppendManual > 0) {
               int nAppendManualTime = m_nSymbol2OrderCount - m_nMaxOrderCountForAuto;
               dLots = NormalizeDouble(m_dLotsForAppendManual * MathPow(m_dMultipleManual, nAppendManualTime), 2);
               if(nAppendManualTime > 1) {
                   dLots = NormalizeDouble(dLots * MathPow(m_dMultipleFactorManual, nAppendManualTime), 2);
               }
            }else {
               dLots = NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, m_nMaxOrderCountForAuto) * MathPow(m_dMultipleFactor, m_nMaxOrderCountForAuto), 2);
            }
         }
         
         if(bMicroLots)
            dLots = LIGHT_LOTS;
         if(m_nSymbol2OrderCount > 0)
         {
            string logMsg = StringFormat("Append: MainDirect = %s, lots = %s",
                               OpName[m_nMainDirect], DoubleToString(dLots, 2));
            LogInfo(logMsg);
         }else 
         {
            string logMsg = StringFormat("New: MainDirect = %s, lots = %s",
                               OpName[m_nMainDirect], DoubleToString(dLots, 2));
            LogInfo(logMsg);
         }
         
         double dCurrentPriceDiff = 0;
         RefreshRates();
         if(m_nMainDirect == OP_BUY)
         {
           // 此时需要获取两种货币对的卖价          
           double dBidPrice1 = MarketInfo(m_symbol1, MODE_ASK);
           double dBidPrice2 = MarketInfo(m_symbol2, MODE_ASK);
           dCurrentPriceDiff = dBidPrice2 - dBidPrice1;
         }else {
            // 此时需要获取两种货币对的卖价          
           double dBidPrice1 = MarketInfo(m_symbol1, MODE_BID);
           double dBidPrice2 = MarketInfo(m_symbol2, MODE_BID);
           dCurrentPriceDiff = dBidPrice2 - dBidPrice1;
         }
         string comment = StringFormat("%s(%s)", m_comment, DoubleToString(dCurrentPriceDiff, 5));
         OpenOrder(m_symbol2, m_nMainDirect, dLots, comment, m_nMagicNum);
         OpenOrder(m_symbol1, m_nSubDirect, dLots, comment, m_nMagicNum);
      }
      return 0;
   }
   // 双向套利平仓条件
   bool CheckForClose1(double dOffset, double dProfitsSetting, double dBackword)
   {
      if(m_nSymbol2OrderCount <= 1)
      {
         // return CheckForCloseByOffset(dOffset) && CheckForCloseByProfits(0, dBackword);
         // 单笔订单，只检查价格差
         // CheckForCloseByProfits(0, dBackword);
         return CheckForCloseByOffset(dOffset) && CheckForCloseByProfits(0, dBackword);
      }else
      {
         return  CheckForCloseByProfits(dProfitsSetting, dBackword);
      }
      
   }
   
   // 双向趋势平仓条件
   bool CheckForClose2(double dOffset, double dProfitsSetting, double dBackword)
   {
      if(m_nSymbol2OrderCount <= 1)
      {
         return CheckForCloseByOffset(dOffset) && CheckForCloseByProfits(0, dBackword);
      }else
      {
         return  CheckForCloseByProfits(dProfitsSetting, dBackword);
      }
      
   }
   
   // 单向平仓条件
   bool CheckForCloseEx(double dOffset, double dProfitsSetting, double dBackword)
   {
      return CheckForCloseByOffset(dOffset) &&   CheckForCloseByProfits(dProfitsSetting, dBackword);
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
      if(m_nMainDirect == OP_BUY) {
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
   
   bool CheckForCloseByOffset(double dOffset)
   {
      bool bRet = false;
      string logMsg;
      int xPos = m_xBasePos;
      int yPos = m_yBasePos + 2;
      
      string strPriceDiff = StringFormat("获利：当前 %s， 最高 %s", 
                           DoubleToString(m_dCurrentProfits, 2),DoubleToString(m_dMostProfits, 2));
      if(m_nMainDirect == OP_BUY) {
         ShowText("ProfitsBuy", strPriceDiff, clrYellow, xPos, yPos); 
      }else
      {
         ShowText("ProfitsSell", strPriceDiff, clrYellow, xPos, yPos);  
      }
      
      if(m_nSymbol2OrderCount > 0)
      {
         // 获取最近一次订单的两种货币对的价格
         double dPrice1 = m_orderInfo1[m_nSymbol1OrderCount - 1].m_Prices;
         double dPrice2 = m_orderInfo2[m_nSymbol2OrderCount - 1].m_Prices;
         double dPriceDiff = dPrice2 - dPrice1;
         
         if(m_nMainDirect == OP_BUY)
         {
           // 此时需要获取两种货币对的卖价
           RefreshRates();
           double dBidPrice1 = MarketInfo(m_symbol1, MODE_BID);
           double dBidPrice2 = MarketInfo(m_symbol2, MODE_BID);
           double dCurrentPriceDiff = dBidPrice2 - dBidPrice1;
           
           // 用现在的价格差减去以前的价格差，看扩大的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPriceDiff - dPriceDiff;
           if(dCurrentOffset >= dOffset)
           {
              // 如果当前的价格差扩大到大于设置的获利点位，则满足平仓条件
              LogInfo("====================== Close Buy Orders Condition OK ===========================");
              logMsg = StringFormat("MainDirect = %d, Offset = %s, Price1 = %s, Price2 = %s, PriceDiff = %s",
                               m_nMainDirect, DoubleToString(dCurrentOffset, 4),  
                               DoubleToString(dPrice1, 5), DoubleToString(dPrice2, 5), DoubleToString(dPriceDiff, 4));
              LogInfo(logMsg);
              
              logMsg = StringFormat("Bid1 = %s, Bid2 = %s, Diff = %s",
                               DoubleToString(dBidPrice1, 5), DoubleToString(dBidPrice2, 5), DoubleToString(dCurrentPriceDiff, 4));
     
              LogInfo(logMsg);
              double  dProfits2 = CalcTotalProfits(m_orderInfo2, m_nSymbol2OrderCount);
              double  dProfits1 = CalcTotalProfits(m_orderInfo1, m_nSymbol1OrderCount);
              logMsg = StringFormat("Profits: %s->%s, %s->%s, Total：%s, Most: %s", 
                        m_symbol1, DoubleToString(dProfits1, 2), m_symbol2, DoubleToString(dProfits2, 2), 
                        DoubleToString(dProfits1 + dProfits2, 2),DoubleToString(m_dMostProfits, 2));
              LogInfo(logMsg);
              bRet = true;
           }
             
         }else
         {
           // 此时需要获取两种货币对的买价
           RefreshRates();
           double dAskPrice1 = MarketInfo(m_symbol1, MODE_ASK);
           double dAskPrice2 = MarketInfo(m_symbol2, MODE_ASK);
           // 计算当前价格差
           double dCurrentPriceDiff = dAskPrice2 - dAskPrice1;
           
           // 用以前的价格差减去现在的价格差，看缩小的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPriceDiff - dPriceDiff;
           if(dCurrentOffset < 0 &&  MathAbs(dCurrentOffset) >= dOffset)
           {
              // 如果当前的价格缩小到小于设置的获利点位，则满足平仓条件
              LogInfo("====================== Close Sell Orders Condition OK ===========================");
              logMsg = StringFormat("MainDirect = %d, Offset = %s, Price1 = %s, Price2 = %s, PriceDiff = %s",
                               m_nMainDirect, DoubleToString(dCurrentOffset, 4),   
                               DoubleToString(dPrice1, 5), DoubleToString(dPrice2, 5), DoubleToString(dPriceDiff, 4));
              LogInfo(logMsg);
                               
              logMsg = StringFormat("Ask1 = %s, Ask2 = %s, Diff = %s",
                               DoubleToString(dAskPrice1, 5), DoubleToString(dAskPrice2, 5), 
                               DoubleToString(dCurrentPriceDiff, 4));
         
              LogInfo(logMsg);
              double  dProfits2 = CalcTotalProfits(m_orderInfo2, m_nSymbol2OrderCount);
              double  dProfits1 = CalcTotalProfits(m_orderInfo1, m_nSymbol1OrderCount);
              logMsg = StringFormat("Profits: %s->%s, %s->%s, Total：%s, Most: %s", 
                        m_symbol1, DoubleToString(dProfits1, 2), m_symbol2, DoubleToString(dProfits2, 2), 
                        DoubleToString(dProfits1 + dProfits2, 2), DoubleToString(m_dMostProfits, 2));
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
      
      for(int i = m_nSymbol2OrderCount - 1; i >= 0; i--)
      {
         CloseOrder(m_orderInfo2[i]);
         CloseOrder(m_orderInfo1[i]);       
      }   
      
      m_dMostProfits = 0.0;
      m_dLeastProfits = 0.0;
      m_dPreProfits = 0;
      m_dCurrentProfits = 0;
         
      return nRet;
   }
   
    bool CheckForAppend(double dOffset, double dFactor, double dBackword)
    {
       // 检查亏损值是否达到最大并反弹10%
       bool bByDeficit = CheckForAppendByDeficit(dBackword);
        
       // 检查点位差是否超过预设的值（如0.003）
       // 第一次加仓条件是基础加仓价格差，如果已有订单，后面的加仓条件以此累加       
       double dOffsetAdjust = dOffset;
       if(m_nSymbol2OrderCount > 0) {
            //  dOffsetAdjust = dOffset + dFactor * (m_nSymbol2OrderCount - 1);
            
            // 2018-05-20, 重新改回按比例计算加仓价格差
            dOffsetAdjust = dOffset * MathPow(dFactor, m_nSymbol2OrderCount - 1);
       } 
       
       
       
       bool bByOffset = CheckForAppendByOffset(dOffsetAdjust);
       return bByDeficit && bByOffset;
    }
    
    bool CheckForAppendEx(double dOffset, double dFactor)
    {
       // 检查点位差是否超过预设的值（如0.003）
       // 第一次加仓条件是基础加仓价格差，如果已有订单，后面的加仓条件以此累加       
       double dOffsetAdjust = dOffset;
       if(m_nSymbol2OrderCount > 0) {
            //  dOffsetAdjust = dOffset + dFactor * (m_nSymbol2OrderCount - 1);
            // 2018-05-20, 重新改回按比例计算加仓价格差
            dOffsetAdjust = dOffset * MathPow(dFactor, m_nSymbol2OrderCount - 1);
       } 
       
       bool bByOffset = CheckForAppendByOffset(dOffsetAdjust);
       return bByOffset;
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
         if(m_nMainDirect == OP_BUY) {
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
 
      if(m_nSymbol2OrderCount > 0)
      {
         // 获取最近一次订单的两种货币对的价格
         double dPrice1 = m_orderInfo1[m_nSymbol1OrderCount - 1].m_Prices;
         double dPrice2 = m_orderInfo2[m_nSymbol2OrderCount - 1].m_Prices;
         double dPriceDiff = dPrice2 - dPrice1;
         
         if(m_nMainDirect == OP_BUY)
         {
           // 此时需要获取两种货币对的卖价
           RefreshRates();
           double dBidPrice1 = MarketInfo(m_symbol1, MODE_BID);
           double dBidPrice2 = MarketInfo(m_symbol2, MODE_BID);
           double dCurrentPriceDiff = dBidPrice2 - dBidPrice1;
           
           // 用现在的价格差减去以前的价格差，看扩大的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPriceDiff - dPriceDiff;
           logMsg = StringFormat("%s: MainDirect = %d, Offset = %s, Price1 = %s, Price2 = %s, PriceDiff = %s <=> Bid1 = %s, Bid2 = %s, Diff = %s",
                               __FUNCTION__, m_nMainDirect, DoubleToString(dCurrentOffset, 4),  
                               DoubleToString(dPrice1, 5), DoubleToString(dPrice2, 5), DoubleToString(dPriceDiff, 4),
                               DoubleToString(dBidPrice1, 5), DoubleToString(dBidPrice2, 5), DoubleToString(dCurrentPriceDiff, 4));
           //OutputLog(logMsg); 
           int xPos = m_xBasePos;
           int yPos = m_yBasePos + 3;
           string strPriceDiff = StringFormat("价格差：%s - %s = %s", 
                                 DoubleToString(dCurrentPriceDiff, 4),DoubleToString(dPriceDiff, 4), DoubleToString(dCurrentOffset, 4));
           ShowText("PriceDiffBuy", strPriceDiff, clrYellow, xPos, yPos);     
           if(dCurrentOffset < 0 &&  MathAbs(dCurrentOffset) > dOffset)
           {
              // 如果当前的价格差缩小了，并且缩小的幅度超过设置的点位，则满足加仓条件
              LogInfo("++++++++++++++++++++++ CheckForAppendByOffset Condition2 OK ++++++++++++++++++++++++++++++");
              LogInfo(logMsg);
              bRet = true;
           }
             
         }else
         {
            // 此时需要获取两种货币对的买价
            RefreshRates();
           double dAskPrice1 = MarketInfo(m_symbol1, MODE_ASK);
           double dAskPrice2 = MarketInfo(m_symbol2, MODE_ASK);
           // 计算当前价格差
           double dCurrentPriceDiff = dAskPrice2 - dAskPrice1;
           
           // 用以前的价格差减去现在的价格差，看缩小的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPriceDiff - dPriceDiff;
           logMsg = StringFormat("%s: MainDirect = %d, Offset = %s, Price1 = %s, Price2 = %s, PriceDiff = %s <=> Ask1 = %s, Ask2 = %s, Diff = %s",
                               __FUNCTION__,  m_nMainDirect, DoubleToString(dCurrentOffset, 4),   
                               DoubleToString(dPrice1, 5), DoubleToString(dPrice2, 5), DoubleToString(dPriceDiff, 4),
                               DoubleToString(dAskPrice1, 5), DoubleToString(dAskPrice2, 5), DoubleToString(dCurrentPriceDiff, 4));
           //OutputLog(logMsg);
           int xPos = m_xBasePos;
           int yPos = m_yBasePos + 3;
           string strPriceDiff = StringFormat("价格差：%s - %s = %s", 
                                 DoubleToString(dCurrentPriceDiff, 4),DoubleToString(dPriceDiff, 4), DoubleToString(dCurrentOffset, 4));
           
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
      if(m_bShowText && gTickCount % 4 == 0) {
            DisplayText(label, text, clr, x, y);
      }
   }
   
};

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
#include "PubVar.mqh"

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
#define MAX_ORDER_COUNT 200

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
  
   double m_dMostProfits;
   double m_dPreProfits;
   double m_dCurrentProfits;
   double m_dLeastProfits;
   
   double m_dMostProfitsForInPassing;
   double m_dPreProfitsForInPassing;
   double m_dCurrentProfitsForInPassing;
   double m_dLeastProfitsForInPassing;
   
   COrderInfo m_orderInfo2[MAX_ORDER_COUNT];
   COrderInfo m_orderInfo1[MAX_ORDER_COUNT];
   
   bool m_bShowText;
   bool m_bComment;
   
   double m_dMaxPriceDiff;
   double m_dMinPriceDiff;
private:
   int m_xBasePos;
   int m_yBasePos;
   
public:
   CMartinOrder(string symbol1, string symbol2, int nDirect, 
               int nTimeFrame, OptParam & optParam[], int nMagicNumber) 
   {
      // m_bShowText = true;
      // m_bComment = true;
      m_bShowText = gbShowText;
      m_bComment = gbShowComment;
      
      m_nMainDirect = nDirect;
      m_nSymbol1OrderCount = 0;
      m_nSymbol2OrderCount = 0;
      m_dLots2 = 0.0;
      m_dLots1 = 0.0;
      m_symbol1 = symbol1;
      m_symbol2 = symbol2;
      m_nTimeFrame = nTimeFrame;
      
      m_dMostProfits = 0.0;
      m_dLeastProfits = 0.0;
      m_dPreProfits = 0;
      m_dCurrentProfits = 0;
      
      m_dMostProfitsForInPassing = 0.0;
      m_dLeastProfitsForInPassing = 0.0;
      m_dPreProfitsForInPassing = 0;
      m_dCurrentProfitsForInPassing = 0;
      
      m_dMaxPriceDiff = 0;
      m_dMinPriceDiff = 0;
     
      if(nDirect == OP_BUY)
      {
         m_comment = "Buy";
         m_nSubDirect = OP_SELL;
         m_strMainDirect = "Buy";
         m_strSubDirect = "Sell";
         m_nMagicNum = nMagicNumber;
         m_xBasePos = 0;
         m_yBasePos = 0;
      }else
      {
         m_comment = "Sell";
         m_nSubDirect = OP_BUY;
         m_strMainDirect = "Sell";
         m_strSubDirect = "Buy";
         m_nMagicNum = nMagicNumber;
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
   
   int LoadAllOrders(OptParam &optParam[], int optMax)
   {
      string logMsg;
      int xPos = m_xBasePos;
      int yPos = m_yBasePos;
      if(m_nMainDirect == OP_BUY) {
         string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, gTickCount);
         ShowVersion("Version", strVersion, clrYellow, xPos, yPos);
      }
      
      yPos++;
          
      CleanOrders();
     
      m_nSymbol2OrderCount = LoadOrders(m_symbol2, m_nMainDirect, m_comment, m_nMagicNum, 
                                       m_orderInfo2, m_nSymbol2OrderCount, m_dLots2 );
      m_nSymbol1OrderCount = LoadOrders(m_symbol1,  m_nSubDirect, m_comment, m_nMagicNum, 
                                          m_orderInfo1, m_nSymbol1OrderCount, m_dLots1);
                                          
      if(m_nSymbol2OrderCount >= 0 && m_nSymbol1OrderCount >= 0 && m_nSymbol1OrderCount != m_nSymbol2OrderCount) {      
         //  订单数量有错误，显示错误提示信息
         string strProfits;
         if(m_nMainDirect == OP_BUY)
         {
            strProfits = StringFormat("【多方】订单数量有错误，请检查！！！(%s/%s = %d/%d)", 
                     m_symbol2, m_symbol1, m_nSymbol2OrderCount, m_nSymbol1OrderCount);
            ShowWarning("OrderStatisticsBuy", strProfits, clrYellow, xPos, yPos);
            LogImportant(strProfits);
         }else
         {
            strProfits = StringFormat("【空方】订单数量有错误，请检查！！！(%s/%s = %d/%d)", 
                     m_symbol2, m_symbol1, m_nSymbol2OrderCount, m_nSymbol1OrderCount);
            ShowWarning("OrderStatisticsSell", strProfits, clrYellow, xPos, yPos);
            LogImportant(strProfits);
         }
         
          if(m_nSymbol1OrderCount > m_nSymbol2OrderCount) {
            logMsg = StringFormat("%s => MainSymbol = %s, ticket = %d, StopLossForAlone = %s, TakeProfitForAlone = %s ",
                                  __FUNCTION__, m_symbol1, m_orderInfo1[m_nSymbol1OrderCount - 1].m_Ticket,
                                  DoubleToString(StopLossForAlone, 5), 
                                  DoubleToString(TakeProfitForAlone, 5));
            LogImportant(logMsg);
            AddLiteralStopsByPips(m_orderInfo1[m_nSymbol1OrderCount - 1].m_Ticket, StopLossForAlone, TakeProfitForAlone);
         }  
         
         if(m_nSymbol2OrderCount > m_nSymbol1OrderCount) {
            logMsg = StringFormat("%s => MainSymbol = %s, ticket = %d, StopLossForAlone = %s, TakeProfitForAlone = %s ",
                                  __FUNCTION__, m_symbol2, m_orderInfo2[m_nSymbol2OrderCount - 1].m_Ticket,
                                  DoubleToString(StopLossForAlone, 5), 
                                  DoubleToString(TakeProfitForAlone, 5));
            LogImportant(logMsg);
            AddLiteralStopsByPips(m_orderInfo2[m_nSymbol2OrderCount - 1].m_Ticket, StopLossForAlone, TakeProfitForAlone);
         } 
             
         return -1;
      }
      
      // 清除掉警告信息
      if(m_nMainDirect == OP_BUY) {
         ShowWarning("OrderStatisticsBuy", "", clrYellow, xPos, yPos);
      }else {
         ShowWarning("OrderStatisticsSell", "", clrYellow, xPos, yPos);
      }
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
            double  dProfits2 = 0;
            double  dProfits1 = 0;
            
            double  dProfits2ForInPassing = 0;
            double  dProfits1ForInPassing = 0;
            
            int nStage = CalcStageNumber(m_nSymbol1OrderCount, optParam, optMax);
            int nAppendNumber = CalcAppendNumber(nStage, m_nSymbol1OrderCount, optParam, optMax);
            
            /*
            if(CheckAllOrdersInLastStage && nStage == optMax - 1) {
               // 当当前阶段是阶段1，或者（是最后一个阶段并且要求检查所有订单获利情况）
               // 此时，计算所有订单的获利情况
               if(optParam[nStage].m_EnableInPassing) {
                  dProfits2 = CalcTotalProfits2(m_orderInfo2, m_nSymbol2OrderCount, nAppendNumber);
                  dProfits1 = CalcTotalProfits2(m_orderInfo1, m_nSymbol1OrderCount, nAppendNumber);      
               } else {
                  dProfits2 = CalcTotalProfits(m_orderInfo2, m_nSymbol2OrderCount);
                  dProfits1 = CalcTotalProfits(m_orderInfo1, m_nSymbol1OrderCount);
               }
            }else {
               // 当当前的阶段数大于1或小于max时，仅计算本阶段的获利值 
               if(optParam[nStage].m_EnableInPassing) {
                  // 启用带单功能，只计算本阶段最近一笔和第一笔订单的盈利金额  
                  dProfits2 = CalcTotalProfits3(m_orderInfo2, m_nSymbol2OrderCount, nAppendNumber);
                  dProfits1 = CalcTotalProfits3(m_orderInfo1, m_nSymbol1OrderCount, nAppendNumber);      
               } else {            
                  dProfits2 = CalcTotalProfits2(m_orderInfo2, m_nSymbol2OrderCount, nAppendNumber);
                  dProfits1 = CalcTotalProfits2(m_orderInfo1, m_nSymbol1OrderCount, nAppendNumber);
               }              
            }
            */
       
            dProfits2 = CalcTotalProfits2(m_orderInfo2, m_nSymbol2OrderCount, nAppendNumber);
            dProfits1 = CalcTotalProfits2(m_orderInfo1, m_nSymbol1OrderCount, nAppendNumber);
            
            dProfits2ForInPassing = CalcTotalProfits3(m_orderInfo2, m_nSymbol2OrderCount, nAppendNumber);
            dProfits1ForInPassing = CalcTotalProfits3(m_orderInfo1, m_nSymbol1OrderCount, nAppendNumber);  
                  
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
               
               
            m_dPreProfitsForInPassing = m_dCurrentProfitsForInPassing;
            m_dCurrentProfitsForInPassing = dProfits2ForInPassing + dProfits1ForInPassing;
            if(m_dCurrentProfitsForInPassing > m_dMostProfitsForInPassing) 
            {
               m_dMostProfitsForInPassing = m_dCurrentProfitsForInPassing;
            }
            
            if(m_dCurrentProfitsForInPassing < m_dLeastProfitsForInPassing) 
            {
               m_dLeastProfitsForInPassing = m_dCurrentProfitsForInPassing;
            }             
                  
           
            string strProfits;
            if(m_nMainDirect == OP_BUY)
            {
               strProfits = StringFormat("【多方】订单数：%d，手数：%s，阶段：%d，轮数：%d", 
                        m_nSymbol2OrderCount, DoubleToString(m_dLots2, 2), nStage + 1, nAppendNumber);
               ShowText("OrderStatisticsBuy", strProfits, clrYellow, xPos, yPos);
            }else
            {
               strProfits = StringFormat("【空方】订单数：%d，手数：%s，阶段：%d，轮数：%d",
                        m_nSymbol2OrderCount, DoubleToString(m_dLots2, 2), nStage + 1,  nAppendNumber);
               ShowText("OrderStatisticsSell", strProfits, clrYellow, xPos, yPos);
             }
         }         
      }  
      return m_nSymbol2OrderCount;
   }
   
           
   int OpenOrders(int nOrderCnt, OptParam &optParam[], int optCount)
   {
      double accMargin = AccountMargin();
      double equity = AccountEquity();
      if(CheckFreeMargin && accMargin != 0 && (equity / accMargin) < (AdvanceRate / 100) ) {
              string logMsg = StringFormat("%s => Free margin not enouth: margin = %s, equity = %s.",
                              __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(equity,3));
              LogWarn(logMsg); 
              return -1; 
       }
       
      int nMaxOrderCount = CalcMaxOrderCount(optParam, optCount);
      if(m_nSymbol2OrderCount < nMaxOrderCount)
      {
         int nStage = CalcStageNumberForOpenOrder(m_nSymbol2OrderCount, optParam, optCount);
         if(nStage < optCount) {
             int nAppendTime = nOrderCnt;
             OptParam param = optParam[nStage];
             
             double dLots1 = NormalizeDouble(param.m_BaseOpenLots1 * MathPow(param.m_MultipleForAppend, nAppendTime) * MathPow(param.m_MulipleFactorForAppend, nAppendTime), 2);
             double dLots2 = NormalizeDouble(param.m_BaseOpenLots2 * MathPow(param.m_MultipleForAppend, nAppendTime) * MathPow(param.m_MulipleFactorForAppend, nAppendTime), 2);  
           
            if(m_nSymbol2OrderCount > 0)
            {
               string logMsg = StringFormat("Append: MainDirect = %s, lots = %s",
                                  OpName[m_nMainDirect], DoubleToString(dLots1, 2));
               LogInfo(logMsg);
            }else 
            {
               string logMsg = StringFormat("New: MainDirect = %s, lots = %s",
                                  OpName[m_nMainDirect], DoubleToString(dLots1, 2));
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
            string comment = StringFormat("S%d-%d-%s(%s)", nStage + 1, nAppendTime +1, 
                                          m_comment, DoubleToString(dCurrentPriceDiff, 5));
            if(!m_bComment) {
               comment = "";
            }
            OpenOrder(m_symbol2, m_nMainDirect, dLots2, comment, m_nMagicNum);
            OpenOrder(m_symbol1, m_nSubDirect, dLots1, comment, m_nMagicNum);
            
            m_dMostProfits = 0.0;
            m_dLeastProfits = 0.0;
            m_dPreProfits = 0;
            m_dCurrentProfits = 0;
            
            m_dMostProfitsForInPassing = 0.0;
            m_dLeastProfitsForInPassing = 0.0;
            m_dPreProfitsForInPassing = 0;
            m_dCurrentProfitsForInPassing = 0;
         }
      }
      return 0;
   }
   
   // 计算第1阶段到第（optCount-1）阶段订单的总数
   int CalcMaxOrderCount( OptParam &optParam[], int optCount) {
      int nMaxCount = 0;
      for(int i = 0; i < optCount; i++) {
         nMaxCount += optParam[i].m_AppendMax;
      }
      return nMaxCount;
   }
   
   // 计算当前所处的阶段数索引
   int CalcStageNumber(int nOrderCount, OptParam &optParam[], int optCount) {
      int nStage = 0;
      int nMaxCount = 0;
      for(int i = 0; i < optCount; i++) {
         nMaxCount += optParam[i].m_AppendMax;
         if(nOrderCount > nMaxCount) {
            nStage = i + 1;
         }
      }
      return nStage;
   }
   
    // 为开仓计算阶段数索引
   int CalcStageNumberForOpenOrder(int nOrderCount, OptParam &optParam[], int optCount) {
      int nStage = 0;
      int nMaxCount = 0;
      for(int i = 0; i < optCount; i++) {
         nMaxCount += optParam[i].m_AppendMax;
         if(nOrderCount >= nMaxCount) {
            nStage = i + 1;
         }
      }
      return nStage;
   }
   
   // 计算所传入阶段的订单数，即索引数为nStage的阶段已经有多少订单了
   int CalcAppendNumber(int nStage, int nOrderCount, OptParam &optParam[], int optCount) {
      int nAppendNumber = 0;
      if(nStage == 0) {
         nAppendNumber = nOrderCount;
      }else {
         int nCount = CalcMaxOrderCount(optParam, nStage);
         nAppendNumber = nOrderCount - nCount;
      }      
      return nAppendNumber;
   }
   
   int OpenOrdersEx(bool bMicroLots, OptParam &optParam[], int optCount)
   {
      double accMargin = AccountMargin();
      double equity = AccountEquity();
      if(CheckFreeMargin && accMargin != 0 && (equity / accMargin) < (AdvanceRate / 100) ) {
              string logMsg = StringFormat("%s => Free margin not enouth: margin = %s, equity = %s.",
                              __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(equity,3));
              LogWarn(logMsg); 
              return -1; 
       }
      
      int nMaxOrderCount = CalcMaxOrderCount(optParam, optCount);
      if(m_nSymbol2OrderCount < nMaxOrderCount)
      {
         int nStage = CalcStageNumberForOpenOrder(m_nSymbol2OrderCount, optParam, optCount);
         if(nStage < optCount) {
             int nAppendTime = CalcAppendNumber(nStage, m_nSymbol2OrderCount, optParam, optCount);
             OptParam param = optParam[nStage];
             double dLots1 = NormalizeDouble(param.m_BaseOpenLots1 * MathPow(param.m_MultipleForAppend, nAppendTime) * MathPow(param.m_MulipleFactorForAppend, nAppendTime), 2);
             double dLots2 = NormalizeDouble(param.m_BaseOpenLots2 * MathPow(param.m_MultipleForAppend, nAppendTime) * MathPow(param.m_MulipleFactorForAppend, nAppendTime), 2);
            if(bMicroLots) {
               dLots1 = LIGHT_LOTS;
               dLots2 = LIGHT_LOTS;
            }
            
            if(m_nSymbol2OrderCount > 0)
            {
               string logMsg = StringFormat("Append: MainDirect = %s, lots = %s",
                                  OpName[m_nMainDirect], DoubleToString(dLots1, 2));
               LogInfo(logMsg);
            }else 
            {
               string logMsg = StringFormat("New: MainDirect = %s, lots = %s",
                                  OpName[m_nMainDirect], DoubleToString(dLots1, 2));
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
            string comment = StringFormat("S%d-%d-%s(%s)", nStage + 1, nAppendTime +1, 
                                          m_comment, DoubleToString(dCurrentPriceDiff, 5));

            if(!m_bComment) {
               comment = "";
            }                                         
            OpenOrder(m_symbol2, m_nMainDirect, dLots2, comment, m_nMagicNum);
            OpenOrder(m_symbol1, m_nSubDirect, dLots1, comment, m_nMagicNum);
            
            m_dMostProfits = 0.0;
            m_dLeastProfits = 0.0;
            m_dPreProfits = 0;
            m_dCurrentProfits = 0;
         }
      }
      return 0;
   }
   
   bool CheckStopLoss(double dStopLossRete) {
      bool ret = false;
      double balance = AccountBalance(); // 余额                 
      double endity = AccountEquity(); // 净值      
      double dProfits2 = CalcTotalProfits(m_orderInfo2, m_nSymbol2OrderCount);
      double dProfits1 = CalcTotalProfits(m_orderInfo1, m_nSymbol1OrderCount);    
      double dProfits = dProfits1 + dProfits2;
      if(dProfits < 0 &&  MathAbs(dProfits) / balance > dStopLossRete) {
         ret = true;
      }
      return ret;
   }
   
   // 双向套利平仓条件
   bool CheckForClose1(double dOffset, double dProfitsSetting, double dBackword, bool bInPassing)
   {
      if(dProfitsSetting == 0.0)
      {
         // return CheckForCloseByOffset(dOffset) && CheckForCloseByProfits(0, dBackword);
         // 单笔订单，只检查价格差
         // CheckForCloseByProfits(0, dBackword);
         return CheckForCloseByOffset(dOffset) && CheckForCloseByProfits(0, dBackword, bInPassing);
      }else
      {
         return  CheckForCloseByProfits(dProfitsSetting, dBackword, bInPassing);
      }
      
   }
   
   // 单向平仓条件
   bool CheckForCloseEx(double dOffset, double dProfitsSetting, double dBackword)
   {
      return CheckForCloseByOffset(dOffset) &&   CheckForCloseByProfits(dProfitsSetting, dBackword, false);
   }
   
   bool CheckForCloseByProfits(double dProfitsSetting, double dBackword, bool bInPassing)
   {
      bool bRet = false;
      double dRealStandardProfits = MathMax(dProfitsSetting, m_dMostProfits * (1 - dBackword));
      if(bInPassing) {
          dRealStandardProfits = MathMax(dProfitsSetting, m_dMostProfitsForInPassing * (1 - dBackword));
      }
      
      int xPos = m_xBasePos;
      int yPos = m_yBasePos + 2;
      string strPriceDiff = StringFormat("获利：当前 %s， 最高 %s, 移动止盈 %s", 
                           DoubleToString(m_dCurrentProfits, 2),DoubleToString(m_dMostProfits, 2), 
                           DoubleToString(dRealStandardProfits, 2));
                           
      if(bInPassing) {
         strPriceDiff = StringFormat("获利：当前 %s， 最高 %s, 移动止盈 %s", 
                           DoubleToString(m_dCurrentProfitsForInPassing, 2),DoubleToString(m_dMostProfitsForInPassing, 2), 
                           DoubleToString(dRealStandardProfits, 2));
      }
      
      if(m_nMainDirect == OP_BUY) {
         ShowText("ProfitsBuy", strPriceDiff, clrYellow, xPos, yPos); 
      }else
      {
         ShowText("ProfitsSell", strPriceDiff, clrYellow, xPos, yPos);  
      }
      
      if(bInPassing) {
         if(m_dCurrentProfitsForInPassing > dProfitsSetting)
         {        
            if(m_dPreProfitsForInPassing > dRealStandardProfits 
               && m_dCurrentProfitsForInPassing <= dRealStandardProfits)
            {
               string logMsg = StringFormat("CheckForCloseByProfits：standard = %s, Pre = %s, Current = %s", 
                        DoubleToString(dRealStandardProfits, 2), DoubleToString(m_dPreProfitsForInPassing, 2), 
                        DoubleToString(m_dCurrentProfitsForInPassing, 2) );
               LogInfo(logMsg);
               bRet = true;
            }          
         } 
      }else {
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
   
   int CloseOrders(int nLatestCnt, bool bEnableInPassing)
   {
      int nRet = 0;
      int nCnt = 0;
      if(bEnableInPassing) {
         int nIndexLast = m_nSymbol2OrderCount - 1;
         if(nIndexLast >= 0) {
            CloseOrder(m_orderInfo2[nIndexLast]);
            CloseOrder(m_orderInfo1[nIndexLast]);
         }
         int nFirstInStage = m_nSymbol2OrderCount - nLatestCnt - 1;
         if(nIndexLast != nFirstInStage && nFirstInStage >= 0) {
            CloseOrder(m_orderInfo2[nFirstInStage]);
            CloseOrder(m_orderInfo1[nFirstInStage]);
         }
      }else {
         for(int i = m_nSymbol2OrderCount - 1; i >= 0; i--)
         {
            CloseOrder(m_orderInfo2[i]);
            CloseOrder(m_orderInfo1[i]);
            nCnt++;
            if(nCnt >= nLatestCnt) {
               break;
            }       
         }  
      } 
      
      m_dMostProfits = 0.0;
      m_dLeastProfits = 0.0;
      m_dPreProfits = 0;
      m_dCurrentProfits = 0;
      
      m_dMostProfitsForInPassing = 0.0;
      m_dLeastProfitsForInPassing = 0.0;
      m_dPreProfitsForInPassing = 0;
      m_dCurrentProfitsForInPassing = 0;
         
      return nRet;
   }
   
    bool CheckForAppend(double dOffset, double dFactor, double dBackword, int nAppendTime, bool bFactor)
    {
       // 检查亏损值是否达到最大并反弹10%
       bool bByDeficit = CheckForAppendByDeficit(dBackword);
        
       // 检查点位差是否超过预设的值（如0.003）
       // 第一次加仓条件是基础加仓价格差，如果已有订单，后面的加仓条件以此累加       
       double dOffsetAdjust = dOffset;
       if(bFactor) {
            //  dOffsetAdjust = dOffset + dFactor * (m_nSymbol2OrderCount - 1);
            
            // 2018-05-20, 重新改回按比例计算加仓价格差
            dOffsetAdjust = dOffset * MathPow(dFactor, nAppendTime - 1);
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
           double dBidPrice1 = MarketInfo(m_symbol1, MODE_ASK);
           double dBidPrice2 = MarketInfo(m_symbol2, MODE_ASK);
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
           double dSpread1 = GetSpread(m_symbol1);
           double dSpread2 = GetSpread(m_symbol2);
           double dSpread = MathMax(dSpread1, dSpread2);
           string strPriceDiff = StringFormat("价格差：%s - %s = %s, 点差：%s", 
                                 DoubleToString(dCurrentPriceDiff, 4),DoubleToString(dPriceDiff, 4), 
                                 DoubleToString(dCurrentOffset, 4), DoubleToString(dSpread, 5));
           ShowText("PriceDiffBuy", strPriceDiff, clrYellow, xPos, yPos);     
           if(dCurrentOffset < 0 &&  MathAbs(dCurrentOffset) > dOffset)
           {
              if(dSpread > SpreadMax) {
                 string strSpreadTooBig = StringFormat("点差太大, %s(%s), %s(%s)",
                                 m_symbol1, DoubleToString(dSpread1, 5),
                                 m_symbol2, DoubleToString(dSpread2, 5));
                 ShowWarning("PriceDiffBuy", strPriceDiff, clrYellow, xPos, yPos);  
                 LogImportant(strSpreadTooBig);
              }else {
                 // 如果当前的价格差缩小了，并且缩小的幅度超过设置的点位，则满足加仓条件
                 LogInfo("++++++++++++++++++++++ CheckForAppendByOffset Condition2 OK ++++++++++++++++++++++++++++++");
                 LogInfo(logMsg);
                 bRet = true;
              }
           }
             
         }else
         {
            // 此时需要获取两种货币对的买价
            RefreshRates();
           double dAskPrice1 = MarketInfo(m_symbol1, MODE_BID);
           double dAskPrice2 = MarketInfo(m_symbol2, MODE_BID);
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
           double dSpread1 = GetSpread(m_symbol1);
           double dSpread2 = GetSpread(m_symbol2);
           double dSpread = MathMax(dSpread1, dSpread2);
           string strPriceDiff = StringFormat("价格差：%s - %s = %s, 点差：%s", 
                                 DoubleToString(dCurrentPriceDiff, 4),DoubleToString(dPriceDiff, 4), 
                                 DoubleToString(dCurrentOffset, 4), DoubleToString(dSpread, 5));
           
           ShowText("PriceDiffSell", strPriceDiff, clrYellow, xPos, yPos);    
           if(dCurrentOffset >= dOffset)
           {
             
              if(dSpread > SpreadMax) {
                 string strSpreadTooBig = StringFormat("点差太大, %s(%s), %s(%s)",
                                 m_symbol1, DoubleToString(dSpread1, 5),
                                 m_symbol2, DoubleToString(dSpread2, 5));
                 ShowWarning("PriceDiffSell", strPriceDiff, clrYellow, xPos, yPos);  
                 LogImportant(strSpreadTooBig);
              }else {
                 // 如果当前的价格缩小到小于设置的获利点位，则满足平仓条件
                 LogInfo("++++++++++++++++++++++ CheckForAppendByOffset Condition2 OK ++++++++++++++++++++++++++++++");
                 LogInfo(logMsg);
                 bRet = true;
              }
           }
         }
       }
       return bRet;
    }
    
    double CalsUnrealizedLoss() {
      double currentBalance = AccountBalance(); // 余额
      double currentEquity = AccountEquity(); // 净值
      return currentBalance - currentEquity; // 浮亏
    }
   
    bool IsAllowBuy() {
      double dAskPrice1 = MarketInfo(m_symbol1, MODE_BID);
      double dAskPrice2 = MarketInfo(m_symbol2, MODE_BID);
      double dCurrentPriceDiff = dAskPrice2 - dAskPrice1;
      
      if(EnablePriceLimitForLongSideMin && EnablePriceLimitForLongSideMax) {
         // 既设置了高限，又设置了低限，则需要两个条件都满足
         if(dCurrentPriceDiff > PriceLimitForLongSideMin 
               && dCurrentPriceDiff < PriceLimitForLongSideMax) {           
            return true;
        }
        return false;
      }
        
      if(EnablePriceLimitForLongSideMax) {  
        // 如果设置了高限，只有低于此价格才允许开多单   
        if(dCurrentPriceDiff < PriceLimitForLongSideMax) {
            return true;
        }
        return false;
      }
      
      if(EnablePriceLimitForLongSideMin) {     
        // 如果设置了低限，只有高于此价格才允许开多单
        if(dCurrentPriceDiff > PriceLimitForLongSideMin) {
            return true;
        }
        return false;
      }
      return true;
   }
   
   bool IsAllowSell() {
      RefreshRates();
      double dBidPrice1 = MarketInfo(m_symbol1, MODE_BID);
      double dBidPrice2 = MarketInfo(m_symbol2, MODE_BID);
      // 计算当前价格差
      double dCurrentPriceDiff = dBidPrice2 - dBidPrice1;
      
      if(EnablePriceLimitForShortSideMin && EnablePriceLimitForShortSideMax) {
         // 既设置了高限，又设置了低限，则需要两个条件都满足
         if(dCurrentPriceDiff > PriceLimitForShortSideMin 
               && dCurrentPriceDiff < PriceLimitForShortSideMax) {           
            return true;
        }
        return false;
      }
        
      if(EnablePriceLimitForShortSideMin) {
        // 设置了空单价格低限
        if(dCurrentPriceDiff > PriceLimitForShortSideMin) {
            // 只有价格差高于此低限，才允许开空单
            return true;
        }
        return false;
      }
      
      if(EnablePriceLimitForShortSideMax) {
        // 设置了空单价格高限
       if(dCurrentPriceDiff < PriceLimitForShortSideMax) {
            // 只有价格差低于此高限，才允许开空单
            return true;
        }
        return false;
      }
      
      return true;
   }
   
   bool CheckForAutoCloseAll(double baseBalance, double preEquity, double leaseEquity,
                            double mostEquity, double realTargetEquity) {
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);   // 净值 
      int xPos = m_xBasePos;
      int yPos = m_yBasePos + 6;
      string strAutoCloseAll = StringFormat("净值：本金:%s,当前:%s", 
               DoubleToString(baseBalance, 2),
               DoubleToString(currentEquity, 2));
      ShowText("AutoCloseAll1", strAutoCloseAll, clrYellow, xPos, yPos);   
      
      strAutoCloseAll = StringFormat("最低:%s,最高:%s,止盈:%s", 
               DoubleToString(leaseEquity, 2),
               DoubleToString(mostEquity, 2),
               DoubleToString(realTargetEquity, 2));
      ShowText("AutoCloseAll2", strAutoCloseAll, clrYellow, xPos, yPos + 1);     
           
      if(currentEquity > baseBalance && preEquity > realTargetEquity && currentEquity <= realTargetEquity) {
         return true;
      }
      return false;
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
      LogImportant(logMsg); 
      logMsg = StringFormat("%s => Symbol = %s, orderType = %d, Lots = %s, magic = %d, comment = %s,  ",
                                  __FUNCTION__, symbol, orderType,
                                  DoubleToString(dLots, 2), nMagicNum, comment);
      LogImportant(logMsg);
      
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
                  LogImportant(logMsg);
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
               double fBidPrice = MarketInfo(symbol, MODE_BID);
               int ticket = OrderSend(symbol, OP_SELL, lots, fBidPrice, 3, 0, 0, comment, nMagicNum, 0, clrGreen); 
               if(ticket > 0) 
               {
                   logMsg = StringFormat("%s => Open sell order: Symbol = %s, Price = %s, Lots = %s",
                                  __FUNCTION__, symbol, 
                                  DoubleToString(fBidPrice, 5), DoubleToString(lots, 2));
                   LogImportant(logMsg);
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
   
   int AddLiteralStopsByPips(int iTicketToGo, double iSL, double iTP)
   {
     string logMsg;
     logMsg = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> AddLiteralStopsByPips >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
     LogImportant(logMsg); 
     logMsg = StringFormat("%s => ticket = %d, iSL = %s, iTP = %s",
                                  __FUNCTION__, iTicketToGo, 
                                  DoubleToString(iSL, 5),
                                  DoubleToString(iTP, 5));
     LogImportant(logMsg); 
     int iDigits, iNumRetries, iError;
     double dSL, dTP;
     
     if(OrderSelect(iTicketToGo, SELECT_BY_TICKET)==true) // SELECT_BY_TICKET
       {
         string symbol = OrderSymbol(); 
         double price = OrderOpenPrice();
         int iType = OrderType();
          // is server or context busy - try n times to submit the order
          iNumRetries = 3;
         
          while(iNumRetries > 0)    // Retries Block  
             {
                if (!IsTradeAllowed()) {
                     Sleep(500);
                }
                RefreshRates();
                  
                if (iType == OP_BUY || iType == OP_BUYSTOP)
                {
                   dSL = price - iSL;
                   dTP = price + iTP;
                }
   
                 if (iType == OP_SELL || iType == OP_SELLSTOP)
                 {
                   dSL = price + iSL;
                   dTP = price - iTP;
                 }
                            
                 logMsg = StringFormat("%s => symbol = %s, price = %s, dSL = %s, dTP = %s",
                                  __FUNCTION__, symbol, 
                                  DoubleToString(price, 5), 
                                  DoubleToString(dSL, 5),
                                  DoubleToString(dTP, 5));
                 LogImportant(logMsg);  
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
      LogImportant(logMsg); 
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
   
   double CalcTotalProfits(const COrderInfo & orderInfo [], int orderCnt)
   {
      double fProfits = 0;
      for(int i = 0; i < orderCnt; i++)
      {
         fProfits += orderInfo[i].m_Profits;
      }         
         
      return fProfits;
   }
   
   double CalcTotalProfits2(const COrderInfo & orderInfo [], int orderCnt, int nLatestCnt)
   {
      double fProfits = 0;
      int nCnt = 0;
      for(int i = orderCnt - 1; i >= 0; i--)
      {
         fProfits += orderInfo[i].m_Profits;
         nCnt++;
         if(nCnt >= nLatestCnt) {
            break;
         }
      }         
         
      return fProfits;
   }
   
   /** 计算最后一个订单和本阶段第一笔订单的盈利金额
   * orderCnt: 总订单数
   * nLatestCnt：要计算的最后的订单数量，也就是本阶段已有的订单数
   */
   double CalcTotalProfits3(const COrderInfo & orderInfo [], int orderCnt, int nLatestCnt)
   {
      double fProfits = 0;
      int nIndexLast = orderCnt - 1;
      if(nIndexLast >= 0) {
         fProfits += orderInfo[nIndexLast].m_Profits;
      }
      int nFirstInStage = orderCnt - nLatestCnt - 1;
      if(nIndexLast != nFirstInStage && nFirstInStage >= 0) {
         fProfits += orderInfo[nFirstInStage].m_Profits;
      }
                     
      return fProfits;
   }
   
   void ShowText(string label, string text, color clr, int x, int y)
   {
      if(m_bShowText && gTickCount % 4 == 0) {
         DisplayText(label, text, clr, x, y);
      }
   }
   
   void ShowWarning(string label, string text, color clr, int x, int y)
   {
      if(gTickCount % 4 == 0) {
         DisplayText(label, text, clr, x, y);
      }
   }
   
   void ShowVersion(string label, string text, color clr, int x, int y)
   {
      if(gTickCount % 4 == 0) {
         DisplayText(label, text, clr, x, y);
      }
   }
   
   double GetSpread(string symbol) {
      RefreshRates();
      double dBid = MarketInfo(symbol, MODE_BID);
      double dAsk = MarketInfo(symbol, MODE_ASK);
  
      double dSpread =  dAsk - dBid;
      return dSpread;
   }
};

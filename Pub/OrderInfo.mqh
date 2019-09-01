//+------------------------------------------------------------------+
//|                                                    OrderInfo.mqh |
//|                                                          Cuilong |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COrderInfo
  {
public:
   string m_Symbol;
   int m_OrderType;
   int m_Ticket;
   double m_Lots;
   double m_Prices;
   double m_StopLoss;
   double m_TakeProfit;
   string m_Comment;
   string m_Magic;
   datetime m_TradeTime;
   double m_Profits;

public:
    COrderInfo();
    COrderInfo(const COrderInfo & orderInfo);
    ~COrderInfo();
    void clear();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COrderInfo::COrderInfo()
  {
    clear();
  }
  
 COrderInfo::COrderInfo(const COrderInfo & orderInfo) {
    m_Symbol = orderInfo.m_Symbol;
    m_Ticket =orderInfo.m_Ticket;
    m_OrderType = orderInfo.m_OrderType;
    m_Lots = orderInfo.m_Lots;
    m_Prices = orderInfo.m_Prices;
    m_StopLoss = orderInfo.m_StopLoss;
    m_TakeProfit = orderInfo.m_TakeProfit;
    m_Comment = orderInfo.m_Comment;
    m_Magic = orderInfo.m_Magic;
    m_TradeTime = orderInfo.m_Magic;
    m_Profits = orderInfo.m_Profits;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COrderInfo::~COrderInfo()
  {
  }
//+------------------------------------------------------------------+
void COrderInfo::clear(void)
{
    m_Symbol = "";
    m_Ticket = 0;
    m_OrderType = -1;
    m_Lots = 0;
    m_Prices = 0;
    m_StopLoss = 0;
    m_TakeProfit = 0;
    m_Comment = "";
    m_Magic = "";
    m_TradeTime = 0;
    m_Profits = 0;
}
//--------------------------------+
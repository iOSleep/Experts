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
   int m_OrderType;
   int m_Ticket;
   double m_Lots;
   double m_Prices;
   double m_StopLoss;
   double m_TakeProfit;
   string m_Comment;
   string m_Magic;
   datetime m_TradeTime;
   
   double m_MostTakeProfie;

public:
    COrderInfo();
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COrderInfo::~COrderInfo()
  {
  }
//+------------------------------------------------------------------+
COrderInfo::clear(void)
{
    m_Ticket = 0;
    m_OrderType = -1;
    m_Lots = 0;
    m_Prices = 0;
    m_StopLoss = 0;
    m_TakeProfit = 0;
    m_Comment = "";
    m_Magic = "";
    m_TradeTime = 0;
    m_MostTakeProfie = 0;
}
//--------------------------------+
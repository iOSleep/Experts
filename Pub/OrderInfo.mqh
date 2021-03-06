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

struct OptParam
{
   double m_BaseOpenLots1;  //基础开仓手数1
   double m_BaseOpenLots2;  //基础开仓手数2
   double m_MultipleForAppend;//加仓倍数
   double m_MulipleFactorForAppend; //加仓倍数调整系数
   int m_AppendMax;          // 最大加仓次数
   double m_PointOffsetForStage; //加仓条件：与上阶段相比最低价格差变化幅度
   double m_PointOffsetForAppend; //加仓条件：本阶段内最低价格差变化幅度
   double m_PointOffsetFactorForAppend; //加仓条件：最低价格差变化的调整系数
   double m_TakeProfitsPerOrder; //平仓条件：单轮的基础止盈获利金额
   double m_TakeProfitsFacorForLongSide; // 平仓条件：多方动态计算止盈金额调整系数
   double m_TakeProfitsFacorForShortSide; // 平仓条件：空方动态计算止盈金额调整系数
   double m_Backword; // 平仓条件：移动止盈回调系数
   double m_OffsetForBuySellStop; // 挂单价格差
   bool m_EnableInPassing;// 平仓时，是否执行带单操作，即平掉最近一笔订单和本阶段第一笔订单
};

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
   double m_MostProfits;
   double m_LeastProfits;

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
    m_MostProfits = orderInfo.m_MostProfits;
    m_LeastProfits = orderInfo.m_LeastProfits;
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
    m_MostProfits = 0;
    m_LeastProfits = 0;
}
//--------------------------------+
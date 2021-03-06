//+------------------------------------------------------------------+
//|                                                        双品种套利.mq4 |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input string 品种1 = "EURUSD";
input string 品种2 = "GBPUSD";
input string 订单注释 = "8888";
input int 打印订单间隔时间（秒） = 5;
input int 止盈标准 = 100;


string OpName [] = 
{
   "买单",
   "卖单"
};

#define LOG_DEBUG 0
#define LOG_INFO 1
#define LOG_WARN 2
#define LOG_ERROR 3
#define LOG_DISABLE 4

int gTickCount = 0;
int LogLevel = LOG_INFO;

bool IsNewBar()
{
   datetime now = TimeCurrent();
   string strNow = StringFormat("IsNewBar: now = %d", now);
   // Print(strNow);
   datetime timeBar0 = iTime(NULL, NULL, 0);
   if(now > timeBar0)
   {
      return false;
   }else 
   {
     return true;
   }
}

void LogDebug(string msg)
{
   if(LogLevel <= LOG_DEBUG)
   {
      PrintFormat("[debug]%s", msg);
   }
}

void LogInfo(string msg)
{
   if(LogLevel <= LOG_INFO)
   {
      PrintFormat("[info]%s", msg);
   }
}

void LogWarn(string msg)
{
   if(LogLevel <= LOG_WARN)
   {
      PrintFormat("[warn]%s", msg);
   }
}

void LogError(string msg)
{
   if(LogLevel <= LOG_ERROR)
   {
      PrintFormat("[error]%s", msg);
   }
}

bool IsFatalError(int Error)
{
   bool isFatal = true;
   switch(Error)                             // 可以克服的错误  
   {  
   case 135:  
      LogError("The price has changed. Retrying.."); // 继续下次迭代
      isFatal = false;                         // 继续下次迭代  
      break;  
   case 136:  
      LogError("No prices. Waiting for a new tick...");  // 继续下次迭代
      while(RefreshRates()==false)        // 新报价  
          Sleep(1);  
      isFatal = false;                         // 继续下次迭代  
      break;   
   case 146:  
      LogError("Trading subsystem is busy. Retrying..");
      isFatal = false;                         // 继续下次迭代  
      break;
   case 4108: 
      LogError("Unknown ticket"); 
      isFatal = false;                         // 继续下次迭代  
      break;
   } 
    
   switch(Error)                             // 致命错误  
    {  
      case 2 :   
         LogError("Common error.");   // 退出'switch'
         isFatal = true;                         // 继续下次迭代  
         break;  
      case 5 :  
         LogError("Old version of the client terminal.");  
         isFatal = true;                         // 继续下次迭代  
         break;
      case 64:   
         LogError("Account is blocked.");
         isFatal = true;                         // 继续下次迭代  
         break;   
      case 133:  
         LogError("Trading is prohibited");
         isFatal = true;                         // 继续下次迭代  
         break; 
      default:   
         LogError("Occurred error " + IntegerToString(Error));  //Other alternatives 
         isFatal = true;    
  }  
  
  return isFatal;
}

double CalcTotalProfits(const string comment,
                        const string& symbol [], bool bOutput)
{
   double fTotalProfits = 0;
   double fProfits[];
   string logMsg;
   int symbolCnt = ArraySize(symbol);
   int nOrdersTotalCnt = OrdersTotal();
   ArrayResize(fProfits, symbolCnt);
   ArrayInitialize(fProfits, 0);
   
   RefreshRates();
   for(int j = 0; j < symbolCnt; j++)
   {
      fProfits[j] = 0;
      for(int i = 0; i < nOrdersTotalCnt; i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            if(OrderSymbol() == symbol[j]
               && (comment == "" || OrderComment() == comment))
            {
               int nTicket = OrderTicket(); 
               double fPrice = OrderOpenPrice();
               double fLots = OrderLots();
               string strComment = OrderComment();
               int nOrderType = OrderType();
               datetime dtOpentime = OrderOpenTime();
               double fProfit = OrderProfit();
               if(nOrderType == OP_BUY || nOrderType == OP_SELL)
               {
                  if(bOutput) 
                  {
                     logMsg = StringFormat("订单[#%d]: 开单时间：%s, 开单价格：%s，手数：%s，类型：%s，获利：%s",
                                 nTicket, TimeToString(dtOpentime, TIME_SECONDS),
                                 DoubleToString(fPrice, 5), DoubleToString(fLots, 2), 
                                 OpName[nOrderType], DoubleToString(fProfit, 3));
                     LogInfo(logMsg); 
                   } 
                   fProfits[j] += fProfit;    
               
               }
             }
          }          
      }
      
      if(bOutput) 
      {
         logMsg = StringFormat("品种 -- %s: 获利：%s",
                               symbol[j], DoubleToString(fProfits[j], 3));
         LogInfo(logMsg);
      } 
      
      fTotalProfits += fProfits[j];
   }
   if(bOutput) 
   {
      logMsg = StringFormat("总获利：%s",DoubleToString(fTotalProfits, 3));
      LogInfo(logMsg);
   } 
   return fTotalProfits;
} 

int CloseOrders(const string comment,
                 const string& symbol [], bool bOutput)
{
   int ret = 0;
   string logMsg;
   
   double fTotalProfits = 0;
   double fProfits[];
  
   int symbolCnt = ArraySize(symbol);
   int nOrdersTotalCnt = OrdersTotal();
   ArrayResize(fProfits, symbolCnt);
   ArrayInitialize(fProfits, 0);
   
   RefreshRates();
   for(int j = 0; j < symbolCnt; j++)
   {
      fProfits[j] = 0;
      for(int i = nOrdersTotalCnt - 1; i >= 0; i--)
      {
         if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES))
         {
            if(OrderSymbol() == symbol[j]
               && (comment == "" || OrderComment() == comment))
            {
               int nTicket = OrderTicket(); 
               double fOpenPrice = OrderOpenPrice();
               double fLots = OrderLots();
               int nOrderType = OrderType(); 
               if(nOrderType != OP_SELL && nOrderType != OP_BUY)
               {
                  continue;
               }           
                  
               if(nTicket > 0)
               {
                  while(true)
                  {
                     RefreshRates();
                     double fProfit = OrderProfit();
                     double fClosePrice = MarketInfo(symbol[j], MODE_BID);
                     color clr = clrRed;
                     if(nOrderType == OP_SELL)
                     {
                        fClosePrice = MarketInfo(symbol[j], MODE_ASK);
                        clr = clrGreen;
                     }
                     
                     if(OrderClose(nTicket, fLots, fClosePrice, 3, clr))
                     {
                        fProfits[j] += fProfit;
                        logMsg = StringFormat("平仓订单[#%d] -- 订单类型：%s，手数：%s，成本价：%s，平仓价：%s，获利：%s",
                                   nTicket, OpName[nOrderType], 
                                   DoubleToString(fLots, 2), DoubleToString(fOpenPrice, 6), 
                                   DoubleToString(fClosePrice, 6), DoubleToString(fProfit, 2)); 
                        LogInfo(logMsg);
                        break;
                  
                     } else
                     {
                        int nErr = GetLastError(); // 平仓失败 :( 
                        logMsg = StringFormat("平仓失败[#%d], 错误码: %d.", nTicket, nErr);
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
      }
      
      if(bOutput) 
      {
         logMsg = StringFormat("平仓订单 -- 品种：%s，: 获利：%s",
                               symbol[j], DoubleToString(fProfits[j], 3));
         LogInfo(logMsg);
      } 
      
      fTotalProfits += fProfits[j];
   }
   if(bOutput) 
   {
      logMsg = StringFormat("总获利：%s",DoubleToString(fTotalProfits, 3));
      LogInfo(logMsg);
   }
   return ret;
}
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
 //---
   int nInterval = 打印订单间隔时间（秒）;
   EventSetTimer(nInterval);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   gTickCount++;
   string symbols [2];
   symbols[0] = 品种1;
   symbols[1] = 品种2;
   string comment = 订单注释;
   double totalProfits = CalcTotalProfits(comment, symbols, false);
   if(totalProfits >= 止盈标准)
   {
      CloseOrders(comment, symbols, true);
   }  
  }
  
  void OnTimer()
  {
      string symbols [2];
      symbols[0] = 品种1;
      symbols[1] = 品种2;
      string comment = 订单注释;
      CalcTotalProfits(comment, symbols, true);
  }
//+------------------------------------------------------------------+

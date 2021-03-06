//+------------------------------------------------------------------+
//|                                                       ClUtil.mqh |
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

#include "3MAPubVar.mqh"

#define LOG_DEBUG 0
#define LOG_INFO 1
#define LOG_WARN 2
#define LOG_ERROR 3
#define LOG_DISABLE 4

input int LogLevel = LOG_INFO;

bool IsNewBar()
{
   datetime now = TimeCurrent();
   string strNow = StringFormat("IsNewBar: now = %d", now);
   // Print(strNow);
   datetime timeBar0 = iTime(NULL, TimeFrame, 0);
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
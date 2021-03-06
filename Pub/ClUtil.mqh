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

#include "PubVar.mqh"

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
   switch(Error)                             // 可以克服的错误  
   {  
   case 4:
      LogError("Server is busy.");
      return false;
   case 6:
      LogError("No connection with trade server. Retrying...");
      while(RefreshRates()==false)        // 新报价  
          Sleep(1);  
      return false;
   case 132:
      LogError("Market is closed. Retrying..");
      return false;
   case 128:
   case 129:
   case 138:
   case 142:
   case 143:
   case 144:
   case 145:
   case 147:
   case 148:
      return false;
   case 135:  
      LogError("The price has changed. Retrying.."); // 继续下次迭代
      return false;                         // 继续下次迭代  
    case 136:  
      LogError("No prices. Waiting for a new tick...");  // 继续下次迭代
      while(RefreshRates()==false)        // 新报价  
          Sleep(1);  
      return false;    
   case 146:  
      LogError("Trading subsystem is busy. Retrying..");
      return false; 
   case 4108: 
      LogError("Unknown ticket"); 
      return false; 
   } 
    
   switch(Error)                             // 致命错误  
    {  
      case 2 :   
         LogError("Common error.");   // 退出'switch'
         return true;
      case 3 :   
         LogError("Invalid trade parameters.");   // 退出'switch'
         return true;  
      case 5 :  
         LogError("Old version of the client terminal.");  
         return true;
      case 7:
      case 8:
      case 65:
      case 130:
      case 139:
      case 140:
      case 141:
      case 149:
      case 150:
         return true;
      case 64:   
         LogError("Account is blocked.");
         return true;   
      case 133:  
         LogError("Trading is prohibited");
         return true;
      case 134:  
         LogError("Not enough money");
         return true; 
      default:   
         LogError("Occurred error " + IntegerToString(Error));  //Other alternatives 
         return true;   
  }  
  
  return true;
}

void DisplayText(string label, string text, color clr, int x, int y)
{
   int xSrc = 10;
   int ySrc = 15;
   int yHigh = 15;
   int xPos = xSrc * x * 2;
   int yPos = ySrc + y * yHigh;
   
   
   string ObjName = label;
   if(ObjectFind(ObjName) < 0)
   {
         ObjectDelete(ObjName); 
         ObjectCreate(ObjName, OBJ_LABEL, 0, 0 ,0.0 ,0, 0.0, 0, 0.0); 
   }
   ObjectSet(ObjName,OBJPROP_XDISTANCE, xPos); 
   ObjectSet(ObjName,OBJPROP_YDISTANCE, yPos); 
   ObjectSetText(ObjName, text, 10, "微软雅黑", clr);
   ChartRedraw();  
 }
 
bool IsExpired()
{
   datetime expireTime = D'2018.06.30';
   datetime now = TimeCurrent(); 
   
   if(now > expireTime) 
   {
      return true;
   }
   return false;
}   
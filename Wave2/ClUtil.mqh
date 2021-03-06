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
#define LOG_IMPORTANT 4
#define LOG_DISABLE 5

int LogLevel = LOG_ERROR;

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


bool IsPrime( int num )  
{  
     //两个较小数另外处理  
     if(num == 2 || num == 3 )  
         return true ;  
     //不在6的倍数两侧的一定不是质数  
     if(num %6 != 1 && num %6 != 5)  
         return false;
           
     int tmp = sqrt(num);  
     //在6的倍数两侧的也可能不是质数  
     for(int i = 5; i <= tmp; i += 6 ) { 
         if(num %i == 0 || num %(i + 2) == 0) {  
            return false;
         } 
     } 
     //排除所有，剩余的是质数  
     return true;  
}  
 
 
int GetMaxPrime(int max)
{
   int nRet = 1;
   int count = 0;
   for (int i = max; i >= 2; i--)
   {
       if(IsPrime(i)) {
         return i;
       }
   }
   return 1;
}
               
int GenPasscode() {
   string symbol = Symbol();
   datetime now = TimeCurrent();
   int y = TimeYear(now);
   int m = TimeMonth(now);
   int d = TimeDay(now);
   
   int sym = 0;
   int pass = 1;
   int i = 0;
   for(i = 0; i < StringLen(symbol); i++) {
      int ch = StringGetChar(symbol, i);
      if(ch > 0) {
         sym += ch;
      }
   }
   int p0 = GetMaxPrime(sym);
   int p1 = GetMaxPrime(y + m * m);
   int p2 = GetMaxPrime(m * y);
   
   pass = p0 * p1 * p2;
   return pass;   
}

int GenPasscodeNextMon() {
   string symbol = Symbol();
   datetime now = TimeCurrent();
   int y = TimeYear(now);
   int m = TimeMonth(now);
   int d = TimeDay(now);
   
   m += 1;
   if(m > 12) {
      m = 1;
      y += 1;
   }
   
   int sym = 0;
   int pass = 1;
   int i = 0;
   for(i = 0; i < StringLen(symbol); i++) {
      int ch = StringGetChar(symbol, i);
      if(ch > 0) {
         sym += ch;
      }
   }
   int p0 = GetMaxPrime(sym);
   int p1 = GetMaxPrime(y + m * m);
   int p2 = GetMaxPrime(m * y);
   
   pass = p0 * p1 * p2;
   return pass;   
}

int GenPasscode(string symbol) {
   datetime now = TimeCurrent();
   int y = TimeYear(now);
   int m = TimeMonth(now);
   int d = TimeDay(now);
   
   int sym = 0;
   int pass = 1;
   int i = 0;
   for(i = 0; i < StringLen(symbol); i++) {
      int ch = StringGetChar(symbol, i);
      if(ch > 0) {
         sym += ch;
      }
   }
   int p0 = GetMaxPrime(sym);
   int p1 = GetMaxPrime(y + m * m);
   int p2 = GetMaxPrime(m * y);
   
   pass = p0 * p1 * p2;
   return pass;   
}

int GenPasscodeNextMon(string symbol) {
   datetime now = TimeCurrent();
   int y = TimeYear(now);
   int m = TimeMonth(now);
   int d = TimeDay(now);
   
   m += 1;
   if(m > 12) {
      m = 1;
      y += 1;
   }
   
   int sym = 0;
   int pass = 1;
   int i = 0;
   for(i = 0; i < StringLen(symbol); i++) {
      int ch = StringGetChar(symbol, i);
      if(ch > 0) {
         sym += ch;
      }
   }
   int p0 = GetMaxPrime(sym);
   int p1 = GetMaxPrime(y + m * m);
   int p2 = GetMaxPrime(m * y);
   
   pass = p0 * p1 * p2;
   return pass;   
}

bool CheckPasscode(int passcode) {
   return passcode == GenPasscode();
}

string GetCurrentTime() {
   datetime now = TimeCurrent();
   int hh = TimeHour(now);
   int mm = TimeMinute(now);
   string ret = StringFormat("%02d:%02d", hh, mm);
   return ret;
}

bool IsBetweenDate(datetime startDate, datetime endDate) {
   datetime now = TimeCurrent();
   return now >= startDate && now <= endDate;        
}

bool IsBetweenTime(string startTime, string endTime) {
   datetime st = StrToTime(startTime);
   datetime end = StrToTime(endTime);
   datetime now = StrToTime(GetCurrentTime());
   return now >= st && now <= end;        
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

void LogImportant(string msg)
{
   if(LogLevel <= LOG_IMPORTANT)
   {
      PrintFormat("[important]%s", msg);
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
      return true; 
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
   int xSrc = 15;
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
   ObjectSetText(ObjName, text, 8, "微软雅黑", clr);
   ChartRedraw();  
 }
 
bool IsExpired()
{
   datetime expireTime = D'2018.12.31';
   datetime now = TimeCurrent(); 
   
   if(now > expireTime) 
   {
      return true;
   }
   return false;
} 

bool IsFriday() {
   int dayOfWeek = DayOfWeek();
   return dayOfWeek == 5;
}

bool CompareDoubles(double number1,double number2) 
{ 
   if(NormalizeDouble(number1-number2,8)==0) 
      return(true); 
   else 
      return(false); 
}   
//+------------------------------------------------------------------+
//|                                                  CheckZigZag.mqh |
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
#include "../Pub/PubVar.mqh"
#include "../Pub/ClUtil.mqh"
#include "OrderUtil.mqh"

int   InpDepth = 12  ;    //Depth
int   InpDeviation = 5  ;    //Deviation
int   InpBackstep = 3  ;    //Backstep
int   BigMa = 10  ;    //大均线周期
int   SmallMa = 5  ;    //小均线周期


enum { FLUCTUATION = 0, TREND_UP = 1, TREND_DOWN = 2};
string TrendName[] = 
{  
   "FLUCTUATION", 
   "TREND_UP", 
   "TREND_DOWN"  
};

#define INDICATOR_NAME "ZigZagMaDiff"
#define EXTREMUM_COUNT 3
double gHighPoints[EXTREMUM_COUNT];
double gLowPoints[EXTREMUM_COUNT];

int gPreTrend = FLUCTUATION;
int gNearestExtremumBar = 9999;

int CheckTrend(int nPreTrend)
{  
   int nTrend = nPreTrend;
   int nTimeFrame = TimeFrame;
   string logMsg;
   int nBarsCnt = iBars(NULL, nTimeFrame);
   int i = 0;
   int nExtremumCnt = 0;
   int nBarsIndex[EXTREMUM_COUNT * 2];
   double dExtremumPoints[EXTREMUM_COUNT * 2];
   ArrayInitialize(dExtremumPoints, 0.0);
   ArrayInitialize(nBarsIndex, 0);
   bool bFirstZigZag = true;
   for (i = InpBackstep; i < nBarsCnt ; i++)
   {
      double dExtremum = iCustom(NULL, nTimeFrame, INDICATOR_NAME, 
                                 InpDepth,InpDeviation,InpBackstep,
                                 BigMa,SmallMa,
                                 PRD1, PRD2, 
                                 0, i);
      /*                                 
      if(dExtremum != 0.0)
      {
         if(bFirstZigZag) 
         {  
            // 跳过第一个zigzag值
            bFirstZigZag = false;
            continue;
         }
      }
      */
      
      if(dExtremum != 0.0 && nExtremumCnt < EXTREMUM_COUNT * 2)
      {
         dExtremumPoints[nExtremumCnt] = dExtremum;
         nBarsIndex[nExtremumCnt] = i;
         logMsg = StringFormat(" %s => Extremum value [%d] = %s.", 
                  __FUNCTION__, i, DoubleToString(dExtremum, 4));
         if(gIsNewBar)
         {
            // LogInfo(logMsg);  
         } 
         nExtremumCnt++;
      }
   }
   
   gNearestExtremumBar = nBarsIndex[0];
   
   logMsg = StringFormat(" %s => Extremum[0] = %s in Bars = %d", 
                  __FUNCTION__, DoubleToString(dExtremumPoints[0], 4), nBarsIndex[0]);
   // LogInfo(logMsg);  
            
   if(nExtremumCnt > 0)
   {
      if(dExtremumPoints[0] > dExtremumPoints[1])
      {
         for(i = 0; i < EXTREMUM_COUNT; i++)
         {
            gHighPoints[i] = dExtremumPoints[2 * i];
            gLowPoints[i] = dExtremumPoints[2 * i + 1];
         }
         nTrend = TREND_DOWN;
      }else 
      {
         for(i = 0; i < EXTREMUM_COUNT; i++)
         {
            gLowPoints[i] = dExtremumPoints[2 * i];
            gHighPoints[i] = dExtremumPoints[2 * i + 1];
         }
         nTrend = TREND_UP;
      }
   }
   
   logMsg = StringFormat(" %s => Trend = %s, L[0] = %s, H[0] = %s, E[0] = %s in Bar[%d],  E[1] = %s in Bar[%d]", 
                  __FUNCTION__, TrendName[nTrend], 
                  DoubleToString(gLowPoints[0], 4),DoubleToString(gHighPoints[0], 4),
                  DoubleToString(dExtremumPoints[0], 4),nBarsIndex[0],
                  DoubleToString(dExtremumPoints[1], 4), nBarsIndex[1]);
   //if(gIsNewBar)
   if(gTickCount % 20 == 0 || nTrend != nPreTrend )
   {
      LogInfo(logMsg);  
   }
   return nTrend;
}

int CheckForOpenBuy()
{
   int nDirect = -1;
   int nTimeFrame = TimeFrame;
   string logMsg;
   double dPreLabel2 = iCustom(NULL, nTimeFrame, INDICATOR_NAME, 
                                 InpDepth,InpDeviation,InpBackstep,
                                 BigMa,SmallMa,
                                 PRD1, PRD2, 
                                 1, 1);
   double dPrePreLabel2 = iCustom(NULL, nTimeFrame, INDICATOR_NAME, 
                                 InpDepth,InpDeviation,InpBackstep,
                                 BigMa,SmallMa,
                                 PRD1, PRD2, 
                                 1, 2);
                                 
   logMsg = StringFormat(" %s => PrePre = %s, Pre = %s", 
                  __FUNCTION__, DoubleToString(dPrePreLabel2, 4), DoubleToString(dPreLabel2, 4));
   if(gIsNewBar)
   {
      LogInfo(logMsg);  
   }
   // 柱号2上的价差值比前两个低点还要低
   if(dPrePreLabel2 <= gLowPoints[0] && dPrePreLabel2 <= gLowPoints[1])
   {
      if(dPreLabel2 > dPrePreLabel2)
      {
         // 价差反转
         nDirect = OP_BUY;
         logMsg = StringFormat(" %s =>Catch direct, OP_BUY, LowPoint1 = %s, LowPoint0 = %s, PrePreLable2 = %s, PreLable2 = %s", 
                  __FUNCTION__, DoubleToString(gLowPoints[1], 4), DoubleToString(gLowPoints[0], 4), 
                  DoubleToString(dPrePreLabel2, 4), DoubleToString(dPreLabel2, 4));
         if(gIsNewBar)
         {
            LogInfo(logMsg);  
         }
      }
      
   }
   return nDirect;
}


int CheckForOpenSell()
{
   int nDirect = -1;
   int nTimeFrame = TimeFrame;
   string logMsg;
   double dPreLabel2 = iCustom(NULL, nTimeFrame, INDICATOR_NAME, 
                                 InpDepth,InpDeviation,InpBackstep,
                                 BigMa,SmallMa,
                                 PRD1, PRD2, 
                                 1, 1);
   double dPrePreLabel2 = iCustom(NULL, nTimeFrame, INDICATOR_NAME, 
                                 InpDepth,InpDeviation,InpBackstep,
                                 BigMa,SmallMa,
                                 PRD1, PRD2, 
                                 1, 2);
   logMsg = StringFormat(" %s => PrePre = %s, Pre = %s", 
                  __FUNCTION__, DoubleToString(dPrePreLabel2, 4), DoubleToString(dPreLabel2, 4));
   if(gIsNewBar)
   {
      LogInfo(logMsg);  
   }
   
   // 柱号2上的价差值比前两个低点还要低
   if(dPrePreLabel2 >= gHighPoints[0] && dPrePreLabel2 >= gHighPoints[1])
   {
      if(dPreLabel2 < dPrePreLabel2)
      {
         // 价差反转
         nDirect = OP_SELL;
         logMsg = StringFormat(" %s =>Catch direct, OP_SELL, HighPoint1 = %s, HighPoint0 = %s, PrePreLable2 = %s, PreLable2 = %s", 
                  __FUNCTION__, DoubleToString(gHighPoints[1], 4), DoubleToString(gHighPoints[0], 4), 
                  DoubleToString(dPrePreLabel2, 4), DoubleToString(dPreLabel2, 4));
         if(gIsNewBar)
         {
            LogInfo(logMsg);  
         }
 
      }
      
   }
   return nDirect;
}

int CheckForOpenEx(int nPreTrend, int nTrend)
{
   int nDirect = -1;
   
   string logMsg;
   double dHighest = MathMax(gHighPoints[0], gHighPoints[1]);
   dHighest = MathMax(dHighest, gHighPoints[2]);
   
   double dLowest = MathMin(gLowPoints[0], gLowPoints[1]);
   dLowest = MathMin(dLowest, gLowPoints[2]); 
   
   double dMidPoint1 = dLowest + (dHighest - dLowest) * 0.382;
   double dMidPoint2 = dLowest + (dHighest - dLowest) * 0.618;
   int nTimeFrame = TimeFrame;
   double dLabel2 = iCustom(NULL, nTimeFrame, INDICATOR_NAME, 
                                 InpDepth,InpDeviation,InpBackstep,
                                 BigMa,SmallMa,
                                 PRD1, PRD2, 
                                 1, 0);
     
   if(nPreTrend != TREND_UP && nTrend == TREND_UP)
   {
     logMsg = StringFormat(" %s =>Trend changed, DOWN-->UP, Nearest bar = %d, L2 = %s, L1 = %s, L0 = %s, Current = %s, MP1 = %s", 
                     __FUNCTION__, gNearestExtremumBar, 
                     DoubleToString(gLowPoints[2], 4), 
                     DoubleToString(gLowPoints[1], 4), 
                     DoubleToString(gLowPoints[0], 4), 
                     DoubleToString(dLabel2, 4), 
                     DoubleToString(dMidPoint1, 4));
      // if(gIsNewBar)
      {
         LogInfo(logMsg);  
      }
         
      if(
            gLowPoints[0] < gLowPoints[1] && gLowPoints[0] < gLowPoints[2] && 
            dLabel2 <= dMidPoint1 
            && gNearestExtremumBar <= InpBackstep + 2)
      {
         nDirect = OP_BUY;
         logMsg = StringFormat(" %s =>Catch direct, OP_BUY", __FUNCTION__);
         // if(gIsNewBar)
         {
            LogInfo(logMsg);  
         }
      } 
   }else if(nPreTrend != TREND_DOWN && nTrend == TREND_DOWN)
   {
   
      logMsg = StringFormat(" %s => Trend changed, UP --> DOWN, Nearest bar = %d, H2 = %s, H1 = %s, H0 = %s, Current = %s, MP2 = %s",
                     __FUNCTION__, gNearestExtremumBar, 
                     DoubleToString(gHighPoints[2], 4), 
                     DoubleToString(gHighPoints[1], 4), 
                     DoubleToString(gHighPoints[0], 4), 
                     DoubleToString(dLabel2, 4), 
                     DoubleToString(dMidPoint2, 4));
       
      // if(gIsNewBar)
      {
         LogInfo(logMsg);  
      }
      
      if(  gHighPoints[0] > gHighPoints[1] && gHighPoints[0] > gHighPoints[2] && 
           dLabel2 >= dMidPoint2   
               && gNearestExtremumBar <= InpBackstep + 2)
      {
        nDirect = OP_SELL;
        logMsg = StringFormat(" %s =>Catch direct, OP_SELL", __FUNCTION__);
         // if(gIsNewBar)
         {
            LogInfo(logMsg);  
         } 
      }
   }
   
   return nDirect;
   
}

bool CheckForClose(string symbol1, string symbol2, int nMainDirect, string comment)
{
   bool bClose = false;
   string symbols [2];
   symbols[0] = symbol1;
   symbols[1] = symbol2;
   
   double dHighest = MathMax(gHighPoints[0], gHighPoints[1]);
   dHighest = MathMax(dHighest, gHighPoints[2]);
   
   double dLowest = MathMin(gLowPoints[0], gLowPoints[1]);
   dLowest = MathMin(dLowest, gLowPoints[2]); 
      
   double stdProfits = TotalProfits;//总获利止盈标准;
   double trailingProfits = 0;
   
   if(DynamicCalcTotalProfits)
   {
      if(nMainDirect == OP_BUY)
      {
         stdProfits = CalcFactor * gBuyTotalLots;
      }
      
      if(nMainDirect == OP_SELL)
      {
         stdProfits = CalcFactor * gSellTotalLots;
      }
   }
   
   if(gMostProfits > stdProfits)
   {
      trailingProfits = gMostProfits * Retracement / 100;
   }else
   {
      trailingProfits = stdProfits * Retracement / 100;
   }
   
   double realTakeProfits = stdProfits;
      
   int xPos = 1;
   int yPos = 0;
   string strVersion = StringFormat("版本号：%s", EA_VERSION);
   DisplayText("Version", strVersion, clrYellow, xPos, yPos);
   
   yPos++;
   string strPruduct = StringFormat("交易品种：%s / %s", symbols[0], symbols[1]);
   DisplayText("Product", strPruduct, clrYellow, xPos, yPos);
   
   yPos++;
   string strComment = StringFormat("订单注释：%s", comment);
   DisplayText("Comment", strComment, clrYellow, xPos, yPos);
   
   yPos++;
   string strMainDirect = StringFormat("订单方向：%d", nMainDirect);
   DisplayText("MainDirect", strMainDirect, clrYellow, xPos, yPos);
   
   yPos++;
   string strStdProfits = StringFormat("总获利止盈标准：%s", DoubleToString(stdProfits, 2));
   DisplayText("StdProfits", strStdProfits, clrYellow, xPos, yPos);
   
   yPos++;
   string strTrailingProfits = StringFormat("移动止盈标准：%s", DoubleToString(trailingProfits, 2));
   DisplayText("TrailingProfits", strTrailingProfits, clrYellow, xPos, yPos);
   
   yPos++;
   string strMostProfits = StringFormat("历史最高获利：%s", DoubleToString(gMostProfits, 2));
   DisplayText("MostProfits", strMostProfits, clrYellow, xPos, yPos);
   
   
   double totalProfits = CalcTotalProfits(comment, symbols, false);
   realTakeProfits = MathMax(stdProfits, gMostProfits - trailingProfits);
   
   
   yPos++;
   string strRealTakeProfits = StringFormat("当前移动止盈点：%s", DoubleToString(realTakeProfits, 2));
   DisplayText("RealTakeProfits", strRealTakeProfits, clrYellow, xPos, yPos);
   
   yPos++;
   string strTotalProfits = StringFormat("当前实际获利：%s", DoubleToString(totalProfits, 2));
   DisplayText("TotalProfits", strTotalProfits, clrYellow, xPos, yPos);
   
   
   if( totalProfits > 0
         && gMostProfits > stdProfits
         && gPreTotalProfits > realTakeProfits 
         && totalProfits <= realTakeProfits)
   {
      string logMsg = StringFormat("%s=>Catch close,Total=%s,std=%s,Pre=%s,real=%s,Most=%s,Trailing=%s, ", 
                  __FUNCTION__,  DoubleToString(totalProfits, 2),
                  DoubleToString(stdProfits, 2),
                  DoubleToString(gPreTotalProfits, 2),
                  DoubleToString(realTakeProfits, 2),
                  DoubleToString(gMostProfits, 2), 
                  DoubleToString(trailingProfits, 2));
      LogInfo(logMsg);  
      bClose = true;
   }
   
   gPreTotalProfits = totalProfits;
   
   if(totalProfits > gMostProfits)
   {
      gMostProfits = totalProfits;
   } 
   return bClose;
}

bool CheckForAppend() {
}

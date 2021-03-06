//+------------------------------------------------------------------+
//|                                                       tester.mq4 |
//|                                                Alexander Fedosov |
//+------------------------------------------------------------------+
#property copyright "Alexander Fedosov"
#property strict
#include <trading.mqh>      //交易函数库
//+------------------------------------------------------------------+
//| Parameters                                                       |
//+------------------------------------------------------------------+
input int             SL = 40;               // 止损
input int             TP = 70;               // 止赢
input bool            Lot_perm=true;         // 根据帐户余额确定交易量
input double          lt=0.01;               // 交易量
input double          risk = 2;              // 风险，%
input int             slippage= 5;           // 滑点
input int             magic=2356;            // Magic数字
input int             period=8;              // RSI 指标周期
input ENUM_TIMEFRAMES tf=PERIOD_CURRENT;     // EA运行周期
int dg,index_rsi,index_ac;
trading tr;
//+------------------------------------------------------------------+
//| EA初始化函数                                                      |
//+------------------------------------------------------------------+
int OnInit()
  {
//---为交易函数辅助类确定变量
//--- 报错显示，默认俄语
   tr.ruErr=true;
   tr.Magic=magic;
   tr.slipag=slippage;
   tr.Lot_const=Lot_perm;
   tr.Lot=lt;
   tr.Risk=risk;
//--- 尝试次数
   tr.NumTry=5;
//--- 确定当前图表的报价位数
   dg=tr.Dig();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| 主函数                                                            |
//+------------------------------------------------------------------+
void OnTick()
  {
   depth_trend();
   speed_ac();
//--- 侦测未平仓订单
   if(OrdersTotal()<1)
     {
      //--- 侦测买入条件
      if(Buy())
         tr.OpnOrd(OP_BUY,tr.Lots(),Ask,SL*dg,TP*dg);
      //---侦测卖出条件
      if(Sell())
         tr.OpnOrd(OP_SELL,tr.Lots(),Bid,SL*dg,TP*dg);
     }
//--- 有未平仓订单吗？
   if(OrdersTotal()>0)
     {
      //---侦测到如果满足平仓条件则平仓卖单。
      if(Sell_close())
         tr.ClosePosAll(OP_SELL);
      //---侦测到如果满足平仓条件则平仓买单。
      if(Buy_close())
         tr.ClosePosAll(OP_BUY);
     }

  }
//+------------------------------------------------------------------+
//| 确定趋势幅度的函数                                                  |
//+------------------------------------------------------------------+
void depth_trend()
  {
//--- 买
   double rsi=iRSI(Symbol(),tf,period,PRICE_CLOSE,0);
   index_rsi = 0;
   if(rsi>90.0) index_rsi=4;
   else if(rsi>80.0)
      index_rsi=3;
   else if(rsi>70.0)
      index_rsi=2;
   else if(rsi>60.0)
      index_rsi=1;
   else if(rsi<10.0)
      index_rsi=-4;
   else if(rsi<20.0)
      index_rsi=-3;
   else if(rsi<30.0)
      index_rsi=-2;
   else if(rsi<40.0)
      index_rsi=-1;
  }
//+------------------------------------------------------------------+
//| 确定趋势速度的函数                                                  |
//+------------------------------------------------------------------+
void speed_ac()
  {
   double ac[];
   ArrayResize(ac,5);
   for(int i=0; i<5; i++)
      ac[i]=iAC(Symbol(),tf,i);

   index_ac=0;
//--- 买入信号
   if(ac[0]>ac[1])
      index_ac=1;
   else if(ac[0]>ac[1] && ac[1]>ac[2])
      index_ac=2;
   else if(ac[0]>ac[1] && ac[1]>ac[2] && ac[2]>ac[3])
      index_ac=3;
   else if(ac[0]>ac[1] && ac[1]>ac[2] && ac[2]>ac[3] && ac[3]>ac[4])
      index_ac=4;
//--- 卖出信号
   else if(ac[0]<ac[1])
      index_ac=-1;
   else if(ac[0]<ac[1] && ac[1]<ac[2])
      index_ac=-2;
   else if(ac[0]<ac[1] && ac[1]<ac[2] && ac[2]<ac[3])
      index_ac=-3;
   else if(ac[0]<ac[1] && ac[1]<ac[2] && ac[2]<ac[3] && ac[3]<ac[4])
      index_ac=-4;
  }
//+------------------------------------------------------------------+
//| 侦测买入条件的函数                                                  |
//+------------------------------------------------------------------+
bool Buy()
  {
   bool res=false;
   if((index_rsi==2 && index_ac>=1) || (index_rsi==3 && index_ac==1))
      res=true;
   return (res);
  }
//+------------------------------------------------------------------+
//| 侦测卖出条件的函数                                                  |
//+------------------------------------------------------------------+
bool Sell()
  {
   bool res=false;
   if((index_rsi==-2 && index_ac<=-1) || (index_rsi==-3 && index_ac==-1))
      res=true;
   return (res);
  }
//+------------------------------------------------------------------+
//| 侦测买单平仓条件的函数                                              |
//+------------------------------------------------------------------+
bool Buy_close()
  {
   bool res=false;
   if(index_rsi>2 && index_ac<0)
      res=true;
   return (res);
  }
//+------------------------------------------------------------------+
//| 侦测卖单平仓条件的函数                                              |
//+------------------------------------------------------------------+
bool Sell_close()
  {
   bool res=false;
   if(index_rsi<-2 && index_ac>0)
      res=true;
   return (res);
  }
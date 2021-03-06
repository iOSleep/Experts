extern int Pips = 50;
extern double Lots = 0.1;
int g_file_88;
bool gi_92=true;
bool gi_96 = FALSE;
int gi_100 = 999999;
int gi_104 = 0;
int gi_108;
int gi_112 = 0;
int gi_116 = 0;
double gd_120;
int GetTime(int ai_0) 
{
   FileSeek(g_file_88, ai_0 + 148, SEEK_SET);
   int li_4 = FileReadInteger(g_file_88);
   return (li_4);
}
int FindTimePlace(int ai_0) 
{
   int li_4;
   int li_8;
   int li_12 = 0;
   int li_16 = FileSize(g_file_88) - 148 - 44;
   int li_20 = GetTime(li_12);
   int li_24 = GetTime(li_16);
   while (li_20 < ai_0 && ai_0 < li_24) 
   {
      li_8 = (li_12 + li_16) / 2;
      li_8 -= li_8 % 44;
      if (li_8 == li_12) break;
      li_4 = GetTime(li_8);
      if (ai_0 >= li_4) 
      {
         li_12 = li_8;
         li_20 = GetTime(li_12);
      } 
      else 
      {
         li_16 = li_8;
         li_24 = GetTime(li_16);
      }
   }
   if (ai_0 <= li_24) 
   {
      FileSeek(g_file_88, li_12 + 148, SEEK_SET);
      return (1);
   }
   return (0);
}
void init() 
{
  
   g_file_88 = FileOpenHistory(Symbol() + Period() + ".hst", FILE_BIN|FILE_READ);
   if (g_file_88 > 0) gi_92 = TRUE;//如果历史数据存在则返回true
   else 
   {
      gi_92 = FALSE;
      return;
   }
   int li_16 = FileSize(g_file_88) - 148 - 44;
  // Print(TimeToStr(GetTime(0),TIME_DATE|TIME_SECONDS));//从1999年开始的第一根k线的时间
  // Print(TimeToStr(GetTime(li_16),TIME_DATE|TIME_SECONDS));//获得最近一根K线的开盘时间
   gi_92 = FindTimePlace(Time[0]);
    Print("gi_92:"+gi_92);
   if (!gi_92) FileClose(g_file_88);
}
void deinit() 
{
   if (gi_92) FileClose(g_file_88);
}
int GetPrices(int &ai_0, int &ai_4, int &ai_8) 
{
   ai_0 = FileReadInteger(g_file_88);
   FileSeek(g_file_88, 8, SEEK_CUR);
   ai_4 = FileReadDouble(g_file_88) / Point + 0.1;
   ai_8 = FileReadDouble(g_file_88) / Point + 0.1;
   FileSeek(g_file_88, 16, SEEK_CUR);
   if (FileTell(g_file_88) + 44 <= FileSize(g_file_88)) return (1);
   return (0);
}
int GetTimeTrade(double &ad_0) 
{
   int li_8;
   int li_12;
   int li_16;
   while (true) 
   {
      if (!GetPrices(li_8, li_12, li_16)) return (-1);
      if (gi_96) 
      {
         if (li_16 > gi_104) 
         {
            gi_104 = li_16;
            gi_108 = li_8;
            continue;
         }
         if (gi_104 - li_12 < Pips) continue;
         gi_96 = FALSE;
         gi_100 = li_12;
         ad_0 = gi_104 * Point;
         break;
      }
      if (li_12 < gi_100) 
      {
         gi_100 = li_12;
         gi_108 = li_8;
         continue;
      }
      if (li_16 - gi_100 < Pips) continue;
      gi_96 = TRUE;
      gi_104 = li_16;
      ad_0 = gi_100 * Point;
      break;
   }
   int li_ret_20 = gi_108;
   gi_108 = li_8;
   return (li_ret_20);
}
void CloseOrder(int a_ticket_0) 
{
   OrderSelect(a_ticket_0, SELECT_BY_TICKET);
   if (OrderType() == OP_BUY) 
   {
      OrderClose(a_ticket_0, OrderLots(), Bid, 0);
      return;
   }
   OrderClose(a_ticket_0, OrderLots(), Ask, 0);
}
int ReverseOrder(int a_ticket_0) 
{
   if (a_ticket_0 == 0) a_ticket_0 = OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, 0, 0);
   else 
   {
      OrderSelect(a_ticket_0, SELECT_BY_TICKET);
      if (OrderType() == OP_BUY) 
      {
         OrderClose(a_ticket_0, OrderLots(), Bid, 0);
         a_ticket_0 = OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, 0, 0);
      } 
      else 
      {
         OrderClose(a_ticket_0, OrderLots(), Ask, 0);
         a_ticket_0 = OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, 0, 0);
      }
   }
   return (a_ticket_0);
}

void System() 
{
   if (gi_116 == 0)
   {
      gi_116 = GetTimeTrade(gd_120);
      Print(TimeToStr(gi_116,TIME_DATE|TIME_SECONDS));//从1999年开始的第一根k线的时间
   }
   else
   {
      if (gi_116 < 0) return;
   }
   if (Time[0] == gi_116) 
   {
      if (NormalizeDouble(Bid - gd_120, Digits) == 0.0) 
      {
         gi_116 = GetTimeTrade(gd_120);
         if (gi_116 < 0) 
         {
            CloseOrder(gi_112);
            return;
         }
         gi_112 = ReverseOrder(gi_112);
      }
   }
}

void start() 
{
   if (gi_92)
   {
      //Print("opk");
      System();
      return;
   }
}
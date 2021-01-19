//+------------------------------------------------------------------+
//|                                                        utils.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

string   timezone="+02:00";

//+------------------------------------------------------------------+
//| Fetch date from formatted string                                 |
//+------------------------------------------------------------------+
string ItemRFCTime(string item)
   {
      string result[];
      ushort sep = StringGetCharacter("|",0);
      StringSplit(item,sep,result);
      
      if(StringLen(item) > 0)
         return(result[0]);
      else
         return("");   
   }

//+------------------------------------------------------------------+
//| Convert Time to RFC3339 string                                   |
//+------------------------------------------------------------------+
string TimeToRFC(datetime time)
   {
      string yyyy = TimeYear(time);
      string mm = LeadingZero(TimeMonth(time));
      string dd = LeadingZero(TimeDay(time));
      string HH = LeadingZero(TimeHour(time));
      string MM = LeadingZero(TimeMinute(time));
      string ss = LeadingZero(TimeSeconds(time));
      
      return(StringFormat("%s-%s-%sT%s:%s:%s%s", yyyy, mm, dd, HH, MM, ss, timezone));
   }

//+------------------------------------------------------------------+
//| Add leading zero to number                                       |
//+------------------------------------------------------------------+
string LeadingZero(int number)
   {
      if(number < 10)
         return("0" + number);
      else
         return number;   
   }   

//+------------------------------------------------------------------+
//| Convert Quote to Redis formatted string                          |
//+------------------------------------------------------------------+
string QuoteToRedis(int index)
   {
      string time = TimeToRFC(Time[index]);
      string open = Open[index];
      string high = High[index];
      string low = Low[index];
      string close = Close[index];
      string volume = Volume[index];
      return(StringFormat("%s|%s|%s|%s|%s|%s", time, open, high, low, close, volume));
   }
   
//+------------------------------------------------------------------+
//| Convert Order to Redis formatted string                          |
//+------------------------------------------------------------------+
string OrderToRedis()
   {
      string ticket = OrderTicket();
      string type = OrderType();
      string magic = OrderMagicNumber();
      string lots = OrderLots();
      string symbol = OrderSymbol();
      string open_time = TimeToRFC(OrderOpenTime());
      string open_price = OrderOpenPrice();
      string stop_loss = OrderStopLoss();
      string take_profit = OrderTakeProfit();
      string close_time = TimeToRFC(OrderCloseTime());
      string close_price = OrderClosePrice();
      string profit = OrderProfit();
      string swap = OrderSwap();
      string commission = OrderCommission();
      string expiration = OrderExpiration();
      string comment = OrderComment();
      
      return(StringFormat("%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s",
               ticket, type, magic, lots, symbol, open_time, open_price, stop_loss, take_profit,
               close_time, close_price, profit, swap, commission, expiration, comment));
   }
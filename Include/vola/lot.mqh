//+------------------------------------------------------------------+
//|                                                          lot.mqh |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property strict

extern double DecreaseFactor = 5.0;
//+------------------------------------------------------------------+
//| Calculate lot size                                               |
//+------------------------------------------------------------------+
double Lot()
  {
   double one_lot = MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   double min_lot = MarketInfo(Symbol(),MODE_MINLOT);
   double Equity=AccountEquity();
   double CurrentMargin=AccountMargin();
   double Free=AccountFreeMargin();

   double MoneyAvailable=Equity/margin_call*100-CurrentMargin;
   if(MoneyAvailable<0) MoneyAvailable=0;
   double MoneyToTrade=MathMin(Equity*symbol_max_load/100,MoneyAvailable);
   double lot_size=MathFloor(MoneyToTrade/one_lot/min_lot)*min_lot;
   
   int    ordersN=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
   
   if(DecreaseFactor > 0)
      {
      for(int i = ordersN - 1; i>=0; i--)
         {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
           {
            Print("Error in history!");
            break;
           }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL)
            continue;
         //---
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
         }
      if(losses > 0)
         lot_size = NormalizeDouble(lot_size - lot_size * losses / DecreaseFactor,2);
      }
   
   if(lot_size < min_lot) lot_size = min_lot;
   return(lot_size);
  }
//+------------------------------------------------------------------+

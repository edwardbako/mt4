//+------------------------------------------------------------------+
//|                                                        trade.mqh |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| Trades Controller                                                |
//+------------------------------------------------------------------+
void Trade(int TradeOp)
  {
   switch(TradeOp)
     {
      case SIGNAL_OPEN_BUY:
         Print("SIGNAL OPEN BUY recieved.");
         Close_All(OP_SELL);
         lots=Lot();
         if(lots > 0 && orders_total < max_orders)
            OpenOrder(OP_BUY,lots);
         return;
      case SIGNAL_CLOSE_BUY:
         Print("SIGNAL CLOSE BUY recieved.");
         Close_All(OP_BUY);
         return;
      case SIGNAL_OPEN_SELL:
         Print("SIGNAL OPEN SELL recieved.");
         Close_All(OP_BUY);
         lots=Lot();
         if(lots > 0 && orders_total < max_orders)
            OpenOrder(OP_SELL,lots);
         return;
      case SIGNAL_CLOSE_SELL:
         Print("SIGNAL CLOSE SELL recieved.");
         Close_All(OP_SELL);
         return;
      case SIGNAL_NONE:
         Trail_Stop(OP_BUY);
         Trail_Stop(OP_SELL);
         return;
     }
  }
//+------------------------------------------------------------------+
//| Close or orders by type                                          |
//+------------------------------------------------------------------+
void Close_All(int Tip)
  {
   //Print("Close All ",OrderTypeToStr(Tip),"S");

   for(int i=0; i<orders_total; i++)
     {
      int ticket;
      double lot;

      if(orders[i][ORDER_G_TYPE]==Tip)
        {

         lot=orders[i][ORDER_G_LOTS];
         ticket=orders[i][ORDER_G_TICKET];

         Print("Trying to close order #",ticket,"...");
         while(true)
           {
            bool Answer=OrderClose(ticket,lot,CloseRightPrice(Tip),3,clrGold);

            if(Answer==true)
               break;
            else
              {
               if(Errors(GetLastError())==false)
                  break;
              }
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Calculate right price by order type                              |
//+------------------------------------------------------------------+
double RightPrice(int Tip)
  {
   switch(Tip)
     {
      case OP_BUY: return(Ask);
      case OP_SELL: return(Bid);
     }
   return(Bid);
  }
  
double CloseRightPrice(int Tip)
   {
   switch(Tip)
      {
      case OP_BUY: return(Bid);
      case OP_SELL: return(Ask);
      }
   return(Bid);   
   }  
//+------------------------------------------------------------------+
//| Calculate right color by order type                              |
//+------------------------------------------------------------------+
color RightColor(int Tip)
  {
   switch(Tip)
     {
      case OP_BUY: return(clrGreen);
      case OP_SELL: return(clrIndianRed);
     }
   return(clrIndigo);
  }
//+------------------------------------------------------------------+
//| Open single order                                                |
//+------------------------------------------------------------------+
void OpenOrder(int Tip,double lot_size)
  {
   int ticket,magic;
   double SL,TP,SAR,BB_UP,BB_LOW;
   SL = 0;
   TP = 0;

   
   while(true)
     {
      magic=TimeCurrent();
      SAR=iSAR(Symbol(),0,SARStep,SARMax,0);
      BB_UP = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_UPPER,0);
      BB_LOW = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_LOWER,0);
      
      switch(Tip)
        {
         case OP_BUY:
           {
            //Print("BUY== SAR: ",SAR,", BY LEVEL: ",Bid - (stop_level+25) * Point);
            double SLevel = Bid - (stop_level+25) * Point;
            SL = MathMin(SAR, SLevel);
            TP = 0;
            break;
           }
         case OP_SELL:
           {
            //Print("SELL== SAR: ",SAR,". BY LEVEL: ",Ask + (stop_level+25) * Point);
            double SLevel = Ask + (stop_level+25) * Point;
            SL = MathMax(SAR, SLevel);
            TP = 0;
            break;
           }
        }
      Print("Trying to open ",OrderTypeToStr(Tip)," on ",lot_size," lots. Price: ",
            RightPrice(Tip),", SL: ",SL,", TP: ",TP);  

      ticket=OrderSend(Symbol(),Tip,lot_size,RightPrice(Tip),3,SL,TP,NULL,
                       magic,0,RightColor(Tip));
      if(ticket>0)
         break;
      else
        {
         if(Errors(GetLastError())==false)
            break;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Modify stoploss level of orders type                             |
//+------------------------------------------------------------------+
void Trail_Stop(int Tip)
  {
   double SL,SAR,BB_UP,BB_LOW;
   bool modify=false;
   for(int i=0; i<orders_total; i++)
     {
      if(orders[i][ORDER_G_TYPE]==Tip)
        {
         
         while(true)
           {
            SAR=iSAR(Symbol(),0,SARStep,SARMax,0);
            BB_UP = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_UPPER,0);
            BB_LOW = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_LOWER,0);

            switch(Tip)
              {
               case OP_BUY:
                 {
                  double SLevel = Bid -(stop_level+5)*Point;
                  SL=MathMin(SAR,SLevel);
                  if(SL>orders[i][ORDER_G_STOPLOSS])
                     modify=true;
                  break;   
                 }
               case OP_SELL:
                 {
                  double SLevel = Ask+(stop_level+5)*Point;
                  SL=MathMax(SAR, SLevel);
                  if(SL<orders[i][ORDER_G_STOPLOSS])
                     modify=true;
                  break;   
                 }
              }
            if(modify==true)
              {
               modify=false;
               Print("Trying to modify order #",orders[i][ORDER_G_TICKET],
                     ", Old SL: ",orders[i][ORDER_G_STOPLOSS],", New SL: ",SL);
               bool Answer=OrderModify(orders[i][ORDER_G_TICKET],orders[i][ORDER_G_OPENPRICE],
                                       SL,orders[i][ORDER_G_TAKEPROFIT],0,clrDodgerBlue);
               if(Answer==true)
                  break;
               else
                 {
                  if(Errors(GetLastError())==false)
                     break;
                 }
              }
            else
               break;
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Convert order code to string                                     |
//+------------------------------------------------------------------+
string OrderTypeToStr(int Tip)
  {
   string str;
   if(Tip == OP_BUY)
      str = "BUY ORDER";
   if(Tip == OP_SELL)
      str = "SELL ORDER";
   return(str);
  }   
//+------------------------------------------------------------------+

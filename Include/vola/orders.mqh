//+------------------------------------------------------------------+
//|                                                       orders.mqh |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property strict

#define  ORDER_G_TICKET       0
#define  ORDER_G_TYPE         1
#define  ORDER_G_LOTS         2
#define  ORDER_G_OPENPRICE    3
#define  ORDER_G_STOPLOSS     4
#define  ORDER_G_TAKEPROFIT   5
#define  ORDER_G_MAGIC        6
#define  ORDER_G_COMMENT      7
//+------------------------------------------------------------------+
//| Load Orders From Terminal                                        |
//+------------------------------------------------------------------+
int LoadOrders()
  {
   int count=0;

   ArrayInitialize(orders,0);

   for(int i=0; i<OrdersTotal(); i++)
     {
      if((OrderSelect(i,SELECT_BY_POS)==true) && (OrderSymbol()==Symbol()))
        {
         orders[count][ORDER_G_TICKET]=OrderTicket();
         orders[count][ORDER_G_TYPE] = OrderType();
         orders[count][ORDER_G_LOTS] = OrderLots();
         orders[count][ORDER_G_OPENPRICE]= OrderOpenPrice();
         orders[count][ORDER_G_STOPLOSS] = OrderStopLoss();
         orders[count][ORDER_G_TAKEPROFIT]=OrderTakeProfit();
         orders[count][ORDER_G_MAGIC]=OrderMagicNumber();
         count++;
        }
     }

   return count;
  }
//+------------------------------------------------------------------+

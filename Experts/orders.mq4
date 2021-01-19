//+------------------------------------------------------------------+
//|                                                       orders.mq4 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- includes
#include <Mt4Redis/Redis.mqh>
#include <mine/utils.mqh>
//--- input parameters
input string   address="192.168.0.16";
input int      port=6379;
input string   password;
input int      db=0;

Redis *client=NULL;
string redisOrdersId = StringFormat("account:%d:orders_data", AccountNumber());
int closed_orders[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   RedisContext *c=RedisContext::connect(address,port);
   if(c==NULL)
     {
      return INIT_FAILED;
     }
   client = new Redis(c);
   client.auth(password);
   client.select(db);
   
   PushClosedOrdersToRedis();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(CheckPointer(client)!=POINTER_INVALID)
     {
      client.quit();
      delete client;
     }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   PushClosedOrdersToRedis();
   PushOpenedOrdersToRedis();
  }
//+------------------------------------------------------------------+
//| Push Order to Redis                                              |
//+------------------------------------------------------------------+
void PushOrderToRedis()
   {
      client.hset(redisOrdersId, OrderTicket(), OrderToRedis());
   }
   
//+------------------------------------------------------------------+
//| Push Closed Orders to Redis                                      |
//+------------------------------------------------------------------+
void PushClosedOrdersToRedis()
   {
      int total = OrdersHistoryTotal();
      int closed_size = ArraySize(closed_orders);
      
      if(closed_size < total)
         {
            ArrayResize(closed_orders, total);
            for(int i=closed_size; i<total; i++)
               {
                  if(OrderSelect(i ,SELECT_BY_POS, MODE_HISTORY)==true)
                     {
                        closed_orders[i] = OrderTicket();
                        PushOrderToRedis();
                     }
                  else
                     {
                        Print(GetLastError());
                     }   
               }
         }
   }

//+------------------------------------------------------------------+
//| Push Opened Orders to Redis                                      |
//+------------------------------------------------------------------+
void PushOpenedOrdersToRedis()
   {
      for(int i=0; i<OrdersTotal(); i++)
         {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
               {
                  PushOrderToRedis();
               }
         }
   }   
//+------------------------------------------------------------------+
//|                                                       market.mq4 |
//|                                      Copyright 2020, Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Edward Bako"
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
string redisSeriesId = StringFormat("series:%s:%d:data", Symbol(), Period());
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
   
   PushHistoryToRedis();
 
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
     PushCurrentToRedis();
      
     return;
  }
//+------------------------------------------------------------------+
//| Push stock data to Redis                                         |
//+------------------------------------------------------------------+
void PushHistoryToRedis()
   {
      int i = Bars - 1;
      int counter = 0;
      
      string last = client.lpop(redisSeriesId);
      
      while(i >= 0)
         {
            if(TimeToRFC(Time[i]) >= ItemRFCTime(last))
               {
                  client.lpush(redisSeriesId, QuoteToRedis(i));
                  counter++;
               }
            i--;
         }
      Print("Pushed :" + counter + " items to Redis.");
      return;
   }
//+------------------------------------------------------------------+
//| Push Current to Redis                                          |
//+------------------------------------------------------------------+
void PushCurrentToRedis()
   {
      string last = client.lpop(redisSeriesId);
      
      if(TimeToRFC(Time[0]) == ItemRFCTime(last))
         {
            client.lpush(redisSeriesId, QuoteToRedis(0));
         }
      else
         {
            client.lpush(redisSeriesId, QuoteToRedis(1));
            client.lpush(redisSeriesId, QuoteToRedis(0));
         }   

      return;   
   }
 
//+------------------------------------------------------------------+

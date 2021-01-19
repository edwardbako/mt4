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
//--- input parameters
input string   address="192.168.0.16";
input int      port=6379;
input string   password;
input int      db=0;
input int      expire=60;

Redis *client=NULL;
string redisAskKey = StringFormat("%s:ask", Symbol());
string redisBidKey = StringFormat("%s:bid", Symbol());
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
     client.set(redisAskKey, DoubleToString(Ask), expire);
     client.set(redisBidKey, DoubleToString(Bid), expire);
      
     return;
  }
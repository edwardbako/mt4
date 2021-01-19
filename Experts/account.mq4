//+------------------------------------------------------------------+
//|                                                      account.mq4 |
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

Redis *client=NULL;
string redisAccountId = StringFormat("account:%d:data", AccountNumber());

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   RedisContext *c=RedisContext::connect(address,port);
   if(c==NULL)
      {
         return(INIT_FAILED);
      }
   client = new Redis(c);
   client.auth(password);
   client.select(db);
   
   PushAccountBasicsToRedis();
   
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
   PushAccountInfoToRedis();
  }
//+------------------------------------------------------------------+   
void PushAccountBasicsToRedis()
   {
      HSet("name", AccountName());
      HSet("server", AccountServer());
      HSet("company", AccountCompany());
      HSet("currency", AccountCurrency());
      HSet("leverage", AccountLeverage());
      HSet("stopout_level", AccountStopoutLevel());
      HSet("stopout_mode", AccountStopoutMode());
   }
//+------------------------------------------------------------------+
void PushAccountInfoToRedis()
   {
      HSet("balance", AccountBalance());
      HSet("credit", AccountCredit());
      HSet("equity", AccountEquity());
      HSet("margin", AccountMargin());
      HSet("free_margin", AccountFreeMargin());
   }   
//+------------------------------------------------------------------+
void HSet(string field, string value)
   {
      StringReplace(value, " ", "\\");
      client.hset(redisAccountId, field, value);
      
      if(!client.isOk())
         Print(client.getErrorMessage());

   }
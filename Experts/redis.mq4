//+------------------------------------------------------------------+
//|                                                        redis.mq4 |
//|                                      Copyright 2020, Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- includes
#include <Mt4Redis/RedisContext.mqh>
//--- input parameters
input string   address="192.168.0.16";
input int      port=6379;
input string   password;
input int      db=0;
input int      expire=60;
input string   timezone="+02:00";

RedisContext *client=NULL;
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
   client=c;
   
   Auth();
   SelectDb();
   PushAccountBasicsToRedis();
   PushSeriesToRedis();
   Print(OrdersTotal());
   Print(OrdersHistoryTotal());
 
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(CheckPointer(client)!=POINTER_INVALID)
     {
      delete client;
     }
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
     SetAsk();
     SetBid();
     PushCurrentToRedis();
     PushAccountInfoToRedis();
      
     return;
  }
  
//+------------------------------------------------------------------+
//| Send Redis Command                                               |
//+------------------------------------------------------------------+
void Command(string command, bool showStatus=false)
   {
      RedisReply *reply;
      reply=client.command(command);
      
      if(showStatus==true && reply.isStatus())
         {
            Print("Command ##" + command + "## status: " + reply.getString());
         }
         
      if(reply.isError())
         {
            Print("Command ##" + command + "## failed: " + reply.getString());
         }
      
//      if(reply.isInteger())
//         {
//            Print("For request ##" + command + "## Redis returns: " + reply.getInteger());
//         }
//      if(reply.isString())
//         {
//            Print("For request ##" + command + "## Redis returns: " + reply.getString());
//         }
//      if(reply.isNil())
//         {
//            Print("Redis returned NOTHING AT ALL");
//         }      
      delete(reply);
      return;
   }

//+------------------------------------------------------------------+
//| Authenticate to Redis                                            |
//+------------------------------------------------------------------+
void Auth()
   {
      if(password!=NULL && password!="")
         {
            Command("AUTH " + password, true);
         }
   }

//+------------------------------------------------------------------+
//| Select Redis Database number                                     |
//+------------------------------------------------------------------+
void SelectDb()
   {
      Command("SELECT " + db, true);
   }  
  
//+------------------------------------------------------------------+
//| Set Ask price on Redis                                           |
//+------------------------------------------------------------------+
void SetAsk()
   {
     Command("SET " + Symbol() + ":ask " + DoubleToString(Ask) + " EX 60");
   }
   
//+------------------------------------------------------------------+
//| set Bid price on Redis                                           |
//+------------------------------------------------------------------+
void SetBid()
   {
      Command("SET " + Symbol() + ":bid " + DoubleToString(Bid) + " EX 60");
   }
//+------------------------------------------------------------------+
//| Push item to Redis                                               |
//+------------------------------------------------------------------+
void PushToRedis(string item)
   {
      Command("LPUSH " + RedisListId() + " " + item);
      return;
   }
//+------------------------------------------------------------------+
//| Push stock data to Redis                                         |
//+------------------------------------------------------------------+
void PushSeriesToRedis()
   {
      int i = Bars - 1;
      int counter = 0;
      string last = ListItem(0);
      
      while(i >= 0)
         {
            if(TimeToRFC(Time[i]) > ItemRFCTime(last))
               {
                  PushToRedis(QuoteToRedis(i));
                  counter++;
                  Print("Already pushed :" + counter + " items");
               }
            i--;
         }
      return;
   }
//+------------------------------------------------------------------+
//| Sets last item on Redis                                          |
//+------------------------------------------------------------------+
void SetRedisItem(int index, string item)
   {
      Command("LSET " + RedisListId() + " " + index + " " + item);
      return;
   }   
//+------------------------------------------------------------------+
//| Push Current to Redis                                          |
//+------------------------------------------------------------------+
void PushCurrentToRedis()
   {
      string last = ListItem(0);
      if(TimeToRFC(Time[0]) == ItemRFCTime(last))
         SetRedisItem(0, QuoteToRedis(0));
      else
         PushToRedis(QuoteToRedis(0));
         SetRedisItem(1, QuoteToRedis(1));
      
      return;   
   }
 
//+------------------------------------------------------------------+
//| Redis List Id                                             |
//+------------------------------------------------------------------+
string RedisListId()
   {
   return("series:" + Symbol() + ":" + Period() + ":data");
   }

//+------------------------------------------------------------------+
//| Redis List Item                                            |
//+------------------------------------------------------------------+
string ListItem(int index)
   {
      string command = "LINDEX " + RedisListId() + " " + index;
      RedisReply *reply;
      reply=client.command(command);
      
      if(reply.isStatus())
         {
            Print("Command ##" + command + "## status: " + reply.getString());
            delete(reply);
            return(NULL);
         }
         
      if(reply.isError())
         {
            Print("Command ##" + command + "## failed: " + reply.getString());
            delete(reply);
            return(NULL);
         }
      
      if(reply.isString())
         {
            //Print("For request ##" + command + "## Redis returns: " + reply.getString());
            string result = reply.getString();
            delete(reply);
            return(result);
         }
      if(reply.isNil())
         {
            Print("Redis returned NOTHING AT ALL");
            delete(reply);
            return(NULL);
         }      
      return(NULL);
   }
   
//+------------------------------------------------------------------+
//| Parse                                           |
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
      
      return(yyyy + "-" + mm + "-" + dd + "T" + HH + ":" + MM + ":" + "00" + timezone);
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
//| QuoteToRedis                                                     |
//+------------------------------------------------------------------+
string QuoteToRedis(int index)
   {
      string time = TimeToRFC(Time[index]);
      string open = Open[index];
      string high = High[index];
      string low = Low[index];
      string close = Close[index];
      string volume = Volume[index];
      return(time + "|" + open + "|" + high + "|" + low + "|" + close + "|" + volume);
   }
   
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Redis Account Id                                                 |
//+------------------------------------------------------------------+
string RedisAccountId()
   {
      return("account:" + AccountNumber() + ":data");
   }
//+------------------------------------------------------------------+
//| Push Account Info to Redis                                       |
//+------------------------------------------------------------------+
void PushAccountBasicsToRedis()
   {
      //Command("HSET " + RedisAccountId() + " name "  + "\"" + AccountName() + "\"");
      //Command("HSET " + RedisAccountId() + " server "  + '"' + AccountServer() + '"');
      //Command("HSET " + RedisAccountId() + " company "  + '"' + AccountCompany() + '"');
      Command("HSET " + RedisAccountId() + " curreny "  + AccountCurrency());
      Command("HSET " + RedisAccountId() + " leverage "  + AccountLeverage());
      Command("HSET " + RedisAccountId() + " stopout_level "  + AccountStopoutLevel());
      Command("HSET " + RedisAccountId() + " stopout_mode "  + AccountStopoutMode());
   }
   
void PushAccountInfoToRedis()
   {
      Command("HSET " + RedisAccountId() + " balance "  + AccountBalance());
      Command("HSET " + RedisAccountId() + " credit "  + AccountCredit());
      Command("HSET " + RedisAccountId() + " equity "  + AccountEquity());
      Command("HSET " + RedisAccountId() + " margin "  + AccountMargin());
      Command("HSET " + RedisAccountId() + " free_margin "  + AccountFreeMargin());
   }   

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Redis Orders List Id                                             |
//+------------------------------------------------------------------+
string RedisOrdersListId()
   {
      return("account:" + AccountNumber() + ":mt_orders");
   }
//+------------------------------------------------------------------+
//| Redis Orders List Id                                             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                         vola.mq4 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- includes
#include <vola\orders.mqh>
#include <vola\lot.mqh>
#include <vola\signal.mqh>
#include <vola\trade.mqh>
#include <vola\errors.mqh>

//--- input parameters

extern double     margin_call=200.0;
extern double     symbol_max_load=5.0;
extern int        max_orders=1;
//--- globals

double lots;
double orders[331][9];
int orders_total;

double stop_level=MarketInfo(Symbol(),MODE_STOPLEVEL);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(IsDemo())
      Print("Я работаю на демонстрационном счете");
   else
      Print("Я работаю на реальном счете");

   orders_total=LoadOrders();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   return;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   orders_total=LoadOrders();
   Trade(Signal());
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+

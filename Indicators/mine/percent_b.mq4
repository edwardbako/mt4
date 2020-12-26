//+------------------------------------------------------------------+
//|                                                    percent_b.mq4 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot MAIN
#property indicator_label1  "MAIN"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- levels
#property indicator_level1 0
#property indicator_level2 50
#property indicator_level3 100
#property indicator_levelcolor clrSlateGray
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1
//--- input parameters
input int      BandsPeriod=20;
input double   BandsDeviation=2.0;
//--- indicator buffers
double         MAINBuffer[];

int inside = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MAINBuffer);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < BandsPeriod)
      return(-1);
   if(prev_calculated < 0)
      return(-1);
      
   int i = rates_total - prev_calculated - 1;
   double upper, lower, price;
   
   
   while(i >= 0)
      {
      price = (high[i] + low[i] + close[i]) / 3;
      upper = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_UPPER,i);
      lower = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_LOWER,i);
      //double middle = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_MAIN,i);
      
      if(price < upper && price > lower)
         inside++;
      
      if(upper - lower > 0)
         MAINBuffer[i] = (price - lower) / (upper - lower) * 100;
      else
         MAINBuffer[i] = 0;   
      i--;
      }
   
   price = (high[0] + low[0] + close[0]) / 3;
   upper = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_UPPER,0);
   lower = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_LOWER,0);
   
   MAINBuffer[0] = (price - lower) / (upper - lower) * 100;
   
   //if(tick_volume[0] < 3)
   //   Print("Inside rate: ",100.0 * inside / rates_total);
   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

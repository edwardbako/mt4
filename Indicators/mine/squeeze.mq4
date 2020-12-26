//+------------------------------------------------------------------+
//|                                                      squeeze.mq4 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 5

input int StepBack = 200;
input int BandsPeriod = 20;
input double BandsDeviation = 2.0;
input double MinSqueze = 0.15;

double squeeze[], min[], max[], ready[], bandwidth[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,squeeze);
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2,clrDodgerBlue);
   SetIndexBuffer(1,min);
   SetIndexStyle(1,DRAW_LINE,STYLE_DASH,1,clrSlateGray);
   SetIndexBuffer(2,max);
   SetIndexStyle(2,DRAW_LINE,STYLE_DASH,1,clrSlateGray);
   SetIndexBuffer(3,ready);
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT,1,clrRed);
   SetIndexBuffer(4,bandwidth);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,2,clrBlack);
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
   if(rates_total < StepBack)
      return(-1);
   if(prev_calculated < 0)
      return(-1);   
      
   int i = rates_total - prev_calculated - 1;
      
   while(i >= 0)
      {
      double upper = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_UPPER,i);
      double lower = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_LOWER,i);
      double middle = iBands(Symbol(),0,BandsPeriod,BandsDeviation,0,PRICE_TYPICAL,MODE_MAIN,i);
      
      if(middle > 0)
         bandwidth[i] = (upper - lower) / middle * 100;
      else
         bandwidth[i] = 0;   
      
      
      double minimum, maximum;
      minimum = bandwidth[i];
      maximum = 0;
      if(i < rates_total - StepBack)
         {
         for(int j = i; j <= i + StepBack - 1; j++)
            {
            if(minimum > bandwidth[j])
               minimum = bandwidth[j];
            if(maximum < bandwidth[j])
               maximum = bandwidth[j];   
            }
         min[i] = minimum;
         max[i] = maximum;
         ready[i] = min[i] + (max[i] - min[i]) * MinSqueze;
         
         if(bandwidth[i] < ready[i])
            squeeze[i] = max[i] * (ready[i] - bandwidth[i]) / (ready[i] - min[i]);
         else
            squeeze[i] = 0;   
         }
      
      i--;
      }      
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

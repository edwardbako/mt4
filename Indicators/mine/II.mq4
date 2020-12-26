//+------------------------------------------------------------------+
//|                                                           II.mq4 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Main
#property indicator_label1  "Main"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot sma
#property indicator_label2  "sma"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRoyalBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

extern int Period = 14;
extern int II_SMA = 20;
//--- indicator buffers
double         MainBuffer[];
double         smaBuffer[];
double         sum = 0;
double         sumv = 0;
datetime       TimePrev;
bool           inited = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MainBuffer);
   SetIndexBuffer(1,smaBuffer);
   //TimePrev = Time[0];
   
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
   if(rates_total < II_SMA)
      return(-1);
      
   if(prev_calculated < 0)
      return(-1);
      
   int i = rates_total - prev_calculated - 1;
   
   while(i > 0)
      {
      sum += ii(i);
      sumv += tick_volume[i];    
      
      if(i < rates_total - Period)   
         {
         sum -= ii(i+Period);
         sumv -= tick_volume[i+Period];
         MainBuffer[i] = sum / sumv;
         }
      else
         MainBuffer[i] = 0;   
         
         
      i--;
      }
      
      
      if(TimePrev != time[0])
         {
         TimePrev = time[0];
         if(inited == false)
            inited = true;
         else
            {
            sum += ii(1);
            sumv += tick_volume[1];
            }
         if(rates_total > Period)
            {
            sum -= ii(Period);
            sumv -= tick_volume[Period];
            }
         }

      MainBuffer[0] = (sum + ii(0)) / (sumv + tick_volume[0]);      
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
  
double ii(int i)
   {
   if(High[i] - Low[i] > 0)
      return((2 * Close[i] - High[i] - Low[i]) / (High[i] - Low[i]) * Volume[i]) * 10000;
   return(0);   
   }               
//+------------------------------------------------------------------+


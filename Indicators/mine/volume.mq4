//+------------------------------------------------------------------+
//|                                                       volume.mq4 |
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
//--- plot MAIN
#property indicator_label1  "MAIN"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label2  "MA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2 STYLE_SOLID

#property indicator_level1 100
#property indicator_levelcolor clrSeaGreen
#property indicator_levelstyle STYLE_SOLID
#property indicator_levelwidth 1
//--- input parameters
input int      MAPeriod=50;
//--- indicator buffers
double         MAINBuffer[], MA[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MAINBuffer);
   SetIndexBuffer(1,MA);
   
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
   long v;
   int i = rates_total - prev_calculated - 1;
   
   if(rates_total < MAPeriod)
      return(-1);
   
   if(prev_calculated < 0)
      return(-1);
      
   v = tick_volume[0];
   
   while(i > 0)
      {
      double sum = 0;
      if(i < rates_total - MAPeriod)
         {
         for(int j = i; j <= i + MAPeriod; j++)
            {
            sum += tick_volume[j];
            }
         }   
      
      double ma = sum / MAPeriod;   
      
      if(ma > 0)
         MAINBuffer[i] = tick_volume[i] / ma * 100;
      else
         MAINBuffer[i] = 0;
         
      MA[i] = ma;   
      
      i--;
      }
   
   double sum, ma;
   if(i == 0)
      sum = 0;
      ma = 0;
      {
      for(int j = 0; j < MAPeriod; j++)
         sum += tick_volume[j];
      ma = sum / MAPeriod;
      
      if(ma > 0)
         MAINBuffer[0] = v / ma * 100;
      else
         MAINBuffer[0] = 0;      
      MA[0] = ma;
      }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

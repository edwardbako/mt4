//+------------------------------------------------------------------+
//|                                                       mfi_%b.mq4 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot Main
#property indicator_label1  "Main"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "mfi"
#property indicator_type2   DRAW_NONE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- Levels
#property indicator_level1 0
#property indicator_level2 50
#property indicator_level3 100
#property indicator_levelcolor clrSlateGray
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1
//--- input parameters
input int      MFIPeriod=14;
input int      BandsPeriod=50;
input double   BandsDeviation=2.0;
//--- indicator buffers
double         MainBuffer[], MFI[];

int inside = 0;
int outside = 0;
int middleout = 0;
int stepback = 1000;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MainBuffer);
   SetIndexBuffer(1,MFI);
   
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
   
   while(i >= 0)
      {
      MFI[i] = iMFI(Symbol(),0,MFIPeriod,i);
      i--;
      }
      
   MFI[0] = iMFI(Symbol(),0,MFIPeriod,0);   
   
   i = rates_total - prev_calculated - 1;
   
   double upper, lower, middle;
   
   while(i >= 0)
      {
      upper = iBandsOnArray(MFI,0,BandsPeriod,BandsDeviation,0,MODE_UPPER,i);
      lower = iBandsOnArray(MFI,0,BandsPeriod,BandsDeviation,0,MODE_LOWER,i);
      middle = iBandsOnArray(MFI,0,BandsPeriod,BandsDeviation,0,MODE_MAIN,i);
      
      if(i < rates_total - stepback)
      if(middle > 75 || middle < 25)
         middleout++;
         
      if(MFI[i] < upper && MFI[i] > lower)
         inside++;
      else
         outside++;      
      
      if(upper - lower > 0)
         MainBuffer[i] = (MFI[i] - lower) / (upper - lower) * 100;
      else
         MainBuffer[i] = 0;   
      i--;
      }
      
   upper = iBandsOnArray(MFI,0,BandsPeriod,BandsDeviation,0,MODE_UPPER,0);
   lower = iBandsOnArray(MFI,0,BandsPeriod,BandsDeviation,0,MODE_LOWER,0);
   
   if(upper - lower > 0)
      MainBuffer[0] = (MFI[0] - lower) / (upper - lower) * 100;
   else
      MainBuffer[0] = 0;     
      
   //if(tick_volume[0] < 2)   
   //   {
   //   Print("inside rate: ", 100.0 * inside / rates_total);
   //   Print("midle outside: ",middleout);
   //   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

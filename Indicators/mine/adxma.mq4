//+------------------------------------------------------------------+
//|                                                        adxma.mq4 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_level1 25
#property indicator_levelcolor clrSlateGray
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1
//--- input parameters
input int      ADXPeriod=14;
input int      MAPeriod=20;

double ADXMA[], ADX[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,ADXMA);
   SetIndexStyle(0,DRAW_LINE,STYLE_DASH,1,clrRed);
   
   SetIndexBuffer(1,ADX);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,clrDodgerBlue);
   
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
   if(Bars < MathMax(ADXPeriod, MAPeriod))
      return(-1);
   if(prev_calculated < 0)
      return(-1);
         
   int i = rates_total - prev_calculated - 1;
   while(i >= 0)
      {
      ADX[i]=iADX(Symbol(),0,ADXPeriod,PRICE_TYPICAL,0,i);
      i--;
      }
   
   i = rates_total - prev_calculated - 1;
   while(i >= 0)
      {
      ADXMA[i] = iMAOnArray(ADX,0,MAPeriod,0,MODE_SMA,i);
      i--;
      }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

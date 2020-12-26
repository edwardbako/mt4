//+------------------------------------------------------------------+
//|                                                       signal.mqh |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| Define Signals codes                                             |
//+------------------------------------------------------------------+
#define SIGNAL_OPEN_BUY       10
#define SIGNAL_CLOSE_BUY      11
#define SIGNAL_OPEN_SELL      20
#define SIGNAL_CLOSE_SELL     21
#define SIGNAL_NONE           0
#define SIGNAL_WRONG          -1
//+------------------------------------------------------------------+
//| Extern variables for tune                                        |
//+------------------------------------------------------------------+
extern int StepBack=200;
extern int BandsPeriod=20;
extern double BandsDeviation=3.2;
extern double EnterLimit=35.0;
extern double ExitLimit=50.0;
extern double MinSqueeze=0.15;
//extern int ADXPeriod=14;
//extern int ADXMAPeriod=20;
extern double SARStep= 0.02;
extern double SARMax = 0.2;
extern int MFIPeriod = 14;
extern int IILength = 10;
//extern int ADXMALimit = 40;
extern int LongMAPeriod = 100;
extern int LongerMAPeriod = 150;
extern double MACDLimit = 3.0;

//+------------------------------------------------------------------+
//| Produce trade signal                                             |
//+------------------------------------------------------------------+
int Signal()
  {
   //if(Volume[0] > 1)
   //   return(SIGNAL_NONE);
   
   double ADX, ADX_Prev, ADXPlus_0, ADXPlus_1, ADXMinus_0, ADXMinus_1, ADXMA,
          PercentB_1, PercentB_2, II, IIPrev, SAR, SAR_Prev, squeeze, MFI,
          MA_Long, MA_Longer, MacdCurrent, SignalCurrent;

   //ADX = iADX(Symbol(),0,ADXPeriod,PRICE_TYPICAL,0,0);
   //ADX_Prev = iADX(Symbol(),0,ADXPeriod,PRICE_TYPICAL,0,1);
   //ADXPlus_0 = iADX(Symbol(),0,ADXPeriod,PRICE_TYPICAL,1,0);
   //ADXPlus_1 = iADX(Symbol(),0,ADXPeriod,PRICE_TYPICAL,1,1);
   //ADXMinus_0 = iADX(Symbol(),0,ADXPeriod,PRICE_TYPICAL,2,0);
   //ADXMinus_1 = iADX(Symbol(),0,ADXPeriod,PRICE_TYPICAL,2,1);
   //ADXMA = iCustom(Symbol(),0,"mine\\adxma",ADXPeriod,ADXMAPeriod,0,0);
   PercentB_1 = iCustom(Symbol(),0,"mine\\percent_b",
                        BandsPeriod,BandsDeviation,0,0);
   PercentB_2 = iCustom(Symbol(),0,"mine\\percent_b",
                        BandsPeriod,BandsDeviation,0,1);
   //II = iCustom(Symbol(), 0,"III2",IILength,0,0);
   SAR = iSAR(Symbol(),0,SARStep,SARMax,0);
   SAR_Prev = iSAR(Symbol(),0,SARStep,SARMax,1);
   //squeeze = iCustom(Symbol(),0,"mine\\squeeze",StepBack,BandsPeriod,BandsDeviation,
   //                  MinSqueeze,0,0);
   MFI = iMFI(Symbol(),0,MFIPeriod,0);
   
   MA_Long = iMA(Symbol(),0,LongMAPeriod,0,MODE_SMA,PRICE_TYPICAL,0);
   //MA_4_Long = iMA(Symbol(),0,LongMAPeriod,0,MODE_SMA,PRICE_TYPICAL,4);
   MA_Longer = iMA(Symbol(),0,LongerMAPeriod,0,MODE_SMA,PRICE_TYPICAL,0);
   //MacdCurrent = iMACD(Symbol(),0,12,26,9,PRICE_TYPICAL,MODE_MAIN,0);
   //SignalCurrent = iMACD(Symbol(),0,12,26,9,PRICE_TYPICAL,MODE_SIGNAL,0);
   
   //II = iCustom(Symbol(),0,"mine\\II",IILength,20,0,0);
   //IIPrev = iCustom(Symbol(),0,"mine\\II",IILength,20,0,1);
   
   
   if(PercentB_2 < 100 - EnterLimit && PercentB_1 >= 100 - EnterLimit )
      return(SIGNAL_OPEN_BUY);
      
   if(PercentB_2 > EnterLimit && PercentB_1 <= EnterLimit )
      return(SIGNAL_OPEN_SELL);
      
//   if(PercentB_2 >= 100 - ExitLimit && PercentB_1 < 100 - ExitLimit)
//      return(SIGNAL_CLOSE_BUY);
//      
//   if(PercentB_2 <= ExitLimit && PercentB_1 > ExitLimit)
//      return(SIGNAL_CLOSE_SELL);      

//   if(MA_Long > MA_Longer && SAR >= SAR_Prev)
      //return(SIGNAL_OPEN_BUY)
   //if(MA_Long < MA_Longer && SAR >= SAR_Prev)
      //return(SIGNAL_CLOSE_BUY)
//      
   //if(MA_Long < MA_Longer && SAR <= SAR_Prev)
      //return(SIGNAL_OPEN_SELL)
   //if(MA_Long > MA_Longer && SAR <= SAR_Prev)
      //return(SIGNAL_CLOSE_SELL)      

      
   return(SIGNAL_NONE);
  }
//+------------------------------------------------------------------+

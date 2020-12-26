//+------------------------------------------------------------------+
//|                                                       errors.mqh |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| Handle errors. true - continue. false - fatal.                   |
//+------------------------------------------------------------------+
bool Errors(int Error)
  {
   switch(Error)
     {
      case 0:
         Print("OK");
         return(false);
         //---
      case 129:
         Print("Wrong price.");
         RefreshRates();
         return(true);
      case 135:
         Print("Price changed.");
         RefreshRates();
         return(true);
      case 136:
         Print("There is no price. Waiting...");
         while(RefreshRates()==false)
            Sleep(1);
         return(true);
      case 138:
         Print("Price mistake.");
         RefreshRates();
         return(false);   
      case 146:
         Print("Trade system is busy.");
         return(true);
         //--- Critical Errors
      case 2:
         Print("General Error.");
         return(false);
      case 5:
         Print("Old terminal version.");
         return(false);
      case 64:
         Print("Account blocked.");
         return(false);
      case 133:
         Print("Trade denied.");
         return(false);
      default:
         Print("ERROR #",Error);
         return(false);
     }

  }
//+------------------------------------------------------------------+

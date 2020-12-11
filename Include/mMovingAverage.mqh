//+------------------------------------------------------------------+
//|                                               mMovingAverage.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| Const                                                            |
//+------------------------------------------------------------------+
enum ENUM_MOVINGAVERAGE_TREND // enumeration of named constants
{
   MOVINGAVERAGE_NONE,        // 0
   MOVINGAVERAGE_FALL,
   MOVINGAVERAGE_RISE
};
#define MA_Main_maPeriod   8
#define MA_Sign_maPeriod   89
#define MA_maShift         0
#define MA_Method          MODE_SMMA
#define MA_Price           PRICE_CLOSE
#define MA_Shift           0
//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
// Indicator: 
//    MODE_MAIN < MODE_SIGNAL: SHORT
//    MODE_MAIN > MODE_SIGNAL: LONG

//+------------------------------------------------------------------+
//| Param                                                            |
//+------------------------------------------------------------------+
bool CLASS_MA_ENABLE = false;
//+------------------------------------------------------------------+
//| Function                                                         |
//+------------------------------------------------------------------+
int OnMAInit(
   bool enable
   )
{
//---   
   CLASS_MA_ENABLE = enable;
   // Disabled
   if (!CLASS_MA_ENABLE)
      return 0;
//---
   return(INIT_SUCCEEDED);

}
void OnMADeinit(const int reason)
  {
//---
   
}
void OnMATimer()
{
}
//+------------------------------------------------------------------+
ENUM_MOVINGAVERAGE_TREND MATrend(
   string symbol = NULL,
   ENUM_TIMEFRAMES timeframe = NULL
   )
{
   // Disabled
   if (!CLASS_MA_ENABLE)
      return 0;
   //double  iMA(
   //   string       symbol,           // symbol
   //   int          timeframe,        // timeframe
   //   int          ma_period,        // MA averaging period
   //   int          ma_shift,         // MA shift
   //   int          ma_method,        // averaging method
   //   int          applied_price,    // applied price
   //   int          shift             // shift
   //   );
   double maMain  = iMA(symbol, timeframe, MA_Main_maPeriod, MA_maShift, MA_Method, MA_Price, MA_Shift);
   double maSign  = iMA(symbol, timeframe, MA_Sign_maPeriod, MA_maShift, MA_Method, MA_Price, MA_Shift);   
   //MODE_MAIN < MODE_SIGNAL: SHORT
   //MODE_MAIN > MODE_SIGNAL: LONG
   if (
      maMain < maSign
   ){
      return MOVINGAVERAGE_FALL;
   }else if(
      maMain > maSign
   ){
      return MOVINGAVERAGE_RISE;
   }
   return MOVINGAVERAGE_NONE;
}


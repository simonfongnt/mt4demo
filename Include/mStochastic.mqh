//+------------------------------------------------------------------+
//|                                                  mStochastic.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Const                                                            |
//+------------------------------------------------------------------+
enum ENUM_STOCHASTIC_TREND // enumeration of named constants
{
   STOCHASTIC_NONE,        // 0
   STOCHASTIC_FALL,
   STOCHASTIC_RISE
};
#define STC_Kperiod     5
#define STC_Dperiod     3
#define STC_slowing     3
//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
// Indicator: 
//    MODE_MAIN < MODE_SIGNAL: SHORT
//    MODE_MAIN > MODE_SIGNAL: LONG

//+------------------------------------------------------------------+
//| Param                                                            |
//+------------------------------------------------------------------+
bool CLASS_STC_ENABLE = false;
//+------------------------------------------------------------------+
//| Function                                                         |
//+------------------------------------------------------------------+
int OnSTCInit(
   bool enable
   )
{
//---   
   CLASS_STC_ENABLE = enable;
   // Disabled
   if (!CLASS_STC_ENABLE)
      return 0;
//---
   return(INIT_SUCCEEDED);

}
void OnSTCDeinit(const int reason)
  {
//---
   
}
void OnSTCTimer()
{
}
//+------------------------------------------------------------------+
ENUM_STOCHASTIC_TREND STCTrend(
   string symbol = NULL,
   ENUM_TIMEFRAMES timeframe = NULL
   )
{
   // Disabled
   if (!CLASS_STC_ENABLE)
      return 0;
   //double  iStochastic(
   //   string       symbol,           // symbol
   //   int          timeframe,        // timeframe
   //   int          Kperiod,          // K line period
   //   int          Dperiod,          // D line period
   //   int          slowing,          // slowing
   //   int          method,           // averaging method
   //   int          price_field,      // price (Low/High or Close/Close)
   //   int          mode,             // line index
   //   int          shift             // shift
   //   );
   double stcMain = iStochastic(symbol, timeframe, STC_Kperiod, STC_Dperiod, STC_slowing, MODE_SMA, 0, MODE_MAIN, 0);
   double stcSign = iStochastic(symbol, timeframe, STC_Kperiod, STC_Dperiod, STC_slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
   
   //MODE_MAIN < MODE_SIGNAL: SHORT
   //MODE_MAIN > MODE_SIGNAL: LONG
   if (
      stcMain < stcSign
   ){
      return STOCHASTIC_FALL;
   }else if(
      stcMain > stcSign
   ){
      return STOCHASTIC_RISE;
   }
   return STOCHASTIC_NONE;
}

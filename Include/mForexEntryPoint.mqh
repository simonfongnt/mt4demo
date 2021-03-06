//+------------------------------------------------------------------+
//|                                             mForexEntryPoint.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| Const                                                            |
//+------------------------------------------------------------------+
enum ENUM_FOREXENTRYPOINT_TREND // enumeration of named constants
{
   FOREXENTRYPOINT_NONE,        // 0
   FOREXENTRYPOINT_FALL,
   FOREXENTRYPOINT_RISE
};
//#define MA_Main_maPeriod   8
//#define MA_Sign_maPeriod   89
//#define MA_maShift         0
//#define MA_Method          MODE_SMMA
//#define MA_Price           PRICE_CLOSE
//#define MA_Shift           0

extern int KPeriod = 21;
extern int DPeriod = 12;
extern int Slowing = 3;
extern int method = 0;
extern int price = 0;
//extern string äëÿ_WPR = "";
extern int ExtWPRPeriod = 14;
extern double ZoneHighPer = 70.0;
extern double ZoneLowPer = 30.0;
extern bool modeone = TRUE;
extern bool PlaySoundBuy = TRUE;
extern bool PlaySoundSell = TRUE;
int gi_136 = 0;
extern string FileSoundBuy = "analyze buy";
extern string FileSoundSell = "analyze sell";
double g_ibuf_156[];
double g_ibuf_160[];
double g_ibuf_164[];
double g_ibuf_168[];
double g_ibuf_172[];
int gi_176 = 0;
int gi_180 = 0;
int g_time_184 = 0;
int gi_188 = 0;
int gi_192 = 0;
int gi_196 = 0;
//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Param                                                            |
//+------------------------------------------------------------------+
bool CLASS_FEP_ENABLE = false;
//+------------------------------------------------------------------+
//| Function                                                         |
//+------------------------------------------------------------------+
int OnFEPInit(
   bool enable
   )
{
//---   
   CLASS_FEP_ENABLE = enable;
   // Disabled
   if (!CLASS_FEP_ENABLE)
      return 0;
   return(INIT_SUCCEEDED);
}
void OnFEPDeinit(const int reason)
{
}
void OnFEPTimer()
{
}
//+------------------------------------------------------------------+
ENUM_FOREXENTRYPOINT_TREND FEPTrend(
   string symbol = NULL,
   ENUM_TIMEFRAMES timeframe = NULL
   )
{
   // Disabled
   if (!CLASS_FEP_ENABLE)
      return 0;   
   //extern int KPeriod = 21;
   //extern int DPeriod = 12;
   //extern int Slowing = 3;
   //extern int method = 0;
   //extern int price = 0;
   //extern string äëÿ_WPR = "";
   //extern int ExtWPRPeriod = 14;
   //extern double ZoneHighPer = 70.0;
   //extern double ZoneLowPer = 30.0;
   //extern bool modeone = TRUE;
   //extern bool PlaySoundBuy = TRUE;
   //extern bool PlaySoundSell = TRUE;
   //extern string FileSoundBuy = "analyze buy";
   //extern string FileSoundSell = "analyze sell";
   
   //ENUM_FOREXENTRYPOINT_TREND fepSignal = iCustom(symbol, timeframe, "mForexEntryPoint", 21, 12, 3, 0, 0, "", 14, 70.0, 30.0, TRUE, TRUE, TRUE, "analyze buy", "analyze sell", 5, 0);
   ENUM_FOREXENTRYPOINT_TREND fepSignal = iCustom(symbol, timeframe, "mForexEntryPoint", 21, 12, 3, 0, 0, "", 14, 70.0, 30.0, TRUE, TRUE, TRUE, 5, 0);
   return fepSignal;   
}
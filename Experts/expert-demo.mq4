//+------------------------------------------------------------------+
//|                                                  expert-demo.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include  <AlgoClass.mqh>
#include  <IOClass.mqh>
#include  <mStochastic.mqh>
#include  <mMovingAverage.mqh>
#include  <mForexEntryPoint.mqh>
//+------------------------------------------------------------------+
//| Const                                                            |
//+------------------------------------------------------------------+
#define STRATEGY_NAME         "EXPERT-DEMO"
#define TimerConst            3000
#define tradingQty            1
//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
double Stoplosspt =              0;    // Stoploss Point, 0 to disable, overrided Stoplosspc
double Stoplosspc =              0;    // Stoploss %, 0 to disable
double Stopgainpt =              0;    // Stopgain Point, 0 to disable, overrided Stopgainpc
double Stopgainpc =              0;    // Stopgain %, 0 to disable

#define CONFIG_IGNORE_HYSTERESIS       true     // Ignore PreOrderHysteresispc
#define PreOrderHysteresispc            0.05    // Hysteresis
#define CONFIG_CLOSE_AT_OPPOSITE_TREND false    // Enable Close at Opposite Trend

#define CONFIG_ALGO_HOURMODE           ALGO_HOURMODE_CLOSE_ONLY   // ALGO_HOURMODE_OFF: Disable
                                                                  // ALGO_HOURMODE_ON:  No Trade during time range
                                                                  // ALGO_HOURMODE_CLOSE_ONLY: only CLOSE during time range
#define CONFIG_ALGO_SHOUR              23                         // HOURMODE: Restriction Start (Local) Hour
#define CONFIG_ALGO_EHOUR              8                         // HOURMODE: Restriction End (Local) Hour

// Indicator: 
//    MODE_MAIN < MODE_SIGNAL: SHORT
//    MODE_MAIN > MODE_SIGNAL: LONG
#define STAT_STOCHASTIC_ENABLE         true
int StochasticArr[] = {             // Check from Bottom to Top
   //PERIOD_M1,
   PERIOD_M5,
   //PERIOD_M15,
   PERIOD_M30,
   PERIOD_H1,
   //PERIOD_H4,
   //PERIOD_D1,
   //PERIOD_W1,
   //PERIOD_MN1,
}; 
#define STAT_MOVINGAVERAGE_ENABLE      false
int MovingAverageArr[] = {             // Check from Bottom to Top
   PERIOD_M1,
   //PERIOD_M5,
   //PERIOD_M15,
   //PERIOD_M30,
   //PERIOD_H1,
   //PERIOD_H4,
   //PERIOD_D1,
   //PERIOD_W1,
   //PERIOD_MN1,
}; 
#define STAT_FOREX_ENTRY_POINT_ENABLE  false
int ForexEntryPointArr[] = {             // Pick one only
   PERIOD_M1,
   PERIOD_M5,
   PERIOD_M15,
   PERIOD_M30,
   PERIOD_H1,
   PERIOD_H4,
   PERIOD_D1,
   PERIOD_W1,
   PERIOD_MN1,
}; 
//+------------------------------------------------------------------+
//| Param                                                            |
//+------------------------------------------------------------------+
bool CONFIG_ALGO_ENABLE = true;
bool CONFIG_IO_ENABLE   = true;
double preOrderPrice    = 0;
ENUM_ALGOPREORDER preOrderStatus = PREORDER_NONE;
ENUM_TREND prevTrend    = TREND_NONE;
ENUM_TREND thisTrend    = TREND_NONE;
bool is_Instant         = CONFIG_IGNORE_HYSTERESIS;  // Assume not Instant Order
int mTicket             = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string initmsg = "MT4 (" + STRATEGY_NAME + ") is connected\n";
   // initialize IOCLASS
   if(   // Backtesting
         MQLInfoInteger(MQL_TESTER)
         // forgot to enable DLL
      || !MQLInfoInteger(MQL_DLLS_ALLOWED)
   ){
      initmsg = initmsg + "(Telegram Disabled)" +"\n";
      CONFIG_IO_ENABLE     = false;
   }else{
      initmsg = initmsg + "(Telegram Enabled)" +"\n";
      
      //--- create timer
      bool rt = EventSetMillisecondTimer(TimerConst);
      if(!rt)
      {
         Print("Error GetLastError() = ", GetLastError() ) ;
      }
   }
   // initialize ALGOCLASS
   if(
         // disabled trading
         !MQLInfoInteger(MQL_TRADE_ALLOWED)
   ){
      initmsg = initmsg + "(Trading Disabled)" +"\n";
      CONFIG_ALGO_ENABLE   = false;
   }else{// enabled trading
      initmsg = initmsg + "(Trading Enabled)" +"\n";
   }
   Alert(
      "CONFIG_ALGO_ENABLE: " + CONFIG_ALGO_ENABLE + " " +
      "CONFIG_IO_ENABLE: " + CONFIG_IO_ENABLE
      );
   // stoploss & stopgain
   if (Stoplosspt > 0)
      Stoplosspc = 0;
   if (Stopgainpt > 0)
      Stopgainpc = 0;    
   // initialization  
   OnIOInit  (CONFIG_IO_ENABLE);
   
   OnSTCInit (STAT_STOCHASTIC_ENABLE); 
   OnAlgoInit(
      CONFIG_ALGO_ENABLE,
      CONFIG_ALGO_HOURMODE,
      CONFIG_ALGO_SHOUR,
      CONFIG_ALGO_EHOUR
      );
   OnMAInit  (STAT_MOVINGAVERAGE_ENABLE);
   OnFEPInit (STAT_FOREX_ENTRY_POINT_ENABLE);
   
   Alert(initmsg);
   IOSendMsg(initmsg);
   //for(int i = ArraySize(StochasticArr)-1; i >= 0 ; i--){
   //   ENUM_TIMEFRAMES timeframe = StochasticArr[i];
   //   Alert(timeframe);
   //}
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   OnAlgoDeinit(reason);
   OnIODeinit  (reason);
   
   OnSTCDeinit (reason);
   OnMADeinit  (reason);
   OnFEPDeinit (reason);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   OnAlgoTimer();
   OnIOTimer  ();
   
   OnSTCTimer ();
   OnMATimer  ();
   OnFEPTimer ();
}
//+------------------------------------------------------------------+
ENUM_ALGOPREORDER OnTickCloseOrder(){
   preOrderPrice  = 0;
   preOrderStatus = PREORDER_NONE;
   return PREORDER_CLOSE;
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
      string msg  = "";        // message to be sent
      string tmsg = "";        // message to be sent
      int thists = getTimestamp();//
      // Direction?
      ENUM_DIRECTION oDir  = DIRECTION_NONE;
      int oTicket          = NULL;
      for(int pos = OrdersTotal()-1; pos >= 0 ; pos--){      
         if (
               OrderSelect(pos, SELECT_BY_POS)
               ){
            oDir     = OrderTypeToDirection(OrderType());
            oTicket  = OrderTicket();
            mTicket  = oTicket;
         }
      }
      int order = PREORDER_NONE;
      // Condition
      bool is_Long    = True;   // Assume Long Order
      bool is_Short   = True;   // Assume Short Order
      //// ENUM_FOREXENTRYPOINT_TREND
      //if (STAT_FOREX_ENTRY_POINT_ENABLE){
      //   tmsg = tmsg + "FEP ";
      //   for(int i = ArraySize(ForexEntryPointArr)-1; i >= 0 ; i--){
      //      ENUM_TIMEFRAMES timeframe = ForexEntryPointArr[i];
      //      ENUM_FOREXENTRYPOINT_TREND trend = FEPTrend(
      //               NULL,
      //               timeframe
      //               );
      //      if (trend == FOREXENTRYPOINT_RISE){
      //         is_Short   = False;
      //         tmsg = tmsg + Tf2Str(timeframe) + "+ ";
      //      }
      //      if (trend == FOREXENTRYPOINT_FALL){
      //         is_Long    = False;
      //         tmsg = tmsg + Tf2Str(timeframe) + "- ";
      //      }
      //   }
      //   tmsg = tmsg + "\n";
      //}   
      // ENUM_STOCHASTIC_TREND
      if (STAT_STOCHASTIC_ENABLE){
         tmsg = tmsg + "STC ";
         for(int i = ArraySize(StochasticArr)-1; i >= 0 ; i--){
            ENUM_TIMEFRAMES timeframe = StochasticArr[i];
            ENUM_STOCHASTIC_TREND trend = STCTrend(
                     NULL,
                     timeframe
                     );
            if (trend == STOCHASTIC_RISE){
               is_Short   = False;
               tmsg = tmsg + Tf2Str(timeframe) + "+ ";
            }
            if (trend == STOCHASTIC_FALL){
               is_Long    = False;
               tmsg = tmsg + Tf2Str(timeframe) + "- ";
            }
         }
         tmsg = tmsg + "\n";
      }
      // ENUM_MOVINGAVERAGE_TREND
      if (STAT_MOVINGAVERAGE_ENABLE){
         tmsg = tmsg + "MA ";
         for(int i = ArraySize(MovingAverageArr)-1; i >= 0 ; i--){
            ENUM_TIMEFRAMES timeframe = MovingAverageArr[i];
            ENUM_MOVINGAVERAGE_TREND trend = MATrend(
                     NULL,
                     timeframe
                     );
            if (trend == MOVINGAVERAGE_RISE){
               is_Short   = False;
               tmsg = tmsg + Tf2Str(timeframe) + "+ ";
            }
            if (trend == MOVINGAVERAGE_FALL){
               is_Long    = False;
               tmsg = tmsg + Tf2Str(timeframe) + "- ";
            }
         }
         tmsg = tmsg + "\n";
      }
      // Long?
      if       ((is_Long)  && (!is_Short)){
         if ((preOrderStatus == PREORDER_NONE) && (!is_Instant)){
            preOrderPrice  = Ask;
            preOrderStatus = PREORDER_LONG;
         }else if ((preOrderStatus != PREORDER_LONG) && (!is_Instant)){
            preOrderPrice  = 0;
            preOrderStatus = PREORDER_NONE;
         }else if (
               is_Instant
            || Ask >= (preOrderPrice * (1.0 + (((double)PreOrderHysteresispc) / 100.0)))
         ){
            preOrderPrice  = 0;
            preOrderStatus = PREORDER_NONE;
            // Close?
            if    (oDir == DIRECTION_NONE)
               order = PREORDER_LONG;            
            else if (
                  (oDir == DIRECTION_SHORT)
               )
               order = PREORDER_CLOSE;
            thisTrend = TREND_LONG;
         }
      // Short?
      }else if ((!is_Long) && (is_Short)){
         if ((preOrderStatus == PREORDER_NONE) && (!is_Instant)){
            preOrderPrice  = Bid;
            preOrderStatus = PREORDER_SHORT;
         }else if ((preOrderStatus != PREORDER_SHORT) && (!is_Instant)){
            preOrderPrice  = 0;
            preOrderStatus = PREORDER_NONE;
         }else if (
               is_Instant
            || Bid <= (preOrderPrice * (1.0 - (((double)PreOrderHysteresispc) / 100.0)))
         ){
            preOrderPrice  = 0;
            preOrderStatus = PREORDER_NONE;
            // Close?
            if    (oDir == DIRECTION_NONE)
               order = PREORDER_SHORT;            
            else if (
                  (oDir == DIRECTION_LONG)
               )
               order = PREORDER_CLOSE;
            thisTrend = TREND_SHORT;
         }
      }else{
         if ( 
               !(CONFIG_CLOSE_AT_OPPOSITE_TREND)
            && (oDir != DIRECTION_NONE)
         ){
            order = PREORDER_CLOSE;
         }
         thisTrend = TREND_NONE;
      }
      // Order?
      // Trading is enabled
      if (CONFIG_ALGO_ENABLE){
         if       (order == PREORDER_CLOSE){
            order = AlgoClose(
                     oTicket
                     );
            mTicket = 0;
            if (order > 0)
               msg = msg + "Close Order!\n";
         }else if (order == PREORDER_LONG){
            order = AlgoOpen(
                     Symbol(),
                     OP_BUY,
                     tradingQty,
                     thists,
                     Stoplosspt,
                     Stoplosspc,
                     Stopgainpt,
                     Stopgainpc
                     );
            if (order > 0)
               msg = msg + "Long Order!\n";
         }else if (order == PREORDER_SHORT){
            order = AlgoOpen(
                     Symbol(),
                     OP_SELL,
                     tradingQty,
                     thists,
                     Stoplosspt,
                     Stoplosspc,
                     Stopgainpt,
                     Stopgainpc
                     );
            if (order > 0)
               msg = msg + "Short Order!\n";            
         }         
         // Stoploss / Takeprofit
         if (  // valid ticket
               mTicket > 0
         ){
            ENUM_ALGOCLOSE mCloseStatus = getCloseStatus(mTicket);
            if       (mCloseStatus == CLOSE_STOPLOSS){
               msg = msg + STRATEGY_NAME + ": " + "Stoploss!\n";
               mTicket = 0;
            }else if (mCloseStatus == CLOSE_STOPGAIN){
               msg = msg + STRATEGY_NAME + ": " + "Takeprofit\n";
               mTicket = 0;
            }
         }
      }      
      if (thisTrend != prevTrend){
         if       (thisTrend == TREND_NONE){
            msg = msg + "No Trend\n";
         }else if (thisTrend == TREND_SHORT){
            msg = msg + "Falling Trend\n";
         }else if (thisTrend == TREND_LONG){
            msg = msg + "Rising Trend\n";
         }
         msg = msg + tmsg;
      }
      prevTrend = thisTrend;
            
      // send to server
      if (msg != ""){
         msg = STRATEGY_NAME + "(" + Symbol() +"):\n" + msg;
         IOSendMsg(msg);
         Alert(msg);
      }
  }
//+------------------------------------------------------------------+
//|                                                    mSTCLogic.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include  <AlgoClass.mqh>
#include  <mStochastic.mqh>
//+------------------------------------------------------------------+
//| Const                                                            |
//+------------------------------------------------------------------+
#define STCLOGICARRSIZE 3
int StochasticArr[] = {             // Check from Bottom to Top
   PERIOD_M5,
   PERIOD_M15,
   PERIOD_M30,
}; 
enum ENUM_STCARR_INDEX  // enumeration of named constants
{
   STCARR_M5,           // 0
   STCARR_M15,
   STCARR_M30
};
//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Param                                                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Function                                                         |
//+------------------------------------------------------------------+
class STCLOGIC1
{
   string name;
   int arrSize;
   ENUM_STOCHASTIC_TREND prevArr[STCLOGICARRSIZE];
   ENUM_STOCHASTIC_TREND thisArr[STCLOGICARRSIZE];
   ENUM_TREND condTrend;
   ENUM_TREND prevTrend;
   int prevts;
   ENUM_TREND prevSTCTrend;
   ENUM_TREND thisSTCTrend;   
   
   string   logicsymbol;            // symbol
   double   logicvolume;            // volume
   double   logicslpt;              // stoploss point
   double   logicslpc;              // stoploss %
   double   logicsgpt;              // stopgain point
   double   logicsgpc;              // stopgain %
   
   int      logicLimit;
   int      logicToggle;
   int      logicTimeout;
   
   bool is_algo;
   int logicTicket;
   
   public:
   //--- An empty default constructor
   STCLOGIC1(      
      string   symbol,              // symbol
      double   volume,              // volume
      double   slpt,              // stoploss point
      double   slpc,              // stoploss %
      double   sgpt,              // stopgain point
      double   sgpc,               // stopgain %
      int      limit,
      int      timeout
      ) {
      name    = "STCLOGIC1";
      arrSize = STCLOGICARRSIZE;
      for (int i = 0; i < STCLOGICARRSIZE; i++){
         prevArr[i] = STOCHASTIC_NONE;
         thisArr[i] = STOCHASTIC_NONE;
      }
      prevTrend    = TREND_NONE;
      condTrend    = TREND_NONE;
      prevSTCTrend = TREND_NONE;
      thisSTCTrend = TREND_NONE;
      
      logicsymbol = symbol;
      logicvolume = volume;
      logicslpt   = slpt;
      logicslpc   = slpc;
      logicsgpt   = sgpt;
      logicsgpc   = sgpc;
      logicToggle = 0;      
      logicTicket = 0;
      is_algo     = false;
      logicLimit  = limit;
      logicTimeout= timeout;
       
   }
   ~STCLOGIC1() { Print(name + " is ended."); } 
   void setthisArr(ENUM_STOCHASTIC_TREND& iArr[]){
      for(int i=0; i < arrSize; i++)
         thisArr[i] = iArr[i];
   }
   void setthisArr(int i, ENUM_STOCHASTIC_TREND trend){thisArr[i] = trend;}
   ENUM_STOCHASTIC_TREND getprevArr(int i){return prevArr[i];}
   ENUM_STOCHASTIC_TREND getthisArr(int i){return thisArr[i];}
   ENUM_TREND getTrend(){return thisSTCTrend;}
   bool isTrend(){
      if(prevSTCTrend != thisSTCTrend)
         return True;      
      return False;
   }
   
   void setAlgoEn(bool enable){is_algo = enable;}
   bool getAlgoEn(){return is_algo;}
   int getTicket(){return logicTicket;}
   
   string order(
      int thists
   ){
      string msg = "";
      // Order in process
      if (
               (thisSTCTrend == TREND_NONE)
            && (logicTicket > 0)
      ){
         if (is_algo)
            int logicOrder = AlgoClose(
                     logicTicket
                     );
         logicTicket = 0;
         msg = msg + name + " Close Order!";
      }else if (
               (thisSTCTrend != TREND_NONE)
            && (logicTicket == 0)
      ){
         int logicType = OP_BUY;
         if (thisSTCTrend == TREND_SHORT){
            logicType = OP_SELL;
            msg = msg + name + " Short Order!";
         }else{
            msg = msg + name + " Long Order!";
         }        
         if (is_algo)    
            logicTicket = AlgoOpen(
                           logicsymbol,
                           logicType,
                           logicvolume,
                           thists,
                           logicslpt,
                           logicslpc,
                           logicsgpt,
                           logicsgpc
                           );
         else
            logicTicket = thists;   // Fake Ticket
      }
      return msg;
   }
   
   ENUM_TREND execute(ENUM_STOCHASTIC_TREND& iArr[], ENUM_TREND thisTrend, int thists){
      setthisArr(iArr);   
      return execute(
         thisTrend,
         thists
         );
   }
   ENUM_TREND execute(ENUM_TREND thisTrend, int thists){
      prevSTCTrend = thisSTCTrend;
      if (
         thisSTCTrend != thisTrend
      ){
         thisSTCTrend = TREND_NONE;   
      }
      if (     // Success
               logicToggle >= logicLimit
         && (
               condTrend != TREND_NONE
            && thisTrend != TREND_NONE
            && condTrend != thisTrend
               )
      ){    
         string condstr;
         if (condTrend == TREND_NONE)
            condstr = "NONE";
         if (condTrend == TREND_SHORT)
            condstr = "SHORT";
         if (condTrend == TREND_LONG)
            condstr = "LONG";  
         Print("logicToggle: " + condstr + " " + logicToggle);
         thisSTCTrend = thisTrend;
      }
      
      // Toggle Condition
      if(      // Initialize
               (condTrend == TREND_NONE)
               // condition failed
            || (prevArr[STCARR_M5] != thisArr[STCARR_M5])
               // Timeout
            || (thists >= prevts + logicTimeout)
            || (
                  condTrend != TREND_NONE
               && thisTrend != TREND_NONE
               && condTrend != thisTrend
                  )
            ){
         condTrend = TREND_NONE;
         // reset number of toggle
         logicToggle          = 0;
         if (
            thisTrend != TREND_NONE
         ){
            condTrend = thisTrend;
         }
         prevts    = thists;
      // Long / Short Condition Trend + No Trend
      }else if(
               thisTrend != prevTrend
      ){
         if (thisTrend == TREND_NONE){
            logicToggle = logicToggle + 1;
         }
      }
      // update param
      for(int i=0; i < arrSize; i++)
         prevArr[i] = thisArr[i];
      prevTrend = thisTrend;
      
      return thisSTCTrend;
   }
};
//+------------------------------------------------------------------+
//| Function                                                         |
//+------------------------------------------------------------------+
class STCLOGIC2
{
   string name;
   int arrSize;
   ENUM_STOCHASTIC_TREND prevArr[STCLOGICARRSIZE];
   ENUM_STOCHASTIC_TREND thisArr[STCLOGICARRSIZE];
   ENUM_TREND condTrend;
   ENUM_TREND prevTrend;
   int prevts;
   ENUM_TREND prevSTCTrend;
   ENUM_TREND thisSTCTrend;   
   
   string   logicsymbol;            // symbol
   double   logicvolume;            // volume
   double   logicslpt;              // stoploss point
   double   logicslpc;              // stoploss %
   double   logicsgpt;              // stopgain point
   double   logicsgpc;              // stopgain %
   
   int      logicLimit;
   int      logicToggle;
   int      logicTimeout;
   
   bool is_algo;
   int logicTicket;
   
   public:
   //--- An empty default constructor
   STCLOGIC2(      
      string   symbol,              // symbol
      double   volume,              // volume
      double   slpt,              // stoploss point
      double   slpc,              // stoploss %
      double   sgpt,              // stopgain point
      double   sgpc,               // stopgain %
      int      limit,
      int      timeout
      ) {
      name    = "STCLOGIC2";
      arrSize = STCLOGICARRSIZE;
      for (int i = 0; i < STCLOGICARRSIZE; i++){
         prevArr[i] = STOCHASTIC_NONE;
         thisArr[i] = STOCHASTIC_NONE;
      }
      prevTrend    = TREND_NONE;
      condTrend    = TREND_NONE;
      prevSTCTrend = TREND_NONE;
      thisSTCTrend = TREND_NONE;
      
      logicsymbol = symbol;
      logicvolume = volume;
      logicslpt   = slpt;
      logicslpc   = slpc;
      logicsgpt   = sgpt;
      logicsgpc   = sgpc;
      logicToggle = 0;      
      logicTicket = 0;
      is_algo     = false;
      logicLimit  = limit;
      logicTimeout= timeout;
       
   }
   ~STCLOGIC2() { Print(name + " is ended."); } 
   void setthisArr(ENUM_STOCHASTIC_TREND& iArr[]){
      for(int i=0; i < arrSize; i++)
         thisArr[i] = iArr[i];
   }
   void setthisArr(int i, ENUM_STOCHASTIC_TREND trend){thisArr[i] = trend;}
   ENUM_STOCHASTIC_TREND getprevArr(int i){return prevArr[i];}
   ENUM_STOCHASTIC_TREND getthisArr(int i){return thisArr[i];}
   ENUM_TREND getTrend(){return thisSTCTrend;}
   bool isTrend(){
      if(prevSTCTrend != thisSTCTrend)
         return True;      
      return False;
   }
   
   void setAlgoEn(bool enable){is_algo = enable;}
   bool getAlgoEn(){return is_algo;}
   int getTicket(){return logicTicket;}
   
   string order(
      int thists
   ){
      string msg = "";
      // Order in process
      if (
               (thisSTCTrend == TREND_NONE)
            && (logicTicket > 0)
      ){
         if (is_algo)
            int logicOrder = AlgoClose(
                     logicTicket
                     );
         logicTicket = 0;
         msg = msg + name + " Close Order!";
      }else if (
               (thisSTCTrend != TREND_NONE)
            && (logicTicket == 0)
      ){
         int logicType = OP_BUY;
         if (thisSTCTrend == TREND_SHORT){
            logicType = OP_SELL;
            msg = msg + name + " Short Order!";
         }else{
            msg = msg + name + " Long Order!";
         }        
         if (is_algo)    
            logicTicket = AlgoOpen(
                           logicsymbol,
                           logicType,
                           logicvolume,
                           thists,
                           logicslpt,
                           logicslpc,
                           logicsgpt,
                           logicsgpc
                           );
         else
            logicTicket = thists;   // Fake Ticket
      }
      return msg;
   }
   
   ENUM_TREND execute(ENUM_STOCHASTIC_TREND& iArr[], ENUM_TREND thisTrend, int thists){
      setthisArr(iArr);   
      return execute(
         thisTrend,
         thists
         );
   }
   ENUM_TREND execute(ENUM_TREND thisTrend, int thists){     
      // update STC Trend
      prevSTCTrend = thisSTCTrend;
      if (
         thisSTCTrend != thisTrend
      && thisTrend    != TREND_NONE
      ){
         thisSTCTrend = TREND_NONE;   
      }
      // Toggle Condition
      if(      // Initialize
               (condTrend == TREND_NONE)
               // condition failed
            || (
                     ((ENUM_STOCHASTIC_TREND)condTrend != thisArr[STCARR_M5])
                  && (thisArr[STCARR_M5] != STOCHASTIC_NONE)
                  )
               // Timeout
            || (thists >= prevts + logicTimeout)
            || (
                  condTrend != TREND_NONE
               && thisTrend != TREND_NONE
               && condTrend != thisTrend
                  )
            ){
         condTrend = TREND_NONE;
         // reset number of toggle
         logicToggle          = 0;
         if (
            thisTrend != TREND_NONE
         ){
            condTrend = thisTrend;
         }
         prevts    = thists;
      // Long / Short Condition Trend + No Trend
      }else if(
               thisTrend != prevTrend
      ){
         if (thisTrend == TREND_NONE){
            logicToggle = logicToggle + 1;
         }         
         if (     // Success
                  logicToggle >= logicLimit
            && (
                  condTrend != TREND_NONE
               && thisTrend == TREND_NONE
                  )
            &&    logicTicket == 0
         ){    
            string condstr;
            if (condTrend == TREND_NONE)
               condstr = "NONE";
            if (condTrend == TREND_SHORT)
               condstr = "SHORT";
            if (condTrend == TREND_LONG)
               condstr = "LONG";  
            thisSTCTrend = condTrend;
            Print("logicToggle: " + condstr + " " + logicToggle + " " + thisSTCTrend);
         } 
      }
      
      // update param
      for(int i=0; i < arrSize; i++)
         prevArr[i] = thisArr[i];
      prevTrend = thisTrend;
      
      return thisSTCTrend;
   }
};
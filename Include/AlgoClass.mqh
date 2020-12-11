//+------------------------------------------------------------------+
//|                                                    AlgoClass.mqh |
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
//| Include                                                          |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Const                                                            |
//+------------------------------------------------------------------+
#define slippage   3
enum ENUM_DIRECTION        // enumeration of named constants
{
   DIRECTION_NONE,        // 0
   DIRECTION_SHORT,
   DIRECTION_LONG
};
enum ENUM_ALGOPREORDER     // enumeration of named constants
{
   PREORDER_NONE,          // 0
   PREORDER_SHORT,
   PREORDER_LONG,
   PREORDER_CLOSE
};
enum ENUM_TREND            // enumeration of named constants
{
   TREND_NONE,             // 0
   TREND_SHORT,
   TREND_LONG
};
enum ENUM_ALGOCLOSE        // enumeration of named constants
{
   CLOSE_NONE,             // 0
   CLOSE_STOPLOSS,
   CLOSE_STOPGAIN,
   CLOSE_NORMAL
};
enum ENUM_ALGO_HOURMODE   // enumeration of named constants
{
   ALGO_HOURMODE_OFF,        // 0
   ALGO_HOURMODE_ON,
   ALGO_HOURMODE_CLOSE_ONLY
};
//+------------------------------------------------------------------+
//| Param                                                            |
//+------------------------------------------------------------------+
bool               ALGO_ENABLE   = false;
ENUM_ALGO_HOURMODE ALGO_HOURMODE = ALGO_HOURMODE_OFF;
int                ALGO_SHOUR    = 0;
int                ALGO_EHOUR    = 0;
//+------------------------------------------------------------------+
//| General Function                                                 |
//+------------------------------------------------------------------+
int getTimestamp(
)
{
   string unixTimestamp = (TimeCurrent()-0);
   int trk=StrToInteger(unixTimestamp);
   return trk;
}
int getTimestampbyDatetime(
   datetime idt
)
{
   string unixTimestamp = (idt-0);
   int trk=StrToInteger(unixTimestamp);
   return trk;
}
string Tf2Str(
   ENUM_TIMEFRAMES timeframe
){
   if      (timeframe == 1)
      return "M1";
   else if (timeframe == 2)
      return "M2";
   else if (timeframe == 3)
      return "M3";
   else if (timeframe == 4)
      return "M4";
   else if (timeframe == 5)
      return "M5";
   else if (timeframe == 6)
      return "M6";
   else if (timeframe == 10)
      return "M10";
   else if (timeframe == 12)
      return "M12";
   else if (timeframe == 15)
      return "M15";
   else if (timeframe == 20)
      return "M20";
   else if (timeframe == 30)
      return "M30";
   else if (timeframe == 60)
      return "H1";
   else if (timeframe == 120)
      return "H2";
   else if (timeframe == 180)
      return "H3";
   else if (timeframe == 240)
      return "H4";
   else if (timeframe == 360)
      return "H6";
   else if (timeframe == 480)
      return "H8";
   else if (timeframe == 720)
      return "H12";
   else if (timeframe == 1440)
      return "D1";
   else if (timeframe == 10080)
      return "W1";
   else if (timeframe == 43200)
      return "MN1";
   return "NULL";
}
// MT4 doesn't interrupt on SL/TP
ENUM_ALGOCLOSE getCloseStatus(
   int ticket
){
   if (
         OrderSelect(ticket, SELECT_BY_TICKET)
      ){
      int closets = getTimestampbyDatetime(OrderCloseTime());
      if (closets > 0){
         ENUM_DIRECTION oDir = OrderTypeToDirection(OrderType());
         double close = OrderClosePrice();
         double sl    = OrderStopLoss();
         double sg    = OrderTakeProfit();
         if       (oDir == DIRECTION_SHORT)
            if ((sl > 0) && (close >= sl))
               return CLOSE_STOPLOSS;
            if ((sg > 0) && (close <= sg))
               return CLOSE_STOPGAIN;
         else if (oDir == DIRECTION_LONG)
            if ((sl > 0) && (close <= sl))
               return CLOSE_STOPLOSS;
            if ((sg > 0) && (close >= sg))
               return CLOSE_STOPGAIN;
      }
   }
   return CLOSE_NONE;
}

ENUM_DIRECTION OrderTypeToDirection(
   int order_type
){
   if ((order_type < 0) || (order_type > 5)){
      return DIRECTION_NONE;
   }else if ((order_type % 2) == 1){
      return DIRECTION_SHORT;
   }
   return DIRECTION_LONG;
}

// check if HOURMODE is active
bool ALGO_HOURMODE_ISACTIVE(
){
   int localHr = TimeHour(TimeLocal());
   if (ALGO_HOURMODE == ALGO_HOURMODE_OFF)
      return False;
   if (  // Start Hour < End Hour
         ALGO_SHOUR < ALGO_EHOUR
   ){
      if (  // Start Hour <= Hour < End Hour
            localHr >= ALGO_SHOUR
         && localHr <  ALGO_EHOUR
      ){
         return True;
      }
   }else if(// End Hour < Start Hour
         ALGO_SHOUR > ALGO_EHOUR
   ){
      if (  // Start Hour >= Hour
            localHr >= ALGO_SHOUR
            // Hour < End Hour
         || localHr <  ALGO_EHOUR
      ){
         return True;
      }   
   }
   // End Hour = Start Hour?
   return False;
}

int AlgoClose(
   int ticketId         //
   )
{
   // Disabled
   if (!ALGO_ENABLE)
      return 0;
   // HOURMODE
   if (  // HOURMODE within range?
         ALGO_HOURMODE_ISACTIVE()
         // CLOSE not restricted by HOURMODE
      && ALGO_HOURMODE != ALGO_HOURMODE_CLOSE_ONLY
      )
      return 0;
   int      mOrder;
   double   cPrice;
   if (
         OrderSelect(ticketId, SELECT_BY_TICKET)
         ){
      mOrder = OrderClose(
               OrderTicket(),
               OrderLots(),
               //cPrice,
               OrderClosePrice(),
               slippage,
               White
               );
   }
   return mOrder;
}

//OP_BUY         0 Buy operation
//OP_SELL        1 Sell operation
//OP_BUYLIMIT    2 Buy limit pending order
//OP_SELLLIMIT   3 Sell limit pending order
//OP_BUYSTOP     4 Buy stop pending order
//OP_SELLSTOP    5 Sell stop pending order
int AlgoOpen(
   string   symbol,              // symbol
   int      cmd,                 // operation
   double   volume,              // volume
   //double   price,               // price
   //int      slippage,            // slippage
   //double   stoploss,            // stop loss
   //double   takeprofit,          // take profit
   //string   comment=NULL,        // comment
   int      magic=0,             // magic number
   //datetime expiration=0,        // pending order expiration
   //color    arrow_color=clrNONE  // color
   
   double   slpt=0,              // stoploss point
   double   slpc=0,              // stoploss %
   double   sgpt=0,              // stopgain point
   double   sgpc=0               // stopgain %
   )
{
   // Disabled
   if (!ALGO_ENABLE)
      return 0;
   // HOURMODE
   if (  // HOURMODE within range?
         ALGO_HOURMODE_ISACTIVE()
      )
      return 0;
   int      mOrder;
   double   oPrice;
   color    oColor;
//   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
//   Print("Minimum Stop Level=",minstoplevel," points");
//   double price=Ask;
//   double stoploss=NormalizeDouble(Bid-minstoplevel*Point,Digits);
//   double takeprofit=NormalizeDouble(Bid+minstoplevel*Point,Digits);
   double stoploss = NULL;
   double stopgain = NULL;
   if (  // SELL
         cmd % 2 > 0
      ){
      oPrice   = Bid;
      oColor   = Red;
      if      (slpt > 0)
         stoploss = Bid + slpt;
      else if (slpc > 0)
         stoploss = Bid * (1.0 + slpc / 100.0);
      if      (sgpt > 0)
         stoploss = Bid - sgpt;
      else if (sgpc > 0)
         stopgain = Bid * (1.0 - sgpc / 100.0);
   } else {
      oPrice   = Ask;
      oColor   = Blue;
      if      (slpt > 0)
         stoploss = Ask - slpt;
      else if (slpc > 0)
         stoploss = Ask * (1.0 - slpc / 100.0);
      if      (sgpt > 0)
         stopgain = Ask + sgpt;
      else if (sgpc > 0)
         stopgain = Ask * (1.0 + sgpc / 100.0);
   }
   //Alert("stoploss " + stoploss + " stopgain " + stopgain);
   //if (slpc == 0)
   //   stoploss = NULL;
   //if (sgpc == 0)
   //   stopgain = NULL;
   mOrder = OrderSend(
            symbol,
            cmd,
            volume,
            oPrice,
            slippage,
            stoploss,
            stopgain,
            NULL,
            magic,
            0,
            oColor
            );
   return mOrder;
}
void alertPos(){
   for(int pos = OrdersTotal()-1; pos >= 0 ; pos--){
      bool oSelect = OrderSelect(pos, SELECT_BY_POS);
      if (oSelect){
         int oType = OrderType();      // 0: Done/None
         string oSym = OrderSymbol();
         Alert(
            OrderTicket() + " " + 
            oSym + " " +
            oSelect + " " +
            "OrderType: " + OrderType() + " " +
            OrderOpenPrice() + "@" + OrderOpenTime() + " " +
            OrderClosePrice() + "@" + OrderCloseTime() + " " +
            ""       
         );
      }
   }
}

// return 1st pending order Ticket ID
int pOrderTicket(){
   for(int pos = OrdersTotal()-1; pos >= 0 ; pos--){
      bool oSelect = OrderSelect(pos, SELECT_BY_POS);
      if (oSelect > 0){
         Alert(
            OrderTicket() + " " + 
            OrderSymbol() + "@" + OrderLots() + " " + 
            oSelect + " " +
            "OrderType: " + OrderType() + " " +
            OrderOpenPrice() + "@" + OrderOpenTime() + " " +
            //OrderClosePrice() + "@" + OrderCloseTime() + " " +
            ""       
         );
         return OrderTicket();
      }
   }
   return 0;
}
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnAlgoInit(
   bool               enable,
   ENUM_ALGO_HOURMODE hrMode  = ALGO_HOURMODE_OFF,
   int                sHour   = 0,
   int                eHour   = 0
)
  {
//---   
   ALGO_ENABLE = enable;
   // Disabled
   if (!ALGO_ENABLE)
      return 0;      
   ALGO_HOURMODE = hrMode;
   ALGO_SHOUR    = sHour;
   ALGO_EHOUR    = eHour;
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnAlgoDeinit(const int reason)
  {
//---
   
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnAlgoTimer()
{
   ////Print("--------Timer-----------") ;
   ////Alert("TimeCurrent=",TimeToStr(TimeCurrent(),TIME_SECONDS),
   ////      " Time[0]=",TimeToStr(Time[0],TIME_SECONDS));
   //int mOrder;
   //for(int pos = OrdersTotal()-1; pos >= 0 ; pos--){
   //   bool oSelect = OrderSelect(pos, SELECT_BY_POS);
   //   if (oSelect > 0){
   //      // Close Order
   //      mOrder = AlgoClose(
   //               OrderTicket()                  
   //               );
   //      Alert(
   //         OrderTicket() + " " + "Closing" + " " + OrderLots()
   //         );
   //   }
   //}
   //int m=TimeSeconds(TimeCurrent());
//   //Alert(m);
//   for(int pos=0; pos < OrdersHistoryTotal(); pos++){
//      int closets = getTimestampbyDatetime(OrderCloseTime());
//      int opents  = getTimestampbyDatetime(OrderOpenTime());
//      Alert(
//         OrderType() + 
//         "C:" + closets + 
//         " M:" + OrderMagicNumber() + 
//         " SL:" + OrderStopLoss() + 
//         " TP:" + OrderTakeProfit()
//         );
//      break;
////      if (
////            OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY)   // Only orders w/
////         && OrderCloseTime()    > lastClose                 // not yet processed,
////         && OrderMagicNumber()  == magic.number             // my magic number
////         
////         && OrderSymbol()       == Symbol()                 // and my pair.
////         && OrderType()         <= OP_SELL
////      ){// Avoid cr/bal https://www.mql5.com/en/forum/126192
////        lastClose    = OrderCloseTime();
////        double DIR   = Direction( OrderType() ),
////               delta = OrderClosePrice() - OrderOpenPrice();
////        bool   HitTP = delta*DIR > 0; // HitSL = !HitTP
////      }
//   }
}
//+------------------------------------------------------------------+

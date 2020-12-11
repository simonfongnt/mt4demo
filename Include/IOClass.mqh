//+------------------------------------------------------------------+
//|                                                      IOClass.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include  <socket.mqh>
//+------------------------------------------------------------------+
//| Const                                                            |
//+------------------------------------------------------------------+
#define IOPort    12345
//+------------------------------------------------------------------+
//| Param                                                            |
//+------------------------------------------------------------------+
bool CLASS_IO_ENABLE = false;
ClientSocket * mClientSocket = NULL;
ServerSocket * mServerSocket;
//ServerSocket = new ServerSocket(12345, true);
//+------------------------------------------------------------------+
//| General Function                                                 |
//+------------------------------------------------------------------+
void IOInitSocket()
{  
   // Disabled
   if (!CLASS_IO_ENABLE)
      return;
   // Create a socket if none already exists
   if (!mClientSocket) {
      mClientSocket = new ClientSocket(IOPort);
   }
}
void IOReinitSocket()
{  
   // Disabled
   if (!CLASS_IO_ENABLE)
      return;
   // Create a socket if none already exists
   delete mClientSocket;
   mClientSocket = new ClientSocket(IOPort);
}
bool IOSendMsg(
   string msg
)
{
   // Disabled
   if (!CLASS_IO_ENABLE)
      return false;
   // Socket is okay. Do some action such as sending or receiving
   if (!mClientSocket.Send(msg)) {
      // Send failed. Socket is presumably dead, and
      // .IsSocketConnected() will now return false
      // Socket may already have been dead, or now detected as failed
      // following the attempt above at sending or receiving.
      if (!mClientSocket.IsSocketConnected()) {
         IOReinitSocket();
      }
      return false;
   }
   return true;
}
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnIOInit(
   bool enable
)
  {
//---
   CLASS_IO_ENABLE = enable;
   // Disabled
   if (!CLASS_IO_ENABLE)
      return 0;
   IOInitSocket();   
   
   //mServerSocket = new ServerSocket(12345, true);
   //if (!mServerSocket.Created()) {
   //   // Almost certainly because port 12345 is already in use
   //}
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnIODeinit(const int reason)
  {
//---
   // Disabled
   if (!CLASS_IO_ENABLE)
      return;
   //if (mServerSocket) delete mServerSocket;
   
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnIOTimer()
{
   // Disabled
   if (!CLASS_IO_ENABLE)
      return;
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
   
   
//   string strMessage = mClientSocket.Receive();
//   if (strMessage != "") {
//      // Process the message
//      Alert(
//         "Received: " + strMessage
//         );
//   }
//   
   if (!mClientSocket.IsSocketConnected()) {
      IOReinitSocket();
   }
}
//+------------------------------------------------------------------+

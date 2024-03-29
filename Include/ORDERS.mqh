struct PRICE{    // 
   PICS Sig1,Sig2;      // вложенная структура предварительных сигналов и сигналов подтверждения
   datetime T, Exp;    // последнее время обновления зоны
   char Sig;         // отслеживаемый паттерн
   float Mem, Val,Stp,Prf,Max,Min;  // 
   }; 
PRICE setSEL, setBUY, SEL, BUY, memSEL, memBUY;
float BUYSTP, SELSTP, BUYLIM, SELLIM;

void ORDERS_SET(){
   SET_BUY();
   SET_SEL();
   }
void SET_BUY(){
   if (setBUY.Val<=0) return;
   int ticket;   double TradeRisk=0;  string str;
   char repeat=3; // три попытки у тебя  
   if (MathAbs(setBUY.Val-ASK)<=StopLevel) setBUY.Val=ASK;  
   if (setBUY.Val-setBUY.Stp <= StopLevel)                  {X("Stop="  +S4(setBUY.Stp)+" too close to setBUY="+S4(setBUY.Val), setBUY.Val, bar, clrRed); repeat=0;}  // слишком близкий/неправильный стоп
   if (setBUY.Prf-setBUY.Val <= StopLevel && setBUY.Prf>0)  {X("Profit="+S4(setBUY.Prf)+" too close to setBUY="+S4(setBUY.Val), setBUY.Val, bar, clrRed); repeat=0;}  // слишком близкий/неправильный тейк
   WAITING("Terminal",20); // ждем 20сек освобождения терминала
   while (repeat>0 && BUY.Val==0 && BUYSTP==0 && BUYLIM==0){ 
      if (Real){
         MARKET_UPDATE(SYMBOL);
         //Print("ORDERS_SET(): setBUY.Val=",S4(setBUY.Val),"/",S4(setBUY.Stp),"/",S4(setBUY.Prf)," Lot=",Lot," Magic=",Magic," Expiration=",Expiration," ASK/BID=",S4(ASK),"/",S4(BID));
         //Lot=MM(setBUY.Val-setBUY.Stp,risk,SYMBOL); if (Lot<0) {REPORT("Lot<0"); break;} 
         TradeRisk=CHECK_RISK(Lot, setBUY.Val-setBUY.Stp, SYMBOL); 
         if (TradeRisk>MaxRisk) {REPORT("CHECK_RISK="+S2(TradeRisk)+"% too BIG!!! Lot="+S2(Lot)+" Balance="+S0(AccountBalance())+" Stop="+S4(setBUY.Val-setBUY.Stp)+" SYMBOL="+SYMBOL); break;}
         }
      if (setBUY.Val-ASK>StopLevel)  {str="Set BuyStp ";   ticket=OrderSend(SYMBOL,OP_BUYSTOP, NormalizeDouble(Lot,LotDigits), N5(setBUY.Val), 3, N5(setBUY.Stp), N5(setBUY.Prf), ID, Magic,setBUY.Exp, CornflowerBlue);}   else
      if (ASK-setBUY.Val>StopLevel)  {str="Set BuyLim ";   ticket=OrderSend(SYMBOL,OP_BUYLIMIT,NormalizeDouble(Lot,LotDigits), N5(setBUY.Val), 3, N5(setBUY.Stp), N5(setBUY.Prf), ID, Magic,setBUY.Exp, CornflowerBlue);}   else
                   {setBUY.Val=ASK;   str="Set setBUY ";   ticket=OrderSend(SYMBOL,OP_BUY,     NormalizeDouble(Lot,LotDigits), N5(setBUY.Val), 3, N5(setBUY.Stp), N5(setBUY.Prf), ID, Magic,    0     , CornflowerBlue);}
      REPORT(str+S4(setBUY.Val)+"/"+S4(setBUY.Stp)+"/"+S4(setBUY.Prf)+"/"+S2(Lot)+"x"+S1(TradeRisk)+"%");
      ORDER_CHECK();
      if (ticket>0) break; // Ордеру назначен номер тикета. В случае неудачи ticket=-1   
      if (ERROR_CHECK(__FUNCTION__)) repeat--; else repeat=0; // ERROR_CHECK() возвращает необходимость повтора торговой операции
      }
   FREE("Terminal");   
   }  
void SET_SEL(){   
   if (setSEL.Val<=0) return; 
   int ticket;   double TradeRisk=0;  string str;
   char repeat=3; // три попытки у тебя  
   if (MathAbs(BID-setSEL.Val)<=StopLevel) setSEL.Val=BID;
   if (setSEL.Stp-setSEL.Val <= StopLevel) {X("Stop="  +S4(setSEL.Stp)+" too close to setSEL="+S4(setSEL.Val), setSEL.Val, bar, clrRed); repeat=0;}  // слишком близкий/неправильный стоп
   if (setSEL.Val-setSEL.Prf <= StopLevel) {X("Profit="+S4(setSEL.Prf)+" too close to setSEL="+S4(setSEL.Val), setSEL.Val, bar, clrRed); repeat=0;}  // слишком близкий/неправильный тейк
   WAITING("Terminal",20); // ждем 20сек освобождения терминала
   while (repeat>0 &&  SEL.Val==0 && SELSTP==0 && SELLIM==0){
      if (Real){
         MARKET_UPDATE(SYMBOL);
         //Print("ORDERS_SET(): setSEL.Val=",S4(setSEL.Val),"/",S4(setSEL.Stp),"/",S4(setSEL.Prf)," Lot=",Lot," Magic=",Magic," Expiration=",Expiration," ASK/BID=",S4(ASK),"/",S4(BID));
         //Lot=MM(setSEL.Stp-setSEL.Val,risk,SYMBOL); if (Lot<0) {REPORT("Lot<0"); break;} 
         TradeRisk=CHECK_RISK(Lot, setSEL.Stp-setSEL.Val, SYMBOL);
         if (TradeRisk>MaxRisk) {REPORT("CHECK_RISK="+S2(TradeRisk)+"% too BIG!!! Lot="+S2(Lot)+" Balance="+S0(AccountBalance())+" Stop="+S4(setSEL.Stp-setSEL.Val)+" SYMBOL="+SYMBOL); break;}
         }
      if (BID-setSEL.Val>StopLevel) {str="Set SellStp ";   ticket=OrderSend(SYMBOL,OP_SELLSTOP, NormalizeDouble(Lot,LotDigits), N5(setSEL.Val), 3, N5(setSEL.Stp), N5(setSEL.Prf), ID, Magic,setSEL.Exp, Tomato);}   else
      if (setSEL.Val-BID>StopLevel) {str="Set SellLim ";   ticket=OrderSend(SYMBOL,OP_SELLLIMIT,NormalizeDouble(Lot,LotDigits), N5(setSEL.Val), 3, N5(setSEL.Stp), N5(setSEL.Prf), ID, Magic,setSEL.Exp, Tomato);}   else
                   {setSEL.Val=BID;  str="Set Sell ";      ticket=OrderSend(SYMBOL,OP_SELL,     NormalizeDouble(Lot,LotDigits), N5(setSEL.Val), 3, N5(setSEL.Stp), N5(setSEL.Prf), ID, Magic,      0   , Tomato);}
      REPORT(str+S4(setSEL.Val)+"/"+S4(setSEL.Stp)+"/"+S4(setSEL.Prf)+"/"+S2(Lot)+"x"+S1(TradeRisk)+"%");
      ORDER_CHECK();
      if (ticket>0) break;  // Ордеру назначен номер тикета. В случае неудачи ticket=-1   
      if (ERROR_CHECK(__FUNCTION__)) repeat--; else repeat=0; // ERROR_CHECK() возвращает необходимость повтора торговой операции
      }
   FREE("Terminal");  
   }  
   
     
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void MODIFY(){   // Похерим необходимые стоп/лимит ордера: удаление если setBUY/Sell=0       
   bool ReSelect=true;      // если похерили какой-то ордер, надо повторить перебор сначала, т.к. OrdersTotal изменилось, т.е. они все перенумеровались 
   WAITING("Terminal",20);
   while (ReSelect){        // и переменная ReSelect вызовет их повторный перебор        
      ReSelect=false; int Orders=OrdersTotal();
      for(int Ord=0; Ord<Orders; Ord++){ 
         if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)!=true || OrderMagicNumber()!=Magic) continue;
         int Order=OrderType();
         bool make=true;  
         uchar repeat=3;  
         while (repeat){// повторяем операции над ордером, пока не более 3 раз
            MARKET_UPDATE(OrderSymbol());
            switch(Order){
               case OP_SELL:        //  C LO O S E     S E LO LO  
                  if (SEL.Val==0){
                     make=OrderClose(OrderTicket(),OrderLots(),ASK,3,Tomato); 
                     REPORT("Close SELL/"+S4(OrderOpenPrice())); 
                     break;
                     }               //  M O D I F Y     S E LO LO  
                  if (!EQUAL(SEL.Stp,OrderStopLoss()) && SEL.Stp-ASK>StopLevel){    //Print("SEL.Stp=",SEL.Stp," OrderStop=",OrderStopLoss());
                     make=OrderModify(OrderTicket(), OrderOpenPrice(), SEL.Stp, OrderTakeProfit(),OrderExpiration(),Tomato);   REPORT("ModifySellStop/"+S4(SEL.Stp));}
                  if (!EQUAL(SEL.Prf,OrderTakeProfit()) && ASK-SEL.Prf>StopLevel){  //Print("SEL.Prf=",SEL.Prf," OrderTakeProfit=",OrderTakeProfit());
                     make=OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), SEL.Prf,OrderExpiration(),Tomato);   REPORT("ModifySellProfit/"+S4(SEL.Prf));}
                  break; 
               case OP_SELLSTOP:    //  D E LO   S E LO LO S T O P  //
                  if (SELSTP==0){ 
                     if (BID-OrderOpenPrice()>StopLevel){   make=OrderDelete(OrderTicket(),Tomato);                              REPORT("Del SellStop/"+S4(OrderOpenPrice()));}
                     else                                                                                                        REPORT("Can't Del SELLSTOP near market! BID="+S5(BID)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}
                  break;
               case OP_SELLLIMIT:   //  D E LO   S E LO LO LO I M I T  //
                  if (SELLIM==0){
                     if (OrderOpenPrice()-BID>StopLevel){   make=OrderDelete(OrderTicket(),Tomato);                              REPORT("Del SellLimit/"+S4(OrderOpenPrice()));}
                     else                                                                                                        REPORT("Can't Del SELLLIMIT! near market, BID="+S5(BID)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}   
                  break;
               case OP_BUY:   //  C LO O S E    B U Y  //////////////////////////////////////////////////////////////
                  if (BUY.Val==0){
                     make=OrderClose(OrderTicket(),OrderLots(),BID,3,CornflowerBlue); 
                     REPORT("Close BUY/"+S4(OrderOpenPrice()));  
                     break;
                     }        // M O D I F Y      B U Y
                  if (!EQUAL(BUY.Stp,OrderStopLoss()) && BID-BUY.Stp>StopLevel){    //Print("BUY.Stp=",BUY.Stp," OrderStop=",OrderStopLoss());
                     make=OrderModify(OrderTicket(), OrderOpenPrice(), BUY.Stp, OrderTakeProfit(),OrderExpiration(),CornflowerBlue);   REPORT("ModifyBuyStop/"+S4(BUY.Stp));} 
                  if (!EQUAL(BUY.Prf,OrderTakeProfit()) && BUY.Prf-BID>StopLevel){  //Print("BUY.Prf=",BUY.Prf," OrderTakeProfit=",OrderTakeProfit());
                     make=OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), BUY.Prf,OrderExpiration(),CornflowerBlue);   REPORT("ModifyBuyProfit/"+S4(BUY.Prf));}
                  break; 
               case OP_BUYSTOP:  //  D E LO  B U Y S T O P  //
                  if (BUYSTP==0){
                     if (OrderOpenPrice()-ASK>StopLevel){   make=OrderDelete(OrderTicket(),CornflowerBlue);                      REPORT("Del BuyStop/"+S4(OrderOpenPrice()));}
                     else                                                                                                        REPORT("Can't Del BUYSTOP near market! ASK="+S5(ASK)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}
                  break; 
               case OP_BUYLIMIT: //  D E LO  B U Y LO I M I T  //
                  if (BUYLIM==0){
                     if (ASK-OrderOpenPrice()>StopLevel){   make=OrderDelete(OrderTicket(),CornflowerBlue);                      REPORT("Del BuyLimit/"+S4(OrderOpenPrice()));}
                     else                                                                                                        REPORT("Can't Del BUYLIMIT near market! ASK="+S5(ASK)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}
                  break;
               }// switch(Order)  
            if (make) break; //  true при успешном завершении, или false в случае ошибки  
            if (ERROR_CHECK("Modify "+ORD2STR(Order)+" Ticket="+S0(OrderTicket())+" repeat="+S0(repeat))) repeat--; else repeat=0; // ERROR_CHECK() возвращает необходимость повтора торговой операции            
            }  //while(repeat)  
         if (Orders!=OrdersTotal()) {ReSelect=true; break;} // при ошибках или изменении кол-ва ордеров надо заново перебирать ордера (выходим из цикла "for"), т.к. номера ордеров поменялись
         }// for(Ord=0; Ord<Orders; Ord++){    
      }// while(ReSelect)     
   ORDER_CHECK();
   FREE("Terminal");
   }  
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool EQUAL(double One, double Two){// совпадение значений с точностью до 10 тиков
   if (MathAbs(One-Two)<MarketInfo(SYMBOL,MODE_POINT)) return true; else return false;
   }     
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void MARKET_UPDATE(string SYM){ // ASK, BID, DIGITS, Spred, StopLevel
   RefreshRates(); 
   SYMBOL   =SYM;
   ASK      =float(MarketInfo(SYM,MODE_ASK)); 
   BID      =float(MarketInfo(SYM,MODE_BID));    // в функции GLOBAL_ORDERS_SET() ордера ставятся с одного графика на разные пары, поэтому надо знать данные пары выставляемого ордера     
   DIGITS   =short(MarketInfo(SYM,MODE_DIGITS)); // поэтому надо знать данные пары выставляемого ордера
   Spred    =float(MarketInfo(SYM,MODE_SPREAD) * MarketInfo(SYM,MODE_POINT));
   StopLevel=float((MarketInfo(SYM,MODE_STOPLEVEL) + MarketInfo(SYM,MODE_SPREAD)) * MarketInfo(SYM,MODE_POINT));  // Спред необходимо учитывать, т.к. вход и выход из позы происходят по разным ценам (ask/bid)
   }      
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void ORDER_CHECK(){   // ПАРАМЕТРЫ ОТКРЫТЫХ И ОТЛОЖЕННЫХ ПОЗ
   BUY.Val=0; BUYSTP=0; BUYLIM=0; SEL.Val=0; SELSTP=0; SELLIM=0;  BUY.Stp=0; BUY.Prf=0; SEL.Stp=0; SEL.Prf=0;
   for (int i=0; i<OrdersTotal(); i++){ 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)!=true || OrderMagicNumber()!=Magic) continue;
      if (OrderType()==6) continue; // ролловеры не записываем
      switch(OrderType()){
         case OP_BUYSTOP:  BUYSTP=float(OrderOpenPrice());   BUY.Stp=float(OrderStopLoss());   BUY.Prf=float(OrderTakeProfit());    BUY.T=OrderOpenTime();    break;
         case OP_BUYLIMIT: BUYLIM=float(OrderOpenPrice());   BUY.Stp=float(OrderStopLoss());   BUY.Prf=float(OrderTakeProfit());    BUY.T=OrderOpenTime();    break;
         case OP_BUY:      BUY.Val=float(OrderOpenPrice());  BUY.Stp=float(OrderStopLoss());   BUY.Prf=float(OrderTakeProfit());    BUY.T=OrderOpenTime();    break;
         case OP_SELLSTOP: SELSTP=float(OrderOpenPrice());   SEL.Stp=float(OrderStopLoss());   SEL.Prf=float(OrderTakeProfit());    SEL.T=OrderOpenTime();   break;
         case OP_SELLLIMIT:SELLIM=float(OrderOpenPrice());   SEL.Stp=float(OrderStopLoss());   SEL.Prf=float(OrderTakeProfit());    SEL.T=OrderOpenTime();   break;
         case OP_SELL:     SEL.Val=float(OrderOpenPrice());  SEL.Stp=float(OrderStopLoss());   SEL.Prf=float(OrderTakeProfit());    SEL.T=OrderOpenTime();   break;
   }  }  }  // в этой функции нельзя вызывать ERROR_CHECK(), т.к. она сама вызывается в ERROR_CHECK и при возникновении повторной ошибки происходит переполнение стека
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void ORDERS_COLLECT(){// Запишем ордера для выставления в массив. 
   if (setBUY.Val>0){ // запланировано открытие лонга
      GlobalVariableSet(S0(Magic)+"setBUY.Val",    setBUY.Val);
      GlobalVariableSet(S0(Magic)+"setBUY.Stp",    setBUY.Stp);
      GlobalVariableSet(S0(Magic)+"setBUY.Prf",    setBUY.Prf);
      GlobalVariableSet(S0(Magic)+"BuyExpiration", setBUY.Exp);
      Print(Magic,": ORDERS_COLLECT: setBUY=",S4(setBUY.Val),"/",S4(setBUY.Stp),"/",S4(setBUY.Prf)," Expir=",DTIME(setBUY.Exp)); 
      }
   if (setSEL.Val>0){
      GlobalVariableSet(S0(Magic)+"setSEL.Val",    setSEL.Val);
      GlobalVariableSet(S0(Magic)+"setSEL.Stp",    setSEL.Stp);
      GlobalVariableSet(S0(Magic)+"setSEL.Prf",    setSEL.Prf);
      GlobalVariableSet(S0(Magic)+"SellExpiration",setSEL.Exp);
      Print(Magic,": ORDERS_COLLECT: SetSell=",S4(setSEL.Val),"/",S4(setSEL.Stp),"/",S4(setSEL.Prf)," Expir=",DTIME(setSEL.Exp));   
   }  }// 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
struct ORDER_DATA{// данные эксперта
   int      Magic, Type;
   datetime Expir, Bar, TestEndTime; 
   string   Sym, ID;
   float    Price, Stop, Profit, Risk, Lot, NewLot;   
   short    Per, BackTest, HistDD, LastTestDD;
   };  
ORDER_DATA ORD[255], TMP;  
   
void GLOBAL_ORDERS_SET(){ // выставление ордеров с учетом риска остальных экспертов 
   if (!Real) return;  // mode=0 режим выставления своих ордеров,  mode=1 режим проверки рисков
   double  OpenRisk=0, OpenMargin=0, NewOrdersRisk=0, NewOrdersMargin=0, MarginCorrect=1, RiskCorrect=1;
   uchar Orders=0;
   GlobalVariableSet("LastBalance",AccountBalance()); // для ф. CHECK_OUT()
   GlobalVariableSet("CHECK_OUT",TimeCurrent());
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__)); 
   Print(Magic,":                 *   G L O B A L   O R D E R S   S E T   B E G I N   *"); 
   // перепишем из глобальных переменных в массивы ПАРАМЕТРЫ НОВЫХ ОРДЕРОВ
   for (uchar e=0; e<ExpTotal; e++){            // перебор массива с параметрами всех экспертов
      string Mgk=S0(CSV[e].Magic);
      if (GlobalVariableCheck(Mgk+"setBUY.Val")){// есть ордер для выставления
         ORD[Orders].Magic  =CSV[e].Magic;
         ORD[Orders].Type   =10; // значит setBUY.Val
         ORD[Orders].Lot=0;   // лот расчитается ниже, исходя из индивидуального риска
         ORD[Orders].Price  =float(GlobalVariableGet(Mgk+"setBUY.Val"));         GlobalVariableDel(Mgk+"setBUY.Val"); // тут же  
         ORD[Orders].Stop   =float(GlobalVariableGet(Mgk+"setBUY.Stp"));         GlobalVariableDel(Mgk+"setBUY.Stp"); // удаляем
         ORD[Orders].Profit =float(GlobalVariableGet(Mgk+"setBUY.Prf"));         GlobalVariableDel(Mgk+"setBUY.Prf"); // считанный
         ORD[Orders].Expir  =datetime(GlobalVariableGet(Mgk+"BuyExpiration"));   GlobalVariableDel(Mgk+"BuyExpiration"); // глобал
         Orders++;    //  Print("NewOrder ",Mgk," ",S4(ORD[Orders].Price),"/",S4(ORD[Orders].Stop),"/",S4(ORD[Orders].Profit));
         }      
      if (GlobalVariableCheck(Mgk+"setSEL.Val")){// есть ордер для выставления
         ORD[Orders].Magic  =CSV[e].Magic;
         ORD[Orders].Type   =11; // значит setSEL.Val
         ORD[Orders].Lot=0;   // лот расчитается ниже, исходя из индивидуального риска
         ORD[Orders].Price  =float(GlobalVariableGet(Mgk+"setSEL.Val"));         GlobalVariableDel(Mgk+"setSEL.Val"); // тут же  
         ORD[Orders].Stop   =float(GlobalVariableGet(Mgk+"setSEL.Stp"));         GlobalVariableDel(Mgk+"setSEL.Stp"); // удаляем
         ORD[Orders].Profit =float(GlobalVariableGet(Mgk+"setSEL.Prf"));         GlobalVariableDel(Mgk+"setSEL.Prf"); // считанный
         ORD[Orders].Expir  =datetime(GlobalVariableGet(Mgk+"SellExpiration"));  GlobalVariableDel(Mgk+"SellExpiration"); // глобал
         Orders++;    //  Print("NewOrder ",Mgk," ",S4(ORD[Orders].Price),"/",S4(ORD[Orders].Stop),"/",S4(ORD[Orders].Profit));
      }  }
   // запишем в массивы параметры имеющихся ордеров  (рыночных и отложенных) 
   for (int i=0; i<OrdersTotal(); i++){// перебераем все открытые и отложенные ордера всех экспертов счета и дописываем их в массив ORD. Ролловеры (OrderType=6) туда не пишем.
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)!=true) continue;
      if (OrderType()==6) continue; // ролловеры не записываем
      ORD[Orders].Type   =OrderType();             
      ORD[Orders].Sym    =OrderSymbol();
      ORD[Orders].Price  =float(OrderOpenPrice());
      ORD[Orders].Stop   =float(OrderStopLoss());
      ORD[Orders].Profit =float(OrderTakeProfit());
      ORD[Orders].Lot    =float(OrderLots());
      ORD[Orders].Magic  =OrderMagicNumber();
      ORD[Orders].ID     =OrderComment();
      ORD[Orders].Expir  =OrderExpiration();   //Print("CurrentOrder-",Ord," ",ORD[Ord].Magic,": ",ORD2STR(ORD[Ord].Type)," ",ORD[Ord].Sym," ",S4(ORD[Ord].Price),"/",S4(ORD[Ord].Stop),"/",S4(ORD[Ord].Profit)," Expir=",TimeToStr(ORD[Ord].Expir,TIME_DATE|TIME_MINUTES)," CurLot=",S2(ORD[Ord].Lot));                   
      Orders++; // Print("Отложенные ордера = ",Ord," OrderType()=",OrderType());
      }   // теперь массив ORD содержит список всех открытых, отложенных и предстоящих установке ордеров
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__));
   if (Orders==0){
      Print(Magic,": No Orders"); 
      Print(Magic,":                 *   G L O B A L   O R D E R S   S E T   E N D   *    ");
      GlobalVariableSet("ORDERS_STATE",ORDERS_STATE());
      return;}  
   TMP.Magic   =Magic;              TMP.TestEndTime=TestEndTime;
   TMP.Per     =Per;                TMP.LastTestDD =LastTestDD;
   TMP.Bar     =BarTime;            TMP.ID         =ID;
   TMP.BackTest=BackTest;           TMP.Sym        =SYMBOL;
   TMP.HistDD  =HistDD;              
   // Пересчитаем РЕАЛЬНЫЙ РИСК КАЖДОГО ЭКСПЕРТА ЧЕРЕЗ MM(), с учетом нового баланса 
   for (uchar i=0; i<Orders; i++){
      uchar e; // объявлен до цикла, т.к. будет использоваться после
      for (e=0; e<ExpTotal; e++){            // из массива с параметрами всех экспертов
         if (ORD[i].Magic==CSV[e].Magic){      // пропишем риски и др. необходимую инфу во все имеющиеся ордера
            ORD[i].Risk        =CSV[e].Risk*Aggress; // умножаем на агрессивность торговли, определяемую при загрузке эксперта: if (Risk>0)  Aggress=Risk; else  Aggress=1
            ORD[i].HistDD      =CSV[e].HistDD;     
            ORD[i].LastTestDD  =CSV[e].LastTestDD;
            ORD[i].TestEndTime =CSV[e].TestEndTime;
            ORD[i].Sym         =CSV[e].Sym;
            ORD[i].Per         =CSV[e].Per; // период потребуется в TesterFileCreate() при отправке ErrorLog()
            break; // теперь "е" содержит номер эксперта этого ордера
         }  } 
      SYMBOL=ORD[i].Sym;
      float Stop=MathAbs(ORD[i].Price-ORD[i].Stop);
      if (ORD[i].Type<2){// открытый ордер
         OpenMargin+=ORD[i].Lot*MarketInfo(SYMBOL,MODE_MARGINREQUIRED); // кол-во маржи, необходимой для открытия лотов
         if (ORD[i].Type==0 && ORD[i].Price-ORD[i].Stop>0)  OpenRisk+=CHECK_RISK(ORD[i].Lot,Stop,SYMBOL); // если стоп еще не ушел в безубыток, считаем риск. В противном случае риск позы равен нулю
         if (ORD[i].Type==1 && ORD[i].Stop-ORD[i].Price>0)  OpenRisk+=CHECK_RISK(ORD[i].Lot,Stop,SYMBOL); // суммарный риск открытых ордеров 
         Print("Order-",i," ",ORD[i].Magic,": ",ORD2STR(ORD[i].Type)," ",ORD[i].Sym," ",S4(ORD[i].Price),"/",S4(ORD[i].Stop),"/",S4(ORD[i].Profit)," Expir=",DTIME(ORD[i].Expir)," Lot=",ORD[i].Lot);
         continue;// считать лот для открытых ордеров не надо
         }
      HistDD      =ORD[i].HistDD;
      LastTestDD  =ORD[i].LastTestDD;
      TestEndTime =ORD[i].TestEndTime;
      Magic       =ORD[i].Magic; 
      ORD[i].NewLot =MM(Stop,ORD[i].Risk, SYMBOL);
      // if (ORD[i].NewLot==0) CSV[e].Risk=0; // MM: CurDD>HistDD!  помечаем в массиве, чтобы больше не возвращаться к этому эксперту.
      Print("Order-",i," ",ORD[i].Magic,": ",ORD2STR(ORD[i].Type)," ",ORD[i].Sym," ",S4(ORD[i].Price),"/",S4(ORD[i].Stop),"/",S4(ORD[i].Profit)," Expir=",DTIME(ORD[i].Expir)," Lot=",ORD[i].Lot," NewLot=",ORD[i].NewLot," CHECK_RISK=",CHECK_RISK(ORD[i].NewLot,Stop,SYMBOL)," CurDD=",S0(CurDD)," HistDD=",S0(HistDD)," LastTestDD=",S0(LastTestDD));      
      NewOrdersRisk+=CHECK_RISK(ORD[i].NewLot,Stop,SYMBOL); // найдем суммарный риск всех новых и отложенных ордеров
      NewOrdersMargin+=ORD[i].NewLot*MarketInfo(SYMBOL,MODE_MARGINREQUIRED); // кол-во маржи, необходимой для открытия новых и отложенных ордеров
      }  //Print ("GLOBAL_ORDERS_SET()/ РИСКИ:  Маржа открытых = ",OpenOrdMargNeed/AccountFreeMargin()*100,",  Маржа отложников и новых = ",MargNeed/AccountFreeMargin()*100,", LongRisk=",LongRisk,"%, OpenLongRisk=",OpenLongRisk,"%, ShortRisk=",ShortRisk,"%, OpenShortRisk=",OpenShortRisk,"%, Orders=",Orders);   
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__));
   // П Р О В Е Р К А   Р И С К О В  /
   if (OpenRisk+NewOrdersRisk>MaxRisk && NewOrdersRisk!=0){// суммарный риск открытых и новых позиций превышает допустимый и риск новых позиций>0, т.е. есть что сократить
      if (OpenRisk<MaxRisk){// риск открытых позиций меньше предельного, т.е. остался запас для новых ордеров
         RiskCorrect=0.95*(MaxRisk-OpenRisk)/NewOrdersRisk; 
         REPORT("SumRisk="+S1(OpenRisk+NewOrdersRisk)+"% reduce Risk on "+S1(RiskCorrect*100)+"%");   
      }else{// риск открытых составляет весь допустимый риск,
         RiskCorrect=0;   // т.е. удаляем все новые неоткрытые ордера 
         REPORT("Open Orders Risk="+S1(OpenRisk)+"%! delete another pending Orders!"); // если риск открытых ордеров превышает MaxRisk, то RiskDecrease будет отрицательным. Значит оставшиеся ордера надо удалить, обнуляя лоты.
      }  }   
   // П Р О В Е Р К А   М А Р Ж И  ///
   if (OpenMargin+NewOrdersMargin>AccountFreeMargin()*MaxMargin && NewOrdersMargin!=0){// перегрузили маржу 
      if (OpenMargin<AccountFreeMargin()*MaxMargin){// маржа открытых позиций меньше предельной, т.е. остался запас для новых ордеров
         MarginCorrect=0.95*(AccountFreeMargin()*MaxMargin-OpenMargin)/NewOrdersMargin; // расчитаем коэффициент уменьшения риска/лота отложенных и новых ордеров (умножаеам на 0.95 для гистерезиса)
         REPORT("Margin="+S1(OpenMargin+NewOrdersMargin)+"% Decrease MarginRisk on "+S1(MarginCorrect*100)+"%"); 
      }else{
         MarginCorrect=0; // если риск открытых ордеров превышает MaxRisk, то RiskDecrease будет отрицательным. Значит оставшиеся ордера надо удалить, обнуляя лоты.
         REPORT("Open Orders Margin="+S1(OpenMargin)+"%! delete all pending Orders!");
      }  }
   double LotDecrease=MathMin(MarginCorrect,RiskCorrect); // из возможных корректировок риска и маржи берем максимальное сокращение
   if (LotDecrease<1){ // при инициализации MarginCorrect=1 и RiskCorrect=1. Если потребовалась одна из корректировок
      for (short i=0; i<Orders; i++){// пересчитаем все лоты
         if (ORD[i].Type<2 || ORD[i].NewLot==0) continue; // открытые (Type=0..1) НЕ ТРОГАЕМ
         ORD[i].NewLot=float(NormalizeDouble(ORD[i].NewLot*LotDecrease, LotDigits));// на всех отложниках и новых ордерах уменьшаем риск/лот, чтобы вписаться в маржу
         if (LotDecrease>0 && ORD[i].NewLot<MarketInfo(ORD[i].Sym,MODE_MINLOT)){// лот меньше допустимого
            // Print("GLOBAL_ORDERS_SET NewLot<MINLOT ",i,". ",ORD[i].Magic,"/",ORD2STR(ORD[i].Type)," i.e. ",ORD[i].NewLot,"<",MarketInfo(ORD[i].Sym,MODE_MINLOT)," NewLot=",MarketInfo(ORD[i].Sym,MODE_MINLOT));
            ORD[i].NewLot=float(MarketInfo(ORD[i].Sym,MODE_MINLOT));
      }  }  }
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__));
   // В Ы С Т А В Л Е Н И Е   О Р Д Е Р О В  
   for (short i=0; i<Orders; i++){
      if (ORD[i].Type<2) continue; // открытые (Type=0..1) НЕ ТРОГАЕМ
      //if (ORD[i].Lot>0 && ORD[i].NewLot>0 && MathAbs(ORD[i].Lot-ORD[i].NewLot)<MarketInfo(ORD[i].Sym,MODE_LOTSTEP)){
      if (ORD[i].Lot==ORD[i].NewLot){
         Print("GLOBAL_ORDERS_SET ",i,". ",ORD[i].Magic,"/",ORD2STR(ORD[i].Type)," SkipModify i.e. Lot=NewLot: Lot=",ORD[i].Lot," NewLot=",ORD[i].NewLot);
         continue;} 
      if (ORD[i].Expir>0 && ORD[i].Expir-TimeCurrent()<ORD[i].Per*60){ // экспирация ордера истекает на этом баре, его модификация приведет к ошибке
         Print("GLOBAL_ORDERS_SET ",i,". ",ORD[i].Magic,"/",ORD2STR(ORD[i].Type)," SkipModify i.e. Order Expiration finish soon ",DTIME(ORD[i].Expir));
         continue;}
      SYMBOL      =ORD[i].Sym;
      Per         =ORD[i].Per; // период потребуется в TESTER_FILE_CREATE() при отправке ErrorLog()
      HistDD      =ORD[i].HistDD;
      LastTestDD  =ORD[i].LastTestDD;
      TestEndTime =ORD[i].TestEndTime;
      Magic       =ORD[i].Magic; 
      ID          =ORD[i].ID;
      MARKET_UPDATE(SYMBOL); // ASK, BID, DIGITS, Spred, StopLevel
      ORDER_CHECK();
      setBUY.Val=0;  setBUY.Stp=ORD[i].Stop; setBUY.Prf=ORD[i].Profit; setBUY.Exp=ORD[i].Expir;
      setSEL.Val=0;  setSEL.Stp=ORD[i].Stop; setSEL.Prf=ORD[i].Profit; setSEL.Exp=ORD[i].Expir;
      switch(ORD[i].Type){
         case 2:  setBUY.Val=ORD[i].Price; BUYLIM=0;   break; // выбираем тип
         case 3:  setSEL.Val=ORD[i].Price; SELLIM=0;   break; // ордера
         case 4:  setBUY.Val=ORD[i].Price; BUYSTP=0;   break; // который
         case 5:  setSEL.Val=ORD[i].Price; SELSTP=0;   break; // нужно удалить
         case 10: setBUY.Val=ORD[i].Price;             break;
         case 11: setSEL.Val=ORD[i].Price;             break;
         } 
      Lot  =ORD[i].NewLot;     if (IsTesting()) Lot=float(0.1); 
      if (Lot>0)  Print("GLOBAL_ORDERS_SET ",i,". ",Magic,"/",ORD2STR(ORD[i].Type)," ",SYMBOL," ",ORD[i].Price,"/",ORD[i].Stop,"/",ORD[i].Profit,"  Risk=",ORD[i].Risk,"  Lot=",Lot,"  Expir=",DTIME(ORD[i].Expir));
      else        REPORT("Delete "+S0(Magic)+", CurDD>HistDD");
      if (ORD[i].Type<6)   MODIFY();      // Удаление отложников 
      if (Lot>0)           ORDERS_SET();
      }    
   Magic    =TMP.Magic;       TestEndTime =TMP.TestEndTime;
   BackTest =TMP.BackTest;    SYMBOL      =TMP.Sym;
   BarTime  =TMP.Bar;         ID          =TMP.ID;
   Per      =TMP.Per;         LastTestDD  =TMP.LastTestDD;
   HistDD   =TMP.HistDD;       
   GlobalVariableSet("ORDERS_STATE",ORDERS_STATE());
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__));
   Print(Magic,":                 *   G L O B A L   O R D E R S   S E T   E N D   * ");    
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void CHECK_OUT(){// Проверка недавних ордеров и состояния баланса для изменения лота текущих отложников  (При инвестировании или после крупных сделок) ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return; 
   Sleep(ExpPause);
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__));
   if (TimeLocal()-GlobalVariableGet("CHECK_OUT")<600) return;
   GlobalVariableSet("CHECK_OUT",TimeLocal());         // обновляем время последнего изменения глобала  "CHECK_OUT"
   if (!GlobalVariableSetOnCondition("GlobalOrdersSet",Magic,0)) return; // попытка захвата флага доступа к ф. "GlobalOrdersSet"    
   GlobalVariableSet("GlobalOrdersSet"+"Busy",TimeLocal()); // обновляем время последнего изменения глобала "GlobalOrdersSet"
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__));
   for (int i=0; i<TimeLocal()-GlobalVariableTime("ORDERS_STATE"); i+=300){ // кол-во пустых строк равно
      Print(" ");                                                          // количеству десятиминуток с последнего обращения к глобалу "ORDERS_STATE"
      if (i>3000) break;}  // берегем бумагу - не более 5 строк
   bool NeedToCheckOrders=false;
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__));
   if (GlobalVariableGet("ORDERS_STATE")!=ORDERS_STATE()){ // время последнего выставленного ордера изменилось
      REPORT("CHECK_OUT(): ORDERS_STATE changed, recount orders");
      NeedToCheckOrders=true;
      }  
   double BalanceChange=(AccountBalance()-GlobalVariableGet("LastBalance"))*100/AccountBalance();
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__));
   if (MathAbs(BalanceChange)>5){
      REPORT("CHECK_OUT(): BalanceChange="+ S0(BalanceChange) +"%, recount orders");  Print("LastBalance=",S0(GlobalVariableGet("LastBalance"))," AccountBalance=",S0(AccountBalance()));
      NeedToCheckOrders=true;
      }
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__));
   for (short e=0; e<ExpTotal; e++){// перебор массива с параметрами всех экспертов
      string Mgk=S0(CSV[e].Magic);
      if (GlobalVariableCheck(Mgk+"setBUY.Val") || GlobalVariableCheck(Mgk+"setSEL.Val")){ // поиск ордеров для выставления через глобалы
         REPORT("CHECK_OUT(): find NewOrder of "+Mgk+" to set");
         NeedToCheckOrders=true;
      }  }   
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__));
   if (NeedToCheckOrders){
      Print(Magic,": CHECK_OUT(): Need to start function 'GLOBAL_ORDERS_SET()'");
      GLOBAL_ORDERS_SET();} // расставляем ордера
   else Print(Magic,": CHECK_OUT(): ORDERS_STATE not changed, BalanceChange=",S1(BalanceChange),"%"); 
   ERROR_CHECK(__FUNCTION__+"-"+S0(__LINE__));
   FREE("GlobalOrdersSet");
   } 
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
string ORD2STR(int Type){ 
   switch(Type){
      case 0:  return ("BUY"); 
      case 1:  return ("SELL");
      case 2:  return ("BUYLIMIT"); 
      case 3:  return ("SELLLIMIT");
      case 4:  return ("BUYSTOP");
      case 5:  return ("SELLSTOP");
      case 6:  return ("RollOver");
      case 10: return ("setBUY");
      case 11: return ("setSELL");
      default: return ("-");
   }  }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
datetime ORDERS_STATE(){ // состояние ордеров: время последнего + общее кол-во.
   datetime LastOrdTime=0;
   for (int i=0; i<OrdersTotal(); i++){// перебераем все открытые и отложенные ордера всех экспертов счета
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false) continue; 
      if (OrderType()==6) continue; // ролловеры пропускаем
      if (OrderOpenTime()>LastOrdTime) LastOrdTime=OrderOpenTime(); //Print("Order ",ORD2STR(OrderType())," time=",TimeToStr(OrderOpenTime(),TIME_DATE | TIME_MINUTES), " LastOrdTime=",TimeToStr(LastOrdTime,TIME_DATE | TIME_MINUTES));
      }      
   return (LastOrdTime+OrdersTotal()); 
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

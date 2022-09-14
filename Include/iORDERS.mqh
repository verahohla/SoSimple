struct SIG{    // Buy, Sell  СИГНАЛЫ 
   datetime T;    // последнее время обновления зоны
   char Pattern;         // отслеживаемый паттерн
   float Mem,New,Stp,Prf;  // цена сигнала, цены ордеров
   PICS Sig1,Sig2;      // вложенная структура предварительных сигналов и сигналов подтверждения
   }; 
SIG Sel,Buy;

struct PRICE{    // 
   float Val,Stp,Prf;  // 
   }; 
PRICE setSEL, setBUY, SEL, BUY;
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
   if (setBUY.Val-setBUY.Stp <= StopLevel)   {X("Stop too close to setBUY: "  +S4(setBUY.Val-setBUY.Stp)+" pips", setBUY.Val, bar, clrRed); repeat=0;}  // слишком близкий/неправильный стоп
   if (setBUY.Prf-setBUY.Val <= StopLevel)   {X("Profit too close to setBUY: "+S4(setBUY.Prf-setBUY.Val)+" pips", setBUY.Val, bar, clrRed); repeat=0;}  // слишком близкий/неправильный тейк
   while (repeat>0 && BUY.Val==0 && BUYSTP==0 && BUYLIM==0){ 
      if (Real){
         TerminalHold(); // ждем 60сек освобождения терминала
         MARKET_UPDATE(SYMBOL);
         Print("ORDERS_SET(): setBUY.Val=",S4(setBUY.Val),"/",S4(setBUY.Stp),"/",S4(setBUY.Prf)," Lot=",Lot," Magic=",Magic," Exp=",Expiration," ASK/BID=",S4(ASK),"/",S4(BID));
         Lot=MM(setBUY.Val-setBUY.Stp, SYMBOL); if (Lot<0) {REPORT("Lot<0"); break;} 
         TradeRisk=RiskChecker(Lot, setBUY.Val-setBUY.Stp, SYMBOL); 
         if (TradeRisk>MaxRisk) {REPORT("RiskChecker="+S2(TradeRisk)+"% too BIG!!! Lot="+S2(Lot)+" Balance="+S0(AccountBalance())+" Stop="+S4(setBUY.Val-setBUY.Stp)+" SYMBOL="+SYMBOL); break;}
         }
      if (setBUY.Val-ASK>StopLevel)  {str="Set BuyStp ";   ticket=OrderSend(SYMBOL,OP_BUYSTOP, Lot, setBUY.Val, 3, setBUY.Stp, setBUY.Prf, ExpID, Magic,Expiration,CornflowerBlue);}   else
      if (ASK-setBUY.Val>StopLevel)  {str="Set BuyLim ";   ticket=OrderSend(SYMBOL,OP_BUYLIMIT,Lot, setBUY.Val, 3, setBUY.Stp, setBUY.Prf, ExpID, Magic,Expiration,CornflowerBlue);}   else
                   {setBUY.Val=ASK;   str="Set setBUY ";      ticket=OrderSend(SYMBOL,OP_BUY,     Lot, setBUY.Val, 3, setBUY.Stp, setBUY.Prf, ExpID, Magic,    0        ,CornflowerBlue);}
      REPORT(str+S4(setBUY.Val)+"/"+S4(setBUY.Stp)+"/"+S4(setBUY.Prf)+"/"+S2(Lot)+"x"+S1(TradeRisk)+"%");
      ORDER_CHECK();
      if (ticket>0) break; // Ордеру назначен номер тикета. В случае неудачи ticket=-1   
      if (ERROR_CHECK("OrdersSet/setBUY")) repeat--; else repeat=0; // ERROR_CHECK() возвращает необходимость повтора торговой операции
      }
   TerminalFree();   
   }  
void SET_SEL(){   
   if (setSEL.Val<=0) return; 
   int ticket;   double TradeRisk=0;  string str;
   char repeat=3; // три попытки у тебя  
   if (MathAbs(BID-setSEL.Val)<=StopLevel) setSEL.Val=BID;
   if (setSEL.Stp-setSEL.Val <= StopLevel) {X("Stop too close to Sell: "  +S4(setSEL.Stp-setSEL.Val)+" pips",  setSEL.Val, bar, clrRed); repeat=0;}  // слишком близкий/неправильный стоп
   if (setSEL.Val-setSEL.Prf <= StopLevel) {X("Profit too close to Sell: "+S4(setSEL.Val-setSEL.Prf)+" pips",  setSEL.Val, bar, clrRed); repeat=0;}  // слишком близкий/неправильный тейк
   while (repeat>0 &&  SEL.Val==0 && SELSTP==0 && SELLIM==0){
      if (Real){
         TerminalHold(); // ждем 60сек освобождения терминала
         MARKET_UPDATE(SYMBOL);
         Print("ORDERS_SET(): setSEL.Val=",S4(setSEL.Val),"/",S4(setBUY.Stp),"/",S4(setBUY.Prf)," Lot=",Lot," Magic=",Magic," Exp=",Expiration," ASK/BID=",S4(ASK),"/",S4(BID));
         Lot=MM(setSEL.Stp-setSEL.Val, SYMBOL); if (Lot<0) {REPORT("Lot<0"); break;} 
         TradeRisk=RiskChecker(Lot, setSEL.Stp-setSEL.Val, SYMBOL);
         if (TradeRisk>MaxRisk) {REPORT("RiskChecker="+S2(TradeRisk)+"% too BIG!!! Lot="+S2(Lot)+" Balance="+S0(AccountBalance())+" Stop="+S4(setSEL.Stp-setSEL.Val)+" SYMBOL="+SYMBOL); break;}
         }
      if (BID-setSEL.Val>StopLevel) {str="Set SellStp ";   ticket=OrderSend(SYMBOL,OP_SELLSTOP, Lot, setSEL.Val, 3, setSEL.Stp, setSEL.Prf, ExpID, Magic,Expiration,Tomato);}   else
      if (setSEL.Val-BID>StopLevel) {str="Set SellLim ";   ticket=OrderSend(SYMBOL,OP_SELLLIMIT,Lot, setSEL.Val, 3, setSEL.Stp, setSEL.Prf, ExpID, Magic,Expiration,Tomato);}   else
                   {setSEL.Val=BID;  str="Set Sell ";      ticket=OrderSend(SYMBOL,OP_SELL,     Lot, setSEL.Val, 3, setSEL.Stp, setSEL.Prf, ExpID, Magic,      0       ,Tomato);}
      REPORT(str+S4(setSEL.Val)+"/"+S4(setSEL.Stp)+"/"+S4(setSEL.Prf)+"/"+S2(Lot)+"x"+S1(TradeRisk)+"%");
      ORDER_CHECK();
      if (ticket>0) break;  // Ордеру назначен номер тикета. В случае неудачи ticket=-1   
      if (ERROR_CHECK("OrdersSet/Sell")) repeat--; else repeat=0; // ERROR_CHECK() возвращает необходимость повтора торговой операции
      }
   TerminalFree();  
   }  
   
     
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void MODIFY(){   // Похерим необходимые стоп/лимит ордера: удаление если setBUY/Sell=0       
   bool ReSelect=true;      // если похерили какой-то ордер, надо повторить перебор сначала, т.к. OrdersTotal изменилось, т.е. они все перенумеровались 
   while (ReSelect){        // и переменная ReSelect вызовет их повторный перебор        
      ReSelect=false; int Orders=OrdersTotal();
      for(int Ord=0; Ord<Orders; Ord++){ 
         if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)!=true || OrderMagicNumber()!=Magic) continue;
         int Order=OrderType();
         bool make=true;  
         uchar repeat=3;  
         while (repeat){// повторяем операции над ордером, пока не более 3 раз
            TerminalHold();
            MARKET_UPDATE(SYMBOL);
            switch(Order){
               case OP_SELL:        //  C L O S E     S E L L  
                  if (SEL.Val==0){
                     make=OrderClose(OrderTicket(),OrderLots(),ASK,3,Tomato); 
                     REPORT("Close SELL/"+S4(OrderOpenPrice())); 
                     break;
                     }               //  M O D I F Y     S E L L  
                  if (!EQUAL(SEL.Stp,OrderStopLoss()) && SEL.Stp-ASK>StopLevel){Print("SEL.Stp=",SEL.Stp," OrderStop=",OrderStopLoss());
                     make=OrderModify(OrderTicket(), OrderOpenPrice(), SEL.Stp, OrderTakeProfit(),OrderExpiration(),Tomato);   REPORT("ModifySellStop/"+S4(SEL.Stp));}
                  if (!EQUAL(SEL.Prf,OrderTakeProfit()) && ASK-SEL.Prf>StopLevel){Print("SEL.Prf=",SEL.Prf," OrderTakeProfit=",OrderTakeProfit());
                     make=OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), SEL.Prf,OrderExpiration(),Tomato);   REPORT("ModifySellProfit/"+S4(SEL.Prf));}
                  break; 
               case OP_SELLSTOP:    //  D E L   S E L L S T O P  //
                  if (SELSTP==0){ 
                     if (BID-OrderOpenPrice()>StopLevel){   make=OrderDelete(OrderTicket(),Tomato);                              REPORT("Del SellStop/"+S4(OrderOpenPrice()));}
                     else                                                                                                        REPORT("Can't Del SELLSTOP near market! BID="+S5(BID)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}
                  break;
               case OP_SELLLIMIT:   //  D E L   S E L L L I M I T  //
                  if (SELLIM==0){
                     if (OrderOpenPrice()-BID>StopLevel){   make=OrderDelete(OrderTicket(),Tomato);                              REPORT("Del SellLimit/"+S4(OrderOpenPrice()));}
                     else                                                                                                        REPORT("Can't Del SELLLIMIT! near market, BID="+S5(BID)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}   
                  break;
               case OP_BUY:   //  C L O S E    B U Y  //////////////////////////////////////////////////////////////
                  if (BUY.Val==0){
                     make=OrderClose(OrderTicket(),OrderLots(),BID,3,CornflowerBlue); 
                     REPORT("Close BUY/"+S4(OrderOpenPrice()));  
                     break;
                     }        // M O D I F Y      B U Y
                  if (!EQUAL(BUY.Stp,OrderStopLoss()) && BID-BUY.Stp>StopLevel){Print("BUY.Stp=",BUY.Stp," OrderStop=",OrderStopLoss());
                     make=OrderModify(OrderTicket(), OrderOpenPrice(), BUY.Stp, OrderTakeProfit(),OrderExpiration(),CornflowerBlue);   REPORT("ModifyBuyStop/"+S4(BUY.Stp));} 
                  if (!EQUAL(BUY.Prf,OrderTakeProfit()) && BUY.Prf-BID>StopLevel){Print("BUY.Prf=",BUY.Prf," OrderTakeProfit=",OrderTakeProfit());
                     make=OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), BUY.Prf,OrderExpiration(),CornflowerBlue);   REPORT("ModifyBuyProfit/"+S4(BUY.Prf));}
                  break; 
               case OP_BUYSTOP:  //  D E L  B U Y S T O P  //
                  if (BUYSTP==0){
                     if (OrderOpenPrice()-ASK>StopLevel){   make=OrderDelete(OrderTicket(),CornflowerBlue);                      REPORT("Del BuyStop/"+S4(OrderOpenPrice()));}
                     else                                                                                                        REPORT("Can't Del BUYSTOP near market! ASK="+S5(ASK)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}
                  break; 
               case OP_BUYLIMIT: //  D E L  B U Y L I M I T  //
                  if (BUYLIM==0){
                     if (ASK-OrderOpenPrice()>StopLevel){   make=OrderDelete(OrderTicket(),CornflowerBlue);                      REPORT("Del BuyLimit/"+S4(OrderOpenPrice()));}
                     else                                                                                                        REPORT("Can't Del BUYLIMIT near market! ASK="+S5(ASK)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}
                  break;
               }// switch(Order)  
            if (make) break; //  true при успешном завершении, или false в случае ошибки  
            if (ERROR_CHECK("Modify "+OrdToStr(Order)+" Ticket="+S0(OrderTicket())+" repeat="+S0(repeat))) repeat--; else repeat=0; // ERROR_CHECK() возвращает необходимость повтора торговой операции            
            }  //while(repeat)  
         if (Orders!=OrdersTotal()) {ReSelect=true; break;} // при ошибках или изменении кол-ва ордеров надо заново перебирать ордера (выходим из цикла "for"), т.к. номера ордеров поменялись
         }// for(Ord=0; Ord<Orders; Ord++){    
      }// while(ReSelect)     
   TerminalFree();
   ERROR_CHECK("Modify");  
   }  
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool EQUAL(double One, double Two){// совпадение значений с точностью до 10 тиков
   //if (MathAbs(N4(One)-N4(Two))>1) return false; else return true;
   if (MathAbs(One-Two)<MarketInfo(SYMBOL,MODE_DIGITS)) return true; else return false;
   }     
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void MARKET_UPDATE(string SYM){ // ASK, BID, DIGITS, Spred, StopLevel
   RefreshRates(); 
   ASK      =MarketInfo(SYM,MODE_ASK); 
   BID      =MarketInfo(SYM,MODE_BID);    // в функции GlobalOrdersSet() ордера ставятся с одного графика на разные пары, поэтому надо знать данные пары выставляемого ордера     
   DIGITS   =int(MarketInfo(SYM,MODE_DIGITS)); // поэтому надо знать данные пары выставляемого ордера
   Spred    =MarketInfo(SYM,MODE_SPREAD)   *MarketInfo(SYM,MODE_POINT);
   StopLevel=(MarketInfo(SYMBOL,MODE_STOPLEVEL) + MarketInfo(SYMBOL,MODE_SPREAD)) * MarketInfo(SYMBOL,MODE_POINT);  // Спред необходимо учитывать, т.к. вход и выход из позы происходят по разным ценам (ask/bid)
   }      
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void ORDER_CHECK(){   // ПАРАМЕТРЫ ОТКРЫТЫХ И ОТЛОЖЕННЫХ ПОЗ
   BUY.Val=0; BUYSTP=0; BUYLIM=0; SEL.Val=0; SELSTP=0; SELLIM=0;  BUY.Stp=0; BUY.Prf=0; SEL.Stp=0; SEL.Prf=0;
   for (int i=0; i<OrdersTotal(); i++){ 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)!=true || OrderMagicNumber()!=Magic) continue;
      if (OrderType()==6) continue; // ролловеры не записываем
      switch(OrderType()){
         case OP_BUYSTOP:  BUYSTP=OrderOpenPrice();   BUY.Stp=OrderStopLoss();   BUY.Prf=OrderTakeProfit();    BuyTime=OrderOpenTime();    break;
         case OP_BUYLIMIT: BUYLIM=OrderOpenPrice();   BUY.Stp=OrderStopLoss();   BUY.Prf=OrderTakeProfit();    BuyTime=OrderOpenTime();    break;
         case OP_BUY:      BUY.Val=OrderOpenPrice();  BUY.Stp=OrderStopLoss();   BUY.Prf=OrderTakeProfit();    BuyTime=OrderOpenTime();    break;
         case OP_SELLSTOP: SELSTP=OrderOpenPrice();   SEL.Stp=OrderStopLoss();   SEL.Prf=OrderTakeProfit();    SellTime=OrderOpenTime();   break;
         case OP_SELLLIMIT:SELLIM=OrderOpenPrice();   SEL.Stp=OrderStopLoss();   SEL.Prf=OrderTakeProfit();    SellTime=OrderOpenTime();   break;
         case OP_SELL:     SEL.Val=OrderOpenPrice();  SEL.Stp=OrderStopLoss();   SEL.Prf=OrderTakeProfit();    SellTime=OrderOpenTime();   break;
   }  }  }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void CHECK_OUT(){// Проверка недавних ордеров и состояния баланса для изменения лота текущих отложников  (При инвестировании или после крупных сделок) ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return; 
   if (TimeCurrent()-GlobalVariableGet("CHECK_OUT_Time")<600) return;
   if (GlobalVariableGet("CanTrade")!=Magic && !GlobalVariableSetOnCondition("CanTrade",Magic,0)) return; // попытка захватат флага доступа к терминалу    
   GlobalVariableSet("CHECK_OUT_Time",TimeCurrent());
   datetime LastOrdTime=LAST_ORD_TIME();
   bool NeedToCheckOrders=false;
   if (GlobalVariableGet("LastOrdTime")!=LastOrdTime){ // разница между сохраненным временем ордера и последним выставленным больше минуты, т.е. 
      REPORT("CHECK_OUT(): LastOrdTime "+TIME(datetime(GlobalVariableGet("LastOrdTime")))+", changed to "+TIME(LastOrdTime)+", recount orders");
      GlobalVariableSet("LastOrdTime",LastOrdTime); 
      NeedToCheckOrders=true;
      }  
   double BalanceChange=(GlobalVariableGet("LastBalance")-AccountBalance())*100/AccountBalance();
   if (MathAbs(BalanceChange)>5){
      REPORT("CHECK_OUT(): BalanceChange="+ S0(BalanceChange) +"%, recount orders");
      NeedToCheckOrders=true;
      }
   GlobalVariableSet("CanTrade",0); // сбрасываем глобал
   //if (NeedToCheckOrders) GlobalOrdersSet(); // расставляем ордера
   //else Print(Magic,": CHECK_OUT(): Time of LastOrd ",TIME(LastOrdTime)," not changed, BalanceChange=",S1(BalanceChange),"%"); 
   } 
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
string OrdToStr(int Type){ 
   switch(Type){
      case 0:  return ("BUY"); 
      case 1:  return ("SELL");
      case 2:  return ("BUYLIMIT"); 
      case 3:  return ("SELLLIMIT");
      case 4:  return ("BUYSTOP");
      case 5:  return ("SELLSTOP");
      case 6:  return ("RollOver");
      case 10: return ("setBUY.Val");
      case 11: return ("setSEL.Val");
      default: return ("-");
   }  }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
datetime LAST_ORD_TIME(){
   datetime LastOrdTime=0;
   for (int i=0; i<OrdersTotal(); i++){// перебераем все открытые и отложенные ордера всех экспертов счета и дописываем их в массив ORD. Ролловеры (OrderType=6) туда не пишем.
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false) continue; 
      if (OrderType()==6) continue; // ролловеры пропускаем
      if (OrderOpenTime()>LastOrdTime) LastOrdTime=OrderOpenTime(); //Print("Order ",OrdToStr(OrderType())," time=",TimeToStr(OrderOpenTime(),TIME_DATE | TIME_MINUTES), " LastOrdTime=",TimeToStr(LastOrdTime,TIME_DATE | TIME_MINUTES));
      }      
   return (LastOrdTime);
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

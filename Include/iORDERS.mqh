void ORDERS_SET(){
   bool repeat;   int ticket;   float TradeRisk=0; 
   if (ExpirBars>0)  Expiration=Time[0]+ExpirBars*Period()*60; else Expiration=0;// уменьшаем период на 30сек, чтоб совпадало с реалом 
   if (SetBUY>0){ 
      repeat=true;   uchar try=0; 
      SetBUY         =N5(SetBUY);
      SetSTOP_BUY    =N5(SetSTOP_BUY);
      SetPROFIT_BUY  =N5(SetPROFIT_BUY);
      if (MathAbs(SetBUY-Ask) <=StopLevel) SetBUY=(float)Ask; 
      if (SetBUY-SetSTOP_BUY  <=StopLevel+Spred)   {X("WrongBuyStop="  +S4(SetBUY-SetSTOP_BUY),   SetBUY, bar, clrRed); return;}  // слишком близкий/неправильный стоп
      if (SetPROFIT_BUY-SetBUY<=StopLevel+Spred)   {X("WrongBuyProfit="+S4(SetPROFIT_BUY-SetBUY), SetBUY, bar, clrRed); return;}  // слишком близкий/неправильный тейк
      if (Real){
         str="";
         ERROR_CHECK("PreBuy");// сброс буфера ошибок
         MARKET_INFO();
         float Stop=SetBUY-SetSTOP_BUY;
         if (Stop<=0) {Report("StopBuy<=0"); return;}
         Lot=MM(Stop); if (Lot<0) {Report("Lot<0"); return;} 
         TradeRisk=RiskChecker(Lot,Stop,Symbol());   //   Print("Lot=",Lot," StopBuy=",StopBuy," TradeRisk=",TradeRisk," SetBUY=",SetBUY," SetSTOP_BUY=",SetSTOP_BUY," SetPROFIT_BUY=",SetPROFIT_BUY);
         if (TradeRisk>MaxRisk) {Report("RiskChecker="+S1(TradeRisk)+"% too BIG!!! Lot="+S2(Lot)+" Balance="+S0(AccountBalance())+" Stop="+S4(Stop)+" SetBUY="+S4(SetBUY)+" SetSTOP_BUY="+S4(SetSTOP_BUY)); return;}
         TerminalHold(60); // ждем 60сек освобождения терминала
         }
      while (repeat && BUY==0 && BUYSTOP==0 && BUYLIMIT==0){ // чтобы исключить повторное выставление при ошибке 128
         if (SetBUY-Ask>StopLevel)  {if (Real) str="SetBuyStp";   ticket=OrderSend(Symbol(),OP_BUYSTOP, Lot, SetBUY, 3, SetSTOP_BUY, SetPROFIT_BUY, ExpID, Magic, Expiration,clrBlue);}   else
         if (Ask-SetBUY>StopLevel)  {if (Real) str="SetBuyLim";   ticket=OrderSend(Symbol(),OP_BUYLIMIT,Lot, SetBUY, 3, SetSTOP_BUY, SetPROFIT_BUY, ExpID, Magic, Expiration,clrBlue);}   else
               {SetBUY=(float)Ask;   if (Real) str="SetBuy";      ticket=OrderSend(Symbol(),OP_BUY,     Lot, SetBUY, 3, SetSTOP_BUY, SetPROFIT_BUY, ExpID, Magic,    0      ,clrBlue);}
         if (ticket<0){
            ERROR_CHECK("Buy");
            repeat=true; 
            try++; if (try>3) repeat=false;}
         else repeat=false;
         if (Real){
            Report(str+S4(SetBUY)+"/"+S4(SetSTOP_BUY)+"/"+S4(SetPROFIT_BUY)+"/"+S2(Lot)+"x"+S1(TradeRisk)+"% Expir="+DTIME(Expiration)); str="";
            ORDER_CHECK();
      }  }  }
   if (SetSELL>0){ 
      repeat=true;   uchar try=0; 
      SetSELL        =N5(SetSELL); 
      SetSTOP_SELL   =N5(SetSTOP_SELL);   
      SetPROFIT_SELL =N5(SetPROFIT_SELL); 
      if (MathAbs(SetSELL-Bid)   <=StopLevel)  SetSELL=(float)Bid;// немного отодвигаем стоп от расчетной точки
      if (SetSTOP_SELL-SetSELL   <=StopLevel+Spred) {X("WrongSellStop="  +S4(SetSTOP_SELL-SetSELL),    SetSELL, bar, clrRed); return;}  // слишком близкий/неправильный стоп
      if (SetSELL-SetPROFIT_SELL <=StopLevel+Spred) {X("WrongSellProfit="+S4(SetSELL-SetPROFIT_SELL),  SetSELL, bar, clrRed); return;}  // слишком близкий/неправильный тейк
      if (Real){
         str="";
         ERROR_CHECK("PreSell");// сброс буфера ошибок
         MARKET_INFO();
         float Stop=SetSTOP_SELL-SetSELL;
         if (Stop<=0) {Report("StopSell<=0"); return;}
         Lot=MM(Stop); if (Lot<0) {Report("Lot<0"); return;}
         TradeRisk=RiskChecker(Lot,Stop,Symbol());
         if (TradeRisk>MaxRisk) {Report("RiskChecker="+S1(TradeRisk)+"% too BIG!!! Lot="+S2(Lot)+" Balance="+S0(AccountBalance())+" Stop="+S4(SetSTOP_SELL-SetSELL)+" SetSELL="+S4(SetSELL)+" SetSTOP_SELL="+S4(SetSTOP_SELL)); return;}
         TerminalHold(60); // ждем 60сек освобождения терминала
         }
      while (repeat &&  SELL==0 && SELLSTOP==0 && SELLLIMIT==0){   //  V("SELL "+S4(SetSELL)+"/"+S4(SetSTOP_SELL)+"/"+S4(SetPROFIT_SELL), SetSELL, bar, clrSilver);
         if (Bid-SetSELL>StopLevel) {if (Real) str="SetSellStp";   ticket=OrderSend(Symbol(),OP_SELLSTOP, Lot, SetSELL, 3, SetSTOP_SELL, SetPROFIT_SELL, ExpID, Magic, Expiration,clrRed);}   else
         if (SetSELL-Bid>StopLevel) {if (Real) str="SetSellLim";   ticket=OrderSend(Symbol(),OP_SELLLIMIT,Lot, SetSELL, 3, SetSTOP_SELL, SetPROFIT_SELL, ExpID, Magic, Expiration,clrRed);}   else
               {SetSELL=(float)Bid;  if (Real) str="SetSell";      ticket=OrderSend(Symbol(),OP_SELL,     Lot, SetSELL, 3, SetSTOP_SELL, SetPROFIT_SELL, ExpID, Magic,      0    ,clrRed);}
         if (ticket<0){
            ERROR_CHECK("Sell");
            repeat=true; 
            try++; if (try>3) repeat=false;}
         else repeat=false;
         if (Real){
            Report(str+S4(SetSELL)+"/"+S4(SetSTOP_SELL)+"/"+S4(SetPROFIT_SELL)+"/"+S2(Lot)+"x"+S1(TradeRisk)+"% Expir="+DTIME(Expiration)); str="";    
            ORDER_CHECK();
      }  }  }
   TerminalFree();
   if (Real) ERROR_CHECK("ORDERS_SET");
   }  
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void ORDERS_MODIFY(){   // Похерим необходимые стоп/лимит ордера: удаление если Buy/Sell=0       
   if (!Modify) return;
   bool ReSelect=true, make;      // если похерили какой-то ордер, надо повторить перебор сначала, т.к. OrdersTotal изменилось, т.е. они все перенумеровались 
   while (ReSelect){        // и переменная ReSelect вызовет их повторный перебор        
      ReSelect=false; int Orders=OrdersTotal(); //Print("ORDERS_MODIFY()/ReSelect=",ReSelect,"  Orders=",Orders);
      for (int i=0; i<Orders; i++){ //Print("for:  i=",i);
         if (ReSelect) break; // при ошибках перебор ордеров начинается заново
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true && OrderMagicNumber()==Magic){
            int Order=OrderType();  make=false;  uchar try=0;  //Print("for: Order=",ORDER_TO_STR(Order));
            if (Real){
               str="";
               MARKET_INFO();
               ERROR_CHECK("PreModify");}
            while (!make){// повторяем операции над ордером, пока не достигнем результата
               make=true; //Print("Begin: Order=",ORDER_TO_STR(Order)," i=",i," Orders=",Orders);
               switch(Order){
                  case OP_SELL:        
                     if (SELL==0){     //  C L O S E     S E L L  
                        if (Real) str="CloseSELL-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);       
                        break;} 
                                       //  M O D I F Y     S E L L  
                     STOP_SELL  =N5(STOP_SELL);    // нормализация до
                     PROFIT_SELL=N5(PROFIT_SELL);  // пятого знака
                     if (EQUAL(STOP_SELL,OrderStopLoss()) && EQUAL(PROFIT_SELL,OrderTakeProfit())) break; // новые значения должны отличаться от текущих охтябы на 10 пунктов
                     if (STOP_SELL-Ask<=Spred || Ask-PROFIT_SELL<=Spred) break; // корректность новых значений 
                     if (Real){
                        if (!EQUAL(STOP_SELL,   OrderStopLoss()))    str="ModifySellStp-"+S4(OrderStopLoss())+"/"+S4(STOP_SELL);
                        if (!EQUAL(PROFIT_SELL, OrderTakeProfit()))  str="ModifySellPrf-"+S4(OrderTakeProfit())+"/"+S4(PROFIT_SELL);}
                     TerminalHold(60);    make=OrderModify(OrderTicket(), OrderOpenPrice(), STOP_SELL, PROFIT_SELL,OrderExpiration(),clrRed);   //Print(" ord=",ord," STOP_SELL=",STOP_SELL," OrderStopLoss=",OrderStopLoss()," PROFIT_SELL=",PROFIT_SELL," OrderTakeProfit=",OrderTakeProfit());    
                  break;     
                  case OP_SELLSTOP:    //  D E L   S E L L S T O P  //
                     if (SELLSTOP==0){ 
                        if (Real) str="DelSellStop-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderDelete(OrderTicket(),clrRed);}                      
                  break;
                  case OP_SELLLIMIT:   //  D E L   S E L L L I M I T  //
                     if (SELLLIMIT==0){
                        if (Real) str="DelSellLimit-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderDelete(OrderTicket(),clrRed);}    
                  break;   
                  case OP_BUY: //  C L O S E     B U Y 
                     if (BUY==0){
                        if (Real) str="CloseBUY-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderClose(OrderTicket(),OrderLots(),Bid,3,clrBlue);       
                        break;}    
                              //   M O D I F Y    B U Y  
                     STOP_BUY  =N5(STOP_BUY);   // нормализация до
                     PROFIT_BUY=N5(PROFIT_BUY); // пятого знака
                     if (EQUAL(STOP_BUY,OrderStopLoss()) && EQUAL(PROFIT_BUY,OrderTakeProfit()))   break; // новые значения должны отличаться от текущих охтябы на 10 пунктов
                     if (Bid-STOP_BUY<=Spred || PROFIT_BUY-Bid<=Spred) break; // корректность новых значений 
                     if (Real){ 
                        if (!EQUAL(STOP_BUY,    OrderStopLoss()))    str="ModifyBuyStp-"+S4(OrderStopLoss())+"/"+S4(STOP_BUY);
                        if (!EQUAL(PROFIT_BUY,  OrderTakeProfit()))  str="ModifyBuyPrf-"+S4(OrderTakeProfit())+"/"+S4(PROFIT_BUY);}
                     TerminalHold(60);    make=OrderModify(OrderTicket(), OrderOpenPrice(), STOP_BUY, PROFIT_BUY,OrderExpiration(),clrBlue);   //Print(" ord=",ord," STOP_BUY=",STOP_BUY," OrderStopLoss=",OrderStopLoss()," PROFIT_BUY=",PROFIT_BUY," OrderTakeProfit=",OrderTakeProfit());      
                  break;
                  case OP_BUYSTOP:  //  D E L  B U Y S T O P  
                     if (BUYSTOP==0){
                        if (Real) str="DelBuyStop-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderDelete(OrderTicket(),clrBlue);}                      
                  break;
                  case OP_BUYLIMIT: //  D E L  B U Y L I M I T  
                     if (BUYLIMIT==0){
                        if (Real) str="DelBuyLimit-"+S4(OrderOpenPrice());
                        TerminalHold(60); make=OrderDelete(OrderTicket(),clrBlue);}                      
                  break;
                  }  //Print("End: Order=",ORDER_TO_STR(Order)," i=",i," Orders=",Orders," make=",make);      
               if (Real && str!="") {Report(str);  str="";}
               if (!make){
                  Print("ERROR1 in Modyfy",ORDER_TO_STR(Order)," Ticket=",OrderTicket());
                  ERROR_CHECK("Modify");
                  try++;  if (try>3) {Print("ERROR2 in Modyfy try=",try); return;}             
            }  }  }//while(repeat)
         if (Orders!=OrdersTotal()) {ReSelect=true; break;} // при ошибках или изменении кол-ва ордеров надо заново перебирать ордера (выходим из цикла "for"), т.к. номера ордеров поменялись
         }//if (OrderSelect      
      }//while(ReSelect)     
   TerminalFree();
   Modify=false; // флаг необходимости модификации (удаления) ордеров
   if (Real) ERROR_CHECK("ORDERS_MODIFY");  
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool EQUAL(double One, double Two){// совпадение значений с точностью до 10 тиков
   if (MathAbs(One-Two)<10*Point) return true; else return false;
   }        
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void ORDER_CHECK(){   // ПАРАМЕТРЫ ОТКРЫТЫХ И ОТЛОЖЕННЫХ ПОЗ
   BUY=0; BUYSTOP=0; BUYLIMIT=0; SELL=0; SELLSTOP=0; SELLLIMIT=0;  STOP_BUY=0; PROFIT_BUY=0; STOP_SELL=0; PROFIT_SELL=0;
   for (int i=0; i<OrdersTotal(); i++){ 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true && OrderMagicNumber()==Magic){
         if (OrderType()==6) continue; // ролловеры не записываем
         switch(OrderType()){
            case OP_BUYSTOP:  BUYSTOP=(float)OrderOpenPrice();  STOP_BUY=(float)OrderStopLoss();  PROFIT_BUY=(float)OrderTakeProfit();   BuyTime=OrderOpenTime();    break;
            case OP_BUYLIMIT: BUYLIMIT=(float)OrderOpenPrice(); STOP_BUY=(float)OrderStopLoss();  PROFIT_BUY=(float)OrderTakeProfit();   BuyTime=OrderOpenTime();    break;
            case OP_BUY:      BUY=(float)OrderOpenPrice();      STOP_BUY=(float)OrderStopLoss();  PROFIT_BUY=(float)OrderTakeProfit();   BuyTime=OrderOpenTime();    break;
            case OP_SELLSTOP: SELLSTOP=(float)OrderOpenPrice(); STOP_SELL=(float)OrderStopLoss(); PROFIT_SELL=(float)OrderTakeProfit();  SellTime=OrderOpenTime();   break;
            case OP_SELLLIMIT:SELLLIMIT=(float)OrderOpenPrice();STOP_SELL=(float)OrderStopLoss(); PROFIT_SELL=(float)OrderTakeProfit();  SellTime=OrderOpenTime();   break;
            case OP_SELL:     SELL=(float)OrderOpenPrice();     STOP_SELL=(float)OrderStopLoss(); PROFIT_SELL=(float)OrderTakeProfit();  SellTime=OrderOpenTime();   break;
   }  }  }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void MARKET_INFO(){// обновление Spred и StopLevel
   RefreshRates();
   Spred    =float((MarketInfo(Symbol(),MODE_SPREAD))*Point);
   StopLevel=float((MarketInfo(Symbol(),MODE_STOPLEVEL)+1)*Point); // 
   }      
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//void BALANCE_CHECK(){// Проверка  состояния баланса для изменения лота текущих отложников  (При инвестировании или после крупных сделок)
//   if (!Real) return; 
//   double BalanceChange=(GlobalVariableGet("LastBalance")-AccountBalance())*100/AccountBalance();
//   if (MathAbs(BalanceChange)<10  || AccountBalance()<1) return; // баланс изменился свыше 10%
//   // тянем жребий, кому выставлять ордера 
//   Print(Magic,": BalanceCheck(): Баланс изменился на ", BalanceChange, "%, пробуем захватить терминал для пересчета ордеров"); 
//   GlobalVariableSetOnCondition("CanTrade",Magic,0); // попытка захватат флага доступа к терминалу    
//   Sleep(100);
//   if (GlobalVariableGet("CanTrade")!=Magic) return;// первыми захватили флаг доступа к терминалу
//   Print(Magic,": BalanceCheck(): Захватили терминал для пересчета ордеров");
//   if (BalanceChange>0) str="increase"; else str="decrease";
//   Report("Balance "+str+" on "+ S0(MathAbs(BalanceChange)) +"%, recount orders");
//   GlobalVariableSet("LastBalance",AccountBalance()); Sleep(100);
//   GlobalVariableSet("CanTrade",0); // сбрасываем глобал
//   if (Real) ERROR_CHECK("BALANCE_CHECK");  
//   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
string ORDER_TO_STR(int Type){ 
   switch(Type){
      case 0:  return ("BUY"); 
      case 1:  return ("SELL");
      case 2:  return ("BUYLIMIT"); 
      case 3:  return ("SELLLIMIT");
      case 4:  return ("BUYSTOP");
      case 5:  return ("SELLSTOP");
      case 10: return ("SetBUY");
      case 11: return ("SetSELL");
      default: return ("---");
   }  }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   


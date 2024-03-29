float MM(double Stop, float risk, string SYM){// ММ ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (risk==0) {Lot=0;   return(Lot);} 
   float    MinLot =float(MarketInfo(SYM,MODE_MINLOT)), // CurDD - глобальная, т.к. передается в ф. TradeHistoryWrite() 
            MaxLot =float(MarketInfo(SYM,MODE_MAXLOT));        
   if (risk>MaxRisk) risk=float(MaxRisk*0.95);// проверка на ошибочное значение риска
   CurDD=CUR_DD(SYM); // последняя незакрытая просадка эксперта (не максимальной) 
   if (Stop<=0)                           {REPORT("MM: Stop<=0!");    return (-MinLot);}
   if (MarketInfo(SYM,MODE_POINT)<=0)     {REPORT("MM: POINT<=0!");   return (-MinLot);}
   if (MarketInfo(SYM,MODE_TICKVALUE)<=0) {REPORT("MM: TICKVAL<0!");  return (-MinLot);}
   if (CurDD>HistDD)                      {REPORT("MM: CurDD>HistDD!: "+S0(CurDD)+">"+S0(HistDD)); return (0);}
   // см.Расчет залога http://www.alpari.ru/ru/help/forex/?tab=1&slider=margins#margin1
   // Margin = Contract*Lot/Leverage = 100000*Lot/100  
   // MaxLotForMargin=NormalizeDouble(AccountFreeMargin()/MarketInfo(SYM,MODE_MARGINREQUIRED),LotDigits) // Макс. кол-во лотов для текущей маржи
   Lot = float(NormalizeDouble(DEPO(MM,SYM)*risk*0.01 / (Stop/MarketInfo(SYM,MODE_POINT)*MarketInfo(SYM,MODE_TICKVALUE)), LotDigits)); // размер стопа через Стоимость пункта. См. калькулятор трейдера http://www.alpari.ru/ru/calculator/
   if (Lot<MinLot) Lot=MinLot;   // Проверка на соответствие условиям ДЦ
   if (Lot>MaxLot) Lot=MaxLot; //Print("risk=",risk," RiskChecker=",RiskChecker(Lot,Stop));
   if (CHECK_RISK(Lot,Stop,SYM)>MaxRisk) {REPORT("MM: RiskChecker="+DoubleToStr(CHECK_RISK(Lot,Stop,SYM),2)+"% - Trade Disable!"); return (-MinLot);}// Не позволяем превышать риск MaxRisk%! 
   return (Lot);
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
float CHECK_RISK(double lot, double Stop, string SYM){// Проверим, какому риску будет соответствовать расчитанный Лот:  
   if (MarketInfo(SYM,MODE_TICKVALUE)<=0) {REPORT("RiskChecker(): "+SYM+" TickValue<0"); return (100);}
   if (MarketInfo(SYM,MODE_POINT)<=0)     {REPORT("RiskChecker(): POINT<=0!"); return (-1);}
   return (float(NormalizeDouble(lot * (Stop/MarketInfo(SYM,MODE_POINT)*MarketInfo(SYM,MODE_TICKVALUE)) / AccountBalance()*100,2)));
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
float CUR_DD(string SYM){// расчет последней незакрытой просадки эксперта (не максимальной) 
   float MaxExpertProfit=LastTestDD, ExpertProfit=0, profit=0;
   for(int Ord=0; Ord<OrdersHistoryTotal(); Ord++){// находим среди всей истории сделок эксперта ПОСЛЕДНЮЮ просадку и измеряем ее от макушки баланса до текущего значения (Не до минимального!)
      if (OrderSelect(Ord,SELECT_BY_POS,MODE_HISTORY)==true && OrderMagicNumber()==Magic && OrderCloseTime()>TestEndTime){
         profit=float((OrderProfit()+OrderSwap()+OrderCommission())/OrderLots()/MarketInfo(SYM,MODE_TICKVALUE)*0.1); // прибыль от выбранного ордера в пунктах
         if (profit!=0){ 
            ExpertProfit+=profit; // текущая прибыль эксперта
            if (ExpertProfit>MaxExpertProfit) MaxExpertProfit=ExpertProfit; // Print(" CurDD(): magic=",Magic," profit=",profit," MaxExpertProfit=",MaxExpertProfit," ExpertProfit=",ExpertProfit," OrderCloseTime()=",TimeToStr(OrderCloseTime(),TIME_SECONDS));// максимальная прибыль эксперта                  
      }  }  } 
   return float(MaxExpertProfit-ExpertProfit); // значение последней незакрытой просадки эксперта (не максимальной)
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
float DEPO(char TypeMM, string SYM){ // Расчет части депозита, от которой берется процент для совершения сделки  
   double Depo, ExpMaxBalance=AccountBalance(); // индивидуальная переменная, должна храниться в файле с временными параметрами
   switch (TypeMM){
      case 1: // Классический Антимартингейл
         Depo=AccountBalance();         
      break; 
      case 2: // уменьшение риска эксперта пропорционально глубине его текущей просадки
          if (HistDD>0) Depo=AccountBalance()*(HistDD-CurDD)/HistDD;  
          else          Depo=AccountBalance();
      break; 
      case 3: // Индивидуальный баланс. Фиксируется начало индивидуальной просадки и риск начинает увеличиваться до выхода из нее за счет прироста баланса от прибыльных систем. 
         // Но не превышает установленного риска для данной системы, если баланс продолжает снижаться.  
         if (CUR_DD(SYM)==0 && AccountBalance()>ExpMaxBalance) ExpMaxBalance=AccountBalance(); // Лот увеличивается только если система в плюсе и общий баланс растет. Т.е. если другие системы не сливают. 
         Depo=MathMin(ExpMaxBalance,AccountBalance()); // Не превышаем установленного риска
      break; 
      case 4: // Процент от общего максимально достигнутого баланса.
         // При просадке экспертов лот не понижается (риск растет вплоть до 10%). 
         // Выход из просадки осуществляется с большей скоростью за счет растущего баланса от друхих систем. 
         // При этом оказывается значителььное влияние убыточных систем на общий баланс. 
         Depo=GlobalVariableGet("MaxBalance");
         if (AccountBalance()>Depo) Depo=AccountBalance();
         GlobalVariableSet("MaxBalance",Depo);
      break;
      default: Depo=AccountBalance(); // Классический Антимартингейл
      }
   return (float(Depo));
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

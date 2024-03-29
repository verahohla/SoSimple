void REPORT(string Missage){ // собираем все сообщения экспертов в одну кучу ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return; 
   if (Missage=="") return;
   if (history=="") history=Missage;
   else     history=history+"\n "+Missage; // без разделителя ";" при записи в RestoreFileName (MailSender()) все сообщения лепятся в одну строку.
   Print("REPORT of ",Magic,": ",Missage);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void SAVE_HISTORY(){ // ПИШЕМ СОБРАННЫЕ СООБЩЕНИЯ history в один общий файл Reports.csv 
   if (history=="") return; 
   string   FileName="Reports.csv"; 
   datetime StartWaiting=TimeLocal(); 
   // ожидание освобождения общего фала со всеми репортами
   while (GlobalVariableGet("RepFile")!=Magic){ // 
      if (GlobalVariableGet("RepFile")==0) GlobalVariableSet("RepFile",Magic);  
      Sleep((BackTest+1)*100); // для разгрузки процессора   
      if (TimeLocal()-StartWaiting>300){ // прождали 5мин, насильно открываем файл, т.к. что-то значит не в порядке
         REPORT("ReportsToFile: Expert "+DoubleToStr(GlobalVariableGet("RepFile"),0)+"  hold Reports.csv more than "+DoubleToStr((TimeLocal()-StartWaiting),0)+" seconds! Try to set own flag"); // докладываем о занятом торговом потоке
         StartWaiting=TimeLocal(); // засекаем заново компьютерное время
         GlobalVariableSet("RepFile",0); // сбрасываем Magic, чтобы попытаться захватить
      }  }
   if (GlobalVariableGet("RepFile")!=Magic) return; // так и не вышло захватить файл   
   // Файл освободился, пишем в него репорты всех экспертов текущего графика
   int File=FileOpen(FileName, FILE_READ | FILE_WRITE);
   if (File<0) {MessageBox("ReportToFile: Can't open "+FileName+" to write data!"); return;}
   FileSeek (File,0,SEEK_END);     // перемещаемся в конец
   FileWrite(File, history);
   FileClose(File);
   GlobalVariableSet("RepFile",0);
   history="";
   ERROR_CHECK("SAVE_HISTORY");
   }
   // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void SAVE_GLOBALS(){// Сохранение индивидуальных переменных и логов 
   string FileName=Company+"_"+AccountCurrency()+"_"+DoubleToStr(Magic,0)+".csv";
   int File=FileOpen(FileName, FILE_READ|FILE_WRITE);  
   if (File<0) {REPORT("IndividualSaving(): Can't open file "+FileName+"! for parameters saving"); return;}
   FileWrite (File, BarTime, RevBUY, RevSELL, ExpMemory); // сохраняем глобальные переменные в файл
   if (history!=""){
      FileSeek (File,0,SEEK_END); 
      FileWrite(File,  TIME(TimeCurrent())+";"+history); 
      //Print(" REPORT ",Magic,": ",history);
      }
   FileClose(File); 
   ERROR_CHECK("SAVE_GLOBALS");
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void CHECK_RESULT(){// ДОКЛАД О ПОСЛЕДНИХ СДЕЛКАХ
   float RiskTemp=Risk;
   datetime  OrdMemory=0;
   int  Ord=0, Orders=0; // Print(Magic,": IndividualSaving(), сохраняем RevBUY и RevSELL всех экспертов с графика ",Symbol(),Period());
   float SMaxBal=0, SDD=0, SCurDD=0, PF=555, SPF=555, SRF=555, Plus=0, Minus=0, SPlus=0, SMinus=0, profit=0, SProfit=0, ExpPrf=0, SExpPrf=0, CheckRisk=0;
   for (Ord=0; Ord<OrdersHistoryTotal(); Ord++){// перебераем историю сделок эксперта
      if (OrderSelect(Ord,SELECT_BY_POS,MODE_HISTORY)==true && OrderMagicNumber()==Magic && OrderCloseTime()>0){
         profit=float(OrderProfit()+OrderSwap()+OrderCommission()); // прибыль от выбранного ордера в валюте депозита 
         if (profit!=0){ // попался закрытый ордер (не Открытый и не Отложенный) 
            Orders++;
            SProfit=profit; // результат в валюте
            if (OrderLots()>0) profit=float(profit/OrderLots()/MarketInfo(Symbol(),MODE_TICKVALUE)*0.1); // результат в пунктах
            SExpPrf+=SProfit;
            ExpPrf +=profit; 
            if ( profit>0)  Plus+= profit; else  Minus-= profit;
            if (SProfit>0) SPlus+=SProfit; else SMinus-=SProfit;
            if (SExpPrf>SMaxBal) SMaxBal=SExpPrf;
            else if (SMaxBal-SExpPrf>SDD) SDD=SMaxBal-SExpPrf;
            OrdMemory=OrderCloseTime(); // время последней сделки 
      }  }  }
   if (OrdMemory==ExpMemory) return;// если время последней сделки обновилось,
   // Print("CHECK_RESULT(): ExpMemory=",ExpMemory," OrdMemory=",OrdMemory," Orders=",Orders);
   ExpMemory=OrdMemory;
   SCurDD=SMaxBal-SExpPrf; // текущая просадка в $
   if (SDD>0) SRF=SMaxBal/SDD;  // фактор восстановления
   float Stop=float(100*Point); // возьмем любой стоп для расчета риска
   Lot = MM(Stop,Risk,Symbol());   // расчет пробного лота для стопа в 100п
   CheckRisk=CHECK_RISK(Lot,Stop,Symbol()); //расчет текущего риска в связи с просадкой
   if ( Minus>0)  PF= Plus/ Minus;
   if (SMinus>0) SPF=SPlus/SMinus;
   string ExpParams,RR;
   if (SProfit>0) ExpParams=ExpParams+" WIN="; else ExpParams=ExpParams+" LOSS="; // запомним значение баланса на случай, если этот лось для данного эксперта - начало ДД (пригодится потом в ММ)
   if (Risk>0) RR=DoubleToStr(CheckRisk/Risk,2); else RR=DoubleToStr(0,2);
   ExpParams=ExpParams+DoubleToStr(SProfit*100/AccountBalance(),1)+"% "+
      "\r Prf="+DoubleToStr(ExpPrf,0)+"pips Risk="+DoubleToStr(Risk,1)+ // 
      "\r RF="+DoubleToStr(SRF,1)+" PF="+DoubleToStr(PF,1)+" Trades="+ DoubleToStr(Orders,0)+    // 
      "\n HistDD/CurDD="+DoubleToStr(HistDD,0)+"/"+DoubleToStr(CUR_DD(Symbol()),0);    //
   REPORT(ExpParams); // шлем миссагу
   ERROR_CHECK("CHECK_RESULT");     
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void MAIL_SEND(){ // отправляем мыло из файла Reports.csv с отчетами
   if (IsTesting() || IsOptimization()) return;
   if (GlobalVariableGet("MailTime")==Hour()) return; // кто-то уже отправил мыло в этот час  
   GlobalVariableSet("MailTime",Hour()); // флаг отправки "мыла" 
   while (TimeLocal()-GlobalVariableTime("CanTrade")<60) Sleep(1000);// ждем, пока после последнего обращения к глобалу пройдет больше минуты, т.е. все отчитались
   float MaxBal=0, MinBal=0, AccDD=0, AccCDD=0, AccPF=555, Plus=0, Minus=0, AccRF=555, AccPrf=0,  profit=0, RollPlus=0, RollMinus=0, LastHourProfit=0;
   int  Ord, Orders=0, LastOrderTime=0;
   // Захват возможности отправки мыла
   datetime StartWaiting=TimeLocal();     
   while (GlobalVariableGet("RepFile")!=Magic){ // через глобал RepFile, открывающий доступ к файлу Reports.csv
      Sleep(1000); // 
      if (GlobalVariableGet("RepFile")==0) GlobalVariableSet("RepFile",Magic);    
      if (TimeLocal()-StartWaiting>300){ // прождали 5мин, насильно открываем файл, т.к. что-то значит не в порядке
         REPORT("MAIL_SEND: Expert "+DoubleToStr(GlobalVariableGet("RepFile"),0)+"  hold ReportFile more then "+DoubleToStr((TimeLocal()-StartWaiting),0)+" seconds! Try to set own flag"); // докладываем о занятом торговом потоке
         StartWaiting=TimeLocal();  
         GlobalVariableSet("RepFile",0); // сбрасываем Magic, чтобы попытаться захватить
      }  }
   MATLAB_LOG();
   if (GlobalVariableGet("LastOrderTime")==0){// если в первый раз LastOrderTime равно нулю
      LastOrderTime=int(iTime(NULL,60,1)); // берем значение времени прошлого бара
      Print(Magic,": GlobalVariable(LastOrderTime)=0, set it to last bar time ", TimeToStr(LastOrderTime,TIME_DATE|TIME_MINUTES));
      GlobalVariableSet("LastOrderTime",LastOrderTime); // и сохраняем в глобал
      }
   for(Ord=0; Ord<OrdersHistoryTotal(); Ord++){// перебераем историю сделок эксперта
      if (OrderSelect(Ord,SELECT_BY_POS,MODE_HISTORY)==true){ // история всех экспертов
         profit=float(OrderProfit()+OrderSwap()+OrderCommission()); // прибыль от выбранного ордера в валюте депозита 
         if (profit!=0){
            if (OrderOpenPrice()==0 && iTime(NULL,60,0)-OrderOpenTime()<3900){// Ордер без цены открытия, т.е. инвестиции. За прошлый час с небольшим запасом в 5мин = 3600с + 300с
               if (profit>0) RollPlus +=profit;   
               else RollMinus+=profit;
               }
            if (OrderOpenPrice()>0){ // ордер открыт экспертом
               Orders++;   // подсчет показателей работы эксперта
               AccPrf+=profit; 
               if (profit>0) Plus+=profit; else Minus-=profit;
               if (AccPrf>MaxBal) {MaxBal=AccPrf; MinBal=MaxBal;}
               if (AccPrf<MinBal) {MinBal=AccPrf; if (MaxBal-MinBal>AccDD) AccDD=MaxBal-MinBal;}   // DD
               if (OrderCloseTime()>GlobalVariableGet("LastOrderTime")){ // время закрытия ордера больше проверенного на прошлом баре (свежий значит)
                  if (OrderCloseTime()>LastOrderTime) LastOrderTime=int(OrderCloseTime()); // ищем самый поздний ордер, чтобы потом его сохранить
                  LastHourProfit+=profit; // суммируем всю прибыль за последний час
      }  }  }  }  }
   // Суммарный риск открытых позиций и отложенных ордеров
   float OpenOrdMargNeed=0, LongRisk=0, ShortRisk=0, MargNeed=0, PerCent=0;
   for(Ord=0; Ord<OrdersTotal(); Ord++){// перебераем все открытые и отложенные ордера всех экспертов счета Ролловеры (OrderType=6) туда не пишем.
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)==true){
         if (OrderType()==6) continue; // ролловеры не нужны
         if (OrderType()<2) //маржа открытых поз
            OpenOrdMargNeed+=float(OrderLots()*MarketInfo(OrderSymbol(),MODE_MARGINREQUIRED)); // кол-во маржи, необходимой для открытия лотов
         else
            MargNeed+=float(OrderLots()*MarketInfo(OrderSymbol(),MODE_MARGINREQUIRED));//маржа отложников
            if (OrderType()==0 || OrderType()==2 || OrderType()==4)
               LongRisk+=CHECK_RISK(float(OrderLots()), float(MathAbs(OrderOpenPrice()-OrderStopLoss())), OrderSymbol());
            if (OrderType()==1 || OrderType()==3 || OrderType()==5)
               ShortRisk+=CHECK_RISK(float(OrderLots()), float(MathAbs(OrderOpenPrice()-OrderStopLoss())), OrderSymbol());   
         }  }  // теперь массив ORD содержит список всех открытых, отложенных и предстоящих установке ордеров   
   if (LastOrderTime>0) GlobalVariableSet("LastOrderTime",LastOrderTime);// сохраняем время самого позднего ордера для текущего бара   
   AccCDD=MaxBal-AccPrf;
   if (AccDD>0) AccRF=AccPrf/AccDD;
   if (Minus>0) AccPF=Plus/Minus;
  string AccountParams= "\n"+//"\nAccountParams:"+
   "\n  RISK: Long+Short = "+DoubleToStr(LongRisk,1)+"%+"+DoubleToStr(ShortRisk,1)+"%"+
   "\n  MARGIN: Open+Depend="+DoubleToStr(OpenOrdMargNeed/AccountFreeMargin()*100,0)+"%+"+DoubleToStr(MargNeed/AccountFreeMargin()*100,0)+"%"+
   "\n  EQUITY="+DoubleToStr(AccountEquity(),0)+" FreeMargin="+DoubleToStr(AccountFreeMargin(),0)+
   "\n  MarketInfo "+Symbol()+":"+
   "\nSpread="+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0)+
   "\nSwap/StpLev = "+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPLONG)+MarketInfo(Symbol(),MODE_SWAPSHORT),1) + "/" + DoubleToStr(MarketInfo(Symbol(),MODE_STOPLEVEL),1)+
   "\n"+ExpertName;   
   string CurPrf, Agr="";
   if (Aggress>1) Agr="x"+DoubleToStr(Aggress,0);
   if (AccountProfit()>0) CurPrf="+"+DoubleToStr(AccountProfit()*100/AccountBalance(),1)+"%"; // текущая незакрытая прибыль в процентах
   if (AccountProfit()<0) CurPrf=    DoubleToStr(AccountProfit()*100/AccountBalance(),1)+"%";
   CurPrf=AccountCurrency()+Agr+"  "+MoneyToStr(AccountBalance())+CurPrf;
   string Warning, RollList, MailText;
   if ((RollPlus-RollMinus)!=0){
      CurPrf=CurPrf+" Roll="+MoneyToStr(RollPlus+RollMinus);// были роловеры
      if (RollPlus>0)  RollList=DoubleToStr(RollPlus,0);
      if (RollMinus<0) RollList=RollList+DoubleToStr(RollMinus,0);
      MailText=MailText+"\n"+"Roll="+RollList+AccountCurrency(); 
      }
   int shift=iBarShift(NULL,0,BarTime,FALSE)-iBarShift(NULL,0,LastBarTime,FALSE); Print("MAIL_SEND():",Magic," BarTime=",TimeToStr(BarTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS)," LastBarTime=",TimeToStr(LastBarTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS)," shift=",shift);
   if (shift>1) // проверка пропущенных баров: разница с прошлым баром (в барах)   
      REPORT("Missed Bars="+DoubleToStr(shift-1,0)+"!,  LastOnLine="+TimeToStr(LastBarTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+",  CurTime="+TimeToStr(BarTime,TIME_MINUTES|TIME_SECONDS));   
   if (LastHourProfit>0){
      PerCent=LastHourProfit/((float)AccountBalance()-LastHourProfit)*100;
      CurPrf=CurPrf+" Win="+DoubleToStr(PerCent,2)+"%";
      }
   if (LastHourProfit<0){
      PerCent=LastHourProfit/((float)AccountBalance()+LastHourProfit)*100;
      CurPrf=CurPrf+" Loss="+DoubleToStr(PerCent,2)+"%"; //
      }
   // открытие файла Reports.csv
   string FileName="Reports.csv";   
   int File=FileOpen(FileName, FILE_READ);  
   if (File>0){
      while (!FileIsEnding(File)) MailText=MailText+"\n"+ FileReadString(File);
      if (StringFind(MailText,"!",0)>0) Warning="WARNING"; // если были предупреждения, выносим их в заголовок мыла
      FileClose(File); 
      }
   SendMail(CurPrf, ORDERS_INF(Warning) + MailText + AccountParams); 
   FileDelete(FileName);
   GlobalVariableSet("RepFile",0);
   Print("MailText: ",MailText," \n \n \n"); 
   ERROR_CHECK("MAIL_SEND");  
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
string MoneyToStr(double Balance){
   if (Balance<1000)       return(DoubleToStr(Balance,0));
   if (Balance<10000)      return(DoubleToStr(Balance/1000,1)+"K");  
   if (Balance<1000000)    return(DoubleToStr(Balance/1000,0)+"K"); 
   if (Balance<10000000)   return(DoubleToStr(Balance/1000000,1)+"M"); 
   return (DoubleToStr(Balance/1000000,0)+"M"); 
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
string ORDERS_INF(string Warning){ // инфа о текущих рыночных характеристиках и профите 
   string MarketOrders=TIME(TimeCurrent())+" "+Company+" "+Warning;
   float POINT, TakeProfit;
   int Ord;
   if (OrdersTotal()==0) return (MarketOrders);
   for(Ord=0; Ord<OrdersTotal(); Ord++){// проверка отложенных ордеров 
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)!=true) continue;
      if (OrderType()==6) continue;
      SYMBOL=OrderSymbol(); // для ф.CHECK_RISK нужен символ ордера
      POINT =(float)MarketInfo(SYMBOL,MODE_POINT); 
      MARKET_UPDATE(SYMBOL);
      if (OrderTakeProfit()==0) TakeProfit=(float)OrderOpenPrice(); else TakeProfit=(float)OrderTakeProfit(); 
      if (OrderType()==OP_BUYSTOP)  {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BS/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderStopLoss()-OrderOpenPrice()),SYMBOL),1)+"%";}
      if (OrderType()==OP_SELLSTOP) {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SS/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderOpenPrice()-OrderStopLoss()),SYMBOL),1)+"%";} 
      if (OrderType()==OP_BUYLIMIT) {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BL/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderStopLoss()-OrderOpenPrice()),SYMBOL),1)+"%";}
      if (OrderType()==OP_SELLLIMIT){MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SL/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderOpenPrice()-OrderStopLoss()),SYMBOL),1)+"%";}  
      if (OrderType()==OP_BUY)      {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BUY/" +DoubleToStr((BID-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderStopLoss()-OrderOpenPrice()),SYMBOL),1)+"%";}   // профит в пунктах / закрепленный стопом профит в пунктах х лот    
      if (OrderType()==OP_SELL)     {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SELL/"+DoubleToStr((OrderOpenPrice()-ASK)/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(CHECK_RISK((float)OrderLots(),float(OrderOpenPrice()-OrderStopLoss()),SYMBOL),1)+"%";}   // профит в пунктах / закрепленный стопом профит в пунктах х лот 
      }   
   return (MarketOrders);
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
#define  EXPERTS_LIM  100    // максимальное кол-во проверяемых экспертов
#define  ORDERS_LIM   400   // максимальное кол-во сделок одного эксперта за последние два года

struct AllExperts{  //  C Т Р У К Т У Р А   P I C
   int      magic;
   short    trade[ORDERS_LIM];
   datetime time[ORDERS_LIM];
   float    tickval;
   };
AllExperts Expert[EXPERTS_LIM];   
uchar Experts=0;   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void MATLAB_LOG (){// Сохранение истории сделок в файл 
   short profit=0;
   short  TradeCnt[EXPERTS_LIM];
   string FileName; 
   ArrayInitialize(TradeCnt,0);
   if (Real) {FileName="MatLab"+AccountCurrency()+".csv"; FileDelete(FileName);} // каждый час создаем новый файл
   else      {FileName="MatLabTest.csv";}//  
   int File=FileOpen(FileName, FILE_READ | FILE_WRITE); 
   if (File<0) {Alert("MatLabLog(): Can not open file "+ FileName+"! for history saving"); return;}
   FileWrite(File, "Magic","TickVal","Risk","Deal/Time..."); // прописываем в первую строку названия столбцов
   for(int i=0; i<OrdersHistoryTotal(); i++){// перебераем историю сделок эксперта
      if (OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==false || OrderMagicNumber()==0 || OrderCloseTime()==0 || OrderProfit()==0) continue;
     //if (Time[0]-OrderCloseTime()>34560000) continue; // Пропускаем все ордера старше двух лет, чтобы не переполнять масссив. Для гарфического анализа они не пригодятся.  
      uchar e=0;
      EXPERTS_PARAMS(e, OrderMagicNumber(), MarketInfo(OrderSymbol(),MODE_TICKVALUE));
      Expert[e].trade[TradeCnt[e]]=short((OrderProfit()+OrderSwap()+OrderCommission())*100/OrderLots()/MarketInfo(OrderSymbol(),MODE_TICKVALUE)*0.1);
      Expert[e].time[TradeCnt[e]]=OrderCloseTime();  //Print(" TrdCnt[",e,"]=",TradeCnt[e]," trade=",Expert[e].trade[TradeCnt[e]]," time=",Expert[e].time[TradeCnt[e]]);
      TradeCnt[e]++; 
      }  
   //Print("Experts=",Experts);     
   for (uchar e=0; e<=Experts; e++){
      short order=1; // Alert("magic[",e,"]=",magic[e]);
      FileSeek (File,0,SEEK_END); // перемещаемся в конец файла MatLabTest.csv
      FileWrite(File, DoubleToStr(Expert[e].magic,0)+";"+DoubleToStr(Expert[e].tickval,5)+";"+"0.1"); // прописываем в первую ячейку magic,
      //Print("TradeCnt[e]=",TradeCnt[e]);
      for (short t=0; t<=TradeCnt[e]; t++){ //
         FileSeek (File,-2,SEEK_END); // потом дописываем
         FileWrite(File,  ""    , DoubleToStr(Expert[e].trade[t],0)+"/"+TimeToStr(Expert[e].time[t],TIME_DATE|TIME_MINUTES));    // ежедневные профиты/время сделки из созданного массива    
      }  }
   FileClose(File); 
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void EXPERTS_PARAMS(uchar& ExpCnt, int ExpMagic, double ExpTickVal){// создание массива параметров для всех экспертов
   for (ExpCnt=0; ExpCnt<EXPERTS_LIM; ExpCnt++){
      if (Expert[ExpCnt].magic==ExpMagic) break;
      if (Expert[ExpCnt].magic==0){
         Expert[ExpCnt].magic=ExpMagic;
         Experts=ExpCnt;
         break;
         }
      if (ExpCnt>=EXPERTS_LIM) {Alert("WARNING!!! Experts>",EXPERTS_LIM, " Can't create MatLabLog File"); }   
      }  
   Expert[ExpCnt].tickval=(float)ExpTickVal;
   }    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void LOAD_GLOBALS(int mgc){ // Восстановление на реале глобальных переменных // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return;
   datetime StartWaiting=TimeLocal();
   int File=-1;  
   string FileName=Company+"_"+AccountCurrency()+"_"+DoubleToStr(mgc,0)+".csv";
   while (File<0){ // ждем, пока не откроется, т.к. без этих данных торговлю лучше не начинать
      Sleep(100); // для разгрузки процессора
      File=FileOpen(FileName, FILE_READ | FILE_WRITE);  
      if (TimeLocal()-StartWaiting>30){
         REPORT("RealParamRestore(): ERROR! Can not open file "+FileName); 
         MessageBox("RealParamRestore(): ERROR! Can't open file "+FileName);
         StartWaiting=TimeLocal();
      }  }
   if (FileReadString(File)==""){ // файл пустой, заполним
      BarTime=0; RevBUY=0;  RevSELL=0; ExpMemory=0;
      for (int i=0; i<15; i++) FileWrite(File,"               ");// создаем несколько пустых строчек в начале файла для последующей записи в них глобальных переменных
      FileWrite(File,"BarTime","RevBUY","RevSELL","ExpMemory"); // ниже заголовок для глобальных переменных
      FileWrite(File,"_______________________________"); // разделялка
      //FileWrite(RestoreFile,"E x p e r t     H i s t o r y :");
      Alert("Create file ",FileName," to save individual history"); 
      GlobalVariableSet("Mem"+DoubleToStr(mgc,0), 0);
      }
   else{ // читаем из файла переменные
      FileSeek(File,0,SEEK_SET);     // перемещаемся в начало   
      BarTime  =StringToTime(FileReadString(File));  // Преобразование строки, содержащей время в формате "yyyy.mm.dd [hh:mi]", в число типа datetime.  
      RevBUY   =float(StrToDouble(FileReadString(File))); 
      RevSELL  =float(StrToDouble(FileReadString(File)));
      ExpMemory=StringToTime(FileReadString(File));
      GlobalVariableSet("Mem"+DoubleToStr(mgc,0), ExpMemory);  
      }
   FileClose(File);
   ERROR_CHECK("LOAD_GLOBALS");
   }    
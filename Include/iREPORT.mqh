void Report(string Missage){ // собираем все сообщения экспертов в одну кучу ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return; 
   if (Missage=="") return;
   history=history+"\r"+DoubleToStr(Magic,0)+"/"+TimeToString(TimeCurrent(),TIME_MINUTES)+"  "+Missage+";"; // без разделителя ";" при записи в FileName (MailSender()) все сообщения лепятся в одну строку.
   Print(" REPORT ",ExpID,": ",Missage);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void SAVE_HISTORY(){ // ПИШЕМ СОБРАННЫЕ СООБЩЕНИЯ history в один общий файл Reports.csv 
   if (history=="") return; 
   datetime StartWaiting=TimeLocal(); 
   // ожидание освобождения общего фала со всеми репортами
   while (GlobalVariableGet("RepFile")!=Magic){ // 
      if (GlobalVariableGet("RepFile")==0) GlobalVariableSet("RepFile",Magic);  
      Sleep(BackTest*100);  
      if (TimeLocal()-StartWaiting>300){ // прождали 5мин, насильно открываем файл, т.к. что-то значит не в порядке
         Report("SAVE_HISTORY: Expert "+DoubleToStr(GlobalVariableGet("RepFile"),0)+"  hold HistoryFile more then "+DoubleToStr((TimeLocal()-StartWaiting),0)+" seconds! Try to set own flag"); // докладываем о занятом торговом потоке
         StartWaiting=TimeLocal(); // засекаем заново компьютерное время
         GlobalVariableSet("RepFile",0); // сбрасываем Magic, чтобы попытаться захватить
      }  }
   if (GlobalVariableGet("RepFile")!=Magic) return; // так и не вышло захватить файл   
   // Файл освободился, пишем в него репорты всех экспертов текущего графика
   string FileName="Reports.csv"; 
   int File=FileOpen(FileName, FILE_READ | FILE_WRITE);
   if (File<0) {MessageBox("SAVE_HISTORY: Не могу открыть файл отчета "+FileName+" для записи проведенных на счете операций"); return;}
   FileSeek (File,0,SEEK_END);     // перемещаемся в конец
   FileWrite(File, history);
   FileClose(File);
   GlobalVariableSet("RepFile",0);
   // пишем историю в индивидуальный файл "EURUSD_23423424234.csv"
   FileName=AccountCurrency()+"_"+DoubleToStr(Magic,0)+".csv";
   File=FileOpen(FileName, FILE_READ|FILE_WRITE);  if (File<0) {Report("SAVE_HISTORY(): Can't open file "+FileName+"! for reports saving"); return;}
   FileSeek (File,0,SEEK_END); 
   FileWrite(File, TimeToString(TimeCurrent(),TIME_DATE)+" "+history); 
   FileClose(File); 
   history="";
   if (Real) ERROR_CHECK("SAVE_HISTORY");
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void SAVE_GLOBALS(){// Сохранение глобальных переменных на случай выключения программы   
   string FileName=AccountCurrency()+"_"+DoubleToStr(Magic,0)+".csv";
   int File=FileOpen(FileName, FILE_READ|FILE_WRITE);  
   if (File<0) {Report("IndividualSaving(): Can't open file "+FileName+"! for parameters saving"); return;}
   FileWrite (File, BarTime, RevBUY, RevSELL, ExpMemory); // сохраняем глобальные переменные в файл
   FileClose(File); 
   if (Real) ERROR_CHECK("SAVE_GLOBALS");
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void LOAD_GLOBALS(){ // ВОССТАНОВЛЕНИЕ НА РЕАЛЕ ГЛОБАЛЬНЫХ ПЕРЕМЕННЫХ 
   datetime StartWaiting=TimeLocal();
   int File=-1; 
   while (AccountCurrency()==""){ // ждем связи, т.к. без нее не будет зачения AccountCurrency() и переменные последней сессии не восстановятся, поскольку имя файла будет неверным
      Sleep(100); 
      if (TimeLocal()-StartWaiting>60) {Report("LOAD_GLOBALS(): No connection with Trade Server, wait a minute"); StartWaiting=TimeLocal();} 
      }  
   if (Real) str=AccountCurrency(); else str="Test";
   string FileName=str+"_"+DoubleToStr(Magic,0)+".csv";
   while (File<0){ // ждем, пока не откроется, т.к. без этих данных торговлю лучше не начинать
      Sleep(BackTest*10); // для разгрузки процессора
      File=FileOpen(FileName, FILE_READ | FILE_WRITE);  
      if (TimeLocal()-StartWaiting>30){
         Report("LOAD_GLOBALS(): ERROR! Can not open file "+FileName); 
         MessageBox("LOAD_GLOBALS(): Не могу открыть файл "+FileName);
         StartWaiting=TimeLocal();
      }  }
   if (FileReadString(File)==""){ // файл пустой, заполним
      int i; for (i=0; i<15; i++) FileWrite(File,"               ");// создаем несколько пустых строчек в начале файла для последующей записи в них глобальных переменных
      FileWrite(File,"BarTime","RevBUY","RevSELL","ExpMemory"); // ниже заголовок для глобальных переменных
      FileWrite(File,"_______________________________"); // разделялка
      //FileWrite(File,"E x p e r t     H i s t o r y :");
      Alert("Создаем файл ",FileName," для сохранения индивидуальных данных эксперта"); 
      }
   else{ // читаем из файла переменные
      FileSeek(File,0,SEEK_SET);     // перемещаемся в начало   
      BarTime  =datetime(StrToDouble(FileReadString(File)));    
      RevBUY   =float(StrToDouble(FileReadString(File))); 
      RevSELL  =float(StrToDouble(FileReadString(File)));
      ExpMemory=datetime(StrToDouble(FileReadString(File)));
      }
   FileClose(File);
   if (Real) ERROR_CHECK("LOAD_GLOBALS");
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void CHECK_RESULT(){// ДОКЛАД О ПОСЛЕДНИХ СДЕЛКАХ
   float RiskTemp=Risk;
   datetime  OrdMemory=0;
   int  Ord=0, Orders=0, Exp=0; // Print(Magic,": IndividualSaving(), сохраняем RevBUY и RevSELL всех экспертов с графика ",Symbol(),Period());
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
   if (OrdMemory!=ExpMemory){// если время последней сделки обновилось,
      // Print("CHECK_RESULT(): ExpMemory=",ExpMemory," OrdMemory=",OrdMemory," Orders=",Orders);
      ExpMemory=OrdMemory;
      SCurDD=SMaxBal-SExpPrf; // текущая просадка в $
      if (SDD>0) SRF=SMaxBal/SDD;  // фактор восстановления
      float Stop=float(100*Point); // возьмем любой стоп для расчета риска
      Lot = MM(Stop);   // расчет пробного лота для стопа в 100п
      CheckRisk=RiskChecker(Lot,Stop,Symbol()); //расчет текущего риска в связи с просадкой
      if ( Minus>0)  PF= Plus/ Minus;
      if (SMinus>0) SPF=SPlus/SMinus;
      string ExpParams=ExpertName+"/"+Symbol()+DoubleToStr(Period(),0);
      if (SProfit>0) ExpParams=ExpParams+" WIN="; else ExpParams=ExpParams+" LOSS="; // запомним значение баланса на случай, если этот лось для данного эксперта - начало ДД (пригодится потом в ММ)
      string RR;
      if (Risk>0) RR=DoubleToStr(CheckRisk/Risk,2); else RR=DoubleToStr(0,2);
      ExpParams=ExpParams+DoubleToStr(MathAbs(profit),0)+"("+DoubleToStr(MathAbs(SProfit),0)+AccountCurrency()+")"+
         "\n Prf="+DoubleToStr(ExpPrf,0)+" ("+DoubleToStr(SExpPrf,0)+AccountCurrency()+")"+" Risk="+DoubleToStr(Risk,1)+"x"+RR+
         "\n RF="+DoubleToStr(SRF,1)+" PF="+DoubleToStr(PF,1)+"("+DoubleToStr(SPF,1)+"$)"+" Trades="+ DoubleToStr(Orders,0)+
         "\n HistDD/CurDD="+DoubleToStr(HistDD,0)+"/"+DoubleToStr(CURRENT_DD(),0)+"("+DoubleToStr(SCurDD,0)+AccountCurrency()+")"+
         "\n LastTestDD="+DoubleToStr(LastTestDD,0)+" TestEndTime="+TimeToStr(TestEndTime,TIME_DATE)+" TickVal="+DoubleToStr(MarketInfo(Symbol(),MODE_TICKVALUE),2);    // Статистика проведенных экспером торгов
      Report(ExpParams); // шлем миссагу
      }
   if (Real) ERROR_CHECK("CHECK_RESULT");     
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void MAIL_SEND(){ // отправляем мыло из файла Reports.csv с отчетами
   if (IsTesting() || IsOptimization()) return;
   if (GlobalVariableGet("MailTime")==Hour()) return; // кто-то уже отправил мыло в этот час  
   Sleep(60000+BackTest*100); // ждем всех минуту с небольшим
   float MaxBal=0, MinBal=0, AccDD=0, AccCDD=0, AccPF=555, Plus=0, Minus=0, AccRF=555, AccPrf=0,  profit=0, RollPlus=0, RollMinus=0, LastHourProfit=0;
   int  Ord, Orders=0, LastOrderTime=0;
   // Захват возможности отправки мыла
   datetime StartWaiting=TimeLocal();     
   while (GlobalVariableGet("RepFile")!=Magic){ // через глобал RepFile, открывающий доступ к файлу Reports.csv
      Sleep(BackTest*10); //
      if (GlobalVariableGet("MailTime")==Hour()) return; // пока захватывали файл, кто-то уже отправил мыло 
      if (GlobalVariableGet("RepFile")==0) GlobalVariableSet("RepFile",Magic);    
      if (TimeLocal()-StartWaiting>300){ // прождали 5мин, насильно открываем файл, т.к. что-то значит не в порядке
         Report("MAIL_SEND: Expert "+DoubleToStr(GlobalVariableGet("RepFile"),0)+"  hold ReportFile more then "+DoubleToStr((TimeLocal()-StartWaiting),0)+" seconds! Try to set own flag"); // докладываем о занятом торговом потоке
         StartWaiting=TimeLocal();  
         GlobalVariableSet("RepFile",0); // сбрасываем Magic, чтобы попытаться захватить
      }  }
   GlobalVariableSet("MailTime",Hour()); // флаг отправки "мыла" 
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
               LongRisk+=RiskChecker(float(OrderLots()), float(MathAbs(OrderOpenPrice()-OrderStopLoss())), OrderSymbol());
            if (OrderType()==1 || OrderType()==3 || OrderType()==5)
               ShortRisk+=RiskChecker(float(OrderLots()), float(MathAbs(OrderOpenPrice()-OrderStopLoss())), OrderSymbol());   
         }  }  // теперь массив ORD содержит список всех открытых, отложенных и предстоящих установке ордеров   
   if (LastOrderTime>0) GlobalVariableSet("LastOrderTime",LastOrderTime);// сохраняем время самого позднего ордера для текущего бара   
   AccCDD=MaxBal-AccPrf;
   if (AccDD>0) AccRF=AccPrf/AccDD;
   if (Minus>0) AccPF=Plus/Minus;
   string AccountParams="\r________AccountParams_________"+
   //"\rAccountProfit="+DoubleToStr(AccPrf,0)+" "+AccountCurrency()+
   //"\rRF="+DoubleToStr(AccRF,1)+
   //" PF="+DoubleToStr(AccPF,1)+
   //"\rMaxDD="+DoubleToStr(AccDD,0)+
   //" CurDD="+DoubleToStr(AccCDD,0)+
   "\rRisk: Long+Short = "+DoubleToStr(LongRisk,1)+"%+"+DoubleToStr(ShortRisk,1)+"%"+
   "\rMargin: Open+Depend="+DoubleToStr(OpenOrdMargNeed/AccountFreeMargin()*100,0)+"%+"+DoubleToStr(MargNeed/AccountFreeMargin()*100,0)+"%"+
   "\rEquity="+DoubleToStr(AccountEquity(),0)+" FreeMargin="+DoubleToStr(AccountFreeMargin(),0);
   string CurPrf;
   if (AccountProfit()>0) CurPrf="+"+DoubleToStr(AccountProfit()*100/AccountBalance(),1)+"%"; // текущая незакрытая прибыль в процентах
   if (AccountProfit()<0) CurPrf=    DoubleToStr(AccountProfit()*100/AccountBalance(),1)+"%";
   CurPrf=AccountCurrency()+" "+DoubleToStr(AccountBalance(),0)+CurPrf+" ";
   string MailText=CurrentTime(Time[0])+"  *"+AccountCompany()+"*   ", MailWarning, RollList;
   if ((RollPlus-RollMinus)!=0){
      CurPrf=CurPrf+" Roll="+DoubleToStr(RollPlus+RollMinus,0);// были роловеры
      if (RollPlus>0)  RollList=DoubleToStr(RollPlus,0);
      if (RollMinus<0) RollList=RollList+DoubleToStr(RollMinus,0);
      MailText=MailText+"\n"+"Roll="+RollList+AccountCurrency(); 
      }
   int shift=iBarShift(NULL,0,BarTime,FALSE)-iBarShift(NULL,0,LastBarTime,FALSE); Print("MAIL_SEND():",Magic," BarTime=",TimeToStr(BarTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS)," LastBarTime=",TimeToStr(LastBarTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS)," shift=",shift);
   if (shift>1) // проверка пропущенных баров: разница с прошлым баром (в барах)   
      Report("Missed Bars="+DoubleToStr(shift-1,0)+"!,  LastOnLine="+TimeToStr(LastBarTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+",  CurTime="+TimeToStr(BarTime,TIME_MINUTES|TIME_SECONDS));   
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
      while (!FileIsEnding(File)){ 
         MailText=MailText+FileReadString(File);; // пихаем все в мыло 
         }
      if (StringFind(MailText,"!",0)>0) MailWarning="! ! !  "; // если были предупреждения, выносим их в заголовок мыла
      FileClose(File); 
      }
   SendMail(MailWarning+CurPrf, MailText+AccountParams + MARKET_INF()); 
   FileDelete(FileName);
   GlobalVariableSet("RepFile",0); 
   if (Real) ERROR_CHECK("MAIL_SEND");  
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
string MARKET_INF(){ // инфа о текущих рыночных характеристиках и профите 
   string MarketInf, MarketOrders;
   float POINT, TakeProfit, ASK, BID;
   int Ord, DIGITS;
   string SYMBOL; 
   if (OrdersTotal()>0) MarketOrders="\r___________Orders:____________";
   for(Ord=0; Ord<OrdersTotal(); Ord++){// проверка отложенных ордеров 
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)==true){
         if (OrderType()==6) continue;
         SYMBOL=OrderSymbol(); // для ф.RiskChecker нужен символ ордера
         DIGITS=(int)MarketInfo(SYMBOL,MODE_DIGITS); 
         POINT =(float)MarketInfo(SYMBOL,MODE_POINT); 
         ASK   =(float)MarketInfo(SYMBOL,MODE_ASK);
         BID   =(float)MarketInfo(SYMBOL,MODE_BID);
         if (OrderTakeProfit()==0) TakeProfit=(float)OrderOpenPrice(); else TakeProfit=(float)OrderTakeProfit(); 
         if (OrderType()==OP_BUYSTOP)  {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BS/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker((float)OrderLots(),float(OrderStopLoss()-OrderOpenPrice()),SYMBOL),1)+"%";}
         if (OrderType()==OP_SELLSTOP) {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SS/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker((float)OrderLots(),float(OrderOpenPrice()-OrderStopLoss()),SYMBOL),1)+"%";} 
         if (OrderType()==OP_BUYLIMIT) {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BL/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker((float)OrderLots(),float(OrderStopLoss()-OrderOpenPrice()),SYMBOL),1)+"%";}
         if (OrderType()==OP_SELLLIMIT){MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SL/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker((float)OrderLots(),float(OrderOpenPrice()-OrderStopLoss()),SYMBOL),1)+"%";}  
         if (OrderType()==OP_BUY)      {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BUY/" +DoubleToStr((BID-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker((float)OrderLots(),float(OrderStopLoss()-OrderOpenPrice()),SYMBOL),1)+"%";}   // профит в пунктах / закрепленный стопом профит в пунктах х лот    
         if (OrderType()==OP_SELL)     {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SELL/"+DoubleToStr((OrderOpenPrice()-ASK)/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker((float)OrderLots(),float(OrderOpenPrice()-OrderStopLoss()),SYMBOL),1)+"%";}   // профит в пунктах / закрепленный стопом профит в пунктах х лот 
         }
      else if (OrderMagicNumber()==Magic) Report("MarketInf(): ERROR! in OrderSelect()="+DoubleToStr(GetLastError(),0));
      } 
   MarketInf= "\r____MarketInfo "+Symbol()+":____"+
              "\rSpread="+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0)+
              "\rSwL/SwS/SLev = "+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPLONG),1)+
              "/"+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPSHORT),1)+
              "/"+DoubleToStr(MarketInfo(Symbol(),MODE_STOPLEVEL),1);           
   if (Real) ERROR_CHECK("MARKET_INF");  
   return (MarketOrders+MarketInf);
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
string CurrentTime (datetime ServerSeconds){// Серверное время в виде  День.Месяц/Час:Минута 
   string ServTime;
   int time;
   time=TimeDay(ServerSeconds);     if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0)+"."; // День.Месяц/Час:Минута
   time=TimeMonth(ServerSeconds);   if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0)+"/"; // 
   time=TimeHour(ServerSeconds);    if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0)+":"; // 
   time=TimeMinute(ServerSeconds);  if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0);     // 
   return (ServTime);
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
uchar ExpertsTotal=0;   
   
void MATLAB_LOG (){// Сохранение истории сделок в файл 
   short profit=0;
   short  TradeCnt[EXPERTS_LIM];
   string FileName; 
   ArrayInitialize(TradeCnt,0);
   if (Real) {FileName="MatLab"+AccountCurrency()+".csv"; FileDelete(FileName);} // каждый час создаем новый файл
   else      {FileName="MatLabTest.csv";}//  
   int File=FileOpen(FileName, FILE_READ | FILE_WRITE); 
   if (File<0) {Alert("MatLabLog(): Can not open file "+ FileName+"! for history saving"); return;}
   Alert("MatLabLog()");
   FileWrite(File, "Magic","TickVal","Risk","Deal/Time..."); // прописываем в первую строку названия столбцов
   for(int i=0; i<OrdersHistoryTotal(); i++){// перебераем историю сделок эксперта
      if (OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==true && OrderMagicNumber()>0 && OrderCloseTime()>0){
         if (Time[0]-OrderCloseTime()>34560000) continue; // Пропускаем все ордера старше двух лет, чтобы не переполнять масссив. Для гарфического анализа они не пригодятся.
         if (OrderProfit()!=0){ // попался закрытый ордер (не Открытый и не Отложенный) 
            uchar Exp=0;
            EXPERTS_PARAMS(Exp, OrderMagicNumber(), MarketInfo(OrderSymbol(),MODE_TICKVALUE));
            Expert[Exp].trade[TradeCnt[Exp]]=short((OrderProfit()+OrderSwap()+OrderCommission())*100/OrderLots()/MarketInfo(OrderSymbol(),MODE_TICKVALUE)*0.1);
            Expert[Exp].time[TradeCnt[Exp]]=OrderCloseTime();  //Print(" TrdCnt[",Exp,"]=",TradeCnt[Exp]," trade=",Expert[Exp].trade[TradeCnt[Exp]]," time=",Expert[Exp].time[TradeCnt[Exp]]);
            TradeCnt[Exp]++; 
      }  }  } 
   //Print("ExpertsTotal=",ExpertsTotal);     
   for (uchar Exp=0; Exp<=ExpertsTotal; Exp++){
      short order=1; // Alert("magic[",Exp,"]=",magic[Exp]);
      FileSeek (File,0,SEEK_END); // перемещаемся в конец файла MatLabTest.csv
      FileWrite(File, DoubleToStr(Expert[Exp].magic,0)+";"+DoubleToStr(Expert[Exp].tickval,5)+";"+"0.1"); // прописываем в первую ячейку magic,
      Print("TradeCnt[Exp]=",TradeCnt[Exp]);
      for (short i=0; i<=TradeCnt[Exp]; i++){ //
         FileSeek (File,-2,SEEK_END); // потом дописываем
         FileWrite(File,  ""    , DoubleToStr(Expert[Exp].trade[i],0)+"/"+TimeToStr(Expert[Exp].time[i],TIME_DATE|TIME_MINUTES));    // ежедневные профиты/время сделки из созданного массива    
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
         ExpertsTotal=ExpCnt;
         break;
         }
      if (ExpCnt>=EXPERTS_LIM) {Alert("WARNING!!! Experts>",EXPERTS_LIM, " Can't create MatLabLog File"); }   
      }  
   Expert[ExpCnt].tickval=(float)ExpTickVal;
   }      
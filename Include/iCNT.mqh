int OnInit(){// при загрузке эксперта, смене инструмента/периода/счета/входных параметров, компиляции
   if (!IsTesting() && !IsOptimization()) Real=true;  
   InitDeposit=short(AccountBalance()); 
   DayMinEquity=InitDeposit;
   SYMBOL=Symbol();
   Per=short(Period());
   MaxRisk=MAX_RISK;
   string AccComp="test";
   if (AccountCompany()!="") AccComp=AccountCompany();
   Company=StringSubstr(AccComp,0,StringFind(AccComp," ",0)); // Первое слово до пробела
   StartDate=""; // тест фиксируется в COUNT, т.к. начинаестя с StartYear, а не с даты, указанной в терминале. 
   if (MarketInfo(Symbol(),MODE_LOTSTEP)<0.1) LotDigits=2; else LotDigits=1;
   CHART_SETTINGS(); // настройки вненшего вида графика 
   MARKET_UPDATE(SYMBOL);// обновление Spred и StopLevel
   if (ATR_INIT()!=INIT_SUCCEEDED) return(INIT_FAILED);  // 
   if (PIC_INIT()!=INIT_SUCCEEDED) return(INIT_FAILED);  // 
   if (Real){
      int ms=0;
      for (int i=0; i<StringLen(Symbol()); i++)    ms+=StringGetChar(Symbol(),i); 
      for (int i=0; i<StringLen(ExpertName); i++)  ms+=StringGetChar(ExpertName,i);
      ms+=Period(); // индивидуальная пауза для каждого эксперта, чтобы не стартовали разом
      while (ms>1000) ms-=1000;  ms*=2;
      Sleep(ms);
      if (!GlobalVariableCheck("GlobalOrdersSet")) GlobalVariableSet("GlobalOrdersSet",0);
      while (!GlobalVariableSetOnCondition("GlobalOrdersSet",ms,0))  Sleep(ms);
      LABEL("                  "+ExpertName+" Back="+S0(BackTest)+" Risk="+S1(Risk)+" MaxRisk="+S0(MaxRisk)+" MM="+S0(MM)+" Bars="+S0(Bars)+" Time[1]="+TimeToStr(Time[1],TIME_DATE));
      Print("Init() ",ExpertName," ",Symbol()+S0(Period())," Bars=",Bars, " Time[Bars]=",TimeToStr(Time[Bars-1],TIME_DATE | TIME_MINUTES)," Time[1]=",TimeToStr(Time[1],TIME_DATE | TIME_MINUTES)," Sleep=",ms,"ms");
      if (Bars<1000) MessageBox("Before(): History too short < 1000 bars!"); // история слишком короткая, индикаторы могут посчитаться неверно
      if (Risk==0) Aggress=1; // Если в настройках выставить риск>0, то риск, считанный из #.csv будет увеличен в данное количество раз. 
      else{
         Aggress=Risk; 
         MaxRisk=MAX_RISK*Aggress; 
         Alert(" WARNING, Risk x ",Aggress,"  MaxRisk=",MaxRisk, " !!!");
         } 
      INPUT_FILE_READ(); // занесение в массив CSV считанных из файла #.csv входных параметров всех экспертов
      for (Exp=1; Exp<=ExpTotal; Exp++){// осуществление перебора всех строк с входными параметрами за один тик (только для реала) 
         if (!EXPERT_SET()) continue; // выбор параметров эксперта из строки Exp массива CSV, сформированного из файла #.csv
         for (bar=Bars-3; bar>1; bar--) COUNT(); // расчет индикаторов на доступной истории
         SAVE_VARIABLES(Exp);// сохранение инициализированных значений Print("v[",e,"].BarDM=",v[e].BarDM," DayBar=",v[e].DayBar," daybar=",v[e].daybar);  
         }
      bar=1;   
      if (!GlobalVariableCheck("LastBalance"))     GlobalVariableSet("LastBalance",AccountBalance()); 
      GlobalVariableSet("RepFile",0); // флаг доступа к файлу с репортами
      GlobalVariableSet("CanTrade",0); // заводим глобал для огранизации доступа к терминалу
      GlobalVariableSet("CHECK_OUT_Time",TimeCurrent()); // глобал для обеспечения периодичности проверки ордеров
      GlobalVariableSet("LastOrdTime",LAST_ORD_TIME()); // время последнего выставленного ордера
      Print("Init() ",ExpertName," ",Symbol()+S0(Period()), " Last Start BarTime=",TimeToStr(BarTime,TIME_DATE | TIME_MINUTES),", ExpetrsTotal =",ExpTotal,", StartPause =",ms,"ms");
      if (UninitializeReason()==1) REPORT("Last Exit=Program Remove");
      GlobalVariableSet("GlobalOrdersSet",0);
   }else{
      if (BackTest==0){// режим оптимизации
         ExpTotal=1; // отключение режима перебора экспертов
         MAGIC_GENERATOR();
         CONSTANT_COUNTER(); // Индивидуальные константы: AtrPer, время входа/выхода...
      }else{// работа экспетра со считанными из файла #.csv параметрами
         INPUT_FILE_READ(); // занесение в массив CSV считанных из файла #.csv входных параметров всех экспертов
         }
      if (StringLen(SkipPer)==5){   
         SkipFrom=2000+short(StrToDouble(StringSubstr(SkipPer,0,2)));
         SkipTo  =2000+short(StrToDouble(StringSubstr(SkipPer,3,2))); Print("Skip from ",SkipFrom," to ",SkipTo);
         }    
      INPUT_PARAMETERS_PRINT();  // ПЕЧАТЬ В ЛЕВОЙ ЧАСТИ ГРАФИКА ВХОДНЫХ ПАРАМЕТРОВ ЭКСПЕРТА   
      }   
   ERROR_CHECK("OnInit");
   Print("INIT: ",__FILE__,"  v",VERSION,"  compilation time: ",__DATETIME__,"\n  ",SYMBOL+S0(Per), " Bars=",Bars," BarsTime=",TimeToStr(Time[Bars-1],TIME_DATE | TIME_MINUTES)," Time[1]=",TimeToStr(Time[1],TIME_DATE | TIME_MINUTES));   
   return (INIT_SUCCEEDED);  
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool COUNT(){// Общие расчеты для всего эксперта 
   //TRADES_ENOUGH();
   history="";
   MARKET_UPDATE(Symbol());
   if (StartDate=="") StartDate=TimeToStr(TimeCurrent(),TIME_DATE); // дата начала оптимизации/тестирования. Фиксируется тут, т.к. т.к. тест начинаестя с StartYear, а не с даты, указанной в терминале. 
   if (!PIC()) return (false);   // ОСНОВНОЙ ЦИКЛ ПОИСКА УРОВНЕЙ 
   POC_SIMPLE();  // ОПРЕДЕЛЕНИЕ ПЛОТНОГО СКОПЛЕНИЯ БАР БЕЗ ПРОПУСКОВ 
   if (BUY.Val>0){
      int Shift=SHIFT(BuyTime);
      MinFromBuy=(float)Low [iLowest (NULL,0,MODE_LOW ,Shift,0)]; 
      MaxFromBuy=(float)High[iHighest(NULL,0,MODE_HIGH,Shift,0)];} //  Print("BUY.Val=",BUY.Val," BuyTime=",BuyTime," Shift=",Shift," MinFromBuy=",MinFromBuy," MaxFromBuy=",MaxFromBuy);    
   if (SEL.Val>0){
      int Shift=SHIFT(SellTime);
      MinFromSell=(float)Low [iLowest (NULL,0,MODE_LOW ,Shift,0)];
      MaxFromSell=(float)High[iHighest(NULL,0,MODE_HIGH,Shift,0)];}//  Print("SEL.Val=",SEL.Val," SellTime=",SellTime," Shift=",Shift," MinFromSell=",MinFromSell," MaxFromSell=",MaxFromSell);      
   if (ExpirBars>0)  Expiration=Time[0]+ExpirBars*Period()*60; else Expiration=0;// уменьшаем период на 30сек, чтоб совпадало с реалом 
   FILTERS (iDblTop, iImp, iFltBrk, UP, DN); // ФИЛЬТРЫ ГЛОБАЛЬНОГО НАПРАВЛЕНИЯ формируют сигналы UP, DN        
   TARGET_ZONE_CHECK(BUYLIM, SELLIM); // ЗАКРЫТИЕ ОРДЕРОВ, ПОПАДАЮЩИХ В ЗОНУ ЦЕЛЕВОГО ДВИЖЕНИЯ / iINPUT()      
   POC_CLOSE_TO_ORDER();// удаление отложника если перед ним формируется флэт(пик) / iOUTPUT()  
   //LINE("HI["+S0(HI)+"] Back="+S4(F[HI].Back)+" Glb"+S0(Trnd.LevBrk), bar+1, F[HI].P, bar, F[HI].P,  clrPink,2);       // LINE("F[HI].Tr", bar+1, F[HI].Tr, bar, F[HI].Tr,  clrPink,0); 
   //LINE("LO["+S0(LO)+"] Back="+S4(F[LO].Back)+" Glb"+S0(Trnd.LevBrk), bar+1, F[LO].P, bar, F[LO].P,  clrLightBlue,2);  // LINE("F[HI].Tr", bar+1, F[HI].Tr, bar, F[HI].Tr,  clrLightBlue,0);  
   // if (BUY.Val){  A("BUY.Val="+S4(BUY.Val)+" Shift="+S0(SHIFT(BuyTime))+" MaxFromBuy="+S4(MaxFromBuy -BUY.Val),  H-ATR*3, 0,  clrGray);
   //if (SEL.Val) V("SEL.Val="+S4(SEL.Val)+" DN="+S0(DN),  L+ATR*3, 0,  clrGray);// " Shift="+S0(SHIFT(SellTime))+" MinFromSell="+S4(SEL.Val-MinFromSell)
   //Print(__FUNCTION__," ",__LINE__);
   ERROR_CHECK(__FUNCTION__);
   return (true);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void CONSTANT_COUNTER(){// Индивидуальные константы: MinProfit, PerAdapter, AtrPer, время входа/выхода...      
   PerAdapter=float(60.00/Period()); //Print("PerAdapter=",PerAdapter);
   SlowAtrPer=A*A;  
   FastAtrPer=a*a;
   TimeOn=short(Tin*60/Period()); // начало торговли в барах от начала сессии, где Tin-часы от начала сессии
   TimeOff=short(TimeOn+(Tper+1)*60/Period()); // период торговли в барах от начала торговли, где Tper-часы от начала торговли Tin
   if (TimeOff>BarsInDay) TimeOff-=BarsInDay; // переход через полночь
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
struct INDIVIDUAL_VARIABLES{// структура данных эксперта
   char Dir;
   uchar n, BrokenPic, hi, lo, hi2, lo2, HI, LO, Hi2, Lo2, midHI, midLO, jmpHI, jmpLO, RevHi, RevLo, RevHi2, RevLo2, FlsUp, FlsDn, uFsUp, uFsDn, TrgHi, TrgLo;
   float ATR, Impulse, New, HiBack, LoBack, MidMovUp, MidMovDn, LastMovUp, LastMovDn, MovUp[Movements], MovDn[Movements], MovUpSrt[Movements], MovDnSrt[Movements], TargetHi, TargetLo;
   float RevBUY, RevSELL, minHi, maxLo;  
   short PocSum;  
   datetime ExpMemory; 
   AtrStruct      Atr;
   PICS           F[LevelsAmount];
   TREND_SIGNALS  Trnd;
   } v[MAX_EXPERTS_AMOUNT];      

void LOAD_VARIABLES(ushort e){// восстановление индивидуальных переменных для эксперта "e" (HI,LO,DM,DayBar) на каждом баре в режиме последовательного запуска на реале
   if (!Real) return;
   Dir=v[e].Dir;
   n=v[e].n; BrokenPic=v[e].BrokenPic; hi=v[e].hi; lo=v[e].lo; hi2=v[e].hi2; lo2=v[e].lo2; HI=v[e].HI; LO=v[e].LO; Hi2=v[e].Hi2; Lo2=v[e].Lo2; midHI=v[e].midHI; midLO=v[e].midLO; RevHi=v[e].RevHi; RevLo=v[e].RevLo; RevHi2=v[e].RevHi2; RevLo2=v[e].RevLo2; FlsUp=v[e].FlsUp; FlsDn=v[e].FlsDn; uFsUp=v[e].uFsUp; uFsDn=v[e].uFsDn; TrgHi=v[e].TrgHi; TrgLo=v[e].TrgLo;    
   ATR=v[e].ATR; Impulse=v[e].Impulse; New=v[e].New; HiBack=v[e].HiBack; LoBack=v[e].LoBack; MidMovUp=v[e].MidMovUp; MidMovDn=v[e].MidMovDn; LastMovUp=v[e].LastMovUp; LastMovDn=v[e].LastMovDn; TargetHi=v[e].TargetHi; TargetLo=v[e].TargetLo;
   for (char i=0; i<Movements; i++) {MovUp[i]=v[e].MovUp[i]; MovDn[i]=v[e].MovDn[i]; MovUpSrt[i]=v[e].MovUpSrt[i]; MovDnSrt[i]=v[e].MovDnSrt[i];}
   RevBUY=v[e].RevBUY; RevSELL=v[e].RevSELL; minHi=v[e].minHi; maxLo=v[e].maxLo; 
   PocSum=v[e].PocSum;
   ExpMemory=v[e].ExpMemory;
   Atr=v[e].Atr;
   for (int i=0; i<LevelsAmount; i++) F[i]=v[e].F[i]; 
   Trnd=v[e].Trnd; 
   }

void SAVE_VARIABLES(ushort e){// сохранение индивидуальных переменных для эксперта "e" (HI,LO,DM,DayBar) на каждом баре в режиме последовательного запуска на реале
   if (!Real) return;
   v[e].Dir=Dir;
   v[e].n=n; v[e].BrokenPic=BrokenPic; v[e].hi=hi; v[e].lo=lo; v[e].hi2=hi2; v[e].lo2=lo2; v[e].HI=HI; v[e].LO=LO; v[e].Hi2=Hi2; v[e].Lo2=Lo2; v[e].midHI=midHI; v[e].midLO=midLO; v[e].RevHi=RevHi; v[e].RevLo=RevLo; v[e].RevHi2=RevHi2; v[e].RevLo2=RevLo2; v[e].FlsUp=FlsUp; v[e].FlsDn=FlsDn; v[e].uFsUp=uFsUp; v[e].uFsDn=uFsDn; v[e].TrgHi=TrgHi; v[e].TrgLo=TrgLo;    
   v[e].ATR=ATR; v[e].Impulse=Impulse; v[e].New=New; v[e].HiBack=HiBack; v[e].LoBack=LoBack; v[e].MidMovUp=MidMovUp; v[e].MidMovDn=MidMovDn; v[e].LastMovUp=LastMovUp; v[e].LastMovDn=LastMovDn; v[e].TargetHi=TargetHi; v[e].TargetLo=TargetLo;
   for (char i=0; i<Movements; i++) {v[e].MovUp[i]=MovUp[i]; v[e].MovDn[i]=MovDn[i]; v[e].MovUpSrt[i]=MovUpSrt[i]; v[e].MovDnSrt[i]=MovDnSrt[i];}
   v[e].RevBUY=RevBUY; v[e].RevSELL=RevSELL; v[e].minHi=minHi; v[e].maxLo=maxLo; 
   v[e].PocSum=PocSum;
   v[e].ExpMemory=ExpMemory;
   v[e].Atr=Atr;
   for (int i=0; i<LevelsAmount; i++) v[e].F[i]=F[i]; 
   v[e].Trnd=Trnd; 
   }   
    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void TESTER_FILE_CREATE(string Inf, string TesterFileName){ // создание файла отчета со всеми характеристиками  //////////////////////////////////////////////////////////////////////////////////////////////////
   ResetLastError(); TesterFile=FileOpen(TesterFileName, FILE_READ|FILE_WRITE | FILE_SHARE_READ | FILE_SHARE_WRITE, ';'); 
   if (TesterFile<0) {REPORT("ERROR! TesterFileCreate()  Не могу создать файл "+TesterFileName); return;}
   string SymPer=Symbol()+DoubleToStr(Period(),0);
   //MAGIC_GENERATOR();
   if (FileReadString(TesterFile)==""){
      FileWrite(TesterFile,"INFO","SymPer",Str1,Str2,Str3,Str4,Str5,Str6,Str7,Str8,Str9,Str10,Str11,Str12,Str13,"Magic","ID"); 
      DATA_PROCESSING(TesterFile, WRITE_HEAD);
      }
   FileSeek (TesterFile, 0,SEEK_END); // перемещаемся в конец   
   FileWrite(TesterFile,    Inf  , SymPer ,Prm1,Prm2,Prm3,Prm4,Prm5,Prm6,Prm7,Prm8,Prm9,Prm10,Prm11,Prm12,Prm13, Magic ,ExpID); 
   DATA_PROCESSING(TesterFile, WRITE_PARAM);
   FileSeek (TesterFile,-2,SEEK_END); FileWrite(TesterFile,"",0,0,0);
   ERROR_CHECK(__FUNCTION__); 
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void MAGIC_GENERATOR(){
   MagicLong=0;
   DATA_PROCESSING(0, MAGIC_GEN);   // генерит огромное чило MagicLong типа ulong складыая побитно все входные параметры
   ExpID=CODE(MagicLong);  // Уникальное 70-ти разрядное строковое имя из символов, сгенерированных на основе числа MagicLong 
   Magic=int(MagicLong);   // обрезаем до размеров, используемых в функциях OrderSend(), OrderModify()...
   if (Magic<0) Magic*=-1; // Отрицательный не нужен
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void INPUT_PARAMETERS_PRINT(){ // ПЕЧАТЬ В ЛЕВОЙ ЧАСТИ ГРАФИКА ВХОДНЫХ ПАРАМЕТРОВ ЭКСПЕРТА и создание файла настроек magic.set 
   if (IsOptimization()) return;
   for (int i=ObjectsTotal()-1; i>=0; i--) ObjectDelete(ObjectName(i)); // удаляются все объекты 
   string FileName=ExpertName+"_"+S0(Magic)+".set";   // TerminalInfoString(TERMINAL_DATA_PATH)+"\\tester\\files\\"+ExpertName+DoubleToString(Magic,0)+".txt";
   int file=FileOpen(FileName,FILE_WRITE|FILE_TXT);
   if (file<0){   Print("INPUT_PARAMETERS_PRINT: Can't write setter file ", FileName);  return;}
   LABEL("                  "+ExpertName+" Back="+S0(BackTest)+" Risk="+S1(Risk)+" MaxRisk="+S0(MaxRisk));
   LABEL("                  Magic="+S0(Magic)); LABEL(" "); 
   DATA_PROCESSING(file, LABEL_WRITE);
   FileClose(file); 
   ERROR_CHECK(__FUNCTION__); 
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void DATA_PROCESSING(int source, char ProcessingType){// универсальная ф-ция для записи/чтения парамеров, их печати на графике и генерации MagicLong   
   if (ProcessingType==LABEL_WRITE)   LABEL(" - P I C   L E V E L S - ");///////////
   DATA("FltLen", FltLen,     source,ProcessingType);
   DATA("PicCnt", PicCnt,     source,ProcessingType);
   DATA("Target", Target,     source,ProcessingType);
   DATA("Power",  Power,      source,ProcessingType);
   DATA("Trd",    Trd,        source,ProcessingType);
   DATA("Pot",    Pot,        source,ProcessingType);
   DATA("Rev",    Rev,        source,ProcessingType);
   DATA("Tch",    Tch,        source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" -  T R E N D   S I G N A L S  - ");////////////////
   DATA("TrGlb",   TrGlb,     source,ProcessingType);
   DATA("TrDblPic",TrDblPic,  source,ProcessingType);
   DATA("TrImp",   TrImp,     source,ProcessingType);
   DATA("iDblTop",iDblTop,    source,ProcessingType);
   DATA("iFltBrk",iFltBrk,    source,ProcessingType);
   DATA("iImp",   iImp,       source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" - A  T  R -");////////////////
   DATA("A",         A,       source,ProcessingType);
   DATA("a",         a,       source,ProcessingType);
   DATA("Ak",        Ak,      source,ProcessingType);
   DATA("PicVal",    PicVal,  source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" -  I N P U T S -");////////////////
//   DATA("iFrstLev",iFrstLev,  source,ProcessingType);
   DATA("iSignal",iSignal,    source,ProcessingType);
   DATA("iParam", iParam,     source,ProcessingType);
   DATA("iFlt",   iFlt,       source,ProcessingType);
   DATA("Iprice", Iprice,     source,ProcessingType);
   DATA("D",      D,          source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" -  S T O P -");////////////////
   DATA("sMin",   sMin,       source,ProcessingType);
   DATA("sMax",   sMax,       source,ProcessingType);
   DATA("Stp",    Stp,        source,ProcessingType);
   DATA("Prf",    Prf,        source,ProcessingType);
   DATA("minPL",  minPL,      source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" -  O U T P U T  -");////////////////
   DATA("oImp",   oImp,       source,ProcessingType);
   DATA("oSig",   oSig,       source,ProcessingType);
   DATA("oFlt",   oFlt,       source,ProcessingType);
   DATA("oPrice", oPrice,     source,ProcessingType);
   DATA("Trl",    Trl,        source,ProcessingType);
   if (ProcessingType==LABEL_WRITE)   LABEL(" -  T I M E  -");////////////////
   DATA("ExpirBars", ExpirBars,source,ProcessingType);
   DATA("Tper",   Tper,       source,ProcessingType);
   DATA("Tin",    Tin,        source,ProcessingType);
   DATA("tPrice", tPrice,     source,ProcessingType);
   if (ProcessingType==READ_ARR){
      TestEndTime=CSV[source].TestEndTime;
      OptPeriod=  CSV[source].OptPeriod;
      HistDD=     CSV[source].HistDD;
      LastTestDD= CSV[source].LastTestDD;
   // Risk=       CSV[source].Risk;
      Magic=      CSV[source].Magic;
      ExpID=      CSV[source].ID;
      RevBUY=     CSV[source].RevBUY; 
      RevSELL=    CSV[source].RevSELL; 
      ExpMemory=  CSV[source].ExpMemory;
      }
   ERROR_CHECK(__FUNCTION__); 
   }       
    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void DATA(string name, char& param, int& source, char ProcessingType){// выбор типа обработки входных данных в DATA_PROCESSING
   char i=2; 
   switch (ProcessingType){// тип обработки входных данных
      case LABEL_WRITE: LABEL(name+"="+S0(param));  FileWrite(source,name+"=",S0(param)); ERROR_CHECK("DATA/LABEL_WRITE"); break;
      case READ_FILE:   param=char(StrToDouble(FileReadString(source)));                  ERROR_CHECK("DATA/READ_FILE");   break; 
      case READ_ARR:    param=CSV[Exp].PRM[source];    source++;                          ERROR_CHECK("DATA/READ_ARR");    break;//  присвоение переменным эксперта параметров строки Exp массива CSV, считанного из файла #.csv   Print(name,"=",param);
      case WRITE_HEAD:  FileSeek (source,-2,SEEK_END); FileWrite(source,"",name);         ERROR_CHECK("DATA/WRITE_HEAD");  break;   
      case WRITE_PARAM: FileSeek (source,-2,SEEK_END); FileWrite(source,"",param);        ERROR_CHECK("DATA/WRITE_PARAM"); break;    
      case MAGIC_GEN:   // формирование длинного числа из всех параметров эксперта
         while (i<param) {i*=2; if (i>4) break;} // кол-во зарзрядов (бит), необходимое для добавления нового параметра, но не более 3, чтобы не сильно растягивать число
         MagicLong*=i; // сдвиг MagicLong на i кол-во зарзрядов  
         MagicLong+=param; // Добавление очередного параметра
         ERROR_CHECK(__FUNCTION__);
         break;
   }  }
   


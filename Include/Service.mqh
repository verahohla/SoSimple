#define MAGIC_GEN    1  // виды  
#define LABEL_WRITE  2  // обработки
#define READ_FILE    3  // входных 
#define READ_ARR     4  // данных 
#define WRITE_HEAD   5  // 
#define WRITE_PARAM  6
#define PARAMS 50 // максимальное количество входных параметров эксперта
#define MAX_EXPERTS_AMOUNT 100
struct EXPERTS_DATA{// данные эксперта
   short   Per, HistDD, LastTestDD;
   datetime Bar, TestEndTime, ExpMemory; 
   char     PRM[PARAMS];
   string   Sym, Name, Hist, OptPeriod;
   float    Risk, RevBUY, RevSELL, Lot;
   int      Magic; 
   };
EXPERTS_DATA CSV[MAX_EXPERTS_AMOUNT]; 
EXPERTS_DATA tm();
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void INPUT_FILE_READ (){// занесение в массив считанных из csv файла входных параметров
   string str, InputFileName="#.csv"; 
   int StrPosition, InputFile=-1, chr;
   datetime StartWaiting=TimeLocal(); 
   while (InputFile<0){
      Sleep((BackTest+1)*50); // для разгрузки процессора 
      InputFile=FileOpen(InputFileName, FILE_SHARE_READ | FILE_SHARE_WRITE); 
      if (TimeLocal()-StartWaiting>120) {REPORT("init(): Can not open file "+InputFileName+"!"); StartWaiting=TimeLocal();}
      }      
   short Column, e=1,  TheSameChart=0; 
   while (!FileIsEnding(InputFile)){ 
      e++;
      str=FileReadString(InputFile); while (!FileIsLineEnding(InputFile)) str=FileReadString(InputFile); // читаем всю херь, пока не кончилась строка 
      str=FileReadString(InputFile); // считываем первый столбец с именем эксперта, датами оптимизации и спредами 
      if (StringFind(str," ",0)<0 || StringFind(str,"-",0)<0){
         CSV[e].Magic=1; // признак пустой строки
         CSV[e].Risk=0;  // признак "пустого" эксперта
         continue;} // если в первом столбце не найдены символы " " и "-" то это левая строка, и параметры из нее не читаем
      StrPosition=StringFind(str," ",0); // ищем в строке пробел
      CSV[e].Name=StringSubstr(str,0,StrPosition); 
      StrPosition=StringFind(str,"-",10); // ищем "-" разелитель между началом и концом теста
      CSV[e].TestEndTime=StrToTime(StringSubstr(str,StrPosition+1,10)); // дату конца теста сразу переводим в секунды  Print("Seconds=",TestEndTime," TestEndTime=",TimeToStr(TestEndTime,TIME_DATE));
      StrPosition=StringFind(str,"OPT-",30); // ищем "OPT-" надпись перед сохраненным периодом оптимизации
      if (StrPosition>0)   CSV[e].OptPeriod=StringSubstr(str,StrPosition+4,0); 
      else                 CSV[e].OptPeriod="UnKnown"; // Print("OptPeriod=",OptPeriod);// период начальной оптимизации, сохраненный при самой первой оптимизации
      str=FileReadString(InputFile);// считываем второй столбец с названием пары и ТФ     
      for (chr=0; chr<StringLen(str); chr++)  // Print("s=",StringSubstr(str,chr,1)," cod=",StringGetChar(str,chr));      
         if (StringGetChar(str,chr)>47 && StringGetChar(str,chr)<58) break; // попалось число с кодом: ("0"-48, "1"-49, "2"-50,..., "9"-57)
      CSV[e].Sym=StringSubstr(str,0,chr); 
      CSV[e].Per=short(StrToDouble(StringSubstr(str,chr,0)));       //Print(" Name=",CSV[e].Name," Sym=",CSV[e].Sym," Per=",CSV[e].Per);
      for (Column=3; Column<15; Column++){ // все столбцы, включая magic
         str=FileReadString(InputFile); // читаем просадки HistDD и LastTestDD
         if (Column==7){
            StrPosition=StringFind(str,"_",0);
            CSV[e].HistDD=short(StrToDouble(StringSubstr(str,0,StrPosition)));         //Print("aHistDD[",e,"]=",CSV[e].HistDD);
            CSV[e].LastTestDD=short(StrToDouble(StringSubstr(str,StrPosition+1,0)));   //Print("aLastTestDD[",e,"]=",CSV[e].LastTestDD);
         }  }   
      CSV[e].Risk =float(StrToDouble(FileReadString(InputFile))); // 15-й столбец (Risk)
      CSV[e].Magic=int(StrToDouble(FileReadString(InputFile))); // 16-й столбец (Magic) нельзя прописывать значение в Magic, т.к. в Before() его надо обновлять только при совпадении Expert,Sym,Per. В GlobalOrdersSet() значение Magic формируется из str, нельзя через DataRead(), т.к. разные эксперты формируют его посвоему.     
      if (CSV[e].Name==ExpertName && CSV[e].Sym==Symbol() && CSV[e].Per==Period() && CSV[e].Risk>0) TheSameChart++; // признак того, что попалась хоть одна строка для текущего чарта
      for (chr=0; chr<PARAMS; chr++) CSV[e].PRM[chr]=char(StrToDouble(FileReadString(InputFile)));
      LOAD_GLOBALS(CSV[e].Magic);// Print(CSV[e].Magic," ",Symbol(),Period()," RealParamRestore");
      CSV[e].Hist="";
      CSV[e].Bar=BarTime;
      CSV[e].RevBUY=RevBUY;//RevBUY; 
      CSV[e].RevSELL=RevSELL; 
      CSV[e].ExpMemory=ExpMemory;  
      Print(e," ",CSV[e].Name," Magic[",e,"]=",CSV[e].Magic,": HistDD=",CSV[e].HistDD," LastTestDD=",CSV[e].LastTestDD," Risk=",CSV[e].Risk," PRM=",CSV[e].PRM[0],",",CSV[e].PRM[1],",",CSV[e].PRM[2],",",CSV[e].PRM[3]," RevBUY=",CSV[e].RevBUY," CSV[e].RevSELL=",CSV[e].RevSELL," ExpBar=",CSV[e].Bar," ExpMemory=",CSV[e].ExpMemory," TestEndTime=",DTIME(CSV[e].TestEndTime));
      if (CSV[e].Risk<=0 && CSV[e].Magic>1){  // считаем количество участвующих в торговле экспертов
         Magic=CSV[e].Magic; 
         EMPTY_EXPERTS_DELETE();
      }  }  
   FileClose(InputFile); 
   if (Real){// удаление всех ордеров, мэджики которых отсутствуют в файле #.csv
      for (int i=0; i<OrdersTotal(); i++){// перебераем все открытые и отложенные ордера всех экспертов счета 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)!=true) continue;
         if (OrderType()==6) continue; // ролловеры 
         bool MustDie=true;
         for (short ex=0; ex<e; ex++) if (CSV[ex].Magic==OrderMagicNumber()) MustDie=false; // если мэджик ордера есть в списке, не трогаем его         
         if (MustDie){
            Alert("Expert ",OrderMagicNumber()," does not exist in #.csv, It's orders will be deleted");
            Magic=OrderMagicNumber();   
            EMPTY_EXPERTS_DELETE();
      }  }  }
   if (Real && TheSameChart==0) MessageBox("File #.csv have no data for "+ExpertName+Symbol()+DoubleToStr(Period(),0));
   // else if (CSV[e].Name!=ExpertName || CSV[e].Sym!=Symbol() || CSV[e].Per!=Period()) return(-1); // на тесте проверяем 
   ERROR_CHECK("INPUT_FILE_READ");
   ExpTotal=e;
   }        
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void EMPTY_EXPERTS_DELETE(){// удаление всех поз экспертов с риском=0.
   if (!Real) return;
   ORDER_CHECK();
   if (BUY.Val==0 && BUYSTP==0 && BUYLIM==0 && SEL.Val==0 && SELSTP==0 && SELLIM==0) return;          
   BUY.Val=0; BUYSTP=0; BUYLIM=0; SEL.Val=0; SELSTP=0; SELLIM=0; 
   Alert("Expert ",Magic," remove it's orders");
   MODIFY(); // херим все ордера c этим Мэджиком 
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
bool EXPERT_SET(){ // запуск в начале функции Start 
   if (!Real && BackTest==0) return (true);     // флаг продолжения основного цикла ф. OnTick() 
   if (BackTest>0 && Exp!=BackTest) return (false);  // ожидание совпадения перебираемого Exp с заданным номером строки BackTest  
   if (CSV[Exp].Magic==0 || CSV[Exp].Name!=ExpertName || CSV[Exp].Sym!=Symbol() || CSV[Exp].Per!=Period() || CSV[Exp].Risk==0) return(false); // данные из строки BackTest соответствуют этому эксперту
   DATA_PROCESSING(0, READ_ARR); // считываем параметры строки "Exp" в переменные эксперта
   CONSTANT_COUNTER(); // вычисление индивидуальных констант: MinProfit, PerAdapter, AtrPer, время входа/выхода...
   LOAD_VARIABLES(Exp);// восстановление индивидуальных переменных (HI,LO,DM,DayBar) на каждом баре в режиме последовательного запуска
   //Print("Exp=",Exp," Name[",Exp,"]=",CSV[Exp].Name," CSV[",Exp,"].Risk=", CSV[Exp].Risk," Risk=",Risk," Magic=",Magic," ExpMemory=",TIME(ExpMemory)); 
   ERROR_CHECK("EXPERT_SET");
   return(true); // продолжаем выпоалнение эксперта с выбраными параметрами из строки Exp файла #.csv
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void AFTER(){// запуск в конце функции Start 
   if (!Real) return; 
   CSV[Exp].RevBUY=RevBUY;   // сохраняем индивидуальные 
   CSV[Exp].RevSELL=RevSELL; // переменные эксперта
   CSV[Exp].Bar=Time[0];
   GlobalVariableSet("LastWaitingExpert",Magic); // флаг последнего эксперта для ждущего в WaitingOthers(), сигнализирующий о том, что хватит ждать, я крайний теперь.
   SAVE_VARIABLES(Exp); // сохранение индивидуальных переменных (HI,LO,DM,DayBar) на каждом баре в режиме последовательного запуска
   CHECK_VARIABLES(); // сравнение значений индикаторов Real/Test
   //Print (Magic,"/",SYMBOL, CSV[BackTest-1].Per,": After(",BackTest-1,")"," Risk=",Risk," RevBUY=",RevBUY," RevSELL=",RevSELL," ExpMemory=",TimeToStr(ExpMemory,TIME_DATE | TIME_SECONDS)," HistDD=",HistDD," LastTestDD=",LastTestDD," Bar=",TimeToStr(Time[0],TIME_DATE | TIME_MINUTES)); 
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
void TheEnd(){// запуск после прохода всех экспертов 
   if (!Real) return; 
   GLOBAL_ORDERS_SET();  // и расставляем ордера
   SAVE_PARAMS(); // Сохранение глобальных переменных экспертов данного чарта в файл, доклад о их последних сделках
   SAVE_HISTORY();  
   MAIL_SEND(); 
   LastBarTime=BarTime; // для подсчета пропущенных бар
   MaxSpred=0; // для статистики пишем макс спред в функции ValueCheck()
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void TerminalHold(){// ожидание освобождения торгового потока, чтобы в каждый момент времени терминал был занят только одним экспертом из всего портфеля
   if (!Real) return; // торговый поток уже занят
   int WaitingTime=60;
   if (GlobalVariableGet("CanTrade")==Magic) {  // если глобал свой,
      GlobalVariableSet("BusyTime",TimeLocal());// обновляем время установки глобала
      //Print(Magic,": TerminalHold / my Magic still free");
      return;} 
   while (GlobalVariableGet("CanTrade")!=Magic){ // присваиваем глобальной переменной значение Magic когда она станет равна 0.
      Sleep(1000); // для разгрузки процессора  
      if (GlobalVariableGet("CanTrade")==0){
         GlobalVariableSet("CanTrade",Magic);
         GlobalVariableSet("BusyTime",TimeLocal());} // фиксируем время установки глобала 
      //Print(Magic,": TerminalHold / BusyTime=",TimeLocal()-GlobalVariableGet("BusyTime"),"seconds");     
      if (TimeLocal()-GlobalVariableGet("BusyTime")>WaitingTime){ // прождали, насильно захватываем торговый поток, т.к. что-то значит не в порядке
         REPORT("Expert "+DoubleToStr(GlobalVariableGet("CanTrade"),0)+" work time exceed "+DoubleToStr((TimeLocal()-GlobalVariableGet("BusyTime")),0)+" seconds!, Set own flag: "+DoubleToStr(Magic,0)); // докладываем о занятом торговом потоке
         GlobalVariableSet("CanTrade",0); // сбрасываем Magic 
   }  }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void TerminalFree(){ // освобождение торгового потока 
   if (!Real) return; // может поток и не занимали
   if (GlobalVariableGet("CanTrade")==0) return;
   if (GlobalVariableGet("CanTrade")!=Magic) // кто-то уже занял без спроса
      REPORT("TerminalFree: Expert "+DoubleToStr(GlobalVariableGet("CanTrade"),0)+" already get terminal!"); 
   else{
      GlobalVariableSet("CanTrade",0);  // освобождаем торговый поток
      //Print(Magic,": TerminalFree");
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void OnDeinit(const int reason){
   if (!Real) return;
   EventKillTimer();
   switch (reason){ // вместо reason можно использовать UninitializeReason()
      //case 0: str="Эксперт самостоятельно завершил свою работу"; break;
      case 1: REPORT("Program "+ExpertName+" removed from chart"); break;
      case 2: REPORT("Program "+ExpertName+" recompile"); break;
      case 3: REPORT("Symbol or Period was CHANGED!"); break;
      case 4: REPORT("Chart closed!"); break;
      case 5: REPORT("Input Parameters Changed!"); break;
      case 6: REPORT("Another Account Activate!"); break; 
      case 9: REPORT("Terminal closed!"); break;   
      }
   if (IsTesting() || IsOptimization()) SAVE_PARAMS(); // (только при тестировании реала) пропишем в конец файла историю совершенных сделок и кривую баланса 
   TerminalFree(); //освобождаем торговый поток, если прерывание программы произошло в момент ее выполнения
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
string EXP_INFO(){
   string SkipPeriod="";
   if (SkipFrom>0) SkipPeriod=S0(SkipFrom)+"..."+S0(SkipTo)+"-"; // формирование пропущенного периода, если задана его дата
   string RunPeriod=StartDate+"-"+SkipPeriod+TimeToStr(LastDay,TIME_DATE); // период теста/оптимизации
   if (BackTest==0 && IsOptimization())  OptPeriod=RunPeriod; // фиксируем интервал оптимизации, чтобы потом отразить его на графике матлаба жирным
   return (ExpertName+" "+RunPeriod+", Sprd="+DoubleToStr(Spred/Point,0)+", StpLev="+DoubleToStr(StopLevel/Point,0)+", Swaps="+DoubleToStr((MarketInfo(Symbol(),MODE_SWAPLONG)+MarketInfo(Symbol(),MODE_SWAPSHORT)),2)+", OPT-"+OptPeriod);
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
double OnTester(){////  Ф О Р М И Р О В А Н И Е   Ф А Й Л А    О Т Ч Е Т А   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   float CustomMax=0;
   if (Real)  for (int e=1; e<=ExpTotal; e++) CustomMax=TEST_RESULT(CSV[e].Magic); 
   else CustomMax=TEST_RESULT(Magic);
   return (CustomMax); // возвращаем критерий оптимизации 
   }
float TEST_RESULT(int magic){
   float   CustomMax, SD=0,  iDD=0, GrossProfit=0, GrossLoss=0, MidWin, MidLoss,  profit, MaxWin[5], FullProfit=0, MaxProfit=0, Years, MO,RF=555, iRF=555, PF=555, Sharp=555;  
   short LossesCnt=0, WinCnt=0;       
   double MinDepo=InitDeposit; 
   ArrayInitialize(MaxWin,0);
   Years=float(day/260.0)-(SkipTo-SkipFrom); //Print("days=",day," Years=",Years, " SkipYears=",SkipTo-SkipFrom);
   ushort Trades=0;
   //InitDeposit=TesterStatistics(STAT_INITIAL_DEPOSIT);
   //PF=TesterStatistics(STAT_PROFIT_FACTOR);
   for(int Ord=0; Ord<OrdersHistoryTotal(); Ord++){   // поиск MO, PF, iRF, kDD
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_HISTORY)!=true || OrderMagicNumber()!=magic) continue; // выясним текущие бай/селл позы и гарантированную прибыль по ним, закрепленную стопами
      int Order=OrderType();
      if (Order==OP_BUY || Order==OP_SELL){
         Trades++; 
         profit=float((OrderProfit()+OrderSwap()+OrderCommission())/MarketInfo(Symbol(),MODE_TICKVALUE));///MarketInfo(Symbol(),MODE_TICKVALUE); //Print(Symbol(),": Pips profit=",profit," OrderProfit()=",OrderProfit()," OrderSwap()=",OrderSwap()," OrderCommission()=",OrderCommission()," TICKVALUE=",MarketInfo(Symbol(),MODE_TICKVALUE));
         FullProfit+=profit; // Значение депо после очередной сделки
         if (profit>MaxWin[0]){ // ищем пять самых крупных выигрышей, чтобы вычесть их потом из профита, т.к. уверены, что они не повторятся 
            for (uchar i=4; i>0; i--) MaxWin[i]=MaxWin[i-1];
            MaxWin[0]=profit;  // т.е. резы тестера будут отличаться в худшую сторону
            } //Print("profit=",profit," FullProfit=",FullProfit);
         if (profit>0) {GrossProfit+=profit; WinCnt++;}
         if (profit<0) {GrossLoss-=profit;   LossesCnt++;}
         if (FullProfit>=MaxProfit) MaxProfit=FullProfit;// подсчет iRF - прибыль делим на среднюю просадку
         else  iDD+=MaxProfit-FullProfit;// нахождение в очередной просадке.   площадь просадочной части эквити в период просадки (подсчет по сделкам)      
      }  }     
   if (Trades<1 || day<1) return(0);
   if (WinCnt>0)    MidWin=GrossProfit/WinCnt;   else MidWin=0;
   if (LossesCnt>0) MidLoss=GrossLoss/LossesCnt; else MidLoss=float(0.01);
   LastTestDD=short(MaxEquity-Equity); // последняя незакрытая просадка на тесте
   for (uchar i=1; i<5; i++) MaxWin[0]+=MaxWin[i]; // суммируем все члены массива в первый член
   FullProfit-=MaxWin[0]; //Print("MaxWin=",MaxWin[0]," FullProfit=",FullProfit);// вычитаем из полного профита пять максимальных винов 
   GrossProfit-=MaxWin[0];
   MaxProfit-=MaxWin[0];
   MO=float(FullProfit/Trades); // МатОжидание или Наклон Эквити     
   if (iDD>0) iRF=float(MaxProfit/iDD*100); //  Своя формула для фактора восстановления 
   iDD=iDD/Trades*10;
   for(int Ord=0; Ord<OrdersHistoryTotal(); Ord++){   // поиск MO, PF, iRF, kDD
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_HISTORY)==true && OrderMagicNumber()==magic){ // выясним текущие бай/селл позы и гарантированную прибыль по ним, закрепленную стопами
         int Order=OrderType();
         if (Order==OP_BUY || Order==OP_SELL){
            profit=float((OrderProfit()+OrderSwap()+OrderCommission())/MarketInfo(Symbol(),MODE_TICKVALUE));
            SD+=MathAbs(MO-profit); // Суммарное отклонение
      }  }  } 
   SD/=Trades; // Отклонение результата сделки от MO
   MO/=(float)MarketInfo(Symbol(),MODE_SPREAD);
   if (GrossLoss>0)  PF=float(GrossProfit/GrossLoss);  
   if (DrawDown>0)   RF=float(MaxProfit/Years/DrawDown); // Фактор восстановления (% в год!)
   if (SD>0)  Sharp=float(MO*1000/SD); // Своя формула для к.Шарпа 
   switch(CustMax){// Критерий оптимизации
      default: CustomMax=FullProfit; break;
      case 1:  CustomMax=RF;         break;
      case 2:  CustomMax=iRF;        break;
      case 3:  CustomMax=Sharp;      break;
      }
   string TesterFileName="";
   if (IsOptimization()){ // Оптимизация / РеОптимизация
      if (BackTest==0) TesterFileName="Opt"; else TesterFileName="ReOpt";
      TesterFileName=TesterFileName+"_"+Symbol()+DoubleToStr(Period(),0);
      if (PF<PF_ && PF_>0) return (CustomMax); //return(PF/PF_*CustomMax);  // если при оптимизации резы не катят, 
      if (RF<RF_ && RF_>0) return (CustomMax); //return(RF/RF_*CustomMax);  // не пишем их в файл отчета
      if (MO<MO_ && MO_>0) return (CustomMax); //return(MO/cMO*CustomMax);  // и пропорционально уменьшаем критерий оптимизации
      if (Trades/Years<Opt_Trades)  return(CustomMax);                                                     
      }
   else  {if (BackTest==0) TesterFileName="Test"; else TesterFileName="Back";} // тест / бэктест
//// формируем файл со статистикой текущей оптимизации    
   TesterFileName=TesterFileName+"_"+ ExpertName+".csv"; 
   Str1="Pip/Y";           Prm1=S0(FullProfit/Years); // Профит пункты / год 
   Str2="Trd/Y";           Prm2=S0(Trades/Years); 
   Str3="RF=MaxPrf/Y/DD";  Prm3=S2(RF);    // Фактор восстановления = профит в месяц / просадку 
   Str4="PF";              Prm4=S2(PF);    // Профит фактор
   Str5="DD/LastDD";       Prm5=" "+S0(DrawDown)+"_"+S0(LastTestDD);  // Максимальная историческая просадка / последняя незакрытая просадка
   Str6="iDD";             Prm6=S0(iDD);   // Средняя площадь всех просадок
   Str7="MO/Spred";        Prm7=S2(MO);    // Мат Ожидание
   Str8="SD";              Prm8=S0(SD);    // Стандартное отклонение SD
   Str9="MO/SD";           Prm9=S1(Sharp); // 
   Str10="iRF=MaxPrf/iDD"; Prm10=S0(iRF);  // Модиф. фактора восстановления
   Str11="W/L*W%";         Prm11=" "+S1(MidWin/MidLoss)+"*"+S0(WinCnt*100/Trades)+" ="; // (Средний профит / Средний лосс ) * процент выигрышных сделок = ...Робастность(см. ниже)
   Str12="  = ";           Prm12=S0(MidWin/MidLoss*WinCnt*100/Trades); //    DoubleToStr(MidWin/MidLoss*(WinCnt/Trades)*100,0);  // Робастность =  (Средний профит / Средний лосс ) * процент выигрышных сделок либо  FullProfit*260*1000/day/MaxDD/Trades  
   Str13="RISK=PF*RF";     Prm13=S1(PF*RF);// выравнивает просадки в портфеле  // старый R I S K = 50*day/MaxDD/Trades
   TESTER_FILE_CREATE(EXP_INFO(),TesterFileName); // создание файла отчета со всеми характеристиками  //
   //Print(magic, ": FullProfit=",S0(FullProfit)," RF=",S1(RF)," PF=",S1(PF)," DD/LastDD=",Prm5, " Trades=",Trades);  
   for (short i=1; i<=day; i++){ // допишем в конец каждой строки еженедельные балансы  
      FileSeek (TesterFile,-2,SEEK_END); // перемещаемся в конец строки
      FileWrite(TesterFile, "",DailyConfirmation[i]/MarketInfo(Symbol(),MODE_TICKVALUE));    // пишем ежедневные Эквити из созданного массива
      }
   FileClose(TesterFile); 
   if (BackTest>0) MATLAB_LOG();
   if (Real) ERROR_CHECK("OnTester");
   return (CustomMax); // возвращаем критерий оптимизации   
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void DAY_STATISTIC(){ // расчет параметров DD, Trades, массив с резами сделок // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (Today!=DayOfYear()){ // начался новый день
      Today=DayOfYear(); //Print("DayMinEquity=",DayMinEquity," DayOfYear()=",DayOfYear());
      day++;
      DailyConfirmation[day]=int((DayMinEquity-InitDeposit)); // сперва умножим на 1000, а в OnTester() разделим. Это для более точного отображения на графике.    
      //if (LastYear<Year()) {LastYear=Year(); day++; DailyConfirmation[day]=0; day++; DailyConfirmation[day]=DailyConfirmation[day-2];}
      DayMinEquity=float(AccountEquity());
      if (TimeCurrent()>LastDay) LastDay=TimeCurrent(); //Print(" LastDay=",ServerTime(LastDay)); // приходится искать максимум, т.к. в конце теста значение почему-то сбрасывается к старому
      }
   if (AccountEquity()<DayMinEquity) DayMinEquity=float(AccountEquity());
   // вычисление DD
   Equity=float(AccountEquity()/MarketInfo(Symbol(),MODE_TICKVALUE)); 
   if (Equity>=MaxEquity) MaxEquity=Equity;  // Новый максимум депо
   else{ 
      FullDD+=MaxEquity-Equity;
      if (MaxEquity-Equity>DrawDown) DrawDown=MaxEquity-Equity;
   }  } 
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
      for (int i=0; i<15; i++) FileWrite(File,0);// создаем несколько пустых строчек в начале файла для последующей записи в них глобальных переменных
      FileWrite(File,"BarTime","RevBUY","RevSELL","ExpMemory"); // ниже заголовок для глобальных переменных
      FileWrite(File,"_______________________________"); // разделялка
      //FileWrite(RestoreFile,"E x p e r t     HI i s t o r y :");
      Alert("Create file ",FileName," to save individual history"); 
      GlobalVariableSet("Mem"+DoubleToStr(mgc,0), 0);
      }
   else{ // читаем из файла переменные
      FileSeek(File,0,SEEK_SET);     // перемещаемся в начало   
      BarTime  =datetime(StrToDouble(FileReadString(File)));  // Преобразование строки, содержащей время в формате "yyyy.mm.dd [hh:mi]", в число типа datetime.  
      RevBUY   =float   (StrToDouble(FileReadString(File))); 
      RevSELL  =float   (StrToDouble(FileReadString(File)));
      ExpMemory=datetime(StrToDouble(FileReadString(File)));
      GlobalVariableSet("Mem"+DoubleToStr(mgc,0), ExpMemory);  //Print("LOAD_GLOBALS: read file ",FileName," BarTime=",BarTime," ExpMemory=",ExpMemory);
      }
   FileClose(File);
   ERROR_CHECK("LOAD_GLOBALS");
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void REPORT(string Missage){ // собираем все сообщения экспертов в одну кучу 
   if (!Real)  return;
   if (Missage=="") return;
   int e;
   for (e=0; e<ExpTotal; e++)  if (CSV[e].Magic==Magic) break; // ищем номер экспетра в массиве для данного меджика
   if (CSV[e].Hist=="") CSV[e].Hist=Missage;
   else     CSV[e].Hist=CSV[e].Hist+"\n "+Missage; // без разделителя ";" при записи в RestoreFileName (MailSender()) все сообщения лепятся в одну строку.
   Print("REPORT of ",Magic,": ",Missage);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void SAVE_HISTORY(){ // пишем собранные сообщения в один общий файл   
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
void SAVE_PARAMS(){// Сохранение глобальных переменных в файл, доклад о последних сделках  ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
   int  MagicTemp=Magic; // Print(Magic,": IndividualSaving(), сохраняем RevBUY и RevSELL всех экспертов с графика ",Symbol(),Period());  
   for (int e=0; e<ExpTotal; e++){    
      if (CSV[e].Name==ExpertName && CSV[e].Sym==Symbol() && CSV[e].Per==Period() && CSV[e].Risk>0){ // имя+ТФ+период  совпадают, выбали эксперта с того же чарта
         Magic=CSV[e].Magic; HistDD=CSV[e].HistDD; LastTestDD=CSV[e].LastTestDD; TestEndTime=CSV[e].TestEndTime;
         int Trades=0;
         datetime OrdMemory=0;
         string ExpParams="";
         float SMaxBal=0, SDD=0, SCurDD=0, PF=555, SPF=555, SRF=555, Plus=0, Minus=0, SPlus=0, SMinus=0, trade=0, profit=0, SProfit=0, ExpPrf=0, SExpPrf=0, CheckRisk=0;
         for (int Ord=0; Ord<OrdersHistoryTotal(); Ord++){// перебераем историю сделок эксперта
            if (OrderSelect(Ord,SELECT_BY_POS,MODE_HISTORY)==true && OrderMagicNumber()==Magic && OrderCloseTime()>0){
               trade=float(OrderProfit()+OrderSwap()+OrderCommission()); // прибыль от выбранного ордера в валюте депозита 
               if (trade==0) continue; 
               Trades++;
               SProfit=trade;
               if (OrderLots()>0) profit=trade/float(OrderLots()/MarketInfo(OrderSymbol(),MODE_TICKVALUE)*0.1);
               SExpPrf+=SProfit;
               ExpPrf +=profit; 
               if ( profit>0) Plus+= profit;  else  Minus-= profit;
               if (SProfit>0) SPlus+=SProfit; else  SMinus-=SProfit;
               if (SExpPrf>SMaxBal) SMaxBal=SExpPrf;
               else if (SMaxBal-SExpPrf>SDD) SDD=SMaxBal-SExpPrf;
               OrdMemory=OrderCloseTime();  
            }  }    
         if (OrdMemory>0 && OrdMemory!=GlobalVariableGet("Mem"+S0(Magic))){// если время последней сделки обновилось,
            //Print("profit=",profit," Open-Close=",N5(MathAbs(OrderOpenPrice()-OrderClosePrice()))," Open=",N5(OrderOpenPrice())," Close=",N5(OrderClosePrice()) ," Lots=",OrderLots()," tick=", MarketInfo(Symbol(),MODE_TICKVALUE) ); 
            GlobalVariableSet("Mem"+S0(Magic),OrdMemory); // Print("Update "+"Mem"+S0(Magic)+":",GlobalVariableGet("Mem"+S0(Magic)));
            SCurDD=SMaxBal-SExpPrf; // текущая просадка в $
            if (SDD>0) SRF=SMaxBal/SDD;  // фактор восстановления
            double Stop=100*Point; // возьмем любой стоп для расчета риска
            Lot = MM(Stop,CSV[e].Risk,Symbol());   // расчет пробного лота для стопа в 100п
            CheckRisk=CHECK_RISK(Lot,Stop,Symbol()); //расчет текущего риска в связи с просадкой
            string CurrentRisk; // запишем, на сколько истинный риск (с учетом просадки) отличается от заданного в настройках 
            if (CheckRisk>CSV[e].Risk) CurrentRisk="+"+DoubleToStr(CheckRisk-CSV[e].Risk,1);
            if (CheckRisk<CSV[e].Risk) CurrentRisk=    DoubleToStr(CheckRisk-CSV[e].Risk,1);
            if ( Minus>0)  PF= Plus/ Minus;
            if (SMinus>0) SPF=SPlus/SMinus;
            if (SProfit>0) ExpParams="\n WIN="; else ExpParams="\n LOSS="; // запомним значение баланса на случай, если этот лось для данного эксперта - начало ДД (пригодится потом в ММ)
            ExpParams=ExpParams+S1(SProfit*100/AccountBalance())+"% "+S0(profit)+"p"+
               "\r Prf="+S0(ExpPrf)+"pips Risk="+S1(CSV[e].Risk)+" CheckRisk="+S1(CheckRisk)+ // 
               "\r RF="+DoubleToStr(SRF,1)+" PF="+DoubleToStr(PF,1)+" Trades="+ S0(Trades)+    // 
               "\n HistDD/CurDD="+DoubleToStr(HistDD,0)+"/"+DoubleToStr(CUR_DD(SYMBOL),0);    //
            REPORT(ExpParams); // шлем миссагу
            }
         CSV[e].ExpMemory=OrdMemory;   
         // Сохранение глобальных переменных на случай выключения программы   
         string FileName=Company+"_"+AccountCurrency()+"_"+DoubleToStr(Magic,0)+".csv";
         int File=FileOpen(FileName, FILE_READ|FILE_WRITE);  
         if (File<0) {REPORT("IndividualSaving(): Can't open file "+FileName+" for parameters saving!"); continue;}
         FileWrite (File, CSV[e].Bar, CSV[e].RevBUY, CSV[e].RevSELL, CSV[e].ExpMemory); // сохраняем глобальные переменные в файл
         if (CSV[e].Hist!=""){
            FileSeek (File,0,SEEK_END); 
            FileWrite (File, TIME(TimeCurrent())+";"+CSV[e].Hist); 
            history+="\n  "+S0(CSV[e].Magic)+": "+CSV[e].Hist;
            //Print("IndividualSaving: CSV[",e,"].Hist=",CSV[e].Hist);
            CSV[e].Hist="";
            }
         FileClose(File); 
      }  }
   Magic=MagicTemp; 
   ERROR_CHECK("SAVE_PARAMS");   
   }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void MAIL_SEND(){ // отправляем мыло из файла Reports.csv с отчетами
   if (IsTesting() || IsOptimization()) return;
   if (GlobalVariableGet("MailTime")==Hour()) return; // кто-то уже отправил мыло в этот час  
   GlobalVariableSet("MailTime",Hour()); // флаг отправки "мыла" 
   while (TimeLocal()-GlobalVariableTime("CanTrade")<60) Sleep(1000);// ждем, пока после последнего обращения к глобалу пройдет больше минуты, т.е. все отчитались
   float MaxBal=0, MinBal=0, AccDD=0, AccCDD=0, AccPF=555, Plus=0, Minus=0, AccRF=555, AccPrf=0,  profit=0, RollPlus=0, RollMinus=0, LastHourProfit=0;
   int  Trades=0, LastHourOrdTime=0;
   // Захват возможности отправки мыла
   datetime StartWaiting=TimeLocal();     
   ERROR_CHECK("MAIL_SEND_1");
   while (GlobalVariableGet("RepFile")!=Magic){ // через глобал RepFile, открывающий доступ к файлу Reports.csv
      Sleep(1000); //
      if (GlobalVariableGet("RepFile")==0) GlobalVariableSet("RepFile",Magic);    
      if (TimeLocal()-StartWaiting>300){ // прождали 5мин, насильно открываем файл, т.к. что-то значит не в порядке
         REPORT("MAIL_SEND: Expert "+DoubleToStr(GlobalVariableGet("RepFile"),0)+"  hold ReportFile more then "+DoubleToStr((TimeLocal()-StartWaiting),0)+" seconds! Try to set own flag"); // докладываем о занятом торговом потоке
         StartWaiting=TimeLocal();  
         GlobalVariableSet("RepFile",0); // сбрасываем Magic, чтобы попытаться захватить
      }  }
   MATLAB_LOG();
   if (GlobalVariableGet("LastHourOrdTime")==0){// если в первый раз LastHourOrdTime равно нулю
      LastHourOrdTime=int(iTime(NULL,60,1)); // берем значение времени прошлого бара
      Print(Magic,": GlobalVariable(LastHourOrdTime)=0, set it to last bar time ", TimeToStr(LastHourOrdTime,TIME_DATE|TIME_MINUTES));
      GlobalVariableSet("LastHourOrdTime",LastHourOrdTime); // и сохраняем в глобал
      }
   for(int i=0; i<OrdersHistoryTotal(); i++){// перебераем историю сделок эксперта
      if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) continue; // история всех экспертов
      profit=float(OrderProfit()+OrderSwap()+OrderCommission()); // прибыль от выбранного ордера в валюте депозита 
      if (profit!=0){
         if (OrderOpenPrice()==0 && iTime(NULL,60,0)-OrderOpenTime()<3900){// Ордер без цены открытия, т.е. инвестиции. За прошлый час с небольшим запасом в 5мин = 3600с + 300с
            if (profit>0) RollPlus +=profit;   
            else RollMinus+=profit;
            }
         if (OrderOpenPrice()>0){ // ордер открыт экспертом
            Trades++;   // подсчет показателей работы эксперта
            AccPrf+=profit; 
            if (profit>0) Plus+=profit; else Minus-=profit;
            if (AccPrf>MaxBal) {MaxBal=AccPrf; MinBal=MaxBal;}
            if (AccPrf<MinBal) {MinBal=AccPrf; if (MaxBal-MinBal>AccDD) AccDD=MaxBal-MinBal;}   // DD
            if (OrderCloseTime()>GlobalVariableGet("LastHourOrdTime")){ // время закрытия ордера больше проверенного на прошлом баре (свежий значит)
               if (OrderCloseTime()>LastHourOrdTime) LastHourOrdTime=int(OrderCloseTime()); // ищем самый поздний ордер, чтобы потом его сохранить
               LastHourProfit+=profit; // суммируем всю прибыль за последний час
      }  }  }  }  
   // Суммарный риск открытых позиций и отложенных ордеров
   double OpenOrdMargNeed=0, LongRisk=0, ShortRisk=0, MargNeed=0, PerCent=0;
   for(int i=0; i<OrdersTotal(); i++){// перебераем все открытые и отложенные ордера всех экспертов счета Ролловеры (OrderType=6) туда не пишем.
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false) continue;
      if (OrderType()==6) continue; // ролловеры не нужны
      if (OrderType()<2)   OpenOrdMargNeed+=float(OrderLots()*MarketInfo(OrderSymbol(),MODE_MARGINREQUIRED)); // кол-во маржи, необходимой для открытия лотов
      else                 MargNeed       +=float(OrderLots()*MarketInfo(OrderSymbol(),MODE_MARGINREQUIRED));//маржа отложников
      if (OrderType()==0 || OrderType()==2 || OrderType()==4)  LongRisk +=CHECK_RISK(float(OrderLots()), float(MathAbs(OrderOpenPrice()-OrderStopLoss())), OrderSymbol());
      if (OrderType()==1 || OrderType()==3 || OrderType()==5)  ShortRisk+=CHECK_RISK(float(OrderLots()), float(MathAbs(OrderOpenPrice()-OrderStopLoss())), OrderSymbol());   
      }    // теперь массив ORD содержит список всех открытых, отложенных и предстоящих установке ордеров   
   ERROR_CHECK("MAIL_SEND_2");
   if (LastHourOrdTime>0) GlobalVariableSet("LastHourOrdTime",LastHourOrdTime);// сохраняем время самого позднего ордера для текущего бара   
   AccCDD=MaxBal-AccPrf;
   if (AccDD>0) AccRF=AccPrf/AccDD;
   if (Minus>0) AccPF=Plus/Minus;
   string AccountParams= "\n"+//"\nAccountParams:"+
   "\n  RISK: Long+Short = "+DoubleToStr(LongRisk,1)+"%+"+DoubleToStr(ShortRisk,1)+"%"+
   "\n  MARGIN: Open+Depend="+DoubleToStr(OpenOrdMargNeed/AccountFreeMargin()*100,0)+"%+"+DoubleToStr(MargNeed/AccountFreeMargin()*100,0)+"%"+
   "\n  EQUITY="+DoubleToStr(AccountEquity(),0)+" FreeMargin="+DoubleToStr(AccountFreeMargin(),0)+
   "\n  MarketInfo "+Symbol()+":"+
   "\nMaxSpred="+DoubleToStr(MaxSpred,Digits)+
   "\nSwap/StpLev = "+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPLONG)+MarketInfo(Symbol(),MODE_SWAPSHORT),Digits) + "/" + DoubleToStr(MarketInfo(Symbol(),MODE_STOPLEVEL),Digits)+
   "\n"+ExpertName+"-"+VERSION;   
   string CurPrf, Agr="";
   if (Aggress>1) Agr="x"+DoubleToStr(Aggress,0);
   if (AccountProfit()>0) CurPrf="+"+DoubleToStr(AccountProfit()*100/AccountBalance(),1)+"%"; // текущая незакрытая прибыль в процентах
   if (AccountProfit()<0) CurPrf=    DoubleToStr(AccountProfit()*100/AccountBalance(),1)+"%";
   CurPrf=AccountCurrency()+Agr+"  "+MONEY2STR(AccountBalance())+CurPrf;
   string Warning, RollList, MailText;
   if ((RollPlus-RollMinus)!=0){
      CurPrf=CurPrf+" Roll="+MONEY2STR(RollPlus+RollMinus);// были роловеры
      if (RollPlus>0)  RollList=DoubleToStr(RollPlus,0);
      if (RollMinus<0) RollList=RollList+DoubleToStr(RollMinus,0);
      MailText=MailText+"\n"+"Roll="+RollList+AccountCurrency(); 
      }
   int shift=iBarShift(NULL,0,BarTime,FALSE)-iBarShift(NULL,0,LastBarTime,FALSE); // Print("MAIL_SEND():",Magic," BarTime=",TimeToStr(BarTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS)," LastBarTime=",TimeToStr(LastBarTime,TIME_DATE|TIME_MINUTES|TIME_SECONDS)," shift=",shift);
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
      while (!FileIsEnding(File)) MailText=MailText+"\n"+ FileReadString(File); // пихаем все в мыло 
      if (StringFind(MailText,"!",0)>0) Warning="WARNING"; // если были предупреждения, выносим их в заголовок мыла
      FileClose(File); 
      }
   SendMail(CurPrf, ORDERS_INF(Warning) + MailText + AccountParams); 
   FileDelete(FileName);
   GlobalVariableSet("RepFile",0); 
   Print("MailText: ",MailText," \n \n \n");
   ERROR_CHECK("MAIL_SEND_3");  
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
string MONEY2STR(double Balance){
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
#define  EXPERTS_LIM  255    // максимальное кол-во проверяемых экспертов
#define  ORDERS_LIM   65535   // максимальное кол-во сделок одного эксперта за последние два года

struct AllExperts{  //  C Т Р У К Т У Р А   P I C
   int      magic;
   short    trade[ORDERS_LIM];
   datetime time[ORDERS_LIM];
   float    tickval;
   };
AllExperts Expert[EXPERTS_LIM];   
uchar Experts=0;   
datetime HistoryPeriod=3600*24*365*2; // анализ истории не глубже 2 лет
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void MATLAB_LOG (){// Сохранение истории сделок в файл 
   short profit=0;
   ushort TradeCnt[EXPERTS_LIM]; // счетчик сделок
   string FileName; 
   ArrayInitialize(TradeCnt,0);
   if (Real) {FileName="MatLab"+AccountCurrency()+".csv"; FileDelete(FileName);} // каждый час создаем новый файл
   else      {FileName="MatLabTest.csv";}//  
   int MgcFile, File=FileOpen(FileName, FILE_READ | FILE_WRITE); 
   if (File<0) {Alert("MatLabLog(): Can not open file "+ FileName+"! for history saving"); return;}
   FileWrite(File, "Magic","TickVal","Risk","Deal/Time..."); // прописываем в первую строку названия столбцов
   for(int i=0; i<OrdersHistoryTotal(); i++){// перебераем историю сделок эксперта
      if (OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==false || OrderMagicNumber()==0 || OrderCloseTime()==0 || OrderProfit()==0) continue;
      if (Time[0]-OrderCloseTime()>HistoryPeriod) continue; // Пропускаем все ордера старше двух лет, чтобы не переполнять масссив. Для гарфического анализа они не пригодятся.  
      uchar e=0;
      EXPERTS_PARAMS(e, OrderMagicNumber(), MgcFile);
      Expert[e].trade[TradeCnt[e]]=short((OrderProfit()+OrderSwap()+OrderCommission())/OrderLots()/MarketInfo(OrderSymbol(),MODE_TICKVALUE));
      Expert[e].time[TradeCnt[e]]=OrderCloseTime();  //Print(" TrdCnt[",e,"]=",TradeCnt[e]," trade=",Expert[e].trade[TradeCnt[e]]," time=",Expert[e].time[TradeCnt[e]]);
      TradeCnt[e]++; 
      }    
   for (uchar e=0; e<=Experts; e++){
      short order=1; // Alert("magic[",e,"]=",magic[e]);
      FileSeek (File,0,SEEK_END); // перемещаемся в конец файла MatLabTest.csv
      FileWrite(File, DoubleToStr(Expert[e].magic,0)+";"+DoubleToStr(Expert[e].tickval,5)+";"+DoubleToStr(CSV[e].Risk,1)); // прописываем в первую ячейку magic,
      for (ushort t=0; t<=TradeCnt[e]; t++){ //
         if (Expert[e].trade[t]==0) continue;  
         FileSeek (File,-2,SEEK_END); // потом дописываем
         FileWrite(File,  ""    , DoubleToStr(Expert[e].trade[t],0)+"/"+TimeToStr(Expert[e].time[t],TIME_DATE|TIME_MINUTES));    // ежедневные профиты/время сделки из созданного массива    
      }  }
   FileClose(File);
   ERROR_CHECK("MATLAB_LOG"); 
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void EXPERTS_PARAMS(uchar& ExpCnt, int ExpMagic, int& File){// создание массива параметров для всех экспертов
   for (ExpCnt=0; ExpCnt<EXPERTS_LIM; ExpCnt++){
      if (Expert[ExpCnt].magic==ExpMagic) break;
      if (Expert[ExpCnt].magic==0){
         Expert[ExpCnt].magic=ExpMagic;
         Expert[ExpCnt].tickval=float(MarketInfo(OrderSymbol(),MODE_TICKVALUE));
         Experts=ExpCnt;
         break;
         }
      if (ExpCnt>=EXPERTS_LIM) {Alert("WARNING!!! Experts>",EXPERTS_LIM, " Can't create MatLabLog File"); }   
   }  }      
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void CHECK_VARIABLES(){  // сравнение значений индикаторов Real/Test
   string   CheckFilename, ServerTime=TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS), //"-"+ без дефиса эксель переворачивает дату и все херится
            AskBid=S5(Ask)+" "+S5(Bid), sB, sBS, sBP, sS, sSS, sSP;
   // int rTime=AlpariTime(0);
   //OrderCheck(); // проверим состояние поз
   StopLevel=float(MarketInfo(SYMBOL,MODE_STOPLEVEL)*Point);
   Spred=float(MarketInfo(SYMBOL,MODE_SPREAD)   *Point);
   if (setBUY.Val>0){ // момент открытия позы в лонг
      sB ="set"+DoubleToStr(setBUY.Val,Digits); 
      sBS="set"+DoubleToStr(setBUY.Stp,Digits); 
      sBP="set"+DoubleToStr(setBUY.Prf,Digits);} 
   else { // поза в лонг уже открыта
      sB =DoubleToStr(BUY.Val+BUYSTP+BUYLIM,Digits); 
      sBS=DoubleToStr(BUY.Stp,Digits); 
      sBP=DoubleToStr(BUY.Prf,Digits);}
   if (setSEL.Val>0){// момент открытия позы в шорт
      sS ="set"+DoubleToStr(setSEL.Val,Digits); 
      sSS="set"+DoubleToStr(setSEL.Stp,Digits); 
      sSP="set"+DoubleToStr(setSEL.Prf,Digits);} 
   else { // поза в шорт уже открыта
      sS =DoubleToStr(SEL.Val+SELSTP+SELLIM,Digits); 
      sSS=DoubleToStr(SEL.Stp,Digits); 
      sSP=DoubleToStr(SEL.Prf,Digits);}
   CheckFilename=Company+"_"+"Check_"+ExpertName+"_"+DoubleToStr(Magic,0)+".csv";
   int CheckFile=FileOpen(CheckFilename, FILE_READ|FILE_WRITE); 
   if (CheckFile<0) {REPORT("ValueCheck(): Can not open file "+CheckFilename+"! for variables save"); return;}
   if (FileReadString(CheckFile)=="")// пропишем заголовки столбцов   
      FileWrite (CheckFile,"ServerTime","Open[0]","ask bid", "MaxSpred" , "ATR" ,      "HI/LO"    ,"BUY","StpBuy","PrfBuy","Sell","StpSel","PrfSel","TrUp","TrDn","InUp","InDn","OutUp","OutDn","Tr0","Tr1","Tr2","Tr3","In0","In1","In2","In3","Out0","Out1","Out2","Out3"); // сохраняем переменные в файл
   FileSeek(CheckFile,0,SEEK_END);     // перемещаемся в конец
   FileWrite    (CheckFile, ServerTime , Open[0] ,  AskBid ,S5(MaxSpred),S5(ATR),S4(HI)+"/"+S4(LO), sB  ,  sBS   ,  sBP   ,  sS  ,  sSS   ,  sSP   , ch[0], ch[1], ch[2], ch[3], ch[4] , ch[5] ,PS[0],PS[1],PS[2],PS[3],PS[4],PS[5],PS[6],PS[7], PS[8], PS[9],PS[10],PS[11]);
   FileClose(CheckFile); 
   ArrayInitialize (PS,0); // обнулим значения массива перед следующим запуском  
   ERROR_CHECK("CHECK_VARIABLES");
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

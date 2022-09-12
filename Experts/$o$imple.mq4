//    Success is not final, failure is not fatal:
//    it is the courage to continue that counts.
//                            /Winston Churchill/
           
#define VERSION   "190.220"
#define MAX_RISK  10
#property version    VERSION // yym.mdd
#property copyright  "Hohla"
#property link       "hohla.ru"
#property strict // Указание компилятору на применение особого строгого режима проверки ошибок 

#ifndef TestMode // 
   #define TestMode // код, находящийся здесь, компилируется, если identifier в данный момент не определен командой препроцессора #define.
#endif

//#ifdef TestMode 
//   Print("Test mode"); 
//#else 
//   Print("Normal mode"); 
//#endif


extern short   BackTest=0;
sinput char    Opt_Trades=10; // Opt_Trades Влияет только на оптимизацию, остальные параметры и на опт ина бэктест
sinput float   RF_=0.5;       // RF При оптимизациях отбрасываем
sinput float   PF_=1.5;       // PF резы с худшими показателями
sinput char    MO_=0;         // MO множитель спреда, т.е. MO=MO_ * Spred
extern float   Risk= 0;       // Risk процент депо в сделке (на реале задается в файле #.csv) 
sinput char    MM=1;          // 1..4 см. ММ: 
extern bool    Real=false;    // Real
extern char    CustMax=0;     // 0-Bal, 1-RF, 2-iRF, 3-MO/SD - максимизируемый при оптимизации параметр
extern string  SkipPer="";    // 08-12 пропустить период при оптимизации 
      sinput string  z2="          -  P I C    L E V E L S  - ";
extern char FltLen=10;  // FltLen=5..15/5 минимальная длина флэта; и бары от пробиваемого пика до его ложняка в SIG_MIRROR_LEVELS()
extern char PicCnt=2;   // PicCnt=1..3 кол-во отскоков для флэтa и ложняка
extern char Target=1;   // Target=-2..2 целевой уровень: >0~макс. <0~средн движение от 1-последнего, 2-разворотного пика  
extern char Power=3;    // Power=4..12 передний и задний фронты АТР*Front 
extern char Trd=0;      // Trd=0..1 С непробитым трендовым должны быть
extern char Pot=0;      // Pot=0..1 Back>Front
extern char Rev=0;      // Rev=0..1 Пробивший охтябы одну вершину.
extern char Tch=0;      // Tch=0..1 Пик дб без касаний при Tch=0
      sinput string  z3="          -  T R E N D   S I G N A L S  - ";
extern char  TrGlb=0;   // TrGlb=0..2 всегда "И" Глобальный тренд определяется пробоем: 2-Первых Уровней, 1-Уровней серединки, 3-образование первого уровня, 0-без Глобала       
extern char  TrDblPic=2;// TrDblPic=2..3 Двойная/тройная вершинка 
extern char  TrImp=4;   // TrImp=2..8/2 порог срабатывания (*ATR) импульса из пика.
extern char iDblTop=0; // iDblTop=0..3   сложение сигналов тренда при входе:  1(AND) суммирование с остальными; 0 без данного сигнала; 
extern char iFltBrk=0; // iFltBrk=0..3   2(OR) достаточно одного сигнала, противоположные отменяются;  
extern char iImp=0;    // iImp=0..3      3(NO) противоположные отменяются.           
      sinput string  z5="          -  A  T  R  - ";       
extern char  A=15;    // A=10..30  кол-во бар^2 для медленного АТР
extern char  a=5;     // a=2..6  кол-во бар^2 для быстрого atr
//extern char  dAtr=10; // dAtr=6..12  ATR=ATR*dAtr*0.1 - минимальное приращение для расчета стопа, тейка и дельты входа: 
extern char  Ak=1;    // Ak=1..3 ATR: 0-(atr,ATR)/2 1~atr 2~min 3~max
extern char  PicVal=20;  // PicVal=10..50  Допуск  Atr.Lim: АТР%
      sinput string  z6="          -  I N P U T S - ";
//extern char  iFrstLev=1;// iFrstLev=-3..3 вход в районе Первых Уровней: |iFrstLev|*ATR / <0 уровня серединки
extern char  iSignal=2; // iSignal=0..4 1-FalseLev, 2-FIRST_LEVELS, 3-FIRST_LEVELS_CONFIRM
extern char  iParam=1;  // iParam=0..4 параметры сигнала   
extern char  Iprice=2;  // Iprice=1..2  1~FirstLev, 2~MidLev 
extern char  D=0;       // D=-5..5 -1Tr,0Mid,1Pic >0~Lim, <0~Stop относительно текущей цены (D+1)*(D+1)*ATR/10  (ATR=dAtr*ATR/10)      
      sinput string  z7="          -  S T O P   - ";
extern char  sMin=0; // sMin=-3..3 if (STOP<sMin*ATR/2) отодвигаем <0 стоп; >0-вход.
extern char  sMax=0; // sMax=-3..3 if (STOP>sMax*ATR) <0~NoTrade; >0-приближаем вход. Где ATR=ATR*dAtr*0.1;
extern char  Stp=1;  // Stp=1..3 стоп=0.4 0.9 1.6 2.5 3.6 4.9 6.4 
extern char  Prf=0;  // Prf=-6..6  0~20ATR, <0~ATR*|Prf|, >0~Back*1/4,1/3,1/2...
extern char  minPL=0; // minPL=-6..6/2 если P/L хуже minPL/2: <0 не открываемся; >0 вход отодвигается для улучшения P/L
   sinput string  z9="          -  O U T P U T  - ";
extern char  oImp=0;    // oImp=0..2 отсутвствие отскока величиной ATR*oImp на первом баре от входа  
extern char  oSig=0;    // oSig=-1..1 закрытие при: -1~противоположном сигнале. 1~отсутвствии сигнала в данном направлении
extern char  oFlt=0;    // oFlt=0..4 флэт перед лимитником на расстоянии ATR*0.5*oFlt   
extern char  oPrice=0;  // oPrice=-1..2 тейк: -1~MaxFromBuy; 0..2~Profit=MAX(BUY,Bid) + oPrice*ATR/2
extern char  Trl=0;     // Trl=-4..4 MinBack=Trl*|ATR|. <0~от стопа; >0~от входа  
      sinput string  z10="          -  T I M E  - ";
extern char  ExpirBars=6;   // ExpirBars=-x..23 <0~удаление отложника при пропадании сигнала. 0~при новом. >0~новый ордер не ставится, пока старый не удалится по экспирации  
extern char  Tper=20;       // Tper=0..23 при Tin=0 кол-во бар удержания открытой позы; при Tin>0 кол-во часов разрешенной торговли Tin..Tin+Tper  
extern char  Tin=0;         // Tin=0..23 Время разрешения торговли (количество БАР с открытия сессии) Tout=Tin+Tper; if (Tout>23) Tout-=24; 
extern char  tPrice=0;     // TimePrf=-1..2 тейк: -1~MaxFromBuy; 0..2~Profit=MAX(BUY,Bid) + tPrice*ATR/2


short    PocScale=5, Per, SkipFrom=0, SkipTo=0, LastTestDD,  HistDD,// PocScale=1..10 множитель длины РОС
         LotDigits, DIGITS, Exp, ExpTotal, TimeOn, TimeOff, TimeHold;         
float    MaxFromBuy, MinFromBuy, MaxFromSell, MinFromSell, RevBUY, RevSELL, ASK, BID, PS[20], ch[6], CurDD, 
         InitDeposit, MaxSpred, StopLevel, Spred, MinStop,  MaxStop, Lot, Aggress=1, PerAdapter,  // максимальный суммарный риск всех позиций в одну сторону (все лонги или все шорты), максимальная загрузка маржи   
         DayMinEquity,  FullDD, Equity, MaxEquity, DrawDown,  MaxRisk=10,  MaxMargin=float(0.7); // максимальный суммарный риск всех позиций в одну сторону (все лонги или все шорты), максимальная загрузка маржи
datetime BarTime, LastBarTime, Expiration, LastDay, TestEndTime, ExpMemory, BuyTime, SellTime;
string   history="", OptPeriod="UnKnown", ExpID, Company, ExpertName="$o$imple"+VERSION, SYMBOL, StartDate,
         Prm1,Prm2,Prm3,Prm4,Prm5,Prm6,Prm7,Prm8,Prm9,Prm10,Prm11,Prm12,Prm13, 
         Str1,Str2,Str3,Str4,Str5,Str6,Str7,Str8,Str9,Str10,Str11,Str12,Str13;
char     UP, DN;   
uchar    ExpertsTotal;       
bool     PocAllocation=1;  // PocAllocation=0..1 показывать/скрыть распределение POC
color    PocColor    = clrGray, MaxPocColor = clrRed;  // цвет гистограммы POC,  цвет максимального POC
int      Today, bar=1, Magic, TesterFile, DailyConfirmation[100000];
ulong    MagicLong;
         
#include <stdlib.mqh> 
#include <iGRAPH.mqh> 
#include <lib_ATR.mqh>
#include <lib_POC.mqh>  // сортировка фракталов 
#include <lib_PIC.mqh>  // сортировка фракталов
#include <lib_Flat.mqh>    // 
#include <SERVICE.mqh>       // сохранение/восстановление параметров, отчеты и др. заморочки
#include <iCnt.mqh>
#include <iINPUT.mqh>
#include <iSIG_FALSE_BREAK.mqh>
#include <iSIG_FIRST_LEVELS_CONFIRM.mqh>
#include <iSIG_FIRST_LEVELS.mqh>
#include <iSIG_TURTLE.mqh>
#include <lib_REZENKO.mqh> // 
#include <iOUTPUT.mqh>
//#include <iREPORT.mqh>       // сохранение/восстановление параметров, отчеты и др. заморочки

#include <iERROR.mqh>    // проверка исполнения
#include <MM.mqh> 
#include <ORDERS.mqh>


void OnTick(){ // 2015.10.22. 23:00 
   if (Real && float(Ask-Bid)>MaxSpred) MaxSpred=float(Ask-Bid);
   if (Time[0]==BarTime) {CHECK_OUT(); return;}  // Сравниваем время открытия текущего(0) бара 
   
   DAY_STATISTIC(); // расчет параметров DD, Trades, массив с резами сделок
   if (TimeYear(Time[bar])>=SkipFrom && TimeYear(Time[bar])<SkipTo){ORDER_CHECK(); FINE_TIME(); return;}
   for (Exp=1; Exp<=ExpTotal; Exp++){// осуществление перебора всех строк с входными параметрами за один тик (только для реала) 
      if (!EXPERT_SET()) continue; // выбор параметров эксперта из строки Exp массива CSV, сформированного из файла #.csv
      ORDER_CHECK();  // ПАРАМЕТРЫ ОТКРЫТЫХ И ОТЛОЖЕННЫХ ПОЗ
      if (COUNT()){
         if (BUY.Val || SEL.Val){
            OUTPUT();   // ВЫХОДЫ 
            TRAILING(); // ТРЕЙЛИНГИ
            }
         DAY_STATISTIC();
         if (FINE_TIME()){ // ОГРАНИЧЕНИЕ ПЕРИОДА ТОРГОВЛИ
            INPUT(); 
            MODIFY();   // МОДИФИКАЦИЯ, УДАЛЕНИЕ ОРДЕРОВ
            if (setBUY.Val || setSEL.Val){ // если осалась потребность выставления нового ордера 
               if (!Real){// на тестах ставим сразу, расчитая лот
                  if (Risk>0) Lot=MM(MathMax(setBUY.Val-setBUY.Stp, setSEL.Stp-setSEL.Val), Risk, SYMBOL); else Lot=float(0.1);
                  ORDERS_SET(Risk);
                  }  
               else ORDERS_COLLECT();  // не реале собираем в файл, чтобы потом разом выставить, разделив маржу поровну с учетом ролловера
         }  }  }
      AFTER();
      } 
   END(); // Print("After BarTime=",BarTime);  // отчет о проведенных операциях, сохранение текущих параметров       
   BarTime=Time[0];   //Print("New BarTime=",BarTime); 
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool FINE_TIME(){ // РАЗРЕШЕННОЕ ВРЕМЯ
   if (Tin==0) return (true); // ограничение по времени не работает
   int CurBar=int((TimeHour(Time[0])*60+Minute())/Period()); // приводим текущее время в количесво бар с начала дня
   if ((TimeOn<TimeOff &&  TimeOn<=CurBar && CurBar<TimeOff) ||                // 00:00 -нельзя- Tin -МОЖНО- Tout -нельзя- 23:59
       (TimeOn>TimeOff && (TimeOn<=CurBar || (0<=CurBar && CurBar<TimeOff)))) //  00:00-можно / Tout-НЕЛЬЗЯ-Tin / можно-23:59  
      return (true);
   // Закрытие всех поз в период запрета торговли    
   BUYSTP=0; BUYLIM=0; SELSTP=0; SELLIM=0; // отложники херим безоговорочно
   if (BUY.Val>0) CLOSE_BUY(tPrice);
   if (SEL.Val>0) CLOSE_SELL(tPrice);
   if (Real) ERROR_CHECK("FINE_TIME"); 
   return (false);     
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void WeekEnd(){   // закрываемся в конце недели 
   if (TimeDayOfWeek(Time[1])==5 && TimeHour(Time[0])>21){  // && TimeMinute(Time[0])>=60-Period()
      BUY.Val=0; SEL.Val=0; setBUY.Val=0; setSEL.Val=0;
   }  }
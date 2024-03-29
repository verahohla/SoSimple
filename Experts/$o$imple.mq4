#define NAME  "SoSimple"  
#define VER   "200.212"
#define MAX_RISK  10
#property version    VER // yym.mdd
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
extern char Power=3;    // Power=3..12 FrontVal>АТР*Power 
extern char Trd=0;      // unused! Trd=0..1 С непробитым трендовым должны быть (Trd=1)
extern char Pot=1;      // Pot=1..3 BackVal>ATR*Power*Pot/2
extern char Rev=0;      // Rev=0..1 Пробивший охтябы одну вершину (Rev=1)
extern char Tch=1;      // unused! Tch=0..1 Пик дб без касаний при Tch=0
extern char Poc=1;      // Poc=1..5 POC по макс. кол-ву: 1-бар, 2-отскоков, 3-сила отскоков, 4-фронт, 5-пиков бар
      sinput string  z3="          -  T R E N D   S I G N A L S  - ";
extern char fGlb=0;     // TrGlb=0..2 Глоб.Тренд=пробой: 2-Первых Уровней, 1-Уровней серединки 0-без Глобала       
extern char iFlt=0;     // iFlt=0..1  Выход из флэта противоположно входу 
extern char iPic=0;     // iPic=0..2  Кол-во пробитых пиков для изменения направления 
extern char iImp=0;     // iImp=0..2  Импульс больше Atr.Fast*(iImp+2)                     
      sinput string  z5="          -  A  T  R  - ";       
extern char  A=15;    // A=10..30  кол-во бар^2 для медленного АТР
extern char  a=5;     // a=2..6  кол-во бар^2 для быстрого atr
extern char  Ak=1;    // Ak=0..3 ATR: 0~slow, 1~fast, 2~min, 3~max
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
extern char  Stp=1;  // Stp=1..4 стоп=0.4 0.9 1.6 2.5 3.6 4.9 6.4 
extern char  Prf=0;  // Prf=-6..6  0~20ATR, <0~ATR*|Prf|, >0~Back*1/4,1/3,1/2...
extern char  minPL=0; // minPL=-6..6/2 если P/L хуже minPL/2: <0 не открываемся; >0 вход отодвигается для улучшения P/L
   sinput string  z9="          -  O U T P U T  - ";
extern char  oImp=0;    // oImp=0..5 отсутвствие отскока (MaxFromBuy-Buy)/noise>oImp/10 после входа  
extern char  oSig=0;    // oSig=-3..3 пропадание сигнала в данном направлении, или появление противоположного
extern char  oDblTch=0;     //  второй подход к уровню

extern char  oFlt=0;    // oFlt=-3..3 флэт после открытия (Poc>3)   
extern char  oPrice=0;  // oPrice=-2..2 Профит выхода: 2-MaxFromBuy, 1-безубыток, 0-по текущей,  Либо стоп: -1~стоп за последний пик, -2~безубыток при отскоке на ATR*oPrice   
extern char  oStop=1;   // unused  BePrice=0..1 стоп безубытка
extern char  Trl=0;     // Trl=-4..4 MinBack=Trl*|ATR|. <0~от стопа; >0~от входа  
      sinput string  z10="          -  T I M E  - ";
extern char  ExpirBars=6;  // ExpirBars=-x..23 <0~удаление отложника при пропадании сигнала. 0~при новом. >0~новый ордер не ставится, пока старый не удалится по экспирации  
extern char  Tper=20;      // Tper=0..23 при Tin=0 кол-во бар удержания открытой позы; при Tin>0 кол-во часов разрешенной торговли Tin..Tin+Tper  
extern char  Tin=0;        // Tin=0..23 Время разрешения торговли (количество БАР с открытия сессии) Tout=Tin+Tper; if (Tout>23) Tout-=24; 
//extern char  tPrice=0;     // TimePrf=-3..3 TimeOver 3-MaxFromBuy, 2-Open[0], 1-безубыток. Либо стоп: -1~стоп за последний пик, 2~безубыток при отскоке на ATR*x 


short    PocScale=5, Per, SkipFrom=0, SkipTo=0, LastTestDD,  HistDD,// PocScale=1..10 множитель длины РОС
         LotDigits, DIGITS, Exp, ExpTotal, TimeOn, TimeOff, TimeHold;         
float    MaxFromBuy, MinFromBuy, MaxFromSell, MinFromSell, RevBUY, RevSELL, ASK, BID, PS[20], ch[6], CurDD, 
         InitDeposit, MaxSpred, StopLevel, Spred, MinStop,  MaxStop, Lot, Aggress=1, PerAdapter, PL,  // максимальный суммарный риск всех позиций в одну сторону (все лонги или все шорты), максимальная загрузка маржи   
         DayMinEquity,  FullDD, Equity, MaxEquity, DrawDown,  MaxRisk=10,  MaxMargin=float(0.7); // максимальный суммарный риск всех позиций в одну сторону (все лонги или все шорты), максимальная загрузка маржи
datetime BarTime, LastBarTime, Expiration, LastDay, TestEndTime, BuyTime, SellTime;
string   ChartHistory="", SYMBOL, Hist, filename, ID, Company, OptPeriod,
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
#include <lib_POC.mqh>  // сортировка фракталов 
#include <lib_PIC.mqh>  // сортировка фракталов
#include <SERVICE.mqh>       // сохранение/восстановление параметров, отчеты и др. заморочки
#include <iCnt.mqh>
#include <iINPUT.mqh>
#include <iSIG_FALSE_BREAK.mqh>
#include <iSIG_FIRST_LEVELS_CONFIRM.mqh>
#include <iSIG_FIRST_LEVELS.mqh>
#include <iSIG_TURTLE.mqh>
#include <iOUTPUT.mqh>
//#include <lib_REZENKO.mqh> // 
//#include <iREPORT.mqh>       // сохранение/восстановление параметров, отчеты и др. заморочки

#include <ERRORs.mqh>    // проверка исполнения
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
               if (Real) ORDERS_COLLECT();// не реале собираем в файл, чтобы потом разом выставить, разделив маржу поровну с учетом ролловера 
               else{// на тестах ставим сразу, расчитая лот
                  if (Risk>0) Lot=MM(MathMax(setBUY.Val-setBUY.Stp, setSEL.Stp-setSEL.Val), Risk, SYMBOL); else Lot=float(0.1);
                  ORDERS_SET();
         }  }  }  }
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
   if (BUY.Val>0) CLOSE_BUY (BREAK_EVEN_PROFIT,"TimeOver");
   if (SEL.Val>0) CLOSE_SELL(BREAK_EVEN_PROFIT,"TimeOver");
   if (Real) ERROR_CHECK("FINE_TIME"); 
   return (false);     
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void WeekEnd(){   // закрываемся в конце недели 
   if (TimeDayOfWeek(Time[1])==5 && TimeHour(Time[0])>21){  // && TimeMinute(Time[0])>=60-Period()
      BUY.Val=0; SEL.Val=0; setBUY.Val=0; setSEL.Val=0;
   }  }
   
/*    T O   D O
выход при повторном подходе к цене входа
вход на ложняке чуть дальше серединки от движения после ложняка
второй отскок от уровня не отраьбатываем, закрываемся


*/   
   
#define VER   "200.212"
#property copyright "Hohla"
#property link      "mail@hohla.ru"
#property version    VER // yym.mdd
#property description "При совпадении PowerCheck вершин начинается верхний флэтовый уровень" 
#property description "Нижний флэтовый уровень чертится по мимимуму между ними." 
#property description "При пробитии одного из этих уровней на LevAccuracy*atr фиксируется начало импульса ложняка и чертится соответствующпй уровень." 
#property strict // Указание компилятору на применение особого строгого режима проверки ошибок 
#property indicator_chart_window 
#property indicator_buffers 20
#property indicator_color1 clrCadetBlue      // Flt.Hi.P: Флэтовые уровни с кол-вом    
#property indicator_color2 clrCadetBlue      // Flt.Lo.P: отскоков больше PowerCheck  
#property indicator_color3 clrLightSlateGray // F[StrHi].P: Хотябы один
#property indicator_color4 clrLightSlateGray // F[StrLo].P: отскок
#property indicator_color5 clrLightCoral     // UP3: Уровни покупки
#property indicator_color6 clrCornflowerBlue // DN3: и продажи

#property indicator_color7 clrOrange      // Fls.Max: максимум ложняка (для постановки стопа)
#property indicator_color8 clrOrange      // Fls.Min: минимум ложняка (для постановки стопа)
#property indicator_color9 clrOrange      // Fls.Buy: уровень покупки для ложняка вверх
#property indicator_color10 clrOrange     // Fls.Sel: уровень продажи для ложняка вниз
#property indicator_color11 clrSilver     // Fls.UpEnd: противоположный (нижний) уровень канала ложняка вверх
#property indicator_color12 clrSilver     // Fls.DnEnd: противоположный (верхний) уровень канала ложняка вниз
#property indicator_color13 clrSilver     // Fls.UpStart: пробитая ложняком верхняя граница
#property indicator_color14 clrSilver     // Fls.DnStart: пробитая ложняком нижняя граница

#property indicator_color15 clrLightCoral    // FirstUp: первый трендовый уровень не продажу
#property indicator_color16 clrCornflowerBlue// FirstDn: первый трендовый уровень не покупку
#property indicator_color17 clrLightCoral    // F[StrLo].P: уровень поддержки при восходящем тренде, или граница флэта при двойном пике
#property indicator_color18 clrCornflowerBlue// F[StrHi].P: уровень сопротивления при нисходящем тренде, или граница флэта при двойном пике
#property indicator_color19 clrRed     // TargetUp: целевой уровень окончания движения вверх на основании измерения предыдущих безоткатных движений
#property indicator_color20 clrGreen    // TargetDn: целевой уровень окончания движения вниз  на основании измерения предыдущих безоткатных движений

//#property indicator_width1 5
//#property indicator_width2 5
////#property indicator_width7 2
////#property indicator_width8 2
#property indicator_width15 3
#property indicator_width16 3
#property indicator_width17 2 // тренд вверх (жирная поддержка АпТренда)
#property indicator_width18 2 // тренд вниз (жирное сопротивление ДаунТренда)
      sinput string  z2="          -  P I C    L E V E L S  - ";
extern char FltLen=10;  // FltLen=5..15/5 минимальная длина флэта; и бары от пробиваемого пика до его ложняка в SIG_MIRROR_LEVELS()
extern char PicCnt=2;   // PicCnt=1..3 кол-во отскоков для флэтa и ложняка
extern char Target=1;   // Target=-2..2 целевой уровень: >0~макс. <0~средн движение от 1-последнего, 2-разворотного пика  
extern char Power=9;    // Power=3..12 FrontVal>АТР*Power 
extern char Trd=0;      // unused! Trd=0..1 С непробитым трендовым должны быть (Trd=1)
extern char Pot=1;      // Pot=1..3 BackVal>ATR*Power*Pot/2
extern char Rev=0;      // Rev=0..1 Пробивший охтябы одну вершину.
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
// переменные из эксперта
char  iFrstLev=1; // iFrstLev=-3..3 вход в районе Первых Уровней: DELTA(|iFrstLev|+1) / <0 уровня серединки
char  iParam=1;   // used in  Максимальный вылет ложняка = ATR*(iParam+1)  /lib_Flat.mqh
char  iSignal=1;  // обработка сигнала ложняка при iSignal=1 (lib_Flat.mqh)
char  D=0;        // (lib_Flat.mqh)
char  Trl=3;      // Trl=-4..4 MinBack=Trl*|ATR|. <0~от стопа; >0~от входа


int      bar, Magic;
ushort   PocScale = 5;  // PocScale=1..10 множитель длины РОС
double   I0[],I1[],I2[],I3[],I4[],I5[],I6[],I7[],I8[],I9[],I10[],I11[],I12[],I13[],I14[],I15[],I16[],I17[],I18[],I19[]; //  ложняки    
datetime BuyTime, SellTime;
bool    PocAllocation=1, Real=false, Modify;  // PocAllocation=0..1 показывать/скрыть распределение POC
color   PocColor    = clrBlack;  // цвет гистограммы POC
color   MaxPocColor = clrRed;   // цвет максимального POC
string SYMBOL=Symbol(),Company;   
string ExpertName="iPIC-"+VER;  // идентификатор графических объектов для их удаления

struct PRICE{    // 
   //PICS Sig1,Sig2;      // вложенная структура предварительных сигналов и сигналов подтверждения
   datetime T;    // последнее время обновления зоны
   char Sig;         // отслеживаемый паттерн
   float Mem, Val,Stp,Prf;  // 
   }; 
PRICE setSEL, setBUY, SEL, BUY;


#include <lib_POC.mqh>     // 
#include <lib_PIC.mqh>     // 
#include <lib_TRG.mqh> 
//#include <lib_REZENKO.mqh> 
//#include <lib_Triangle.mqh>
 // 
#include <iGRAPH.mqh>

int OnInit(){//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   IndicatorBuffers(20);  IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);   SetIndexBuffer(0,I0);   // UP2: сильные уровни с кол-вом 
   SetIndexStyle(1,DRAW_LINE);   SetIndexBuffer(1,I1);   // DN2: отскоков больше PowerCheck
   
   SetIndexStyle(2,DRAW_LINE);   SetIndexBuffer(2,I2);   // F[StrHi].P: хотябы один 
   SetIndexStyle(3,DRAW_LINE);   SetIndexBuffer(3,I3);   // F[StrLo].P: отскок
   
   SetIndexStyle(4,DRAW_LINE);   SetIndexBuffer(4,I4);   // UP3: уровни покупки
   SetIndexStyle(5,DRAW_LINE);   SetIndexBuffer(5,I5);   // DN3: и продажи
   
   SetIndexStyle(6,DRAW_LINE);   SetIndexBuffer(6,I6);   // Fls.Max: максимум ложняка (для постановки стопа)
   SetIndexStyle(7,DRAW_LINE);   SetIndexBuffer(7,I7);   // Fls.Min: минимум ложняка (для постановки стопа)
    
   SetIndexStyle(8,DRAW_LINE);   SetIndexBuffer(8,I8);   // Fls.Buy: уровень покупки для ложняка вверх
   SetIndexStyle(9,DRAW_LINE);   SetIndexBuffer(9,I9);   // Fls.Sel: уровень продажи для ложняка вниз
   
   SetIndexStyle(10,DRAW_LINE);  SetIndexBuffer(10,I10); // Fls.UpEnd: противоположный (нижний) уровень канала ложняка вверх
   SetIndexStyle(11,DRAW_LINE);  SetIndexBuffer(11,I11); // Fls.DnEnd: противоположный (верхний) уровень канала ложняка вниз
   
   SetIndexStyle(12,DRAW_LINE);  SetIndexBuffer(12,I12); // Fls.UpStart: пробитая ложняком верхняя граница
   SetIndexStyle(13,DRAW_LINE);  SetIndexBuffer(13,I13); // Fls.DnStart: пробитая ложняком нижняя граница
   
   SetIndexStyle(14,DRAW_LINE);  SetIndexBuffer(14,I14); // FirstUp: первый трендовый уровень не продажу
   SetIndexStyle(15,DRAW_LINE);  SetIndexBuffer(15,I15); // FirstDn: первый трендовый уровень не покупку
   
   SetIndexStyle(16,DRAW_LINE);  SetIndexBuffer(16,I16); // F[StrHi].P: уровень сопротивления при нисходящем тренде, или граница флэта при двойном пике
   SetIndexStyle(17,DRAW_LINE);  SetIndexBuffer(17,I17); // F[StrLo].P: уровень поддержки при восходящем тренде, или граница флэта при двойном пике
   
   SetIndexStyle(18,DRAW_LINE);  SetIndexBuffer(18,I18); // TargetUp: целевой уровень окончания движения вверх на основании измерения предыдущих безоткатных движений
   SetIndexStyle(19,DRAW_LINE);  SetIndexBuffer(19,I19); // TargetDn: целевой уровень окончания движения вниз  на основании измерения предыдущих безоткатных движений
   
   // iName=iName+"("+DoubleToStr(A,0)+") ";   
   IndicatorShortName(ExpertName);
   SetIndexLabel(0,ExpertName);
   LABEL(90,ExpertName);
   LABEL(90,"Bars="+S0(Bars)+", ChartTime: "+TimeToStr(Time[Bars-1],TIME_DATE)+"-"+TimeToStr(Time[1],TIME_DATE)); 
   LABEL(10," -  P I C    L E V E L S  -");
   LABEL(5,"FltLen="+S0(FltLen));
   LABEL(5,"PicCnt="+S0(PicCnt));
   LABEL(5,"Target="+S0(Target));
   LABEL(5,"Power="+S0(Power));
   LABEL(5,"Trd="+S0(Trd));
   LABEL(5,"Pot="+S0(Pot));
   LABEL(5,"Rev="+S0(Rev));
   LABEL(5,"Tch="+S0(Tch));
   LABEL(5,"Poc="+S0(Poc));
   LABEL(10," -  T R E N D   S I G N A L S  -");
   LABEL(5,"fGlb="+S0(fGlb));
   LABEL(5,"iFlt="+S0(iFlt));
   LABEL(5,"iPic="+S0(iPic));
   LABEL(5,"iImp="+S0(iImp));
   LABEL(10," -  A  T  R  -");
   LABEL(5,"A="+S0(A));
   LABEL(5,"a="+S0(a));
   LABEL(5,"Ak="+S0(Ak));
   LABEL(5,"PicVal="+S0(PicVal));
   BarsInDay=short(60*24/Period()); // кол-во бар в дне
   CHART_SETTINGS(); // настройки вненшего вида графика 
   if (ATR_INIT()==INIT_FAILED) {Print("OnInit(): ATR_INIT()=INIT_FAILED"); return(INIT_FAILED);}
   return(PIC_INIT());  // (0)=Успешная инициализация. Результат выполнения функции OnInit() анализируется терминалом только если программа скомпилирована с использованием #property strict      
   }                    // НЕнулевой код возврата означает неудачную инициализацию и генерирует событие Deinit с кодом причины деинициализации REASON_INITFAILED



void start(){
   int UnCounted=Bars-IndicatorCounted()-PicPer-1;
   for (bar=UnCounted; bar>0; bar--){ //Print(" Bars=",Bars," IndicatorCounted=",IndicatorCounted()," UnCounted=",UnCounted, " bar=",bar);
      if (!PIC()) continue; // ОСНОВНОЙ ЦИКЛ ПОИСКА УРОВНЕЙ 
      if (TimeDayOfWeek(Time[bar])==1 && TimeHour(Time[bar])<TimeHour(Time[bar+1])) LINE("NewWeek",  bar,L,   bar,H, clrDeepSkyBlue,2);
      POC_SIMPLE();  // ОПРЕДЕЛЕНИЕ ПЛОТНОГО СКОПЛЕНИЯ БАР БЕЗ ПРОПУСКОВ
      //I0[bar]=F[sH].P;
      //I1[bar]=F[sL].P;
    
      //if (Prn) V(S4(F[14].Flt.Lev)+"/"+S0(F[14].Fls.Phase), High[bar]+0.0010, bar, clrGray);//Print(DTIME(Time[bar])," F[14].Fls.Phase",F[14].Fls.Phase);
      //TRADE_ZONE(2);
      //SIG_SIMPLE();
     //NEW_W();
     //TAPERING_TRIANGLE();
     //I4[bar]=TargetHi; //  LINE("PreTargetHi", bar+1, PreTargetHi,  bar, PreTargetHi, clrOrange,0);
     //I5[bar]=TargetLo; //  LINE("PreTargetLo", bar+1, PreTargetLo,  bar, PreTargetLo, clrOrange,0);
      
      //SIG_TURTLE();   
      //POC(); /* if (PocCnt>2) I3[bar]=PocCenter; */ // ОПРЕДЕЛЕНИЕ ПЛОТНОГО СКОПЛЕНИЯ БАР БЕЗ ПРОПУСКОВ   
         //LINE(" HI", bar+1,F[HI].P,  bar, F[HI].P, clrPink,3);          LINE(" FstCenter", bar+1,F[HI].PocPrice,  bar, F[HI].PocPrice, clrPink,0);
         //LINE(" LO=", bar+1,F[LO].P,  bar, F[LO].P, clrPowderBlue,3);   LINE(" FstCenter", bar+1,F[LO].PocPrice,  bar, F[LO].PocPrice, clrPowderBlue,0);
     //I14[bar]=F[HI].P;
     //I15[bar]=F[LO].P;
      //if (TrGlb>0){   
      //   if (Trnd.Global<0) I16[bar]=High[bar]+Atr.Lim; // флэтовый уровень сверху (не менее двух отскоков)
      //   if (Trnd.Global>0) I17[bar]=Low [bar]-Atr.Lim; // флэтовый уровень снизу  (не менее двух отскоков)
      //   } 
      //char     UP, DN;
      //TREND_FILTER (iDblTop, iImp, iFltBrk, UP, DN);   
      //if (Trnd.Up>0) I16[bar]=Low [bar]; 
      //if (Trnd.Dn>0) I15[bar]=High[bar]; 
     
   }  }/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
int deinit(){
	CLEAR_CHART();// удаляем все свои линии
	return(0);
   }
void REPORT(string Missage){ // собираем все сообщения экспертов в одну кучу 
   Print("REPORT of ",Magic,": ",Missage);
   }
  

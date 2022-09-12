#property copyright "Hohla"
#property link      "hohla@mail.ru"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 SkyBlue
#property indicator_color2 RoyalBlue
#property strict // Указание компилятору на применение особого строгого режима проверки ошибок 

extern char  A=15;    // A=10..30  кол-во бар^2 для медленного АТР
extern char  a=5;     // a=2..6  кол-во бар^2 для быстрого Atr1
extern char  dAtr=10; // dAtr=6..12  Atr2=Atr2*dAtr*0.1 - минимальное приращение для расчета стопа, тейка и дельты входа: 
extern char  Ak=1;    // Ak=1..3 Atr2: 0-(Atr1,Atr2)/2 1~Atr1 2~min 3~max
extern char  PicVal=20;  // PicVal=10..50  Допуск  Atr.Lim: АТР%

double Atr1[],Atr2[];
bool   Real=false, Modify;
int    bar, Magic;
string SYMBOL,Company;   
string ExpertName="iATR";  // идентификатор графических объектов для их удаления

#include <iGRAPH.mqh>
#include <lib_ATR.mqh> 

int OnInit(void){//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   string short_name;
   IndicatorBuffers(3); // т.к. temp[] тоже считается
   SetIndexStyle(0,DRAW_LINE);    SetIndexBuffer(0,Atr1);
   SetIndexStyle(1,DRAW_LINE);    SetIndexBuffer(1,Atr2);
   short_name="Atr1("+DoubleToStr(a,0)+"), Atr2("+DoubleToStr(A,0)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   if (ATR_INIT()==INIT_FAILED) {Print("OnInit(): ATR_INIT()=INIT_FAILED"); return(INIT_FAILED);}
   return (INIT_SUCCEEDED); // "0"-Успешная инициализация.
   }//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

int start(){//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   int BarsToCount=Bars-IndicatorCounted()-1;
   
   for (bar=BarsToCount; bar>0; bar--){
      ATR_COUNT();
      Atr1[bar]=Atr.Fast;
      Atr2[bar]=Atr.Slow;
      }
   
   ////Print("Start Atr2(",a,",",A,") Bars=",Bars," IndicatorCounted=",IndicatorCounted()," BarsToCount=",BarsToCount);
   //for (bar=BarsToCount; bar>0; bar--){
   //   HL[bar]=High[bar]-Low[bar]; 
   //   //if (bar>BarsToCount-2 || bar<3) Print("HL[",bar,"]=",DoubleToStr(HL[bar],Digits-1)," Time[",bar,"]=",TimeToStr(Time[bar],TIME_DATE | TIME_MINUTES));
   //   }
   //for (bar=BarsToCount; bar>0; bar--){
   //   Atr1[bar]=iMAOnArray(HL,0,a,0,MODE_SMA,bar); // Быстрый
   //   Atr2[bar]=iMAOnArray(HL,0,A,0,MODE_SMA,bar); // Мэдлэнный
   //   //if (bar>BarsToCount-2 || bar<3) Print("Atr1[",bar,"]=",DoubleToStr(Atr1[bar],Digits-1)," Atr2[",bar,"]=",DoubleToStr(Atr2[bar],Digits-1));
   //   }
   return(0);   
   }//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
  
void REPORT(string Missage){ // собираем все сообщения экспертов в одну кучу 
   Print("REPORT of ",Magic,": ",Missage);
   }   


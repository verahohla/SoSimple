ushort SlowAtrPer, FastAtrPer; 
float ATR;

struct AtrStruct{  //  C Т Р У К Т У Р А   A T R
   float Fast;   // 
   float Slow;   //
   float Lim;    // точность совпадения уровней
   float Max;
   float Min;
   }Atr;  

int ATR_INIT(){
   if (a<=0)   {Print("ATR_INIT(): a<=0");   return(INIT_FAILED);}
   if (A<=0)   {Print("ATR_INIT(): A<=0");   return(INIT_FAILED);}
   if (a>A)    {Print("ATR_INIT(): a>A");    return(INIT_FAILED);}
   Print("ATR_INIT(): "," bar=",bar,"  Bars=",Bars," Time[bar]=",DTIME(Time[bar])," Time[1]=",DTIME(Time[1])," Time[Bars]=",DTIME(Time[Bars-1]));
   return (INIT_SUCCEEDED); // Успешная инициализация. Результат выполнения функции OnInit() анализируется терминалом только если программа скомпилирована с использованием #property strict.
   } 
   
bool ATR_COUNT(){  
   Atr.Fast=float(iATR(NULL,0,FastAtrPer,bar)); //Print("atr=",atr);
   Atr.Slow=float(iATR(NULL,0,SlowAtrPer,bar)); //Print("ATR=",ATR);
   if (Atr.Slow==0) return(false);
   if (Atr.Fast>Atr.Slow){
      Atr.Max=Atr.Fast;
      Atr.Min=Atr.Slow;
   }else{ // Atr.Fast<Atr.Slow
      Atr.Max=Atr.Slow;
      Atr.Min=Atr.Fast;
      }
   switch (Ak){// АТР для стопов: 
      default: ATR=(Atr.Fast+Atr.Slow)/20*dAtr; break; // среднее значение 
      case  1: ATR=Atr.Fast;        break;
      case  2: ATR=Atr.Min/10*dAtr; break;
      case  3: ATR=Atr.Max/10*dAtr; break;}
   Atr.Lim=ATR*PicVal/100;   // допуск уровней в % ATR
   return(true);
   }
   
/* ДАННЫЙ МЕТОД НЕ РАБОТАЕТ НА ТЕСТИРОВАНИИ (В ИНДЮКЕ ВСЕ ОК) ИЗ-ЗА СБОЕВ НА ПРОПУЩЕННЫХ БАРАХ
   fstBUF+=float(High[bar]-Low[bar]);  cntFastBars++; 
   slwBUF+=float(High[bar]-Low[bar]);  cntSlowBars++;
      
   if (cntFastBars<=FastAtrPer)  return(false);// набралось достаточно HL для усреднения
   fstBUF-=float(High[bar+FastAtrPer]-Low[bar+FastAtrPer]);
   Atr.Fast=fstBUF/FastAtrPer; 
      
   if (cntSlowBars<=SlowAtrPer)  return(false);
   slwBUF-=float(High[bar+SlowAtrPer]-Low[bar+SlowAtrPer]);
   Atr.Slow=slwBUF/SlowAtrPer;   
 */  
      
   
  
      
    

    
   
           
ushort SlowAtrPer, FastAtrPer; 
float ATR,fstBUF,slwBUF;
int cntAtrBars;

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
   SlowAtrPer=A*A;
   FastAtrPer=a*a;
   cntAtrBars=0;
   Print("ATR_INIT(): "," bar=",bar,"  Bars=",Bars," Time[bar]=",DTIME(Time[bar])," Time[1]=",DTIME(Time[1])," Time[Bars]=",DTIME(Time[Bars-1]));
   return (INIT_SUCCEEDED); // Успешная инициализация. Результат выполнения функции OnInit() анализируется терминалом только если программа скомпилирована с использованием #property strict.
   } 
   
bool ATR_COUNT(){  
   // ВАРИАНТ-I   ДАННЫЙ МЕТОД НЕ РАБОТАЕТ НА ТЕСТИРОВАНИИ  ИЗ-ЗА СБОЕВ НА ПРОПУЩЕННЫХ БАРАХ, т.е. 
   //             при разной длине истории получаются разные значения индикатора. 
   //float HL=float(High[bar]-Low[bar]);
   //fstBUF+=HL;   
   //slwBUF+=HL;  
   //cntAtrBars++;   
   //if (cntAtrBars<=FastAtrPer)  return(false);// набралось достаточно HL для усреднения
   //fstBUF-=float(High[bar+FastAtrPer]-Low[bar+FastAtrPer]);
   //Atr.Fast=fstBUF/FastAtrPer;    
   //if (cntAtrBars<=SlowAtrPer)  return(false);
   //slwBUF-=float(High[bar+SlowAtrPer]-Low[bar+SlowAtrPer]);
   //Atr.Slow=slwBUF/SlowAtrPer;   
   
   // ВАРИАНТ-II  Расчет ATR с помощью классических индюков, при этом в тестере появляется доп окно с графиками 
   Atr.Fast=float(iCustom(NULL,0,"iATR",FastAtrPer,SlowAtrPer,0,bar));   // сдвоенный АТР по аналогии с библиотечным MQL индюком
   Atr.Slow=float(iCustom(NULL,0,"iATR",FastAtrPer,SlowAtrPer,1,bar));   // (при одинаковых входных параметрах вызывается один раз)
   
   if (Atr.Slow==0 || Atr.Fast==0) return(false);
   if (Atr.Fast>Atr.Slow){
      Atr.Max=Atr.Fast;
      Atr.Min=Atr.Slow;
   }else{ // Atr.Fast<Atr.Slow
      Atr.Max=Atr.Slow;
      Atr.Min=Atr.Fast;
      }
   switch (Ak){// АТР для стопов: 
      default: ATR=Atr.Slow;  break; // 
      case  1: ATR=Atr.Fast;  break;
      case  2: ATR=Atr.Min;   break;
      case  3: ATR=Atr.Max;   break;
      }
   Atr.Lim=ATR*PicVal/100;   // допуск уровней в % ATR
   return(true);
   }
   

      
   
  
      
    

    
   
           
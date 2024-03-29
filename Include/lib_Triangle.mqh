float  MinHL, LastHi;
uchar free, MinHLnum;
datetime PicInterval;
#define  www 8 // кол-во одновременно отслеживаемых формаций

struct Rez{  //  
   int      Phase;   // этап формирования первой формации
   datetime TME;     // общий счетчик
   datetime H1Time;  // время первого хая
   datetime H2Time;  // время второго хая
   datetime H3Time;  // 
   datetime H4Time;
   datetime L1Time;  // --
   datetime L2Time;
   datetime L3Time;
   datetime L4Time;
   float   H1;   // первый хай 
   float   H2;   // перехай вервого хая
   float   H3;   // 
   float   H4;
   float   L1;   // первый лоу (между хаями)
   float   L2;   // ПереЛоу первого лоу
   float   L3;   // 
   float   L4;
   float   H1Front, H2Front, H3Front, L1Front, L2Front, L3Front;
   float   HiLo; // диапазон H1-L2
   float   Poc;
   }; 
Rez W[www];   



void REZENKO_INIT(){
   W[0].Phase=0;
   PicInterval=3600*24*5;  // минимальный  интрервал между макушками, чтобы не отбирались движения длинной в год
   }


   
void TAPERING_TRIANGLE(){// ПОИСК ПЕРВЫХ ПРИЗНАКОВ ФОРМАЦИИ "Голова/Плечи" = понижающийся Хай
   if (!Update) return;  // небыло нового пика
   uchar      w; 
   //int MaxPoc; double MaxPocPrice;
   // ожидание "НедоХай"
   MinHL=99999; 
   free=0;
   //Buy.Pattern=BLOCK;   
   for (w=1; w<www; w++)  TRIANGLE_CHECK(w);
   if (free==0){   // не нашлось свободных подлежащих удалению формаций
      free=MinHLnum; // удалим самую узкую
      //X(TIME(Time[bar])+": X["+S0(free)+"] "+TIME(W[free].H1Time)+" HiLo="+S4(W[free].HiLo), W[free].H1, SHIFT(W[free].H1Time), clrGreen);
      }  
   // ФОРМИРОВАНИЕ ВТОРОГО НЕДОХАЯ 
   if (Dir>0 && F[hi].P<F[HI].P && F[hi].P>F[HI].P-(F[HI].P-F[HI].Back)/3 && LastHi!=F[HI].P){  //  
      LastHi=F[HI].P; // чтобы один и тот же сигнал не записывался в несколько ячеек 
      W[free].Phase=1; // переход к следующей фазе
      W[free].TME=F[hi].T; // общий счетчик
      W[free].H1=F[HI].P;  W[free].H1Time=F[HI].T;    // верхняя граница формации 
      W[free].H2=F[hi].P;  W[free].H2Time=F[hi].T;       W[free].H2Front=F[hi].Frnt; // НедоХай
      W[free].L1=F[hi].P;  W[free].L2Time=F[hi].T;    // нижняя граница, подлежащая коррекции
      int b=iLowest (NULL,0,MODE_LOW ,SHIFT(W[free].H1Time)-SHIFT(F[hi].T),SHIFT(F[hi].T)); // минимум между хаями
      W[free].L1=float(Low [b]);  W[free].L1Time=Time[b];// нижняя крайняя граница треугольника
      W[free].HiLo=W[free].H1-W[free].L1; // диапазон формации для сравнения на случай поиска самого узкого
      V("H1["+S0(free)+"]", W[free].H1, SHIFT(W[free].H1Time), clrGreen);
      V("H2["+S0(free)+"]", W[free].H2, SHIFT(W[free].H2Time), clrGreen);
      LINE("New W["+S0(free)+"].L1="+S4(W[free].L1), SHIFT(W[free].H1Time), W[free].H1, SHIFT(W[free].L1Time), W[free].L1, clrGreen,0);
      LINE("New W["+S0(free)+"].H2="+S4(W[free].H2), SHIFT(W[free].H2Time), W[free].H2, SHIFT(W[free].L1Time), W[free].L1, clrGreen,0);
   }  }
   
     
   
void TRIANGLE_CHECK(uchar w){// ПРОВЕРКА ФОРМАЦИИ "ГОЛОВА/ПЛЕЧИ"
   if (W[w].Phase==0) {free=w; return;} // пропускаем пустые (отработанные) формации
   
   // проверка пробоя сужающихся границ формации
   //if (F[lo].P<W[w].L1) {W[w].Phase=0;  free=w; return;}
   if (W[w].Phase<4){
      
      if (F[hi].P>W[w].H1){ // пробой верхней вершины треугольника
         X("X H1["+S0(w)+"]", F[hi].P, SHIFT(F[hi].T), clrRed); // пробой головы
         W[w].Phase=0;  free=w; return;} // X("X L1["+S0(w)+"]", W[w].L1, SHIFT(W[w].L1Time), clrRed);
      if (F[hi].P>W[w].H2){
         W[w].Phase=1;
         W[w].H2=F[hi].P; W[w].H2Time=F[hi].T;
         V("H2["+S0(w)+"]", W[w].H2, SHIFT(W[w].H2Time), clrGreen);
         LINE("New W["+S0(free)+"].H2="+S4(W[free].H2), SHIFT(W[w].H2Time), W[w].H2, SHIFT(W[w].L1Time), W[w].L1, clrGreen,0);
         }
      if (W[w].L1-F[lo].P>Atr.Lim){ // пробой нижней вершины треугольника
         X("X L1["+S0(w)+"]", F[lo].P, SHIFT(F[lo].T), clrRed); // пробой дна
         W[w].Phase=0;  free=w; return;}   
      
      if (W[w].Phase>1 && F[lo].P<W[w].L2) {W[w].Phase=1;   return;} // break II  phase   
      if (W[w].Phase>2 && F[hi].P>W[w].H3) {W[w].Phase=2;   return;} // break III phase 
      }
      
      
            
   if (W[w].Phase==1 || W[w].Phase==2){// НедоЛоу 2
      if (F[lo].P>W[w].L1 && F[lo].P<(W[w].L1+W[w].H2)/2){ //   && F[lo].T>W[w].TME  && F[lo].T-W[w].L1Time<PicInterval
         W[w].L2=F[lo].P;  W[w].L2Time=F[lo].T;    W[w].TME=F[lo].T; // второй недолоу
         W[w].Phase=2; // переход к следующей фазе
         //DRAW_W(w);
      }  }   
   if (W[w].Phase==2){// НедоХай 3
      if (F[hi].P<W[w].H2 && F[hi].T>W[w].TME && F[hi].T-W[w].H2Time<PicInterval){// && F[hi].Frnt>W[w].L2Front/2
         W[w].Phase=3;// переход к следующей фазе
         W[w].H3=F[hi].P;  W[w].H3Time=F[hi].T;    W[w].TME=F[hi].T;   
      }  }   
   if (W[w].Phase==3){// НедоЛоу 3
      if (F[lo].P>W[w].L2 && F[lo].T>W[w].TME && F[lo].T-W[w].L2Time<PicInterval){//  && F[lo].Frnt>W[w].H3Front/2
         W[w].Phase=4; // переход к следующей фазе
         W[w].L3=F[lo].P;  W[w].L3Time=F[lo].T;    W[w].TME=F[lo].T;    
         
      }  } //if (w==5) A("L3["+S0(w)+"]", W[w].L3, SHIFT(W[w].L3Time), clrRed);  
   if (W[w].Phase==4){
      if (F[hi].P>W[w].H1 && F[hi].T>W[w].TME){// УХОД ВВЕРХ
         W[w].Phase=5;
         W[w].H4=F[hi].P;  W[w].H4Time=F[hi].T;    W[w].TME=F[hi].T; // обновление значения 
         LINE("L3-H4["+S0(w)+"]",   SHIFT(W[w].H4Time), W[w].H4,  SHIFT(W[w].L3Time), W[w].L3, clrRed,0);
         DRAW_W(w);   
         }  
      if (F[lo].P<W[w].L1 && F[lo].T>W[w].TME){// УХОД ВНИЗ
         W[w].Phase=5;
         W[w].L4=F[lo].P;  W[w].L4Time=F[lo].T;    W[w].TME=F[lo].T; // обновление значения 
         LINE("H3-L4["+S0(w)+"]",   SHIFT(W[w].H3Time), W[w].H3,  SHIFT(W[w].L4Time), W[w].L4, clrRed,0);
         DRAW_W(w);   
         }  
      } 
      
   if (W[w].Phase==5){// 
      if (F[lo].P<W[w].L3){
         W[w].Phase=0;
         X("X L3["+S0(w)+"]", F[lo].P, SHIFT(F[lo].T), clrRed);} // пробой головы
      // (F[hi].P>W[w].H2- && F[hi].T>W[w].L3Time){
      if (F[lo].P<W[w].L3+ATR && F[lo].P>W[w].L1 && F[lo].T>W[w].H4Time){
         W[w].Phase=6;
         BUY.Sig=GOGO;
         //Buy.Opn=float(Ask);// серединка второго пика (подтверждающего)
         //Buy.Stp=F[lo].P;   // за первый пик (уровень) 
         //Buy.Prf=W[w].H2;  // треть движения, коснувшегося зоны продажи 
         A("BUY ["+S0(w)+"]", F[lo].P, SHIFT(F[lo].T), clrBlue);// LINE("L3-HH["+S0(w)+"]",   SHIFT(W[w].L3Time), W[w].L3,   SHIFT(F[hi].T), F[hi].P, clrOrange);
         LINE("L3-Buy["+S0(w)+"]",   SHIFT(F[lo].T), F[lo].P,  SHIFT(W[w].L3Time), W[w].L3+ATR, clrYellow,0);   
      }  } 
         
   //if (Prn && (w==9)) Print(ttt," w="+S0(w)+" Phase="+S0(W[w].Phase)+" F[hi]="+S4(W[w].H1)+" F[lo]="+S4(W[w].L2));   
   if (W[w].Phase==6)  W[w].Phase=0;      // конец паттерна
   if (W[w].Phase==0) {free=w; return;}   // при сбросе формации запоминаем освободившийся член
   if (W[w].Phase>1 && W[w].HiLo<MinHL) {MinHL=W[w].HiLo; MinHLnum=w;} // поиск самой узкой на случай недостатка свободного члена    
   }   
 
void DRAW_W(uchar w){
   //if (w!=3) return;
   V("H1 ["+S0(w)+"]", W[w].H1, SHIFT(W[w].H1Time), clrGreen);
   LINE("H1-L1["+S0(w)+"]",   SHIFT(W[w].H1Time), W[w].H1,  SHIFT(W[w].L1Time), W[w].L1, clrGreen,0);   
   LINE("L1-H2["+S0(w)+"]",   SHIFT(W[w].H2Time), W[w].H2,  SHIFT(W[w].L1Time), W[w].L1, clrGreen,0);
   LINE("H2-L2["+S0(w)+"]",   SHIFT(W[w].H2Time), W[w].H2,  SHIFT(W[w].L2Time), W[w].L2, clrGreen,0);
   LINE("L2-H3["+S0(w)+"]",   SHIFT(W[w].H3Time), W[w].H3,  SHIFT(W[w].L2Time), W[w].L2, clrGreen,0);
   LINE("H3-L3["+S0(w)+"]",   SHIFT(W[w].H3Time), W[w].H3,  SHIFT(W[w].L3Time), W[w].L3, clrGreen,0);
   
   
   LINE("H1-H3["+S0(w)+"]",   SHIFT(W[w].H1Time), W[w].H1,  SHIFT(W[w].H3Time), W[w].H3, clrGold,0);   
   LINE("L1-L3["+S0(w)+"]",   SHIFT(W[w].L1Time), W[w].L1,  SHIFT(W[w].L3Time), W[w].L3, clrGold,0);
   A("L3["+S0(w)+"]", W[w].L3, SHIFT(W[w].L3Time), clrRed);
   V("H2["+S0(w)+"]", W[w].H2, SHIFT(W[w].H2Time), clrGreen);
   //LINE("POC["+S0(w)+"]",     SHIFT(W[w].H1Time), W[w].Poc, SHIFT(W[w].L2Time), W[w].Poc, clrRed);
   } 
   

   
   
   
   
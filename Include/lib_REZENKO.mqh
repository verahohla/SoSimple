float  MinHL, LastHi;
uchar free, MinHLnum;
datetime PicInterval;
#define  www 8 // кол-во одновременно отслеживаемых формаций

struct Rez{  //  
   int      Phase;   // этап формирования первой формации
   datetime H1Time;  // время первого хая
   datetime H2Time;  // время второго хая
   datetime L1Time;  // --
   datetime L2Time;
   datetime L3Time;
   datetime H3Time;  // 
   datetime H4Time;
   float   H1;   // первый хай 
   float   H2;   // перехай вервого хая
   float   H3;  // выстрел из первой формации
   float   H4;
   float   L1;   // первый лоу (между хаями)
   float   L2;   // ПереЛоу первого лоу
   float   L3;   // 
   float   HiLo; // диапазон H1-L2
   float   Poc;
   }; 
Rez W[www];   



void REZENKO_INIT(){
   W[0].Phase=0;
   PicInterval=3600*24*5;  // минимальный  интрервал между макушками, чтобы не отбирались движения длинной в год
   }


   
void NEW_W(){// ПОИСК ПЕРВЫХ ПРИЗНАКОВ ФОРМАЦИИ "Голова/Плечи" = понижающийся Хай
   if (!Update) return;  // небыло нового пика
   uchar      w; 
   //int MaxPoc; double MaxPocPrice;
   // ожидание "НедоХай"
   MinHL=99999; 
   free=0;
   //setBUY.Sig=BLOCK;   
   for (w=1; w<www; w++)  W_CHECK(w);
   if (free==0){   // не нашлось свободных подлежащих удалению формаций
      free=MinHLnum; // удалим самую узкую
      //X(TIME(Time[bar])+": X["+S0(free)+"] "+TIME(W[free].H1Time)+" HiLo="+S4(W[free].HiLo), W[free].H1, SHIFT(W[free].H1Time), clrGreen);
      }  
   if (Dir>0 && F[hi].P>F[Hi2].P && LastHi!=F[Hi2].P){  //  
      LastHi=F[Hi2].P; // чтобы один и тот же сигнал не записывался в несколько ячеек 
      W[free].Phase=1; // переход к следующей фазе
      W[free].H1=F[Hi2].P;   W[free].H1Time=F[Hi2].T;  // верхняя граница формации 
      W[free].H2=F[hi].P;    W[free].H2Time=F[hi].T;     // пробивающий Хай
      int b=iLowest (NULL,0,MODE_LOW ,SHIFT(W[free].H1Time)-SHIFT(F[hi].T),SHIFT(F[hi].T)); // минимум между хаями
      W[free].L1=float(Low [b]);  W[free].L1Time=Time[b];// нижняя граница, которая должна пробиться для формирования "молнии"
      //W[free].Poc=POC_SIMPLE((F[Hi2].P+Low[b])/2, Low [b], SHIFT(F[Hi2].T), SHIFT(F[hi].T), MaxPoc, MaxPocPrice);
      W[free].Poc=float((F[Hi2].P+Low[b])/2); // объем формации
      W[free].HiLo=W[free].H1-W[free].L1; // диапазон формации для сравнения на случай поиска самого узкого
      V("H1["+S0(free)+"]", W[free].H1, SHIFT(W[free].H1Time), clrGreen);
      LINE("New W["+S0(free)+"].H2="+S4(W[free].H2),  SHIFT(W[free].H2Time), W[free].H2, SHIFT(W[free].H1Time), W[free].H1, clrGainsboro,0);
      LINE("New W["+S0(free)+"].Poc="+S4(W[free].Poc),SHIFT(W[free].H2Time), W[free].Poc,SHIFT(W[free].H1Time), W[free].Poc,clrGainsboro,0);
   }  }
   
     
   
void W_CHECK(uchar w){// ПРОВЕРКА ФОРМАЦИИ "ГОЛОВА/ПЛЕЧИ"
   if (W[w].Phase==0) {free=w; return;} // пропускаем пустые (отработанные) формации
   
   if (F[lo].P<W[w].L1){// постоянная проверка на пробой нижней границы формации
      W[w].Phase=0;   X("X L1["+S0(w)+"]", W[w].L1, SHIFT(W[w].L1Time), clrRed);
      free=w; return;
      } 
   if (W[w].Phase<4 && F[hi].P>W[w].H2){// снова обновился второй ПереХай 
         W[w].Phase=1;
         W[w].H2=F[hi].P;   W[w].H2Time=F[hi].T;
         }    
   if (W[w].Phase==1){// ФОРМИРОВАНИЕ ЛОУ ЛЕВОГО ПЛЕЧА 
      if (F[lo].P<W[w].Poc && F[lo].T>W[w].H2Time){ // пробит объем (центр) формации
         W[w].L2=F[lo].P;   W[w].L2Time=F[lo].T;  // левое плечо
         W[w].Phase=2; // переход к следующей фазе
      }  }   
   if (W[w].Phase==2){// ФОРМИРОВАНИЕ ХАЙ ЛЕВОГО ПЛЕЧА
      if (F[lo].P<W[w].L2)  {W[w].L2=F[lo].P;   W[w].L2Time=F[lo].T;}  // вновь обновилось левое плечо
      if (F[hi].P>W[w].L2+(W[w].H2-W[w].L2)/3 && F[hi].T>W[w].L2Time){// откат вверх на одну треть пройденного от верхней до нижней точки
         W[w].Phase=3;// переход к следующей фазе
         W[w].H3=F[hi].P;   W[w].H3Time=F[hi].T;  // хай левого плеча
      }  }   
   if (W[w].Phase==3){// ФОРМИРОВАНИЕ ГОЛОВЫ
      if (F[lo].P<W[w].L2 && F[lo].T>W[w].H3Time){// пробито левое плечо (сформирована голова)
         W[w].Phase=4; // переход к следующей фазе
         W[w].L3=F[lo].P;  W[w].L3Time=F[lo].T;    // Голова (ложняк)
      }  } //if (w==5) A("L3["+S0(w)+"]", W[w].L3, SHIFT(W[w].L3Time), clrRed);  
   if (W[w].Phase==4){// ПОДТВЕРЖДЕНИЕ ЛОЖНЯКА = УХОД ВВЕРХ
      if (F[lo].P<W[w].L3)  {W[w].L3=F[lo].P;  W[w].L3Time=F[lo].T;} // обновилась голова
      if (F[hi].P>W[w].H3 && F[hi].T>W[w].L3Time){
         W[w].Phase=5;
         W[w].H4=F[hi].P;   W[w].H4Time=F[hi].T; // обновление значения 
         V("CONFIRM ["+S0(w)+"]", F[hi].P, SHIFT(F[hi].T), clrOrange);// LINE("L3-HH["+S0(w)+"]",   SHIFT(W[w].L3Time), W[w].L3,   SHIFT(F[hi].T), F[hi].P, clrOrange);
         DRAW_W(w);   
      }  } 
   if (W[w].Phase==5){// 
      //A("Phase==5", F[lo].P, SHIFT(F[lo].T), clrBlue);
      if (F[lo].P<W[w].L3){// пробой головы
         X("X L3["+S0(w)+"]", F[lo].P, SHIFT(F[lo].T), clrRed); 
         W[w].Phase=0; 
         free=w;  return;} 
      // (F[hi].P>W[w].H2- && F[hi].T>W[w].L3Time){
      if (F[lo].P<W[w].L3+ATR && F[lo].P>W[w].L1 && F[lo].T>W[w].H4Time){
         W[w].Phase=6;
         //setBUY.Sig=GOGO;
         //setBUY.Val=float(Ask);// серединка второго пика (подтверждающего)
         //setBUY.Stp=F[lo].P;   // за первый пик (уровень) 
         //setBUY.Prf=W[w].H2;  // треть движения, коснувшегося зоны продажи 
         A("BUY.Val ["+S0(w)+"]", F[lo].P, SHIFT(F[lo].T), clrBlue);// LINE("L3-HH["+S0(w)+"]",   SHIFT(W[w].L3Time), W[w].L3,   SHIFT(F[hi].T), F[hi].P, clrOrange);
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
   LINE("L2-H3["+S0(w)+"]",   SHIFT(W[w].H3Time), W[w].H3,  SHIFT(W[w].L2Time), W[w].L2, clrBlue,0);
   LINE("H3-L3["+S0(w)+"]",   SHIFT(W[w].H3Time), W[w].H3,  SHIFT(W[w].L3Time), W[w].L3, clrBlue,0);
   LINE("L3-H4["+S0(w)+"]",   SHIFT(W[w].H4Time), W[w].H4,  SHIFT(W[w].L3Time), W[w].L3, clrBlue,0);
   A("L3["+S0(w)+"]", W[w].L3, SHIFT(W[w].L3Time), clrRed);
   V("H2["+S0(w)+"]", W[w].H2, SHIFT(W[w].H2Time), clrGreen);
   //LINE("POC["+S0(w)+"]",     SHIFT(W[w].H1Time), W[w].Poc, SHIFT(W[w].L2Time), W[w].Poc, clrRed);
   } 
   

   
   
   
   
#include <head_PIC.mqh> 
#include <lib_TRG.mqh>
#include <lib_ATR.mqh> 
#include <lib_Flat.mqh>   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
int PIC_INIT(){
   //REZENKO_INIT();
   ArrayResize(MovDn,Movements); // массив безоткатных движений
   ArrayResize(MovUp,Movements); // массив безоткатных движений
   ArrayResize(MovUpSrt,Movements); // массивы для сортировки
   ArrayResize(MovDnSrt,Movements); // безоткатных движений
   BarSeconds=ushort(Period()*60);  // кол-во секунд в баре
   BarsInDay=short(24*60/Period()); // Кол-во бар в сутках 
   Trnd.Global=0; // инициализация глобального тренда
   for (uchar f=0; f<LevelsAmount; f++) F[f].P=0;  
   //LINE("MaxPoc="+S0(MaxPoc), t1, MaxPocPrice,  t2, MaxPocPrice, clrRed);
   Print("INIT: ",__FILE__,"  v",VER,"  compilation time: ",__DATETIME__);
   return (INIT_SUCCEEDED); // "0"-Успешная инициализация. Результат выполнения функции OnInit() анализируется терминалом только если программа скомпилирована с использованием #property strict.
   }          
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
bool PIC(){// ОСНОВНОЙ ЦИКЛ ПОИСКА УРОВНЕЙ
   if (!ATR_COUNT())  {return(false);}   // Print(DTIME(Time[bar]),": ATR don't ready");
   H1=H; L1=L; C1=C;
   H=(float)High[bar];
   L=(float)Low [bar];
   C=(float)Close[bar];
   Update=0;
   if (High[bar+PicPer]==High[iHighest(NULL,0,MODE_HIGH,PicPer*2+1,bar)]){ // Новый hi  ///////////////////////////////////////////////////////    
      NEW_LEVEL( 1, (float)High[bar+PicPer]); // ФОРМИРОВАНИЕ И УДАЛЕНИЕ УРОВНЕЙ
      }
   if (Low [bar+PicPer]==Low [iLowest (NULL,0,MODE_LOW ,PicPer*2+1,bar)]){ // Новый lo  /////////////////////////////////////////////////////////     
      NEW_LEVEL(-1, (float)Low[bar+PicPer]); // ФОРМИРОВАНИЕ И УДАЛЕНИЕ УРОВНЕЙ
      }
   //NEW_W();             // Сигнал "Голова/Плечи" (стоит до GLOBAL_TREND(), т.к. проверяется пробитие Первых Уровней
   //TARGET_COUNT();// РАСЧЕТ ЦЕЛЕВЫХ УРОВНЕЙ ОКОНЧАНИЯ ДВИЖЕНИЯ НА ОСНОВАНИИ ИЗМЕРЕНИЯ ПРЕДЫДУЩИХ ДВИЖЕНИЙ   
   GLOBAL_TREND();      // ОПРЕДЕЛЕНИЕ ТРЕНДА (стоит до LEVELS_FIND_AROUND(), т.к. пробой уровней проверяется до их обновления    
   LEVELS_FIND_AROUND();// ПОИСК СИЛЬНЫХ УРОВНЕЙ      
   LOCAL_TREND();
   //LINE(" F/Fi="+S0(Atr.Fast/Point)+"/"+S0(fst/Point)+" S/Si="+S0(Atr.Slow/Point)+"/"+S0(slw/Point), bar+1, Close[bar], bar, Close[bar],  clrDarkSeaGreen,3);
   //Print(BTIME(bar)," NewPic=",New);
   return(true);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
#define TEST_DATE "2022.04.27 20:00"
void NEW_LEVEL(char dir, float NewFractal){// ФОРМИРОВАНИЕ И УДАЛЕНИЕ УРОВНЕЙ
   Update=True;// признак появления нового пика
   Dir=dir;    // направление последнего пика
   New=NewFractal;
   datetime ExPicTime=Time[Bars-1];// время ближайшшего превосходящего пика из массива...
   char  Flt=1;         // кол-во совпадений c флэтовыми непробитыми пиками
   uchar Pics=0;        // кол-во совпадений со всеми пиками
   uchar FlatBegin=0;   // время начала флэта
   float LevMiddle=New; // средний уровень совпавших пиков
   float PwrSum=0;  // Сумма сил пиков, совпадающих с этим по уровню
   uchar LowestWeightCell=0;   // номер ячейки и 
   float LowestWeight=99999;  // сила самого слабого уровня для удаления на случай, если не найдется свободной ячейки
   float Weight=0; // критерий удаления
   uchar e; // ExPicTime array index
   for (uchar f=1; f<LevelsAmount; f++){// перебираем весь массив фракталов от большего к меньшему
      if (F[f].P==0){ // незаполненная ячейка
         LowestWeight=Weight; 
         LowestWeightCell=f; 
         continue;
         } 
      F[f].Count++; if (F[f].Count>LevelsAmount) F[f].Count=LevelsAmount; // порядковый номер (очередность) от нового к самому старому.
      Weight = F[f].Power * F[f].Flt.Num / F[f].Count / MathMax(MIRROR,F[f].Brk); // критерий удаления = минимальный фронт * кол-во отскоков / удаление от текущего бара / число пробоев(пропилов)
      if (F[f].Fls.Phase<START && Weight<LowestWeight && f!=HI && f!=LO && f!=Hi2 && f!=Lo2 && f!=stpH && f!=stpL){// самый слабый уровень для удаления. Должен быть старше двух дней и не не стадии ложного пробития. 
         LowestWeight=Weight; 
         LowestWeightCell=f;
         }     
      if (MathAbs(New-F[f].P)<Atr.Lim){ // совпадение уровней
         PwrSum+=F[f].Power;  // Сумма сил пиков, совпадающих с этим по уровню
         F[f].Pics++;   // кол-во совпадений со всеми пиками (пробитыми и зеркальными) 
         Pics++;        // для поиска уровня с максимальным количеством отскоков
         } 
      if (F[f].Brk==BROKEN){  // подтверждение зеркального уровня - достаточно глубокий пробой 
         if (F[f].Dir>0 && New>F[f].P+Atr.Max*2) {F[f].Brk=MIRROR;} // глубокий пробой   V(DTIME(Time[bar+PicPer])+"/"+S4(FrntVal), F[f].P, SHIFT(F[f].T), clrBlue);
         if (F[f].Dir<0 && New<F[f].P-Atr.Max*2) {F[f].Brk=MIRROR;} // сонаправленным пиком  
         }
      FALSE_BREAK(f);// проверка ложного пробоя при iSignal=1 (lib_Flat.mqh)
      // if (Time[bar+PicPer]==StringToTime(TEST_DATE)) V("Weight="+S4(Weight/Point/10)+" Pwr="+S0(F[f].Power/Point/10)+" Flt="+S0(F[f].Flt.Num)+" Brk="+S0(F[f].Brk)+" Сount= "+S0(F[f].Count), f, clrRed); 
      if (F[f].T==StringToTime(TEST_DATE)) V(" Brk="+S0(F[f].Brk)+" Trnd="+S0(F[f].TrBrk),  bar+1, New, clrRed);
      if (F[f].Brk>CLEAR ) continue;   // далее рассматриваются непробитые уровни 0-CLEAR, 1-TOUCH, 2-MIRROR, 3-BROKEN, 5-USED
      if (Dir==F[f].Dir){ // сонаправленный пик
         if (MathAbs(New-F[f].P)<Atr.Lim){// сравниваемые фракталы в пределах Lim и это не пробитый пик, т.е. между отобранным и новым пиками ничего не выступает  
            F[f].Flt.Num++; Flt++;   // поиск совпадающих уровней, увеличиваем кол-во совпадений
            LevMiddle+=F[f].P;   // и их сумма для усреднения LINE(S0(f)+" Lim="+S5(Atr.Lim)+" a="+S4(Atr.Fast)+" A="+S4(Atr.Slow), bar+PicPer,New,  SHIFT(F[f].T),F[f].P,clrLightBlue,0);
            if (FlatBegin==0 || F[f].T<F[FlatBegin].T) FlatBegin=f;// самый старый пик флэта, для противоположной границы
            if (Flt>1) SQUARE_TRIANGLE(f, F[f].TRG.N); // если было совпадение вершин, обрабатывается прямоугольный треугольник
            }
         else if (LEVEL.BREAKING(f, New)) continue; // иногда пробой баром "не срабатывает" => доп проверка пробоя фракталом 
         if (F[f].T>ExPicTime)   {ExPicTime=F[f].T; e=f;} // время ближайшего превосходящего пика для поиска фронта
         if (Dir>0 && New>F[f].Near)  {F[f].Near=New; F[f].NearVal=New-F[f].Back;} // самый близкий подход цены к уровню - его цена и амплидуда
         if (Dir<0 && New<F[f].Near)  {F[f].Near=New; F[f].NearVal=F[f].Back-New;} //         
         }     
      else{ // противолежащий пик
         if (F[f].Dir>0){ // вершина
            if (New<F[f].Back){  // очередное удаление от пика
               F[f].Back=New;    // обновление заднего фронта
               F[f].BackVal=F[f].P-New; // и его амплитуды
               F[f].BackT=Time[bar+PicPer]; // время последней вершины Back уровня
               F[f].Power=MathMin(F[f].FrntVal,F[f].BackVal);
               F[f].Near=New; // и самого близкого подхода 
               F[f].NearVal=0; 
               if (F[f].FrntVal>ATR*Power && F[f].BackVal>ATR*Power*Pot/2)  F[f].First=true;       // при большом переднем (First=1) и заднем фронтах ставится флаг первого уровня First=2
            }  }  
         else{// впадина
            if (New>F[f].Back){           // очередное удаление от пика
               F[f].Back=New;             // обновление заднего фронта
               F[f].BackVal=New-F[f].P;   // и его амплитуды
               F[f].BackT=Time[bar+PicPer]; // время последней вершины Back уровня
               F[f].Power=MathMin(F[f].FrntVal,F[f].BackVal); 
               F[f].Near=New;   // if (f==LO) V(S4(New), New, bar+PicPer, clrBlue); 
               F[f].NearVal=0; 
               if (F[f].FrntVal>ATR*Power && F[f].BackVal>ATR*Power*Pot/2)  F[f].First=true;       // при большом переднем (First=1) и заднем фронтах ставится флаг первого уровня First=2   
         }  }  }  
      if (F[f].TrBrk==CLEAR){ // трендовый уровень сформирован
         if (F[f].Dir>0)   {if (New>F[f].TrMid) F[f].TrBrk=BROKEN;} // пробитие трендового уровня    
         else              {if (New<F[f].TrMid) F[f].TrBrk=BROKEN;} // пробитие трендового уровня        
         }
      //if (F[f].Brk==2 || F[f].Brk==3){  // отмена зеркального уровня - касание, либо обратный пробой
      //   if (F[f].Dir>0 && Dir<0 && New<F[f].P+Atr.Lim) {F[f].Brk=4; X(DTIME(Time[bar+PicPer]), F[f].P, SHIFT(F[f].T), clrRed);} // пробой, либо касание противоположным пиком,  
      //   if (F[f].Dir<0 && Dir>0 && New>F[f].P-Atr.Lim) {F[f].Brk=4;} // маркируем отработавшим   
      //   }         
      //if (F[f].T==StringToTime("2001.01.08 08:00")) Print(Time[bar]," Brk=",F[f].Brk," Frnt=",F[f].Frnt," Back=",F[f].Back);
      
      } 
   // X("n-"+DTIME(F[n].T)+" LowestPower="+S0(LowestPower), New,bar+PicPer, clrBlue);// если пустых ячеек нет, берем самую слабую  
   //Print(" OldestTime=",DTIME(F[Oldest].T)," Oldest=",S0(Oldest)," F[",n,"]=",N4(New)," at ",DTIME(Time[bar+PicPer])); 
   //PRN("n="+S0(n)+" "+DTIME(F[n].T)+" LowestPower="+S0(LowestPower));
   n=LowestWeightCell;
   int Shift=iBarShift(NULL,0,ExPicTime,false); // сдвиг превосходящего пика относительно нового пика
   F[n].Count=1;     // порядковый номер (очередность) от нового к самому старому. 
   F[n].P=New;            // пишем в свободную ячейку значение фрактала
   F[n].T=Time[bar+PicPer];      // время возникновения фрактала
   F[n].Flt.T=Time[bar+PicPer];  // время формирования первого (дальнего) пика флэта
   F[n].Flt.Num=Flt;  // кол-во совпадений с предыдущими непробитыми уровнями
   F[n].Pics=Pics;// кол-во совпадений со всеми уровнями  
   F[n].Dir=Dir;   // направление фрактала: 1=ВЕРШИНА, -1=ВПАДИНА
   F[n].ExT=ExPicTime; // время ближайшего превосходящего пика для поиска фронта
   F[n].Per=PicPer; // кол-во бар до пробоя пика
   F[n].Brk=CLEAR;   // Признак пробитости: -1~NEW, 0~CLEAR, -1-MIRROR, +1-BROKEN
   F[n].Rev=0; // Разворотный(повышающийся) - превосходящий предыдущий пик, только из разворотных выбираются Первые Уровни 
   F[n].First=false; // Признак сильного "Первого" уровня (большой передний и задний фронты, задний фронт еще не сформирован, поэтому false)
   F[n].TrBrk=NEW; // статус трендового уровня: (-1)-не сформирован,  CLEAR(0)-сформирован,  BROKEN(1)-пробит  Пока хай не опустится под трендовый, он будет не действителен.
   F[n].Fls.Phase=NONE; // стадия ложняка: NONE, START, CONFIRM, BREAK
   F[n].TRG.N=0;  // кол-во вершин в треугольнике
   F[n].PwrSum=PwrSum;  // Сумма сил пиков, совпадающих с этим по уровню
   F[n].Mid=0;    // Уровень "чуть дальше серединки" движения (для Первых уровней)
   F[n].MaxMov=0; // максимальный откат с момента формирования пика для измеренных движений (для Первых уровней)
   F[n].Imp=MathAbs(New-C); // максимальный импульс из пика для определения тренда.   
   if (Dir>0){ // вершина  
      F[n].Tr=New-Atr.Fast;// для вершины трендовый уровень не продажу (пока хай не опустится под трендовый, он будет не действителен)     LINE("PicHi="+S4(F[hi].P)+" F[hi].Trd="+S4(F[hi].Trd), bar+PicPer*2, F[hi].Trd,  bar, F[hi].Trd, clrRed);
      F[n].TrMid=(F[n].P+F[n].Tr)/2;     // серединка на пробой  F[n].Mid=F[n].P-(F[n].P-F[n].Tr)/3;
      F[n].Frnt=float(Low [iLowest (NULL,0,MODE_LOW ,Shift-(bar+PicPer),bar+PicPer+1)]);   // Передний Фронт уровня (величина развернутого им движения) = минимум, лежащий между новым пиком и превосходящим его баром.    
      F[n].Back=float(Low [iLowest (NULL,0,MODE_LOW ,PicPer,bar)]);// задний фронт = минимальная цена после пика. Будет постепенно увеличиваться по мере удаления цены от уровня       
      F[n].FrntVal=New-F[n].Frnt; // амплитуды
      F[n].BackVal=New-F[n].Back; // этих значений
      F[n].NearVal=0; // Near - уровень, до которого цена приближалась к пику. NearVal - расстояние от Back до Near, т.е. Back от Back
      if (New>F[hi].P)    {F[n].Rev=1;   RevHi=n;}  // "повышающийся пик"  нужен для формирования измеренных движений X("RevHi="+DoubleToString(Rev.F[hi].P,4), Rev.F[hi].P, bar+PicPer, clrRed);    
      hi3=hi2; hi2=hi; hi=n; //   if (F[n].FrntVal>ATR*Power) V(S0(n)+","+S4(F[n].FrntVal), New, bar+PicPer, clrRed);
      float ImpHi=F[hi].Imp/(F[lo].Imp+F[lo2].Imp+F[lo3].Imp+float(Point))*3; //V("Imp="+S4(F[hi].Imp)+" dImp="+S4(ImpHi),hi,clrRed);
      if (ImpHi>iImp+2) {Trnd.Imp=-1;  V("Imp="+S4(ImpHi),hi,clrRed);}   
   }else{      // впадина                                                             
      F[n].Tr=New+Atr.Fast;// для впадины трендовый уровень на покупку (пока лоу не поднимется над трендовым, он будет недействительным)
      F[n].TrMid=(F[n].P+F[n].Tr)/2;    // серединка на пробой    F[n].Mid=F[n].P+(F[n].Tr-F[n].P)/3;
      F[n].Frnt=float(High[iHighest(NULL,0,MODE_HIGH,Shift-(bar+PicPer),bar+PicPer+1)]);   // Передний Фронт уровня (величина развернутого им движения) = максимум, лежащий между новым пиком и нижележащим его баром. 
      F[n].Back=float(High[iHighest(NULL,0,MODE_HIGH,PicPer,bar)]);// задний фронт = максимальная цена после пика. Будет постепенно увеличиваться по мере удаления цены от уровня        
      F[n].FrntVal=F[n].Frnt-New; // амплитуды
      F[n].BackVal=F[n].Back-New; // этих значений
      F[n].NearVal=0; // Near - уровень, до которого цена приближалась к пику. NearVal - расстояние от Back до Near, т.е. Back от Back
      if (New<F[lo].P)    {F[n].Rev=1;   RevLo=n;} // "понижающаяся впадина"  нужен для формирования измеренных движений X("RevLo="+DoubleToString(F[RevLo].P,4), F[RevLo].P, bar+PicPer, clrGreen);
      lo3=lo2; lo2=lo; lo=n;  //  if (F[n].T==StringToTime("2022.08.03 17:00"))  A(" Frnt="+S4(F[n].Frnt)+" ExPicTime="+DTIME(ExPicTime)+" "+S0(F[e].Brk), New, bar+PicPer+1, clrBlue);
      float ImpLo=F[lo].Imp/(F[hi].Imp+F[hi2].Imp+F[hi3].Imp+float(Point))*3; 
      if (ImpLo>iImp+2) {Trnd.Imp=1; V("Imp="+S4(ImpLo),lo,clrGreen);}
      } 
   F[n].Power=MathMin(F[n].FrntVal,F[n].BackVal); // Power=MIN(FrntVal,BackVal)   
   FLAT_DETECT(LevMiddle, FlatBegin);
   // if (F[n].T==StringToTime("2022.07.27 21:00")) A("Frnt="+S4(F[n].Frnt)+" ExPicTime="+DTIME(ExPicTime), New, bar+PicPer, clrBlue);
   }         
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ       
void LOWEST_HI(float BaseLev, float& Delta, uchar f, uchar& Nearest){// ближайший к BaseLev уровень CheckLev, возвращается его номер NearestNum и расстояние между ними
   if (F[f].P+Atr.Lim>BaseLev && F[f].P-BaseLev<Delta)  {Delta=F[f].P-BaseLev;  Nearest=f;}
   }   
void HIGHEST_LO(float BaseLev, float& Delta, uchar f, uchar& Nearest){// ближайший к BaseLev уровень CheckLev, возвращается его номер NearestNum и расстояние между ними
   if (F[f].P-Atr.Lim<BaseLev && BaseLev-F[f].P<Delta)  {Delta=BaseLev-F[f].P;  Nearest=f;}  
   }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
#define  DrawFirstLevels 1 
void LEVELS_FIND_AROUND(){ // П О И С К   Б Л И З Л Е Ж А Щ И Х   У Р О В Н Е Й 
   uchar fHI=0, fLO=0, fH=0, fL=0; // номера уровней в массиве
   float  minTrgHi=99999, minTrgLo=99999, minHI=999999, minLO=999999, minH=999999, minL=999999, StpVal=ATR*MathAbs(Trl); 
   TrgHi=0; TrgLo=0; stpH=0; stpL=0; // номера уровней в массиве
   for (uchar f=1; f<LevelsAmount; f++){// в нулевом хранится последнее значение, оно же записывается в массив вместо самого слабого пика 
      if (F[f].P==0)    continue; // пустые значения
      if (LEVEL.CHECK(f)!=CLEAR) continue;
      F[f].Per++;  // увеличение периода уровня до момента пробития  
      if (F[f].TrBrk==NEW){// трендовый уровень еще не сформирован
         if (F[f].Dir>0 && H<F[f].TrMid) {F[f].TrBrk=CLEAR;}  // окончательнрое формирование трендового, когда хоть один хай опустился ниже его уровня.
         if (F[f].Dir<0 && L>F[f].TrMid) {F[f].TrBrk=CLEAR;}
         }
      if (Target!=0){
         if (F[f].Dir>0)   LOWEST_HI(TargetHi, minTrgHi, f, TrgHi);  // ближайший пик к расчитанному целевому уровню   
         else              HIGHEST_LO(TargetLo, minTrgLo, f, TrgLo);    
         }
      //if (F[f].Dir>0)   Imp=(F[f].P-L)/F[f].Per;
      //else              Imp=(H-F[f].P)/F[f].Per; 
      //if (Imp>F[f].Imp) F[f].Imp=Imp;  // максимальный импульс из пика для определения тренда.   
      // if (Tch==0 && F[f].Brk==TOUCH)   continue; // Пик дб без касаний при Tch=0
      // if (F[f].TrBrk!=CLEAR) continue; // только с непробитым cформированным трендовым   Trd>0  && 
      if (Rev>0  && F[f].Rev==0)       continue; // уровень должен пробить хотябы один пик (REV=1)   
      // TRAILING/STOP LEVELS
      if (F[f].BackVal>StpVal){
         if (F[f].Dir>0){
            if (F[f].T>SellTime) LOWEST_HI (H, minH, f, stpH);  // ближайший пик к текущей цене для шортового стопа
         }else{
            if (F[f].T>BuyTime)  HIGHEST_LO(L, minL, f, stpL);  // ближайший пик к текущей цене для лонгового стопа    
         }  }
      // FIRST LEVELS  0-негодный; 1-большой передний фронт; 2-Первый уровень, т.е. большой передний и задний фронты 
      if (F[f].First==true){ // поиск первых уровней, только среди последних 150 бар && SHIFT(F[f].T)<bar+130
         if (F[f].Dir>0)   LOWEST_HI (H, minHI, f, fHI);  // ближайший первый  уровень к текущей цене, 
         else              HIGHEST_LO(L, minLO, f, fLO);  // ближайший первый  уровень к текущей цене, 
      }  }
   // П Е Р В Ы E    У Р О В Н И  if (Time[bar]<StringToTime("1999.11.26 08:00")  || Time[bar]>StringToTime("1999.11.27 00:00"))   return;    
   if (fHI>0 && HI!=fHI) HI=fHI; // else HI=0; ПЕРВЫЙ ТРЕНДОВЫЙ НА ПРОДАЖУ обновился и есть небольшой отрыв от него // && F[fHI].NearVal>F[fHI].BackVal/6        
   if (fLO>0 && LO!=fLO) LO=fLO; // else LO=0; ПЕРВЫЙ ТРЕНДОВЫЙ НА ПОКУПКУ обновился и есть небольшой отрыв от него //  && F[fLO].NearVal>F[fLO].BackVal/6        
   // У Р О В Н И    С Е Р Е Д И Н К И
   if (HI>0 && midHi!=F[HI].P+F[HI].Back && H>F[HI].Back+F[HI].BackVal/4){ // обновилась вершина, либо Back  && F[HI].NearVal>F[HI].BackVal/4
      midHi=F[HI].P+F[HI].Back; // обновление контрольной суммы
      F[HI].Mid=POC(F[HI].Back+Atr.Min, F[HI].P-Atr.Min, SHIFT(F[HI].T), SHIFT(F[HI].BackT), F[HI].MaxMov, Poc, false); 
      if (DrawFirstLevels){ 
         LINE("HI="+S0(HI)+" Mid="+S4(F[HI].Mid)+", ATR="+S4(ATR)+" MaxMov="+S4(F[HI].MaxMov), SHIFT(F[HI].T),F[HI].P, SHIFT(F[HI].BackT), F[HI].Back,DNCLR,0);  //  if (F[HI].Mid==0) V("NoPoc "+S0(HI)+" Back="+S4(F[HI].Back), H, bar, DNCLR); // V("TrDn", H, bar, DNCLR);
         //V(S0(HI)+" "+DTIME(F[HI].BackT), F[mov].P, SHIFT(F[mov].T), DNCLR); 
         LINE("HI="+S0(HI)+", Back="+S4(F[HI].Back)+"/"+DTIME(F[HI].BackT), SHIFT(F[HI].T),F[HI].Mid,  bar,F[HI].Mid, DNCLR,0);
      }  }
   if (LO >0 && midLo!=F[LO].P+F[LO].Back && L<F[LO].Back-F[LO].BackVal/4){ // обновилась вершина, либо ее Back  && F[LO].NearVal>F[LO].BackVal/4
      midLo=F[LO].P+F[LO].Back; // обновление контрольной суммы   
      F[LO].Mid=POC(F[LO].P+Atr.Min, F[LO].Back-Atr.Min, SHIFT(F[LO].T), SHIFT(F[LO].BackT), F[LO].MaxMov, Poc, false); 
      if (DrawFirstLevels){ 
         LINE("LO="+S0(LO)+" Mid="+S4(F[LO].Mid)+", ATR="+S4(ATR), SHIFT(F[LO].T),F[LO].P, SHIFT(F[LO].BackT), F[LO].Back,UPCLR,0);  // if (F[LO].Mid==0) A("NoPoc "+S0(LO)+" Back="+S4(F[LO].Back), L, bar, UPCLR); // A("TrUp", L, bar, UPCLR);
         //A(S0(LO)+" "+DTIME(F[LO].BackT), F[mov].P, SHIFT(F[mov].T), UPCLR); 
         LINE("LO="+S0(LO)+", Back="+S4(F[LO].Back)+"/"+DTIME(F[LO].BackT), SHIFT(F[LO].T),F[LO].Mid,  bar,F[LO].Mid, UPCLR,0);
      }  }
   if (F[LO].Mid>0 && F[LO].Near<F[LO].Mid)  {F[LO].Mid=0;}// "уровень серединки" пробит A("TrDn", L1, bar+1, UPCLR);
   if (F[HI].Mid>0 && F[HI].Near>F[HI].Mid)  {F[HI].Mid=0;}// "уровень серединки" пробит   V("TrUp", H1, bar+1, DNCLR);  
   if (F[HI].P==0) LINE("F[HI].P==0",  bar,L,   bar,H, DNCLR,3);
   if (F[LO].P==0) LINE("F[LO].P==0",  bar,L,   bar,H, UPCLR,3);
   }     
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
class LevelFunctions{ //  0-CLEAR, 1-TOUCH, 2-MIRROR, 3-BROKEN, 5-USED
   public:
   bool TOUCHING(uchar f){ // touching
      if (F[f].TrBrk<CLEAR) return(false); // Трендовый уровень не успел сформироваться, соответсвенно пик тоже 
      if (F[f].Dir>0 && H>F[f].P-Atr.Lim && H<F[f].P+Atr.Lim)  {F[f].Brk=TOUCH; return (true);}
      if (F[f].Dir<0 && L<F[f].P+Atr.Lim && L>F[f].P-Atr.Lim)  {F[f].Brk=TOUCH; return (true);}
      return(false);
      }
   bool BREAKING(uchar f){ // breaking by bar
      if (F[f].Dir>0 && H>=F[f].P+Atr.Lim)   {SET_BROKEN(f); return (true);}
      if (F[f].Dir<0 && L<=F[f].P-Atr.Lim)   {SET_BROKEN(f); return (true);}
      return(false);
      }  
   bool BREAKING(uchar f, float pic){ // breaking by new pic
      if (F[f].Dir>0 && pic>=F[f].P+Atr.Lim)   {SET_BROKEN(f); return (true);}
      if (F[f].Dir<0 && pic<=F[f].P-Atr.Lim)   {SET_BROKEN(f); return (true);}
      return(false);
      }         
   bool CROSSING(uchar f){
      if (H>F[f].P && L<F[f].P){ 
         if (F[f].Brk<BROKEN) F[f].Brk=BROKEN;
         F[f].Brk++; if (F[f].Brk>126) F[f].Brk=126; 
         return (true);}
      return(false);
      }          
   char CHECK(uchar f);  
   void SET_BROKEN(uchar f);             
   }LEVEL;
   
char LevelFunctions::CHECK(uchar f){
   if (F[f].Brk==CLEAR && (TOUCHING(f) || BREAKING(f)))  return(F[f].Brk);
   if (F[f].Brk==TOUCH  && BREAKING(f)) return(F[f].Brk);
   if (F[f].Brk==MIRROR && CROSSING(f)) return(F[f].Brk);
   if (F[f].Brk>=BROKEN && CROSSING(f)) return(F[f].Brk);          
   return(F[f].Brk);
   }    
void LevelFunctions::SET_BROKEN(uchar f){
   F[f].BrkT=Time[bar]; // время пробития
   F[f].Brk=BROKEN;
   if (F[f].Dir>0)   {Trnd.PicBrk++; if (Trnd.PicBrk> iPic) Trnd.PicBrk= iPic;}
   else              {Trnd.PicBrk--; if (Trnd.PicBrk<-iPic) Trnd.PicBrk=-iPic;}
   if (F[f].Power>ATR*Power) {  // был пробит сильный уровень
      F[f].Fls.Phase=WAIT;} // его ложняк будет интересен: ставим начальный флаг. Флаг сбрасывается на "BREAK"  при формировании уровня в FLAT_DETECT()
   //if (F[f].Flt.Len>0){// если это был флэт шириной более FltLen бар,
   //   if (F[f].Dir>0) Trnd.FltBrk=F[f].P; else Trnd.FltBrk=-F[f].P;//  генерится сигнал "пробой флэта"
   //   }
   
   }     
      


// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void GLOBAL_TREND(){ // Cмена глоб. тренда при пробитии Первых Уровней. 
   if (HI>0 && H>F[HI].P-Atr.Lim)   {Hi2=HI; HI=0;  if (fGlb==2) Trnd.Global= 1;}  // V(" HI="+S4(H), F[Hi2].P, bar, clrOrange);   
   if (LO>0 && L<F[LO].P+Atr.Lim)   {Lo2=LO; LO=0;  if (fGlb==2) Trnd.Global=-1;}  // A(" LO="+S4(H), F[Lo2].P, bar, clrOrange); 
   
   if (fGlb==1){ // Cмена глоб. тренда при пробитии "Уровней серединки", определяемого максимальным скоплением бар
      if (Trnd.Global!= 1 && H>F[HI].Mid && H1<F[HI].Mid)  {Trnd.Global= 1;}  //  LINE("HI PocPrice",   bar+3,F[HI].PocPrice, bar, F[HI].PocPrice,clrRed,0);
      if (Trnd.Global!=-1 && L<F[LO].Mid && L1>F[LO].Mid)  {Trnd.Global=-1;}  //  LINE("LO PocPrice",   bar+3,F[LO].PocPrice, bar, F[LO].PocPrice,clrGreen,0);  
      } 
   
   
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void LOCAL_TREND(){
   // значительный ИМПУЛЬС из последнего пика
   if (!hi || !lo) return;
   //if (F[lo].Imp/Atr.Fast>iImp+4) {Trnd.Imp=1;  V("Imp="+S4(F[lo].Imp)+" Per="+S0(F[hi].Per)+" Brk="+S0(F[hi].Brk),bar,L,clrRed);} //if (F[hi].Per>0) F[hi].Per
   //if (F[hi].Imp/Atr.Fast>iImp+4) {Trnd.Imp=-1; V("Imp="+S4(F[hi].Imp)+" Per="+S0(F[lo].Per)+" Brk="+S0(F[lo].Brk),bar,H,clrGreen);}
   
   //float ImpLo=F[hi].Imp/(F[lo].Imp+F[lo2].Imp+F[lo3].Imp)*3; if (ImpLo>iImp+2) {Trnd.Imp=1;  V("Imp="+S4(ImpLo)+" Per="+S0(F[hi].Per)+" "+DTIME(F[hi].T),bar,L,clrRed);}
   //float ImpHi=F[lo].Imp/(F[hi].Imp+F[hi2].Imp+F[hi3].Imp)*3; if (ImpHi>iImp+2) {Trnd.Imp=-1; V("Imp="+S4(ImpHi)+" Per="+S0(F[lo].Per)+" "+DTIME(F[lo].T),bar,H,clrGreen);}
   //if (Atr.Fast<Atr.Slow) Trnd.Imp=0;  // отмена сигнала импульса при спадании АТР   
   Trnd.Local=0;
   if (iPic>0){ // пробой iPic пиков подряд
      if (Trnd.PicBrk>0) Trnd.Local=1;   
      if (Trnd.PicBrk<0) Trnd.Local=-1;
      }
   if (iFlt) Trnd.Local+=Trnd.Flat; // Выход из флэта напротив входа
   if (iImp) Trnd.Local+=Trnd.Imp;  // Резкий импульс превышающий Atr.Fast*(iImp+2)
   }

// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
//void TREND_FILTER(char DblTop, char Imp, char FltBrk, char& Up, char& Dn){// суммирование входных сигналов  
//   Up=1; Dn=1; 
//   if (Trnd.Global>0) Dn=0;    // глобальный
//   if (Trnd.Global<0) Up=0;    // тренд
//   SIG_SUM(DblTop, Trnd.DblTop,   Up, Dn); // двойной отскок
//   SIG_SUM(FltBrk, Trnd.FltBrk,   Up, Dn); // пробой флэта
//   SIG_SUM(Imp,    Trnd.Imp,      Up, Dn); // резкий импульс
//   
//   if (fGlb   && Trnd.Global>0)   LINE("Up="+S0(Up)+" Global="  +S0(Trnd.Global), bar+1, Low [bar+1]-Atr.Slow, bar, Low [bar]-Atr.Slow, clrBlack,0);
//   if (fGlb   && Trnd.Global<0)   LINE("Dn="+S0(Dn)+" Global="  +S0(Trnd.Global), bar+1, High[bar+1]+Atr.Slow, bar, High[bar]+Atr.Slow, clrBlack,0); 
//   if (DblTop && Trnd.DblTop>0)   LINE("Up="+S0(Up)+" DblTop", bar+1, Low [bar+1]-Atr.Slow*1.2, bar, Low [bar]-Atr.Slow*1.2, clrRed,0);
//   if (DblTop && Trnd.DblTop<0)   LINE("Dn="+S0(Dn)+" DblTop", bar+1, High[bar+1]+Atr.Slow*1.2, bar, High[bar]+Atr.Slow*1.2, clrRed,0); 
//   if (FltBrk && Trnd.FltBrk>0)   LINE("Up="+S0(Up)+" BrkFlat",   bar+1, Low [bar+1]-Atr.Slow*1.4, bar, Low [bar]-Atr.Slow*1.4, clrGreen,0);
//   if (FltBrk && Trnd.FltBrk<0)   LINE("Dn="+S0(Dn)+" BrkFlat",   bar+1, High[bar+1]+Atr.Slow*1.4, bar, High[bar]+Atr.Slow*1.4, clrGreen,0); 
//   if (Imp    && Trnd.Imp>0)      LINE("Up="+S0(Up)+" Imp="     +S0(Trnd.Imp),    bar+1, Low [bar+1]-Atr.Slow*1.6, bar, Low [bar]-Atr.Slow*1.6, clrMagenta,0);
//   if (Imp    && Trnd.Imp<0)      LINE("Dn="+S0(Dn)+" Imp="     +S0(Trnd.Imp),    bar+1, High[bar+1]+Atr.Slow*1.6, bar, High[bar]+Atr.Slow*1.6, clrMagenta,0); 
//   }    // if (Prn) X("Flt="+DoubleToString(Trnd.Flt,0)+" Global="+DoubleToString(Trnd.Global,0)+" Trnd.Dn="+DoubleToString(1,0), Close[bar], bar, clrGray);
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
//void SIG_SUM(char SumMethod, float Sig, char& Up, char& Dn){// trend signals sum: "NO", "AND", "OR"
//   if (SumMethod==0) return;
//   if (SumMethod<0){   // signal reverse
//      if (Sig>0) Sig=-1;
//      if (Sig<0) Sig= 1;
//      } 
//   switch (MathAbs(SumMethod)){   
//      case 1:  // "NO" отмена противоположного
//         if (Sig>0)  {Dn=0;}  // 
//         if (Sig<0)  {Up=0;}  //
//      break;   
//      case 2: // "AND" - сложение сигналов
//         if (Sig<=0 && Up>0) Up=0; // 
//         if (Sig>=0 && Dn>0) Dn=0; //
//      break;
//      case 3:  // "OR" доминирующий над "AND" сигнал c отменой противоположного
//         if (Sig>0 && Trnd.Global>=0)  Up=1;   // 
//         if (Sig<0 && Trnd.Global<=0)  Dn=1;   // 
//      break;
//   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
//void TARGET_COUNT(){// расчет целевых уровней окончания движения на основании измерения предыдущих безоткатных движений
//   if (Target==0) return; // 
//   if (Dir>0){// вершина
//     if (RevLo2!=RevLo){// пересортировка, если были понижающиеся Lo, иначе обновляется лишь последнее движение LastMovUp
//         RevLo2=RevLo;
//         for (uchar i=Movements-1; i>0; i--) {MovUp[i]=MovUp[i-1];}   // пересортировка массива движений    if (Prn) Print("MovUp[",i,"]=",S4(MovUp[i]));
//         MovUp[0]=LastMovUp; // последнее движение = последний пик - разворотная впадина  if (Prn) Print("MovUP[0]=",S4(MovUp[0]));
//         ArrayCopy(MovUpSrt,MovUp,0,0,WHOLE_ARRAY); // копируем во временный массив для сортировки
//         ArraySort(MovUpSrt,WHOLE_ARRAY,0,MODE_DESCEND); // сортировка в порядке убывания 
//         if (Target<0)  MidMovUp=(MovUpSrt[1]+MovUpSrt[2])/2; // среднее движение: отбрасываем самый большой (0) и два самых маленьких (4)(3) движения
//         LastMovUp=0;      
//         }
//      if (F[hi].P-F[RevLo].P>LastMovUp) {LastMovUp=F[hi].P-F[RevLo].P;}// обновляем последнее движение, если новый пик дальше от разворотной впадины, чем предыдущий   LINE("LastMovUp="+S4(LastMovUp)+" F[RevLo].P="+S4(F[RevLo].P), SHIFT(F[RevLo].T), F[RevLo].P,  bar+PicPer, F[hi].P, clrRed);
//      if (Target>0) MidMovUp=(MovUpSrt[0]+MathMax(MovUpSrt[1],LastMovUp))/2;  // среднее максимальных значений прошлых и последнего движения
//      if (MathAbs(Target)==1 || (MathAbs(Target)==2 && hi==RevHi)){ // отмеряем целевое движение вниз от последнего пика, или только от разворотного пика
//         TargetLo=F[hi].P-MidMovDn;} //LINE("MidMovDn="+S4(MidMovDn), SHIFT(F[hi].T), F[hi].P,  SHIFT(F[hi].T), PreTargetLo, clrOrange);
//   }else{// впадина
//      if (RevHi2!=RevHi){// пересортировка, если были повышающиеся Hi, иначе обновляется лишь последнее движение LastMovDn
//         RevHi2=RevHi;   
//         for (uchar i=Movements-1; i>0; i--) {MovDn[i]=MovDn[i-1];}//пересортировка массива движений    if (Prn) Print("MovDn[",i,"]=",S4(MovDn[i]));
//         MovDn[0]=LastMovDn;  // последнее движение = разворотный пик - последняя впадина    if (Prn) Print("MovDn[0]=",S4(MovDn[0]));
//         ArrayCopy(MovDnSrt,MovDn,0,0,WHOLE_ARRAY); // копируем во временный массив для сортировки
//         ArraySort(MovDnSrt,WHOLE_ARRAY,0,MODE_DESCEND); // сортировка в порядке убывания 
//         if (Target<0)  MidMovDn=(MovDnSrt[1]+MovDnSrt[2])/2; // среднее движение: отбрасываем самый большой (0) и два самых маленьких (4)(3) движения
//         LastMovDn=0;
//         }    
//      if (F[RevHi].P-F[lo].P>LastMovDn)  {LastMovDn=F[RevHi].P-F[lo].P;}// обновляем последнее движение, если новый пик дальше от разворотной впадины, чем предыдущий   LINE("LastMovDn="+S4(LastMovDn)+" MidMovDn="+S4(MidMovDn), SHIFT(F[RevHi].T), F[RevHi].P,  bar+PicPer, F[lo].P, clrGreen);  
//      if (Target>0) MidMovDn=(MovDnSrt[0]+MathMax(MovDnSrt[1],LastMovDn))/2;  // среднее максимальных значений прошлых и последнего движения
//      if (MathAbs(Target)==1 || (MathAbs(Target)==2 && lo==RevLo)){ // отмеряем целевое движение вверх от последнего пика, или только от разворотного пика
//         TargetHi=F[lo].P+MidMovUp; //LINE("MidMovUp="+S4(MidMovUp), SHIFT(F[lo].T), F[lo].P,  SHIFT(F[lo].T), PreTargetHi, clrCornflowerBlue); 
//   }  }  }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   

// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
   

//int POC_DETECT(){// кол-во бар, образующих объем пика
//   double UpZone=P.New, DnZone=P.New-ATR, Zone=P.New-ATR/2;  // верхняя и нижняя границы поиска бар, формирующих POC
//   int BarOut=0, PocBars=0;
//   if (Dir<0) {UpZone=P.New+ATR; DnZone=P.New; Zone=P.New+ATR/2;} // при нижнем пике границы меняются местами
//   for (int p=bar; p<Bars; p++){// поиск назад от текущего бара
//      if (High[p]<DnZone || Low[p]>UpZone) BarOut++; else {PocBars++; } // бар или не попадает, или попадает в границы РОС   if (Prn) X(" PocBars="+DoubleToString(PocBars,0)+" p="+DoubleToString(p,0), (UpZone+DnZone)/2, p, clrRed);
//      if (p-bar>PicPer && BarOut>PocBars) break;}  // if (Prn) Print("p=",p," High[p]=",High[p]," Low[p]=",Low[p]," UpZone=",UpZone," DnZone=",DnZone);
//   //if (PocBars>PocPer){ 
//   //   LINE("Up: POC="+DoubleToString(PocBars,0), bar+PocBars, UpZone,  bar, UpZone, clrGreen); //+BarOut
//   //   LINE("Dn: POC="+DoubleToString(PocBars,0), bar+PocBars, DnZone,  bar, DnZone, clrGreen); //+BarOut
//   //   }
//   return (PocBars);
//   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
   
   
   //void DAY_ATR(){// Д Н Е В Н О Й   Д И А П А З О Н   З А   П О С Л Е Д Н И Е   П Я Т Ь   Д Н Е Й 
//   if (TimeHour(Time[bar])>TimeHour(Time[bar+1])) return; // новый день     
//   double DayHigh=High[iHighest(NULL,0,MODE_HIGH,BarsInDay,bar)], DayLow=Low[iLowest(NULL,0,MODE_LOW ,BarsInDay,bar)];
//   DayMov[DaysCnt]=DayHigh-DayLow; DaysCnt++; if (DaysCnt>=5) DaysCnt=0;
//   DayAtr=0; for (int i=0; i<5; i++) DayAtr+=DayMov[i]; DayAtr/=5; 
//   } //Print(ttt,"NewDay ","  ",DTIME(Time[bar])," DayHigh-DayLow=",DayHigh-DayLow,"   ",NormalizeDouble(DayMov[0],Digits-1)," ",NormalizeDouble(DayMov[1],Digits-1)," ",NormalizeDouble(DayMov[2],Digits-1)," ",NormalizeDouble(DayMov[3],Digits-1)," ",NormalizeDouble(DayMov[4],Digits-1),"      DayAtr=",NormalizeDouble(DayAtr,Digits-1));    

   
           
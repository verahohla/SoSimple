#include <head_PIC.mqh> 
#include <lib_TRG.mqh>
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
   Print("INIT: ",__FILE__,"  v",VERSION,"  compilation time: ",__DATETIME__);
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
   //NEW_W();             // Сигнал "Голова/Плечи" (стоит до TREND_DETECT(), т.к. проверяется пробитие Первых Уровней
   //TARGET_COUNT();// РАСЧЕТ ЦЕЛЕВЫХ УРОВНЕЙ ОКОНЧАНИЯ ДВИЖЕНИЯ НА ОСНОВАНИИ ИЗМЕРЕНИЯ ПРЕДЫДУЩИХ ДВИЖЕНИЙ   
   TREND_DETECT();      // ОПРЕДЕЛЕНИЕ ТРЕНДА (стоит до LEVELS_FIND_AROUND(), т.к. пробой уровней проверяется до их обновления    
   LEVELS_FIND_AROUND();// ПОИСК СИЛЬНЫХ УРОВНЕЙ      
   //LINE(" F/Fi="+S0(Atr.Fast/Point)+"/"+S0(fst/Point)+" S/Si="+S0(Atr.Slow/Point)+"/"+S0(slw/Point), bar+1, Close[bar], bar, Close[bar],  clrDarkSeaGreen,3);
   //Print(BTIME(bar)," NewPic=",New);
   return(true);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
void NEW_LEVEL(char dir, float NewFractal){// ФОРМИРОВАНИЕ И УДАЛЕНИЕ УРОВНЕЙ
   Update=True;// признак появления нового пика
   Dir=dir;    // направление последнего пика
   New=NewFractal;
   datetime OldestTime=Time[bar+PicPer];
   datetime ExPicTime=Time[Bars-1];// время ближайшшего превосходящего пика из массива...
   char  Cnt=1;         // кол-во совпадений c флэтовыми непробитыми пиками
   uchar Pics=0;        // кол-во совпадений со всеми пиками
   uchar FlatBegin=0;   // время начала флэта
   uchar Oldest=1;
   float LevMiddle=New; // средний уровень совпавших пиков
   float PwrSum=0;  // Сумма сил пиков, совпадающих с этим по уровню
   uchar LowestPowerCell=0;   // номер ячейки и 
   float LowestPower=99999;  // сила самого слабого уровня для удаления на случай, если не найдется свободной ячейки
   datetime StartSearchTime=Time[MathMin(bar+BarsInDay*5, Bars-1)];  // время начала поиска самого слабого уровня на удаление  = два дня назад
   n=0;           // новая свободная ячейка для заполнения
   for (uchar f=1; f<LevelsAmount; f++){// перебираем весь массив фракталов от большего к меньшему
      if (F[f].P==0) {n=f; continue;} // 
      if (F[f].T<OldestTime){ // ищем самый старый пик в массиве
         OldestTime=F[f].T;
         Oldest=f;
         }
      float check=F[f].Power/(1+F[f].Brk); // критерий удаления = минимальный фронт, деленный на степень пробоя
      if (F[f].T<StartSearchTime && F[f].Fls.Phase<START && check<LowestPower && f!=HI && f!=LO && f!=Hi2 && f!=Lo2 && f!=stpH && f!=stpL){// самый слабый уровень для удаления. Должен быть старше двух дней и не не стадии ложного пробития. 
         LowestPower=check; 
         LowestPowerCell=f;}     
      if (MathAbs(New-F[f].P)<Atr.Lim){ // совпадение уровней
         PwrSum+=F[f].Power;  // Сумма сил пиков, совпадающих с этим по уровню
         F[f].Pics++;   // кол-во совпадений со всеми пиками (пробитыми и зеркальными) 
         Pics++;        // для поиска уровня с максимальным количеством отскоков
         } 
      if (F[f].Brk==BROKEN){  // подтверждение зеркального уровня - достаточно глубокий пробой 
         if (F[f].Dir>0 && New>F[f].P+ATR*Power) {F[f].Brk=MIRROR;} // глубокий пробой   V(DTIME(Time[bar+PicPer])+"/"+S4(FrntVal), F[f].P, SHIFT(F[f].T), clrBlue);
         if (F[f].Dir<0 && New<F[f].P-ATR*Power) {F[f].Brk=MIRROR;} // сонаправленным пиком  
         }
      FALSE_BREAK(f);// проверка ложного пробоя при iSignal=1 (lib_Flat.mqh)
      if (F[f].Brk>=BROKEN) continue;   // далее рассматриваются непробитые уровни
      if (Dir==F[f].Dir){ // сонаправленный пик
         if (MathAbs(New-F[f].P)<Atr.Lim){// сравниваемые фракталы в пределах Lim и это не пробитый пик, т.е. между отобранным и новым пиками ничего не выступает  
            F[f].Brk=TOUCH;      // касание в пределах Lim
            F[f].Cnt++; Cnt++;   // поиск совпадающих уровней, увеличиваем кол-во совпадений
            LevMiddle+=F[f].P;   // и их сумма для усреднения LINE(S0(f)+" Lim="+S5(Atr.Lim)+" a="+S4(Atr.Fast)+" A="+S4(Atr.Slow), bar+PicPer,New,  SHIFT(F[f].T),F[f].P,clrLightBlue,0);
            if (FlatBegin==0 || F[f].T<F[FlatBegin].T) FlatBegin=f;// самый старый пик флэта, для противоположной границы
            if (Cnt>1) SQUARE_TRIANGLE(f, F[f].TRG.N); // если было совпадение вершин, обрабатывается прямоугольный треугольник
            }
         if (F[f].Brk==CLEAR){    // БЕЗ КАСАНИЯ     CLEAR(0)-нет, TOUCH(1)-касание, BROKEN(2)-пробой, MIRROR(3)-глубокий резкий пробой (зеркальный), USED(4)-никчемный
            if (F[f].T>ExPicTime)   ExPicTime=F[f].T; // время ближайшего превосходящего пика для поиска фронта
            if (Dir>0 && New>F[f].Near)  {F[f].Near=New; F[f].NearVal=New-F[f].Back;} // самый близкий подход цены к уровню - его цена и амплидуда
            if (Dir<0 && New<F[f].Near)  {F[f].Near=New; F[f].NearVal=F[f].Back-New;} //         
         }  }   
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
   if (n==0) {n=LowestPowerCell;} // X("n-"+DTIME(F[n].T)+" LowestPower="+S0(LowestPower), New,bar+PicPer, clrBlue);// если пустых ячеек нет, берем самую слабую  
   //Print(" OldestTime=",DTIME(F[Oldest].T)," Oldest=",S0(Oldest)," F[",n,"]=",N4(New)," at ",DTIME(Time[bar+PicPer])); 
   //PRN("n="+S0(n)+" "+DTIME(F[n].T)+" LowestPower="+S0(LowestPower));
   int Shift=iBarShift(NULL,0,ExPicTime,false); // сдвиг превосходящего пика относительно нового пика
   F[n].P=New;            // пишем в свободную ячейку значение фрактала
   F[n].T=Time[bar+PicPer];      // время возникновения фрактала
   F[n].Flt.T=Time[bar+PicPer];  // время формирования первого (дальнего) пика флэта
   F[n].Cnt=Cnt;  // кол-во совпадений с предыдущими непробитыми уровнями
   F[n].Pics=Pics;// кол-во совпадений со всеми уровнями  
   F[n].Dir=Dir;   // направление фрактала: 1=ВЕРШИНА, -1=ВПАДИНА
   F[n].ExT=ExPicTime; // время ближайшего превосходящего пика для поиска фронта
   F[n].Per=PicPer-1; // кол-во бар до пробоя пика
   F[n].Brk=CLEAR;   // Признак пробитости: CLEAR(0)-нет, TOUCH(1)-касание, BROKEN(2)-пробой, MIRROR(3)-глубокий резкий пробой (зеркальный), USED(4)-отработанный
   F[n].Wid=0;    // POC_DETECT(); 
   F[n].Rev=0; // Разворотный(повышающийся) - превосходящий предыдущий пик, только из разворотных выбираются Первые Уровни 
   F[n].First=false; // Признак сильного "Первого" уровня (большой передний и задний фронты, задний фронт еще не сформирован, поэтому false)
   F[n].TrBrk=NOTHING; // статус трендового уровня: NOTHING(-1)-не сформирован,  CLEAR(0)-сформирован,  BROKEN(2)-пробит  Пока хай не опустится под трендовый, он будет не действителен.
   F[n].Fls.Phase=NONE; // стадия ложняка: NONE, START, CONFIRM, BREAK
   F[n].TRG.N=0; // кол-во вершин в треугольнике
   F[n].PwrSum=PwrSum;  // Сумма сил пиков, совпадающих с этим по уровню
   if (Dir>0){ // вершина  
      F[n].Tr=New-Atr.Fast;// для вершины трендовый уровень не продажу (пока хай не опустится под трендовый, он будет не действителен)     LINE("PicHi="+S4(F[hi].P)+" F[hi].Trd="+S4(F[hi].Trd), bar+PicPer*2, F[hi].Trd,  bar, F[hi].Trd, clrRed);
      F[n].TrMid=(F[n].P+F[n].Tr)/2;     // серединка на пробой  F[n].Mid=F[n].P-(F[n].P-F[n].Tr)/3;
      F[n].Frnt=float(Low [iLowest (NULL,0,MODE_LOW ,Shift-(bar+PicPer),bar+PicPer)]);   // Передний Фронт уровня (величина развернутого им движения) = минимум, лежащий между новым пиком и превосходящим его баром.    
      F[n].Back=float(Low [iLowest (NULL,0,MODE_LOW ,PicPer,bar)]);// задний фронт = минимальная цена после пика. Будет постепенно увеличиваться по мере удаления цены от уровня       
      F[n].FrntVal=New-F[n].Frnt; // амплитуды
      F[n].BackVal=New-F[n].Back; // этих значений
      F[n].NearVal=0; // Near - уровень, до которого цена приближалась к пику. NearVal - расстояние от Back до Near, т.е. Back от Back
      if (New>F[hi].P)    {F[n].Rev=1;   RevHi=n;}  // "повышающийся пик"  нужен для формирования измеренных движений X("RevHi="+DoubleToString(Rev.F[hi].P,4), Rev.F[hi].P, bar+PicPer, clrRed);    
      hi2=hi; hi=n; //   if (F[n].FrntVal>ATR*Power) V(S0(n)+","+S4(F[n].FrntVal), New, bar+PicPer, clrRed);
   }else{      // впадина                                                             
      F[n].Tr=New+Atr.Fast;// для впадины трендовый уровень на покупку (пока лоу не поднимется над трендовым, он будет недействительным)
      F[n].TrMid=(F[n].P+F[n].Tr)/2;    // серединка на пробой    F[n].Mid=F[n].P+(F[n].Tr-F[n].P)/3;
      F[n].Frnt=float(High[iHighest(NULL,0,MODE_HIGH,Shift-(bar+PicPer),bar+PicPer)]);   // Передний Фронт уровня (величина развернутого им движения) = максимум, лежащий между новым пиком и нижележащим его баром. 
      F[n].Back=float(High[iHighest(NULL,0,MODE_HIGH,PicPer,bar)]);// задний фронт = максимальная цена после пика. Будет постепенно увеличиваться по мере удаления цены от уровня        
      F[n].FrntVal=F[n].Frnt-New; // амплитуды
      F[n].BackVal=F[n].Back-New; // этих значений
      F[n].NearVal=0; // Near - уровень, до которого цена приближалась к пику. NearVal - расстояние от Back до Near, т.е. Back от Back
      if (New<F[lo].P)    {F[n].Rev=1;   RevLo=n;} // "понижающаяся впадина"  нужен для формирования измеренных движений X("RevLo="+DoubleToString(F[RevLo].P,4), F[RevLo].P, bar+PicPer, clrGreen);
      lo2=lo; lo=n;  // 
      } 
   F[n].Power=MathMin(F[n].FrntVal,F[n].BackVal); // Power=MIN(FrntVal,BackVal)   
   FLAT_DETECT(LevMiddle, FlatBegin);
   //if (F[n].T==StringToTime("2000.04.19 11:00")) V(" Frnt="+S4(F[n].Frnt)+" Pics="+S0(F[n].Pics), New, bar+PicPer, clrBlue);
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
#define  DrawFirstLevels true 
void LEVELS_FIND_AROUND(){ // П О И С К   Б Л И З Л Е Ж А Щ И Х   У Р О В Н Е Й 
   uchar fHI=0, fLO=0, fH=0, fL=0; // номера уровней в массиве
   float minTrgHi=99999, minTrgLo=99999, minHI=999999, minLO=999999, minH=999999, minL=999999, StpVal=ATR*MathAbs(Trl); 
   TrgHi=0; TrgLo=0; stpH=0; stpL=0; // номера уровней в массиве
   for (uchar f=1; f<LevelsAmount; f++){// в нулевом хранится последнее значение, оно же записывается в массив вместо самого слабого пика 
      if (F[f].Brk>=BROKEN){// 2-4 глубоко пробитые более чем на Lim пунктов
         if (F[f].Brk<USED){ // проверка уровней на "отработанность"
            if (F[f].Dir>0)   {if (L<F[f].P+Atr.Lim) {F[f].Brk=USED; }} // цена подошла слишком близко к зеркальному уровню с обратной стороны, LINE(" ",SHIFT(F[f].T),High[SHIFT(F[f].T)],bar,L,clrRed,0);
            else              {if (H>F[f].P-Atr.Lim) {F[f].Brk=USED; }} // т.е. он отработан, ставим флаг "никчемный"         LINE(" ",SHIFT(F[f].T), Low[SHIFT(F[f].T)],bar,H,clrRed,0);
            }
         continue; // далее анализ только непробитых уровней
         }
      if (F[f].P==0)    continue; // пустые значения
      if (IS_BROKEN(f)) continue; // BROKEN-глубоко пробитые 
      if (F[f].Dir>0){ // вершина
         if (F[f].TrBrk==NOTHING){// трендовый уровень еще не сформирован
            if (H<F[f].Tr) {F[f].TrBrk=CLEAR;   if (F[f].Flt.Len>0) Trnd.DblTop=-F[f].P;} // окончательнрое формирование трендового, когда хоть один хай опустился ниже его уровня. Шортовый сигнал "Двойная вершина"
            else F[f].Wid++;// увеличение РОС пика до тех пор, пока не сформировался его трендовый уровень    
            }
         if (Target!=0) LOWEST_HI(TargetHi, minTrgHi, f, TrgHi);   // ближайший пик к расчитанному целевому уровню 
      }else{   // впадина
         if (F[f].TrBrk==NOTHING){// трендовый уровень еще не сформирован
            if (L>F[f].Tr) {F[f].TrBrk=CLEAR;   if (F[f].Flt.Len>0) Trnd.DblTop=F[f].P;}  // окончательнрое формирование трендового, когда хоть один лоу поднялся выше его уровня. Шортовый сигнал "Двойная вершина"
            else F[f].Wid++;// увеличение РОС пика до тех пор, пока не сформировался его трендовый уровень 
            }
         if (Target!=0) HIGHEST_LO(TargetLo, minTrgLo, f, TrgLo);  // ближайший пик к расчитанному целевому уровню 
         }
      F[f].Per++;  // увеличение периода уровня до момента пробития      
      if (Tch==0 && F[f].Brk==TOUCH)   continue; // Пик дб без касаний при Tch=0
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
      if (F[f].First==true){ // фильтр первых уровней
         if (F[f].Dir>0)   LOWEST_HI (H, minHI, f, fHI);  // ближайший первый  уровень к текущей цене, 
         else              HIGHEST_LO(L, minLO, f, fLO);  // ближайший первый  уровень к текущей цене, 
      }  }
   // П Е Р В Ы E    У Р О В Н И  if (Time[bar]<StringToTime("1999.11.26 08:00")  || Time[bar]>StringToTime("1999.11.27 00:00"))   return;    
   if (fHI>0 && HI!=fHI) HI=fHI;// ПЕРВЫЙ ТРЕНДОВЫЙ НА ПРОДАЖУ обновился и есть небольшой отрыв от него // && F[fHI].NearVal>F[fHI].BackVal/6        
   if (fLO>0 && LO!=fLO) LO=fLO;// ПЕРВЫЙ ТРЕНДОВЫЙ НА ПОКУПКУ обновился и есть небольшой отрыв от него //  && F[fLO].NearVal>F[fLO].BackVal/6        
   // У Р О В Н И    С Е Р Е Д И Н К И
   static float memHi,memLo,MaxPoc;
   if (memHi!=F[HI].P+F[HI].Back && F[HI].NearVal>F[HI].BackVal/4){ // обновилась вершина, либо Back  && F[HI].NearVal>F[HI].BackVal/4
      memHi=F[HI].P+F[HI].Back; // обновление контрольной суммы
      F[HI].Poc=POC(F[HI].Tr, (F[HI].P+F[HI].Back)/2, SHIFT(F[HI].T), SHIFT(F[HI].BackT), MaxPoc, Poc, false);   // POC на "уровне серединки" в диапазоне сильного движения 
      if (DrawFirstLevels) LINE("HI("+S0(HI)+"), "+S4(ATR)+" "+DTIME(F[HI].T), SHIFT(F[HI].T),F[HI].P, SHIFT(F[HI].BackT), F[HI].Back,DNCLR,0);  //V("TrDn", H, bar, DNCLR);
      }
   if (memLo!=F[LO].P+F[LO].Back && F[LO].NearVal>F[LO].BackVal/4){ // обновилась вершина, либо ее Back  && F[LO].NearVal>F[LO].BackVal/4
      memLo=F[LO].P+F[LO].Back; // обновление контрольной суммы
      F[LO].Poc=POC(F[LO].P+F[LO].BackVal/2, F[LO].Tr, SHIFT(F[LO].T), SHIFT(F[LO].BackT), MaxPoc, Poc, false);  // POC на "уровне серединки" в диапазоне сильного движения
      if (DrawFirstLevels) LINE("LO("+S0(LO)+"), "+S4(ATR)+" "+DTIME(F[LO].T), SHIFT(F[LO].T),F[LO].P, SHIFT(F[LO].BackT), F[LO].Back,UPCLR,0);  //A("TrUp", L, bar, UPCLR);
      }
   if (F[LO].Poc>0 && F[LO].Near<F[LO].Poc)  {F[LO].Poc=0;}// "уровень серединки" пробит A("TrDn", L1, bar+1, UPCLR);
   if (F[HI].Poc>0 && F[HI].Near>F[HI].Poc)  {F[HI].Poc=0;}// "уровень серединки" пробит   V("TrUp", H1, bar+1, DNCLR);  
   static float memHiPoc, memLoPoc;   
   if (memHiPoc!=F[HI].Poc) {memHiPoc=F[HI].Poc; if (DrawFirstLevels) LINE(" Back="+S4(F[HI].Back)+" "+DTIME(F[HI].T), SHIFT(F[HI].T),F[HI].Poc,  bar,F[HI].Poc, DNCLR,0); } //V("", F[HI].Poc, bar, DNCLR);
   if (memLoPoc!=F[LO].Poc) {memLoPoc=F[LO].Poc; if (DrawFirstLevels) LINE(" Back="+S4(F[LO].Back)+" "+DTIME(F[LO].T), SHIFT(F[LO].T),F[LO].Poc,  bar,F[LO].Poc, UPCLR,0); } //A("", F[LO].Poc, bar, UPCLR);
   if (F[HI].P==0) LINE("F[HI].P==0",  bar,L,   bar,H, clrGreen,5);
   if (F[LO].P==0) LINE("F[LO].P==0",  bar,L,   bar,H, clrRed,5);
   }     
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
bool IS_BROKEN(uchar f){ // ПРОБИТИЕ if (F[f].Brk>=BROKEN) continue;
   if (F[f].Dir>0){
      if (H>F[f].P+Atr.Lim)   {F[f].Brk=USED;   F[f].BrkT=Time[bar];}// пробитие глубже касания, пока ставится флаг "отработанный"    
      if (H>F[f].P+Atr.Max)   {F[f].Brk=BROKEN; } // если резкое и глубокое пробитие, уровень годится в кандидаты на зеркальный  V(BTIME(bar), F[f].P, SHIFT(F[f].T), clrBlue);  LINE(" ",SHIFT(F[f].T),F[f].P,bar,H,clrBlue,0);
   }else{
      if (L<F[f].P-Atr.Lim)   {F[f].Brk=USED;   F[f].BrkT=Time[bar];}// пробитие глубже касания, пока ставится флаг "отработанный"    
      if (L<F[f].P-Atr.Max)   {F[f].Brk=BROKEN;}// если резкое и глубокое пробитие, уровень годится в кандидаты на зеркальный           LINE(" ",SHIFT(F[f].T),F[f].P,bar,L,clrBlue,0);
      }
   if (F[f].Brk<TOUCH)   return(false); // далее обработка пробоев
   //if (F[f].Str!=0 && F[f].Brk==CLEAR) V(S0(f)+" F"+S4(F[f].Frnt)+" "+DTIME(F[f].ExT), F[f].P, SHIFT(F[f].T), clrBlack); 
   if (F[f].Power>ATR*Power){  // был пробит сильный уровень
      F[f].Fls.Phase=WAIT;} // его ложняк будет интересен: ставим начальный флаг. Флаг сбрасывается на "BREAK"  при формировании уровня в FLAT_DETECT()
   if (F[f].Flt.Len>0){// если это был флэт шириной более FltLen бар,
      if (F[f].Dir>0) Trnd.FltBrk=F[f].P; else Trnd.FltBrk=-F[f].P;//  генерится сигнал "пробой флэта"
      }  
   return(true);   
   }     
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void TREND_DETECT(){ // О П Р Е Д Е Л Е Н И Е   Т Р Е Н Д А  
   // отмена сигналов "формирование флэта" 
   if (Trnd.DblTop>0 && Trnd.DblTop-L>Atr.Lim)  Trnd.DblTop=0; // цена пробила
   if (Trnd.DblTop<0 && H+Trnd.DblTop>Atr.Lim) Trnd.DblTop=0;  // сформированный флэт
   // отмена сигналов "Пробой флэта"
   if (Trnd.FltBrk>0 && H<Trnd.FltBrk)   Trnd.FltBrk=0;  // цена вернулась в   
   if (Trnd.FltBrk<0 && L>-Trnd.FltBrk)  Trnd.FltBrk=0;  // пробитый флэт
   // Cмена глоб. тренда при пробитии Первых Уровней.
   if (HI>0 && H-F[HI].P>Atr.Lim)   {Hi2=HI; HI=0;  if (fGlb==2) Trnd.Global= 1;}  // V(" HI="+S4(H), F[Hi2].P, bar, clrOrange);   
   if (LO>0 && F[LO].P-L>Atr.Lim)   {Lo2=LO; LO=0;  if (fGlb==2) Trnd.Global=-1;}  // A(" LO="+S4(H), F[Lo2].P, bar, clrOrange); 
   
   if (fGlb==1){ // Cмена глоб. тренда при пробитии "Уровней серединки", определяемого максимальным скоплением бар
      if (Trnd.Global!= 1 && H>F[HI].Poc && H1<F[HI].Poc)  {Trnd.Global= 1;}  //  LINE("HI PocPrice",   bar+3,F[HI].PocPrice, bar, F[HI].PocPrice,clrRed,0);
      if (Trnd.Global!=-1 && L<F[LO].Poc && L1>F[LO].Poc)  {Trnd.Global=-1;}  //  LINE("LO PocPrice",   bar+3,F[LO].PocPrice, bar, F[LO].PocPrice,clrGreen,0);  
      }
   // значительный ИМПУЛЬС из последнего пика /(SHIFT(F[hi].T)-bar)
   if ((F[hi].BackVal)>Atr.Slow*fImp) {Trnd.Imp=F[hi].Back-F[hi].P; }  // ИМПУЛЬС ВНИЗ V(S0(lo)+" "+S4(Trnd.Imp)+" Back="+S4(F[lo].Back), High[bar], bar, clrGreen);
   if ((F[lo].BackVal)>Atr.Slow*fImp) {Trnd.Imp=F[lo].Back-F[lo].P; }  // ИМПУЛЬС ВВЕРХ  A(S0(lo)+" "+S4(Trnd.Imp)+" Back="+S4(F[lo].Back), Low [bar], bar, clrGreen);
   if (Atr.Fast<Atr.Slow) Trnd.Imp=0;  // отмена сигнала импульса при спадании АТР    
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void FILTERS(char DblTop, char Imp, char FltBrk, char& Up, char& Dn){// суммирование входных сигналов  
   Up=1; Dn=1; 
   if (Trnd.Global>0) Dn=0;    // глобальный
   if (Trnd.Global<0) Up=0;    // тренд
   SIG_SUM(DblTop, Trnd.DblTop,   Up, Dn); // двойной отскок
   SIG_SUM(FltBrk, Trnd.FltBrk,   Up, Dn); // пробой флэта
   SIG_SUM(Imp,    Trnd.Imp,      Up, Dn); // резкий импульс
   
   if (fGlb   && Trnd.Global>0)   LINE("Up="+S0(Up)+" Global="  +S0(Trnd.Global), bar+1, Low [bar+1]-Atr.Slow, bar, Low [bar]-Atr.Slow, clrBlack,0);
   if (fGlb   && Trnd.Global<0)   LINE("Dn="+S0(Dn)+" Global="  +S0(Trnd.Global), bar+1, High[bar+1]+Atr.Slow, bar, High[bar]+Atr.Slow, clrBlack,0); 
   if (DblTop && Trnd.DblTop>0)   LINE("Up="+S0(Up)+" DblTop", bar+1, Low [bar+1]-Atr.Slow*1.2, bar, Low [bar]-Atr.Slow*1.2, clrRed,0);
   if (DblTop && Trnd.DblTop<0)   LINE("Dn="+S0(Dn)+" DblTop", bar+1, High[bar+1]+Atr.Slow*1.2, bar, High[bar]+Atr.Slow*1.2, clrRed,0); 
   if (FltBrk && Trnd.FltBrk>0)   LINE("Up="+S0(Up)+" BrkFlat",   bar+1, Low [bar+1]-Atr.Slow*1.4, bar, Low [bar]-Atr.Slow*1.4, clrGreen,0);
   if (FltBrk && Trnd.FltBrk<0)   LINE("Dn="+S0(Dn)+" BrkFlat",   bar+1, High[bar+1]+Atr.Slow*1.4, bar, High[bar]+Atr.Slow*1.4, clrGreen,0); 
   if (Imp    && Trnd.Imp>0)      LINE("Up="+S0(Up)+" Imp="     +S0(Trnd.Imp),    bar+1, Low [bar+1]-Atr.Slow*1.6, bar, Low [bar]-Atr.Slow*1.6, clrMagenta,0);
   if (Imp    && Trnd.Imp<0)      LINE("Dn="+S0(Dn)+" Imp="     +S0(Trnd.Imp),    bar+1, High[bar+1]+Atr.Slow*1.6, bar, High[bar]+Atr.Slow*1.6, clrMagenta,0); 
   }    // if (Prn) X("Flt="+DoubleToString(Trnd.Flt,0)+" Global="+DoubleToString(Trnd.Global,0)+" Trnd.Dn="+DoubleToString(1,0), Close[bar], bar, clrGray);
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void SIG_SUM(char SumMethod, float Sig, char& Up, char& Dn){// trend signals sum: "NO", "AND", "OR"
   if (SumMethod==0) return;
   if (SumMethod<0){   // signal reverse
      if (Sig>0) Sig=-1;
      if (Sig<0) Sig= 1;
      } 
   switch (MathAbs(SumMethod)){   
      case 1:  // "NO" отмена противоположного
         if (Sig>0)  {Dn=0;}  // 
         if (Sig<0)  {Up=0;}  //
      break;   
      case 2: // "AND" - сложение сигналов
         if (Sig<=0 && Up>0) Up=0; // 
         if (Sig>=0 && Dn>0) Dn=0; //
      break;
      case 3:  // "OR" доминирующий над "AND" сигнал c отменой противоположного
         if (Sig>0 && Trnd.Global>=0)  Up=1;   // блокировка противоположного,  
         if (Sig<0 && Trnd.Global<=0)  Dn=1;   // если не было аналогичной блокировки, ставим флаг "2"
      break;
   }  }
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

   
           
void SIG_FIRST_LEVELS_CONFIRM(){  // работа от первых уровней с подтверждением
   // ПРОДАЖА ОТ ПИКА ПЕРВОГО УРОВНЯ
   if (setSEL.T!=F[HI].T){// при смене первых уровней
      setSEL.T=F[HI].T;      // запоминаем время формирования первых уровней 
      setSEL.Sig=1;          // сигнал переходит на стадию ожидания,
      SELSTP=0; SELLIM=0;// установленные ордера отменяются
      V("BEGIN", F[HI].P, bar, clrSlateBlue);
      }  
   if (SEL.Val) {setSEL.Sig=0;} // X(" ", Close[bar], bar, clrBlue);
   if (F[hi].P>setSEL.Sig1.P)   {setSEL.Sig=1;} // при обновлении пика перезаход    X("XXX Step="+S0(setSEL.Sig), Close[bar], bar, clrBlue);
   //if (setSEL.Sig>WAIT && High[bar]>setSEL.Sig1.P) {setSEL.Sig=BLOCK; X(" ", High[bar], bar, clrBlue);} // при обновлении пика блокировка сигнала до формирования следующей зоны продажи 
   
   float delta=(MathAbs(iParam)+1)*ATR;
   // ПООЧЕРЕДНОЕ ОТСЛЕЖИВАНИЕ ПАТТЕРНОВ
   switch (setSEL.Sig){
   case 1:  // ОЖИДАНИЕ КАСАНИЯ ЗОНЫ ПРОДАЖИ
      //X("F[hi].P="+S4(F[hi].P), F[hi].P, bar, clrGray);
      if (F[hi].P<F[HI].P && F[hi].P>F[HI].P-delta && F[hi].T>F[HI].T){ // последний пик в зоне продажи и возник после ее формирования
         setSEL.Sig=2;// переключение на следующий шаг - "откат"
         setSEL.Sig1=F[hi];      // копирование структуры пиков в структуру сигналов (все уровни и времена)
         V("WAIT", setSEL.Sig1.P, SHIFT(setSEL.Sig1.T), clrRed);
         }
   break;
   case 2: // ОТКАТ = формирование уровня, пробой которого даст подтверждение
      // I вариант
      if (F[lo].T>setSEL.Sig1.T){// после верхнего пика возникла впадина  && F[lo].P>Sel.Zone.Dn   и она в зоне продажи
         setSEL.Sig=3;    // подтверждение пробоем ближайшего трендового
         setSEL.Sig2=F[lo];            //  копирование структуры пиков в структуру сигналов (все уровни и времена)
         A("START-1", setSEL.Sig2.P, bar, clrYellow);
         LINE("setSEL.Sig2.TrMid="+S4(setSEL.Sig2.TrMid), bar+1, setSEL.Sig2.TrMid, bar, setSEL.Sig2.TrMid,  clrBlue,0);
         }
      //// II вариант
      if (High[bar]>High[bar+1] && High[bar]<setSEL.Sig1.P){// из хаев образовалась впадина (трендовый уровень на покупку)
         setSEL.Sig=3;    // подтверждение пробоем ближайшего трендового
         setSEL.Sig2.P=float(Low[bar+1]);// значение самого пика и 
         setSEL.Sig2.TrMid=float(Low[bar+1]+(High[bar+1]-Low[bar+1])/3); // его серединки
         setSEL.Sig2.T=Time[bar+1]; // момент отката
         A("START-2", setSEL.Sig2.P, bar, clrBlue);
         LINE("setSEL.Sig2.TrMid="+S4(setSEL.Sig2.TrMid), bar+1, setSEL.Sig2.TrMid, bar, setSEL.Sig2.TrMid,  clrBlue,0);
         }     
   break;
   case 3:// ПОДТВЕРЖДЕНИЕ
      if (Low[bar]<setSEL.Sig2.TrMid && Time[bar]-setSEL.Sig2.T<BarSeconds*10){   // противоположный пик подтверждения пробит не позже 10бар
         setSEL.Sig=GOGO;    // сигнал на открытие позы
         setSEL.Val=setSEL.Sig1.Tr;// трендовый уровень первого пика
         setSEL.Val=setSEL.Sig2.TrMid;// серединка второго пика (подтверждающего)
         setSEL.Stp=setSEL.Sig1.P; // за первый пик
         setSEL.Prf=setSEL.Sig1.Frnt; // треть движения, коснувшегося зоны продажи
         A("GOGO", setSEL.Val, bar,  clrBlack);
         }
   break;
   case GOGO:  break;//setSEL.Sig=WAIT;      
      }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   // ПОКУПКА ОТ ВПАДИНЫ ПЕРВОГО УРОВНЯ
   if (setBUY.T!=F[LO].T){// при смене первых уровней
      setBUY.Sig=WAIT;          // сигнал сбрасывается на стадию ожидания,
      BUYSTP=0; BUYLIM=0;}    // установленные ордера отменяются
   setBUY.T=F[LO].T;      // запоминаем время формирования первых уровней
   if (F[lo].P<setBUY.Sig1.P) {setBUY.Sig=WAIT;} // при обновлении пика перезаход
   if (BUY.Val) {setBUY.Sig=BLOCK;} // X(" ", Close[bar], bar, clrBlue);
   // ПООЧЕРЕДНОЕ ОТСЛЕЖИВАНИЕ ПАТТЕРНОВ
   switch (setBUY.Sig){
   case WAIT:  // ОЖИДАНИЕ КАСАНИЯ ЗОНЫ ПОКУПКИ
      X("F[lo].P="+S4(F[lo].P), F[lo].P, bar, clrGray);
      if (F[lo].P<F[LO].P+delta && F[lo].P>F[LO].P && F[lo].T>F[LO].T){ // последний пик в зоне продажи и возник после ее формирования
         setBUY.Sig=START;   // переключение на следующий паттерн - "откат"
         setBUY.Sig1=F[lo];         // копирование структуры пиков в структуру сигналов (все уровни и времена)
         X("WAIT Frnt="+S4(setBUY.Sig1.Frnt), setBUY.Sig1.P, SHIFT(setBUY.Sig1.T), clrOrangeRed);
         }
   break;
   case START: // ОТКАТ = формирование уровня, пробой которого даст подтверждение
      // I вариант
      if (F[hi].T>setBUY.Sig1.T){// после нижнего пика возник пик и он в зоне покупки    && F[lo].P>Buy.Zone.Dn
         setBUY.Sig=CONFIRM;    // подтверждение пробоем ближайшего трендового
         setBUY.Sig2=F[hi];    //  копирование структуры пиков в структуру сигналов (все уровни и времена)
         X("START P="+S4(setBUY.Sig1.P), setBUY.Sig2.P, bar, clrYellow);
         }
      // II вариант
      if (Low[bar]<Low[bar+1]){ // из хаев образовалась впадина (трендовый уровень на покупку)
         setBUY.Sig=CONFIRM;      // подтверждение пробоем ближайшего трендового
         setBUY.Sig2.P=float(High[bar+1]); // значение самого пика и 
         setBUY.Sig2.TrMid=float(High[bar+1]-(High[bar+1]-Low[bar+1])/3); // его серединки
         setBUY.Sig2.T=Time[bar+1];// момент отката
         X("START P="+S4(setBUY.Sig1.P), setBUY.Sig2.P, bar, clrYellow);
         }     
   break;
   case CONFIRM:// ПОДТВЕРЖДЕНИЕ
      if (High[bar]>setBUY.Sig2.TrMid && Time[bar]-setBUY.Sig2.T<BarSeconds*10){   // противоположный пик подтверждения пробит не позже 10бар
         setBUY.Sig=GOGO;         // сигнал на открытие позы
         setBUY.Val=setBUY.Sig1.Tr;   // трендовый уровень первого пика
         setBUY.Val=setBUY.Sig2.TrMid;   // серединка второго пика (подтверждающего)
         setBUY.Stp=F[LO].P;       // за первый пик (уровень) 
         setBUY.Prf=setBUY.Sig1.Frnt; // треть движения, коснувшегося зоны покупки
         X("CONF P.Front="+S4(F[lo].P+setBUY.Sig1.Frnt)+"Stp="+S4(setBUY.Stp), setBUY.Val, bar,  clrWhite);
         }
   break;
   case GOGO:  break;//setBUY.Sig=WAIT;      
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   


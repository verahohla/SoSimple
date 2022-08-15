
void SIG_NULL(){
   Buy.Pattern=GOGO;    // сигнал на открытие позы
   setBUY.Val=(float)Ask;  // трендовый уровень первого пика
   setBUY.Stp=(float)Ask-ATR*2; // 
   setBUY.Prf=(float)Ask+ATR*5; // 
   Sel.Pattern=GOGO;    // сигнал на открытие позы
   setSEL.Val=(float)Bid;  // трендовый уровень первого пика
   setSEL.Stp=(float)Bid+ATR*2; // 
   setSEL.Prf=(float)Bid-ATR*5; // 
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
void SIG_FIRST_LEVELS(){ // От первых уровней и уровней серединки.  iSignal=2; Iprice=1..2
   float Delta=float(ATR*Front/2);     
   // Ш О Р Т О В Ы Е   П А Т Т Е Р Н Ы   ////////////////////////////////////////////////////////////////////////////
   if (Sel.Mem!=F[HI].P){// при обновлении Первого Уровня на Продажу
      Sel.Mem=F[HI].P;
      Sel.Pattern=WAIT;          // сигнал переходит на стадию ожидания,
      }//V("HI="+S0(HI), F[HI].P, bar, clrPink);
   if (SEL.Val) {Sel.Pattern=NONE;}
   switch (Sel.Pattern){ 
      case WAIT:  // удаление от ЗОНЫ ПРОДАЖИ
         if (F[HI].P-H>Delta){   // цена опустилась от уровня продажи достаточно низко
            Sel.T=Time[bar];     // время формирования сигнала
            Sel.Pattern=GOGO;    // сигнал на открытие позы
            V("GOGO", H, bar,  clrGreen);
            switch (Iprice){
               case  2: SELL_PIC(jmpHI);  SELL_STOP(F[jmpHI].P);  break;// от Уровней серединки
               case  1: SELL_PIC(HI);     SELL_STOP(F[HI].P);     break;// от Первых Уровней  
            }  }
      break;
      case GOGO:// после выставления ордеров при начале приближения к точке входа снимаем сигнал  
         if (F[HI].P-H<Delta) {Sel.Pattern=WAIT;   V("WAIT", H, bar,  clrGreen);}           
      break;
      }     
   // Л О Н Г О В Ы Е   П А Т Т Е Р Н Ы   ////////////////////////////////////////////////////////////////////////////
   if (Buy.Mem!=F[LO].P){// при обновлении Первого Уровня на Покупку
      Buy.Mem=F[LO].P;
      Buy.Pattern=WAIT;          // сигнал переходит на стадию ожидания,
      }  // A("LO="+S0(LO), F[LO].P, bar, clrLightBlue);
   if (BUY.Val) {Buy.Pattern=NONE;} // X(" ", Close[bar], bar, clrBlue);
   switch (Buy.Pattern){ 
      case WAIT:  // удаление от ЗОНЫ ПОКУПКИ
         if (L-F[LO].P>Delta){// цена поднялась над уровнем покупки достаточно высоко
            Buy.T=Time[bar];// время формирования сигнала
            Buy.Pattern=GOGO;    // сигнал на открытие позы
            A("GOGO", L, bar,  clrGreen);
            switch (Iprice){
               case  2: BUY_PIC(jmpLO);  BUY_STOP(F[jmpLO].P);  break;// от Уровней серединки
               case  1: BUY_PIC(LO);     BUY_STOP(F[LO].P);     break;// от Первых Уровней  
               
            }  } 
      break;
      case GOGO:// после выставления ордеров снимаем сигнал   
         if (L-F[LO].P<Delta) {Buy.Pattern=WAIT; A("WAIT", L, bar,  clrGreen);}          
      break;//       
      }  
   if (Real) ERROR_CHECK("SIG_FIRST_LEVELS");
   }

   ////  SET  INPUT
   //switch (Iprice){   
   //   case  2: // от Первых Уровней    V("F[HI].P"+S4(F[HI].P),F[HI].P, bar, clrWhite);
   //      SET_OPEN(LO, HI);       
   //      SET_STOP(F[LO].P, F[HI].P); // установка и проверка стопов                          
   //   break;                                    
   //   case  1: // из функций сигналов V("setSEL.Val="+S4(setSEL.Val),setSEL.Val, bar, clrYellow);       
   //      SET_STOP(setBUY.Stp,    setSEL.Stp); // проверка стопов                       
   //   break;             
   //   case  0: // по текущей цене
   //      if (UP>0) setBUY.Val=float(Ask)-DELTA(D);  
   //      if (DN>0) setSEL.Val=float(Bid)+DELTA(D);  
   //      SET_STOP(F[stpL].P, F[stpH].P); // за ближайшие сильные пики               
   //   break;   
   //   case -1: // Пробой первых уровней
   //      SET_OPEN(HI, LO);       
   //      SET_STOP(setBUY.Val-MinStop, setSEL.Val+MinStop);  
   //   break;
   //   }//LINE("Up/Dn="+S0(UP)+"/"+S0(DN)+" BUY.Val/Stp-SEL.Val/Stp="+S4(setBUY.Val)+"/"+S4(setBUY.Stp)+"-"+S4(setSEL.Val)+"/"+S4(setSEL.Stp), bar+1, Close[bar+1], bar, Close[bar],  clrGray,0);   
   
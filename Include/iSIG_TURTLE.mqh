


void SIG_TURTLE(){
   // УДАЛЕНИЕ ОТЛОЖНИКА ПРИ "ПЕРЕДЫШКЕ" ЦЕНЫ ПЕРЕД НИМ
   //if (Update==True){
      if (SELSTP>0 && High[bar]>Sel.Mem) {Sel.Pattern=0; SELSTP=0; Modify=true;} // повторный пробой пробивающего пика (ложняк пробился), 
      if (BUYSTP>0  && Low [bar]<Buy.Mem) {Buy.Pattern=0; BUYSTP=0;  Modify=true;} // отменяем сигнал
      
      if (BrokenPic>0 && // номер последнего пробитого пика
         F[BrokenPic].Back>=ATR*Front && // с достаточным отскоком
         F[BrokenPic].TrBrk >-1 &&  // сформированным трендовым уровнем
         F[BrokenPic].Per>FltLen*5 && SHIFT(F[BrokenPic].T)>FltLen){   // период последнего пробитого пика достаточно велик и с момента его формирования до пробоя больше FltLen бар
         
         if (F[BrokenPic].Dir>0){// пробита вершина
            Sel.Pattern=WAIT; // ждем окончания формирования пробивающего пика
            Sel.T=Time[bar];         // время пробивающего бара
            Sel.Mem=F[BrokenPic].P;  // значение пробитой вершины
            if (D>-2) {BUY_PIC(lo);}// низ зоны продажи
            else     setSEL.Val=F[BrokenPic].P+DELTA(D+2);  // стоп ордер на возврат к пробитой вершине 
            setSEL.Prf=setSEL.Val-ATR*5; 
            //V(" Per="+S0(F[BrokenPic].Per)+" Shift="+S0(SHIFT(F[BrokenPic].T)), H, bar, clrRed);
            LINE(" ", SHIFT(F[BrokenPic].T),F[BrokenPic].P, bar,H, clrGray,0); 
         }else{// пробитая впадина
            Buy.Pattern=WAIT;
            Buy.T=Time[bar];
            if (D>-2) {SELL_PIC(hi);}     // последняя вершинка, из которой был выстрел
            else     setBUY.Val=F[BrokenPic].P-DELTA(D+2); // пробитая впадина
            setBUY.Prf=setBUY.Val+ATR*5;
            //A(" Per="+S0(F[BrokenPic].Per)+" Shift="+S0(SHIFT(F[BrokenPic].T)), L, bar, clrBlue);
            LINE("  Tbuy="+DTIME(Buy.T)+" New="+S4(setBUY.Val), SHIFT(F[BrokenPic].T),F[BrokenPic].P, bar,L, clrGray,0);
            }
         }
      if (Sel.Pattern==WAIT && F[hi].T>=Sel.T){  // дождались формирования пробивающего пика
         Sel.Pattern=GOGO;    // сигнал на открытие позы
         Sel.Mem=F[hi].P; // запомним теперь значение пробивающей вершины
         setSEL.Stp=F[hi].P;  // за первый пик
         V(" GOGO Mem="+S4(Sel.Mem), F[hi].P, SHIFT(F[hi].T), clrRed);
         }
      if (Buy.Pattern==WAIT && F[lo].T>=Buy.T){ 
         Buy.Pattern=GOGO;
         Buy.Mem=F[lo].P; // запомним значение пробивающей впадины
         setBUY.Stp=F[lo].P;  // за первый пик
         A(" GOGO Mem="+S4(Buy.Mem), F[lo].P, SHIFT(F[lo].T), clrBlue);
         }       
   //if (Real) ERROR_CHECK("SIG_TURTLE");
   }


void SIG_FALSE_BREAK(){// при iSignal=1  
   // iParam=0..3 - Максимальный вылет ложняка = ATR*(iParam+1). /lib_flat.mqh
   // П Р О Б О Й   В Е Р Ш И Н Ы  =  Ш О Р Т    ////////////////////////////////////////////////////////////////////////////
   if (setSEL.Mem!=FlsUp && F[FlsUp].Fls.Phase==GOGO && setSEL.Sig!=GOGO){// образовался новый ложняк, он подтвердился, нет сигнала от прошлого ложняка
      setSEL.Mem=FlsUp;  // фиксим номер ложняка
      setSEL.Sig=GOGO;    // сигнал на открытие позы
      setSEL.T=Time[bar];// время формирования сигнала
      /*    D   */   // цена входа (c подтверждением)
      /*  5.. 3 */   if (D> 2)   setSEL.Val = F[FlsUp].P       +float((D-4)*ATR/2); else  // лимитник от пробитой вершины  -0.5 .. +0.5 ATR
      /*  2.. 0 */   if (D>=0)   setSEL.Val = F[FlsUp].Fls.Base+float((D-1)*ATR/2); else  // лимитник от базы ложняка      -0.5 .. +0.5 ATR
      // без подтверждения - сразу ставим ордер на пробой при D<0
      /* -1..-2 */   if (D>-3)   setSEL.Val = F[FlsUp].P       +float((D+1)*ATR/2); else  // обратный пробой пробитой вершины  -0.5 .. +0 ATR
      /* -3..-5 */               setSEL.Val = F[FlsUp].Fls.Base+float((D+4)*ATR/2);       // пробой базы ложняка           -0.5 .. +0.5 ATR
      setSEL.Stp=F[FlsUp].Fls.P+DELTA(Stp);// за пик ложняка
      setSEL.Prf=F[FlsUp].Back;// тейк на величину движения, которое дал уровень
      //V("GOGO "+S0(FlsUp), setSEL.Val, bar,  clrGreen);
      }  
   if (setSEL.Sig==GOGO && F[FlsUp].Fls.Phase==NONE){// отмена сигнала при отмене ложняка 
      setSEL.Sig=NONE;
      }       
      
   // П Р О Б О Й   В П А Д И Н Ы  =  Л О Н Г   ////////////////////////////////////////////////////////////////////////////
   if (setBUY.Mem!=FlsDn && F[FlsDn].Fls.Phase==GOGO && setBUY.Sig!=GOGO){// образовался новый ложняк, он подтвердился, нет сигнала от прошлого ложняка 
      setBUY.Mem=FlsDn;  // фиксим номер ложняка
      setBUY.Sig=GOGO;    // сигнал на открытие позы
      setBUY.T=Time[bar];// время формирования сигнала
      /*    D   */   // цена входа (c подтверждением)
      /*  5.. 3 */   if (D> 2)   setBUY.Val = F[FlsDn].P       -float((D-4)*ATR/2); else  // лимитник от пробитой впадины  -0.5 .. +0.5 ATR
      /*  2.. 0 */   if (D>=0)   setBUY.Val = F[FlsDn].Fls.Base-float((D-1)*ATR/2); else  // лимитник от базы ложняка      -0.5 .. +0.5 ATR
      // без подтверждения - сразу ставим ордер на пробой при D<0
      /* -1..-2 */   if (D>-3)   setBUY.Val = F[FlsDn].P       -float((D+1)*ATR/2); else  // обратный пробой пробитой впадины  -0.5 .. +0 ATR
      /* -3..-5 */               setBUY.Val = F[FlsDn].Fls.Base-float((D+4)*ATR/2);       // пробой базы ложняка           -0.5 .. +0.5 ATR
      setBUY.Stp=F[FlsDn].Fls.P-DELTA(Stp);  // за первый пик
      setBUY.Prf=F[FlsDn].Back;// тейк на величину движения, которое дал уровень
      //A("GOGO "+S0(FlsDn), setBUY.Val, bar,  clrGreen);
      }
   if (setBUY.Sig==GOGO && F[FlsDn].Fls.Phase==NONE){     // отмена ложняка
      setBUY.Sig=NONE;
      }
   if (Real) ERROR_CHECK("FALSE_BREAK_SIG");
   }
   
   
   

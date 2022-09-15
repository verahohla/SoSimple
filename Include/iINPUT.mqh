// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void INPUT(){
   //if (LO==0 || HI==0)  return; // если первые уровни не определены все сигналы блокируются
   setBUY.Val=0; setBUY.Stp=0; setBUY.Prf=0;    setSEL.Val=0; setSEL.Stp=0; setSEL.Prf=0; // значения ордеров 
   MinStop=MathAbs(sMin)*ATR/2;
   MaxStop=MathAbs(sMax)*ATR+MinStop; 
   if (BUY.Val)    UP=0; // UP,DN могут принимать значения -1..2
   if (SEL.Val)   DN=0;  
   SIG_LINES(UP==1," UP="+S0(UP)+" Buy="+S4(BUY.Val) +" BuyLim="+S4(BUYLIM), 
             DN==1," DN="+S0(DN)+" Sel="+S4(SEL.Val)+" SelLim="+S4(SELLIM),clrSIG1);
   // ПЕРЕКЛЮЧАТЕЛЬ ГЛОБАЛЬНЫХ СИГНАЛОВ.
   switch(iSignal){ 
      case 1:  FALSE_BREAK_SIG();   break;   // работает в lib_PIC
      case 2:  SIG_FIRST_LEVELS();        break;   // ОТСКОК  (iParam=0..4~лимитка удаляется при приближении цены  ATR*Back*2/(iParam+1)
      case 3:  SIG_FIRST_LEVELS_CONFIRM();   break;   // LONG_FIRST_LEV(); 
      case 4:  SIG_TURTLE();        break;
      default: SIG_NULL();          break;   // БЕЗ ГЛОБАЛОВ
      }
   if (setBUY.Sig!=GOGO) UP=0;
   if (setSEL.Sig!=GOGO) DN=0;   
   SIG_LINES(setBUY.Sig==GOGO,"GOGO: UP="+S0(UP)+" Buy="+S4(BUY.Val) +" BuyLim="+S4(BUYLIM), 
             setSEL.Sig==GOGO,"GOGO: DN="+S0(DN)+" Sel="+S4(SEL.Val)+" SelLim="+S4(SELLIM),clrSIG1);  // линии сиглалов MovUP и MovDN: (сигналы, смещение от H/L, цвет)      
   
   //LINE("Up/Dn="+S0(UP)+"/"+S0(DN)+" FlsUpDn="+S0(FlsUp)+"/"+S0(FlsDn)+" FlsPhase="+S0(F[FlsUp].Fls.Phase)+"/"+S0(F[FlsDn].Fls.Phase)+" PtrnBuy/Sel="+S0(setBUY.Sig)+"/"+S0(setSEL.Sig), bar+1, Close[bar+1], bar, Close[bar],  clrSilver,0); 
   LINE("FlsUp/Dn="+S0(FlsUp)+"/"+S0(FlsDn)+" PhaseUp/Dn"+S0(F[FlsUp].Fls.Phase)+"/"+S0(F[FlsDn].Fls.Phase)+" PatternBuy/Sel="+S0(setBUY.Sig)+"/"+S0(setSEL.Sig), bar+1, Close[bar+1], bar, Close[bar],  clrSilver,0);
   if (UP<1 && DN<1) return; // UP,DN могут принимать значения -1..2
   SET_PROFIT();
   SIG_LINES(UP,"2 setBUY.Val=" +S4(setBUY.Val) +" setBUY.Val="+S4(setBUY.Val), 
             DN,"2 setSEL.Val="+S4(setSEL.Val)+" setSEL.Val="+S4(setSEL.Val),clrSIG2);     
   // УДАЛЕНИЕ СТАРЫХ ОРДЕРОВ
   if (ExpirBars==0){// Удаление отложников при появлении нового сигнала
      if (setBUY.Val >0 && (MathAbs(setBUY.Val-MathMax(BUYSTP ,BUYLIM ))>ATR/2 || MathAbs(setBUY.Stp -BUY.Stp)>ATR/2))   {BUYSTP=0;    BUYLIM=0;   Modify=true;}  //    X("BUYLIM=" +S4(BUYLIM)+ " setBUY.Val=" +S4(setBUY.Val), BUYLIM, 0, clrBlack);
      if (setSEL.Val>0  && (MathAbs(setSEL.Val-MathMax(SELSTP,SELLIM))>ATR/2 || MathAbs(setSEL.Stp-SEL.Stp)>ATR/2))   {SELSTP=0;   SELLIM=0;  Modify=true;}   //  X("SELLIM="+S4(SELLIM)+" setSEL.Val="+S4(setSEL.Val),SELLIM,0, clrBlack);
      }
   else if (ExpirBars<0){// удаление отложника при пропадании сигнала
      if (DN<1 && (SELSTP>0 || SELLIM>0))  {SELSTP=0; SELLIM=0; Modify=true;}
      if (UP<1 && (BUYSTP>0  ||  BUYLIM>0))  {BUYSTP=0;  BUYLIM=0;  Modify=true;} 
      }
   else {// новый сигнал игнорируется, пока стоит старый отложник (удалится по экспирации >0)
      if (BUYSTP  || BUYLIM)  setBUY.Val=0;
      if (SELSTP || SELLIM) setSEL.Val=0;
      }
   //if (setSEL.Val)   setSEL.Sig=DONE; // ордер готов,
   //if (setBUY.Val)    setBUY.Sig=DONE; // сбрасываем паттерн   
   SIG_LINES(setBUY.Val ,"3 setBUY.Val="+S4(setBUY.Val)+" BUYLIM="+S4(BUYLIM), 
             setSEL.Val,"3 setSEL.Val="+S4(setSEL.Val)+" SELLIM="+S4(SELLIM),clrSIG3); // линии сиглалов UP и DN: (сигналы, цвет)
   if (Real) ERROR_CHECK("INPUT");
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void SELL_PIC (uchar f){// шорт от пика 
      if (f==0) {setSEL.Val=0; return;}
      if (D>0)  setSEL.Val=F[f].P-DELTA(1-D);// пик и выше
      if (D==0) setSEL.Val=F[f].Mid;   // серединка пика с объемом  F[f].Mid=(F[f].P+F[f].Tr)/2;  
      if (D<0)  setSEL.Val=F[f].Tr+DELTA(1+D);// трендовый и ниже
      }
void BUY_PIC (uchar f){// лонг от впадины
      if (f==0) {setBUY.Val=0; return;}
      if (D>0)  setBUY.Val=F[f].P+DELTA(1-D); // пик и ниже
      if (D==0) setBUY.Val=F[f].Mid;
      if (D<0)  setBUY.Val=F[f].Tr-DELTA(1+D);// трендовый и выше
      }          
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void SELL_STOP (float SetStop) {// УСТАНОВКА СТОПА дальше, чем предыдущий вариант с проверками        
   if (setSEL.Val==0 || SetStop==0) return;
   setSEL.Stp=SetStop+DELTA(Stp);
   if (sMin!=0 && setSEL.Stp-setSEL.Val<MinStop){// стоп слишком близко
      if (sMin<0)  setSEL.Stp=setSEL.Val+MinStop; else setSEL.Val=setSEL.Stp-MinStop;}// отодвигаем стоп, либо вход от стопа
   if (sMax!=0 && setSEL.Stp-setSEL.Val>MaxStop){// стоп слишком далеко
      if (sMax<0)  setSEL.Val=0; else setSEL.Val=setSEL.Stp-MaxStop;  // не ставим, либо пододвигаем вход к стопу  V("stop "+S0(OrdSet),setSEL.Stp,0,clrRed);
   }  }   
void BUY_STOP (float SetStop) {// УСТАНОВКА СТОПА дальше, чем предыдущий вариант с проверками 
   if (setBUY.Val==0 || SetStop==0) return;
   setBUY.Stp=SetStop-DELTA(Stp);
   if (sMin!=0 && setBUY.Val -setBUY.Stp<MinStop){// стоп слишком близко
      if (sMin<0)  setBUY.Stp=setBUY.Val -MinStop; else setBUY.Val=setBUY.Stp+MinStop;}// отодвигаем стоп, либо вход от стопа
   if (sMax!=0 && setBUY.Val -setBUY.Stp>MaxStop){// стоп слишком далеко 
      if (sMax<0)  setBUY.Val=0; else setBUY.Val=setBUY.Stp+MaxStop;  // не ставим, либо пододвигаем вход к стопу   A("stop "+S0(OrdSet),setBUY.Stp,0,clrBlue);
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void TARGET_ZONE_CHECK(float& buy, float& sel){// ЗАКРЫТИЕ ОРДЕРОВ, ПОПАДАЮЩИХ В ЗОНУ ЦЕЛЕВОГО ДВИЖЕНИЯ
   if (Target==0) return;
   if (buy>0 && buy>TargetLo) {X("OFF TargetLo", buy, bar, clrBlue);  buy=0; Modify=true;}   LINE("TargetLo", bar+1, TargetLo, bar, TargetLo,  clrGray,0); //      
   if (sel>0 && sel<TargetHi) {X("OFF TargetHi", sel, bar, clrRed);   sel=0; Modify=true;}   LINE("TargetHi", bar+1, TargetHi, bar, TargetHi,  clrGray,0); //    
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ       
float PL=(float)MathAbs(minPL)/2;
void SET_PROFIT(){
   if (setBUY.Val>0){   // PROFIT FOR LONG //////////////////////////////////////////////////
      switch(pType){ 
         case  0: setBUY.Prf=setBUY.Val+ATR*(pVal+2)*2;  break;  // 6ATR, 8ATR, 10ATR, 12ATR
         case  1: setBUY.Prf=setBUY.Val+ATR*pVal;        break;  // ATR, 2ATR, 3ATR, 4ATR
         case  2: setBUY.Prf=F[HI].Tr - (F[HI].Tr - setBUY.Val)/(pVal+1); break;   // трендовый первого уровня - 1/2, 1/3, 1/4, 1/5  диапазона
         case  3: setBUY.Prf=F[LO].Back-(F[LO].Back-setBUY.Val)/(pVal+1); break;   // задний фронт первого уровня - 1/2, 1/3, 1/4, 1/5  диапазона   
         }
      if (Target!=0 && TrgHi>0 && F[TrgHi].P<setBUY.Prf) setBUY.Prf=F[TrgHi].P; // если целевой уровень ближе установленного тейка, просто приближаем тейк на целевой уровень     
      if (minPL!=0){   
         float Stop=setBUY.Val-setBUY.Stp;
         float Profit=setBUY.Prf-setBUY.Val;
         if (Stop>0 && Profit/Stop <PL){// при худшем соотношении P/L:
            if (minPL<0)   setBUY.Val=0;                                 // поза не открывается, либо   
            if (minPL>0)   {setBUY.Val=setBUY.Stp+(Stop+Profit)/(1+PL);    if (setBUY.Val-setBUY.Stp<MinStop) setBUY.Val=0;}// цена открытия перемещается для удовлетворения отношения PL
      }  }  }
   if (setSEL.Val>0){// PROFIT FOR SHORT ///////////////////////////////////////////////////
      switch(pType){  
         case  0: setSEL.Prf=setSEL.Val-ATR*(pVal+2)*2;  break;   // 6ATR, 8ATR, 10ATR, 12ATR
         case  1: setSEL.Prf=setSEL.Val-ATR*pVal;        break;   // ATR, 2ATR, 3ATR, 4ATR
         case  2: setSEL.Prf=F[LO].Tr + (setSEL.Val-F[LO].Tr)  /(pVal+1); break;   // трендовый первого уровня -  1/2, 1/3, 1/4, 1/5  диапазона
         case  3: setSEL.Prf=F[HI].Back+(setSEL.Val-F[HI].Back)/(pVal+1); break;   // задний фронт первого уровня - 1/2, 1/3, 1/4, 1/5  диапазона  
         }
      if (Target!=0 && TrgLo>0 && F[TrgLo].P>setSEL.Prf) setSEL.Prf=F[TrgLo].P; // если целевой уровень ближе установленного тейка, просто приближаем тейк на целевой уровень
      if (minPL!=0){
         float Stop=setSEL.Stp-setSEL.Val;   
         float Profit=setSEL.Val-setSEL.Prf;
         if (Stop>0 && Profit/Stop<PL){// при худшем соотношении P/L:
            if (minPL<0)   setSEL.Val=0;                                // поза не открывается, либо 
            if (minPL>0)   {setSEL.Val=setSEL.Stp-(Stop+Profit)/(1+PL);  if (setSEL.Stp-setSEL.Val<MinStop) setSEL.Val=0;}// цена открытия перемещается для удовлетворения отношения PL
   }  }  }  } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
float DELTA(int delta){  // 0.4  0.9  1.6  2.5  3.6  4.9  6.4
   if (delta>0) return( (float)MathPow(delta+1,2)/10*ATR);    
   if (delta<0) return(-(float)MathPow(delta-1,2)/10*ATR); //  ATR = ATR*dAtr*0.1,     
   return (0);
   }    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
float MAX(float price1, float price2){
   if (price1>price2) return (price1); else return (price2);
   } 
float MIN(float price1, float price2){// возвращает меньшее, но не нулевое значение
   if (price1==0) return (price2);
   if (price2==0) return (price1);
   if (price1<price2) return (price1); else return (price2);
   }  
   
     
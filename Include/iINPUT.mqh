// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void INPUT(){
   //if (LO==0 || HI==0)  return; // если первые уровни не определены все сигналы блокируются
   setBUY.Val=0; setBUY.Stp=0; setBUY.Prf=0;    setSEL.Val=0; setSEL.Stp=0; setSEL.Prf=0; // значения ордеров 
   PL=(float)MathAbs(minPL)/2; // minPL=-6..6/2 если P/L хуже minPL/2: <0 не открываемся; >0 вход отодвигается для улучшения P/L
   MinStop=MathAbs(sMin)*ATR/2; // sMin=-3..3 if (STOP<sMin*ATR/2) отодвигаем <0 стоп; >0-вход.
   MaxStop=MathAbs(sMax)*ATR+MinStop;  // sMax=-3..3 if (STOP>sMax*ATR) <0~NoTrade; >0-приближаем вход. Где ATR=ATR*dAtr*0.1;
   if (BUY.Val)   UP=0; // UP,DN 0..1 - trend signals sum: Global, DblTop, FltBrk, Imp
   if (SEL.Val)   DN=0;  
   //SIG_LINES(UP==1," UP="+S0(UP)+" Buy="+S4(BUY.Val)+" BuyLim="+S4(BUYLIM), 
   //          DN==1," DN="+S0(DN)+" Sel="+S4(SEL.Val)+" SelLim="+S4(SELLIM),clrSIG1);
   switch(iSignal){// ГЛОБАЛЬНЫЕ СИГНАЛОЫ 
      case 1:  SIG_FALSE_BREAK();   break;   // работает в lib_PIC
      case 2:  SIG_FIRST_LEVELS();  break;   // ОТСКОК  (iParam=0..4~лимитка удаляется при приближении цены  ATR*Back*2/(iParam+1)
      case 3:  SIG_FIRST_LEVELS_CONFIRM();   break;   // LONG_FIRST_LEV(); 
      case 4:  SIG_TURTLE();        break;
      default: SIG_NULL();          break;   // БЕЗ ГЛОБАЛОВ
      }
   if (setBUY.Sig!=GOGO) UP=0;
   if (setSEL.Sig!=GOGO) DN=0;   
   //SIG_LINES(setBUY.Sig==GOGO,"GOGO: UP="+S0(UP)+" Buy="+S4(BUY.Val)+" BuyLim="+S4(BUYLIM), 
   //          setSEL.Sig==GOGO,"GOGO: DN="+S0(DN)+" Sel="+S4(SEL.Val)+" SelLim="+S4(SELLIM),clrSIG1);  // линии сиглалов MovUP и MovDN: (сигналы, смещение от H/L, цвет)      
   
   //LINE("Up/Dn="+S0(UP)+"/"+S0(DN)+" FlsUpDn="+S0(FlsUp)+"/"+S0(FlsDn)+" FlsPhase="+S0(F[FlsUp].Fls.Phase)+"/"+S0(F[FlsDn].Fls.Phase)+" PtrnBuy/Sel="+S0(setBUY.Sig)+"/"+S0(setSEL.Sig), bar+1, Close[bar+1], bar, Close[bar],  clrSilver,0); 
   LINE(" sigBuy/Sel="+SIG2TXT(setBUY.Sig)+"/"+SIG2TXT(setSEL.Sig), bar+1, Close[bar+1], bar, Close[bar],  clrSilver,0); //"FlsUp/Dn="+S0(FlsUp)+"/"+S0(FlsDn)+" PhaseUp/Dn"+S0(F[FlsUp].Fls.Phase)+"/"+S0(F[FlsDn].Fls.Phase)+
   if (!UP && !DN) return; // UP,DN могут принимать значения 0..1
   if (setSEL.Val>0 && (setSEL.Stp<=setSEL.Val || setSEL.Prf<0 || setSEL.Prf>=setSEL.Val)) setSEL.Val=0;
   if (setBUY.Val>0 && (setBUY.Stp>=setBUY.Val || setBUY.Stp<=0 || (setBUY.Prf!=0 && setBUY.Prf<=setBUY.Val))) setBUY.Val=0;
   
   //SIG_LINES(UP,"2 setBUY.Val="+S4(setBUY.Val), 
   //          DN,"2 setSEL.Val="+S4(setSEL.Val),clrSIG2);     
   // УДАЛЕНИЕ СТАРЫХ ОРДЕРОВ    // ExpirBars=-x..23 <0~удаление отложника при пропадании сигнала. 0~при новом. >0~новый ордер не ставится, пока старый не удалится по экспирации  
   if (ExpirBars==0){// Удаление отложников при появлении нового сигнала
      if (setBUY.Val>0 && (MathAbs(setBUY.Val-MathMax(BUYSTP,BUYLIM))>ATR/2 || MathAbs(setBUY.Stp-BUY.Stp)>ATR/2))   {X("Replace BUYLIM "+S4(setBUY.Val), MAX(BUYSTP,BUYLIM), bar, clrBlack);    BUYSTP=0;   BUYLIM=0;}
      if (setSEL.Val>0 && (MathAbs(setSEL.Val-MathMax(SELSTP,SELLIM))>ATR/2 || MathAbs(setSEL.Stp-SEL.Stp)>ATR/2))   {X("Replace SELLIM "+S4(setSEL.Val), MAX(SELSTP,SELLIM), bar, clrBlack);    SELSTP=0;   SELLIM=0;}
      }
   else if (ExpirBars<0){// удаление отложника при пропадании сигнала
      if (DN==0 && (SELSTP>0 || SELLIM>0)) {SELSTP=0; SELLIM=0;}
      if (UP==0 && (BUYSTP>0 || BUYLIM>0)) {BUYSTP=0; BUYLIM=0;} 
      }
   else {// новый сигнал игнорируется, пока старый отложник не удалится по экспирации
      if (BUYSTP || BUYLIM)  setBUY.Val=0;
      if (SELSTP || SELLIM)  setSEL.Val=0;
      }
   //if (setSEL.Val)   setSEL.Sig=DONE; // ордер готов,
   //if (setBUY.Val)    setBUY.Sig=DONE; // сбрасываем паттерн   
   //SIG_LINES(setBUY.Val ,"3 setBUY.Val="+S4(setBUY.Val)+" BUYLIM="+S4(BUYLIM), 
   //          setSEL.Val,"3 setSEL.Val="+S4(setSEL.Val)+" SELLIM="+S4(SELLIM),clrSIG3); // линии сиглалов UP и DN: (сигналы, цвет)
   if (Real) ERROR_CHECK(__FUNCTION__);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void SELL_PRICE (float price){// шорт от уровня
   if (price==0) return;
   float Delta=ATR/2;
   if (D>0){// вход от пиков в заданном диапазоне
      float StpPwr=0, UpBorder=price+Delta*D, DnBorder=price-Delta; // поиск пика в диапазоне -0.5ATR/+0.5...2.5ATR
      uchar s=0;
      for (uchar f=1; f<LevelsAmount; f++){  // 
         if (F[f].Dir<0 || F[f].Brk>TOUCH || F[f].P==0 || F[f].P<DnBorder || F[f].P>UpBorder) continue; // самый сильный непробитый пик в заданном диапазоне
         if (F[f].Power>StpPwr){ // *F[f].Pics
            s=f;
            StpPwr=F[f].Power; // *F[f].Pics
         }  }
      if (s>0){ 
         setSEL.Stp=F[s].P+Atr.Lim;
         setSEL.Val=MAX(F[s].P-Delta*Stp, Open[0]+Atr.Lim); // если точка входа ниже текущей цены, входим по текущей, но не стоп ордером
         V("StopPic Power="+S4(F[s].Power)+" Pics="+S0(F[s].Pics), F[s].P, SHIFT(F[s].T), clrRed);
      }else setSEL.Val=0; // если пик НЕ был найден
   }else{ // вход от заданной цены +/- Delta
      setSEL.Val=price+Delta*(3+D); // price+3Delta...price-2Delta  
      setSEL.Stp=setSEL.Val+Delta*Stp;
      }
   //V("S="+S0(s)+"("+S4(StpPwr)+")", setSEL.Stp, bar, clrRed);
   //PRN("HI="+S4(F[HI].P)+" "+DTIME(F[HI].T)+" Back="+S4(F[HI].Back));
   }  
void BUY_PRICE (float price){// лонг от уровня
   if (price==0) return;
   float Delta=ATR/2;
   if (D>0){// вход от пиков в заданном диапазоне
      float StpPwr=0, UpBorder=price+Delta, DnBorder=price-Delta*D; // поиск пика в диапазоне 0.5ATR/-0.5...-2.5ATR
      uchar s=0;
      for (uchar f=1; f<LevelsAmount; f++){  // 
         if (F[f].Dir>0 || F[f].Brk>TOUCH || F[f].P==0 || F[f].P<DnBorder || F[f].P>UpBorder) continue; // самый сильный непробитый пик в заданном диапазоне
         if (F[f].Power>StpPwr){// *F[f].Pics
            s=f;
            StpPwr=F[f].Power; // *F[f].Pics
         }  }
      if (s>0){ 
         setBUY.Stp=F[s].P-Atr.Lim;
         setBUY.Val=MIN(F[s].P+Delta*Stp, Open[0]-Atr.Lim); // если точка входа выше текущей цены, входим по текущей, но не стоп ордером
         A("StopPic Power="+S4(F[s].Power)+" Pics="+S0(F[s].Pics), F[s].P, SHIFT(F[s].T), clrBlue);
      }else setBUY.Val=0; // если пик НЕ был найден
   }else{
      setBUY.Val=price-Delta*(3+D); // price-3Delta...price+2Delta 
      setBUY.Stp=setBUY.Val-Delta*Stp;
      }
   
   }    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ       
void BUY_PROFIT(){
   if (setBUY.Val==0) return;   // PROFIT FOR LONG //////////////////////////////////////////////////
   switch(Prf){
      case  1: setBUY.Prf=setBUY.Val+(F[LO].Back-setBUY.Val)*1/4; break;
      case  2: setBUY.Prf=setBUY.Val+(F[LO].Back-setBUY.Val)*1/3; break; 
      case  3: setBUY.Prf=setBUY.Val+(F[LO].Back-setBUY.Val)*1/2; break; 
      case  4: setBUY.Prf=setBUY.Val+(F[LO].Back-setBUY.Val)*2/3; break;
      case  5: setBUY.Prf=setBUY.Val+(F[LO].Back-setBUY.Val)*3/4; break;
      case  6: setBUY.Prf=F[LO].Back-ATR; break;
      case  7: setBUY.Prf=F[HI].P   -ATR; break;
      default: setBUY.Prf=setBUY.Val+20*ATR;
      }        
   if (Prf<0)  setBUY.Prf=setBUY.Val+DELTA(1-Prf); // 0.9  1.6  2.5  3.6  4.9
   //if (Target!=0 && TrgHi>0 && F[TrgHi].P<setBUY.Prf) setBUY.Prf=F[TrgHi].P; // если целевой уровень ближе установленного тейка, просто приближаем тейк на целевой уровень     
   if (minPL!=0){   
      float Stop  =setBUY.Val-setBUY.Stp;
      float Profit=setBUY.Prf-setBUY.Val;
      if (Stop>0 && Profit/Stop <PL){// при худшем соотношении P/L:
         X("P/L="+S4(Profit/Stop)+" CHANGE setBUY.Val", setBUY.Val, bar, clrRed);
         if (minPL<0)   setBUY.Val=0;                                // поза не открывается, либо   
         if (minPL>0)   setBUY.Val=setBUY.Stp+(Stop+Profit)/(1+PL);  // переносится вход     
   }  }  }  
void SELL_PROFIT(){   
   if (setSEL.Val==0) return;// PROFIT FOR SHORT ///////////////////////////////////////////////////
   switch(Prf){  
      case  1: setSEL.Prf=setSEL.Val-(setSEL.Val-F[HI].Back)*1/4; break;   
      case  2: setSEL.Prf=setSEL.Val-(setSEL.Val-F[HI].Back)*1/3; break;
      case  3: setSEL.Prf=setSEL.Val-(setSEL.Val-F[HI].Back)*1/2; break;
      case  4: setSEL.Prf=setSEL.Val-(setSEL.Val-F[HI].Back)*2/3; break;
      case  5: setSEL.Prf=setSEL.Val-(setSEL.Val-F[HI].Back)*3/4; break;
      case  6: setSEL.Prf=F[HI].Back+ATR; break;
      case  7: setSEL.Prf=F[LO].P   +ATR; break; 
      default: setSEL.Prf=setSEL.Val-20*ATR; 
      }
   if (Prf<0)  setSEL.Prf=setSEL.Val-DELTA(1-Prf); // 0.9  1.6  2.5  3.6  4.9  6.4    
   //if (Target!=0 && TrgLo>0 && F[TrgLo].P>setSEL.Prf) setSEL.Prf=F[TrgLo].P; // если целевой уровень ближе установленного тейка, просто приближаем тейк на целевой уровень
   if (minPL!=0){
      float Stop=setSEL.Stp-setSEL.Val;   
      float Profit=setSEL.Val-setSEL.Prf;
      if (Stop>0 && Profit/Stop<PL){// при худшем соотношении P/L:
         X("P/L="+S4(Profit/Stop)+" CHANGE setSEL.Val", setBUY.Val, bar, clrRed);
         if (minPL<0)   setSEL.Val=0;                                // поза не открывается, либо 
         if (minPL>0)   setSEL.Val=setSEL.Stp-(Stop+Profit)/(1+PL);  // цена открытия перемещается для удовлетворения отношения PL
   }  }  }              
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
//void SELL_STOP (float SetStop) {// УСТАНОВКА СТОПА дальше, чем предыдущий вариант с проверками        
//   if (setSEL.Val==0 || SetStop==0) return;
//   setSEL.Stp=SetStop+DELTA(Stp); //   0.4  0.9  1.6  2.5  3.6  4.9  6.4
//   if (sMin!=0 && setSEL.Stp-setSEL.Val<MinStop){// стоп слишком близко
//      if (sMin<0)  setSEL.Stp=setSEL.Val+MinStop; else setSEL.Val=setSEL.Stp-MinStop;}// отодвигаем стоп, либо вход от стопа
//   if (sMax!=0 && setSEL.Stp-setSEL.Val>MaxStop){// стоп слишком далеко
//      if (sMax<0)  setSEL.Val=0; else setSEL.Val=setSEL.Stp-MaxStop;  // не ставим, либо пододвигаем вход к стопу  V("stop "+S0(OrdSet),setSEL.Stp,0,clrRed);
//   }  }   
//void BUY_STOP (float SetStop) {// УСТАНОВКА СТОПА дальше, чем предыдущий вариант с проверками 
//   if (setBUY.Val==0 || SetStop==0) return;
//   setBUY.Stp=SetStop-DELTA(Stp);
//   if (sMin!=0 && setBUY.Val -setBUY.Stp<MinStop){// стоп слишком близко
//      if (sMin<0)  setBUY.Stp=setBUY.Val -MinStop; else setBUY.Val=setBUY.Stp+MinStop;}// отодвигаем стоп, либо вход от стопа
//   if (sMax!=0 && setBUY.Val -setBUY.Stp>MaxStop){// стоп слишком далеко 
//      if (sMax<0)  setBUY.Val=0; else setBUY.Val=setBUY.Stp+MaxStop;  // не ставим, либо пододвигаем вход к стопу   A("stop "+S0(OrdSet),setBUY.Stp,0,clrBlue);
//   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void TARGET_ZONE_CHECK(float& buy, float& sel){// ЗАКРЫТИЕ ОРДЕРОВ, ПОПАДАЮЩИХ В ЗОНУ ЦЕЛЕВОГО ДВИЖЕНИЯ
   if (Target==0) return;
   if (buy>0 && buy>TargetLo) {X("OFF TargetLo", buy, bar, clrBlue);  buy=0;}   LINE("TargetLo", bar+1, TargetLo, bar, TargetLo,  clrGray,0); //      
   if (sel>0 && sel<TargetHi) {X("OFF TargetHi", sel, bar, clrRed);   sel=0;}   LINE("TargetHi", bar+1, TargetHi, bar, TargetHi,  clrGray,0); //    
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
float DELTA(int delta){  // 0.4  0.9  1.6  2.5  3.6  4.9  6.4
   if (delta>0) return( (float)MathPow(delta+1,2)/10*ATR);    
   if (delta<0) return(-(float)MathPow(delta-1,2)/10*ATR); //  ATR = ATR*dAtr*0.1,     
   return (0);
   }    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
float MAX(double price1, double price2){
   if (price1>price2) return (float(price1)); else return (float(price2));
   } 
float MIN(double price1, double price2){// возвращает меньшее, но не нулевое значение
   if (price1==0) return (float(price2));
   if (price2==0) return (float(price1));
   if (price1<price2) return (float(price1)); else return (float(price2));
   }  

string SIG2TXT(char sig){
   switch(sig){
      case -1: return("BLOCK");  // блокировка 
      case  0: return("NONE");
      case  1: return("WAIT");   // ожидание
      case  2: return("START");  // начало
      case  3: return("CONFIRM");// подтверждение
      case  4: return("GOGO");   // сигнал на открытие позы
      case  5: return("BREAK");  // отмена
      case  6: return("DONE");   // поза открыта 
      default: return(DoubleToStr(sig));
   }  }
      
      
      
      
     
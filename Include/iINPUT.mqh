struct SIG{    // Buy, Sell  СИГНАЛЫ 
   datetime T;    // последнее время обновления зоны
   char Pattern;         // отслеживаемый паттерн
   float Mem,Opn,Stp,Prf;  // цена сигнала, цены ордеров
   PICS Sig1,Sig2;      // вложенная структура предварительных сигналов и сигналов подтверждения
   }; 
SIG Sel,Buy;
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void INPUT(){
   //if (LO==0 || HI==0)  return; // если первые уровни не определены все сигналы блокируются
   SetBUY=0;   SetSTOP_BUY=0;    SetPROFIT_BUY=0; SetSELL=0;  SetSTOP_SELL=0;   SetPROFIT_SELL=0; // значения ордеров 
   MinStop=MathAbs(sMin)*Atr.Max/2;
   MaxStop=MathAbs(sMax)*Atr.Max+MinStop; 
   if (BUY)    UP=0; // UP,DN могут принимать значения -1..2
   if (SELL)   DN=0;  
   //SIG_LINES(UP==1," UP="+S0(UP)+" Buy="+S4(BUY) +" BuyLim="+S4(BUYLIMIT), 
   //          DN==1," DN="+S0(DN)+" Sel="+S4(SELL)+" SelLim="+S4(SELLLIMIT),clrSIG1);
   // ПЕРЕКЛЮЧАТЕЛЬ ГЛОБАЛЬНЫХ СИГНАЛОВ.
   switch(iSignal){ 
      case 1:  FALSE_BREAK_SIG();   break;   // работает в lib_PIC
      case 2:  SIG_FIRST_LEVELS();        break;   // ОТСКОК  (iParam=0..4~лимитка удаляется при приближении цены  ATR*Back*2/(iParam+1)
      case 3:  SIG_FIRST_LEVELS_CONFIRM();   break;   // LONG_FIRST_LEV(); 
      case 4:  SIG_TURTLE();        break;
      default: SIG_NULL();          break;   // БЕЗ ГЛОБАЛОВ
      }
   if (Buy.Pattern!=GOGO) UP=0;
   if (Sel.Pattern!=GOGO) DN=0;   
   SIG_LINES(Buy.Pattern==GOGO,"GOGO: UP="+S0(UP)+" Buy="+S4(BUY) +" BuyLim="+S4(BUYLIMIT), 
             Sel.Pattern==GOGO,"GOGO: DN="+S0(DN)+" Sel="+S4(SELL)+" SelLim="+S4(SELLLIMIT),clrSIG1);  // линии сиглалов MovUP и MovDN: (сигналы, смещение от H/L, цвет)      
   if (ExpirBars<0){// удаление отложника при пропадании сигнала
      if (DN<1 && (SELLSTOP>0 || SELLLIMIT>0))  {SELLSTOP=0; SELLLIMIT=0; Modify=true;}
      if (UP<1 && (BUYSTOP>0  ||  BUYLIMIT>0))  {BUYSTOP=0;  BUYLIMIT=0;  Modify=true;} 
      }
   //LINE("Up/Dn="+S0(UP)+"/"+S0(DN)+" FlsUpDn="+S0(FlsUp)+"/"+S0(FlsDn)+" FlsPhase="+S0(F[FlsUp].Fls.Phase)+"/"+S0(F[FlsDn].Fls.Phase)+" PtrnBuy/Sel="+S0(Buy.Pattern)+"/"+S0(Sel.Pattern), bar+1, Close[bar+1], bar, Close[bar],  clrSilver,0); 
   LINE("FlsUp/Dn="+S0(FlsUp)+"/"+S0(FlsDn)+" PhaseUp/Dn"+S0(F[FlsUp].Fls.Phase)+"/"+S0(F[FlsDn].Fls.Phase)+" PatternBuy/Sel="+S0(Buy.Pattern)+"/"+S0(Sel.Pattern), bar+1, Close[bar+1], bar, Close[bar],  clrSilver,0);
   if (UP<1 && DN<1) return; // UP,DN могут принимать значения -1..2
   //  SET  INPUT
   switch (Iprice){   
      case  2: // от Первых Уровней    V("F[HI].P"+S4(F[HI].P),F[HI].P, bar, clrWhite);
         SET_OPEN(LO, HI);       
         SET_STOP(F[LO].P, F[HI].P);                           
      break;                                    
      case  1: // из функций сигналов V("Sel.Opn="+S4(Sel.Opn),Sel.Opn, bar, clrYellow);
         if (UP>0) SetPROFIT_BUY=Buy.Prf; 
         if (DN>0) SetPROFIT_SELL=Sel.Prf;                           
         SET_STOP(Buy.Stp,    Sel.Stp);                        
      break;             
      case  0: // по текущей цене открытия
         if (UP>0) SetBUY =float(Ask)-DELTA(D);  
         if (DN>0) SetSELL=float(Bid)+DELTA(D);  
         SET_STOP(F[lo].P, F[hi].P); // за ближайшие пики               
      break;   
      case -1: // Пробой первых уровней
         SET_OPEN(HI, LO);       
         SET_STOP(SetBUY-MinStop, SetSELL+MinStop);  
      break;
      }//LINE("Up/Dn="+S0(UP)+"/"+S0(DN)+" BUY/Stp-SELL/Stp="+S4(SetBUY)+"/"+S4(SetSTOP_BUY)+"-"+S4(SetSELL)+"/"+S4(SetSTOP_SELL), bar+1, Close[bar+1], bar, Close[bar],  clrGray,0);   
   // SET  PROFIT
   float PrfBuy=0, PrfSel=0;
   switch (Prf){
      default: PrfBuy=SetBUY+DELTA(Prf+1);   PrfSel=SetSELL-DELTA(Prf+1);  break;   // ATR
      case  0: PrfBuy=SetBUY+50*ATR;         PrfSel=SetSELL-50*ATR;        break;   // в бесконечность
      case -1: PrfBuy=Buy.Prf;               PrfSel=Sel.Prf;               break;   // из функции сигналов
      case -2: PrfBuy=F[HI].Tr;              PrfSel=F[LO].Tr;              break;   // трендовый уровень первого
      case -3: PrfBuy=F[LO].Back;            PrfSel=F[HI].Back;            break;   // откат от первого уровня
      }     
   if (pDiv>0){// приближаем тейк на: 2/3, 2/4, 2/5, 2/6  
      PrfBuy=SetBUY +(PrfBuy-SetBUY)*2/(pDiv+2); 
      PrfSel=SetSELL-(SetSELL-PrfSel)*2/(pDiv+2); 
      }
   if (Target!=0){// Целевые уровни 
      if (TrgHi>0 && F[TrgHi].P<PrfBuy) PrfBuy=F[TrgHi].P; // если целевой уровень ближе установленного тейка,
      if (TrgLo>0 && F[TrgLo].P>PrfSel) PrfSel=F[TrgLo].P; // просто приближаем тейк на целевой уровень
      } 
   if (Iprice!=1){ // при Iprice=1 параметры ордера ставятся из функций сигналов    
      if (SetBUY>0  && PrfBuy>0 && PrfBuy>SetBUY)  SetPROFIT_BUY=PrfBuy;   else SetBUY=0;
      if (SetSELL>0 && PrfSel>0 && PrfSel<SetSELL) SetPROFIT_SELL=PrfSel;  else SetSELL=0;
      }
   if (SetBUY==0 && SetSELL==0)  return; 
   SIG_LINES(UP,"2 SetBUY=" +S4(SetBUY) +" Buy.Opn="+S4(Buy.Opn), 
             DN,"2 SetSELL="+S4(SetSELL)+" Sel.Opn="+S4(Sel.Opn),clrSIG2);     
   PL_CHECK();// ПРОВЕРКА СООТНОШЕНИЯ Profit/Loss        //if (Prn) Print("2 SetSELL=",S4(SetSELL)," SetPROFIT_SELL=",S4(SetPROFIT_SELL)," HI=",F[HI].P," StrLo=",F[StrLo].P," FltLo=",F[FltLo].P);   
   // УДАЛЕНИЕ СТАРЫХ ОРДЕРОВ
   if (ExpirBars==0){// Удаление отложников при появлении нового сигнала
      if (SetBUY >0 && (MathAbs(SetBUY -MathMax(BUYSTOP ,BUYLIMIT ))>ATR/2 || MathAbs(SetSTOP_BUY -STOP_BUY)>ATR/2))    {BUYSTOP=0;    BUYLIMIT=0;   Modify=true;}  //    X("BUYLIMIT=" +S4(BUYLIMIT)+ " SetBUY=" +S4(SetBUY), BUYLIMIT, 0, clrBlack);
      if (SetSELL>0 && (MathAbs(SetSELL-MathMax(SELLSTOP,SELLLIMIT))>ATR/2 || MathAbs(SetSTOP_SELL-STOP_SELL)>ATR/2))   {SELLSTOP=0;   SELLLIMIT=0;  Modify=true;}   //  X("SELLLIMIT="+S4(SELLLIMIT)+" SetSELL="+S4(SetSELL),SELLLIMIT,0, clrBlack);
   }else{// новый сигнал игнорируется, пока стоит старый отложник, который удалится по экспирации (>0) либо при пропадании сигнала (<0)
      if (BUYSTOP  || BUYLIMIT)  SetBUY=0;
      if (SELLSTOP || SELLLIMIT) SetSELL=0;
      }
   //if (SetSELL)   Sel.Pattern=DONE; // ордер готов,
   //if (SetBUY)    Buy.Pattern=DONE; // сбрасываем паттерн   
   SIG_LINES(SetBUY ,"3 SetBUY="+S4(SetBUY)+" BUYLIMIT="+S4(BUYLIMIT), 
             SetSELL,"3 SetSELL="+S4(SetSELL)+" SELLLIMIT="+S4(SELLLIMIT),clrSIG3); // линии сиглалов UP и DN: (сигналы, цвет)
   if (Real) ERROR_CHECK("INPUT");
   }    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void SET_OPEN (uchar b, uchar s){// УСТАНОВКА ЦЕНЫ ОТКРЫТИЯ  
   if (UP>0 && b>0){ // UP,DN могут принимать значения -1..2
      if (D>0)  SetBUY=F[b].P+DELTA(1-D); // пик и ниже
      if (D==0) SetBUY=F[b].Mid;
      if (D<0)  SetBUY=F[b].Tr-DELTA(1+D);// трендовый и выше
      } //V("DN="+S0(DN)+" s="+S0(s)+" Sel="+S4(F[s].Mid),H, bar, clrSilver);  
   if (DN>0 && s>0){
      if (D>0)  SetSELL=F[s].P-DELTA(1-D);// пик и выше
      if (D==0) SetSELL=F[s].Mid;
      if (D<0)  SetSELL=F[s].Tr+DELTA(1+D);// трендовый и ниже
   }  }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void SET_STOP (float StpBuy,  float StpSel) {// УСТАНОВКА СТОПА дальше, чем предыдущий вариант с проверками 
   if (SetBUY>0 && StpBuy>0){ // OrdSet-тип ордера (1-выставление, 0-модификация)
      StpBuy-=DELTA(Stp);
      if (sMin!=0 && SetBUY -StpBuy<MinStop){// стоп слишком близко
         if (sMin<0)  StpBuy=SetBUY -MinStop; else SetBUY=StpBuy+MinStop;}// отодвигаем стоп, либо вход от стопа
      if (sMax!=0 && SetBUY -StpBuy>MaxStop){// стоп слишком далеко 
         if (sMax<0)  StpBuy=0; else SetBUY=StpBuy+MaxStop;}  // не ставим, либо пододвигаем вход к стопу   A("stop "+S0(OrdSet),SetSTOP_BUY,0,clrBlue);
      if (StpBuy>0)    SetSTOP_BUY=StpBuy; else SetBUY=0;// если стоп не задался, отменяем ордер
      }  
   if (SetSELL>0 && StpSel>0){// OrdSet-тип ордера (1-выставление, 0-модификация)
      StpSel+=DELTA(Stp);
      if (sMin!=0 && StpSel-SetSELL<MinStop){// стоп слишком близко
         if (sMin<0)  StpSel=SetSELL+MinStop; else SetSELL=StpSel-MinStop;}// отодвигаем стоп, либо вход от стопа
      if (sMax!=0 && StpSel-SetSELL>MaxStop){// стоп слишком далеко
         if (sMax<0)  StpSel=0; else SetSELL=StpSel-MaxStop;}  // не ставим, либо пододвигаем вход к стопу  V("stop "+S0(OrdSet),SetSTOP_SELL,0,clrRed);
      if (StpSel>0)   SetSTOP_SELL=StpSel; else SetSELL=0;// если стоп не задался, отменяем ордер
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
void FSTLEV_ZONE_CHECK(float& buy, float& sel){// ОГРАНИЧЕНИЕ ТОРГОВОГО ДИАПАЗОНА ВБЛИЗИ ПЕРВЫХ УРОВНЕЙ
   if (iFrstLev==0) return;
   float delta=MathAbs(iFrstLev)*ATR;
   if (iFrstLev>0){  // ВХОД В РАЙОНЕ ПЕРВЫХ УРОВНЕЙ 
      if (buy>F[LO].P+delta)   {X("BuyZoneOut", buy, bar, clrBlue); buy=0;}  // LINE("BuyUp", bar+1,F[LO].P+delta,bar,F[LO].P+delta,clrLightBlue,0);   
      if (sel<F[HI].P-delta)   {X("SelZoneOut", sel, bar, clrRed);  sel=0;}  // LINE("SelDn", bar+1,F[HI].P-delta,bar,F[HI].P-delta,clrPink,0);           
   }else{            // В РАЙОНЕ УРОВНЯ СЕРЕДИНКИ
      if (buy>F[LO].Mid+delta) {X("BuyZoneOut", buy, bar, clrBlue); buy=0;}    
      if (sel<F[HI].Mid-delta) {X("SelZoneOut", sel, bar, clrRed);  sel=0;} 
   }  }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void PL_CHECK(){// ПРОВЕРКА СООТНОШЕНИЯ Profit/Loss
   if (minPL==0) return;
   float PL=(float)MathAbs(minPL)/2;   
   if (SetBUY>0){
      float Stop=SetBUY-SetSTOP_BUY;
      float Profit=SetPROFIT_BUY-SetBUY;
      if (Stop>0 && Profit/Stop <PL){// при худшем соотношении P/L:
         if (minPL<0)   SetBUY=0;                                 // поза не открывается, либо   
         if (minPL>0)   {SetBUY=SetSTOP_BUY+(Stop+Profit)/(1+PL);    if (SetBUY-SetSTOP_BUY<MinStop) SetBUY=0;}// цена открытия перемещается для удовлетворения отношения PL
      }  }
   if (SetSELL>0){ 
      float Stop=SetSTOP_SELL-SetSELL;   
      float Profit=SetSELL-SetPROFIT_SELL;
      if (Stop>0 && Profit/Stop<PL){// при худшем соотношении P/L:
         if (minPL<0)   SetSELL=0;                                // поза не открывается, либо 
         if (minPL>0)   {SetSELL=SetSTOP_SELL-(Stop+Profit)/(1+PL);  if (SetSTOP_SELL-SetSELL<MinStop) SetSELL=0;}// цена открытия перемещается для удовлетворения отношения PL
   }  }  } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
float DELTA(int delta){  // 0.4  0.9  1.6  2.5  3.6
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
     
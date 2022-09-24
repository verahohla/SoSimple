void OUTPUT(){
   if (!BUY.Val  && !SEL.Val) return;
   setBUY.Prf=0;  setSEL.Prf=0; // значения тейков для обновления ордеров 
      
   if (BUY.Val){  // A("BUY.Val="+S4(BUY.Val)+" Shift="+S0(SHIFT(BuyTime))+" MaxFromBuy="+S4(MaxFromBuy -BUY.Val),  H-ATR*3, 0,  clrGray);
      if (oImp>0 && !IMP_UP())                        {CLOSE_BUY(oPrice);  V("CloseBuy: NoImp",H, bar,  clrBlue);}         // отсутствие резкого отскока на первом баре после входа
      if (oFlt>0 && PocCnt>3)                         {CLOSE_BUY(oPrice);  V("CloseBuy: FlatStart", H, bar,  clrBlue);}    // начался микрофлэт - несколько идущих подряд бар 
      if (oSig>0 && (UP<1 || setBUY.Sig==NONE))       {CLOSE_BUY(oPrice);  V("CloseBuy: NoSig UP<1", H, bar,  clrBlue);}   // отсутвствие лонгового сигнала
      if (oSig<0 && DN>0 && UP<1)                     {CLOSE_BUY(oPrice);  V("CloseBuy: OppSig DN>0", H, bar,  clrBlue);}  // появление шортового сигнала
      if (Tper>0 && Tin==0 && SHIFT(BuyTime)>=Tper)   {CLOSE_BUY(tPrice);  V("CloseBuy: HoldOverTime", H, bar,  clrBlue);} //  если не задан период работы Tin, то Tper определяет HoldTime
      }  
   if (SEL.Val){ //V("SEL.Val="+S4(SEL.Val)+" DN="+S0(DN),  L+ATR*3, 0,  clrGray);// " Shift="+S0(SHIFT(SellTime))+" MinFromSell="+S4(SEL.Val-MinFromSell)
      if (oImp>0 && !IMP_DN())                        {CLOSE_SELL(oPrice); A("CloseSELL: NoImp", L, bar,  clrRed);}        // отсутствие резкого отскока на первом баре после входа
      if (oFlt>0 && PocCnt>3)                         {CLOSE_SELL(oPrice); A("CloseSell: FlatStart", L, bar,  clrRed);}    // начался микрофлэт - несколько идущих подряд бар 
      if (oSig>0 && (DN<1 || setSEL.Sig==NONE))       {CLOSE_SELL(oPrice); A("CloseSELL: NoSig DN<1", L, bar,  clrRed);}   // отсутствие шортового сигнала
      if (oSig<0 && UP>0 && DN<1)                     {CLOSE_SELL(oPrice); A("CloseSELL: OppSig UP>0", L, bar,  clrRed);}  // появление лонгового сигнала
      if (Tper>0 && Tin==0 && SHIFT(SellTime)>=Tper)  {CLOSE_SELL(tPrice); A("CloseSELL: HoldOverTime", L, bar,  clrRed);} // если не задан период работы Tin, то Tper определяет HoldTime
      }
   if (Real) ERROR_CHECK(__FUNCTION__);   
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
char IMP_UP(){// Проверка резкого отскока на первом баре лонга
   if (SHIFT(BuyTime) >1 && MaxFromBuy -BUY.Val <ATR*oImp)   return (false); else return (true); // Shift=1 бар входа, Shift=2 следующий
   }  
char IMP_DN(){// Проверка резкого отскока на первом баре шорта
   if (SHIFT(SellTime)>1 && SEL.Val-MinFromSell<ATR*oImp)   return (false); else return (true); // *SHIFT(SellTime)
   }      
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void CLOSE_BUY(char ClosePrice){// подтягиваем тейк на
   float NewProfit;
   switch (ClosePrice){
      case -1: NewProfit=MaxFromBuy;         break;   // максимальную цену с момента открытия позы
      case  0: NewProfit=MAX(BUY.Val,Bid);   break;   // по текущей цене, либо цене входа
      case  1: NewProfit=MAX(PocCenter,Bid); break;   // по текущей цене, либо последней проторговке 
      default: NewProfit=float(Bid) + (ClosePrice-2)*ATR/2;  // по текущей цене + жадность
      }
   if (NewProfit-Bid<StopLevel){
      BUY.Val=0;  
      A("CloseBuy", L, bar,  clrBlue);  
      return;} // тейк недопустимо близко к цене, просто закрываемся
   if (NewProfit>0 && (NewProfit<BUY.Prf || BUY.Prf==0)){
      BUY.Prf=NewProfit;   A("ModifyProfit="+S4(NewProfit), NewProfit, bar,  clrBlue);   
   }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void CLOSE_SELL(char ClosePrice){
   float NewProfit;
   switch (ClosePrice){
      case -1: NewProfit=MinFromSell;        break;   // минимальную цену с момента открытия позы
      case  0: NewProfit=MIN(SEL.Val,Ask);   break;   // по текущей цене, либо цене входа
      case  1: NewProfit=MIN(PocCenter,Ask); break;   // по текущей цене, либо последней проторговке 
      default: NewProfit=float(Ask) - (ClosePrice-2)*ATR/2; // по текущей цене + жадность
      }
   if (Ask-NewProfit<StopLevel){
      SEL.Val=0;     
      V("CloseSell", H, bar,  clrRed);
      return;} // тейк недопустимо близко к цене, просто закрываемся  
   if (NewProfit>0 && (NewProfit>SEL.Prf || SEL.Prf==0)){
      SEL.Prf=NewProfit;    V("ModifyProfit="+S4(NewProfit), NewProfit, bar,  clrRed);     
   }  }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ          
void TRAILING(){//    - T R A I L I N G   S T O P -
   if (Trl==0) return;
   float StpBuy=0, StpSel=0;    // 
   //for (uchar f=1; f<LevelsAmount; f++){ 
   //   if (F[f].P==0)    continue; // пустые значения пропускаем
   //   if (F[f].Brk>0)  continue; // только непробитые,        
   //   if (MathAbs(F[f].P-F[f].Back)<MinBack) continue; // уровень должен быть с достаточным отскоком 
   //   if (F[f].Dir>0 && F[f].T>SellTime)  LOWEST_HI (H, minHI, f, TrlHi);  // пик, образовавшийся после продажи
   //   if (F[f].Dir<0 && F[f].T>BuyTime)   HIGHEST_LO(L, minLO, f, TrlLo);  // впадина, образовавшаяся после покупки
   //   }
   float TrlStop=DELTA(MathAbs(Trl)-1);
   if (stpL>0)   StpBuy=F[stpL].P-TrlStop;    
   if (stpH>0)   StpSel=F[stpH].P+TrlStop;      
   
   if (BUY.Val  && StpBuy>0 && StpBuy-BUY.Stp>ATR  && (StpBuy>BUY.Val  || Trl<0)){ // 
      A("TRAILING_BUY="+S4(StpBuy), StpBuy, SHIFT(F[stpL].T), clrGreen);
      BUY.Stp=StpBuy; }            
   if (SEL.Val && StpSel>0 && SEL.Stp-StpSel>ATR && (StpSel<SEL.Val || Trl<0)){//
      V("TRAILING_SELL="+S4(StpSel), StpSel, SHIFT(F[stpH].T), clrGreen);
      SEL.Stp=StpSel; } 
   if (Real) ERROR_CHECK("TRAILING");     
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void POC_CLOSE_TO_ORDER(){// УДАЛЕНИЕ ОТЛОЖНИКА ЕСЛИ ПЕРЕД НИМ ФОРМИРУЕТСЯ ФЛЭТ. Проверяется в COUNT()
   if (iFlt==0) return;   // 
   float Near=float(iFlt*ATR);
   if (SELLIM>0){ // пик (poc) перед зоной продажи = цена "отдохнула"
      if (PocCnt>2 && SELLIM-PocCenter<Near)       {setSEL.Sig=0; SELLIM=0;   X("PocNearSel", PocCenter, bar+1, clrRed);}  // перед лимиткой cформировалось уплотнение из нескольких бар
      if (SELLIM-F[n].P<Near && F[n].T>SellTime)   {setSEL.Sig=0; SELLIM=0;   X("PicNearSel", F[n].P,    bar+1, clrRed);}  // или пик
      }   
   if (BUYLIM>0){  // пик перед зоной продажи = цена "отдохнула"
      if (PocCnt>2 && PocCenter-BUYLIM<Near)       {setBUY.Sig=0; BUYLIM=0;   X("PocNearBuy", PocCenter, bar,   clrRed);}
      if (F[n].P-BUYLIM<Near && F[n].T>BuyTime)    {setBUY.Sig=0; BUYLIM=0;   X("PicNearBuy", F[n].P,    bar+1, clrRed);} 
   }  } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ            



   
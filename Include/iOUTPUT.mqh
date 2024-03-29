#define BREAK_EVEN_STOP   -2  // стоп в безубыток 
#define LAST_PIC_STOP     -1  // стоп за последний пик 
#define CUR_PRICE          0  // текущая цена
#define BREAK_EVEN_PROFIT  1  // тейк в безубыток
#define MAX_REACH          2  // максимальная с открытия

void OUTPUT(){
   if (!BUY.Val  && !SEL.Val) return;
   setBUY.Prf=0;  setSEL.Prf=0; // значения тейков для обновления ордеров 
      
   if (BUY.Val){  // A("BUY.Val="+S4(BUY.Val)+" Shift="+S0(SHIFT(BuyTime))+" MaxFromBuy="+S4(MaxFromBuy -BUY.Val),  H-ATR*3, 0,  clrGray);
      if (oImp && !IMP_UP())                       CLOSE_BUY(oPrice,"ImpulseOver");   // отсутствие резкого отскока после входа
      if (oFlt && PocCnt>oFlt+2)                   CLOSE_BUY(oPrice,"FlatStart");     // начался микрофлэт - несколько идущих подряд бар 
      if (oSig && DN>0)                            CLOSE_BUY(oPrice,"OppSig DN>0");   // появление шортового сигнала
      if (Tper && Tin==0 && SHIFT(BuyTime)>=Tper)  CLOSE_BUY(oPrice,"HoldOverTime");  //  если не задан период работы Tin, то Tper определяет HoldTime
      }  
   if (SEL.Val){ //V("SEL.Val="+S4(SEL.Val)+" DN="+S0(DN),  L+ATR*3, 0,  clrGray);// " Shift="+S0(SHIFT(SellTime))+" MinFromSell="+S4(SEL.Val-MinFromSell)
      if (oImp && !IMP_DN())                       CLOSE_SELL(oPrice,"ImpulseOver");        // отсутствие резкого отскока после входа
      if (oFlt && PocCnt>oFlt+2)                   CLOSE_SELL(oPrice,"FlatStart");    // начался микрофлэт - несколько идущих подряд бар 
      if (oSig && UP>0)                            CLOSE_SELL(oPrice,"OppSig UP>0");  // появление лонгового сигнала
      if (Tper && Tin==0 && SHIFT(SellTime)>=Tper) CLOSE_SELL(oPrice,"HoldOverTime"); // если не задан период работы Tin, то Tper определяет HoldTime
      }
   if (Real) ERROR_CHECK(__FUNCTION__);   
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
char IMP_UP(){// наличие импульса после открытия. 
   if (SHIFT(BuyTime)==1 || oImp==0) return(true); // либо только первый бар с открытия, либо сигнал не активен 
   double noise=BUY.Val-Low[SHIFT(BuyTime)]; // 
   for (int i=bar; i<SHIFT(BuyTime); i++) noise+=(High[i]-Low[i]); // шум  в барах
   A(S4(MaxFromBuy -BUY.Val)+" / "+S4(noise), L, bar,  clrGray);
   if ((MaxFromBuy -BUY.Val)/noise>MathAbs(oImp)*0.1)   return (true); else return (false); // Shift=1 бар входа, Shift=2 следующий
   }  
char IMP_DN(){// Проверка резкого отскока 
   if (SHIFT(SellTime)==1 || oImp==0) return(true); // либо только первый бар с открытия, либо сигнал не активен 
   double noise=High[SHIFT(SellTime)]-SEL.Val;
   for (int i=bar; i<SHIFT(SellTime); i++) noise+=(High[i]-Low[i]); // шум  в барах
   V(S4(SEL.Val-MinFromSell)+" / "+S4(noise), H, bar,  clrGray);
   if ((SEL.Val-MinFromSell)/noise>MathAbs(oImp)*0.1)   return (true); else return (false); // Shift=1 бар входа, Shift=2 следующий
   }      
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void CLOSE_BUY(char price, string comment){// 
   if (price>0){ // двигаем тейк 
      float NewProfit=0, CurPrice=float(Open[0]+Atr.Min/2); // 
      switch (price){// тип цены закрытия
         case 0:  NewProfit=CurPrice;              break;   // по текущей
         case 1:  NewProfit=MAX(CurPrice,BUY.Val); break;   // не хуже чем безубыток
         case 2:  NewProfit=MaxFromBuy;            break;   // по максимально достигнутой цене
         }
      if (NewProfit<BUY.Prf || BUY.Prf==0)   BUY.Prf=NewProfit;      
      if (NewProfit-Bid<StopLevel)           BUY.Val=0;  // тейк недопустимо близко к цене, просто закрываемся
      V("CloseBuy: "+comment, NewProfit, bar,  clrGreen);
   }else{// подтягиваем стоп
      float NewStop=0;
      switch (price){
         case -1: NewStop=F[lo].P-Atr.Lim;   break;   // стоп за последний пик 
         case -2: NewStop=BUY.Val;           break;   // стоп в безубыток
         }   
      if (NewStop-BUY.Stp>Atr.Lim && Bid-NewStop>Atr.Max)  BUY.Stp=NewStop;     
      A("CloseBuy: "+comment, NewStop, bar, clrRed);
   }  }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ     
void CLOSE_SELL(char price, string comment){
   if (price>0){ // двигаем тейк 
      float NewProfit=0, CurPrice=float(Open[0]-Atr.Min/2);
      switch (price){
         case 0:  NewProfit=CurPrice;              break;   // по текущей
         case 1:  NewProfit=MIN(CurPrice,SEL.Val); break;   // не хуже чем безубыток
         case 2:  NewProfit=MinFromSell;           break;   // по минимально достигнутой цене 
         }
      if (NewProfit>SEL.Prf || SEL.Prf==0)   SEL.Prf=NewProfit;  
      if (Ask-NewProfit<StopLevel)           SEL.Val=0;     
      A("CloseSELL: "+comment, NewProfit, bar,  clrGreen);  
   }else{// подтягиваем стоп
      float NewStop=0;       
      switch (price){
         case -1: NewStop=F[hi].P+Atr.Lim;   break;   // стоп за последний пик 
         case -2: NewStop=SEL.Val;           break;   // стоп в безубыток
         }   
      if (SEL.Stp-NewStop>Atr.Lim && NewStop-Ask>Atr.Max)  SEL.Stp=NewStop;     
      V("CloseSELL: "+comment, NewStop, bar, clrRed);
   }  }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ          
void TRAILING(){//    - T R A I L I N G   S T O P -
   if (Trl==0) return;
   float StpBuy=0, StpSel=0;    // 
   
   if (stpL>0)   StpBuy=F[stpL].P-Atr.Lim;    
   if (stpH>0)   StpSel=F[stpH].P+Atr.Lim;      
   
   if (BUY.Val  && StpBuy>0 && StpBuy-BUY.Stp>Atr.Lim  && (StpBuy>BUY.Val  || Trl<0)){ // 
      A("TRAILING_BUY, Back="+S4(F[stpL].BackVal), StpBuy, bar, clrBlue);
      BUY.Stp=StpBuy; }            
   if (SEL.Val && StpSel>0 && SEL.Stp-StpSel>Atr.Lim && (StpSel<SEL.Val || Trl<0)){//
      V("TRAILING_SELL "+DTIME(F[stpH].T), StpSel, bar, clrRed); 
      SEL.Stp=StpSel; } 
   if (Real) ERROR_CHECK(__FUNCTION__);     
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



   
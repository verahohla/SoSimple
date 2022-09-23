
void SIG_NULL(){
   setBUY.Sig=GOGO;    // сигнал на открытие позы
   setBUY.Val=(float)Ask;  // трендовый уровень первого пика
   setBUY.Stp=(float)Ask-ATR*2; // 
   setBUY.Prf=(float)Ask+ATR*5; // 
   setSEL.Sig=GOGO;    // сигнал на открытие позы
   setSEL.Val=(float)Bid;  // трендовый уровень первого пика
   setSEL.Stp=(float)Bid+ATR*2; // 
   setSEL.Prf=(float)Bid-ATR*5; // 
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  

void SIG_FIRST_LEVELS(){ // От первых уровней и уровней серединки.  iSignal=2; Iprice=1..2
   float Delta=float(ATR*Power/3);     
   MID_ZONE_TYPE=Iprice; // // способы вычисления зоны POC: 1~BARS_POC -зона, пересекающая максимальное кол-во бар,   2~PICS_POC -с максимальным кол-вом отскоков,   3~BARSPICS_POC -проходящая через максимальное кол-во пиков бар 
   // Ш О Р Т О В Ы Е   П А Т Т Е Р Н Ы   ////////////////////////////////////////////////////////////////////////////
   
   //if (SEL.Val ){// блокирвока сигнала после первой открывшейся позы
   //   setSEL.Mem=F[HI].P;
   //   if (setSEL.Sig!=BLOCK) V("BLOCK", H, bar,  clrBlue);
   //   setSEL.Sig=BLOCK;
   //   } 
   
   switch (setSEL.Sig){ 
      case BLOCK:
         if (setSEL.Mem!=F[HI].P){ 
            setSEL.Sig=WAIT; // разблокирвка только при смене Первого Уровня на Продажу
            V("UNBLOCK", H+ATR, bar,  clrDarkViolet);
            }
      break;
      case WAIT:  // удаление от ЗОНЫ ПРОДАЖИ
         setSEL.T=Time[bar];     // время формирования сигнала
         setSEL.Sig=GOGO;    // сигнал на открытие позы
         V("GOGO "+S0(HI), H, bar,  clrGreen);
         //if (F[midHI].P-F[HI].Poc<ATR*2 && F[midHI].P>F[HI].Poc){
         //   setSEL.Val=F[HI].Poc-DELTA(D);
         //   setSEL.Stp=F[midHI].P+DELTA(Stp); 
            SELL_PRICE(F[midHI].P-ATR, F[midHI].P);
            SET_PROFIT();
         //   }
      break;
      default:
         if (setSEL.Mem!=F[HI].Mem){// при обновлении F[HI].Back, F[HI].Nearest уровни POC тоже обновляются, переставляем ордер на новый уровень
            setSEL.Mem=F[HI].Mem;
            setSEL.Sig=WAIT;          // сигнал переходит на стадию ожидания,
            }
      }     
   // Л О Н Г О В Ы Е   П А Т Т Е Р Н Ы   ////////////////////////////////////////////////////////////////////////////
   if (setBUY.Mem!=F[LO].Mem){// при обновлении Первого Уровня на Покупку
      setBUY.Mem=F[LO].Mem;
      setBUY.Sig=WAIT;          // сигнал переходит на стадию ожидания,
      }  // A("LO="+S0(LO), F[LO].P, bar, clrLightBlue);
   if (BUY.Val) {setBUY.Sig=NONE;} // X(" ", Close[bar], bar, clrBlue);
   //switch (setBUY.Sig){ 
   //   case WAIT:  // удаление от ЗОНЫ ПОКУПКИ
   //      if (L-F[LO].P>Delta){// цена поднялась над уровнем покупки достаточно высоко
   //         setBUY.T=Time[bar];// время формирования сигнала
   //         setBUY.Sig=GOGO;    // сигнал на открытие позы
   //         A("GOGO "+S0(LO), L, bar,  clrGreen);
   //         BUY_PRICE(F[LO].Poc); 
   //         SET_PROFIT();
   //         } 
   //   break;
   //   case GOGO:// после выставления ордеров снимаем сигнал   
   //      if (L-F[LO].P<Delta) {setBUY.Sig=WAIT; A("WAIT", L, bar,  clrGreen);}          
   //   break;//       
   //   }  
   if (Real) ERROR_CHECK(__FUNCTION__);
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
   
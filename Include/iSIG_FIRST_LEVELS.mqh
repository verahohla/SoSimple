
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
   MID_ZONE_TYPE=Iprice; // // способы вычисления зоны POC: 1~BARS_POC -зона, пересекающая максимальное кол-во бар,   2~PICS_POC -с максимальным кол-вом отскоков,   3~BARSPICS_POC -проходящая через максимальное кол-во пиков бар 
   // Ш О Р Т О В Ы Е   П А Т Т Е Р Н Ы   ////////////////////////////////////////////////////////////////////////////
   //if (SEL.Val ){// блокирвока сигнала после первой открывшейся позы
   //   setSEL.Mem=F[HI].P;
   //   setSEL.Sig=BLOCK; if (setSEL.Sig!=BLOCK) V("BLOCK", H, bar,  clrBlue);
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
         V("GOGO "+S4(F[HI].Poc), F[HI].Poc, bar,  clrGreen);
         //if (F[midHI].P-F[HI].Poc<ATR*2 && F[midHI].P>F[HI].Poc){
         //   setSEL.Val=F[HI].Poc-DELTA(D);
         //   setSEL.Stp=F[midHI].P+DELTA(Stp); 
         if (Iprice==0) SELL_PRICE(F[midHI].P, F[midHI].P); // уровень с максимальным Back
         else           SELL_PRICE(F[HI].Poc,  F[HI].Poc);  // при Iprice>0 берутся три варианта POC: 1~BARS_POC,  2~PICS_POC,  3~BARSPICS_POC
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
   
   //if (BUY.Val){
   //   setBUY.Mem=F[LO].P;
   //   setBUY.Sig=BLOCK;
   //   } 
   switch (setBUY.Sig){ 
      case BLOCK:  // удаление от ЗОНЫ ПОКУПКИ
         if (setBUY.Mem!=F[LO].P){ 
            setBUY.Sig=WAIT; // разблокирвка только при смене Первого Уровня на Продажу
            A("UNBLOCK", L-ATR, bar,  clrDarkViolet);
            }
      break;
      case WAIT:// после выставления ордеров снимаем сигнал   
         setBUY.T=Time[bar];     // время формирования сигнала
         setBUY.Sig=GOGO;    // сигнал на открытие позы
         A("GOGO "+S0(LO), L, bar,  clrGreen);
         if (Iprice==0) BUY_PRICE(F[midLO].P, F[midLO].P);
         else           BUY_PRICE(F[LO].Poc,  F[LO].Poc);
         SET_PROFIT();     
      break;//       
      default:
         if (setBUY.Mem!=F[LO].Mem){// при обновлении Первого Уровня на Покупку
            setBUY.Mem=F[LO].Mem;
            setBUY.Sig=WAIT;          // сигнал переходит на стадию ожидания,
            }  // A("LO="+S0(LO), F[LO].P, bar, clrLightBlue);
      }  
   if (Real) ERROR_CHECK(__FUNCTION__);
   }
   
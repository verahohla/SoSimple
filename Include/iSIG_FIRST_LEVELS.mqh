
void SIG_NULL(){
   setBUY.Sig=GOGO;    // сигнал на открытие позы
   setBUY.Val=(float)Ask;  // трендовый уровень первого пика
   setBUY.Stp=(float)Ask-ATR; // 
   setBUY.Prf=(float)Ask+ATR*3; // 
   setSEL.Sig=GOGO;    // сигнал на открытие позы
   setSEL.Val=(float)Bid;  // трендовый уровень первого пика
   setSEL.Stp=(float)Bid+ATR; // 
   setSEL.Prf=(float)Bid-ATR*3; // 
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  

void SIG_FIRST_LEVELS(){ // От первых уровней и уровней серединки.  iSignal=2;   
                           // BARS_CROSS   1  // зона, пересекающая максимальное кол-во бар
                           // PICS_KICK    2  // зона с максимальным кол-вом отскоков
                           // BARS_KICK    3  // зона, проходящая через максимальное кол-во пиков бар
                           // PICS_PWR_KICK  4  // зона с максимальной силой отскоков/разворотов. Суммируются Power=MIN(FrntVal,BackVal)
                           // MAX_FRONT    5  // пик с максимальным фронтом (не используется)
   // Ш О Р Т О В Ы Е   П А Т Т Е Р Н Ы   ////////////////////////////////////////////////////////////////////////////
   if (DN && F[HI].P>0){
      switch (setSEL.Sig){ 
         case WAIT:  // удаление от ЗОНЫ ПРОДАЖИ
            setSEL.T=Time[bar];     // время формирования сигнала
            setSEL.Sig=GOGO;    // сигнал на открытие позы
            V("GOGO ", F[HI].Mid, bar,  clrGreen);
            SELL_PRICE(F[HI].Mid);  // +Atr.Lim при Iprice>0 берутся три варианта POC: 1~BARS_POC,  2~PICS_POC,  3~BARSPICS_POC
            SELL_PROFIT();
            //Print("F[HI].P=",F[HI].P, " ATR=",ATR);
         break;
         default:
            if (setSEL.Mem!=F[HI].P){// при обновлении F[HI].Back, F[HI].Nearest уровни POC тоже обновляются, переставляем ордер на новый уровень
               setSEL.Mem=F[HI].P;
               setSEL.Sig=WAIT;          // сигнал переходит на стадию ожидания,
               }
      }  } 
        
   // Л О Н Г О В Ы Е   П А Т Т Е Р Н Ы   ////////////////////////////////////////////////////////////////////////////
   if (UP && F[LO].P>0){   
      switch (setBUY.Sig){ 
         case WAIT:// после выставления ордеров снимаем сигнал   
            setBUY.T=Time[bar];     // время формирования сигнала
            setBUY.Sig=GOGO;    // сигнал на открытие позы
            A("GOGO ", F[LO].Mid, bar,  clrGreen);
            BUY_PRICE(F[LO].Mid);
            BUY_PROFIT();
            //Print("F[LO].P=",F[LO].P, " ATR=",ATR);     
         break;//       
         default:
            if (setBUY.Mem!=F[LO].P){// при обновлении Первого Уровня на Покупку
               setBUY.Mem=F[LO].P;
               setBUY.Sig=WAIT;          // сигнал переходит на стадию ожидания,
               }  // A("LO="+S0(LO), F[LO].P, bar, clrLightBlue);
      }  }
   if (Real) ERROR_CHECK(__FUNCTION__);
   }
   
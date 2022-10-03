#define  DrawFlat     0
void FLAT_DETECT(float LevMiddle, uchar FlatBegin){
   //if (Prn) Print(DTIME(Time[bar])," F[14].Fls.Phase",F[14].Fls.Phase);
   F[n].Flt.Len=0;   // для начала обнулим значения на случай, 
   F[n].Flt.Lev=0;   // если флэт не состоится
   F[n].Fls.Phase=NONE;   // сброс флага (ложняка для данного пика не будет проверяться)
   F[n].Fls.P=F[n].P;    // максимум ложнаяка, пробившего этот пик, пока приравняем к самому пику
   if (FlatBegin==0) return; // у пика небыло совпадений с предыдущими
   if (F[n].Cnt<PicCnt || F[n].Cnt<2)  return; // не набралось кол-во отскоков, либо в условии задано <2 
   int len=SHIFT(F[FlatBegin].T)-bar; // длина флэта
   if (len>126) F[n].Flt.Len=127; else F[n].Flt.Len=char(len); // длина = кол-во бар между крайними пиками (ограничиваем до разумных пределов)  
   if (F[n].Flt.Len<FltLen) return; // слишком короткий флэт
   F[n].Flt.T=F[FlatBegin].T;       // время формирования первого (дальнего) пика флэта
   F[n].Flt.Frnt=F[FlatBegin].Frnt; // фронт первого пика флэта (движение предшествующее флэту) 
   F[n].Flt.Back=F[FlatBegin].Back; // противоположная граница флэта это Back первого пика флэта
   F[n].Flt.Lev=LevMiddle/F[n].Cnt;   // усредненная граница флэта  
   //if (MathAbs(F[n].Flt.Lev-F[n].Flt.Back)<ATR*2) return; // структура флэта формируется, если он достаточно широкий,   
   
   
   if (DrawFlat) LINE("Begin: "+DTIME(F[n].Flt.T)+" Len="+S0(F[n].Flt.Len), SHIFT(F[n].Flt.T), F[n].Flt.Lev, bar+PicPer,F[n].Flt.Lev,clrDarkViolet,0);
   if (DrawFlat) LINE("Opposite="+S4(F[n].Flt.Back), SHIFT(F[n].Flt.T),F[n].Flt.Back, bar+PicPer,F[n].Flt.Back,clrThistle,0);
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ       
#define  DrawFalseBreak     1
void FALSE_BREAK(uchar f){// проверка ложного пробоя
   // iParam=0 - с подтверждением пробоем базы 
   // iParam=1 - без подтверждения пробоем базы
   int i;
   if (iSignal!=1)            return;  // обработка сигнала ложняка при iSignal=1 (функция INPUT())
   if (F[f].Fls.Phase==NONE)  return;  // ложняк уровня либо отработался, либо не годен
   if (F[f].Flt.Len<FltLen)   return;  // Пробитый флэт д.б. достаточно широким
   if (F[f].Per<FltLen)       return;  // Между пиком и пробоем достаточно бар (>12 по Баженову)
   if (F[f].Cnt<PicCnt)       return;  // количество отскоков от уровня не достаточно
   if (F[f].Dir>0){// Вершина
      if (New>F[f].P+Atr.Max*2){// слишком далеко вылетело 
         if (DrawFalseBreak) X("TooBig"+S0(f), New, bar+PicPer, UPCLR);
         F[f].Fls.Phase=NONE;
         return;} // отменяем слишком большой ложняк  
      if (F[f].Fls.Phase>WAIT && New<F[f].Back+F[f].BackVal/3){ // ложняк зародился и цена вернулась слишком глубоко
         if (DrawFalseBreak) LINE("Back="+S4(F[f].Back), bar+PicPer,New, SHIFT(F[f].Fls.T),F[f].Fls.P,clrGreen,2);
         F[f].Fls.Phase=NONE; // ложняк отработался
         return;}
      if (F[f].Fls.Phase>START && New>F[f].P+Atr.Lim){// новый пик над пробитым уровнем
         if (DrawFalseBreak) X("Double Break "+S0(f), New, bar+PicPer, clrRed);
         F[f].Fls.Phase=NONE; // отменяем, ложняк должен состоять из одного фрактала   
         return;}
      if (F[f].Fls.Phase==WAIT && New>F[f].P+Atr.Lim){// уровень только что пробит 
         if (DrawFalseBreak) LINE(S0(f)+" Per="+S0(F[f].Per), bar+PicPer,New,  bar+PicPer,F[f].Back,UPCLR,0);// вертикаль из ложняка до Back пробитого уровня (потенциал)
         if (DrawFalseBreak) LINE(S0(f)+" Back="+S4(F[f].Back)+" "+DTIME(F[f].Flt.T)+" Len="+S0(F[f].Flt.Len), bar+PicPer,F[f].P,  SHIFT(F[f].Flt.T),F[f].P,UPCLR,0); // Соединяет пробитый пик с ложняком       
         F[f].Fls.Phase=START;// начало формирования ложняка V(S0(f), F[f].P, SHIFT(F[f].T), clrBlack);
         F[f].Fls.P=New;      // запоминаем пик ложняка
         F[f].Fls.T=Time[bar+PicPer];// и время его 
         F[f].Fls.Base=float(Low[bar+PicPer+1]);  // предварительное значение базы ложняка - пик из которого он выстрелил
         F[f].Fls.BT=Time[bar+PicPer+1];          // и времени базы
         for (i=bar+PicPer+2; i<SHIFT(F[f].T); i++){// поиск базы ложняка от ложняка до пробитого пика  
            if (Low[i]<F[f].Fls.Base) {F[f].Fls.Base=float(Low[i]); F[f].Fls.BT=Time[i];} // обновляем значение базы и ее время
            if (High[i]<High[i+1] || Low[i]<Low[i+1]) break;} // минимум по High или Low между пробитой вершиной и новым пиком  
         if (DrawFalseBreak) LINE("BuyLev"+S0(f), bar+PicPer,F[f].Fls.Base, i,F[f].Fls.Base,UPCLR,0); // горизонталь по уровню базы
         }
      if (F[f].Fls.Phase==START){
         if (New>F[f].Fls.P){ 
            if (DrawFalseBreak) V("NewPic "+S0(f), New, bar+PicPer, UPCLR);
            F[f].Fls.P=New;
            F[f].Fls.T=Time[bar+PicPer];}
         if (New<F[f].P-Atr.Lim){ // возврат под пробитый уровень 
            F[f].Fls.Phase=CONFIRM; 
            if (DrawFalseBreak) LINE("CONFIRM "+S0(FlsUp), bar+PicPer,New, SHIFT(F[f].Fls.BT),New,UPCLR,2);
         }  }
      if (F[f].Fls.Phase==CONFIRM && New<F[f].Fls.Base){ // подтверждение ложняка пробоем его базы (уровня на покупку, из которого он выстрелил) 
         F[f].Fls.Phase=GOGO; 
         FlsUp=f;    // индекс ложняка
         if (DrawFalseBreak) LINE("GOGO "+S0(FlsUp), bar+PicPer,New, SHIFT(F[f].Fls.BT),New,UPCLR,4);
         }
            
      
   }else{//  Впадина /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      if (New<F[f].P-Atr.Max*2){// слишком далеко вылетело 
         F[f].Fls.Phase=NONE; 
         if (DrawFalseBreak) X("TooBig"+S0(f), New, bar+PicPer, DNCLR);
         }
      if (F[f].Fls.Phase!=WAIT){ // ложняк уже зародился
         //if (New<F[f].P-Atr.Lim){// новый пик под пробитым уровнем
         //   if (DrawFalseBreak) X("Double Break "+S0(f), New, bar+PicPer, DNCLR);
         //   F[f].Fls.Phase=NONE;} // отменяем
         if (New>(F[f].P+F[f].Back)*0.5){// цена улетела выше половины диапа, открываться уже нет смысла 
            if (DrawFalseBreak) LINE("TARGET "+S0(f)+" PHASE="+S0(F[f].Fls.Phase), bar+PicPer,New, SHIFT(F[f].Fls.T),F[f].Fls.P,clrPaleGreen,2);
            F[f].Fls.Phase=NONE;// ложняк отработался 
         }  }    
      switch (F[f].Fls.Phase){
         case WAIT:
            if (Dir<0 && New<F[f].P-Atr.Lim){// ложняк только что образовался
               if (DrawFalseBreak) LINE(S0(f)+" Per="+S0(F[f].Per), bar+PicPer,New,  bar+PicPer,F[f].Back,DNCLR,0);// обновление максимума ложняка, пробившего этот пик
               if (DrawFalseBreak) LINE(S0(f)+" Back="+S4(F[f].Back)+" Сnt="+S0(F[f].Cnt)+" "+DTIME(F[f].Fls.T), bar+PicPer,F[f].P, SHIFT(F[f].Flt.T),F[f].P,DNCLR,0);
               if (New<F[f].P-Atr.Max*2){// слишком далеко вылетело 
                  F[f].Fls.Phase=NONE; 
                  if (DrawFalseBreak) X("TooBig"+S0(f), New, bar+PicPer, DNCLR);
                  break;} // отменяем слишком большой ложняк       
               F[f].Fls.Phase=START;// флаг зарождения V(S0(f), F[f].P, SHIFT(F[f].T), clrBlack);
               F[f].Fls.P=New;   // запоминаем пик ложняка
               F[f].Fls.T=Time[bar+PicPer];// и время его 
               F[f].Fls.Base=float(High[bar+PicPer+1]);// предварительное значение базы ложняка - пик из которого он выстрелил
               F[f].Fls.BT=Time[bar+PicPer+1];
               if (D<0){// без подтверждения - сразу ставим ордер на пробой базы, либо на пробитой вершины
                  FlsDn=f; // индекс ложняка
                  F[f].Fls.Phase=CONFIRM;} 
               for (i=bar+PicPer+2; i<SHIFT(F[f].T); i++){// поиск базы ложняка от ложняка до пробитого пика  
                  if (High[i]>F[f].Fls.Base) {F[f].Fls.Base=float(High[i]); F[f].Fls.BT=Time[i];} // обновляем значение базы и ее время
                  if (High[i]>High[i+1] || Low[i]>Low[i+1]) break;} // максимум по High или Low между пробитой вершиной и новым пиком  
               if (DrawFalseBreak) LINE("SelLev"+S0(f)+" "+DTIME(F[f].Fls.BT), bar+PicPer,F[f].Fls.Base, SHIFT(F[f].Fls.BT),F[f].Fls.Base,DNCLR,3);
               }
         break;
         case START:
            if (New>F[f].Fls.Base){// подтверждение ложняка пробоем его базы (уровня на покупку, из которого он выстрелил) 
               F[f].Fls.Phase=CONFIRM; 
               FlsDn=f;    // индекс ложняка
               if (DrawFalseBreak) LINE("CONFIRM "+S0(FlsDn), bar+PicPer,New, SHIFT(F[f].Fls.BT),New,DNCLR,3);
               }
         break;        
         case CONFIRM:
            if (New<F[f].P-Atr.Lim){// повторный пробой пробитого уровня
               if (DrawFalseBreak) X("Second Break "+S0(f), New, bar+PicPer, DNCLR);
               F[f].Fls.Phase=NONE;} // отменяем
         break;      
         } 
      
   }  }  
   
//float CENTER(int i){    // определение центра пересечения трех бар (i-й и два по краям)
//   double Hi=MathMin(High[i],High[i+1]); // крайние значения между
//   double Lo=MathMax(Low [i],Low [i+1]); // i-м и предыдущим
//   Hi=MathMin(Hi,High[i-1]);  // крайние значения между
//   Lo=MathMax(Lo,Low [i-1]);  // i-м и последующим
//   return (float(Hi+Lo)/2);
//   }    
            
            
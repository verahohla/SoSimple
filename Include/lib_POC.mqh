#include <head_PIC.mqh> 
float minHi,maxLo; // самая нижняя впадина сверху и самая высокая снизу в формирующемся диапазоне
short PocSum, LastPoc;   // инкремент РОС для формирования массива распределения 

// способы вычисления зоны POC: 
#define MAX_FRONT       1  // пик с максимальным фронтом
#define BARS_CROSS      2  // зона, пересекающая максимальное кол-во бар
#define PICS_KICK       3  // зона с максимальным кол-вом отскоков
#define PICS_PWR_KICK   4  // зона с максимальной силой отскоков/разворотов. Суммируются Power=MIN(FrntVal,BackVal)
#define BARS_KICK       5  // зона, проходящая через максимальное кол-во пиков бар

 



void POC_INDICATOR(){
   float  MaxPoc;        // максимальное значение POC
   float   MaxPocPrice;   // уровень с максимальным значением POC
   minHi=float(MathMin(High[bar],minHi)); // С каждым новым баром края диапазона minHi и maxLo с учетом новых High и Low
   maxLo=float(MathMax(Low [bar],maxLo)); // обрезаются, стремясь к его середине. 
   PocSum++;
   LastPoc++;
   if (minHi > maxLo) return;// диапазон пересечения последних нескольких бар положителен, т.е. ни один бар не "выскочил" за него: считаем кол-во идущих подряд бар с общим ценовым диапазоном 
   
   if (PocSum>5){// совпало достаточное кол-во бар
      float UpBorder=float(iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, LastPoc+1, bar+1)));
      float DnBorder=float(iLow (NULL, 0, iLowest (NULL, 0, MODE_LOW,  LastPoc+1, bar+1)));
      MaxPocPrice=POC(UpBorder,DnBorder,bar+LastPoc+1, bar+1, MaxPoc,  PICS_KICK, true); 
      //POC_COUNT(bar+LastPoc+1, bar+1, MaxPoc, MaxPocPrice); // расчет уровня и значения РОС в сформированном диапазоне
      if (MaxPoc>uchar(FltLen) && bar+MaxPoc<Bars){
         LINE("Up=" ,bar+1,MaxPocPrice, bar+int(MaxPoc),MaxPocPrice, MaxPocColor,1);
         LastPoc=0;
      }  }
   PocSum=0; // кол-во совпавших бар = текущий и предыдущий
   float mHi=float(High[bar]);   minHi=mHi;
   float mLo=float(Low [bar]);   maxLo=mLo;
   for (int i=bar+1; i<Bars; i++){
      mHi=float(MathMin(High[i],mHi)); // С каждым новым баром края диапазона minHi и maxLo с учетом новых High и Low
      mLo=float(MathMax(Low [i],mLo)); // обрезаются, стремясь к его середине. 
      if (mHi<mLo) break;
      else{
         PocSum++;
         minHi=mHi;   // для дальнейшего
         maxLo=mLo;   // отслеживания  
      }  }
            
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
double HiZone, DnZone; 
float PocCenter; 
uchar PocCnt;  // кол-во пересекающихся друг за другом бар
void POC_SIMPLE(){    // определение плотного скопления бар без пропусков
   HiZone=MathMin(High[bar],HiZone); // С каждым новым баром края диапазона h и l
   DnZone=MathMax(Low [bar],DnZone); // обрезаются с учетом новых High и Low
   if (HiZone>DnZone) {PocCnt++; PocCenter=float((HiZone+DnZone)/2);} // считаем длину сформированного диапазона и его серединку
   else{// Диапазон прервался (сузился до нуля)
      //LINE("POC="+S0(PocCnt) ,bar+PocCnt,PocCenter, bar,PocCenter, PocColor,0);
      PocCnt=1;    
      HiZone=High[bar]; 
      DnZone=Low[bar]; 
   }  }    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
  //           F[HI].Tr, (F[HI].P+F[HI].Back)/2, SHIFT(F[HI].T), SHIFT(F[HI].BackT), MaxPoc, Poc, false
float POC(float DnBorder, float UpBorder, int FromBar, int ToBar, float& MaxPoc, char PocType, bool DrawHistogram){// РОС - зона скопления цен, вычисляется тремя способами: 1-максимальное кол-во пиков бар, 2-отскоков, 3-скопление бар 
   //if (UpBorder<DnBorder)  {float temp=UpBorder; UpBorder=DnBorder; DnBorder=temp;}
   //if (FromBar>ToBar)      {int temp=FromBar; FromBar=ToBar; ToBar=temp;}
   float   MaxPocPrice, point=float(Point*50.0); // шаг сканирования диапазона (снизу вверх)    Atr.Lim
   if (ToBar>Bars-1) ToBar=Bars-1;
   int UpEdge = int(UpBorder/point)-1;   // диапазона на текущем ТФ в целых числах
   int DnEdge = int(DnBorder/point)+1;   // нижняя и верхняя границы
	int Range = UpEdge-DnEdge+1; // размер диапазона в пунктах от нижней до верхней его границы = коло-во членов массива PocArr
	if (Range<1) return(0);
	MaxPocPrice=0; MaxPoc=0;
	ushort PocArr[];// массив распределения POC 
	uchar Pic=0;
	ArrayResize(PocArr, Range);
	switch (PocType){ // разные способы нахождения РОС
   	case MAX_FRONT:  // 1: пик с максимальным фронтом
         for (uchar f=1; f<LevelsAmount; f++){  // 
            if (F[f].Brk>TOUCH || F[f].P<=DnBorder || F[f].P>=UpBorder || SHIFT(F[f].T)>FromBar || SHIFT(F[f].T)<ToBar) continue; // пик за пределами интересующего нас диапазона 
            //if (F[f].Dir>0 || F[f].T<F[LO].T || SHIFT(F[f].T)<bar+PicPer*2 || F[f].P>UpBorder || F[f].P<DnBorder || F[f].P>L || F[f].FrntVal<MaxFront || F[f].P==0) continue; //  F[f].T<F[LO].T || 
            if (F[f].FrntVal>MaxPoc){   //Power
               MaxPoc=F[f].FrntVal; 
               MaxPocPrice=F[f].P; 
               Pic=f;
            }  }
      MaxPoc=Pic; // V(S0(HI), F[Pic].P, SHIFT(F[Pic].T), clrBlack);
      
      break;
   	case BARS_CROSS: // 2: зона, пересекающая максимальное кол-во бар
         for (int b=FromBar; b<=ToBar; b++){// перебор диапазона по барам справа налево
      		int Hi=int(High[b]/point); // H свечи
      		int Lo=int(Low [b]/point); // L свечи (в целых числах)
      		if (Hi<DnEdge || Lo>UpEdge) continue; // свеча за пределами диапазона
      		if (Hi>UpEdge) Hi=UpEdge;
		      if (Lo<DnEdge) Lo=DnEdge;
      		for (int p=Lo; p<=Hi; p++){// перебор свечи от L к H с шагом point=Point*10
      		   PocArr[p-DnEdge]+=1;    // заполняем массив на каждом уровне, где попадается свеча
            }  }
      break;
   	case PICS_KICK:  // 3: зона с максимальным кол-вом отскоков
         for (uchar f=1; f<LevelsAmount; f++){  // 
            int p=int(F[f].P/point);            // значение пика кратное шагу сканирования диапазона
            if (p<=DnEdge || p>=UpEdge) continue; // пик за пределами интересующего нас диапазона
            PocArr[p-DnEdge]+=ushort(F[f].Pics);    // складываются все отскоки на данном уровне  *MathAbs(F[f].P-F[f].Back)/Point/1000
            }
      break;
      case PICS_PWR_KICK:  // 4: зона с максимальной силой отскоков
         for (uchar f=1; f<LevelsAmount; f++){  // 
            if (F[f].P<DnBorder || F[f].P>UpBorder) continue; // пик за пределами интересующего нас диапазона
            if (F[f].PwrSum>MaxPoc){   //Power
               MaxPoc=F[f].PwrSum; 
               MaxPocPrice=F[f].P;
            }  }
      break;
      
      case BARS_KICK: // 5: зона, проходящая через максимальное кол-во пиков бар
      	for (int b=FromBar; b<=ToBar; b++){// перебор диапазона по барам справа налево
      		int Hi=int(High[b]/point); // H свечи
      		int Lo=int(Low [b]/point); // L свечи (в целых числах)
      	   if (Hi<UpEdge && Hi>DnEdge)  PocArr[Hi-DnEdge]+=1; // for (int p=Hi-DnEdge-1; p<=Hi-DnEdge+1; p++) PocArr[p]+=1;  // Если кончик свечи в пределах диапазона,
      	   if (Lo<UpEdge && Lo>DnEdge)  PocArr[Lo-DnEdge]+=1; // for (int p=Lo-DnEdge-1; p<=Lo-DnEdge+1; p++) PocArr[p]+=1;  // увеличиваем количество его попаданий в массиве уровней 
      	   } 
      break;
      }        
	//if (MaxPocPrice==0){ // MaxPocPrice ищется через массив PocArr 
 //  	int MaxPocIndex=ArrayMaximum(PocArr,WHOLE_ARRAY,0);
 //  	MaxPoc=PocArr[MaxPocIndex]; 
 //  	if (MaxPoc==0) MaxPocPrice=0;
 //  	else           MaxPocPrice=(DnEdge+MaxPocIndex)*point;
 //  	}
	// DRAW HISTOGRAM
	if (!DrawHistogram) return(MaxPocPrice);
	for (int p=0; p<Range; p++){ // от нижней до верхней границы гистограммы POC 
      float Y=(DnEdge+p)*point;
      int X=bar+PocArr[p]/2;
      if (X>Bars-1) X=Bars-1;
      LINE("POC" ,bar+1,Y, X,Y, PocColor,0);   
      } 
   if (bar+MaxPoc<Bars) LINE("Up",bar+1,MaxPocPrice, bar+(int)MaxPoc/2,MaxPocPrice, MaxPocColor,2);  // максимум гистограммы выделяем красным
	return (MaxPocPrice);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
float POC_HI(float UpBorder, float DnBorder, int ToBar, int From, float& MaxPoc,  char PocType, bool DrawHistogram){// самая верхняя из посчитанных тремя способами РОС
   float Poc1=POC(UpBorder,DnBorder,ToBar, From, MaxPoc,  BARS_CROSS, false);  // зона, пересекающая максимальное кол-во бар
   if (bar+MaxPoc<Bars) LINE("BARS_CROSS "+S4(MaxPoc),bar+1,Poc1, bar+(int)MaxPoc/3,Poc1, clrMediumSeaGreen,0);    
   float Poc2=POC(UpBorder,DnBorder,ToBar, From, MaxPoc,  PICS_KICK, false);  // зона с максимальным кол-вом отскоков
   if (bar+MaxPoc<Bars) LINE("PICS_KICK "+S4(MaxPoc),bar+1,Poc2, bar+(int)MaxPoc*2,Poc2, clrRed,2);  
   float Poc3=POC(UpBorder,DnBorder,ToBar, From, MaxPoc,  BARS_KICK, false); // зона, проходящая через максимальное кол-во пиков бар
   if (bar+MaxPoc<Bars) LINE("BARS_KICK "+S4(MaxPoc),bar+1,Poc3, bar+(int)MaxPoc,Poc3, clrBlue,0);  
   float MaxPocPrice=MathMax(Poc1,Poc2);
   MaxPocPrice=MathMax(Poc3,MaxPocPrice);
   return (MaxPocPrice);
   }
float POC_LO(float UpBorder, float DnBorder, int ToBar, int From, float& MaxPoc,  char PocType, bool DrawHistogram){// самая нижняя из посчитанных тремя способами РОС
   float Poc1=POC(UpBorder,DnBorder,ToBar, From, MaxPoc,  BARS_CROSS, false);  // зона, пересекающая максимальное кол-во бар
   if (bar+MaxPoc<Bars) LINE("BARS_CROSS "+S4(MaxPoc),bar+1,Poc1, bar+(int)MaxPoc/3,Poc1, clrMediumSeaGreen,0);    
   float Poc2=POC(UpBorder,DnBorder,ToBar, From, MaxPoc,  PICS_KICK, false);  // зона с максимальным кол-вом отскоков
   if (bar+MaxPoc<Bars) LINE("PICS_KICK "+S4(MaxPoc),bar+1,Poc2, bar+(int)MaxPoc*2,Poc2, clrRed,2);  
   float Poc3=POC(UpBorder,DnBorder,ToBar, From, MaxPoc,  BARS_KICK, false); // зона, проходящая через максимальное кол-во пиков бар
   if (bar+MaxPoc<Bars) LINE("BARS_KICK "+S4(MaxPoc),bar+1,Poc3, bar+(int)MaxPoc, Poc3, clrBlue,0);  
   float MaxPocPrice=MathMin(Poc1,Poc2);
   MaxPocPrice=MathMin(Poc3,MaxPocPrice);
   return (MaxPocPrice);
   }   
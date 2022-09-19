#include <head_PIC.mqh> 
float minHi,maxLo; // самая нижняя впадина сверху и самая высокая снизу в формирующемся диапазоне
short PocSum, LastPoc;   // инкремент РОС для формирования массива распределения 

// способы вычисления зоны POC
#define BARS_POC     1  // зона, пересекающая максимальное кол-во бар
#define PICS_POC     2  // зона с максимальным кол-вом отскоков
#define BARSPICS_POC 3  // зона, проходящая через максимальное кол-во пиков бар

void POC_INDICATOR(){
   ushort  MaxPoc;        // максимальное значение POC
   float   MaxPocPrice;   // уровень с максимальным значением POC
   minHi=float(MathMin(High[bar],minHi)); // С каждым новым баром края диапазона minHi и maxLo с учетом новых High и Low
   maxLo=float(MathMax(Low [bar],maxLo)); // обрезаются, стремясь к его середине. 
   PocSum++;
   LastPoc++;
   if (minHi > maxLo) return;// диапазон пересечения последних нескольких бар положителен, т.е. ни один бар не "выскочил" за него: считаем кол-во идущих подряд бар с общим ценовым диапазоном 
   
   if (PocSum>5){// совпало достаточное кол-во бар
      float UpBorder=float(iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, LastPoc+1, bar+1)));
      float DnBorder=float(iLow (NULL, 0, iLowest (NULL, 0, MODE_LOW,  LastPoc+1, bar+1)));
      POC(UpBorder,DnBorder,bar+LastPoc+1, bar+1, MaxPoc, MaxPocPrice, PICS_POC); 
      //POC_COUNT(bar+LastPoc+1, bar+1, MaxPoc, MaxPocPrice); // расчет уровня и значения РОС в сформированном диапазоне
      if (MaxPoc>uchar(FltLen) && bar+MaxPoc<Bars){
         LINE("Up=" ,bar+1,MaxPocPrice, bar+MaxPoc,MaxPocPrice, MaxPocColor,1);
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
float POC(float UpBorder, float DnBorder, int BarFrom, int BarTo, ushort& MaxPoc, float& MaxPocPrice, char PocType){// РОС - зона, где встречается самое большое количество кончиков бар
   float   point=float(Point*50.0); // шаг сканирования диапазона (снизу вверх)    Atr.Lim
   if (BarFrom>Bars-1) BarFrom=Bars-1;
   int bars=BarFrom-BarTo;
   int UpEdge = int(UpBorder/point);   // диапазона на текущем ТФ в целых числах
   int DnEdge = int(DnBorder/point);   // нижняя и верхняя границы
	int Range = UpEdge-DnEdge+1; // размер диапазона в пунктах от нижней до верхней его границы = коло-во членов массива PocArr
	if (Range<1) return(0);
	ushort PocArr[];// массив распределения POC 
	ArrayResize(PocArr, Range);
	switch (PocType){ // разные способы нахождения РОС
   	case BARSPICS_POC: // зона, проходящая через максимальное кол-во пиков бар
      	for (int b=BarTo; b<=BarFrom; b++){// перебор диапазона по барам справа налево
      		int Hi=int(High[b]/point); // H свечи
      		int Lo=int(Low [b]/point); // L свечи (в целых числах)
      	   if (Hi<UpEdge && Hi>DnEdge)  PocArr[Hi-DnEdge]+=1; // for (int p=Hi-DnEdge-1; p<=Hi-DnEdge+1; p++) PocArr[p]+=1;  // Если кончик свечи в пределах диапазона,
      	   if (Lo<UpEdge && Lo>DnEdge)  PocArr[Lo-DnEdge]+=1; // for (int p=Lo-DnEdge-1; p<=Lo-DnEdge+1; p++) PocArr[p]+=1;  // увеличиваем количество его попаданий в массиве уровней 
      	   } 
      break;
      case PICS_POC:  // зона с максимальным кол-вом отскоков
         for (uchar f=1; f<LevelsAmount; f++){// в нулевом хранится последнее значение, оно же записывается в массив вместо самого слабого пика 
            int p=int(F[f].P/point); // значение пика кратное шагу сканирования диапазона
            if (p<=DnEdge || p>=UpEdge) continue; // пик за пределами интересующего нас диапазона
            PocArr[p-DnEdge]+=ushort(F[f].Cnt);    // складываются все отскоки на данном уровне  *MathAbs(F[f].P-F[f].Back)/Point/1000
            }
      break;
      case BARS_POC: // зона, пересекающая максимальное кол-во бар
         for (int b=0; b<=bars; b++){// перебор диапазона по барам справа налево
      		int Hi=int(High[BarTo+b]/point); // H свечи
      		int Lo=int(Low [BarTo+b]/point); // L свечи (в целых числах)
      		if (Hi<DnEdge || Lo>UpEdge) continue; // свеча за пределами диапазона
      		if (Hi>UpEdge) Hi=UpEdge;
		      if (Lo<DnEdge) Lo=DnEdge;
      		for (int p=Lo; p<=Hi; p++){// перебор свечи от L к H с шагом point=Point*10
      		   PocArr[p-DnEdge]+=1;    // заполняем массив на каждом уровне, где попадается свеча
            }  }
      break;
      }        
	int MaxPocIndex=ArrayMaximum(PocArr,WHOLE_ARRAY,0);
	MaxPoc=PocArr[MaxPocIndex]; 
	MaxPocPrice=(DnEdge+MaxPocIndex)*point;
	// DRAW HISTOGRAM
	for (int p=0; p<Range; p++){ // от нижней до верхней границы гистограммы POC 
      float Y=(DnEdge+p)*point;
      int X=bar+PocArr[p];
      if (X>Bars-1) X=Bars-1;
      LINE("POC" ,bar+1,Y, X,Y, PocColor,0);   
      } 
   if (bar+MaxPoc<Bars) LINE("Up",bar+1,MaxPocPrice, bar+MaxPoc,MaxPocPrice, MaxPocColor,2);  // максимум гистограммы выделяем красным
	return (MaxPocPrice);
   }
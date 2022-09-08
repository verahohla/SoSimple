#include <head_PIC.mqh> 
float minHi,maxLo; // самая нижняя впадина сверху и самая высокая снизу в формирующемся диапазоне
short PocSum, LastPoc;   // инкремент РОС для формирования массива распределения 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//int POC_INIT(){
//   //Comment( "Начало истории минуток         ",  TimeToString(iTime(NULL,PERIOD_M1, iBars(NULL,PERIOD_M1)-1)), ", в окне  ",iBars(NULL,PERIOD_M1)," бар"+"\n"+
//   //         "Начало истории текущего ТФ ",      TimeToString(Time[Bars-1]),                                   ", в окне  ",Bars,                 " бар");
//   Print("POC_INIT() success");
//   return (INIT_SUCCEEDED); // Успешная инициализация. Результат выполнения функции OnInit() анализируется терминалом только если программа скомпилирована с использованием #property strict.
//   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
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
      BAR_TIP_POC(UpBorder,DnBorder,bar+LastPoc+1, bar+1, MaxPoc, MaxPocPrice); 
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
float BAR_TIP_POC(float UpBorder, float DnBorder, int BarFrom, int BarTo, ushort& MaxPoc, float& MaxPocPrice){// РОС - зона, где встречается самое большое количество кончиков бар
   float   point=Atr.Lim/2; // шаг сканирования диапазона (снизу вверх)  float(Point*30.0)
   if (BarFrom>Bars-1) BarFrom=Bars-1;
   int bars=BarFrom-BarTo;
   int maxp=0;
   int UpEdge = int(UpBorder/point)+1;   // диапазона на текущем ТФ в целых числах
   int DnEdge = int(DnBorder/point);   // нижняя и верхняя границы
	int Range = UpEdge-DnEdge+1; // размер диапазона в пунктах от нижней до верхней его границы = коло-во членов массива PocArr
	int PocArr[];// массив распределения POC 
	ArrayResize(PocArr, Range);
	ArrayInitialize(PocArr, 0);
	MaxPoc=0; 
	int Lim=int(Atr.Lim/point); // погрешность для поиска отскоков   
	for (int b=BarTo; b<=BarFrom; b++){// перебор диапазона по барам справа налево
		int Hi=int(High[b]/point); // H свечи
		int Lo=int(Low [b]/point); // L свечи (в целых числах)
	   if (Hi<UpEdge && Hi>DnEdge)  PocArr[Hi-DnEdge]+=1; // for (int p=Hi-DnEdge-1; p<=Hi-DnEdge+1; p++) PocArr[p]+=1;  // Если кончик свечи в пределах диапазона,
	   if (Lo<UpEdge && Lo>DnEdge)  PocArr[Lo-DnEdge]+=1; // for (int p=Lo-DnEdge-1; p<=Lo-DnEdge+1; p++) PocArr[p]+=1;  // увеличиваем количество его попаданий в массиве уровней 
	   }
	for (int p=0; p<Range; p++){// перебор массива уровней в поисках самого большого количества совпадений 
	   if (PocArr[p]>MaxPoc){
	      MaxPoc=(ushort)PocArr[p]; // Maксимальное значение POC
	      maxp=p;  // Индекс максимального значения 
	   }  }  
	MaxPocPrice=(DnEdge+maxp)*point;
	//for (int p=maxp; p<Range; p++)// шарим массив в обратном направлении
	//   if (PocArr[p]<MaxPoc) {MaxPocPrice=(int(maxp+p-1)/2+DnEdge)*point; break;} // в поисках центра POC  
	
	//// Draw POC lines
	//for (int p=0; p<Range; p++){ // от нижней до верхней границы гистограммы POC 
 //     float Y=(DnEdge+p)*point;
 //     int X=bar+PocArr[p];
 //     if (X>Bars-1) X=Bars-1;
 //     LINE("POC="+S5(MaxPocPrice) ,bar+1,Y, X,Y, PocColor,0);   // максимум гистограммы выделяем красным
 //     }
 //  if (bar+MaxPoc<Bars) LINE("Up="+S4(UpBorder)+" Dn="+S4(DnBorder) ,bar+1,MaxPocPrice, bar+MaxPoc,MaxPocPrice, MaxPocColor,1);   
	return (MaxPocPrice);
   }  
    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
float PIC_CNT_POC(float UpBorder, float DnBorder, ushort& MaxPoc, float& MaxPocPrice){// РОС - зона с самым большим количеством отскоков
   float   point=Atr.Lim; // шаг сканирования диапазона (снизу вверх)
   int maxp=0;
   int UpEdge = int(UpBorder/point);   // диапазона на текущем ТФ в целых числах
   int DnEdge = int(DnBorder/point);   // нижняя и верхняя границы
	int Range = UpEdge-DnEdge+1; // размер диапазона в пунктах от нижней до верхней его границы = коло-во членов массива PocArr
	uchar PocArr[];// массив распределения POC 
	ArrayResize(PocArr, Range);
	ArrayInitialize(PocArr, 0);
	MaxPoc=0; 
	for (uchar f=1; f<LevelsAmount; f++){// в нулевом хранится последнее значение, оно же записывается в массив вместо самого слабого пика 
      int p=int(F[f].P/point); // значение пика кратное шагу сканирования диапазона
      if (p<DnEdge || p>UpEdge) continue; // пик за пределами интересующего нас диапазона
      PocArr[p-DnEdge]+=F[f].Cnt;    // заполняем массив на каждом уровне, где попадается свеча
      if (PocArr[p-DnEdge]>MaxPoc){
	      MaxPoc=(ushort)PocArr[p-DnEdge]; // Maксимальное значение POC
	      maxp=p-DnEdge;  // Индекс максимального значения
	      MaxPocPrice=p*point; // Цена с этим значением 
         }
      }
      
      
	//// Draw POC lines
	//for (int p=0; p<Range; p++){ // от нижней до верхней границы гистограммы POC 
 //     float Y=(DnEdge+p)*point;
 //     int X=bar+PocArr[p];
 //     if (X>Bars-1) X=Bars-1;
 //     LINE("POC="+S5(MaxPocPrice) ,bar+1,Y, X,Y, PocColor,0);   // максимум гистограммы выделяем красным
 //     }
 //  if (bar+MaxPoc<Bars) LINE("Up="+S4(UpBorder)+" Dn="+S4(DnBorder) ,bar+1,MaxPocPrice, bar+MaxPoc,MaxPocPrice, MaxPocColor,1);   
	return (MaxPocPrice);
   }     
   
       
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
int POC_COUNT(int  BarFrom, int BarTo, ushort& MaxPoc, float& MaxPocPrice){// расчет уровня и значения РОС за последние PocBars бар
   float   point=float(Point*10.0); // шаг сканирования диапазона (снизу вверх). Для ускорения увеличиваем х10 
   if (BarFrom>Bars-1) BarFrom=Bars-1;
   int bars = BarFrom-BarTo; // размер диапазона в пунктах от нижней до верхней его границы
   int DnEdge = (int)MathRound(iLow (NULL, 0, iLowest (NULL, 0, MODE_LOW,  bars+1, BarTo))/point);   // нижняя и верхняя границы
   int UpEdge = (int)MathRound(iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, bars+1, BarTo))/point);   // диапазона на текущем ТФ в целых числах
	int Range=UpEdge-DnEdge+1; // Range - размер диапазона в пунктах от нижней до верхней его границы = коло-во членов массива PocArr
	ushort PocArr[];// массив распределения POC 
	ArrayResize(PocArr, Range);
	ArrayInitialize(PocArr, 0);
	int max_p_index=0; // индекс максимального члена массива
	for (int i=0; i<=bars; i++){// перебор диапазона по барам справа налево
		int Hi=(int)MathRound((High[BarTo+i])/point)-DnEdge; // H свечи
		int Lo=(int)MathRound((Low [BarTo+i])/point)-DnEdge; // L свечи (в целых числах)
		for (int p=Lo; p<=Hi; p++){// перебор свечи от L к H с шагом point=Point*10
		   PocArr[p]+=1;    // заполняем массив на каждом уровне, где попадается свеча
		   if (PocArr[p]>MaxPoc){
		      MaxPoc=PocArr[p]; 
		      max_p_index=p; 
		      MaxPocPrice=p*point; // сразу ищем максимальное значение POC и запоминаем цену с этим значением 
	   }  }  }
	for (int p=max_p_index; p<Range; p++)// шарим массив ввверх от первого максимального члена
	   if (PocArr[p]<MaxPoc) {MaxPocPrice=float(DnEdge+(max_p_index+p)*0.5)*point; break;} // в поисках центра POC   
   
   for (int p=0; p<Range; p++){ // от нижней до верхней границы гистограммы POC 
      float Y=(DnEdge+p)*point;
      int X=bar+PocArr[p];
      if (X>Bars-1) X=Bars-1;
      color Color=PocColor;
      //if (PocArr[p]==MaxPoc) Color=MaxPocColor; 
      LINE("POC="+S5(MaxPocPrice) ,bar+1,Y, X,Y, Color,0);   // максимум гистограммы выделяем красным
      }
   if (bar+MaxPoc<Bars) LINE("POC="+S5(MaxPocPrice) ,bar+1,MaxPocPrice, bar+MaxPoc,MaxPocPrice, MaxPocColor,0);   
      
   return(0);   
   }

// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 

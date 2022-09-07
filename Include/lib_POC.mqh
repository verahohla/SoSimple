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
      POC_SIMPLE(UpBorder,DnBorder,bar+LastPoc+1, bar+1, MaxPoc, MaxPocPrice); 
      //POC_COUNT(bar+LastPoc+1, bar+1, MaxPoc, MaxPocPrice); // расчет уровня и значения РОС в сформированном диапазоне
      if (MaxPoc>PocPer && bar+MaxPoc<Bars){
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
float POC_SIMPLE(float UpBorder, float DnBorder, int BarFrom, int BarTo, ushort& MaxPoc, float& MaxPocPrice){// расчет уровня и значения РОС за последние PocBars бар
   float   point=float(Point*10.0); // шаг сканирования диапазона (снизу вверх)
   if (BarFrom>Bars-1) BarFrom=Bars-1;
   int bars=BarFrom-BarTo;
   int shift=0, maxp=0;
   int UpEdge = int(UpBorder/point)+1;   // диапазона на текущем ТФ в целых числах
   int DnEdge = int(DnBorder/point);   // нижняя и верхняя границы
	int Range = UpEdge-DnEdge+1; // размер диапазона в пунктах от нижней до верхней его границы = коло-во членов массива PocArr
	int PocArr[];// массив распределения POC 
	ArrayResize(PocArr, Range);
	ArrayInitialize(PocArr, 0);
	MaxPoc=0; 
	for (int i=0; i<=bars; i++){// перебор диапазона по барам справа налево
		int Hi=int(High[i+BarTo]/point)+1; // H свечи
		int Lo=int(Low [i+BarTo]/point);   // L свечи (в целых числах)
		if (Hi<DnEdge || Lo>UpEdge) continue; // свеча за пределами диапазона
		if (Hi>UpEdge) Hi=UpEdge;
		if (Lo<DnEdge) Lo=DnEdge;
		for (int p=Lo; p<=Hi; p++){// перебор свечи от L к H с шагом point=Point*10
		   PocArr[p-DnEdge]+=1;    // заполняем массив на каждом уровне, где попадается свеча
		   if (PocArr[p-DnEdge]>MaxPoc){
		      MaxPoc=(ushort)PocArr[p-DnEdge]; // Maксимальное значение POC
		      maxp=p-DnEdge;  // Индекс максимального значения
		      MaxPocPrice=p*point; // Цена с этим значением 
	   }  }  }
	for (int p=maxp; p<Range; p++)// шарим массив в обратном направлении
	   if (PocArr[p]<MaxPoc) {MaxPocPrice=(int(maxp+p-1)/2+DnEdge)*point; break;} // в поисках центра POC  
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

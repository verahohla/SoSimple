#property copyright "www.hohla.ru"
#property link      "www.hohla.ru"
#property version    "191.114" // yym.mdd
#property strict // Указание компилятору на применение особого строгого режима проверки ошибок 
#property description "Индикатор горизонтального объема показывает распределение проторгованного объема на заданном интервале."
#property description "При Interval=0, индикатор пересчитывается ежедневно в 00:00,"
#property description "при Interval=1..5 - в заданный день недели."
#property description "CountDays=1..30 - глубина анализа в днях."
#property description "Длина линий пропорциональна проторгованному в данном диапазоне цен объему."
#property description "PipStep=10 - Шаг сканирования диапазона, чем он больше, тем быстрее и грубее подсчет."
#property description "Не имеет смысла устанавливать его менее 10 пунктов (значение по умолчанию)."
#property indicator_chart_window 
#property indicator_buffers 0


sinput string  II=" -  в х о д н ы е   п а р а м е т р ы   - "; 
extern int     Interval=1; // Interval=0..5 интервал (в днях) расчета объема
extern int     CountDays=3;// CountDays=1..30 количество дней, на котором расчитывается объем   
sinput string  III=" -  о т о б р а ж е н и е   г и с т о г р а м м ы  - ";
extern color   PocColor    = clrLightBlue; // цвет гистограммы распределения объема
extern color   MaxPocColor = clrRed;      // цвет зоны максимального объема 
extern int     PipStep = 10;  // PipStep=10..30 шаг сканирования диапазона (чем больше, тем грубее и быстрее расчет)
      
int bar,Per,CurDay;
string SYMBOL, Company="Alpari";
string ExpertName="iPOC"; // идентификатор графических объектов для их удаления

// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
int OnInit(){
   string iName="VolumeClaster";
   if (Interval<0 || Interval>5){ Alert("значение интервала расчета индикатора (Interval) должно быть от 0 до 5 включительно "); return(INIT_FAILED);}
   if (CountDays<1){ Alert("количество дней, на котором расчитывается объем (CountDays) должно быть положительно "); return(INIT_FAILED);} 
   iName=iName+"("+S0(CountDays)+") ";  //  
   IndicatorShortName(iName);
   SetIndexLabel(0,iName);
   Per=CountDays*24*60/Period();
   // CHART_SETTINGS(); // настройки вненшего вида графика 
   Print(" Init  ",__FILE__,": Interval=",Interval,", CountDays=",CountDays,", PipStep=",PipStep,"  ",Symbol(),Period());   
   ERROR_CHECK(__FUNCTION__);
   return(INIT_SUCCEEDED);  // (0)=Успешная инициализация. Результат выполнения функции OnInit() анализируется терминалом только если программа скомпилирована с использованием #property strict      
   }                    // НЕнулевой код возврата означает неудачную инициализацию и генерирует событие Deinit с кодом причины деинициализации REASON_INITFAILED
void start(){
   ushort MaxPoc;
   float MaxPocPrice;
   int UnCounted=Bars-IndicatorCounted()-2;
   for (bar=UnCounted; bar>0; bar--){ 
      if (Interval>0 && TimeDayOfWeek(Time[bar])!=Interval) continue; 
      if (TimeDay(Time[bar])==CurDay) continue; // начало нового дня
      CurDay=TimeDay(Time[bar]);
      float UpBorder=float(iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, Per+1, bar)));
      float DnBorder=float(iLow (NULL, 0, iLowest (NULL, 0, MODE_LOW,  Per+1, bar)));
      POC_SIMPLE(UpBorder,DnBorder,bar+Per, bar+1, MaxPoc, MaxPocPrice); 
      ERROR_CHECK(__FUNCTION__);
   }  } 
   
float POC_SIMPLE(float UpBorder, float DnBorder, int BarFrom, int BarTo, ushort& MaxPoc, float& MaxPocPrice){// расчет уровня и значения РОС за последние PocBars бар
   float   point=float(Point*PipStep); // шаг сканирования диапазона (снизу вверх)
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
		      MaxPoc=(ushort)PocArr[p-DnEdge]; 
		      maxp=p-DnEdge; 
		      MaxPocPrice=p*point; // сразу ищем максимальное значение POC и запоминаем цену с этим значением 
	   }  }  }
	for (int p=maxp; p<Range; p++)// шарим массив в обратном направлении
	   if (PocArr[p]<MaxPoc) {MaxPocPrice=(int(maxp+p-1)/2+DnEdge)*point; break;} // в поисках центра POC   
	// Draw POC lines
	for (int p=0; p<Range; p++){ // от нижней до верхней границы гистограммы POC 
      float Y=(DnEdge+p)*point;
      int X=bar+PocArr[p];
      if (X>Bars-1) X=Bars-1;
      LINE("POC="+S5(MaxPocPrice) ,bar+1,Y, X,Y, PocColor,0);   // максимум гистограммы выделяем красным
      }
   if (bar+MaxPoc<Bars) LINE("Up="+S4(UpBorder)+" Dn="+S4(DnBorder) ,bar+1,MaxPocPrice, bar+MaxPoc,MaxPocPrice, MaxPocColor,1);   
	return (MaxPocPrice);
   }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
void OnDeinit(const int reason){
	CLEAR_CHART();// удаляем все свои линии
	string text;
	switch(reason){ 
      case REASON_ACCOUNT:       text="Account was changed";   break; 
      case REASON_CHARTCHANGE:   text="Symbol or timeframe was changed";   break; 
      case REASON_CHARTCLOSE:    text="Chart was closed";      break; 
      case REASON_PARAMETERS:    text="Input-parameter was changed";       break; 
      case REASON_RECOMPILE:     text="Program "+__FILE__+" was recompiled";break; 
      case REASON_REMOVE:        text="Program "+__FILE__+" was removed from chart";   break; 
      case REASON_TEMPLATE:      text="New template was applied to chart"; break; 
      default:text=DoubleToStr(reason,0); 
      } 
   Print(__FUNCTION__,": ",text);   
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
uint ArrowCnt=0, TextCnt=0, LineCnt=0; // Индивидуальные счетчики для каждого типа объектов
string S5(double Data)  {return(DoubleToString(Data,int(MarketInfo(SYMBOL,MODE_DIGITS))));}
string S4(double Data)  {return(DoubleToString(Data,int(MarketInfo(SYMBOL,MODE_DIGITS))-1));}
string S2(double Data)  {return(DoubleToString(Data,2));}
string S1(double Data)  {return(DoubleToString(Data,1));}
string S0(double Data)  {return(DoubleToString(Data,0));}
float  N5(double Data)  {return(float(NormalizeDouble(Data,int(MarketInfo(SYMBOL,MODE_DIGITS)))));}
float  N4(double Data)  {return(float(NormalizeDouble(Data,int(MarketInfo(SYMBOL,MODE_DIGITS))-1)));}
int    N0(double Data)  {return(  int(NormalizeDouble(Data,0)));}
string BTIME(int      Shift)  {return(TimeToString(Time[Shift],TIME_DATE | TIME_MINUTES));}  // if (Shift>=Bars || Shift<=0) Print("STIME() Error: Shift=",Shift); return("");
string DTIME(datetime time)   {return(TimeToString(time,TIME_DATE | TIME_MINUTES));}
int    SHIFT(datetime time)   {return(iBarShift(NULL,0,time,false));}
string TIME (datetime ServerSeconds){// Серверное время в виде  День.Месяц/Час:Минута 
   string ServTime;
   int time;
   time=TimeDay(ServerSeconds);     if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0)+"."; // День.Месяц/Час:Минута
   time=TimeMonth(ServerSeconds);   if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0)+"/"; // 
   time=TimeHour(ServerSeconds);    if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0)+":"; // 
   time=TimeMinute(ServerSeconds);  if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0);     // 
   return (ServTime);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void CLEAR_CHART(){// Очистить график от своих объектов. ID-идентификатор линий, чтобы удалять с графика только их и не трогать остальные объекты 
	for (int i=ObjectsTotal()-1; i>=0; i--){
		if (StringFind(ObjectName(i),"\n",0) >-1) ObjectDelete(ObjectName(i)); // удаляются только свои объекты с символом переноса строки "\n"
	}  }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  	
string GRAPH_NAME(string txt, uint& Cnt){
   Cnt++; if (Cnt>4294967294) Print("GRAPH_NAME(): CNT>4294967295");
   string id="\n"+CODE(Cnt); //CODE(Cnt) идентификатор графического объекта с кодированием порядкового номера "CODE(Cnt)" для сокращения записи
   short MaxLen=63-(short)StringLen(id); // имя не должно превышать 63 символа
   if (StringLen(txt)>MaxLen) txt=StringSubstr(txt,0,MaxLen); // обрезаем по необходимости
   return (txt+id);  //
	}
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void A(string txt, double price, int bar0, color clr){// ГАЛОЧКА          
   string name=GRAPH_NAME(txt, TextCnt);
   ObjectCreate(0,name,OBJ_TEXT,0,Time[bar0],price-0*Point);
   ObjectSetString (0,name,OBJPROP_TEXT,txt+" > ");// текст
   ObjectSetString (0,name,OBJPROP_TOOLTIP,txt);   // текст всплывающей подсказки
   ObjectSetString (0,name,OBJPROP_FONT,"Arial"); // шрифт 
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,7);   // размер шрифта 
   ObjectSetDouble (0,name,OBJPROP_ANGLE,90);      // угол наклона текста 
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT);    //  привязка справа
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);     // цвет 
   ObjectSetInteger(0,name,OBJPROP_BACK,false);    // на переднем (false) или заднем (true) плане 
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true); // возможность выделить и перемещать
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void V(string txt, double price, int bar0, color clr){// ГАЛОЧКА          
   string name=GRAPH_NAME(txt, TextCnt);
   ObjectCreate(0,name,OBJ_TEXT,0,Time[bar0],price+0*Point);
   ObjectSetString (0,name,OBJPROP_TEXT," < "+txt);// текст
   ObjectSetString (0,name,OBJPROP_TOOLTIP,txt);   // текст всплывающей подсказки 
   ObjectSetString (0,name,OBJPROP_FONT,"Arial");  // шрифт 
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,7);    // размер шрифта 
   ObjectSetDouble (0,name,OBJPROP_ANGLE,90);      // угол наклона текста 
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);    //  привязка справа
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);     // цвет   
   ObjectSetInteger(0,name,OBJPROP_BACK,false);    // на переднем (false) или заднем (true) плане 
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true); // возможность выделить и перемещать
   }           
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void X(string txt, double price, int bar0, color clr){// КРЕСТИК        
   string name=GRAPH_NAME(txt, ArrowCnt);
   ObjectCreate    (0,name,OBJ_ARROW_STOP,0,Time[bar0],price+20*Point);  // 15*Point - поправка, т.к. крестик рисуется низковато 
   ObjectSetString (0,name,OBJPROP_TOOLTIP,txt);      // текст всплывающей подсказки
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,0);         // привязка
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);        // цвет 
   ObjectSetInteger(0,name,OBJPROP_BACK,false);       // на переднем (false) или заднем (true) плане 
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);          // размер
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true); // возможность выделить и перемещать
   } 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void LINE(string txt, int bar0, double price0, int bar1, double price1, color clr, uchar Width){// СИГНАЛ ШОРТ (линия сверху)
  string name=GRAPH_NAME(txt, LineCnt);
   ObjectCreate(0,name,OBJ_TREND,0, Time[bar0],price0, Time[bar1],price1); // потом от прошлого значения к новому
   ObjectSetString (0,name,OBJPROP_TOOLTIP,txt);         // текст всплывающей подсказки
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);           // цвет 
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);   // сплошная линия. STYLE_DASH-Штриховая, STYLE_DOT-пунктир 
   ObjectSetInteger(0,name,OBJPROP_WIDTH,Width);         // размер  
   ObjectSetInteger(0,name,OBJPROP_BACK,true);           // на переднем (false) или заднем (true) плане 
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);     // Луч не продолжается вправо 
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);    // возможность выделить и перемещать 
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
int xUP, xDN, xTime;
void X_LINES(int up, int dn, int clr){// отмена крестиками сиглалов UP и DN: (сигналы, смещение от H/L, цвет)
   if (xTime!=Time[bar]){// новый бар
      xTime=int(Time[bar]);
      xUP=100; // расстояние ближней линии 
      xDN=100; // к текущей цене (в пунктах).
      }
   if (up<=0) {xUP+=40; X("UP",Low [bar]-xUP*Point,bar,clr);}
   if (dn<=0) {xDN+=40; X("DN",High[bar]+xDN*Point,bar,clr);} 
   }
       	
#define BITS  71 // разрядность "новой" системы исчисления
string CODE(ulong Data){  // КОДИРОВАНИЕ ОЧ ДЛИННОГО ЧИСЛА В ГРАФИЧЕСКИЕ СИМВОЛЫ вида "f@j6[w2" для сокращения записи
   string Result="", Sym;
   ulong Integer;
   char Part=0;
   while (Part>0 || Data>0){
      Integer=Data/BITS;      // целая часть от деления на разрядность
      Part=char(Data-Integer*BITS);// остаток от деления
      Data=Integer;
      if (Data==0 && Part==0) break;
      Sym=StringSetChar(" ", 0, ushort(Part+48)); // декодирование цифр 0..92 в символы, эквивалентные ASCII кодам с 48 до 122 
      Sym=ASCII(Part);
      Result=Sym+Result; //    
      }  
   return (Result); // на выходе получаем аброкадабру вида "f@j6[w2"
   }   
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
ulong DECODE(string SymCode){ // ВОССТАНОВЛЕНИЕ ЧИСЛА ИЗ ГРАФИЧЕСКИХ СИМВОЛОВ
   int Lengh=StringLen(SymCode); 
   char Char=0;
   ulong cnt=1, Result=0;
   for (int i=Lengh-1; i>=0; i--){  
      Char=DE_ASCII(StringSubstr(SymCode,i,1));
      Result+=Char*cnt; // Print(cnt," Sym=",StringSubstr(SymCode,i, 1)," Char=",Char," Result=", Result);
      cnt*=(BITS);
      }  
   return(Result);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
char DE_ASCII(string Sym){
   for (char Code=0; Code<BITS; Code++) if (ASCII(Code)==Sym) return (Code); 
   return (-1);
   }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
string ASCII(char Code){// ФОРМИРОВАНИЕ СОБСТВЕННОЙ ТАБЛИЦЫ БЕЗ ЗАПРЕЩЕННЫХ СИМВОЛОВ \/?...
   switch (Code){ 
      case  0: return("0");     
      case  1: return("1");     
      case  2: return("2");     
      case  3: return("3");     
      case  4: return("4");     
      case  5: return("5");     
      case  6: return("6");     
      case  7: return("7");     
      case  8: return("8");     
      case  9: return("9");     
      
      case  10: return("a");     
      case  11: return("b");     
      case  12: return("c");     
      case  13: return("d");     
      case  14: return("e");     
      case  15: return("f");     
      case  16: return("g");     
      case  17: return("h");     
      case  18: return("i");     
      case  19: return("j");     
      
      case  20: return("k");     
      case  21: return("l");     
      case  22: return("m");     
      case  23: return("n");     
      case  24: return("o");     
      case  25: return("p");     
      case  26: return("q");     
      case  27: return("r");     
      case  28: return("s");     
      case  29: return("t");     
      
      case  30: return("u");     
      case  31: return("v");     
      case  32: return("w");     
      case  33: return("x");     
      case  34: return("y");     
      case  35: return("z");     
      case  36: return("A");     
      case  37: return("B");     
      case  38: return("C");     
      case  39: return("D");     
      
      case  40: return("E");     
      case  41: return("F");     
      case  42: return("G");     
      case  43: return("H");     
      case  44: return("I");     
      case  45: return("J");     
      case  46: return("K");     
      case  47: return("L");     
      case  48: return("M");     
      case  49: return("N");     
      
      case  50: return("O");     
      case  51: return("P");     
      case  52: return("Q");     
      case  53: return("R");     
      case  54: return("S");     
      case  55: return("T");     
      case  56: return("U");     
      case  57: return("V");     
      case  58: return("W");     
      case  59: return("X");     
      
      case  60: return("Y");     
      case  61: return("Z");     
      case  62: return("_");     
      case  63: return("-");     
      case  64: return("+");     
      case  65: return("@");     
      case  66: return("#");     
      case  67: return("$");     
      case  68: return("~");   // терминал не любит символ "%"  
      case  69: return("^");     
      case  70: return("&");     
      case  71: return("№");     
      default : return ("?"); 
   }  }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
void ERROR_CHECK(string ErrTxt){ // Проверка проведения операций с ордерами. Возвращает необходимость повтора торговой операции
   int err=GetLastError(); //
   if (err==0) return; // Ошибок нет. Повтор не нужен
   ErrTxt=ErrTxt+": "+ErrorDescription(err)+"! err-"+S0(err);
   Alert(ErrTxt);                 
   }
string ErrorDescription(int error_code){
   string error_string;
   switch(error_code){
      //--- codes returned from trade server
      case 0:   error_string="no error";                                                   break;
      case 1:   error_string="no error, trade conditions not changed";                     break;
      case 2:   error_string="common error";                                               break;
      case 3:   error_string="invalid trade parameters";                                   break;
      case 4:   error_string="trade server is busy";                                       break;
      case 5:   error_string="old version of the client terminal";                         break;
      case 6:   error_string="no connection with trade server";                            break;
      case 7:   error_string="not enough rights";                                          break;
      case 8:   error_string="too frequent requests";                                      break;
      case 9:   error_string="malfunctional trade operation (never returned error)";       break;
      case 64:  error_string="account disabled";                                           break;
      case 65:  error_string="invalid account";                                            break;
      case 128: error_string="trade timeout";                                              break;
      case 129: error_string="invalid price";                                              break;
      case 130: error_string="invalid stops";                                              break;
      case 131: error_string="invalid trade volume";                                       break;
      case 132: error_string="market is closed";                                           break;
      case 133: error_string="trade is disabled";                                          break;
      case 134: error_string="not enough money";                                           break;
      case 135: error_string="price changed";                                              break;
      case 136: error_string="off quotes";                                                 break;
      case 137: error_string="broker is busy (never returned error)";                      break;
      case 138: error_string="requote";                                                    break;
      case 139: error_string="order is locked";                                            break;
      case 140: error_string="long positions only allowed";                                break;
      case 141: error_string="too many requests";                                          break;
      case 145: error_string="modification denied because order is too close to market";   break;
      case 146: error_string="trade context is busy";                                      break;
      case 147: error_string="expirations are denied by broker";                           break;
      case 148: error_string="amount of open and pending orders has reached the limit";    break;
      case 149: error_string="hedging is prohibited";                                      break;
      case 150: error_string="prohibited by FIFO rules";                                   break;
      //--- mql4 errors
      case 4000: error_string="no error (never generated code)";                           break;
      case 4001: error_string="wrong function pointer";                                    break;
      case 4002: error_string="array index is out of range";                               break;
      case 4003: error_string="no memory for function call stack";                         break;
      case 4004: error_string="recursive stack overflow";                                  break;
      case 4005: error_string="not enough stack for parameter";                            break;
      case 4006: error_string="no memory for parameter string";                            break;
      case 4007: error_string="no memory for temp string";                                 break;
      case 4008: error_string="non-initialized string";                                    break;
      case 4009: error_string="non-initialized string in array";                           break;
      case 4010: error_string="no memory for array\' string";                              break;
      case 4011: error_string="too long string";                                           break;
      case 4012: error_string="remainder from zero divide";                                break;
      case 4013: error_string="zero divide";                                               break;
      case 4014: error_string="unknown command";                                           break;
      case 4015: error_string="wrong jump (never generated error)";                        break;
      case 4016: error_string="non-initialized array";                                     break;
      case 4017: error_string="dll calls are not allowed";                                 break;
      case 4018: error_string="cannot load library";                                       break;
      case 4019: error_string="cannot call function";                                      break;
      case 4020: error_string="expert function calls are not allowed";                     break;
      case 4021: error_string="not enough memory for temp string returned from function";  break;
      case 4022: error_string="system is busy (never generated error)";                    break;
      case 4023: error_string="dll-function call critical error";                          break;
      case 4024: error_string="internal error";                                            break;
      case 4025: error_string="out of memory";                                             break;
      case 4026: error_string="invalid pointer";                                           break;
      case 4027: error_string="too many formatters in the format function";                break;
      case 4028: error_string="parameters count is more than formatters count";            break;
      case 4029: error_string="invalid array";                                             break;
      case 4030: error_string="no reply from chart";                                       break;
      case 4050: error_string="invalid function parameters count";                         break;
      case 4051: error_string="invalid function parameter value";                          break;
      case 4052: error_string="string function internal error";                            break;
      case 4053: error_string="some array error";                                          break;
      case 4054: error_string="incorrect series array usage";                              break;
      case 4055: error_string="custom indicator error";                                    break;
      case 4056: error_string="arrays are incompatible";                                   break;
      case 4057: error_string="global variables processing error";                         break;
      case 4058: error_string="global variable not found";                                 break;
      case 4059: error_string="function is not allowed in testing mode";                   break;
      case 4060: error_string="function is not confirmed";                                 break;
      case 4061: error_string="send mail error";                                           break;
      case 4062: error_string="string parameter expected";                                 break;
      case 4063: error_string="integer parameter expected";                                break;
      case 4064: error_string="double parameter expected";                                 break;
      case 4065: error_string="array as parameter expected";                               break;
      case 4066: error_string="requested history data is in update state";                 break;
      case 4067: error_string="internal trade error";                                      break;
      case 4068: error_string="resource not found";                                        break;
      case 4069: error_string="resource not supported";                                    break;
      case 4070: error_string="duplicate resource";                                        break;
      case 4071: error_string="cannot initialize custom indicator";                        break;
      case 4072: error_string="cannot load custom indicator";                              break;
      case 4073: error_string="no history data";                                           break;
      case 4074: error_string="not enough memory for history data";                        break;
      case 4075: error_string="not enough memory for indicator";                           break;
      case 4099: error_string="end of file";                                               break;
      case 4100: error_string="some file error";                                           break;
      case 4101: error_string="wrong file name";                                           break;
      case 4102: error_string="too many opened files";                                     break;
      case 4103: error_string="cannot open file";                                          break;
      case 4104: error_string="incompatible access to a file";                             break;
      case 4105: error_string="no order selected";                                         break;
      case 4106: error_string="unknown symbol";                                            break;
      case 4107: error_string="invalid price parameter for trade function";                break;
      case 4108: error_string="invalid ticket";                                            break;
      case 4109: error_string="trade is not allowed in the expert properties";             break;
      case 4110: error_string="longs are not allowed in the expert properties";            break;
      case 4111: error_string="shorts are not allowed in the expert properties";           break;
      case 4200: error_string="object already exists";                                     break;
      case 4201: error_string="unknown object property";                                   break;
      case 4202: error_string="object does not exist";                                     break;
      case 4203: error_string="unknown object type";                                       break;
      case 4204: error_string="no object name";                                            break;
      case 4205: error_string="object coordinates error";                                  break;
      case 4206: error_string="no specified subwindow";                                    break;
      case 4207: error_string="graphical object error";                                    break;
      case 4210: error_string="unknown chart property";                                    break;
      case 4211: error_string="chart not found";                                           break;
      case 4212: error_string="chart subwindow not found";                                 break;
      case 4213: error_string="chart indicator not found";                                 break;
      case 4220: error_string="symbol select error";                                       break;
      case 4250: error_string="notification error";                                        break;
      case 4251: error_string="notification parameter error";                              break;
      case 4252: error_string="notifications disabled";                                    break;
      case 4253: error_string="notification send too frequent";                            break;
      case 4260: error_string="ftp server is not specified";                               break;
      case 4261: error_string="ftp login is not specified";                                break;
      case 4262: error_string="ftp connect failed";                                        break;
      case 4263: error_string="ftp connect closed";                                        break;
      case 4264: error_string="ftp change path error";                                     break;
      case 4265: error_string="ftp file error";                                            break;
      case 4266: error_string="ftp error";                                                 break;
      case 5001: error_string="too many opened files";                                     break;
      case 5002: error_string="wrong file name";                                           break;
      case 5003: error_string="too long file name";                                        break;
      case 5004: error_string="cannot open file";                                          break;
      case 5005: error_string="text file buffer allocation error";                         break;
      case 5006: error_string="cannot delete file";                                        break;
      case 5007: error_string="invalid file handle (file closed or was not opened)";       break;
      case 5008: error_string="wrong file handle (handle index is out of handle table)";   break;
      case 5009: error_string="file must be opened with FILE_WRITE flag";                  break;
      case 5010: error_string="file must be opened with FILE_READ flag";                   break;
      case 5011: error_string="file must be opened with FILE_BIN flag";                    break;
      case 5012: error_string="file must be opened with FILE_TXT flag";                    break;
      case 5013: error_string="file must be opened with FILE_TXT or FILE_CSV flag";        break;
      case 5014: error_string="file must be opened with FILE_CSV flag";                    break;
      case 5015: error_string="file read error";                                           break;
      case 5016: error_string="file write error";                                          break;
      case 5017: error_string="string size must be specified for binary file";             break;
      case 5018: error_string="incompatible file (for string arrays-TXT, for others-BIN)"; break;
      case 5019: error_string="file is directory, not file";                               break;
      case 5020: error_string="file does not exist";                                       break;
      case 5021: error_string="file cannot be rewritten";                                  break;
      case 5022: error_string="wrong directory name";                                      break;
      case 5023: error_string="directory does not exist";                                  break;
      case 5024: error_string="specified file is not directory";                           break;
      case 5025: error_string="cannot delete directory";                                   break;
      case 5026: error_string="cannot clean directory";                                    break;
      case 5027: error_string="array resize error";                                        break;
      case 5028: error_string="string resize error";                                       break;
      case 5029: error_string="structure contains strings or dynamic arrays";              break;
      default:   error_string="unknown error";
     }
//---
   return(error_string);
  }

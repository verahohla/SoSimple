#property copyright "Hohla"
#property link      "http://www.hohla.ru"
#property version   "2.00"
#property strict
#property description "Alerts" 
#property description "В настоящий момент в индикатор встроены несколько ZigZag с различными алгоритмами" 

int LotDigits, DIGITS, CurHour;
string   Sym;
double   UpLevel, DnLevel, MinLot, TickVal, MaxDayBalance, CanTrade=1, StopOfBuy=0, StopOfSell=0;
datetime BarTime;

struct ALERT{
   float Price;
   int   Dir;
   string Sym;
   } Alrt[];

#include <stderror.mqh>
#include <stdlib.mqh>

int OnInit(){//| Expert initialization function 
   ArrayResize(Alrt,2); // зададим для начала размерность массива под два алерта
   return(INIT_SUCCEEDED);
   }
   
void OnTick(){//| Expert tick function 
   int Alerts=ArraySize(Alrt);
   // check current alerts
   for (int i=0; i<Alerts; i++){
      if (Alrt[i].Price==0) continue;
      if (Alrt[i].Dir>0){  // алерт над ценой
         if (MarketInfo(Alrt[i].Sym,MODE_ASK)>=Alrt[i].Price){
            MSG(Sym+" ASK >= "+DoubleToStr(Alrt[i].Price,DIGITS)); 
            Alrt[i].Price=0;} // алерт при достижении цены отложенного ордера
      }else{               // алерт под ценой
         if (MarketInfo(Alrt[i].Sym,MODE_BID)<=Alrt[i].Price){
            MSG(Sym+" BID <= "+DoubleToStr(Alrt[i].Price,DIGITS)); 
            Alrt[i].Price=0;} // 
      }  }
   // проверка на необходимость установки нового алерта
   for(int Ord=0; Ord<OrdersTotal(); Ord++){ // перебор всех отложников
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)==false || OrderMagicNumber()!=0) continue;   
      if (OrderType()<2 || OrderType()>5) continue; // рассматриваются только отложники
      int free=-1;
      for (int i=0; i<Alerts; i++){ 
         if (OrderOpenPrice()==Alrt[i].Price){// для данной цены алерт уже есть
            free=-2;// флаг прекращения цикла перебора ордеров
            break;} 
         if (Alrt[i].Price==0)  free=i; // свободное место для нового алерта
         }
      if (free==-2) continue; // для данного ордера алерт уже есть, переходим к следующему    
      if (free<0){
         Alerts++;
         ArrayResize(Alrt, Alerts);
         free=Alerts;
         }    
      Alrt[free].Price=OrderOpenPrice(); 
      Alrt[free].Sym=OrderSymbol();
      if (OrderOpenPrice()>MarketInfo(OrderSymbol(),MODE_BID)) 
         Alrt[free].Dir=1; // алерт над ценой
      else                                   
         Alrt[free].Dir=-1;// алерт под ценой 
   }  }       
   
void MSG(string text){
   SendNotification(TimeToStr(TimeCurrent(),TIME_MINUTES)+" "+text);
   } 

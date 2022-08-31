#property copyright "Hohla"
#property link      "http://www.hohla.ru"
#property version   "2.00"
#property strict

input int      Risk=1;        // риск, устанавливаемый автоматом
input int      DayDD=2;       // блокировка торговли при превышении
input int      ATR_Period=20; // Период ATR
input double   StopLoss=1;    // кол-во ATR для стоп лосса 
input double   TakeProfit=3;  // кол-во ATR для тейк профита  
// сразу после появления отложника автоматом ставятся стоп на расстоянии АТР(60) и профит 3хАТР с заданным риском.
// данный уровень запоминается, т.е. после удаления ордера при достижении ценой данного уровня выдается алерт.
//  
int LotDigits, DIGITS, CurHour;
string   Sym;
double   UpLevel, DnLevel, MinLot, TickVal, MaxDayBalance, CanTrade=1, StopOfBuy=0, StopOfSell=0;
datetime BarTime;


#include <stderror.mqh>
#include <stdlib.mqh>

int OnInit(){//| Expert initialization function 
   EventSetTimer(60);// запускаем таймер
   if (MarketInfo(Symbol(),MODE_LOTSTEP)<0.1) LotDigits=2; else LotDigits=1;
   TickVal=MarketInfo(Symbol(),MODE_TICKVALUE);
   MinLot =MarketInfo(Symbol(),MODE_MINLOT);
   CurHour=Hour();
   GlobalVariableSet("LastProfit",0); // обнуляем значение, чтобы не было ложных сообщений при запуске 
   GlobalVariableSet("InitBalance",AccountBalance());
   return(INIT_SUCCEEDED);
   }
   
void OnTick(){//| Expert tick function 
   int Ord, Error, OrdType; 
   bool SetOrder=false;
   string Order;
   double Stop, Lot=0, NewStop=0, NewProf=0, CurOpen, CurStop,CurProf;
   if (Time[0]!=BarTime){// Сравниваем время открытия текущего(0) бара 
      BarTime=Time[0];
      }  
   for(Ord=0; Ord<OrdersTotal(); Ord++){// перебераем все открытые и отложенные ордера всех экспертов счета Ролловеры (OrderType=6) не смотрим.
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)==true && OrderMagicNumber()==0 && OrderSymbol()==Symbol()){
         OrdType=OrderType();
         if (OrdType==6) continue; // ролловеры не нужны
         CurOpen=OrderOpenPrice();
         CurStop=OrderStopLoss();
         CurProf=OrderTakeProfit();
         Sym=OrderSymbol();
         DIGITS=(int)MarketInfo(Sym,MODE_DIGITS);
         switch(OrdType){
            case OP_BUY:      Order="Buy";         NewStop=CurOpen-ATR()*StopLoss; NewProf=CurOpen+ATR()*TakeProfit;    break;
            case OP_SELL:     Order="Sell";        NewStop=CurOpen+ATR()*StopLoss; NewProf=CurOpen-ATR()*TakeProfit;    break;
            case OP_BUYSTOP:  Order="BuyStop";     NewStop=CurOpen-ATR()*StopLoss; NewProf=CurOpen+ATR()*TakeProfit;    break;
            case OP_BUYLIMIT: Order="BuyLimit";    NewStop=CurOpen-ATR()*StopLoss; NewProf=CurOpen+ATR()*TakeProfit;    break;
            case OP_SELLSTOP: Order="SellStop";    NewStop=CurOpen+ATR()*StopLoss; NewProf=CurOpen-ATR()*TakeProfit;    break;
            case OP_SELLLIMIT:Order="SellLimit";   NewStop=CurOpen+ATR()*StopLoss; NewProf=CurOpen-ATR()*TakeProfit;    break;
            }
         if (!CanTrade){// перебор по убыткам, все ордера закрываем
            switch(OrdType){
               case OP_BUY:  SetOrder=OrderClose(OrderTicket(),OrderLots(),Bid,5,Red);
               case OP_SELL: SetOrder=OrderClose(OrderTicket(),OrderLots(),Ask,5,Red);
               default:      SetOrder=OrderDelete(OrderTicket()); 
               }               
            Error=GetLastError();   if (Error>0) Print("ERROR, while Delete ",Order,": ",ErrorDescription(Error)); 
            MSG("DayDD Exceed "+DoubleToStr(DayDD,1)+"%, Trading Disable"); 
            return;
            }
         if (CurStop==0){    // первый стоп выставляется автоматом
            CurStop=NewStop; // чтобы его можно было передвинуть на нужное значение
            CurProf=NewProf;
            }
         // Если рыночные ордера без стопов, ставим:
         SetOrder=false; 
         if (OrdType==OP_SELL){
            if (OrderStopLoss()==0) SetOrder=OrderModify(OrderTicket(),OrderOpenPrice(),CurStop,CurProf,0,Blue); // в ордерах без стопа ставим сразу стоп в АТР
            if (OrderStopLoss()!=StopOfSell) {// если стоп поменялся, сообщаем текущий риск
               StopOfSell=OrderStopLoss(); 
               MSG(Order+"/"+DoubleToStr(OrderLots()*((OrderOpenPrice()-OrderStopLoss())/Point()*TickVal)/AccountBalance()*100,1)+"%");  
            }  } 
         if (OrdType==OP_BUY){
            if (OrderStopLoss()==0) SetOrder=OrderModify(OrderTicket(),OrderOpenPrice(),CurStop,CurProf,0,Blue); // в ордерах без стопа ставим сразу стоп в АТР 
            if (OrderStopLoss()!=StopOfBuy){// если стоп поменялся, сообщаем текущий риск
               StopOfBuy=OrderStopLoss(); 
               MSG(Order+"/"+DoubleToStr(OrderLots()*((OrderStopLoss()-OrderOpenPrice())/Point()*TickVal)/AccountBalance()*100,1)+"%");  
            }  }
         if (SetOrder){   
            Error=GetLastError();   
            if (Error>0) Print("ERROR, while Modify ",Order,": ",ErrorDescription(Error));
            } 
         if (OrdType<2) continue;  // рыночные ордера больше не трогаем, в отложниках меняем риск
         Stop=MathAbs(CurOpen-CurStop); // для подсчета риска нужен стоп 
         if (Stop>0) Lot = NormalizeDouble(AccountBalance()*Risk*0.01 / (Stop/Point()*TickVal), LotDigits);
         if (Lot<MinLot) Lot=MinLot;
         SetOrder=false;
         if (Lot!=OrderLots()|| OrderStopLoss()==0){ // корректируем размер позы если риск не равен 1%
            SetOrder=OrderDelete(OrderTicket()); // true - флаг успешного удаления ордера
            Error=GetLastError();   if (Error>0) Print("ERROR, while Delete ",Order,": ",ErrorDescription(Error)); 
            }
         if (!SetOrder) continue; // если ничего не удаляли, ставить тоже нечего
         SetOrder=OrderSend(Symbol(),OrdType, Lot, CurOpen, 3, CurStop, CurProf, Order ,0,0,CLR_NONE); 
         Error=GetLastError();  if (Error>0) Print("Error, while Set ",Order,": ",ErrorDescription(Error));
         if (CurStop!=NewStop) // отправляем сабж только на окончательно выставленный ордер
            MSG(
            Symbol()+" Set "+Order+" "+
            DoubleToStr(CurOpen,DIGITS-1)+"/"+
            DoubleToStr(CurStop,DIGITS-1)+"/"+
            DoubleToStr(Lot*(Stop/Point()*TickVal)/AccountBalance()*100,1)+"%"); 
   }  }  }     
   

void OnTimer(){// Timer function 
   double DayProfit=0, MaxDayDD=0, LastProfit, InitBalance=0;
   if (CurHour>Hour()){ // новый день,
      GlobalVariableSet("InitBalance",AccountBalance());  // фиксируем значение баланса в глобал, чтобы можно было пользовать с разных графиков
      if (CanTrade==false) MSG("Trading Enable");
      CanTrade=true; // разрешаем торговлю
      Print("New DAY:  CurHour=",CurHour," CanTrade=",CanTrade," InitBalance=",InitBalance," DayProfit=",DayProfit);
      MaxDayBalance=AccountBalance();
      }
   CurHour=Hour(); 
   LastProfit=GlobalVariableGet("LastProfit"); // чтобы не было дублирования сообщения, если эксперт установлен на разных графиках 
   InitBalance=GlobalVariableGet("InitBalance"); // сохраняем LastProfit и InitBalance в глобалы
   if (InitBalance==0) return; 
   DayProfit=(AccountBalance()-InitBalance)/InitBalance*100; // процентное изменение баланса за сегодняшний день
   if (AccountBalance()>MaxDayBalance) MaxDayBalance=AccountBalance();
   if (MaxDayBalance>0) MaxDayDD=(MaxDayBalance-AccountBalance())/MaxDayBalance*100;
   if (MaxDayDD>=DayDD) CanTrade=false; // запрет торговли при превышении просадки
   if (DayProfit!=LastProfit && InitBalance!=AccountBalance()){ // 
      string profit;
      if (DayProfit>0) profit=" DayProfit="; else profit=" DayLoss=";
      MSG(profit+DoubleToStr(DayProfit,1)+"% DD="+DoubleToStr(MaxDayDD,1)+"%");
      GlobalVariableSet("LastProfit",DayProfit);
      Print("CurHour=",CurHour," CanTrade=",CanTrade," InitBalance=",InitBalance," DayProfit=",DayProfit," LastProfit=",LastProfit);
   }  }
   
     
void MSG(string text){
   SendNotification(TimeToStr(TimeCurrent(),TIME_MINUTES)+" "+text);
   } 
double ATR(){
   return(iATR(Sym,0,ATR_Period,1));
   }   
bool CHECK_MARGIN(int Ord, double lots){   
   if (AccountFreeMarginCheck(Sym,Ord,lots)<0){  
      Print("Not enough money. Error code=",GetLastError());
      return(false); 
      } 
   return(true); 
   }     



void OnDeinit(const int reason){//| Expert deinitialization function  
   EventKillTimer(); //--- destroy timer
   }
    
double OnTester(){// Tester function 
   double ret=0.0;
   return(ret);
   }
   
void OnChartEvent(const int id,  //| ChartEvent function 
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
   {
   //---
   }

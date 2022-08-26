#define  TrgAmount   5  // кол-во одновременно отслеживаемых треугольников
#define  PicAmount   10 // кол-во пиков в треугольнике
int PicInterval;
 
struct TRG_PRM{
   float    P[PicAmount];       // price
   float    Frnt[PicAmount];    // передний фронт пика 
   float    Back[PicAmount];    // задний фронт пика
   datetime T[PicAmount];
   char     Phase;   // стадия NONE, START, CONFIRM, BREAK 
   char     Dir;
   uchar    Cnt;     // размерность треугольника (кол-во сформированных пиков
   uchar    Id;   // номер пика первой вершины формации в структуре PICS 
   }M[TrgAmount],W[TrgAmount];   
   
void TRG_INIT(){
   for (uchar i=0; i<TrgAmount; i++){
      W[i].Phase=0;
      M[i].Phase=0;}
   PicInterval=3600*24*5;  // минимальный  интрервал между макушками, чтобы не отбирались движения длинной в год
   }
   
void TRIAG(uchar f, uchar Cnt){
   if (F[f].Pwr!=2)     return; // не первый уровень
   if (F[f].Brk!=TOUCH) return; // статус пика д.б. "с касанием". Не "CLEAR" и не "BROKEN" 
   if (Cnt<2)           return; // для нового пика не было касаний, т.е. никаких изменений в треугольние не произошло 
   F[f].TRG.Cnt++;   // Статус - кол-во вершин в треугольнике,
   if (F[f].TRG.Cnt==2){   // начало формирования треугольника - вторая вершина 
      
      F[f].TRG.Frnt=F[f].Frnt;      // передний фронт второго пика равен заднему первого пика (Первого Уровня)
      F[f].TRG.T=F[f].T;  // время первого пика = время пика Первого Уровня
      return;
      }
   int Shift=iBarShift(NULL,0,F[f].TRG.T,false); // сдвиг прошлого последнего пика относительно нового
   F[f].TRG.T=Time[bar+PicPer];    // время нового пика 
     
   F[f].TRG.Frnt1=F[f].TRG.Frnt;
   if (Dir>0){
      F[f].TRG.Frnt=float(Low [iLowest (NULL,0,MODE_LOW ,Shift-(bar+PicPer),bar+PicPer)]);
      if (F[f].TRG.Frnt<F[f].TRG.Frnt1) return;
   }else{
      F[f].TRG.Frnt=float(High[iHighest(NULL,0,MODE_HIGH,Shift-(bar+PicPer),bar+PicPer)]);   // Передний Фронт уровня 
      if (F[f].TRG.Frnt>F[f].TRG.Frnt1) return;
      }
   
   

   uchar FreeW=-1, FreeM=-1, MinW, MinM;
   float MinSizeW=999999, MinSizeM=999999;
   // поиск пробитых среди текущих формаций
   if (Dir>0){
      for (uchar i=0; i<TrgAmount; i++){ // проверка формации "M"
         if (M[i].Phase==0) {FreeM=i; continue;}
         if (M[i].P[0]-M[i].Back[0]<MinSizeM) {MinSizeM=M[i].P[0]-M[i].Back[0]; MinM=i;} // поиск минимальной формации М
         if (New-M[i].P[0]>Atr.Lim){// пробой M формации
            M[i].Phase=0;
            FreeM=i;}
         if (MathAbs(New-M[i].P[0])<Atr.Lim){ }// очередное совпадение
                 
      }  }  
   else{
      for (uchar i=0; i<TrgAmount; i++){ // проверка формации "W"
         if (W[i].Phase==0) {FreeW=i; continue;}
         if (W[i].Back[0]-W[i].P[0]<MinSizeW) {MinSizeW=W[i].Back[0]-W[i].P[0]; MinW=i;} // поиск минимальной формации W
         if (W[i].P[0]-New>Atr.Lim){ // пробой W формации
            W[i].Phase=0;
            FreeW=i;}
      }  }
   
   if (Cnt<2) return; // отскоков небыло
   
   // формирование новой формации
   if (Cnt==2 && F[f].Pwr==2){ // первое касание "Первого" уровня
      if (Dir>0){
         M[FreeM].Phase=1;
         M[FreeM].Cnt=Cnt;
         M[FreeM].P[0]=F[f].P;
         M[FreeM].P[1]=F[n].P;
         M[FreeM].Frnt[1]=F[n].Frnt;
      }  }    
      
      
   // M[2].P[4]=99;
   
   }   
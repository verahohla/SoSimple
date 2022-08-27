    
//struct TRG_PRM{
//   float    P[PicAmount];       // price
//   float    Frnt[PicAmount];    // передний фронт пика 
//   float    Back[PicAmount];    // задний фронт пика
//   datetime T[PicAmount];
//   char     Phase;   // стадия NONE, START, CONFIRM, BREAK 
//   char     Dir;
//   uchar    Cnt;     // размерность треугольника (кол-во сформированных пиков
//   uchar    Id;   // номер пика первой вершины формации в структуре PICS 
//   }M[TrgAmount],W[TrgAmount];   
   
//void TRG_INIT(){
//   for (uchar i=0; i<TrgAmount; i++){
//      W[i].Phase=0;
//      M[i].Phase=0;}
//   PicInterval=3600*24*5;  // минимальный  интрервал между макушками, чтобы не отбирались движения длинной в год
//   }
   
void TRIAG(uchar f, char Cnt){
   if (F[f].Pwr!=2)     return; // не первый уровень
   if (F[f].Brk!=TOUCH) return; // статус пика д.б. "с касанием". Не "CLEAR" и не "BROKEN" 
   if (Cnt<2)           return; // для нового пика не было касаний, т.е. никаких изменений в треугольние не произошло 
   if (F[f].TRG.Cnt==1){   // начало формирования треугольника - у треугольника пока была только одна вершина 
      F[f].TRG.P[1]=F[f].P;  // пик треугольника, лежащий на горизонтальной оси (первый - пик Первого Уровня)
      F[f].TRG.T[1]=F[f].T;  // время первого пика = время пика Первого Уровня
      F[f].TRG.H[1]=F[f].Frnt;// пик треугольника, лежащий на наклонной оси
      F[f].TRG.HT[1]=F[f].ExT;// время ближайшего превосходящего пика
      }
   
   int Shift=iBarShift(NULL,0,F[f].TRG.T[F[f].TRG.Cnt],false); int Tmp=Shift;// сдвиг прошлого последнего пика относительно нового
   if (Shift-bar-PicPer>FltLen)    // если новый пик значительно удален от предыдущего, добавляем в новый член. Иначе, обновляем предыдущее значение 
      F[f].TRG.Cnt++;   // Статус - кол-во вершин в треугольнике  
   char i=F[f].TRG.Cnt; // кол-во вершин треугольника (1,2,....,21)
   
   F[f].TRG.T[i]=Time[bar+PicPer];    // время нового пика 
   F[f].TRG.P[i]=New; // значение нового пика горизонтальной оси
   
   if (Dir>0){
      Shift=iLowest (NULL,0,MODE_LOW ,Shift-(bar+PicPer),bar+PicPer);
      F[f].TRG.H[i]=float(Low [Shift]);   // пик наклонной оси
      if (F[f].TRG.H[i]<F[f].TRG.H[i-1]){ // новый фронт ниже предыдущего, 
         F[f].TRG.Cnt=0;                  // треугольник нарушен
         return;
      }  }
   else{
      Shift=iHighest(NULL,0,MODE_HIGH,Shift-(bar+PicPer),bar+PicPer);
      F[f].TRG.H[i]=float(High[Shift]);    
      if (F[f].TRG.H[i]>F[f].TRG.H[i-1]){ // новый фронт выше предыдущего 
         F[f].TRG.Cnt=0;
         return;
      }  }
   F[f].TRG.HT[i]=Time[Shift]; // время нового пика на наклонной оси
   if (F[f].TRG.Cnt>2){
      LINE("TRG", SHIFT(F[f].TRG.T[1]),F[f].TRG.P[1], bar+PicPer, New,clrLightGreen,0); 
      LINE("TRG", SHIFT(F[f].TRG.HT[2]),F[f].TRG.H[2], SHIFT(F[f].TRG.HT[F[f].TRG.Cnt]), F[f].TRG.H[F[f].TRG.Cnt],clrRoyalBlue,0);
      for (char j=1; j<=F[f].TRG.Cnt; j++) A("F"+S0(j)+" "+S0(Tmp)+"-"+S0(bar+PicPer), F[f].TRG.P[j], SHIFT(F[f].TRG.T[j]), clrBlack);
      }     

   
   
   
//   uchar FreeW=-1, FreeM=-1, MinW, MinM;
//   float MinSizeW=999999, MinSizeM=999999;
//   // поиск пробитых среди текущих формаций
//   if (Dir>0){
//      for (uchar i=0; i<TrgAmount; i++){ // проверка формации "M"
//         if (M[i].Phase==0) {FreeM=i; continue;}
//         if (M[i].P[0]-M[i].Back[0]<MinSizeM) {MinSizeM=M[i].P[0]-M[i].Back[0]; MinM=i;} // поиск минимальной формации М
//         if (New-M[i].P[0]>Atr.Lim){// пробой M формации
//            M[i].Phase=0;
//            FreeM=i;}
//         if (MathAbs(New-M[i].P[0])<Atr.Lim){ }// очередное совпадение
//                 
//      }  }  
//   else{
//      for (uchar i=0; i<TrgAmount; i++){ // проверка формации "W"
//         if (W[i].Phase==0) {FreeW=i; continue;}
//         if (W[i].Back[0]-W[i].P[0]<MinSizeW) {MinSizeW=W[i].Back[0]-W[i].P[0]; MinW=i;} // поиск минимальной формации W
//         if (W[i].P[0]-New>Atr.Lim){ // пробой W формации
//            W[i].Phase=0;
//            FreeW=i;}
//      }  }
//   
//   if (Cnt<2) return; // отскоков небыло
   
   // формирование новой формации
   //if (Cnt==2 && F[f].Pwr==2){ // первое касание "Первого" уровня
   //   if (Dir>0){
   //      M[FreeM].Phase=1;
   //      M[FreeM].Cnt=Cnt;
   //      M[FreeM].P[0]=F[f].P;
   //      M[FreeM].P[1]=F[n].P;
   //      M[FreeM].Frnt[1]=F[n].Frnt;
   //   }  }    
      
      
   // M[2].P[4]=99;
   
   }   
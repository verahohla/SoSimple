    
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





   
void TRIAG(uchar f, char& N){// Прямоугольный треугольник: f-номер первой вершины в массиве, N-количество вершин
   if (F[f].Pwr!=2)     return; // вершина треугольника должна быть первым уровнем      
   if (N==0){   // начало формирования треугольника - у треугольника пока была только одна вершина 
      F[f].TRG.P[1]=F[f].P;  // пик треугольника, лежащий на горизонтальной оси (первый - пик Первого Уровня)
      F[f].TRG.T[1]=F[f].T;  // время первого пика = время пика Первого Уровня
      F[f].TRG.P[0]=F[f].Frnt;   // пик треугольника, лежащий на наклонной оси. Этот не участвует в построении, нужен для первого сравнения
      F[f].TRG.T[0]=F[f].ExT;    // его время - время ближайшего превосходящего пика
      N=1;  //X("F1",    F[f].TRG.P[1], SHIFT(F[f].TRG.T[1]), clrRed);
      V("F"+S0(N)+" ("+S0(f)+")",      F[f].TRG.P[0],    SHIFT(F[f].TRG.T[1]), clrBlack);
      }
   float NewPic; // промежуточный пик, лежащий между совпавшими на горизонтальной оси вершинами
   int NewShift; // его сдвиг относительно текущего бара
   int Shift=iBarShift(NULL,0,F[f].TRG.T[N],false); // сдвиг прошлого горизонтального пика относительно нового
   if (Dir>0){
      NewShift=iLowest (NULL,0,MODE_LOW ,Shift-(bar+PicPer),bar+PicPer);   
      NewPic=float(Low[NewShift]); 
      if (N==1 || (Shift-bar>FltLen && NewPic>F[f].TRG.P[N-1])){ // новый фронт выше предыдущего,
         N+=2; 
      }  }                  // треугольник нарушен  
   else{
      NewShift=iHighest(NULL,0,MODE_HIGH,Shift-(bar+PicPer),bar+PicPer);   
      NewPic=float(High[NewShift]); if (f==80) A("F"+S0(N)+" ("+S0(f)+") "+S0(Shift-bar),   New,    bar+PicPer, clrBlack);
      if (N==1 || (Shift-bar>FltLen && NewPic<F[f].TRG.P[N-1])){ // новый фронт ниже предыдущего 
         N+=2; A("   F"+S0(N)+" ("+S0(f)+")",   New,    bar+PicPer, clrRed);
      }  }   
   F[f].TRG.P[N]  =New; // значение нового пика горизонтальной оси       
   F[f].TRG.T[N]  =Time[bar+PicPer];    // время нового пика   
   F[f].TRG.P[N-1]=NewPic;// пик наклонной оси
   F[f].TRG.T[N-1]=Time[NewShift]; // время нового пика на наклонной оси
   if (N>3){
      LINE("N="+S0(N)+"("+S0(f)+")", SHIFT(F[f].TRG.T[2]),F[f].TRG.P[2], SHIFT(F[f].TRG.T[N-1]), F[f].TRG.P[N-1],clrRoyalBlue,2);
      LINE("N="+S0(N)+"("+S0(f)+")", SHIFT(F[f].TRG.T[2]),F[f].TRG.P[2], SHIFT(F[f].TRG.T[1]), F[f].TRG.P[1],clrRoyalBlue,2);
      LINE("TRG"+"("+S0(f)+")", SHIFT(F[f].TRG.T[1]),F[f].TRG.P[1], bar+PicPer, New,clrLightGreen,0);
      //if (Dir>0){
      //   A("F"+S0(N-1)+" ("+S0(f)+")", NewPic, NewShift,   clrBlack);
      //   V("F"+S0(N)+" ("+S0(f)+")",   New,    bar+PicPer, clrBlack);
      //}else{
      //   V("F"+S0(N-1)+" ("+S0(f)+")", NewPic, NewShift,   clrBlack);
      //   A("F"+S0(N)+" ("+S0(f)+")",   New,    bar+PicPer, clrBlack);
      //   }
      //for (char j=1; j<=F[f].TRG.Cnt; j++) A("F"+S0(j)+" "+S0(Shift)+"-"+S0(bar+PicPer), F[f].TRG.P[j], SHIFT(F[f].TRG.T[j]), clrBlack);
      }     
   
   }   
   
void SQUARE_TRIANGLE(uchar f, char& N){// Прямоугольный треугольник: f-номер первой вершины в массиве, N-количество сформированных по горизонтальрой оси вершин
   if (!F[f].First)     return; // вершина треугольника должна быть первым уровнем      
   if (N==0){   // начало формирования треугольника - не было ни  одного совпадения пиков на горизонтальной оси 
      F[f].TRG.P[1]=F[f].P;  // пик треугольника, лежащий на горизонтальной оси (первый - пик Первого Уровня)
      F[f].TRG.T[1]=F[f].T;  // время первого пика = время пика Первого Уровня
      N=1;  // пики горизонтальной оси с нечетными номерами: 1,3,5,7. Пики наклонной - с четными: 2,4,6
      }
   int   Shift=iBarShift(NULL,0,F[f].TRG.T[N],false); // сдвиг прошлого горизонтального пика относительно нового
   float PrePic; // промежуточный пик на наклонной оси, лежащий между совпавшими на горизонтальной оси вершинами
   int   PreShift; // его сдвиг относительно текущего бара
   char i;
   if (Dir>0){
      PreShift=iLowest (NULL,0,MODE_LOW ,Shift-(bar+PicPer),bar+PicPer); // минимум между новым пиком и предыдущим пиком горизонтальной оси  
      PrePic=float(Low[PreShift]); // новая высота треугольника
      for (i=N; i>1; i=i-2)  if (PrePic>F[f].TRG.P[i-1])  break; // среди прежних высот (2,4,6,8) ищем превосходящую, чтобы встать за ней.  
      }                   
   else{
      PreShift=iHighest(NULL,0,MODE_HIGH,Shift-(bar+PicPer),bar+PicPer);   
      PrePic=float(High[PreShift]); 
      for (i=N; i>1; i=i-2) if (PrePic<F[f].TRG.P[i-1])  break;      
      }
   N=i+2;            
   F[f].TRG.P[N]  =New;             // значение нового пика горизонтальной оси       
   F[f].TRG.T[N]  =Time[bar+PicPer];// время нового пика горизонтальной оси    
   F[f].TRG.P[N-1]=PrePic;          // пик наклонной оси
   F[f].TRG.T[N-1]=Time[PreShift];  // время нового пика на наклонной оси
   //if (N>3){
   //   LINE("N="+S0(N)+"("+S0(f)+")",SHIFT(F[f].TRG.T[2]),F[f].TRG.P[2], SHIFT(F[f].TRG.T[N]), F[f].TRG.P[N],clrRoyalBlue,0);
   //   LINE("N="+S0(N)+"("+S0(f)+")",SHIFT(F[f].TRG.T[2]),F[f].TRG.P[2], SHIFT(F[f].TRG.T[1]), F[f].TRG.P[1],clrRoyalBlue,0);
   //   LINE("TRG"+"("+S0(f)+")",     SHIFT(F[f].TRG.T[1]),F[f].TRG.P[1], SHIFT(F[f].TRG.T[N]), F[f].TRG.P[N],clrLightGreen,0);
   //   for (char j=1; j<=N; j+=2){
   //      if (Dir>0)  V("F"+S0(j)+" "+S0(f), F[f].TRG.P[j], SHIFT(F[f].TRG.T[j]), clrBlack);
   //      else        A("F"+S0(j)+" "+S0(f), F[f].TRG.P[j], SHIFT(F[f].TRG.T[j]), clrBlack);
   //   }  }    
   
   }   
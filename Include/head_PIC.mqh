#define  PicPer   1 // период фракталов (самый ухкий)

#define  TRND  1  // признак пробоя трендового уровня
#define  BRK   2  // признак пробоя пика
#define  LevelsAmount   250 // в месяце 576 часов, т.е. грубо 576/3 фракталов 
#define  BarsToCount    150 // кол-во бар, глубже которого не считаются первые уровни, и остаются только самые крупные пики 
#define  Movements      5   // размерность MovUp, MovDn  (должнa быть не меньше 3)
// СТАДИИ ФОРМИРОВАНИЯ СИГНАЛОВ
#define  BLOCK   -1  // блокировка 
#define  NONE     0
#define  WAIT     1  // ожидание
#define  START    2  // начало 
#define  CONFIRM  3  // подтверждение
#define  GOGO     4  // сигнал на открытие позы
#define  BREAK    5  // отмена
#define  DONE     6  // поза открыта
// ВИДЫ ФЛЭТА
#define  DBLPIC   1  // просто два отскока с подтвержденным трендовым уровнем
#define  FLAT     2  // широкий и протяженный флэт
// СТАДИИ ПРОБОЯ УРОВНЯ
#define  NOTHING -1 // не сформирован (для трендовых)
#define  CLEAR    0 // новый непробитый
#define  TOUCH    1 // с касанием флэтовый
#define  BROKEN   2 // пробитый
#define  MIRROR   3 // зеркальный
#define  USED     4 // отработанный
// NEW EXTERNAL 
// LEVELS PROPERTIES

#define  UPCLR clrSeaGreen
#define  DNCLR clrTomato

float    H, L, C, H1, L1, C1,
         Impulse,    // величина последнего импульса, превысившего порог Atr.Slow*TrImp
         New,        // новый (последний) фрактал
         //HiBack, LoBack, // Откаты от Первых уровней
         HiNearest, LoNearest, // Ближайшие цены к первым уровням
         midHi,midLo, // проверочные значения последних "первых уровней"
         MidMovUp, MidMovDn, LastMovUp, LastMovDn,    // среднее значение нескольких пследних движений
         MovUp[1], MovDn[1], MovUpSrt[1], MovDnSrt[1],// массивы безоткатных движений для определения целевого движения, инициализируюстя в init() на Movements членов
         TargetHi, TargetLo;  // целевые движения и их предварительные значения    
datetime BarSeconds; // кол-во секунд в баре         
short    BarsInDay; // период поиска первых уровней (сек). На нем ищем пики, развернувшие самые большие движения         
char     Dir;        // направление последнего пика
// Индексы уровней
uchar n,          // номер последнего пика
      BrokenPic,  // последний из пробитых
      hi,lo,      // последний Hi/Lo
      hi2,lo2,    // предпоследний
      stpH, stpL,    // уровни стопов
      //TrlHi, TrlLo,  // уровни трейлингов
      HI,LO,Hi2,Lo2, // Первый, предпоследний Первый
      PocHI, PocLO,  // Уровень чуть дальше серединки с максимальным кол-вом: BARS_POC | PICS_POC | BARSPICS_POC
      RevHi,RevLo,RevHi2,RevLo2,// Разворотный,
      FlsUp,FlsDn,// ложняки подтвержденные
      uFsUp,uFsDn,// ложняки неподтвержденные
      TrgHi,TrgLo;// целевой
bool  Update;     // признак обновления пика

struct FLS_BRK{// вложенная структура ложных пробоев
   datetime BT;   // время базы, из которой выстрелил ложняк
   datetime T;    // время пика ложняка
   float    Base; // база, из которой выстрелил ложняк
   float    P;    // пик ложняка
   char     Phase;// стадия NONE, START, CONFIRM, BREAK 
   }; 
struct FLT_LEV{// вложенная структуа флэта, сформированного пиком
   float  Lev;  // усредненное значение сформированной границы флэта
   float  Frnt; // фронт первого пика флэта (движение предшествующее флэту) (пока ХЗ зачем)
   float  Back; // противоположная граница флэта
   datetime T;  // время начала флэта
   char   Len;  // длина флэта 
   };  
#define  TrgPics   20 // кол-во пиков в треугольнике
struct TRIANGLE{  // структура треугольника
   float    P[TrgPics]; // пик треугольника, 
   datetime T[TrgPics]; // время возникновения пика
   char  N;             // кол-во вершин треугольника
   };  
struct PICS{  //  C Т Р У К Т У Р А   P I C
   float P;       // price
   float Tr;      // трендовые уровни пиков
   char  TrBrk;   // статус трендового NOTHING(-1)-не сформирован,  CLEAR(0)-сформирован,  BROKEN(2)-пробит 
   float TrMid;   // серединка трендового уровня на пробой
   float Mid;     // Уровень "чуть дальше серединки" движения
   float Mir;     // зеркальный уровень движения
   float Frnt;    // передний фронт пика - минимум между ним и превосходящей его вершиной
   float FrntVal; // амплитуда переднего фронта
   float Back;    // задний фронт пика (цена)
   float BackVal; // амплитуда заднего фронта
   float Near;    // уровень, до которого цена приближалась к пику
   float NearVal; // расстояние от Back до Near, т.е. Back от Back
   float MaxMov;  // максимальный откат с момента формирования пика для измеренных движений
   float Power;   // Сила пика Power=MIN(FrntVal,BackVal); 
   float PwrSum;  // Сумма сил пиков на этом уровне 
   datetime T;       // время формирования пика 
   datetime BrkT;    // время пробоя уровня
   datetime BackT;   // время последней вершины Back уровня
   datetime ExT;     // время ближайшего превосходящего пика для поиска фронта. время начала движения, которое развернул уровень.
   datetime Per;     // кол-во бар до пробоя пика
   char  Dir;     // направление фрактала: 1=ВЕРШИНА, -1=ВПАДИНА
   char  Rev;     // признак разворотной вершины, повышающегося пика. Только из них выбираются Первые Уровни 
   char  Brk;     // Признак пробитости: CLEAR(0)-нет, TOUCH(1)-касание, BROKEN(2)-пробой, MIRROR(3)-глубокий резкий пробой (зеркальный), USED(4)-никчемный
   bool  First;   // Признак сильного "Первого" уровня (большой передний и задний фронты)
   char  Cnt;     // кол-во совпадений c сонаправленными пиками для простоения флэта
   uchar Pics;    // кол-во совпадений c любыми пиками для нахождения зоны с максимальным кол-вом отскоков
   uchar Wid;     // Ширина пика в барах
   FLT_LEV Flt;  // вложенная структуа флэта, сформированного пиком
   FLS_BRK Fls;  // вложенная структура ложных пробоев
   TRIANGLE TRG; // вложенная структура треугольников
   } F[LevelsAmount]; 
                 
struct TREND_SIGNALS{  //  C Т Р У К Т У Р А   T R E N D
   char  PicBrk;  // пробитии подряд PicBrk пиков
   char  Global;  // пробитие уровня противоположным пиком
   float Imp;     // импульс
   char  Up;       
   char  Dn;
   float DblTop;  // сигнал "Двойная вершина" (туда записывается значение уровня)
   float FltBrk;  // пробой флэта
   }Trnd;      // 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      

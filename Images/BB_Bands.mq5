//---PROPERTIES--------------------------------------------------------------------------------------------//
   #property   indicator_chart_window                  // Where to place indicator
   #property   indicator_buffers    3                  // Number of buffer to use   
   #property   indicator_plots      3                  // number of plot on the graph

//---plot characteristics
   #property indicator_label1  "UpperBand"             // Label
   #property indicator_type1   DRAW_LINE               // Plot type   
   #property indicator_color1  clrBlue                 // Color  
   #property indicator_style1  STYLE_SOLID             // Plot style
   #property indicator_width3  1                       // Plot width
   
   #property indicator_label2  "LowerBand"
   #property indicator_type2   DRAW_LINE        
   #property indicator_color2  clrBlue         
   #property indicator_style2  STYLE_SOLID      
   #property indicator_width2  1                



//---GLOBAL VARIABLES--------------------------------------------------------------------------------------//
//---Inputs
   input int      BB_Len  = 20;          // Averaging period             
   input double   BB_SDs  = 2.0;         // Number of standard deviations


//---Handle
   int            BB_Handle;             // Pointer of the BB function

//---Buffers
   double         BB_Upper_Buffer[];     // Data buffer for upper band
   double         BB_Lower_Buffer[];     // Data buffer for lower band


//--Containers for any other variable
   double         EntryType;              // holder for what type of entry is price at. long: 1 short:2
   double         EntryType_Buffer[];     // Bufer to store is price is long or short.
   double         ClosePrice;             // Holder for the close price


             
//---CODE TO RUN ONCE WHEN THE INDICATOR IS FIRST LAODED---------------------------------------------------//

int OnInit()
{
//--- Handle Creation...tell MQL5 the fucntion to use.
   BB_Handle = iBands( Symbol(), Period(), BB_Len, 0, BB_SDs,PRICE_CLOSE);

//---Map buffers...or in other words, give numbers to the buffers that will be used
   SetIndexBuffer(0, BB_Upper_Buffer,  INDICATOR_DATA);
   SetIndexBuffer(1, BB_Lower_Buffer,  INDICATOR_DATA);
   SetIndexBuffer(2, EntryType_Buffer, INDICATOR_DATA);
   
return(INIT_SUCCEEDED);
}

//---CODE TO RUN AT EACH TICK OF CANDLE--------------------------------------------------------------------//
int OnCalculate( const int        rates_total,      // Total number of bars to be processed
                 const int        prev_calculated,  // Number of bars calculated in the previous call
                 const datetime   &time[],          // Array of bar times  
                 const double     &open[],          // Array of bar open prices
                 const double     &high[],          // Array of bar high prices
                 const double     &low[],           // Array of bar low prices  
                 const double     &close[],         // Array of bar close prices
                 const long       &tick_volume[],   // Array of tick volumes for each bar
                 const long       &volume[],        // Array of real volumes for each bar
                 const int        &spread[])        // Array of spreads for each bar
{
//---Bypass calculation if there are not enough candels.
   if(rates_total<BB_Len) return(0);
      
 //--- Calculate over how many candels to do calculation. If it is first time, calculate over all candlas, 
 //---  if not, calcualte since last calculaiton.
   int CopyUpTo;
   if(prev_calculated>rates_total || prev_calculated<0)
      CopyUpTo=rates_total;
   else
     {
      CopyUpTo=(rates_total-prev_calculated)+1;
     }
     
      
//--- fill the Buffer array with values of the BB indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, go to start again
   if(!CopyBuffer(BB_Handle,1,0,CopyUpTo,BB_Upper_Buffer)) return(0);
      
   if(!CopyBuffer(BB_Handle,2,0,CopyUpTo,BB_Lower_Buffer))  return(0);


//-- Any extra calcualiton. here we check if price is above or below BBands
   for( int i = CopyUpTo; i < rates_total ; i++) {
      ClosePrice= close[i];
      EntryType  = ClosePrice>BB_Upper_Buffer[i] ? 1: ClosePrice<BB_Lower_Buffer[i]? 2: 0;
      EntryType_Buffer[i]=EntryType;
   } 
   
return(rates_total); 
}

module ImageProc_tb();
    logic clk;
    logic rst_n;
    //Signals from Data Capture
    logic         oDATA,
    logic [11:0]  oX_Cont,
    logic	[15:0]	oY_Cont,
    logic	[31:0]	oFrame_Cont,
    logic			oDVAL,
    //Signals to SDRAM
    //	FIFO Write Side 1
    logic [15:0]  WR1_DATA;               //Data Input
    logic         WR1;					          //Write Request
    logic [15:0]	WR1_ADDR;				        //Write Start Address
    logic [15:0]  WR1_MAX_ADDR;			      //Write Max Address
    logic			WR1_LOAD;			         	//Write FIFO Clear
    logic [7:0]	WR1_LENGTH;     				//Write Length
    logic			WR1_CLK;				        //Write FIFO Clock
    //	FIFO Write Side 2
    logic [15:0]  WR2_DATA;               //Data Input
    logic			WR2;					          //Write Request
    logic	[15:0]	WR2_ADDR;				        //Write Start Address
    logic	[15:0]	WR2_MAX_ADDR;			      //Write Max Address
    logic [7:0]	WR2_LENGTH;     				//Write Length
    logic         WR2_LOAD;			         	//Write FIFO Clear
    logic         WR2_CLK;	

    ImageProc iDUT( .clk(clk), 
                    .rst_n(rst_n), 
                    .oDATA(), 
                    .oX_Cont(), 
                    .oY_Cont(), 
                    .oFrame_Cont(), 
                    .oDVAL(),
                    .WR1_DATA(),     
                    .WR1(),	
                    .WR1_ADDR(),				 
                    .WR1_MAX_ADDR(),			    
                    .WR1_LENGTH(),     				
                    .WR1_LOAD(),			         	
                    .WR1_CLK(),				       
                    .WR2_DATA(),               
                    .WR2(),					        
                    .WR2_ADDR(),				        
                    .WR2_MAX_ADDR(),			   
                    .WR2_LENGTH(),     				
                    .WR2_LOAD(),			         	
                    .WR2_CLK()	
    )

    initial begin
        clk = 0;

        

    end

    always 
        #5 clk = ~clk;

endmodule
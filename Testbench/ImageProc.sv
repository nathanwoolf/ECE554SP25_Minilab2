module ImageProc(
    input logic clk,
    input logic rst_n,
    //Signals from Data Capture
    input logic         oDATA,
    input logic [11:0]  oX_Cont,
    input logic	[15:0]	oY_Cont,
    input logic	[31:0]	oFrame_Cont,
    input logic			oDVAL,
    //Signals to SDRAM
    //	FIFO Write Side 1
    output logic [15:0]  WR1_DATA,               //Data Input
    output logic         WR1,					          //Write Request
    output logic [15:0]	WR1_ADDR,				        //Write Start Address
    output logic [15:0]  WR1_MAX_ADDR,			      //Write Max Address
    output logic [7:0]	WR1_LENGTH,     				//Write Length
    output logic			WR1_LOAD,			         	//Write FIFO Clear
    output logic			WR1_CLK,				        //Write FIFO Clock
    //	FIFO Write Side 2
    output logic [15:0]  WR2_DATA,               //Data Input
    output logic			WR2,					          //Write Request
    output logic	[15:0]	WR2_ADDR,				        //Write Start Address
    output logic	[15:0]	WR2_MAX_ADDR,			      //Write Max Address
    output logic [7:0]	WR2_LENGTH,     				//Write Length
    output logic         WR2_LOAD,			         	//Write FIFO Clear
    output logic         WR2_CLK	

);

logic iDVAL;
logic [11:0] iDATA;
logic [11:0] mDATA_1;
logic [11:0] mDATA_0;
logic [32:0] index_debug;

Line_Buffer1 	BayerPixelBuffer0	(	.clken(iDVAL),
                                        .clock(clk),
                                        .shiftin(iDATA),
                                        .shiftout(oDATA),
                                        .taps0x(mDATA_1),
                                        .taps1x(mDATA_0)	);

/*
Line_Buffer1 	BayerPixelBuffer1	(	.clken(iDVAL),
                                        .clock(iCLK),
                                        .shiftin(iDATA),
                                        .taps0x(mDATA_1),
                                        .taps1x(mDATA_0)	);

Line_Buffer1 	BayerPixelBuffer2	(	.clken(iDVAL),
                                        .clock(iCLK),
                                        .shiftin(iDATA),
                                        .taps0x(mDATA_1),
                                        .taps1x(mDATA_0)	);

Line_Buffer1 	BayerPixelBuffer2	(	.clken(iDVAL),
                                        .clock(iCLK),
                                        .shiftin(iDATA),
                                        .taps0x(mDATA_1),
                                        .taps1x(mDATA_0)	);
*/

endmodule
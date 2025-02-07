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
logic [11:0] mDATA_1_ff;
logic [11:0] mDATA_0;
logic [11:0] mDATA_0_ff;


Line_Buffer1 	BayerPixelBuffer0	(	.clken(iDVAL),
                                        .clock(clk),
                                        .shiftin(iDATA),
                                        .shiftout(oDATA),
                                        .taps0x(mDATA_1),
                                        .taps1x(mDATA_0));

//SM and singals to control I/O from line buffer
reg [10:0] cnt;
logic row_cmplt;        //will go high once every 1280 clk cycles
logic avg_cs;           //control sig to take average of pixel vals
logic data_valid;
logic [11:0] calc;      //TODO: verify bit width on calculation vector
logic [11:0] gs_out;    //single pixel gray scale output vector TODO: determine where this goes next
reg [1:0] init;

// STATE MACHINE
typedef enum [1:0] state {FILL_INIT, FILL, COMP} state_t;
state_t state, next_state;

always_ff @(posedge clk, negedge rst_n) begin 
    if (!rst_n) begin 
        state <= FILL_INIT
        init <= '0;
    end
    else state <= next_state;
end

// COUNTER
always_ff @(posedge clk, negedge rst_n) begin 
    if (!rst_n)
        cnt <= '0;
    else if (row_cmplt)
        cnt <= '0;
    else 
        cnt <= cnt + 1;
end

assign row_cmplt = (cnt==11'd1280);         // Counter complete continuous assign

/////////////////////////////////////////////////////////////////////////////////////
// oscillating flop 
// data valid only high every other clock cycle so we can propogate fill buffer taps 
// so we can get real data into data_out regs for gray scale conversion
/////////////////////////////////////////////////////////////////////////////////////
always_ff @(posedge clk, negedge rst_n) begin 
    if (!rst_n) avg_cs <= 1'b0;
    else if (row_cmplt) avg_cs <= 1'b0;
    else avg_cs <= ~avg_cs;
end

// hold onto outputs from line buffer for one clock cycle
always_ff @(posedge clk, negedge rst_n) begin 
    if (!rst_n) begin 
        mDATA_1_ff <= '0;
        mDATA_0_ff <= '0;
    end 
    else begin 
        mDATA_1_ff <= mDATA_1;
        mDATA_0_ff <= mDATA_0;
    end
end

//TODO: can break this up into clock cycles if we need to. wont have any issues
assign calc = (mDATA_1 + mDATA_0 + mDATA_1_ff + mDATA_0_ff) / 4;

//avg_cs high every other clk cycle, data_valid low for 1280 and high for 1280
//TODO: use avg_cs to determine when we want to write grayscale output to other line buffer
assign gs_out = (avg_cs & data_valid) ? calc : '0;          

always_comb begin 
    data_valid = 1'b0;

    case (state) 
        //fill for two rows 
        FILL_INIT: begin 
            if (row_cmplt) begin 
                init <= init + 1;
            end
            //does init equal 2?
            if (init[1]) next_state = COMP;
            //TODO: idk what oDATA behavior is when nothing has been shifted in. X or 0? might just want to delete this line 
            //counter should suffice
            else if(|oDATA !== 0) next_state = COMP;    
        end

        FILL : begin
            if (row_cmplt)
                next_state = COMP; 
        end 

        
        COMP : begin  
            data_valid = 1'b1;
            if (row_cmplt)
                next_state = FILL;
        end

        default: begin end; 

    endcase
end

Line_Buffer1 	GrayScalePixelBuffer1(  .clken(avg_cs),
                                        .clock(iCLK),
                                        .shiftin(gs_out),
                                        .taps0x(mDATA_1),
                                        .taps1x(mDATA_0));




/*
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
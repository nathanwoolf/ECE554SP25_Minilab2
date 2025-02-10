module ImageProc(
    input logic clk,
    input logic rst_n,
    //Signals from Data Capture
    input logic [11:0] iDATA,
    //Signals to SDRAM
    output logic [15:0] output_data,         
    output logic        output_valid
);

//CONV Matrix
localparam signed Sobel00 = -1;
localparam signed Sobel01 = 0;
localparam signed Sobel02 = 1;
localparam signed Sobel10 = -2;
localparam signed Sobel11 = 0;
localparam signed Sobel12 = 2;
localparam signed Sobel20 = -1;
localparam signed Sobel21 = 0;
localparam signed Sobel22 = 1;

//Internal Signals
logic [11:0] gray_row_counter;
logic gray_row_valid;
logic gray_col_valid;
logic gray_calc_valid;
logic [11:0] gray_data_row_0_col_0, gray_data_row_1_col_0;
logic [11:0] gray_data_row_0_col_1, gray_data_row_1_col_1;
logic [23:0] gray_taps;
logic [11:0] gray_scale_data;

logic [35:0] conv_taps;
logic signed [11:0] conv_data_row_0_col_0, conv_data_row_0_col_1, conv_data_row_0_col_2;
logic signed [11:0] conv_data_row_1_col_0, conv_data_row_1_col_1, conv_data_row_1_col_2;
logic signed [11:0] conv_data_row_2_col_0, conv_data_row_2_col_1, conv_data_row_2_col_2;
logic signed [63:0] conv_data, conv_data_pos; 
logic [11:0] conv_abs_val_data;

//contains bayer pixels
Line_Buffer_gray grayBuffer(  .aclr(~rst_n),
	                        .clock(clk),
	                        .shiftin(iDATA),
	                        .shiftout(),
	                        .taps(gray_taps));
assign gray_data_row_0_col_0 = gray_taps[11:0];
assign gray_data_row_1_col_0 = gray_taps[23:12];

//contains grey scale pixels
Line_Buffer_conv convBuffer(  .aclr(~rst_n),
	                        .clock(clk),
	                        .shiftin(gray_scale_data),
	                        .shiftout(),
	                        .taps(conv_taps));
assign conv_data_row_0_col_0 = conv_taps[11:0];
assign conv_data_row_1_col_0 = conv_taps[23:12];
assign conv_data_row_2_col_0 = conv_taps[35:24];

/////  Grey scale calc  //////

//every other col is valid
always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        gray_col_valid <= 0;
    end
    else begin
        gray_col_valid <= ~gray_col_valid;
    end
end

//Every other row is valid
always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        gray_row_counter <= 0;
    else if(gray_row_counter == 12'd1280) 
        gray_row_counter <= 0;
    else
        gray_row_counter <= gray_row_counter + 1;
end
always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) 
        gray_row_valid <= 0;
    else if(gray_row_counter == 12'd1280)
        gray_row_valid <= ~gray_row_valid;
end

assign gray_calc_valid = gray_row_valid & gray_col_valid;

//Save prev pixel
always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        gray_data_row_0_col_1 <= '0;
        gray_data_row_1_col_1 <= '0;
    end
    else begin
        gray_data_row_0_col_1 <= gray_data_row_0_col_0;
        gray_data_row_1_col_1 <= gray_data_row_1_col_0;
    end
end

assign gray_scale_data = (gray_data_row_0_col_0 + gray_data_row_0_col_1 + gray_data_row_1_col_0 + gray_data_row_1_col_1) / 4;

//Convolution
always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        conv_data_row_0_col_1 <= '0;
        conv_data_row_1_col_1 <= '0;
        conv_data_row_2_col_1 <= '0;
    end
    else begin
        conv_data_row_0_col_1 <= conv_data_row_0_col_0;
        conv_data_row_1_col_1 <= conv_data_row_1_col_0;
        conv_data_row_2_col_1 <= conv_data_row_2_col_0;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        conv_data_row_0_col_2 <= '0;
        conv_data_row_1_col_2 <= '0;
        conv_data_row_2_col_2 <= '0;
    end
    else begin
        conv_data_row_0_col_2 <= conv_data_row_0_col_1;
        conv_data_row_1_col_2 <= conv_data_row_1_col_1;
        conv_data_row_2_col_2 <= conv_data_row_2_col_1;
    end
end

assign conv_data =  ((conv_data_row_0_col_0 * Sobel00) + 
                    (conv_data_row_0_col_1 * Sobel01) +
                    (conv_data_row_0_col_2 * Sobel02) +
                    (conv_data_row_1_col_0 * Sobel10) +
                    (conv_data_row_1_col_1 * Sobel11) +
                    (conv_data_row_1_col_2 * Sobel12) +
                    (conv_data_row_2_col_0 * Sobel20) +
                    (conv_data_row_2_col_1 * Sobel21) +
                    (conv_data_row_2_col_2 * Sobel22));

//Absolute value
assign conv_data_pos = ~conv_data + 1;
assign conv_abs_val_data = (conv_data[63]) ?    ((conv_data_pos > 12'd2048) ? 12'd2048 : conv_data_pos) 
                                                : ((conv_data > 12'd2048) ? 12'd2048 : conv_data);

                                                
assign output_valid = gray_calc_valid;
assign output_data = conv_abs_val_data;

endmodule
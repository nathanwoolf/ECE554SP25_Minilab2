module ImageProcessing (
input	logic 		    iCLK,
input	logic 		    iRST,
input	logic [10:0]	iX_Cont,
input	logic [10:0]	iY_Cont,
input	logic [11:0]	iDATA,
input	logic 		    iDVAL,
input	logic 		    grayscale_cs,
input	logic 		    h_edgeDetect,
output	logic [11:0]	oRed,
output	logic [11:0]	oGreen,
output	logic [11:0]	oBlue,
output	logic 		    oDVAL
);

logic   [11:0]  grayscale_pixel, conv_pixel, bayer_pixel;
logic   [11:0]  bayer_pixel_ff, iDATA_ff;

logic               gray_shift_en;
logic signed [14:0] signed_pixel_out;
logic        [11:0] pixel_out;

assign pixel_out = (grayscale_cs) ? ((signed_pixel_out[14]) ? (~signed_pixel_out) + 1 : signed_pixel_out) : grayscale_pixel;
 
assign oDVAL = gray_shift_en;

assign oBlue = pixel_out;
assign oGreen = pixel_out;
assign oRed = pixel_out;
logic [11:0] conv[0:2][0:2];

Line_Buffer2 iBayerBuffer(
    .clken(iDVAL),
    .clock(iCLK),
    .shiftin(iDATA),
    .shiftout(),
    .taps(bayer_pixel)
);

Line_Buffer3 iGrayBuffer0(
    .clken(gray_shift_en),
    .clock(iCLK),
    .shiftin(conv[2][2]),
    .shiftout(),
    .taps(conv[1][2])
);

Line_Buffer3 iGrayBuffer1(
    .clken(gray_shift_en),
    .clock(iCLK),
    .shiftin(conv[1][2]),
    .shiftout(),
    .taps(conv[0][2])
);

always_ff @(posedge iCLK, negedge iRST) begin
    if(~iRST) begin
        grayscale_pixel <= '0;
        bayer_pixel_ff <= '0;
        iDATA_ff <= '0;
    end
    else begin
        bayer_pixel_ff <= bayer_pixel;
        iDATA_ff <= iDATA;
        grayscale_pixel <= (bayer_pixel_ff + bayer_pixel + iDATA + iDATA_ff) / 4;
    end
end 

always_ff @(posedge iCLK, negedge iRST) begin
    if(~iRST) begin
        gray_shift_en <= 0;
    end
    else begin
        gray_shift_en <= ((!iY_Cont[0]) | (!iX_Cont[0])) ? iDVAL : 1'b0;
    end
end


////////////////////
// convolution logic
////////////////////
assign conv[2][2] = grayscale_pixel; 
always @(posedge iCLK, negedge iRST) begin 
    if (!iRST) begin 
        conv[2][1] <= 0;
        conv[2][0] <= 0;
        conv[1][1] <= 0;
        conv[1][0] <= 0;
        conv[0][1] <= 0;
        conv[0][0] <= 0;
    end
    else begin
        conv[2][1] <= conv[2][2];
        conv[2][0] <= conv[2][1];
        conv[1][1] <= conv[1][2];
        conv[1][0] <= conv[1][1];
        conv[0][1] <= conv[0][2];
        conv[0][0] <= conv[0][1];
    end
end

always_comb begin
    if (h_edgeDetect) begin
        signed_pixel_out <=     (-1 * conv[0][0]) + (-2 * conv[0][1]) + (-1 * conv[0][2]) + 
                                (1 * conv[2][0]) + (2 * conv[2][1]) + (1 * conv[2][2]);
    end
    else begin 
        signed_pixel_out <=     (-1 * conv[0][0]) + (-2 * conv[1][0]) + (-1 * conv[2][0]) + 
                                (1 * conv[0][2]) + (2 * conv[1][2]) + (1 * conv[2][2]);
    end
end

endmodule
`timescale 1 ps / 1 ps
module ImageProc_tb();
    logic clk;
    logic rst_n;
    //Signals from Data Capture
    logic [11:0] iDATA;
    logic [11:0] oDATA;
    logic oDATAvalid;

    logic index_debug;

    ImageProc iDUT( .clk(clk), 
                    .rst_n(rst_n), 
                    .iDATA(iDATA),
                    .output_data(oDATA),
                    .output_valid(oDATAvalid)	
    );

    initial begin
        rst_n = 0;
        clk = 0;
        index_debug = 0;

        repeat (5) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        for (integer i = 0; i < 5000; i++) begin
            iDATA = (i + 1) % 1000;
            index_debug = i;
            @(posedge clk);
        end

        #100
        $stop;
    end

    always 
        #5 clk = ~clk;

endmodule
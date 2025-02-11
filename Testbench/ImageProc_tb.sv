`timescale 1 ps / 1 ps
module ImageProc_tb();
    logic clk;
    logic rst_n;
    //Signals from Data Capture
    logic [10:0] iX_Cont; 
    logic [10:0] iY_Cont;
    logic [10:0] iData;
    logic iDVAL;
    logic grayscale_cs; 
    logic h_edgeDetect;
    logic [11:0] oRed;
    logic [11:0] oGreen;
    logic [11:0] oBlue;
    logic oDVAL;

    ImageProcessing iDUT(   .iCLK(clk), 
                            .iRST(rst_n), 
                            .iX_Cont(iX_Cont), 
                            .iY_Cont(iY_Cont), 
                            .iDATA(iDATA), 
                            .iDVAL(iDVAL), 
                            .grayscale_cs(grayscale_cs), 
                            .h_edgeDetect(h_edgeDetect), 
                            .oRed(oRed), 
                            .oGreen(oGreen), 
                            .oBlue(oBlue), 
                            .oDVAL(oDVAL));

    initial begin
        $display("RESETTING");
        rst_n = 0;
        clk = 0;
        index_debug = 0;

        repeat (5) @(posedge clk);
        rst_n = 1;

        //set DUT inputs
        iY_Cont = 12'h0; 
        iX_Cont = 12'h0;
        iDVAL = 1;

        ////////////////////////////////////////////////
        // GENERATION OF RANDOM CAMERA DATA FOR IMG_PROC
        ////////////////////////////////////////////////
        repeat(5120) @(posedge clk) iDATA = $urandom%4096;
        //iDATA will get the last random value hereafter 

        // make sure we get oDVAL (out data valid) at some point
        $display("waiting for oDVAL");
        fork
            begin : odval_to
                repeat(960*1280) @(posedge clk);
                $display("ERR: timeout waiting for oDVAL to go high"); 
                $stop(); 
            end: odval_to
            begin 
                @(posedge oDVAL) begin 
                    $display("PASS: got out data valid signal");
                    disable odval_to;
                end
            end
        join

        ////////////////////////////////////////////////////////////////////////////////
        //Test series: Make sure grayscale_cs yields approximately correct output values
        ////////////////////////////////////////////////////////////////////////////////
        $display("Testing grayscale functionality");
        $dipslay("turning on grayscale control signal");
        grayscale_cs = 1; 
        if (oRed !== oGreen || oRed !== oBlue || oBlue != oGreen) begin
            $display("FAILED: grayscale logic not functional -> RGB values from img_proc should be equal");
            $stop();
        end else 
            $display("PASS: grayscale is manipulating pixel values"); 

        //turn off grayscale_cs to make sure toggle funct works
        $display("Testing turning off grayscale");
        grayscale_cs = 0;
        if (oRed === oGreen && oRed === oBlue && oBlue == oGreen) begin
            $display("FAILED: toggling grayscale does not work");
            $stop();
        end else 
            $display("PASS: turning off grayscale_cs relinquishes control to RGB");

        //cant really test edge detection aside from interface signals. passing on this for now.

        $display("ALL TEST CASES PASS");
        $stop;
    end

    always 
        #5 clk = ~clk;

endmodule
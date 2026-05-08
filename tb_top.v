`timescale 1ns/1ps

module tb_top;

reg clk;
reg reset;

// Instantiate your top module
top_module uut (
    .clk(clk),
    .reset(reset)
);

// Clock generation (10ns period)
always #5 clk = ~clk;

initial begin
    $dumpfile("wave.vcd");   // for GTKWave
    $dumpvars(0, tb_top);


    clk = 0;
    reset = 1;

    #10;
    reset = 0;   

    #200;
    $finish;
end

endmodule


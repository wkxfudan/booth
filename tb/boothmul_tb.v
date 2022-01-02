`timescale 1ns/1ps

// Basic exhaustive self checking test bench.
`define TEST_WIDTH 32
module booth_fsm_tb;

reg clk;
reg rstn;
reg en;
integer multiplier1;
integer multiplicand1;
reg [`TEST_WIDTH-1:0] multiplier;
reg [`TEST_WIDTH-1:0] multiplicand;
wire    done;
reg     finish;

//输入 ：要定义有符号和符号，输出：无要求
wire signed [2*`TEST_WIDTH-1:0] product;
wire signed [`TEST_WIDTH-1:0]                m1_in;
wire signed [`TEST_WIDTH-1:0]                m2_in;

reg  signed [2*`TEST_WIDTH-1:0] product_ref;
reg  [2*`TEST_WIDTH-1:0] product_ref_u;
assign m1_in = multiplier[`TEST_WIDTH-1:0];
assign m2_in = multiplicand[`TEST_WIDTH-1:0];

booth_fsm #(.DATAWIDTH(`TEST_WIDTH)) booth 
(
  .clk(clk),
  .rstn(rstn),
  .en(en),
  .multiplier(multiplier),                            
  .multiplicand(multiplicand),
  .done  (done),
  .product(product)
 );

always #1 clk = ~clk;

integer num_good;
integer i,j;
initial begin
  clk = 1;
  en = 0;
  rstn = 1;
  finish = 0;
  #2 rstn = 0; #2 rstn = 1;
  
  num_good = 0;
  multiplier=0;
  multiplicand=0;
  #8;

  for(i = 0; i < 32'hFFFF;i=i+1) begin
          
      
        en = 1;

        wait (done == 0);
        wait (done == 1);
        multiplier={$random}%(32'hFFFF_FFFF);
        multiplicand={$random}%(32'hFFFF_FFFF);
        if (product_ref !== product) 
            $display("multiplier = %d multiplicand = %d proudct =%d product_ref =%d",m1_in,m2_in,product,product_ref);
        else
            num_good = num_good + 1;
        @(posedge clk);
  end		
  finish = 1;
  $display("sim done. num good = %d",num_good);
  $finish;

end

always @(posedge clk or negedge rstn) begin
    product_ref<=m1_in*m2_in;
    product_ref_u<=m1_in*m2_in;
end

initial begin
    // $fsdbDumpvars();
    // $fsdbDumpMDA();
    // $dumpvars();
    // if(finish === 1)
    //     $finish;
 end
endmodule


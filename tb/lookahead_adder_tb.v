`timescale 1ns/1ps

// Basic exhaustive self checking test bench.
`define TEST_WIDTH 66
module adder_tb;

reg clk;
reg rstn;
integer src1;
integer src2;
reg [`TEST_WIDTH-1:0] A;
reg [`TEST_WIDTH-1:0] B;


//输入 ：要定义有符号和符号，输出：无要求
wire signed [`TEST_WIDTH-1:0]               data_out;
wire signed [`TEST_WIDTH-1:0]               data_in1;
wire signed [`TEST_WIDTH-1:0]               data_in2;

reg  signed [`TEST_WIDTH-1:0]               adder_ref;
reg  signed [`TEST_WIDTH-1:0]                      adder_ref_next;
assign data_in1 = A[`TEST_WIDTH-1:0];
assign data_in2 = B[`TEST_WIDTH-1:0];

adder_66 adder 
(
  .A(data_in1),                            
  .B(data_in2),
  .S(data_out),
  .c66()
 );

always #1 clk = ~clk;

integer num_good;
integer i,j;
initial begin
  clk = 1;
  rstn = 1;

  #2 rstn = 0; #2 rstn = 1;
  
  num_good = 0;


  for(i = 0; i < 32'hFFFF;i=i+1) begin
          

        A={$random}%(66'h3_FFFF_FFFF_FFFF_FFFF);//
        B={$random}%(66'h3_FFFF_FFFF_FFFF_FFFF);//
        if (adder_ref_next !== data_out) 
            $display("A = %d B = %d data_out =%d adder_ref =%d",data_in1,data_in2,data_out,adder_ref_next);
        else
            num_good = num_good + 1;
        @(posedge clk);
  end		

  $display("sim done. num good = %d",num_good);
  $finish;

end

always @(posedge clk or negedge rstn) begin
    adder_ref<=data_in1+data_in2;
    adder_ref_next<=adder_ref;
end

initial begin
    // $fsdbDumpvars();
    // $fsdbDumpMDA();
    // $dumpvars();
    // if(finish === 1)
    //     $finish;
 end
endmodule


`timescale 1ns/1ps

module booth_fsm
# (parameter DATAWIDTH = 32)
(
  input                        clk,
  input                        rstn,
  input                        en,
  input        [DATAWIDTH-1:0] multiplier,                            
  input        [DATAWIDTH-1:0] multiplicand,
  output reg                   done,
  output reg [2*DATAWIDTH-1:0] product
);


parameter   IDLE   = 2'b00,
            ADD    = 2'b01,
            SHIFT  = 2'b11,
            OUTPUT = 2'b10;

reg  [1:0]              current_state, next_state;  // state registers.
reg  [2*DATAWIDTH+1:0]  a_reg,s_reg,p_reg,sum_reg;  // computational values.
reg  [DATAWIDTH-1:0]    iter_cnt;                   // iteration count for determining when done.
wire [DATAWIDTH:0]      multiplier_neg;             // negative value of multiplier
wire [2*DATAWIDTH+1:0]  data_in1,data_in2,sum;

adder_66 adder1(
  .A(data_in1),
  .B(data_in2),
  .S(sum),
  .c66()
);


always @(posedge clk or negedge rstn)
  if (!rstn) current_state <= IDLE;
  else current_state <= next_state;

// state transform
always @(*) begin
  next_state = 2'bx;
  case (current_state)
    IDLE  : if (en) next_state <= ADD;
            else    next_state <= IDLE;
    ADD   : next_state <= SHIFT;
    SHIFT : if (iter_cnt==DATAWIDTH) next_state <= OUTPUT;
            else            next_state <= ADD;
    OUTPUT: next_state <= IDLE;
  endcase
end

// negative value of multiplier.
assign multiplier_neg = -{multiplier[DATAWIDTH-1],multiplier};//取补码，相当于每一位取反，然后加1
assign data_in1 =     p_reg;
assign data_in2 =    (p_reg[1:0]==2'b01)?a_reg:// + multiplier
                     (p_reg[1:0]==2'b10)?s_reg:// - multiplier
                                      0;       // nop

// algorithm implemenation details.
always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    {a_reg,s_reg,p_reg,iter_cnt,done,sum_reg,product} <= 0;
  end else begin
  case (current_state)
    IDLE :  begin
      a_reg    <= {multiplier[DATAWIDTH-1],multiplier,{(DATAWIDTH+1){1'b0}}};
      s_reg    <= {multiplier_neg,{(DATAWIDTH+1){1'b0}}};
      p_reg    <= {{(DATAWIDTH+1){1'b0}},multiplicand,1'b0};
      iter_cnt <= 0;
      done     <= 1'b0;
    end
    ADD  :  begin
      sum_reg <= sum;
      iter_cnt <= iter_cnt + 1;
    end
    SHIFT :  begin
      p_reg <= {sum_reg[2*DATAWIDTH+1],sum_reg[2*DATAWIDTH+1:1]}; // right shift 
    end
    OUTPUT : begin
      product <= p_reg[2*DATAWIDTH:1];
      done <= 1'b1;
    end
  endcase
 end
end

endmodule


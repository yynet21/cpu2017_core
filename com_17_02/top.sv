module top #(
  parameter INST_LEN = 18,
  parameter DATA_LEN = 20,
  parameter REG_LEN  = 32
)(
  input logic CLK_P,
  input logic CLK_N,
  input logic SW_N,
  input logic SW_S,
  input logic SW_E,
  input logic SW_W,
	output logic[7:0] LED
);
	logic clk;
	int counter;
	logic[31:0] pc=0;
	//logic status;
	enum logic {
		LOAD,
		RUN
	} status = LOAD;
	IBUFGDS ibufgds(.I(CLK_P), .IB(CLK_N), .O(clk));

  logic[REG_LEN-1:0] mem_inst[REG_LEN];
  logic[REG_LEN-1:0] mem_data[REG_LEN];
  logic[REG_LEN-1:0][REG_LEN-1:0] reg_data = {{31{32'bx}}, 32'b0};

/*算術、論理、シフト(整数型)*/
  localparam OP_A = 6'b000000;
  localparam OP_B = 6'b010001;
  localparam FUNC_ADD =6'b100000;
  localparam FUNC_SUB =6'b100010;
//  localparam FUNC_SUBI =6'b000000;
//  localparam FUNC_MUL =6'b000000;
  localparam FUNC_AND =6'b100100;
//  localparam FUNC_ANDI =6'b000000;
  localparam FUNC_OR  =6'b100101;
//  localparam FUNC_ORI =6'b000000;
  localparam FUNC_NOR =6'b100111;

  localparam FUNC_SLL =6'b000000;
  localparam FUNC_SRL =6'b000010;

  localparam FUNC_JR  =6'b001000;

  //localparam DATA_LD =6'b000000;
  //localparam DATA_SD =6'b000000;

  localparam DATA_BEQ =6'b000100;
  localparam DATA_BNE =6'b000101;
  localparam DATA_J   =6'b000010;
  localparam DATA_JAL =6'b000011;

/*算術、論理、シフト(浮動小数点型)
  localparam F_FUNC_ADD =6'b000000;
  localparam F_FUNC_ADD =6'b000000;
  localparam F_FUNC_ADD =6'b000000;
  localparam F_FUNC_ADD =6'b000000;
  localparam F_FUNC_ADD =6'b000000;
  localparam F_FUNC_ADD =6'b000000;
  localparam F_FUNC_ADD =6'b000000;*/
  /*データ転送*/  /*条件分岐*/

  localparam DATA_ADDI = 6'b001000;
  localparam DATA_BEQ = 6'b000100;
  localparam DATA_LW = 6'b000011;
  localparam DATA_LUI = 6'b001111;
  localparam DATA_SW = 6'b101011;
  localparam DATA_IN = 6'b011010;
  localparam DATA_OUT = 6'b011011;

/*  localparam OP_XXX = 6'b000000;
  localparam OP_XXX = 6'b000000;
  localparam OP_XXX = 6'b000000;
  localparam OP_XXX = 6'b000000;*/

  //assign inst = mem_inst[pc];
  logic[31:0] inst;
 // assign inst = 32'h00020820;
  assign inst = 32'h92345676;
  assign LED[7] = (status == RUN) ;
  always @(posedge clk) begin
    if (SW_N) begin
      status <= LOAD;
    end

    if (SW_S) begin
      status <= RUN;
    end

    if (status==LOAD) begin

    end

    if (status==RUN) begin
    case(inst[31:26])
        OP_A:
          case(inst[5:0])
            FUNC_ADD: reg_data[inst[15:11]] <= reg_data[inst[25:21]]+reg_data[inst[20:16]];
            FUNC_SUB: reg_data[inst[15:11]] <= reg_data[inst[25:21]]-reg_data[inst[20:16]];
            FUNC_AND: reg_data[inst[15:11]] <= reg_data[inst[25:21]]&reg_data[inst[20:16]];
            FUNC_OR:  reg_data[inst[15:11]] <= reg_data[inst[25:21]]|reg_data[inst[20:16]];
            FUNC_NOR: reg_data[inst[15:11]] <= ~(reg_data[inst[25:21]]|reg_data[inst[20:16]]);
            FUNC_SLL: reg_data[inst[15:11]] <= reg_data[inst[20:16]] << inst[10:6];
            FUNC_SRL: reg_data[inst[15:11]] <= reg_data[inst[20:16]] >> inst[10:6];
            FUNC_JR:  reg_data[inst[15:11]] <= pc+1 ;
            FUNC_SLT: reg_data[inst[15:11]] <= (reg_data[inst[25:21]] <= reg_data[inst[20:16]]);
          endcase
       OP_B:
          case(inst[5:0])
             /*F_FUNC_ADD:;
             F_FUNC_SUB:;
             F_FUNC_AND:;
             F_FUNC_OR:;
             F_FUNC_NOR:;
             F_FUNC_SLW:;
             F_FUNC_SRW:;
             F_FUNC_BB:;*/
          endcase
        DATA_ADDI:reg_data[inst[20:16]] <= reg_data[inst[25:21]]+inst[15:0];
        DATA_BEQ:
        DATA_BNE:
        DATA_J:
        DATA_JAL:
        DATA_LW:
        DATA_LUI:
        DATA_SW:
        DATA_IN:
        DATA_OUT:

       /* DATA_LW:				OP_LW  : if (stage[0]) gpr[inst[20:16]] <= data_mem_out;

        DATA_SW:;
        DATA_BEQ:;
        DATA_BNE:;
        DATA_J:;
        DATA_JAL:;
        */
     endcase
    end

		if (counter==99) begin
			counter <= 0;
		end else begin
			counter <= counter+1;
		end
      pc <= pc + 1;
      LED[2:0] <= inst[2:0];
      LED[3] <= inst[31];
      LED[6:4] <=pc%8;
      //LED[6:4] <= (pc>>18)%8;
  end

endmodule

module alu(
    input wire [31:0] op1,
    input wire [31:0] op2,
    input wire [3:0] alu_op,
    output wire zero,
    output reg  [31:0] result,
    output reg ovf
);

    parameter [3:0] ALUOP_AND  = 4'b1000;
    parameter [3:0] ALUOP_OR   = 4'b1001;
    parameter [3:0] ALUOP_NOR  = 4'b1010;
    parameter [3:0] ALUOP_NAND = 4'b1011;
    parameter [3:0] ALUOP_XOR  = 4'b1100;
    parameter [3:0] ALUOP_ADD  = 4'b0100;
    parameter [3:0] ALUOP_SUB  = 4'b0101;
    parameter [3:0] ALUOP_MULT = 4'b0110;
    parameter [3:0] ALUOP_LSR  = 4'b0000;
    parameter [3:0] ALUOP_LSL  = 4'b0001;
    parameter [3:0] ALUOP_ASR  = 4'b0010;
    parameter [3:0] ALUOP_ASL  = 4'b0011;

    assign zero = (result == 32'b0);

    reg [63:0] mult_res;

    always @(*) 
        begin
        result = 32'b0;
        ovf = 1'b0;
        mult_res = 64'b0;

        case(alu_op)
            ALUOP_AND:  result = op1 & op2;
            ALUOP_OR:   result = op1 | op2;
            ALUOP_NOR:  result = ~(op1 | op2);
            ALUOP_NAND: result = ~(op1 & op2);
            ALUOP_XOR:  result = op1 ^ op2;

            ALUOP_ADD: begin
                result = op1 + op2;
                if (op1[31] == op2[31] && result[31] != op1[31])
                    ovf = 1'b1;
            end

            ALUOP_SUB: begin
                result = op1 - op2;
                if (op1[31] != op2[31] && result[31] != op1[31])
                    ovf = 1'b1;
            end

            ALUOP_MULT: begin
                mult_res = $signed(op1) * $signed(op2);
                result = mult_res[31:0];
                if (mult_res != {{32{result[31]}}, result}) 
                    ovf = 1'b1;
            end

            ALUOP_LSR: result = op1 >> op2;
            ALUOP_LSL: result = op1 << op2;
            ALUOP_ASR: result = $signed(op1) >>> op2;
            ALUOP_ASL: result = $signed(op1) <<< op2; 
            default: result = 32'b0;
        endcase
    end

endmodule
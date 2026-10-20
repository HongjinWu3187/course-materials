module ALU #(
    parameter ENABLE_MUL = 1'b0
)(
    input  [31:0] in1,
    input  [31:0] in2,
    input  [4:0]  alu_ctl,
    output reg [31:0] out,
    output        zero
);

    localparam ALU_AND  = 5'd0;
    localparam ALU_OR   = 5'd1;
    localparam ALU_ADD  = 5'd2;
    localparam ALU_SUB  = 5'd3;
    localparam ALU_SLT  = 5'd4;
    localparam ALU_NOR  = 5'd5;
    localparam ALU_XOR  = 5'd6;
    localparam ALU_SLL  = 5'd7;
    localparam ALU_SRL  = 5'd8;
    localparam ALU_SRA  = 5'd9;
    localparam ALU_SLTU = 5'd10;
    localparam ALU_MUL  = 5'd11;

    assign zero = (out == 32'b0);

    always @(*) begin
        case (alu_ctl)
            ALU_AND:  out = in1 & in2;
            ALU_OR:   out = in1 | in2;
            ALU_ADD:  out = in1 + in2;
            ALU_SUB:  out = in1 - in2;
            ALU_SLT:  out = ($signed(in1) < $signed(in2)) ? 32'd1 : 32'd0;
            ALU_NOR:  out = ~(in1 | in2);
            ALU_XOR:  out = in1 ^ in2;
            ALU_SLL:  out = in2 << in1[4:0];
            ALU_SRL:  out = in2 >> in1[4:0];
            ALU_SRA:  out = $signed(in2) >>> in1[4:0];
            ALU_SLTU: out = (in1 < in2) ? 32'd1 : 32'd0;
            ALU_MUL:  out = ENABLE_MUL ? (in1 * in2) : 32'b0;
            default:  out = 32'b0;
        endcase
    end

endmodule

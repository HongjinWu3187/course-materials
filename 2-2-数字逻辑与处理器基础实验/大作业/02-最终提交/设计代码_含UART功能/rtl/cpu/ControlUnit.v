module ControlUnit(
    input  [31:0] instr,
    output reg        reg_write,
    output reg [1:0]  reg_dst,
    output reg        mem_read,
    output reg        mem_write,
    output reg [1:0]  result_src,
    output reg        alu_src1_shamt,
    output reg        alu_src2_imm,
    output reg        imm_zero_ext,
    output reg        imm_lui,
    output reg [4:0]  alu_ctl,
    output reg [2:0]  branch_type,
    output reg [1:0]  jump_type,
    output reg        uses_rs,
    output reg        uses_rt
);

    localparam DEST_RT = 2'd0;
    localparam DEST_RD = 2'd1;
    localparam DEST_RA = 2'd2;

    localparam RES_ALU  = 2'd0;
    localparam RES_MEM  = 2'd1;
    localparam RES_LINK = 2'd2;

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

    localparam BR_NONE = 3'd0;
    localparam BR_BEQ  = 3'd1;
    localparam BR_BNE  = 3'd2;
    localparam BR_BLEZ = 3'd3;
    localparam BR_BGTZ = 3'd4;
    localparam BR_BLTZ = 3'd5;
    localparam BR_BGEZ = 3'd6;

    localparam JP_NONE = 2'd0;
    localparam JP_ABS  = 2'd1;
    localparam JP_REG  = 2'd2;

    wire [5:0] op;
    wire [4:0] rt;
    wire [5:0] funct;

    assign op    = instr[31:26];
    assign rt    = instr[20:16];
    assign funct = instr[5:0];

    always @(*) begin
        reg_write      = 1'b0;
        reg_dst        = DEST_RT;
        mem_read       = 1'b0;
        mem_write      = 1'b0;
        result_src     = RES_ALU;
        alu_src1_shamt = 1'b0;
        alu_src2_imm   = 1'b0;
        imm_zero_ext   = 1'b0;
        imm_lui        = 1'b0;
        alu_ctl        = ALU_ADD;
        branch_type    = BR_NONE;
        jump_type      = JP_NONE;
        uses_rs        = 1'b0;
        uses_rt        = 1'b0;

        case (op)
            6'h00: begin
                case (funct)
                    6'h00: begin // sll, also nop when instr is 0
                        reg_write      = (instr != 32'b0);
                        reg_dst        = DEST_RD;
                        alu_src1_shamt = 1'b1;
                        alu_ctl        = ALU_SLL;
                        uses_rt        = (instr != 32'b0);
                    end
                    6'h02: begin
                        reg_write      = 1'b1;
                        reg_dst        = DEST_RD;
                        alu_src1_shamt = 1'b1;
                        alu_ctl        = ALU_SRL;
                        uses_rt        = 1'b1;
                    end
                    6'h03: begin
                        reg_write      = 1'b1;
                        reg_dst        = DEST_RD;
                        alu_src1_shamt = 1'b1;
                        alu_ctl        = ALU_SRA;
                        uses_rt        = 1'b1;
                    end
                    6'h08: begin
                        jump_type = JP_REG; // jr
                        uses_rs   = 1'b1;
                    end
                    6'h09: begin
                        reg_write = 1'b1;   // jalr
                        reg_dst   = DEST_RD;
                        result_src = RES_LINK;
                        jump_type = JP_REG;
                        uses_rs   = 1'b1;
                    end
                    6'h20, 6'h21: begin
                        reg_write = 1'b1;
                        reg_dst   = DEST_RD;
                        alu_ctl   = ALU_ADD;
                        uses_rs   = 1'b1;
                        uses_rt   = 1'b1;
                    end
                    6'h22, 6'h23: begin
                        reg_write = 1'b1;
                        reg_dst   = DEST_RD;
                        alu_ctl   = ALU_SUB;
                        uses_rs   = 1'b1;
                        uses_rt   = 1'b1;
                    end
                    6'h24: begin
                        reg_write = 1'b1;
                        reg_dst   = DEST_RD;
                        alu_ctl   = ALU_AND;
                        uses_rs   = 1'b1;
                        uses_rt   = 1'b1;
                    end
                    6'h25: begin
                        reg_write = 1'b1;
                        reg_dst   = DEST_RD;
                        alu_ctl   = ALU_OR;
                        uses_rs   = 1'b1;
                        uses_rt   = 1'b1;
                    end
                    6'h26: begin
                        reg_write = 1'b1;
                        reg_dst   = DEST_RD;
                        alu_ctl   = ALU_XOR;
                        uses_rs   = 1'b1;
                        uses_rt   = 1'b1;
                    end
                    6'h27: begin
                        reg_write = 1'b1;
                        reg_dst   = DEST_RD;
                        alu_ctl   = ALU_NOR;
                        uses_rs   = 1'b1;
                        uses_rt   = 1'b1;
                    end
                    6'h2a: begin
                        reg_write = 1'b1;
                        reg_dst   = DEST_RD;
                        alu_ctl   = ALU_SLT;
                        uses_rs   = 1'b1;
                        uses_rt   = 1'b1;
                    end
                    6'h2b: begin
                        reg_write = 1'b1;
                        reg_dst   = DEST_RD;
                        alu_ctl   = ALU_SLTU;
                        uses_rs   = 1'b1;
                        uses_rt   = 1'b1;
                    end
                endcase
            end

            6'h01: begin
                uses_rs = 1'b1;
                if (rt == 5'h00)
                    branch_type = BR_BLTZ;
                else if (rt == 5'h01)
                    branch_type = BR_BGEZ;
            end

            6'h02: begin
                jump_type = JP_ABS; // j
            end

            6'h03: begin
                reg_write = 1'b1;   // jal
                reg_dst   = DEST_RA;
                result_src = RES_LINK;
                jump_type = JP_ABS;
            end

            6'h04: begin
                branch_type = BR_BEQ;
                alu_ctl     = ALU_SUB;
                uses_rs     = 1'b1;
                uses_rt     = 1'b1;
            end

            6'h05: begin
                branch_type = BR_BNE;
                alu_ctl     = ALU_SUB;
                uses_rs     = 1'b1;
                uses_rt     = 1'b1;
            end

            6'h06: begin
                branch_type = BR_BLEZ;
                uses_rs     = 1'b1;
            end

            6'h07: begin
                branch_type = BR_BGTZ;
                uses_rs     = 1'b1;
            end

            6'h08, 6'h09: begin // addi, addiu
                reg_write    = 1'b1;
                alu_src2_imm = 1'b1;
                alu_ctl      = ALU_ADD;
                uses_rs      = 1'b1;
            end

            6'h0a: begin // slti
                reg_write    = 1'b1;
                alu_src2_imm = 1'b1;
                alu_ctl      = ALU_SLT;
                uses_rs      = 1'b1;
            end

            6'h0b: begin // sltiu
                reg_write    = 1'b1;
                alu_src2_imm = 1'b1;
                alu_ctl      = ALU_SLTU;
                uses_rs      = 1'b1;
            end

            6'h0c: begin // andi
                reg_write    = 1'b1;
                alu_src2_imm = 1'b1;
                imm_zero_ext = 1'b1;
                alu_ctl      = ALU_AND;
                uses_rs      = 1'b1;
            end

            6'h0d: begin // ori
                reg_write    = 1'b1;
                alu_src2_imm = 1'b1;
                imm_zero_ext = 1'b1;
                alu_ctl      = ALU_OR;
                uses_rs      = 1'b1;
            end

            6'h0e: begin // xori
                reg_write    = 1'b1;
                alu_src2_imm = 1'b1;
                imm_zero_ext = 1'b1;
                alu_ctl      = ALU_XOR;
                uses_rs      = 1'b1;
            end

            6'h0f: begin // lui
                reg_write    = 1'b1;
                alu_src2_imm = 1'b1;
                imm_lui      = 1'b1;
                alu_ctl      = ALU_ADD;
            end

            6'h1c: begin
                if (funct == 6'h02) begin // mul
                    reg_write = 1'b1;
                    reg_dst   = DEST_RD;
                    alu_ctl   = ALU_MUL;
                    uses_rs   = 1'b1;
                    uses_rt   = 1'b1;
                end
            end

            6'h23: begin // lw
                reg_write    = 1'b1;
                mem_read     = 1'b1;
                result_src   = RES_MEM;
                alu_src2_imm = 1'b1;
                alu_ctl      = ALU_ADD;
                uses_rs      = 1'b1;
            end

            6'h2b: begin // sw
                mem_write    = 1'b1;
                alu_src2_imm = 1'b1;
                alu_ctl      = ALU_ADD;
                uses_rs      = 1'b1;
                uses_rt      = 1'b1;
            end
        endcase
    end

endmodule

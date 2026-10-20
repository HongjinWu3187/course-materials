module PipelineCPU(
    input         clk,
    input         reset,
    output [31:0] instr_addr,
    input  [31:0] instr_rdata,
    output        data_mem_read,
    output        data_mem_write,
    output [31:0] data_addr,
    output [31:0] data_wdata,
    input  [31:0] data_rdata,
    output [31:0] debug_pc,
    output [31:0] debug_wb_pc,
    output        debug_wb_reg_write,
    output [4:0]  debug_wb_reg,
    output [31:0] debug_wb_data
);

    localparam NOP = 32'h00000000;

    localparam DEST_RT = 2'd0;
    localparam DEST_RD = 2'd1;
    localparam DEST_RA = 2'd2;

    localparam RES_ALU  = 2'd0;
    localparam RES_MEM  = 2'd1;
    localparam RES_LINK = 2'd2;

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

    reg [31:0] pc;

    reg [31:0] if_id_pc;
    reg [31:0] if_id_pc4;
    reg [31:0] if_id_instr;

    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_pc4;
    reg [31:0] id_ex_rs_data;
    reg [31:0] id_ex_rt_data;
    reg [31:0] id_ex_imm;
    reg [4:0]  id_ex_rs;
    reg [4:0]  id_ex_rt;
    reg [4:0]  id_ex_shamt;
    reg [4:0]  id_ex_write_reg;
    reg        id_ex_reg_write;
    reg        id_ex_mem_read;
    reg        id_ex_mem_write;
    reg [1:0]  id_ex_result_src;
    reg        id_ex_alu_src1_shamt;
    reg        id_ex_alu_src2_imm;
    reg [4:0]  id_ex_alu_ctl;
    reg [2:0]  id_ex_branch_type;
    reg [31:0] id_ex_link_value;

    reg [31:0] ex_mem_pc;
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_write_data;
    reg [31:0] ex_mem_link_value;
    reg [4:0]  ex_mem_write_reg;
    reg        ex_mem_reg_write;
    reg        ex_mem_mem_read;
    reg        ex_mem_mem_write;
    reg [1:0]  ex_mem_result_src;

    reg [31:0] mem_wb_pc;
    reg [31:0] mem_wb_alu_result;
    reg [31:0] mem_wb_mem_data;
    reg [31:0] mem_wb_link_value;
    reg [4:0]  mem_wb_write_reg;
    reg        mem_wb_reg_write;
    reg [1:0]  mem_wb_result_src;

    wire [31:0] pc4;
    wire [31:0] pc_next;
    wire        pc_write;

    assign pc4 = pc + 32'd4;
    assign instr_addr = pc;
    assign debug_pc = pc;

    wire [5:0] id_op;
    wire [4:0] id_rs;
    wire [4:0] id_rt;
    wire [4:0] id_rd;
    wire [4:0] id_shamt;
    wire [15:0] id_imm16;

    assign id_op    = if_id_instr[31:26];
    assign id_rs    = if_id_instr[25:21];
    assign id_rt    = if_id_instr[20:16];
    assign id_rd    = if_id_instr[15:11];
    assign id_shamt = if_id_instr[10:6];
    assign id_imm16 = if_id_instr[15:0];

    wire        id_reg_write;
    wire [1:0]  id_reg_dst;
    wire        id_mem_read;
    wire        id_mem_write;
    wire [1:0]  id_result_src;
    wire        id_alu_src1_shamt;
    wire        id_alu_src2_imm;
    wire        id_imm_zero_ext;
    wire        id_imm_lui;
    wire [4:0]  id_alu_ctl;
    wire [2:0]  id_branch_type;
    wire [1:0]  id_jump_type;
    wire        id_uses_rs;
    wire        id_uses_rt;

    ControlUnit control_unit(
        .instr          (if_id_instr),
        .reg_write      (id_reg_write),
        .reg_dst        (id_reg_dst),
        .mem_read       (id_mem_read),
        .mem_write      (id_mem_write),
        .result_src     (id_result_src),
        .alu_src1_shamt (id_alu_src1_shamt),
        .alu_src2_imm   (id_alu_src2_imm),
        .imm_zero_ext   (id_imm_zero_ext),
        .imm_lui        (id_imm_lui),
        .alu_ctl        (id_alu_ctl),
        .branch_type    (id_branch_type),
        .jump_type      (id_jump_type),
        .uses_rs        (id_uses_rs),
        .uses_rt        (id_uses_rt)
    );

    wire [31:0] wb_write_data;
    assign wb_write_data = (mem_wb_result_src == RES_MEM)  ? mem_wb_mem_data :
                           (mem_wb_result_src == RES_LINK) ? mem_wb_link_value :
                                                             mem_wb_alu_result;

    wire [31:0] id_rs_data;
    wire [31:0] id_rt_data;

    RegisterFile register_file(
        .clk         (clk),
        .reset       (reset),
        .reg_write   (mem_wb_reg_write),
        .read_reg1   (id_rs),
        .read_reg2   (id_rt),
        .write_reg   (mem_wb_write_reg),
        .write_data  (wb_write_data),
        .read_data1  (id_rs_data),
        .read_data2  (id_rt_data)
    );

    wire [31:0] id_imm_ext;
    assign id_imm_ext = id_imm_lui      ? {id_imm16, 16'b0} :
                        id_imm_zero_ext ? {16'b0, id_imm16} :
                                          {{16{id_imm16[15]}}, id_imm16};

    reg [4:0] id_write_reg;
    always @(*) begin
        case (id_reg_dst)
            DEST_RD: id_write_reg = id_rd;
            DEST_RA: id_write_reg = 5'd31;
            default: id_write_reg = id_rt;
        endcase
    end

    wire id_jump_reg;
    wire id_jump_any;
    wire [31:0] id_jump_abs_target;
    wire [31:0] id_jump_reg_target;
    wire [31:0] id_jump_target;

    assign id_jump_reg        = (id_jump_type == JP_REG);
    assign id_jump_any        = (id_jump_type != JP_NONE);
    assign id_jump_abs_target = {if_id_pc4[31:28], if_id_instr[25:0], 2'b00};
    assign id_jump_reg_target = id_rs_data;
    assign id_jump_target     = id_jump_reg ? id_jump_reg_target : id_jump_abs_target;

    wire stall;
    HazardUnit hazard_unit(
        .id_ex_mem_read   (id_ex_mem_read),
        .id_ex_rt         (id_ex_rt),
        .if_id_rs         (id_rs),
        .if_id_rt         (id_rt),
        .if_id_uses_rs    (id_uses_rs),
        .if_id_uses_rt    (id_uses_rt),
        .if_id_jump_reg   (id_jump_reg),
        .id_ex_reg_write  (id_ex_reg_write),
        .id_ex_write_reg  (id_ex_write_reg),
        .ex_mem_reg_write (ex_mem_reg_write),
        .ex_mem_write_reg (ex_mem_write_reg),
        .stall            (stall)
    );

    wire [31:0] ex_mem_forward_data;
    wire        ex_mem_can_forward;
    assign ex_mem_forward_data = (ex_mem_result_src == RES_LINK) ? ex_mem_link_value : ex_mem_alu_result;
    assign ex_mem_can_forward  = (ex_mem_result_src != RES_MEM);

    wire [1:0] forward_a;
    wire [1:0] forward_b;
    ForwardingUnit forwarding_unit(
        .id_ex_rs           (id_ex_rs),
        .id_ex_rt           (id_ex_rt),
        .ex_mem_reg_write   (ex_mem_reg_write),
        .ex_mem_can_forward (ex_mem_can_forward),
        .ex_mem_write_reg   (ex_mem_write_reg),
        .mem_wb_reg_write   (mem_wb_reg_write),
        .mem_wb_write_reg   (mem_wb_write_reg),
        .forward_a          (forward_a),
        .forward_b          (forward_b)
    );

    reg [31:0] ex_forward_rs;
    reg [31:0] ex_forward_rt;
    always @(*) begin
        case (forward_a)
            2'b10: ex_forward_rs = ex_mem_forward_data;
            2'b01: ex_forward_rs = wb_write_data;
            default: ex_forward_rs = id_ex_rs_data;
        endcase

        case (forward_b)
            2'b10: ex_forward_rt = ex_mem_forward_data;
            2'b01: ex_forward_rt = wb_write_data;
            default: ex_forward_rt = id_ex_rt_data;
        endcase
    end

    wire [31:0] ex_alu_in1;
    wire [31:0] ex_alu_in2;
    wire [31:0] ex_alu_result;
    wire        ex_alu_zero;

    assign ex_alu_in1 = id_ex_alu_src1_shamt ? {27'b0, id_ex_shamt} : ex_forward_rs;
    assign ex_alu_in2 = id_ex_alu_src2_imm   ? id_ex_imm : ex_forward_rt;

    ALU #(
        .ENABLE_MUL(1'b0)
    ) alu (
        .in1     (ex_alu_in1),
        .in2     (ex_alu_in2),
        .alu_ctl (id_ex_alu_ctl),
        .out     (ex_alu_result),
        .zero    (ex_alu_zero)
    );

    reg ex_branch_taken;
    always @(*) begin
        ex_branch_taken = 1'b0;
        case (id_ex_branch_type)
            BR_BEQ:  ex_branch_taken = (ex_forward_rs == ex_forward_rt);
            BR_BNE:  ex_branch_taken = (ex_forward_rs != ex_forward_rt);
            BR_BLEZ: ex_branch_taken = ($signed(ex_forward_rs) <= 0);
            BR_BGTZ: ex_branch_taken = ($signed(ex_forward_rs) > 0);
            BR_BLTZ: ex_branch_taken = ($signed(ex_forward_rs) < 0);
            BR_BGEZ: ex_branch_taken = ($signed(ex_forward_rs) >= 0);
            default: ex_branch_taken = 1'b0;
        endcase
    end

    wire [31:0] ex_branch_target;
    assign ex_branch_target = id_ex_pc4 + {id_ex_imm[29:0], 2'b00};

    wire id_jump_take;
    assign id_jump_take = id_jump_any && !stall;

    assign pc_next = ex_branch_taken ? ex_branch_target :
                     id_jump_take    ? id_jump_target :
                                       pc4;
    assign pc_write = ex_branch_taken || !stall;

    assign data_mem_read  = ex_mem_mem_read;
    assign data_mem_write = ex_mem_mem_write;
    assign data_addr      = ex_mem_alu_result;
    assign data_wdata     = ex_mem_write_data;

    assign debug_wb_pc        = mem_wb_pc;
    assign debug_wb_reg_write = mem_wb_reg_write;
    assign debug_wb_reg       = mem_wb_write_reg;
    assign debug_wb_data      = wb_write_data;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'b0;
        end else if (pc_write) begin
            pc <= pc_next;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            if_id_pc    <= 32'b0;
            if_id_pc4   <= 32'b0;
            if_id_instr <= NOP;
        end else if (ex_branch_taken) begin
            if_id_pc    <= 32'b0;
            if_id_pc4   <= 32'b0;
            if_id_instr <= NOP;
        end else if (id_jump_take) begin
            if_id_pc    <= 32'b0;
            if_id_pc4   <= 32'b0;
            if_id_instr <= NOP;
        end else if (!stall) begin
            if_id_pc    <= pc;
            if_id_pc4   <= pc4;
            if_id_instr <= instr_rdata;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            id_ex_pc             <= 32'b0;
            id_ex_pc4            <= 32'b0;
            id_ex_rs_data        <= 32'b0;
            id_ex_rt_data        <= 32'b0;
            id_ex_imm            <= 32'b0;
            id_ex_rs             <= 5'b0;
            id_ex_rt             <= 5'b0;
            id_ex_shamt          <= 5'b0;
            id_ex_write_reg      <= 5'b0;
            id_ex_reg_write      <= 1'b0;
            id_ex_mem_read       <= 1'b0;
            id_ex_mem_write      <= 1'b0;
            id_ex_result_src     <= RES_ALU;
            id_ex_alu_src1_shamt <= 1'b0;
            id_ex_alu_src2_imm   <= 1'b0;
            id_ex_alu_ctl        <= 5'd2;
            id_ex_branch_type    <= BR_NONE;
            id_ex_link_value     <= 32'b0;
        end else if (ex_branch_taken || stall) begin
            id_ex_pc             <= 32'b0;
            id_ex_pc4            <= 32'b0;
            id_ex_rs_data        <= 32'b0;
            id_ex_rt_data        <= 32'b0;
            id_ex_imm            <= 32'b0;
            id_ex_rs             <= 5'b0;
            id_ex_rt             <= 5'b0;
            id_ex_shamt          <= 5'b0;
            id_ex_write_reg      <= 5'b0;
            id_ex_reg_write      <= 1'b0;
            id_ex_mem_read       <= 1'b0;
            id_ex_mem_write      <= 1'b0;
            id_ex_result_src     <= RES_ALU;
            id_ex_alu_src1_shamt <= 1'b0;
            id_ex_alu_src2_imm   <= 1'b0;
            id_ex_alu_ctl        <= 5'd2;
            id_ex_branch_type    <= BR_NONE;
            id_ex_link_value     <= 32'b0;
        end else begin
            id_ex_pc             <= if_id_pc;
            id_ex_pc4            <= if_id_pc4;
            id_ex_rs_data        <= id_rs_data;
            id_ex_rt_data        <= id_rt_data;
            id_ex_imm            <= id_imm_ext;
            id_ex_rs             <= id_rs;
            id_ex_rt             <= id_rt;
            id_ex_shamt          <= id_shamt;
            id_ex_write_reg      <= id_write_reg;
            id_ex_reg_write      <= id_reg_write;
            id_ex_mem_read       <= id_mem_read;
            id_ex_mem_write      <= id_mem_write;
            id_ex_result_src     <= id_result_src;
            id_ex_alu_src1_shamt <= id_alu_src1_shamt;
            id_ex_alu_src2_imm   <= id_alu_src2_imm;
            id_ex_alu_ctl        <= id_alu_ctl;
            id_ex_branch_type    <= id_branch_type;
            id_ex_link_value     <= if_id_pc4;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem_pc          <= 32'b0;
            ex_mem_alu_result  <= 32'b0;
            ex_mem_write_data  <= 32'b0;
            ex_mem_link_value  <= 32'b0;
            ex_mem_write_reg   <= 5'b0;
            ex_mem_reg_write   <= 1'b0;
            ex_mem_mem_read    <= 1'b0;
            ex_mem_mem_write   <= 1'b0;
            ex_mem_result_src  <= RES_ALU;
        end else begin
            ex_mem_pc          <= id_ex_pc;
            ex_mem_alu_result  <= ex_alu_result;
            ex_mem_write_data  <= ex_forward_rt;
            ex_mem_link_value  <= id_ex_link_value;
            ex_mem_write_reg   <= id_ex_write_reg;
            ex_mem_reg_write   <= id_ex_reg_write;
            ex_mem_mem_read    <= id_ex_mem_read;
            ex_mem_mem_write   <= id_ex_mem_write;
            ex_mem_result_src  <= id_ex_result_src;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_pc          <= 32'b0;
            mem_wb_alu_result  <= 32'b0;
            mem_wb_mem_data    <= 32'b0;
            mem_wb_link_value  <= 32'b0;
            mem_wb_write_reg   <= 5'b0;
            mem_wb_reg_write   <= 1'b0;
            mem_wb_result_src  <= RES_ALU;
        end else begin
            mem_wb_pc          <= ex_mem_pc;
            mem_wb_alu_result  <= ex_mem_alu_result;
            mem_wb_mem_data    <= data_rdata;
            mem_wb_link_value  <= ex_mem_link_value;
            mem_wb_write_reg   <= ex_mem_write_reg;
            mem_wb_reg_write   <= ex_mem_reg_write;
            mem_wb_result_src  <= ex_mem_result_src;
        end
    end

endmodule

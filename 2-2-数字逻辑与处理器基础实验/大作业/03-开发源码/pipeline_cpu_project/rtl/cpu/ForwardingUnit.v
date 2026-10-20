module ForwardingUnit(
    input  [4:0] id_ex_rs,
    input  [4:0] id_ex_rt,
    input        ex_mem_reg_write,
    input        ex_mem_can_forward,
    input  [4:0] ex_mem_write_reg,
    input        mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        if (ex_mem_reg_write && ex_mem_can_forward && ex_mem_write_reg != 5'd0 && ex_mem_write_reg == id_ex_rs)
            forward_a = 2'b10;
        else if (mem_wb_reg_write && mem_wb_write_reg != 5'd0 && mem_wb_write_reg == id_ex_rs)
            forward_a = 2'b01;

        if (ex_mem_reg_write && ex_mem_can_forward && ex_mem_write_reg != 5'd0 && ex_mem_write_reg == id_ex_rt)
            forward_b = 2'b10;
        else if (mem_wb_reg_write && mem_wb_write_reg != 5'd0 && mem_wb_write_reg == id_ex_rt)
            forward_b = 2'b01;
    end

endmodule

module RegisterFile(
    input         clk,
    input         reset,
    input         reg_write,
    input  [4:0]  read_reg1,
    input  [4:0]  read_reg2,
    input  [4:0]  write_reg,
    input  [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);

    reg [31:0] regs [31:1];
    integer i;

    assign read_data1 = (read_reg1 == 5'd0) ? 32'b0 :
                        ((reg_write && write_reg == read_reg1 && write_reg != 5'd0) ? write_data : regs[read_reg1]);
    assign read_data2 = (read_reg2 == 5'd0) ? 32'b0 :
                        ((reg_write && write_reg == read_reg2 && write_reg != 5'd0) ? write_data : regs[read_reg2]);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 1; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else if (reg_write && write_reg != 5'd0) begin
            regs[write_reg] <= write_data;
        end
    end

endmodule

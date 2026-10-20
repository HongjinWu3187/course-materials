module SevenSegPeripheral(
    input         clk,
    input         reset,
    input         mem_write,
    input  [31:0] write_data,
    output [7:0]  seg,
    output [3:0]  an,
    output [11:0] raw_value
);

    reg [11:0] value;

    assign raw_value = value;
    assign seg = value[7:0];
    assign an  = value[11:8];

    always @(posedge clk or posedge reset) begin
        if (reset)
            value <= 12'b0;
        else if (mem_write)
            value <= write_data[11:0];
    end

endmodule

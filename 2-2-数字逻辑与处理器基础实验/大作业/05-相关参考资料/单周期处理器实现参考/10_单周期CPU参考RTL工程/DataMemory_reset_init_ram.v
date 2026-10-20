module DataMemory(
	input  reset    , 
	input  clk      ,  
	input  MemRead  ,
	input  MemWrite ,
	input  [32 -1:0] Address    ,
	input  [32 -1:0] Write_data ,
	output [32 -1:0] Read_data
);
	
	// RAM size is 256 words, each word is 32 bits, valid address is 8 bits
	parameter RAM_SIZE      = 256;
	parameter RAM_SIZE_BIT  = 8;
	
	// RAM_data is an array of 256 32-bit registers
	reg [31:0] RAM_data [RAM_SIZE - 1: 0];

	// read data from RAM_data as Read_data
	assign Read_data = MemRead? RAM_data[Address[RAM_SIZE_BIT + 1:2]]: 32'h00000000;
	
	// write Write_data to RAM_data at clock posedge
	integer i;
	always @(posedge reset or posedge clk)begin
		if (reset) begin
			// -------- Paste Data Memory Configuration Below (Data-q1.txt)
			RAM_data[0] <= 32'hffffffd3; // X0 = -45
			RAM_data[1] <= 32'h00000003; // Y0 = 3

			RAM_data[2] <= 32'h00000028; // X1 = 40
			RAM_data[3] <= 32'h00000024; // Y1 = 36


			RAM_data[4] <= 32'hfffffffe; // X2 = -2
			RAM_data[5] <= 32'h00000006; // Y2 = 6

			RAM_data[6] <= 32'hfffffff9; // X3 = -7
			RAM_data[7] <= 32'h0000003a; // Y3 = 58

			for (i = 8; i < RAM_SIZE; i = i + 1)
				RAM_data[i] <= 32'h00000000;
			// -------- Paste Data Memory Configuration Above
		end
		else if (MemWrite) begin
			RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
		end
	end
			
endmodule

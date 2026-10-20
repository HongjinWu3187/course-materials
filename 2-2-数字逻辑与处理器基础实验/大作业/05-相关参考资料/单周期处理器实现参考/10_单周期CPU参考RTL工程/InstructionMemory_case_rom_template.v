module InstructionMemory(
	input      [32 -1:0] Address, 
	output reg [32 -1:0] Instruction
);
	
	always @(*)
		case (Address[9:2])

			// -------- Paste Binary Instruction Below (Inst-q1-1/Inst-q1-2.txt)

			// -------- Paste Binary Instruction Above
			
			default: Instruction <= 32'h00000000;
		endcase
		
endmodule

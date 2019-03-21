module Encoder_Generate_Counter(
	input 			CLOCK_BMQ,				//输入时钟
	output 			CLOCK_Bit,				//输出位时钟
	output [2:0] 	Counter_Bits,			//位计数器
	output [6:0] 	Counter_Channel,		//通道计数器
	output [15:0] 	Counter_Frame			//帧计数器
);
	//变量声明
	reg [31:0]	Counter_CLOCK = 32'D0;		//时钟计数器
	
	always @(posedge CLOCK_BMQ)	begin
		Counter_CLOCK = Counter_CLOCK + 1'B1;
	end

	assign CLOCK_Bit 					= Counter_CLOCK[0];
	assign Counter_Bits[2:0] 		= Counter_CLOCK[3:1];
	assign Counter_Channel[6:0] 	= Counter_CLOCK[10:4];
	assign Counter_Frame[15:0] 	= Counter_CLOCK[26:11];


endmodule

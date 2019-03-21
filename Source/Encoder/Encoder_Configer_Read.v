module Encoder_Configer_Read(
	input 			CLOCK_BMQ,				//时钟
	input [6:0] 	ID_Channel,				//7位通道编号
	output [15:0] 	Configer_Word			//16位配置字
);

	ROM_Encoder 	Encoder_ROM(
		.address(ID_Channel),
		.clock(CLOCK_BMQ),
		.q(Configer_Word)
	);
endmodule

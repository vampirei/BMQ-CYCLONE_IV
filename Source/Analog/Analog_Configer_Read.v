module Analog_Configer_Read(
	input 			CLOCK_BMQ,				//时钟
	input [4:0] 	ID_Analog,				//5位模拟信号采集编号
	output [31:0] 	Configer_Word			//32位配置字
);

	ROM_Analog 	Analog_ROM(
		.address(ID_Analog),
		.clock(CLOCK_BMQ),
		.q(Configer_Word)
	);
	
endmodule

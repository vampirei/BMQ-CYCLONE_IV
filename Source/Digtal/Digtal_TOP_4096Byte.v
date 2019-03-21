module Digtal_TOP_4096Byte(
	input 			Clock_29491200Hz,
	input 			CS_Digtal,
	input 			Rx_Digtal,
	output [7:0] 	Data_Digtal
);

	parameter CLOCK_Frequency = 29491200;		//数字接口时钟频率
	
	parameter BAUD_Digtal = 921600;			//综控波特率
	parameter Rx_Length = 8;						//综控数字接口数据长度
	
	parameter Instert_Length = 4;					//插入字长度，4---8
	parameter Instert_Byte1 = 8'HEB;				//插入字1
	parameter Instert_Byte2 = 8'H90;				//插入字2
	parameter Instert_Byte3 = 8'H90;				//插入字3
	parameter Instert_Byte4 = 8'HEB;				//插入字4
	parameter Instert_Byte5 = 8'HEB;				//插入字5
	parameter Instert_Byte6 = 8'H90;				//插入字6
	parameter Instert_Byte7 = 8'H90;				//插入字7
	parameter Instert_Byte8 = 8'HEB;				//插入字8

//----------------内部声明	
	wire 				Baud16X;							//16倍波特率时钟
	wire 				RD;								//接收模块数据输出时钟
	wire [7:0]		Rx_Data;							//接收模块数据输出
	
	wire [7:0]		RAM_Data_In;					//RAM输入数据
	wire [30:0]		RAM_RDADD;						//RAM读取地址（控制模块输出）
	wire [30:0]		RAM_WRADD;						//RAM写入地址(控制模块输出)
	wire 				RAM_RDEN;						//RAM读请求
	wire				RAM_WREN;						//RAM写请求
	wire [7:0]		RAM_Q;							//RAM数据输出
	//----------------16倍波特率生成
	Digtal_Baud	#(
		.CLOCK_Frequency(CLOCK_Frequency),			//数字接口时钟频率
		.Baud_Frequency(BAUD_Digtal)					//数字接口波特率频率
	)	Baud_16X(
		.Clock(Clock_29491200Hz),									//数字接口时钟
		.Baud16X(Baud16X)									//16倍波特率输出
	);
	
	//---------------接收模块
	Digtal_Rx	#(
		.Rx_Length(Rx_Length)
	)	Receive_Inst(
		.Baud16X(Baud16X),							//16倍波特率输入
		.Rx(Rx_Digtal),								//数据输入
		.RD(RD),								//数据输出时钟
		.Data(Rx_Data)								//数据输出
	);
	
	//--------------RAM读写控制
	Digtal_Main	#(
		.Instert_Length(Instert_Length),
		.Instert_Byte1(Instert_Byte1),
		.Instert_Byte2(Instert_Byte2),
		.Instert_Byte3(Instert_Byte3),
		.Instert_Byte4(Instert_Byte4),
		.Instert_Byte5(Instert_Byte5),
		.Instert_Byte6(Instert_Byte6),
		.Instert_Byte7(Instert_Byte7),
		.Instert_Byte8(Instert_Byte8)
	)	RAM_RW(
		.CLOCK_Digtal(Clock_29491200Hz),					//数字接口时钟
		
		.CS(CS_Digtal),										//片选
		
		.RD(RD),													//接收模块数据输出时钟
		.Rx_Data(Rx_Data),									//接收模块数据输出
		
		.RAM_Data_In(RAM_Data_In),							//RAM数据输入
		.RAM_RDADD(RAM_RDADD),								//RAM读取地址
		.RAM_WRADD(RAM_WRADD),								//RAM写入地址
		.RAM_RDEN(RAM_RDEN),									//RAM读请求
		.RAM_WREN(RAM_WREN),									//RAM写请求
		.RAM_Q(RAM_Q),											//RAM数据输出
		
		.Out_Data(Data_Digtal)										//数据输出
	);
	
	//--------------RAM
	Buffer_4096Byte 	Buffer_Inst(
		.clock(Clock_29491200Hz),
		.data(RAM_Data_In),
		.rdaddress(RAM_RDADD[11:0]),
		.rden(RAM_RDEN),
		.wraddress(RAM_WRADD[11:0]),
		.wren(RAM_WREN),
		.q(RAM_Q)
	);
	
	
	
endmodule

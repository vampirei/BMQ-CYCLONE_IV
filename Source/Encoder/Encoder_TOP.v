module Encoder_TOP(
	input 			CLOCK_BMQ,			//4MHz  
	//模拟接口相关
	output 			CS_Analog,			//模拟接口片选
	output [5:0] 	ID_Analog,			//模拟信号编号
	input [13:0] 	DataBus_Analog,	//模拟接口数据总线
	//数字接口相关
	input [7:0]  	DataBus_Digtal,	//数字接口数据总线
	output [7:0] 	CS_Digtal,			//数字接口片选
	//外部接口相关
	input [7:0]  	DataBus_Extern,	//外部数据总线
	output [7:0] 	CS_Extern,			//外部数据片选
	//PCM输出	
	output 			PCM							//PCM
);

//----------------内部变量
	
	wire 			CLOCK_Bit;							//位时钟
	wire [2:0] 	Counter_Bits;						//位计数
	wire [6:0] 	Counter_Channel;					//通道计数
	wire [15:0] Counter_Frame;						//帧计数
	
	wire [15:0] Configer_Word;						//配置字
	
//----------------读取配置字ROM实例化
	Encoder_Configer_Read	Configer_Inst(
		.CLOCK_BMQ(CLOCK_BMQ),				//时钟
		.ID_Channel(Counter_Channel),		//7位通道编号
		.Configer_Word(Configer_Word)		//16位配置字
	);	
	
//----------------产生位时钟、位计数、通道计数、帧计数
	Encoder_Generate_Counter	CLOCK_Bits_Inst(
		.CLOCK_BMQ(CLOCK_BMQ),						//输入时钟
		.CLOCK_Bit(CLOCK_Bit),						//输出位时钟
		.Counter_Bits(Counter_Bits),				//位计数器
		.Counter_Channel(Counter_Channel),		//通道计数器
		.Counter_Frame(Counter_Frame)				//帧计数器
	);	
	
//----------------编码器
	Encoder_Main	BMQ(
		.CLOCK_Bit(CLOCK_Bit),
		.Counter_Bits(Counter_Bits),
		.Counter_Channel(Counter_Channel),
		.Counter_Frame(Counter_Frame),
		.Configer_Word(Configer_Word),
		.CS_Analog(CS_Analog),
		.ID_Analog(ID_Analog),
		.DataBus_Analog(DataBus_Analog),
		.DataBus_Digtal(DataBus_Digtal),
		.CS_Digtal(CS_Digtal),
		.DataBus_Extern(DataBus_Extern),
		.CS_Extern(CS_Extern),
		.PCM(PCM)
	);	
endmodule

module Analog_TOP(
	input 			CLOCK_BMQ,								//编码器时钟  4MHz
	//Encoder相关
	input 			CS_Analog,								//模拟接口片选--Encoder
	input [5:0]		ID_Analog,								//模拟信号编号--Encoder
	output [13:0]	DataBus_Analog,						//模拟接口数据总线
	//ADG相关
	output [3:0]	CS_ADG,									//ADG片选
	output [3:0]	ADD_ADG,									//ADG地址
	//ADC相关
	input [13:0]	DATA_ADC,								//ADC数据
	input 			EOC_ADC,									//ADC_EOC
	output 			CONVST_ADC,								//ADC_Convst
	output			RD_ADC,									//ADC_RD
	output			CS_ADC									//ADC_CS
);
//---------内部变量
	wire [31:0] Configer_Word;
	wire [4:0] ID_Convst_Analog;
//---------读取配置文件
	Analog_Configer_Read		Configer_Inst(
		.CLOCK_BMQ(CLOCK_BMQ),						//时钟
		.ID_Analog(ID_Convst_Analog),				//5位模拟信号采集编号
		.Configer_Word(Configer_Word)				//32位配置字
	);
//---------模拟采集	
	Analog_Main		Analog_Inst(
	.CLOCK_BMQ(CLOCK_BMQ),
	//配置字相关
	.ID_Convst_Analog(ID_Convst_Analog),				//配置字地址
	.Configer_Word(Configer_Word),			//32位配置字
	//编码器相关
	.CS_Analog(CS_Analog),						//模拟接口片选--Encoder
	.ID_Analog(ID_Analog),						//模拟信号编号--Encoder
	.DataBus_Analog(DataBus_Analog),			//模拟接口数据总线
	//ADG相关
	.CS_ADG(CS_ADG),								//ADG片选
	.ADD_ADG(ADD_ADG),							//ADG地址
	//ADC相关
	.DATA_ADC(DATA_ADC),							//ADC数据
	.EOC_ADC(EOC_ADC),							//ADC_EOC
	.CONVST_ADC(CONVST_ADC),					//ADC_Convst
	.RD_ADC(RD_ADC),								//ADC_RD
	.CS_ADC(CS_ADC)								//ADC_CS
);
endmodule

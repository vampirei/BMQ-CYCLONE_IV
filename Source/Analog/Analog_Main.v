module Analog_Main(
	input 			CLOCK_BMQ,
	//配置字相关
	output [5:0]	ID_Convst_Analog,				//配置字地址
	input [31:0]	Configer_Word,					//32位配置字
	//编码器相关
	input				CS_Analog,						//模拟接口片选--Encoder
	input [5:0]		ID_Analog,						//模拟信号编号--Encoder
	output [13:0]	DataBus_Analog,				//模拟接口数据总线
	//ADG相关
	output [3:0]	CS_ADG,							//ADG片选
	output [3:0]	ADD_ADG,							//ADG地址
	//ADC相关
	input [13:0]	DATA_ADC,						//ADC数据
	input				EOC_ADC,							//ADC_EOC
	output			CONVST_ADC,						//ADC_Convst
	output			RD_ADC,							//ADC_RD
	output			CS_ADC							//ADC_CS
);
//--------------------------------------------------------
//--------------------------------------------------------
//--------------------------------------------------------
	reg [31:0]	Counter_CLOCK = 32'D0;				//时钟计数器
	wire 			CLOCK_Bit;								//位时钟
	wire [2:0]	Counter_Bits;							//位计数器
	wire [6:0]	Counter_Channel;						//通道计数器
	reg [5:0]	ID_Convst_Analog_Reg = 6'D0;		//配置字地址缓存
	reg [3:0]	CS_ADG_Reg = 4'D0;					//片选缓存
	reg 			CONVST_ADC_Reg = 1'B0;				//ADC转换控制缓存
	reg [1:0]	ADC_EOC_Edge = 2'B00;				//ADC_EOC边沿判断寄存器
	reg [13:0]	DataBus_Analog_Reg = 14'D0;		//模拟接口数据输出缓存
	reg [1:0]	CS_Analog_Edge = 2'B00;				//CS_Analog边沿判断寄存器
	
	//--------------采集值缓存
	reg [19:0] 	N1_Average = 20'D0,	N2_Average = 20'D0,	N3_Average = 20'D0,	N4_Average = 20'D0,	N5_Average = 20'D0;
	reg [19:0] 	N6_Average = 20'D0,	N7_Average = 20'D0,	N8_Average = 20'D0,	N9_Average = 20'D0,	N10_Average = 20'D0;
	reg [19:0]	N11_Average = 20'D0,	N12_Average = 20'D0,	N13_Average = 20'D0,	N14_Average = 20'D0,	N15_Average = 20'D0;
	reg [19:0]	N16_Average = 20'D0,	N17_Average = 20'D0,	N18_Average = 20'D0,	N19_Average = 20'D0,	N20_Average = 20'D0;
	reg [19:0]	N21_Average = 20'D0,	N22_Average = 20'D0,	N23_Average = 20'D0,	N24_Average = 20'D0,	N25_Average = 20'D0;
	reg [13:0]	N1_Send = 14'D0,	N2_Send = 14'D0,	N3_Send = 14'D0,	N4_Send = 14'D0,	N5_Send = 14'D0,	N6_Send = 14'D0;
	reg [13:0]	N7_Send = 14'D0,	N8_Send = 14'D0,	N9_Send = 14'D0,	N10_Send = 14'D0,	N11_Send = 14'D0,	N12_Send = 14'D0;
	reg [13:0]	N13_Send = 14'D0,	N14_Send = 14'D0,	N15_Send = 14'D0,	N16_Send = 14'D0,	N17_Send = 14'D0,	N18_Send = 14'D0;
	reg [13:0]	N19_Send = 14'D0,	N20_Send = 14'D0,	N21_Send = 14'D0,	N22_Send = 14'D0,	N23_Send = 14'D0,	N24_Send = 14'D0;
	reg [19:0]	N1_1 = 20'D0,	N1_2 = 20'D0,	N1_3 = 20'D0,	N1_4 = 20'D0;
	reg [19:0]	N2_1 = 20'D0,	N2_2 = 20'D0,	N2_3 = 20'D0,	N2_4 = 20'D0;
	reg [19:0]	N3_1 = 20'D0,	N3_2 = 20'D0,	N3_3 = 20'D0,	N3_4 = 20'D0;
	reg [19:0]	N4_1 = 20'D0,	N4_2 = 20'D0,	N4_3 = 20'D0,	N4_4 = 20'D0;
	reg [19:0]	N5_1 = 20'D0,	N5_2 = 20'D0,	N5_3 = 20'D0,	N5_4 = 20'D0;
	reg [19:0]	N6_1 = 20'D0,	N6_2 = 20'D0,	N6_3 = 20'D0,	N6_4 = 20'D0;
	reg [19:0]	N7_1 = 20'D0,	N7_2 = 20'D0,	N7_3 = 20'D0,	N7_4 = 20'D0;
	reg [19:0]	N8_1 = 20'D0,	N8_2 = 20'D0,	N8_3 = 20'D0,	N8_4 = 20'D0;
	reg [19:0]	N9_1 = 20'D0,	N9_2 = 20'D0,	N9_3 = 20'D0,	N9_4 = 20'D0;
	reg [19:0]	N10_1 = 20'D0,	N10_2 = 20'D0,	N10_3 = 20'D0,	N10_4 = 20'D0;
	reg [19:0]	N11_1 = 20'D0,	N11_2 = 20'D0,	N11_3 = 20'D0,	N11_4 = 20'D0;
	reg [19:0]	N12_1 = 20'D0,	N12_2 = 20'D0,	N12_3 = 20'D0,	N12_4 = 20'D0;
	reg [19:0]	N13_1 = 20'D0,	N13_2 = 20'D0,	N13_3 = 20'D0,	N13_4 = 20'D0;
	reg [19:0]	N14_1 = 20'D0,	N14_2 = 20'D0,	N14_3 = 20'D0,	N14_4 = 20'D0;
	reg [19:0]	N15_1 = 20'D0,	N15_2 = 20'D0,	N15_3 = 20'D0,	N15_4 = 20'D0;
	reg [19:0]	N16_1 = 20'D0,	N16_2 = 20'D0,	N16_3 = 20'D0,	N16_4 = 20'D0;
	reg [19:0]	N17_1 = 20'D0,	N17_2 = 20'D0,	N17_3 = 20'D0,	N17_4 = 20'D0;
	reg [19:0]	N18_1 = 20'D0,	N18_2 = 20'D0,	N18_3 = 20'D0,	N18_4 = 20'D0;
	reg [19:0]	N19_1 = 20'D0,	N19_2 = 20'D0,	N19_3 = 20'D0,	N19_4 = 20'D0;
	reg [19:0]	N20_1 = 20'D0,	N20_2 = 20'D0,	N20_3 = 20'D0,	N20_4 = 20'D0;
	reg [19:0]	N21_1 = 20'D0,	N21_2 = 20'D0,	N21_3 = 20'D0,	N21_4 = 20'D0;
	reg [19:0]	N22_1 = 20'D0,	N22_2 = 20'D0,	N22_3 = 20'D0,	N22_4 = 20'D0;
	reg [19:0]	N23_1 = 20'D0,	N23_2 = 20'D0,	N23_3 = 20'D0,	N23_4 = 20'D0;
	reg [19:0]	N24_1 = 20'D0,	N24_2 = 20'D0,	N24_3 = 20'D0,	N24_4 = 20'D0;
//--------------------------------------------------------
	//时钟计数器
	always @(posedge CLOCK_BMQ)	begin
		Counter_CLOCK = Counter_CLOCK + 1'B1;
	end
	
	//计数器分配
	assign CLOCK_Bit = Counter_CLOCK[0];
	assign Counter_Bits = Counter_CLOCK[3:1];
	assign Counter_Channel = Counter_CLOCK[10:4];

//--------------------------------------------------------	
	//配置字地址输出
	always @(posedge CLOCK_BMQ)	begin
		case(Counter_Channel)	
			7'D0:			ID_Convst_Analog_Reg = 6'D0;
			7'D5:			ID_Convst_Analog_Reg = 6'D1;
			7'D10:		ID_Convst_Analog_Reg = 6'D2;
			7'D15:		ID_Convst_Analog_Reg = 6'D3;
			7'D20:		ID_Convst_Analog_Reg = 6'D4;
			7'D25:		ID_Convst_Analog_Reg = 6'D5;
			7'D30:		ID_Convst_Analog_Reg = 6'D6;
			7'D35:		ID_Convst_Analog_Reg = 6'D7;
			7'D40:		ID_Convst_Analog_Reg = 6'D8;
			7'D45:		ID_Convst_Analog_Reg = 6'D9;
			7'D50:		ID_Convst_Analog_Reg = 6'D10;
			7'D55:		ID_Convst_Analog_Reg = 6'D11;
			7'D60:		ID_Convst_Analog_Reg = 6'D12;
			7'D65:		ID_Convst_Analog_Reg = 6'D13;
			7'D70:		ID_Convst_Analog_Reg = 6'D14;
			7'D75:		ID_Convst_Analog_Reg = 6'D15;
			7'D80:		ID_Convst_Analog_Reg = 6'D16;
			7'D85:		ID_Convst_Analog_Reg = 6'D17;
			7'D90:		ID_Convst_Analog_Reg = 6'D18;
			7'D95:		ID_Convst_Analog_Reg = 6'D19;
			7'D100:		ID_Convst_Analog_Reg = 6'D20;
			7'D105:		ID_Convst_Analog_Reg = 6'D21;
			7'D110:		ID_Convst_Analog_Reg = 6'D22;
			7'D115:		ID_Convst_Analog_Reg = 6'D23;
			7'D120:		ID_Convst_Analog_Reg = 6'D0;
			default:		ID_Convst_Analog_Reg = ID_Convst_Analog_Reg;
		endcase
	end
	
	assign ID_Convst_Analog = ID_Convst_Analog_Reg;
	
//--------------------------------------------------------	
	//ADG控制
	//ADG地址输出
	assign ADD_ADG[3:0] = Configer_Word[7:4];
	
	//ADG片选输出
	always @(posedge CLOCK_BMQ)	begin
		case(Configer_Word[3:0])
			4'D1:			CS_ADG_Reg = 4'B0001;
			4'D2:			CS_ADG_Reg = 4'B0010;
			4'D3:			CS_ADG_Reg = 4'B0100;
			4'D4:			CS_ADG_Reg = 4'B1000;
			default:		CS_ADG_Reg = 4'B0000;
		endcase
	end
	
	assign CS_ADG[3:0] = CS_ADG_Reg[3:0];

//--------------------------------------------------------		
	//ADC控制		同步与位时钟
	//ADC_转换控制 
	always @(posedge CLOCK_Bit)	begin
		if(Counter_Bits == 3'B000)	begin						
			if(Counter_Channel == 7'D1 || Counter_Channel == 7'D2 || Counter_Channel == 7'D3 || Counter_Channel == 7'D4 ||				//N1采集通道
				Counter_Channel == 7'D6 || Counter_Channel == 7'D7 || Counter_Channel == 7'D8 || Counter_Channel == 7'D9 ||				//N2采集通道
				Counter_Channel == 7'D11 || Counter_Channel == 7'D12 || Counter_Channel == 7'D13 || Counter_Channel == 7'D14 ||		//N3采集通道
				Counter_Channel == 7'D16 || Counter_Channel == 7'D17 || Counter_Channel == 7'D18 || Counter_Channel == 7'D19 ||		//N4采集通道
				Counter_Channel == 7'D21 || Counter_Channel == 7'D22 || Counter_Channel == 7'D23 || Counter_Channel == 7'D24 ||		//N5采集通道
				Counter_Channel == 7'D26 || Counter_Channel == 7'D27 || Counter_Channel == 7'D28 || Counter_Channel == 7'D29 ||		//N6采集通道
				Counter_Channel == 7'D31 || Counter_Channel == 7'D32 || Counter_Channel == 7'D33 || Counter_Channel == 7'D34 ||		//N7采集通道
				Counter_Channel == 7'D36 || Counter_Channel == 7'D37 || Counter_Channel == 7'D38 || Counter_Channel == 7'D39 ||		//N8采集通道
				Counter_Channel == 7'D41 || Counter_Channel == 7'D42 || Counter_Channel == 7'D43 || Counter_Channel == 7'D44 ||		//N9采集通道
				Counter_Channel == 7'D46 || Counter_Channel == 7'D47 || Counter_Channel == 7'D48 || Counter_Channel == 7'D49 ||		//N10采集通道
				Counter_Channel == 7'D51 || Counter_Channel == 7'D52 || Counter_Channel == 7'D53 || Counter_Channel == 7'D54 ||		//N11采集通道
				Counter_Channel == 7'D56 || Counter_Channel == 7'D57 || Counter_Channel == 7'D58 || Counter_Channel == 7'D59 ||		//N12采集通道
				Counter_Channel == 7'D61 || Counter_Channel == 7'D62 || Counter_Channel == 7'D63 || Counter_Channel == 7'D64 ||		//N13采集通道
				Counter_Channel == 7'D66 || Counter_Channel == 7'D67 || Counter_Channel == 7'D68 || Counter_Channel == 7'D69 ||		//N14采集通道
				Counter_Channel == 7'D71 || Counter_Channel == 7'D72 || Counter_Channel == 7'D73 || Counter_Channel == 7'D74 ||		//N15采集通道
				Counter_Channel == 7'D76 || Counter_Channel == 7'D77 || Counter_Channel == 7'D78 || Counter_Channel == 7'D79 ||		//N16采集通道
				Counter_Channel == 7'D81 || Counter_Channel == 7'D82 || Counter_Channel == 7'D83 || Counter_Channel == 7'D84 ||		//N17采集通道
				Counter_Channel == 7'D86 || Counter_Channel == 7'D87 || Counter_Channel == 7'D88 || Counter_Channel == 7'D89 ||		//N18采集通道
				Counter_Channel == 7'D91 || Counter_Channel == 7'D92 || Counter_Channel == 7'D93 || Counter_Channel == 7'D94 ||		//N19采集通道
				Counter_Channel == 7'D96 || Counter_Channel == 7'D97 || Counter_Channel == 7'D98 || Counter_Channel == 7'D99 ||		//N20采集通道
				Counter_Channel == 7'D101 || Counter_Channel == 7'D102 || Counter_Channel == 7'D103 || Counter_Channel == 7'D104 ||	//N21采集通道
				Counter_Channel == 7'D106 || Counter_Channel == 7'D107 || Counter_Channel == 7'D108 || Counter_Channel == 7'D109 ||	//N22采集通道
				Counter_Channel == 7'D111 || Counter_Channel == 7'D112 || Counter_Channel == 7'D113 || Counter_Channel == 7'D114 ||	//N23采集通道
				Counter_Channel == 7'D116 || Counter_Channel == 7'D117 || Counter_Channel == 7'D118 || Counter_Channel == 7'D119 		//N24采集通道
				)	begin
				CONVST_ADC_Reg = 1'B1;
			end
			else	begin
				CONVST_ADC_Reg = 1'B0;
			end
		end
		else	begin
			CONVST_ADC_Reg = 1'B0;
		end
	end
	
	assign CONVST_ADC = CONVST_ADC_Reg;
	
	//ADC_读取请求控制
	assign RD_ADC = EOC_ADC;
	
	//ADC_片选控制
	assign CS_ADC = 1'B0;
	//ADC_读取数据
	always @(posedge CLOCK_BMQ)	begin				//ADC_EOC边沿判断
		ADC_EOC_Edge[1] = ADC_EOC_Edge[0];
		ADC_EOC_Edge[0] = EOC_ADC;
	end
//	always @(posedge CLOCK_BMQ)	begin
	always @(posedge CLOCK_Bit)	begin
//		if(ADC_EOC_Edge == 2'B10)	begin				//ADC_EOC下降沿，数据采集完成
		if( Counter_Bits== 3'B111)	begin
			case(Counter_Channel)
				//N1采集通道
				7'D1:	begin
					N1_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D2:	begin
					N1_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D3:	begin
					N1_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D4:	begin
					N1_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N1_Average = ((N1_1 + N1_2 + N1_3 + N1_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N1_Average[13] == 1'B0)					N1_Send = 14'D0;
						else							N1_Send = N1_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N1_Average[13] == 1'B1)					N1_Send = 14'D0;
						else							N1_Send = N1_Average[13:0];
					end
					else	begin          //正负信号
													N1_Send = N1_Average[13:0];
					end
				end
				//N2采集通道
				7'D6:	begin
					N2_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D7:	begin
					N2_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D8:	begin
					N2_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D9:	begin
					N2_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N2_Average = ((N2_1 + N2_2 + N2_3 + N2_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N2_Average[13] == 1'B0)					N2_Send = 14'D0;
						else							N2_Send = N2_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N2_Average[13] == 1'B1)					N2_Send = 14'D0;
						else							N2_Send = N2_Average[13:0];
					end
					else	begin          //正负信号
													N2_Send = N2_Average[13:0];
					end
				end
				//N3采集通道
				7'D11:	begin
					N3_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D12:	begin
					N3_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D13:	begin
					N3_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D14:	begin
					N3_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N3_Average = ((N3_1 + N3_2 + N3_3 + N3_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N3_Average[13] == 1'B0)					N3_Send = 14'D0;
						else							N3_Send = N3_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N3_Average[13] == 1'B1)					N3_Send = 14'D0;
						else							N3_Send = N3_Average[13:0];
					end
					else	begin          //正负信号
													N3_Send = N3_Average[13:0];
					end
				end
				//N4采集通道
				7'D16:	begin
					N4_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D17:	begin
					N4_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D18:	begin
					N4_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D19:	begin
					N4_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N4_Average = ((N4_1 + N4_2 + N4_3 + N4_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N4_Average[13] == 1'B0)					N4_Send = 14'D0;
						else							N4_Send = N4_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N4_Average[13] == 1'B1)					N4_Send = 14'D0;
						else							N4_Send = N4_Average[13:0];
					end
					else	begin          //正负信号
													N4_Send = N4_Average[13:0];
					end
				end
				//N5采集通道
				7'D21:	begin
					N5_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D22:	begin
					N5_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D23:	begin
					N5_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D24:	begin
					N5_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N5_Average = ((N5_1 + N5_2 + N5_3 + N5_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N5_Average[13] == 1'B0)					N5_Send = 14'D0;
						else							N5_Send = N5_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N5_Average[13] == 1'B1)					N5_Send = 14'D0;
						else							N5_Send = N5_Average[13:0];
					end
					else	begin          //正负信号
													N5_Send = N5_Average[13:0];
					end
				end
				//N6采集通道
				7'D26:	begin
					N6_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D27:	begin
					N6_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D28:	begin
					N6_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D29:	begin
					N6_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N6_Average = ((N6_1 + N6_2 + N6_3 + N6_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N6_Average[13] == 1'B0)					N6_Send = 14'D0;
						else							N6_Send = N6_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N6_Average[13] == 1'B1)					N6_Send = 14'D0;
						else							N6_Send = N6_Average[13:0];
					end
					else	begin          //正负信号
													N6_Send = N6_Average[13:0];
					end
				end
				//N7采集通道
				7'D31:	begin
					N7_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D32:	begin
					N7_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D33:	begin
					N7_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D34:	begin
					N7_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N7_Average = ((N7_1 + N7_2 + N7_3 + N7_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N7_Average[13] == 1'B0)					N7_Send = 14'D0;
						else							N7_Send = N7_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N7_Average[13] == 1'B1)					N7_Send = 14'D0;
						else							N7_Send = N7_Average[13:0];
					end
					else	begin          //正负信号
													N7_Send = N7_Average[13:0];
					end
				end
				//N8采集通道
				7'D36:	begin
					N8_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D37:	begin
					N8_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D38:	begin
					N8_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D39:	begin
					N8_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N8_Average = ((N8_1 + N8_2 + N8_3 + N8_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N8_Average[13] == 1'B0)					N8_Send = 14'D0;
						else							N8_Send = N8_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N8_Average[13] == 1'B1)					N8_Send = 14'D0;
						else							N8_Send = N8_Average[13:0];
					end
					else	begin          //正负信号
													N8_Send = N8_Average[13:0];
					end
				end
				//N9采集通道
				7'D41:	begin
					N9_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D42:	begin
					N9_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D43:	begin
					N9_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D44:	begin
					N9_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N9_Average = ((N9_1 + N9_2 + N9_3 + N9_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N9_Average[13] == 1'B0)					N9_Send = 14'D0;
						else							N9_Send = N9_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N9_Average[13] == 1'B1)					N9_Send = 14'D0;
						else							N9_Send = N9_Average[13:0];
					end
					else	begin          //正负信号
													N9_Send = N9_Average[13:0];
					end
				end
				//N10采集通道
				7'D46:	begin
					N10_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D47:	begin
					N10_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D48:	begin
					N10_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D49:	begin
					N10_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N10_Average = ((N10_1 + N10_2 + N10_3 + N10_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N10_Average[13] == 1'B0)					N10_Send = 14'D0;
						else							N10_Send = N10_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N10_Average[13] == 1'B1)					N10_Send = 14'D0;
						else							N10_Send = N10_Average[13:0];
					end
					else	begin          //正负信号
													N10_Send = N10_Average[13:0];
					end
				end
				//N11采集通道
				7'D51:	begin
					N11_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D52:	begin
					N11_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D53:	begin
					N11_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D54:	begin
					N11_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N11_Average = ((N11_1 + N11_2 + N11_3 + N11_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N11_Average[13] == 1'B0)					N11_Send = 14'D0;
						else							N11_Send = N11_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N11_Average[13] == 1'B1)					N11_Send = 14'D0;
						else							N11_Send = N11_Average[13:0];
					end
					else	begin          //正负信号
													N11_Send = N11_Average[13:0];
					end
				end
				//N12采集通道
				7'D56:	begin
					N12_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D57:	begin
					N12_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D58:	begin
					N12_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D59:	begin
					N12_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N12_Average = ((N12_1 + N12_2 + N12_3 + N12_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N12_Average[13] == 1'B0)					N12_Send = 14'D0;
						else							N12_Send = N12_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N12_Average[13] == 1'B1)					N12_Send = 14'D0;
						else							N12_Send = N12_Average[13:0];
					end
					else	begin          //正负信号
													N12_Send = N12_Average[13:0];
					end
				end
				//N13采集通道
				7'D61:	begin
					N13_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D62:	begin
					N13_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D63:	begin
					N13_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D64:	begin
					N13_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N13_Average = ((N13_1 + N13_2 + N13_3 + N13_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N13_Average[13] == 1'B0)					N13_Send = 14'D0;
						else							N13_Send = N13_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N13_Average[13] == 1'B1)					N13_Send = 14'D0;
						else							N13_Send = N13_Average[13:0];
					end
					else	begin          //正负信号
													N13_Send = N13_Average[13:0];
					end
				end
				//N14采集通道
				7'D66:	begin
					N14_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D67:	begin
					N14_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D68:	begin
					N14_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D69:	begin
					N14_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N14_Average = ((N14_1 + N14_2 + N14_3 + N14_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N14_Average[13] == 1'B0)					N14_Send = 14'D0;
						else							N14_Send = N14_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N14_Average[13] == 1'B1)					N14_Send = 14'D0;
						else							N14_Send = N14_Average[13:0];
					end
					else	begin          //正负信号
													N14_Send = N14_Average[13:0];
					end
				end
				//N15采集通道
				7'D71:	begin
					N15_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D72:	begin
					N15_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D73:	begin
					N15_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D74:	begin
					N15_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N15_Average = ((N15_1 + N15_2 + N15_3 + N15_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N15_Average[13] == 1'B0)					N15_Send = 14'D0;
						else							N15_Send = N15_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N15_Average[13] == 1'B1)					N15_Send = 14'D0;
						else							N15_Send = N15_Average[13:0];
					end
					else	begin          //正负信号
													N15_Send = N15_Average[13:0];
					end
				end
				//N16采集通道
				7'D76:	begin
					N16_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D77:	begin
					N16_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D78:	begin
					N16_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D79:	begin
					N16_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N16_Average = ((N16_1 + N16_2 + N16_3 + N16_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N16_Average[13] == 1'B0)					N16_Send = 14'D0;
						else							N16_Send = N16_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N16_Average[13] == 1'B1)					N16_Send = 14'D0;
						else							N16_Send = N16_Average[13:0];
					end
					else	begin          //正负信号
													N16_Send = N16_Average[13:0];
					end
				end
				//N17采集通道
				7'D81:	begin
					N17_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D82:	begin
					N17_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D83:	begin
					N17_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D84:	begin
					N17_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N17_Average = ((N17_1 + N17_2 + N17_3 + N17_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N17_Average[13] == 1'B0)					N17_Send = 14'D0;
						else							N17_Send = N17_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N17_Average[13] == 1'B1)					N17_Send = 14'D0;
						else							N17_Send = N17_Average[13:0];
					end
					else	begin          //正负信号
													N17_Send = N17_Average[13:0];
					end
				end
				//N18采集通道
				7'D86:	begin
					N18_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D87:	begin
					N18_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D88:	begin
					N18_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D89:	begin
					N18_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N18_Average = ((N18_1 + N18_2 + N18_3 + N18_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N18_Average[13] == 1'B0)					N18_Send = 14'D0;
						else							N18_Send = N18_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N18_Average[13] == 1'B1)					N18_Send = 14'D0;
						else							N18_Send = N18_Average[13:0];
					end
					else	begin          //正负信号
													N18_Send = N18_Average[13:0];
					end
				end
				//N19采集通道
				7'D91:	begin
					N19_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D92:	begin
					N19_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D93:	begin
					N19_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D94:	begin
					N19_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N19_Average = ((N19_1 + N19_2 + N19_3 + N19_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N19_Average[13] == 1'B0)					N19_Send = 14'D0;
						else							N19_Send = N19_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N19_Average[13] == 1'B1)					N19_Send = 14'D0;
						else							N19_Send = N19_Average[13:0];
					end
					else	begin          //正负信号
													N19_Send = N19_Average[13:0];
					end
				end
				//N20采集通道
				7'D96:	begin
					N20_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D97:	begin
					N20_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D98:	begin
					N20_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D99:	begin
					N20_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N20_Average = ((N20_1 + N20_2 + N20_3 + N20_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N20_Average[13] == 1'B0)					N20_Send = 14'D0;
						else							N20_Send = N20_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N20_Average[13] == 1'B1)					N20_Send = 14'D0;
						else							N20_Send = N20_Average[13:0];
					end
					else	begin          //正负信号
													N20_Send = N20_Average[13:0];
					end
				end
				//N21采集通道
				7'D101:	begin
					N21_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D102:	begin
					N21_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D103:	begin
					N21_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D104:	begin
					N21_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N21_Average = ((N21_1 + N21_2 + N21_3 + N21_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N21_Average[13] == 1'B0)					N21_Send = 14'D0;
						else							N21_Send = N21_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N21_Average[13] == 1'B1)					N21_Send = 14'D0;
						else							N21_Send = N21_Average[13:0];
					end
					else	begin          //正负信号
													N21_Send = N21_Average[13:0];
					end
				end
				//N22采集通道
				7'D106:	begin
					N22_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D107:	begin
					N22_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D108:	begin
					N22_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D109:	begin
					N22_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N22_Average = ((N22_1 + N22_2 + N22_3 + N22_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N22_Average[13] == 1'B0)					N22_Send = 14'D0;
						else							N22_Send = N22_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N22_Average[13] == 1'B1)					N22_Send = 14'D0;
						else							N22_Send = N22_Average[13:0];
					end
					else	begin          //正负信号
													N22_Send = N22_Average[13:0];
					end
				end
				//N23采集通道
				7'D111:	begin
					N23_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D112:	begin
					N23_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D113:	begin
					N23_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D114:	begin
					N23_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N23_Average = ((N23_1 + N23_2 + N23_3 + N23_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N23_Average[13] == 1'B0)					N23_Send = 14'D0;
						else							N23_Send = N23_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N23_Average[13] == 1'B1)					N23_Send = 14'D0;
						else							N23_Send = N23_Average[13:0];
					end
					else	begin          //正负信号
													N23_Send = N23_Average[13:0];
					end
				end
				//N24采集通道
				7'D116:	begin
					N24_1 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D117:	begin
					N24_2 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D118:	begin
					N24_3 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
				end
				7'D119:	begin
					N24_4 = {6'D0,~DATA_ADC[13],DATA_ADC[12:0]};
					N24_Average = ((N24_1 + N24_2 + N24_3 + N24_4)  >> 2);
					if(Configer_Word[17:16] == 2'B01)	begin          //正信号
						if(N24_Average[13] == 1'B0)					N24_Send = 14'D0;
						else							N24_Send = N24_Average[13:0];
					end
					else if(Configer_Word[17:16] == 2'B10)	begin          //负信号
						if(N24_Average[13] == 1'B1)					N24_Send = 14'D0;
						else							N24_Send = N24_Average[13:0];
					end
					else	begin          //正负信号
													N24_Send = N24_Average[13:0];
					end
				end
			endcase
		end
	end

//--------------------------------------------------------		
	//输出数据
	//CS边沿获取
	always @(posedge CLOCK_BMQ)	begin
		CS_Analog_Edge[1] = CS_Analog_Edge[0];
		CS_Analog_Edge[0] = CS_Analog;
	end
	//CS上升沿根据ID_Analog获取数据
	always @(posedge CLOCK_BMQ)	begin
		if(CS_Analog_Edge == 2'B01)	begin		//CS上升沿读取数据
			case(ID_Analog)
				6'D0:				DataBus_Analog_Reg[13:0] = N1_Send[13:0];
				6'D1:				DataBus_Analog_Reg[13:0] = N2_Send[13:0];
				6'D2:				DataBus_Analog_Reg[13:0] = N3_Send[13:0];
				6'D3:				DataBus_Analog_Reg[13:0] = N4_Send[13:0];
				6'D4:				DataBus_Analog_Reg[13:0] = N5_Send[13:0];
				6'D5:				DataBus_Analog_Reg[13:0] = N6_Send[13:0];
				6'D6:				DataBus_Analog_Reg[13:0] = N7_Send[13:0];
				6'D7:				DataBus_Analog_Reg[13:0] = N8_Send[13:0];
				6'D8:				DataBus_Analog_Reg[13:0] = N9_Send[13:0];
				6'D9:				DataBus_Analog_Reg[13:0] = N10_Send[13:0];
				6'D10:			DataBus_Analog_Reg[13:0] = N11_Send[13:0];
				6'D11:			DataBus_Analog_Reg[13:0] = N12_Send[13:0];
				6'D12:			DataBus_Analog_Reg[13:0] = N13_Send[13:0];
				6'D13:			DataBus_Analog_Reg[13:0] = N14_Send[13:0];
				6'D14:			DataBus_Analog_Reg[13:0] = N15_Send[13:0];
				6'D15:			DataBus_Analog_Reg[13:0] = N16_Send[13:0];
				6'D16:			DataBus_Analog_Reg[13:0] = N17_Send[13:0];
				6'D17:			DataBus_Analog_Reg[13:0] = N18_Send[13:0];
				6'D18:			DataBus_Analog_Reg[13:0] = N19_Send[13:0];
				6'D19:			DataBus_Analog_Reg[13:0] = N20_Send[13:0];
				6'D20:			DataBus_Analog_Reg[13:0] = N21_Send[13:0];
				6'D21:			DataBus_Analog_Reg[13:0] = N22_Send[13:0];
				6'D22:			DataBus_Analog_Reg[13:0] = N23_Send[13:0];
				6'D23:			DataBus_Analog_Reg[13:0] = N24_Send[13:0];
				default:			DataBus_Analog_Reg[13:0] = N25_Average[13:0];
			endcase
		end
	end
	//端口输出数据
	assign DataBus_Analog = (CS_Analog == 1'B1) ? DataBus_Analog_Reg[13:0] : 14'HZZZ;
endmodule

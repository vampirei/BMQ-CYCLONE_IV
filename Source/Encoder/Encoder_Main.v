/*				时序
Counter_Bits == 0		等待配置模块读出配置字  
							所有片选维持原来状态；
							获取传输数据值；
							PCM输出缓存值[0]
Counter_Bits == 1		获取配置模块配置字，并进行分配；
							所有片选无效；
							PCM输出缓存值获取；
							PCM输出缓存值[7];
Counter_Bits == 2		根据通道类型输出对应通道片选、ID；
							PCM输出缓存值[6];
Counter_Bits == 3		维持通道片选、ID；
							PCM输出缓存值[5];
Counter_Bits == 4		维持通道片选、ID；
							PCM输出缓存值[4];
Counter_Bits == 5		维持通道片选、ID；
							PCM输出缓存值[3];
Counter_Bits == 6		维持通道片选、ID；
							PCM输出缓存值[2];
Counter_Bits == 7		维持通道片选、ID；
							PCM输出缓存值[1];
*/

module Encoder_Main(
	//位时钟 及各个计数器
	input 			CLOCK_Bit,
	input [2:0]		Counter_Bits,
	input [6:0]		Counter_Channel,
	input [15:0]	Counter_Frame,
	//配置字
	input [15:0] 	Configer_Word,
	//模拟接口相关
	output 			CS_Analog,
	output [5:0]	ID_Analog,
	input [13:0]	DataBus_Analog,
	//数字接口相关
	input [7:0]		DataBus_Digtal,
	output [7:0]	CS_Digtal,
	//外部数据相关
	input [7:0]		DataBus_Extern,
	output [7:0]	CS_Extern,
	//PCM
	output			PCM
);
	//内部参量
	localparam  AnalogChannel_H = 3'B000;				//模拟通道H
	localparam  AnalogChannel_L = 3'B001;				//模拟通道L
	localparam  AnalogChannel_F = 3'B010;				//模拟通道自由
	localparam  DigtalChannel = 3'B011;					//数字通道
	localparam	ExterChannel = 3'B100;					//外部通道
	localparam	FixChannel = 3'B101;						//固定值通道
	localparam	CounterChannel_H = 3'B110;				//计数器H通道
	localparam	CounterChannel_L = 3'B111;				//计数器L通道
	
	//内部变量
	reg [15:0]	Configer_Word_Reg = 16'D23200;		//配置字寄存器	默认 固定字AA
	reg 			Mode_Encoder = 1'B0;						//编码模式  默认NRZL
	reg [2:0]	Type_Channel	= 3'B101;				//通道类型  默认 固定字
	reg [7:0]	Type_B_Channel = 8'HAA;					//通道类型补充 默认 AA
	reg [3:0] 	Value_Analog = 4'D0;						//模拟信号取值 默认[13:6]
	
	reg 			CS_Analog_Reg = 1'B0;					//模拟接口片选缓存 默认片选无效
	reg [5:0] 	ID_Analog_Reg = 6'D0;					//模拟接口ID缓存 默认A1
	reg [7:0] 	CS_Digtal_Reg = 8'D0;					//数字接口片选缓存  默认片选无效
	reg [7:0] 	CS_Extern_Reg = 8'D0;					//外部片选缓存 默认片选无效
	
	reg [13:0]	Value_Analog_Reg = 14'D0;				//模拟通道缓存值  默认0
	reg [7:0]	Value_Channel_Reg = 8'HBB;				//通道
	reg [7:0]	Value_PCM_Reg = 8'HAA;					//PCM缓存值
	reg 			PCM_Reg = 1'B1;							//PCM输出
	
	//位计数1  从配置字分配 编码模式、通道类型、通道类型补充、模拟信号取值
	always @(posedge CLOCK_Bit)	begin
		if(Counter_Bits == 3'D1)	begin			//位计数1  获取配置字  并分配
			Configer_Word_Reg[15:0] = Configer_Word[15:0];
			//分配现通道
			Mode_Encoder = 	Configer_Word_Reg[15];
			Type_Channel = 	Configer_Word_Reg[14:12];
			Type_B_Channel = 	Configer_Word_Reg[11:4];
			Value_Analog = 	Configer_Word_Reg[3:0];
		end
		else	begin									//位计数其他时刻	  维持分配值不变
			Mode_Encoder = 	Mode_Encoder;
			Type_Channel = 	Type_Channel;
			Type_B_Channel = 	Type_B_Channel;
			Value_Analog = 	Value_Analog;
		end
	end
	//模拟接口片选
	always @(posedge CLOCK_Bit)	begin
		if(Counter_Bits == 3'D1)	begin					//位计数1  清除模拟片选
			CS_Analog_Reg = 1'B0;							//清除模拟片选
		end
		else if(Counter_Bits == 3'D2)	begin			//位计数2  根据通道类型 设置模拟片选
			if(Type_Channel == AnalogChannel_H)	begin				//通道类型为 模拟通道H
				CS_Analog_Reg = 1'B1;							//设置模拟片选
			end
			else if(Type_Channel == AnalogChannel_F)	begin		//通道类型为  模拟自由
				CS_Analog_Reg = 1'B1;							//设置模拟片选
			end
			else	begin											//通道类型为  其他
				CS_Analog_Reg = 1'B0;							//清除模拟片选
			end
		end
		else	begin											//位计数 其他 保持模拟片选不变
			CS_Analog_Reg = CS_Analog_Reg;
		end
	end
	//模拟接口ID
	always @(posedge CLOCK_Bit)	begin
		if(Counter_Bits == 3'D2)	begin					//位计数2  设置模拟接口ID
			if((Type_Channel == AnalogChannel_H) || (Type_Channel == AnalogChannel_F))	begin		//模拟片选有效时，设置模拟接口ID
				ID_Analog_Reg[5:0] = Type_B_Channel[5:0];
			end
			else	begin																			//模拟片选无效时，保持模拟接口ID不变
				ID_Analog_Reg[5:0] = ID_Analog_Reg[5:0];
			end
		end
	end
	//数字接口片选
	always @(posedge CLOCK_Bit)	begin
		if(Counter_Bits == 3'D1)	begin							//位计数1  清除数字接口片选
			CS_Digtal_Reg[7:0] = 8'D0;
		end
		else if(Counter_Bits == 3'D2)	begin					//位计数2  设置除数字接口片选
			if(Type_Channel == DigtalChannel)	begin						//通道类型为 数字通道
				CS_Digtal_Reg[7:0] = Type_B_Channel[7:0];			//根据通道类型补充设置数字接口片选
			end
			else	begin													//通道类型为 其他通道
				CS_Digtal_Reg[7:0] = 8'D0;								//清除数字接口片选
			end
		end
		else	begin													//位计数其他时刻	  维持值不变
			CS_Digtal_Reg[7:0] = CS_Digtal_Reg[7:0];
		end
	end
	//外部数据片选
	always @(posedge CLOCK_Bit)	begin
		if(Counter_Bits == 3'D1)	begin							//位计数1  清除外部数据片选
			CS_Extern_Reg[7:0] = 8'D0;
		end
		else if(Counter_Bits == 3'D2)	begin					//位计数2  设置除外部数据片选
			if(Type_Channel == ExterChannel)	begin						//通道类型为 外部通道
				CS_Extern_Reg[7:0] = CS_Extern_Reg[7:0];			//根据通道类型补充设置外部数据片选
			end
			else	begin													//通道类型为 其他通道
				CS_Extern_Reg[7:0] = 8'D0;								//清除外部数据片选
			end
		end
		else	begin													//位计数其他时刻	  维持值不变
			CS_Extern_Reg[7:0] = CS_Extern_Reg[7:0];
		end
	end
	//获取传输数据值
	always @(posedge CLOCK_Bit)	begin
		if(Counter_Bits == 3'B000)	begin											//位计数0 获取传输数据值，
			if(Type_Channel == AnalogChannel_H)	begin								//通道类型为 模拟通道H  获取模拟接口数据
				Value_Analog_Reg[13:0] = DataBus_Analog[13:0];						//缓存模拟接口数据值
				Value_Channel_Reg[7:0] = DataBus_Analog[13:6];						//置通道值
			end
			else if(Type_Channel == AnalogChannel_L)	begin						//通道类型为 模拟通道L  
				Value_Channel_Reg[7:0] = {Value_Analog_Reg[5:0],2'B00};			//置通道值
			end
			else if(Type_Channel == AnalogChannel_F)	begin			//通道类型为 模拟通道自由
				case(Value_Analog)
					4'B0000:			Value_Channel_Reg[7:0] = DataBus_Analog[13:6];
					4'B0001:			Value_Channel_Reg[7:0] = {DataBus_Analog[13],DataBus_Analog[11:5]};
					4'B0010:			Value_Channel_Reg[7:0] = {DataBus_Analog[13],DataBus_Analog[10:4]};
					4'B0011:			Value_Channel_Reg[7:0] = {DataBus_Analog[13],DataBus_Analog[9:3]};
					4'B0100:			Value_Channel_Reg[7:0] = {DataBus_Analog[13],DataBus_Analog[8:2]};
					4'B0101:			Value_Channel_Reg[7:0] = {DataBus_Analog[13],DataBus_Analog[7:1]};
					4'B0110:			Value_Channel_Reg[7:0] = {DataBus_Analog[13],DataBus_Analog[6:0]};
					4'B0111:			Value_Channel_Reg[7:0] = DataBus_Analog[12:5];
					4'B1000:			Value_Channel_Reg[7:0] = DataBus_Analog[11:4];
					4'B1001:			Value_Channel_Reg[7:0] = DataBus_Analog[10:3];
					4'B1010:			Value_Channel_Reg[7:0] = DataBus_Analog[9:2];
					4'B1011:			Value_Channel_Reg[7:0] = DataBus_Analog[8:1];
					default:			Value_Channel_Reg[7:0] = DataBus_Analog[7:0];
				endcase
			end
			else if(Type_Channel == DigtalChannel)	begin				//通道类型为  数字通道
				Value_Channel_Reg[7:0] = DataBus_Digtal[7:0];
			end
			else if(Type_Channel == ExterChannel)	begin				//通道类型为  外部通道
				Value_Channel_Reg[7:0] = DataBus_Extern[7:0];
			end
			else if(Type_Channel == FixChannel)	begin					//通道类型为  固定值通道
				Value_Channel_Reg[7:0] = Type_B_Channel[7:0];
			end
			else if(Type_Channel == CounterChannel_H)	begin			//通道类型为  计数器H通道
				Value_Channel_Reg[7:0] = Counter_Frame[15:8];
			end
			else if(Type_Channel == CounterChannel_L)	begin			//通道类型为  计数器L通道
				Value_Channel_Reg[7:0] = Counter_Frame[7:0];
			end
		end
	end
	//PCM输出
	always @(posedge CLOCK_Bit)	begin
		case(Counter_Bits)
			3'B000:			PCM_Reg = Value_PCM_Reg[0];
			3'B001:	begin
				Value_PCM_Reg[7:0] = Value_Channel_Reg[7:0];
				PCM_Reg = Value_PCM_Reg[7];
			end
			3'B010:			PCM_Reg = Value_PCM_Reg[6];
			3'B011:			PCM_Reg = Value_PCM_Reg[5];
			3'B100:			PCM_Reg = Value_PCM_Reg[4];
			3'B101:			PCM_Reg = Value_PCM_Reg[3];
			3'B110:			PCM_Reg = Value_PCM_Reg[2];
			3'B111:			PCM_Reg = Value_PCM_Reg[1];
		endcase
	end
	//端口输出
	assign CS_Analog = CS_Analog_Reg;
	assign ID_Analog = ID_Analog_Reg;
	assign CS_Digtal = CS_Digtal_Reg;
	assign CS_Extern = CS_Extern_Reg;
	assign PCM       = PCM_Reg;
endmodule

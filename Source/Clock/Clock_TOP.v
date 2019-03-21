module Clock_TOP(
	input		Clock_Board_BMQ,					//板上编码器时钟
	input 	Clock_Board_Dig,					//板上数字接口时钟
	
	output	Clock_BMQ,							//输出2倍码率时钟  BMQ时钟
	output	Clock_Digtal						//输出数字接口时钟
	
);
//-----------
	parameter	Board_Clock = 16000000;				//定义板上输入时钟频率
	parameter	BMQ_Clock = 4000000;					//定义编码器时钟，注意 该时钟为码率时钟2倍
//-----------
	reg [31:0]	Counter_BMQ = 32'D0;
	reg 			Clock_BMQ_Reg = 1'B0;
//-----------输出数字接口时钟
assign Clock_Digtal = Clock_Board_Dig;


//-----------输出编码器时钟
always @(posedge Clock_Board_BMQ)	begin
	if(Counter_BMQ == (Board_Clock / BMQ_Clock / 2 - 1))	begin
		Clock_BMQ_Reg = 1'B1;
		Counter_BMQ = Counter_BMQ + 1'B1;
	end
	else if(Counter_BMQ >= (Board_Clock / BMQ_Clock - 1))	begin
		Clock_BMQ_Reg = 1'B0;
		Counter_BMQ = 32'D0;
	end
	else	begin
		Clock_BMQ_Reg = Clock_BMQ_Reg;
		Counter_BMQ = Counter_BMQ + 1'B1;
	end
end

assign Clock_BMQ = (Board_Clock == BMQ_Clock) ? Clock_Board_BMQ : Clock_BMQ_Reg;
endmodule

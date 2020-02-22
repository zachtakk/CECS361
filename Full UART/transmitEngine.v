`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// This document contains information proprietary to the CSULB student that created
// the file - any reuse without adequate approval and documentation is prohibited   
//
// File Name: transmitEngine.v
// Project: Proj 3
// Created by <Zachery Takkesh> on <November 16th, 2019>
// Copyright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: The transmit engine is designed to communicate with terminal using UART.
// 			It comes out of reset with TxRdy active signals notifying the engine is
// 			ready to transmit. The engine is utilized to send out various messages
// 			to a serial terminal program. If transmitted successfully,
//				the message can be seen on terminal program i.e Realterm,PuTTY.
//
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////
module transmitEngine(clk, reset, load, eight, pen, ohel, baud_out,
							out_port, TxRdy, Tx);
	
	// Input and Output Declarations
	input clk, reset, load, eight, pen, ohel;
	input [18:0] baud_out;
	
	input [7:0] out_port;
	
	output reg TxRdy, Tx;
	
	wire done, btu, op, ep;
	
	// Internal registers
	reg do_it, done_d1, write_d1, bit10, bit9; 
	reg [3:0] bit_count, bit_count_D;
	reg [7:0] load_data;
	reg [10:0] shift_out; 
	reg [18:0] bit_time_count, bit_time_count_D;
		
	//*******************************************************
	//  TxRdy SR Flop				
	//  This resets to 1
	//*******************************************************
	always @ (posedge clk, posedge reset)
		if(reset)
			TxRdy <= 1'b1;
		else begin 
			casez({done_d1,load})
				2'b00 : TxRdy <= TxRdy;
				2'b01 : TxRdy <= 1'b0;
				2'b10 : TxRdy <= 1'b1;
				2'b11 : TxRdy <= 1'b?;
				default: TxRdy <= 1'b1;
			endcase
		end
	
	//*******************************************************
	//  Do It Flop			write[0] = load
	//*******************************************************
	always @ (posedge clk, posedge reset)
		if(reset)
			do_it <= 1'b0;
		else begin 
			casez({load,done})
				2'b00 : do_it <= do_it;
				2'b01 : do_it <= 1'b0;
				2'b10 : do_it <= 1'b1;
				2'b11 : do_it <= do_it;
				default: do_it <= 1'b0;
			endcase
		end
								  
	//*******************************************************
	//  Load_Data reg			
	//*******************************************************
	always @(posedge clk, posedge reset)
		if(reset)
			load_data <= 8'b0;
		else begin
			if(load)
				load_data <= out_port;
			else
				load_data <= load_data;	
		end
		

	//*******************************************************
	//  Bit time counter	
	//*******************************************************	
	assign btu = bit_time_count == baud_out;
	
	always @(posedge clk, posedge reset) begin
		if ( reset )
			bit_time_count <= 19'b0;
		else
			bit_time_count <= bit_time_count_D;
	end
	
	always @ (*) 
		case({do_it, btu})
			2'b00: bit_time_count_D = 19'b0;
			2'b01: bit_time_count_D = 19'b0;
			2'b10: bit_time_count_D = bit_time_count + 19'b1;
			2'b11: bit_time_count_D = 19'b0;
		endcase 
	
	//*******************************************************
	//  Bit counter
	//*******************************************************
	
	assign done = bit_count == 4'd11;
	
	always @(posedge clk, posedge reset) begin
		if ( reset )
			bit_count <= 4'b0;
		else
			bit_count <= bit_count_D;
	end
	
	always @ (*) 
		case({do_it, btu})
			2'b00: bit_count_D = 4'b0;
			2'b01: bit_count_D = 4'b0;
			2'b10: bit_count_D = bit_count;
			2'b11: bit_count_D = bit_count + 4'b1;
	endcase 
		
	//*******************************************************
	//  Done D1 Reg	
   //  Delay 1 clock	
	//*******************************************************
	
	always @ (posedge clk, posedge reset)
		if (reset)
			done_d1 <= 1'b0;
		else
			done_d1 <= done; 
			
	//*******************************************************
	//  Write D1 Reg	
   //  Delay 1 clock 	
	//*******************************************************
	
	always @ (posedge clk, posedge reset)
		if (reset)
			write_d1 <= 1'b0;
		else
			write_d1 <= load; 
			
	//*******************************************************
	//  Decoder 	
	//  EP - even parity, OP - odd parity 
	//  XOR checking # of 1's on load_data 
   //	 inputs odd # of 1's, output's 1 ; even # of 1's output's 0
	//  eight signal tells the decoder whether load_data is 7/8 bits
	//*******************************************************	
	
	assign ep = eight ?  (^load_data) :  ^(load_data[6:0]);
	assign op = eight ? ~(^load_data) : ~(^load_data[6:0]);
	
	always @ (*) begin
		case({eight,pen,ohel})
			3'b000: {bit10, bit9} = {1'b1, 1'b1};
			3'b001: {bit10, bit9} = {1'b1, 1'b1};
			3'b010: {bit10, bit9} = {1'b1, ep};
			3'b011: {bit10, bit9} = {1'b1, op};
			3'b100: {bit10, bit9} = {1'b1, load_data[7]};
			3'b101: {bit10, bit9} = {1'b1, load_data[7]} ;
			3'b110: {bit10, bit9} = {ep, load_data[7]};
			3'b111: {bit10, bit9} = {op, load_data[7]};
			default: {bit10, bit9} = 2'b0; 
		endcase
	end
	
	//*******************************************************
	//  Shift Reg 	
	//*******************************************************
	
	always @ ( posedge clk, posedge reset) 
		if (reset) 
			shift_out <=  11'b111_1111_1111;
		else begin
			if (write_d1)
				shift_out <= {bit10, bit9, load_data[6:0], 1'b0, 1'b1};
			if (btu)
				shift_out <= {1'b1, shift_out[10:1]};
		end
		
	always @ (*) begin 
		Tx = shift_out[0]; 
	end
	
endmodule // end of transmit engine module
`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// This document contains information proprietary to the CSULB student that created
// the file - any reuse without adequate approval and documentation is prohibited   
//
// File Name: receiveEngine.v
// Project: Proj 3
// Created by <Zachery Takkesh> on <November 16th, 2019>
// Copyright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: The receive engine is designed to receive data from the Rx input one 
//				bit at a time. The input data is coming from a serial terminal program.
//				The terminal program will accept a user input. Depending on user input,
//				certain control characters will trigger different outputs 
//				sent to terminal.
//
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////
module receiveEngine(clk, reset, eight, pen, ohel, k, read_0, 
							Rx, RxRdy, OVF, FERR, PERR, rx_data);
							
	// Input and Output Declarations
	input        clk, reset, eight, pen, ohel, Rx, read_0;
	input [18:0] k;
	
	output wire       RxRdy, OVF, FERR, PERR;
	output wire [7:0] rx_data;
 
   // Register Declarations
 	reg        start, doit, nstart, ndoit;
	reg [1:0]  pstate, nstate;
	reg [18:0] bit_time_count, bit_time_count_D;
	reg [3:0]  bit_count, bit_count_D, bit_count_mux;
	reg [9:0]  shift_out, combo_out; 
	reg        stop_bit_sel;
	
	// Wire Declarations
	wire [18:0] k_2, baud_out;
	wire btu, done, shift, parity_gen_sel,  
		  parity_bit_gen, parity_bit, parity, frame_bit, ovf_bit, even; 
	
	//*******************************************************
	// State Machine 
	//*******************************************************
	always @(posedge clk, posedge reset)
		if(reset)
			{pstate, start, doit} <= 4'b0;
		else
			{pstate, start, doit} <= {nstate, nstart, ndoit};
		
	always @ (*) 
		casez({pstate, Rx, btu, done})
			5'b00_0_?_?: {nstate, nstart, ndoit} = {2'b01,1'b0, 1'b0};
			5'b00_1_?_?: {nstate, nstart, ndoit} = {2'b00,1'b0, 1'b0};
		
			5'b01_0_0_?: {nstate, nstart, ndoit} = {2'b01,1'b1, 1'b1};
			5'b01_0_1_?: {nstate, nstart, ndoit} = {2'b10,1'b1, 1'b1};
			5'b01_1_?_?: {nstate, nstart, ndoit} = {2'b00,1'b1, 1'b1};
		
			5'b10_?_?_0: {nstate, nstart, ndoit} = {2'b10,1'b0, 1'b1};
			5'b10_?_?_1: {nstate, nstart, ndoit} = {2'b00,1'b0, 1'b1};
			default: {nstate, nstart, ndoit} = 4'b0; 
		endcase
		
	//*******************************************************
	//  Bit time counter	
	//*******************************************************	
	assign k_2 = (k>>1);
	assign baud_out = (start) ? k_2:k;
	
	always @(posedge clk, posedge reset) begin
		if ( reset )
			bit_time_count <= 19'b0;
		else
			bit_time_count <= bit_time_count_D;
	end
	
	always @ (*) 
		case({doit, btu})
			2'b00: bit_time_count_D = 19'b0;
			2'b01: bit_time_count_D = 19'b0;
			2'b10: bit_time_count_D = bit_time_count + 1;
			2'b11: bit_time_count_D = 19'b0;
		endcase 
		
	assign btu = bit_time_count == baud_out;
	
	//*******************************************************
	//  Bit counter
	//*******************************************************
	always @(*)
		casex({eight,pen})
			2'b00: bit_count_mux = 4'd9;
			2'b01: bit_count_mux = 4'd10;
			2'b10: bit_count_mux = 4'd10;
			2'b11: bit_count_mux = 4'd11;
			default: bit_count_mux = 4'd9;
		endcase
	
	assign done = bit_count == bit_count_mux;
	
	always @(posedge clk, posedge reset) begin
		if ( reset )
			bit_count <= 4'b0;
		else
			bit_count <= bit_count_D;
	end
	
	always @ (*) 
		case({doit, btu})
			2'b00: bit_count_D = 4'b0;
			2'b01: bit_count_D = 4'b0;
			2'b10: bit_count_D = bit_count;
			2'b11: bit_count_D = bit_count + 1;
	endcase 
		
	//*******************************************************
	//  Shift Register
	//*******************************************************
	assign shift = (~start) & btu;
	
	always @ (posedge clk, posedge reset)
		if (reset)
			shift_out <= 10'b0;
		else if (shift)
			shift_out <= {Rx, shift_out[9:1]};
		else 
			shift_out <= shift_out; 
	
	//*******************************************************
	//  Remap Combo
	//*******************************************************
	always @ (*)
		case({eight,pen})
			2'b00: combo_out = {1'b0, 1'b0, shift_out[9:2]};
			2'b01: combo_out = {1'b0, shift_out[9:1]};
			2'b10: combo_out = {1'b0, shift_out[9:1]};
			2'b11: combo_out = shift_out;
		endcase
		
	assign rx_data = (eight) ? combo_out [7:0]:{1'b0,combo_out[6:0]};
	
	//*******************************************************
	//  Parity Gen Select
	//*******************************************************
	assign parity_gen_sel = (eight) ? combo_out[7] : 1'b0;
	
	//*******************************************************
	//  Parity Bit Select
	//*******************************************************
	assign parity_bit_sel = (eight) ? combo_out[8] : combo_out[7];
	
	//*******************************************************
	//  Stop Bit Select
	//*******************************************************
	always @ (*)
		case({eight,pen})
			2'b00: stop_bit_sel = combo_out[7];
			2'b01: stop_bit_sel = combo_out[8];
			2'b10: stop_bit_sel = combo_out[8];
			2'b11: stop_bit_sel = combo_out[9];
		endcase
	
	//*******************************************************
	//  Receive Ready 
	//*******************************************************
	rs_flop rx_flop0 (.clk(clk),
						   .reset(reset),
							.r(read_0),
							.s(done),
							.Q(RxRdy));
							
	//*******************************************************
	//  Parity Error
	//*******************************************************
	assign even = (ohel == 1'b0);
	
	assign parity_bit_gen = parity_gen_sel ^ (^combo_out[6:0]);
	
	assign parity_bit = (even) ? parity_bit_gen: ~parity_bit_gen;
	
	assign parity = (parity_bit ^ parity_bit_sel) & pen & done; 
	
	rs_flop perr_flop (.clk(clk),
							 .reset(reset),
							 .r(read_0),
							 .s(parity),
							 .Q(PERR));

	//*******************************************************
	//  Framing Error
	//*******************************************************
	assign frame_bit = done & ~stop_bit_sel;
	
	rs_flop ferr_flop (.clk(clk),
						    .reset(reset),
							 .r(read_0),
							 .s(frame_bit),
							 .Q(FERR));

	//*******************************************************
	//  Overflow Error
	//*******************************************************
	assign ovf_bit = done & RxRdy;
	
	rs_flop ovf_flop (.clk(clk),
						    .reset(reset),
							 .r(read_0),
							 .s(ovf_bit),
							 .Q(OVF));
endmodule

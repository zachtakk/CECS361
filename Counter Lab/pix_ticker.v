`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This document contains information prorietary to the CSULB student that created
// the file -  any reuse without adequate approval and documentation is prohibited
//
// File Name: ticker.v
// Project: Lab 1
// Created by <Zachery Takkesh> on <September 23, 2019>
// Copright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: The ticker intakes in the default clock frequency and generate a 
// 480 Hz clock  
// 
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////
module pix_ticker(clk, reset, tick);

	// Input declarations
	input clk, reset;
	
	// Output declarations
	output wire tick;
	
	// Reg to hold values for count and D
	reg [17:0] count, D;
	
	// Tick goes high if count counts up to 208_334 in decimal
	assign tick = count == 18'd208334;
	
	// If tick goes high, reset D. If tick is not yet high,
	// continue to increment D
	always @(*)
		if (tick) 
			D = 18'b0;
		else 
			D = count + 18'b1;
	
	// If reset goes high, count goes 0. Else count gets D for 
	// increment
	always @ ( posedge clk, posedge reset)
		if (reset)
			count <= 18'b0;
		else
			count <= D;

endmodule
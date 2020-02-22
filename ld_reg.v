`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This document contains information prorietary to the CSULB student that created
// the file -  any reuse without adequate approval and documentation is prohibited
//
// File Name: ld_reg.v
// Project: Lab 1
// Created by <Zachery Takkesh> on <September 23, 2019>
// Copright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: The loadable register module produces a one-bit load signal. It is a 
//				high-active signal. When asserted, D datat gets loaded into Q. When 
//				deasserted, Q retains the same data.  
// 
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////
module ld_reg(clk, reset, D, Q, ld);
	
	// Input and Output declarations
	input             clk, reset, ld;
	input      [15:0] D;
	output reg [15:0] Q;
	
	// Sequential block for to read the load signal
	// When load is active, Q gets D, or else Q gets Q 
	always @(posedge clk, posedge reset)
		if(reset)
			Q <= 16'b0;
		else begin
			if(ld)
				Q <= D;
			else
				Q <= Q;
		end
endmodule

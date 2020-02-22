`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// This document contains information proprietary to the CSULB student that created
// the file - any reuse without adequate approval and documentation is prohibited   
//
// File Name: ld_reg.v
// Project: Proj 3
// Created by <Zachery Takkesh> on <November 16th, 2019>
// Copyright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: The loadable register module produces a one-bit load signal. It is a 
//				high-active signal. When asserted, the data on D gets loaded into Q.
//				When deasserted, Q retains the same data. Data load/retain happens
//				every clock period.    
// 
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////
module ld_reg(clk, reset, D, Q, load);
	
	// Input and Output declarations
	input            clk, reset, load;
	input      [7:0] D;
	output reg [7:0] Q;
	
	// Sequential block to read the load signal
	// When load is active Q gets D, else Q gets Q 
	always @(posedge clk, posedge reset)
		if(reset)
			Q <= 8'b0;
		else begin
			if(load)
				Q <= D;
			else
				Q <= Q;
		end // end of sequential begin for load asserted
		
endmodule // end of load register
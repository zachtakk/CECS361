`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// This document contains information proprietary to the CSULB student that created
// the file - any reuse without adequate approval and documentation is prohibited   
//
// File Name: rs_flop.v
// Project: Proj 3
// Created by <Zachery Takkesh> on <November 16th, 2019>
// Copyright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: The RS flop module has R and S as inputs to determine the Q output. 
// 			Different values for R and S allow the flop to output different 
//				values for Q. When both signals are on, a don't-care is used so it
//				doesn't matter what value is passed to Q. Default output receives zero.
// 
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////
module rs_flop(clk, reset, r, s, Q);

	// Input and output declarations
	input      clk, reset, r,s;
	output reg Q;
	
	// Sequential block to determine value for Q output
	always @ (posedge clk, posedge reset)
		if(reset)
			Q <= 1'b0;
		else begin 
		
		// Case statement for S and R inputs
			casez({s,r})
				2'b00 : Q <= Q;
				2'b01 : Q <= 1'b0;
				2'b10 : Q <= 1'b1;
				2'b11 : Q <= 1'bz;
				default: Q <= 1'b0;
			endcase //end of casex
		end // end of sequential block
endmodule // end of rs_flop module
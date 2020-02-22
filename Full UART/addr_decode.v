`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// This document contains information proprietary to the CSULB student that created
// the file - any reuse without adequate approval and documentation is prohibited   
//
// File Name: addr_decode.v
// Project: Proj 3
// Created by <Zachery Takkesh> on <November 16th, 2019>
// Copyright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: Address decoder module is designed to receive data from the
// 			TramelBlaze containing: port_id, read_strobe, and write_strobe. The 
//				read_strobe and write_strobe signals will be processed and decoded 
//				from a one-bit to an eight-bit signal.
// 
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////

module addr_decode(en, signal, sel, out);

	// Input and Output Declaration
	input [2:0]  sel;
   input	       en, signal; 
	
	output reg [7:0] out; 
	
	// Case statements to decode input signals 
	always @ (*)
		casez({en, signal, sel})
			5'b0_0_???: out = 8'b0000_0000;
			
			5'b1_1_000: out = 8'b0000_0001;
			5'b1_1_001: out = 8'b0000_0010;
			5'b1_1_010: out = 8'b0000_0100;
			5'b1_1_011: out = 8'b0000_1000;
			
			5'b1_1_100: out = 8'b0001_0000;
			5'b1_1_101: out = 8'b0010_0000;
			5'b1_1_110: out = 8'b0100_0000;
			5'b1_1_111: out = 8'b1000_0000;
			default: out = 8'b0000_0000;
		endcase
		
endmodule // end of address decoder module
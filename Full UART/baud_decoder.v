`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// This document contains information proprietary to the CSULB student that created
// the file - any reuse without adequate approval and documentation is prohibited   
//
// File Name: baud_decoder.v
// Project: Proj 3
// Created by <Zachery Takkesh> on <November 16th, 2019>
// Copyright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: The baud rate decoder is designed to take an incoming baud signal and 
//				decode it to a decimal value representing the baud rate. This module 
//				allows for different baud rates to be selected by using on-board
//			 	switches for the UART protocol.
//
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////
module baud_decoder(baud_val, baud_out);

	// Input and Output Declarations
	input [3:0] baud_val;
	
	output reg [18:0] baud_out;
	
	//*******************************************************
	//  Baud Decoder Selection
	//*******************************************************
	always@(*) begin
		case(baud_val)
			4'b0000: baud_out = 19'd333_333;     //     300
			4'b0001: baud_out = 19'd83_333;      //   1_200
			4'b0010: baud_out = 19'd41_667;      //   2_400
			4'b0011: baud_out = 19'd20_833;      //   4_800
			4'b0100: baud_out = 19'd10_417;      //   9_600
			4'b0101: baud_out = 19'd5_208;       //  19_200
			4'b0110: baud_out = 19'd2_604;       //  38_400
			4'b0111: baud_out = 19'd1_736;       //  57_600
			4'b1000: baud_out = 19'd868;         // 115_200
			4'b1001: baud_out = 19'd434;         // 230_400
			4'b1010: baud_out = 19'd217;         // 460_800
			4'b1011: baud_out = 19'd109;         // 921_600
			default: baud_out = 19'd333_333;
		endcase // end of baud case statement
	end // end of combinational block
	
endmodule // end of baud decoder
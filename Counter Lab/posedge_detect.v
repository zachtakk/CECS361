`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This document contains information prorietary to the CSULB student that created
// the file -  any reuse without adequate approval and documentation is prohibited
//
// File Name: posedge_detect.v
// Project: Lab 1
// Created by <Zachery Takkesh> on <September 23, 2019>
// Copright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: The positive edge detect module is designed to detect a positive edge
// 			input and then returns a one-shot pulse output. If the input is HIGH 
//				for first and second clock period, it will output a high one
//				clock period. 
//
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////
module posedge_detect(clk , reset , in , ped ) ;

	// Input declarations
	input  clk , reset ;
	input  in  ;
	
	// Output declarations
	output wire ped ;
	
	// Reg declarations 
	reg Q1, Q2;

	// if reset asserted clear Q1/2 registers 
	always @ (posedge clk, posedge reset)
		if(reset)
			{Q1, Q2} <= 2'b0;
		else
			{Q1, Q2} <= {in, Q1};
	
	
	assign ped = Q1 & ~Q2; 
	
endmodule // end of positive edge detect 

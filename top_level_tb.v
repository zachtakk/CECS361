`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// This document contains information prorietary to the CSULB student that created
// the file -  any reuse without adequate approval and documentation is prohibited
//
// File Name: top_level_tb.v
// Project: Lab 1
// Created by <Zachery Takkesh> on <September 23, 2019>
// Copright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: This is the top level module testbench. It provides the top level module
// with a stimulus; clk, reset, db_but, sw_uhdl and wait for the TramelBlaze
// to do the increment/decrement of data. 
//
// In submitting this file for class work at CSULB
// I am confirming that this is Tramel's testbench represented on his instruction
// video. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
///////////////////////////////////////////////////////////////////////////////////
module top_level_tb;

	// Inputs
	reg clk;
	reg reset_but;
	reg db_but;
	reg sw_uhdl;

	// Outputs
	wire [7:0] anode;
	wire a;
	wire b;
	wire c;
	wire d;
	wire e;
	wire f;
	wire g;

	// Instantiate the Unit Under Test (UUT)
	top_level uut (
		.clk(clk), 
		.reset_but(reset_but), 
		.db_but(db_but), 
		.anode(anode), 
		.sw_uhdl(sw_uhdl), 
		.a(a), 
		.b(b), 
		.c(c), 
		.d(d), 
		.e(e), 
		.f(f), 
		.g(g)
	);
	always #5 clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		reset_but = 1;
		db_but = 0;
		sw_uhdl = 0; // This value depends since the TramelBlaze
					// take quite long to execute an instruction.
					// Set as 0 to start decrement or 1 to start increment

		// Wait 100 ns for global reset to finish
		#100 reset_but = 0; 
		
		// Wait 1000ns to turn on debounce
		#1000
		db_but  = 1; 
		repeat(10) begin // Repeat this 10 times
		db_but = 1;
		#40_000_000 db_but = 0;
		#40_000_000 db_but = 1;
		
		end
		
		#1000 // Wait 1000ns to turn db off
		db_but = 0;
		sw_uhdl = 1;
		repeat(10) begin // Repeat this 10 times
		db_but = 1;
		#40_000_000 db_but = 0;
		#40_000_000 db_but = 1;
		end

	end
      
endmodule


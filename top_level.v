`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// This document contains information prorietary to the CSULB student that created
// the file -  any reuse without adequate approval and documentation is prohibited
//
// File Name: top_level.v
// Project: Lab 1
// Created by <Zachery Takkesh> on <September 23, 2019>
// Copright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: This is the top level module to the counter that utilizes the 
// 			tramelblze for its functionality. For project 1, we are using the
//				tramel blaze to instantiate a counter. When sw is up, the counter
//				increments. When the switch is down, the counter decrements. 
//
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
/////////////////////////////////////////////////////////////////////////////////// 

module top_level(clk, reset_but, db_but, anode, sw_uhdl,
					  a, b, c, d, e, f, g);
	
	// Input and Output declarations
	input        clk, reset_but, db_but, sw_uhdl;
	output [7:0] anode;
	output       a, b, c, d, e, f, g;
	
	// Wires declarations to interconnect the instantiated modules 
	wire        reset,  pulse,  ped, INT_ACK, rs_out,write_strobe,write_led;
	wire [15:0] tb_out, id_out, load_out;
	

	assign write_led = (id_out == 16'h0001) && write_strobe;
	
	// Instantiate Asynchronous In Synchrnous Out module
	// to synchronize the release of reset
	AISO		reset_sync0 (.clk(clk),
								 .reset(reset_but),
								 .reset_sync(reset));
								 
	// Instantiate debounce module to generate a stable
	// signal. Any transition less than 20ms is ignored 
	debounce bounce0		 (.clk(clk),
								  .reset(reset),
								  .in(db_but),
								  .p_out(pulse));
	
	// Instantiate posedge_detect module to detect the 
	// positive edge of the clock
	posedge_detect ped0   (.clk(clk),
							     .reset(reset),
								  .in(pulse),
								  .ped(ped));
	
	// Instantiate the rs_flop to allow Q outputs to be
	// either 1 or 0
	rs_flop  flop0        (.clk(clk),
								  .reset(reset),
								  .s(ped),
								  .r(INT_ACK),
								  .Q(rs_out));
	
	// Instanatiate the TramelBlaze as a processor 
	tramelblaze_top  tb0     (.CLK(clk),
									  .RESET(reset),
									  .IN_PORT({15'b0,sw_uhdl}),
									  .INTERRUPT(rs_out),
									  .INTERRUPT_ACK(INT_ACK),
									  .READ_STROBE(),
									  .OUT_PORT(tb_out),
									  .PORT_ID(id_out),
									  .WRITE_STROBE(write_strobe));
	
   // Instantiate the loadable registers to load data
   // to the output 	
	ld_reg			reg0      (.clk(clk),
									  .reset(reset),
									  .ld(write_led),
									  .D(tb_out),
									  .Q(load_out));
	
	// Instantiate the display controller module
	// to display counter Q onto the 7seg display
	display_controller disp0 (.clk(clk),
								     .reset(reset),
									  .addr(16'b0),
									  .D_out(load_out),
									  .anode(anode),
									  .a(a), .b(b), .c(c), .d(d),
									  .e(e), .f(f), .g(g));
									  	
endmodule
`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// This document contains information proprietary to the CSULB student that created
// the file - any reuse without adequate approval and documentation is prohibited   
//
// File Name: UART_top.v
// Project: Proj 3
// Created by <Zachery Takkesh> on <November 16th, 2019>
// Copyright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: The UART top module connects the UART module to the TramelBlaze with 
// 			a synchronized reset. The TramelBlaze executes assembly instructions 
//				from a generated memory file via the Trambler.PY program. The software
//				is designed to output a welcome banner first, followed by an output 
//				prompt asking for user input(s). An input of "@" will output the number
//				of inputed characters prior to entering the "@" character. An input 
//				of "*" will output the assembly code designers hometown. 
//				A "BS" or "backspace" deletes an inputted character. "CR" or 
//				"enter" will output the prompt to a new line.
//
//
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////////
module UART_top(clk, reset_but, sw, Rx, Tx, LED);
	// Input and Output declarations
	input clk, reset_but, Rx;
	input [7:0] sw;
	
	output Tx;
	output reg [15:0] LED;
	
	// Inner Module wire declarations
	wire reset, int_ack, read_strobe, write_strobe, interrupt;
	wire [7:0] read, write;
	wire [15:0] out_port, port_id, in_port; 
	
	//***********************************************************
	//  AISO Instantiation
	//***********************************************************
	AISO reset0 (.clk(clk),
					 .reset(reset_but),
					 .reset_sync(reset));
		
	//***********************************************************
	//  UART Instantiation
	//***********************************************************	
	UART uart0 (.clk(clk),
					.reset(reset),
					.switches(sw),
					.Rx(Rx),
					.read(read),
					.write(write),
					.out_port(out_port),
					.interrupt_ack(int_ack),
					.interrupt(interrupt),
					.Tx(Tx),
					.in_port(in_port));
	
	//***********************************************************
	// TramelBlaze Instantiation
	//***********************************************************
	tramelblaze_top tb0(.CLK(clk),
							  .RESET(reset),
							  .IN_PORT(in_port),
							  .INTERRUPT(interrupt),
							  .OUT_PORT(out_port),
							  .PORT_ID(port_id),
							  .READ_STROBE(read_strobe),
							  .WRITE_STROBE(write_strobe),
							  .INTERRUPT_ACK(int_ack));
	
	//***********************************************************
	// Address decoder Instantiation for Read Strobe (8-bit)
	//***********************************************************
	addr_decode read_decode (.en(~port_id[15]), 
								    .sel(port_id[2:0]),
									 .signal(read_strobe),
									 .out(read));
	
	//***********************************************************
	// Address decoder Instantiation for Write Strobe (8-bit)
	//***********************************************************
	addr_decode write_decode (.en(~port_id[15]), 
								    .sel(port_id[2:0]), 
									 .signal(write_strobe),
									 .out(write));
	
	//***********************************************************
	// Loadable Register Instantiation for walking LED's 
	//***********************************************************
	always @(posedge clk, posedge reset)
		if (reset)
			LED <= 16'b0;
		else if (write[2])
			LED <= out_port;
		else
			LED <= LED;
			
endmodule // end of UART top module
`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// This document contains information proprietary to the CSULB student that created
// the file - any reuse without adequate approval and documentation is prohibited   
//
// File Name: UART.v
// Project: Proj 3
// Created by <Zachery Takkesh> on <November 16th, 2019>
// Copyright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: The UART module is designed to connect the Transmit Engine and 
// 			Receive Engine. There are other essential components for the UART 
//				module such as a loadable register for the UART configuration, a mux
//				to select which signals to send to the output registers via the 
//				IN_PORT channel contained in the TramelBlaze module.
//
//
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////
module UART(clk, reset, switches, Rx, read, write, out_port, interrupt_ack,
            interrupt, Tx, in_port);
				
	// Input and Output Declarations 
	input        clk, reset, Rx, interrupt_ack;
	input [7:0]  read, write, switches;
	input [15:0] out_port;
	
	output wire interrupt, Tx;
	output reg [15:0] in_port;
	
	// Inner Module Wire Declarations
	wire        TxRdy, RxRdy, ovf, ferr, perr, TxPed, RxPed, int_s;
	wire [7:0]  uart_config, rx_data;
	wire [18:0] k;
	
	//***********************************************************
	//  Loadable Register Instantiation for UART Configuration
	//***********************************************************
	ld_reg load0 (.clk(clk),
					  .reset(reset),
					  .D(out_port[7:0]),
					  .Q(uart_config),
					  .load(write[6]));
						  
	//***********************************************************
	//  Baud Decoder Instantiation for Baud Rate Selection
	//***********************************************************
	baud_decoder baud0 (.baud_val(uart_config[7:4]),
							  .baud_out(k));


	//***********************************************************
	//  Transmit Engine Instantiation 
	//***********************************************************
	transmitEngine tx0 (.clk(clk),
							  .reset(reset),
							  .load(write[0]),
							  .eight(uart_config[3]),
							  .pen(uart_config[2]),
							  .ohel(uart_config[1]),
							  .baud_out(k),
							  .out_port(out_port[7:0]),
							  .TxRdy(TxRdy),
							  .Tx(Tx));
							  
	//***********************************************************
	//  Receive Engine Instantiation
	//***********************************************************
	receiveEngine rx0 (.clk(clk),
							 .reset(reset),
							 .eight(uart_config[3]),
							 .pen(uart_config[2]),
							 .ohel(uart_config[1]),
							 .k(k),
							 .read_0(read[0]),
							 .Rx(Rx),
							 .RxRdy(RxRdy),
							 .OVF(ovf),
							 .FERR(ferr),
							 .PERR(perr),
							 .rx_data(rx_data));
							 
	//***********************************************************
	//  Positive Edge Instantiation for RxRdy and TxRdy 
	//***********************************************************
	posedge_detect ped0 (.clk(clk),
								.reset(reset),
								.in(TxRdy),
								.ped(TxPed));
			
	posedge_detect ped1 (.clk(clk),
								.reset(reset),
								.in(RxRdy),
								.ped(RxPed));
						
	//***********************************************************
	//  RS Flop Instantiation for Interrupt 
	//***********************************************************						
	assign int_s = (TxPed | RxPed);
	
	rs_flop int_rs (.clk(clk),
						 .reset(reset),
						 .r(interrupt_ack),
						 .s(int_s),
						 .Q(interrupt));
						 
	//***********************************************************
	//  In port Multiplexor(MUX) for TramelBlaze IN_PORT
	//***********************************************************
	wire [7:0] status;
	
	assign status = {3'b0, ovf, ferr, perr, TxRdy, RxRdy};
	
	always @ (*)
		casez({read[2:0]})
			3'b001: in_port = {8'b0,rx_data};
			3'b010: in_port = {8'b0, status};
			3'b100: in_port = {8'b0,switches};
			default: in_port = 8'b0; 
		endcase
		
endmodule // end of UART module
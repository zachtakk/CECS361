`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////
// This document contains information prorietary to the CSULB student that created
// the file -  any reuse without adequate approval and documentation is prohibited
//
// File Name: pixel_controller.v
// Project: Lab 1
// Created by <Zachery Takkesh> on <September 23, 2019>
// Copright @ 2019 <Zachery Takkesh>. All rights reserved
//
// Purpose: This module is a FSM which has 3 parts:
// 			the next state output, state register, and the output
// 			combo. Since this is an Moore FSM, it will go
// 			from S0 to S7 with its corresponding outputs for anode and S (select).
//
// In submitting this file for class work at CSULB
// I am confirming that this is my work and the work of no one else. 
// 
// In submitting this code I acknowledge that plagiarism in student project
// work is subject to dismissal from the class. 
////////////////////////////////////////////////////////////////////////////////

module pixel_controller(clk, reset, S, anode );

        // Inputs, outputs, and register declarations
        input            clk , reset ;
        output reg [7:0] anode;
		  
        // S value selects a value which will be assign to Y
        output reg [2:0] S;
		  
        // Present state and next state
        reg        [2:0] pState, nState;
			
		  // Clock wire to divide down the clock
			wire clk_out;
			
		  // Instantiate pixel clock to divide the default clock of 100MHz to 480Hz
        // The reason for using a divided clock is to refresh the 7Segments on the 
	     // FPGA board
	     pix_ticker        clk0       (.clk(clk), 
										        .reset(reset), 
											     .tick(clk_out));
												  
        /********NEXT STATE COMBINATIONAL LOGIC********
        * This FSM sets a new state based on what the 
		  * present state is. 
        **********************************************/
        always@ (pState) begin
            case ({pState,clk_out})
					 4'b000_0:  nState = 3'b000;
                4'b000_1:  nState = 3'b001;
					 
					 4'b001_0:  nState = 3'b001;
                4'b001_1:  nState = 3'b010;
					 
					 4'b010_0:  nState = 3'b010;
                4'b010_1:  nState = 3'b011;
					 
					 4'b011_0:  nState = 3'b011;
                4'b011_1:  nState = 3'b100;
					 
					 4'b100_0:  nState = 3'b100;
                4'b100_1:  nState = 3'b101;
					 
					 4'b101_0:  nState = 3'b101;
                4'b101_1:  nState = 3'b110;
					 
					 4'b110_0:  nState = 3'b110;
                4'b110_1:  nState = 3'b111;
					 
					 4'b111_0:  nState = 3'b111;
                4'b111_1:  nState = 3'b000;
                default: nState = 3'b000; // default next state is 0
            endcase // end of case statement 
				
        end // end of next state combo block

        /*******************STATE REGISTER*******************
        * The state register is a simple D_ff. When the reset
        * is 1, the present state returns to its initial state.
        * Otherwise, present state is set equal to next state. 
        ****************************************************/
        always@(posedge clk or posedge reset) begin
            if (reset == 1'b1)
                pState <= 3'b000;
            else 
                pState <= nState;
					 
        end // end of state register block
		  
		 /************OUTPUT COMBINATIONAL LOGIC************
        * When the present state is at a specific state the
        * anodes and S will have an output. anode has 8 bits
        * and S has 3 bits which is totalled up to be 11 bits.
        *************************************************/
        always@ (pState) begin
            case (pState)
                3'b000:  {anode, S} = 11'b11111110_000; // anode[0]
                3'b001:  {anode, S} = 11'b11111101_001; // anode[1]
                3'b010:  {anode, S} = 11'b11111011_010; // anode[2]
                3'b011:  {anode, S} = 11'b11110111_011; // anode[3]
                3'b100:  {anode, S} = 11'b11101111_100; // anode[4]
                3'b101:  {anode, S} = 11'b11011111_101; // anode[5]
                3'b110:  {anode, S} = 11'b10111111_110; // anode[6]
                3'b111:  {anode, S} = 11'b01111111_111; // anode[7]
                default: {anode, S} = 11'b00000000_000; // default all anode on, S is 0
            endcase // end of case statement
				
        end // end of output combo logic

endmodule // end of pixel_controller
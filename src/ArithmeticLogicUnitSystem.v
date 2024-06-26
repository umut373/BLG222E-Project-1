`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.03.2024 21:07:09
// Design Name: 
// Module Name: ArithmeticLogicUnitSystem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ArithmeticLogicUnitSystem(
    RF_OutASel, RF_OutBSel, RF_FunSel, RF_RegSel, RF_ScrSel, ALU_FunSel, ALU_WF, ARF_OutCSel, 
    ARF_OutDSel, ARF_FunSel, ARF_RegSel, IR_LH, IR_Write, Mem_WR, Mem_CS, MuxASel, MuxBSel, MuxCSel, Clock
    );
    input [2:0] RF_OutASel, RF_OutBSel, RF_FunSel;
    input [3:0] RF_RegSel, RF_ScrSel;
    input [4:0] ALU_FunSel;
    input ALU_WF;
    input [1:0] ARF_OutCSel, ARF_OutDSel;
    input [2:0] ARF_FunSel, ARF_RegSel;
    input IR_LH, IR_Write;
    input Mem_WR, Mem_CS;
    input [1:0] MuxASel, MuxBSel;
    input MuxCSel;
    input Clock;
    
    reg [15:0] MuxAOut, MuxBOut;
    reg [7:0] MuxCOut;
    
    wire [15:0] OutA, OutB, OutC;
    wire [15:0] Address;
    wire [15:0] ALUOut;
    wire [7:0] IROut;
    wire [7:0] MemOut;
    
    RegisterFile RF(.I(MuxAOut), .OutASel(RF_OutASel), .OutBSel(RF_OutBSel), .FunSel(RF_FunSel), 
        .RegSel(RF_RegSel), .ScrSel(RF_ScrSel), .Clock(Clock), .OutA(OutA), .OutB(OutB));
    AddressRegisterFile ARF(.I(MuxBOut), .OutCSel(ARF_OutCSel), .OutDSel(ARF_OutDSel), .FunSel(ARF_FunSel), 
               .RegSel(ARF_RegSel), .Clock(Clock), .OutC(OutC), .OutD(Address));
    InstructionRegister IR(.I(MemOut), .Write(IR_Write), .LH(IR_LH), .Clock(Clock), .IROut(IROut));
    ArithmeticLogicUnit ALU(.A(OutA), .B(OutB), .FunSel(ALU_FunSel), .WF(ALU_WF), .Clock(Clock), .ALUOut(ALUOut));
    Memory MEM(.Address(Address), .Data(MuxCOut), .WR(Mem_WR), .CS(Mem_CS), .Clock(Clock), .MemOut(MemOut));
    
    always @(*) begin
        case(MuxASel)
            2'b00: MuxAOut = ALUOut;
            2'b01: MuxAOut = OutC;
            2'b10: MuxAOut = {8'b0, MemOut};
            2'b11: MuxAOut[7:0] = IROut;
        endcase
        
        case(MuxBSel)
            2'b00: MuxBOut = ALUOut; 
            2'b01: MuxBOut = OutC;
            2'b10: MuxBOut = {8'b0, MemOut};
            2'b11: MuxBOut[7:0] = IROut;
        endcase
        
        case(MuxCSel)
            1'b0: MuxCOut = ALUOut[7:0];
            1'b1: MuxCOut = ALUOut[15:8]; 
        endcase
    end
    
endmodule

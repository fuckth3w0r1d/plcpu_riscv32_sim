`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, IMM, aluout, stall, NPC);  // next pc module
   input  [31:0] PC;        // pc
   input  [4:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
   input [31:0] aluout;     // alu out 给 jalr 使用
   input stall;             // stall 信号
   output reg [31:0] NPC;   // next pc
   
   wire [31:0] PCPLUS4;
   assign PCPLUS4 = PC + 4; // pc + 4
  
// `define NPC_PLUS4   5'b00000
// `define NPC_BRANCH  5'b00001
// `define NPC_JUMP    5'b00010
// `define NPC_JALR 5'b00100

   always @(*) begin
        if (stall) begin
            NPC = PC;  // stall
        end else begin
        case (NPCOp)
            `NPC_PLUS4:  NPC = PCPLUS4;
            `NPC_BRANCH: NPC = PC + IMM;
            `NPC_JUMP:   NPC = PC + IMM;
            `NPC_JALR:   NPC = aluout;
            default:     NPC = PCPLUS4;
        endcase
        end
    end // end always
   
endmodule

module Hazard_Detect(
    input [4:0] IF_ID_rs1, IF_ID_rs2,  // IF/ID阶段的源寄存器
    input [4:0] ID_EX_rd,              // ID/EX阶段的目的寄存器
    input ID_EX_RegWrite,
    input ID_EX_MemRead,               // ID/EX阶段是否为load
    input IF_ID_Use_rs2,               // IF/ID指令是否在EX阶段使用rs2
    output reg stall
);

always @(*) begin
    stall = 1'b0;
    // 只对真正的 load-use 冒险停顿
    if (ID_EX_MemRead && ID_EX_RegWrite && (ID_EX_rd != 0) &&
        ((ID_EX_rd == IF_ID_rs1) ||
         (IF_ID_Use_rs2 && (ID_EX_rd == IF_ID_rs2)))) begin
        stall = 1'b1;
    end
end

endmodule

module Forwarding(
    input [4:0] ID_EX_rs1,    // ID/EX阶段的rs1
    input [4:0] ID_EX_rs2,    // ID/EX阶段的rs2
    input [4:0] EX_MEM_rs2,    // EX/MEM阶段的rs2（sw写内存的数据源寄存器）
    input [4:0] EX_MEM_rd,    // EX/MEM阶段的rd
    input [4:0] MEM_WB_rd,    // MEM/WB阶段的rd
    input EX_MEM_RegWrite,    // EX/MEM阶段的寄存器写使能
    input MEM_WB_RegWrite,    // MEM/WB阶段的寄存器写使能
    output reg [1:0] ForwardA, // ALU输入A的前递选择
    output reg [1:0] ForwardB  // ALU输入B的前递选择
    output reg ForwardMEM      // 写内存时源寄存器数据的转发（sw）
);

// ForwardA控制逻辑
always @(*) begin
    ForwardA = 2'b00; // 默认值：无前递
    
    // 优先级1：EX/MEM阶段前递（最近的计算结果）
    if (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1)) begin
        ForwardA = 2'b10; // EX/MEM -> EX
    end 
    // 优先级2：MEM/WB阶段前递（较早的结果）
    else if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs1)) begin
        ForwardA = 2'b01; // MEM/WB -> EX （此时需要一次stall）
    end
end

// ForwardB控制逻辑
always @(*) begin
    ForwardB = 2'b00; // 默认值：无前递
    
    if (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2)) begin
        ForwardB = 2'b10; 
    end 
    else if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs2)) begin
        ForwardB = 2'b01;
    end
end

// MEM/WB -> MEM：给store指令写内存的数据做旁路
always @(*) begin
    ForwardMEM = 1'b0;

    if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == EX_MEM_rs2)) begin
        ForwardMEM = 1'b1;
    end
end

endmodule
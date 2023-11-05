module seq_core #(
                    parameter A_BITS = 10,
                    parameter D_BITS = 32
)(
       // general
       input rst, // active 0
       input clk,
       // program memory
       output reg [A_BITS-1:0] pc,
       input [15:0] instr,
       // data memory
       output reg read, // active 1
       output reg write, //active 1
       output reg [A_BITS-1:0] address,
       input [D_BITS-1:0] data_in,
       output  reg [D_BITS-1:0] data_out
);

// intern memory
reg [D_BITS-1:0] memory[0:7];

reg [D_BITS-1:0] result;

// index used for reseting regs
integer i; 

// current program counter
reg [A_BITS-1:0] currentPC;

reg [A_BITS-1:0] nextPC;

always@(*) begin
    if(!rst) begin
    // reset signals and registers
        read = 1'b0;
        write = 1'b0;
        address = 'bx;
        for(i=0; i<8;i = i + 1)begin
            memory[i] = 0;
        end
    end else begin
        if(instr[15:0] ==  `HALT) begin
            nextPC = pc;
            $display("CURRENT PC IS THE SAME");
        end 
        else if(instr[15:0] == `NOP) nextPC = pc + 1;
        // check if there is a jump operations
        else 
        case(instr[15:12])
            `JMP : nextPC =  memory[instr[2:0]];
            `JMPR: begin
                nextPC = pc + ({{A_BITS - 6{instr[5]}}, instr[5:0]});
            end
            `JMPCOND:
                case(instr[11:9])
                    `N : begin
                        if(memory[instr[8:6]] < 0) begin
                            nextPC = memory[instr[2:0]];
                            $display("entered in `N JMPCOND");
                        end else
                            nextPC = pc +1;
                            $display("entered in else `N JMPCOND");
                    end
                    `NN:begin
                        if(memory[instr[8:6]] >= 0) begin
                            nextPC =  memory[instr[2:0]];
                            $display("entered in `NN JMPCOND");
                        end else
                            nextPC = pc +1;
                            $display("entered in else `NN JMPCOND");
                    end
                    `Z:begin
                        if(memory[instr[8:6]] == 0) begin
                            nextPC =  memory[instr[2:0]];
                            $display("entered in `Z JMPCOND");
                        end else
                            nextPC = pc +1;
                            $display("entered in else `Z JMPCOND");
                    end
                    `NZ:begin
                        if(memory[instr[8:6]] != 0) begin
                            nextPC =  memory[instr[2:0]];
                            $display("entered in `NZ JMPCOND");
                        end else
                            nextPC = pc +1;
                            $display("entered in else `NZ JMPCOND");
                    end
                endcase
            `JMPRCOND: begin
                case(instr[11:9])
                    `N: begin
                        if(memory[instr[8:6]] < 0) begin
                            nextPC = pc + ({{A_BITS - 6{instr[5]}}, instr[5:0]});
                        end else
                            nextPC = pc + 1;
                    end
                    `NN: begin
                         if(memory[instr[8:6]] >= 0) begin
                            nextPC = pc + ({{A_BITS - 6{instr[5]}}, instr[5:0]});
                        end else
                            nextPC = pc + 1;
                    end
                    `Z: begin
                         if(memory[instr[8:6]] == 0) begin
                            nextPC = pc + ({{A_BITS - 6{instr[5]}}, instr[5:0]});
                        end else
                            nextPC = pc + 1;
                    end
                    `NZ: begin
                         if(memory[instr[8:6]] != 0) begin
                            nextPC = pc + ({{A_BITS - 6{instr[5]}}, instr[5:0]});
                        end else
                            nextPC = pc + 1;
                    end
                endcase
            
            end
            
            default : begin
                nextPC = pc + 1;
            end 
        endcase
    end 
end


always@(*) begin
    case(instr[15:14])
    // arithemtic ops
        2'b00: begin
            case(instr[15:9])
                `ADD:    result = memory[instr[5:3]] + memory[instr[2:0]];
                `ADDF:   result = memory[instr[5:3]] + memory[instr[2:0]];
                `SUB:    result = memory[instr[5:3]] - memory[instr[2:0]];
                `SUBF:   result = memory[instr[5:3]] - memory[instr[2:0]];
                `AND:    result = memory[instr[5:3]] & memory[instr[2:0]];
                `OR:     result = memory[instr[5:3]] | memory[instr[2:0]];
                `XOR:    result = memory[instr[5:3]] ^ memory[instr[2:0]];
                `NAND:   result = ~(memory[instr[5:3]] & memory[instr[2:0]]);
                `NOR:    result = ~(memory[instr[5:3]] | memory[instr[2:0]]);
                `NXOR:   result = ~(memory[instr[5:3]] ^ memory[instr[2:0]]);
                `SHIFTR: result = memory[instr[8:6]] >> memory[instr[5:0]];
                `SHIFTRA:result = memory[instr[8:6]] >>> memory[instr[5:0]];
                `SHIFTL: result = memory[instr[8:6]] << memory[instr[5 :0]];
            endcase
        end
        // memory access ops
        2'b01: begin
            case(instr[15:11])
                `LOAD : begin
                    result = data_in;
                    address = memory[instr[2:0]][A_BITS-1:0];
                    read = 1'b1;
                    write = 1'b0;
                    data_out = 'bx;
                 end 
                //`STORE: memory[instr[10:8]] = memory[instr[2:0]];
                `LOADC: begin
                    result = {memory[instr[10:8]][D_BITS-1:8],instr[7:0]};
                    read = 1'b0;
                    write = 1'b0;
                    address = 'bx;
                    data_out = 'bx;
                 end
                `STORE : begin
                    //memory[instr[10:8]] = memory[instr[2:0]];
                     data_out = memory[instr[2:0]];
                    address = memory[instr[10:8]][A_BITS-1:0];
                    read = 1'b0;
                    write = 1'b1;
                 end 
                 default : begin
                    read = 1'b0;
                    write = 1'b0;
                    address = 'bx;
                    data_out = 'bx;
                 end
            endcase
        end
       
    endcase
end

always@(posedge clk) begin
// updating the program counter  
    if(rst) begin
        pc <= nextPC;
        case(instr[15:14])
            2'b00: // arithmetic ops
                memory[instr[8:6]] <= result;
            2'b01: // memory access ops
                if(instr[15:11] == `LOADC || instr[15:11] == `LOAD) begin
                    memory[instr[10:8]] <= result;
                end 
        endcase
   end else begin
        pc <= 0;
        nextPC = 0;
   end
end

//assign data_out = (read) ? memory[address] : 'bx;

endmodule
// This testcase generates random data and addresses and writes them into the RAM.
// The same addresses are read back out and the values are compared to the values that were written
// If the data does not match, then the simulaiton fails. 
// If the simulaiton makes it to the end, then its considered a pass

`timescale 1ns / 1ps

parameter C_RAM_DEPTH  = 256;
parameter C_RAM_WIDTH  = 16;
parameter C_ADDR_WIDTH  = $clog2(C_RAM_DEPTH);
parameter RD_CLK_FREQ_MHz = 200; // 200 MHz
parameter WR_CLK_FREQ_MHz = 100; // 100 MHz
    
class random_stimulous;
    rand logic rand_wr_enable;
    randc logic [C_ADDR_WIDTH-1:0] rand_wr_addr; // need to use randc because if we write to the same address twice before its read, the testcase could fail
    rand logic [C_RAM_WIDTH-1:0] rand_data_in;
endclass

module testbench();

    random_stimulous rs;
   
    logic clka, clkb;
    logic resetn;
    logic write_enable;
    logic rd_enable;
    logic [C_ADDR_WIDTH-1:0] write_addr;
    logic [C_ADDR_WIDTH-1:0] rd_addr;
    logic [C_RAM_WIDTH-1:0] data_in;
    logic [C_RAM_WIDTH-1:0] data_out;

    logic [C_RAM_WIDTH-1:0] expected_data;
    logic [C_RAM_WIDTH-1:0] valid_data_writes [$];
    logic [C_ADDR_WIDTH-1:0] valid_addr_writes [$];
    
    initial begin
        rs = new();
        clka = 0;
        clkb = 0;
        resetn = 0;
        #200;
        resetn = 1;
    end

    always #(1000/RD_CLK_FREQ_MHz) clka = ~ clka;
    always #(1000/WR_CLK_FREQ_MHz) clkb = ~ clkb;

    // Write random data to RAM:
    always @ (posedge clka) begin
        assert(rs.randomize()) else begin
            $display("Randomization of stimulous class failed at %0t ns", $time);
            $stop;
        end
        data_in = rs.rand_data_in;
        write_addr = rs.rand_wr_addr;
        write_enable = rs.rand_wr_enable;

        // Store the valid write data and address in a queue so we can read thee addresses back out and compare
        if(write_enable == 1 && resetn == 1) begin
            $display("Into Queue: data = 0x%0X, address = 0x%0X", data_in, write_addr);
            valid_data_writes.push_back(data_in);
            valid_addr_writes.push_back(write_addr);
        end
    end

    // When there is an address in the queue, read it and compare it to the expected value
    always @ (posedge clkb) begin
        if(valid_addr_writes.size() != 0) begin
            rd_enable = 1;
            rd_addr = valid_addr_writes.pop_front();
            // Check if the data_out bus matches the data in the queue:
            expected_data = valid_data_writes.pop_front();
            $display("Out of Queue: data = 0x%0X, address = 0x%0X", expected_data, rd_addr);
            @ (posedge clkb); // wait a clk cycle for read data
            assert (data_out == expected_data) else begin
                $error("Memory read error @ time %0t: expected value at addr 0x%0X = 0x%0X, actual value = 0x%0X ", $time, rd_addr, expected_data, data_out);
                $display("----------------------------------");
                $display("SIMULATION FAILED");
                $display("----------------------------------");
                $stop;
            end
        end else begin
            rd_enable = 0;
        end

    end

    RAM # (
        .RAM_DEPTH(C_RAM_DEPTH),
        .RAM_WIDTH(C_RAM_WIDTH),
        .ADDR_WIDTH(C_ADDR_WIDTH)
    ) DUT (
        .clk_wr(clka),
        .clk_rd(clkb),
        .aresetn(resetn),
        .write_en(write_enable),
        .read_en(rd_enable),
        .addr_wr(write_addr),
        .addr_rd(rd_addr),
        .data_in(data_in),
        .data_out(data_out)
    );
    

endmodule

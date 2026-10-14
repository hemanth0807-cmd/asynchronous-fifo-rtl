
module tb_async_fifo;

    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;

    //-----------------------------------------
    // DUT Signals
    //-----------------------------------------

    logic wr_clk;
    logic rd_clk;

    logic wr_rst_n;
    logic rd_rst_n;

    logic wr_en;
    logic rd_en;

    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;

    logic full;
    logic empty;
    
    //==================================================
    // Scoreboard
    //==================================================

    // Expected data queue
    logic [DATA_WIDTH-1:0] expected_q[$];

    // Variable to store expected data
    logic [DATA_WIDTH-1:0] expected_data;

    //-----------------------------------------
    // DUT
    //-----------------------------------------

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),

        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty)
    );

    //-----------------------------------------
    // Write Clock
    //-----------------------------------------

    initial begin
        wr_clk = 0;
        forever #1.5 wr_clk = ~wr_clk;
    end

    //-----------------------------------------
    // Read Clock
    //-----------------------------------------

    initial begin
        rd_clk = 0;
        forever #2.35 rd_clk = ~rd_clk;
    end

    //-----------------------------------------
    // Driver Write
    //-----------------------------------------

   task automatic driver_write(input logic [DATA_WIDTH-1:0] data);

    @(negedge wr_clk);

    if (full) begin
        $display("[%0t] DRIVER : FIFO FULL - Write skipped", $time);
        return;
    end

    wr_data = data;
    wr_en   = 1;

    @(posedge wr_clk);

    @(negedge wr_clk);

    wr_en = 0;

    $display("[%0t] DRIVER WRITE : %h", $time, data);

endtask

    //-----------------------------------------
    // Driver Read
    //-----------------------------------------

    task automatic driver_read();

    @(negedge rd_clk);

    if (empty) begin
        $display("[%0t] DRIVER : FIFO EMPTY - Read skipped", $time);
        return;
    end

    rd_en = 1;

    @(posedge rd_clk);

    @(negedge rd_clk);

    rd_en = 0;

endtask

    //-----------------------------------------
    // Write Monitor
    //-----------------------------------------

    initial begin

        forever begin

            @(posedge wr_clk);

            if (wr_en && !full) begin

            expected_q.push_back(wr_data);

            $display("[%0t] MONITOR WRITE : %h",
             $time, wr_data);
                end
        end

    end

    //-----------------------------------------
    // Read Monitor
    //-----------------------------------------

    initial begin

        forever begin

            @(posedge rd_clk);

            if (rd_en && !empty) begin

                expected_data = expected_q.pop_front();
            
                if (expected_data == rd_data)
            
                    $display("[%0t] PASS : Expected = %h Actual = %h",
                             $time, expected_data, rd_data);
            
                else
            
                    $display("[%0t] FAIL : Expected = %h Actual = %h",
                             $time, expected_data, rd_data);
            
            end 

        end

    end

//==================================================
// Assertions
//==================================================

property no_write_when_full;
    @(posedge wr_clk)
    !(wr_en && full);
endproperty

assert property(no_write_when_full)
else
    $error("[%0t] ERROR: Write attempted while FIFO is FULL", $time);
    
    
property no_read_when_empty;
    @(posedge rd_clk)
    !(rd_en && empty);
endproperty

assert property(no_read_when_empty)
else
    $error("[%0t] ERROR: Read attempted while FIFO is EMPTY", $time);
    
    
property wptr_increment;

    @(posedge wr_clk)
    disable iff(!wr_rst_n)

    (wr_en && !full)
        |=> (dut.wbin == $past(dut.wbin) + 1);

endproperty

assert property (wptr_increment)
else
    $error("[%0t] ERROR : Write pointer failed to increment", $time);
    
 property wptr_stable;

    @(posedge wr_clk)
    disable iff(!wr_rst_n)

    (!wr_en || full)
        |=> $stable(dut.wbin);

endproperty

assert property (wptr_stable)
else
    $error("[%0t] ERROR : Write pointer changed unexpectedly", $time);
    

    
    
    //=====================================
    // TEST 5 : RANDOM STRESS TEST
    //=====================================

initial begin

    //-------------------------
    // Reset
    //-------------------------

    wr_rst_n = 0;
    rd_rst_n = 0;

    wr_en   = 0;
    rd_en   = 0;
    wr_data = 0;

    #20;

    wr_rst_n = 1;
    rd_rst_n = 1;

    $display("\n==================================");
    $display("TEST 5 : RANDOM STRESS TEST");
    $display("==================================\n");

    //-------------------------
    // 100 Random Transactions
    //-------------------------

    repeat (100) begin

        if ($urandom_range(0,1))
            driver_write($urandom_range(0,255));
        else
            driver_read();

    end

    //-------------------------
    // Drain Remaining Data
    //-------------------------

    while (!empty)
        driver_read();

    #20;
    $finish;

end
endmodule
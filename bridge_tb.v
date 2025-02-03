module bridge_tb(




		);

 /////////////////////ahb slave
reg hclk,hresetn,hselapb,hwrite;
reg [1:0] htrans;
reg [31:0] haddr,hwdata;
wire hresp;
wire [31:0] hrdata;

////////////////////////////apb outpute signal

reg [31:0] prdata;
wire psel,penable, pwrite,hready;
wire [31:0] paddr,pwdata;

bridge_rtl bridge(hclk,hresetn,hselapb,hwrite,htrans,
 		haddr,hwdata,
		prdata,
		paddr,pwdata,
		psel,penable,pwrite,
		hresp,hready,
		hrdata);
  initial
	begin
	    hclk = 0;
  end


always #10 hclk = ~hclk;


task reset_bridge();
	begin
	    @(negedge hclk)
		hresetn = 1;
		@(negedge hclk)
		  hresetn = 0;
	end
	endtask
  



	initial
	begin
	
	reset_bridge ();
	#10 ;
	hwrite = 1'b0;
	hselapb = 1'b1;
	htrans = 2'b10;
	haddr =32;
	#10 ;
	hwrite = 1'bx;
	hselapb = 1'b0;
	htrans = 2'bxx;
	haddr = 32'hxxxx_xxxx;
	#5 ;
	prdata =40;
	end
endmodule
	


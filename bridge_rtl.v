module bridge_rtl(
input hclk,hresetn,hselapb,hwrite,
input [1:0] htrans,input[31:0] haddr,
input [31:0] hwdata,
input [31:0] prdata,
output reg [31:0] paddr,pwdata,
output reg psel,penable,pwrite,
output reg hresp,hready,
output reg [31:0] hrdata
);
 
  parameter idle = 3'b000;
  parameter read = 3'b001;
  parameter wwait = 3'b010;
  parameter write = 3'b011;
  parameter write_p = 3'b100;
  parameter wenable_p =3'b101;
  parameter wenable = 3'b110;
  parameter renable = 3'b111; 
  reg[31:0] haddr_temp,hwdata_temp;
  reg[2:0] present_state,next_state;
  reg valid,hwrite_temp;

  always@(*)
  	begin
	   if(hselapb == 1'b1 && (htrans == 2'b10 || htrans == 2'b11))
		valid = 1'b1;
		else
		valid = 1'b0;
 
                if(hresetn == 1'b0)
		    present_state = idle;
		  else
		    present_state = next_state;
    end
    

    always@(present_state)
	begin
		case(present_state)
			idle:
			    begin
			       psel = 1'b0;
			       penable = 1'b0;
 				hready = 1'b1;

   				if(valid == 1'b0)
				    next_state = idle;
				    else if(valid == 1'b1 && hwrite ==1'b0)
					next_state = read;
					
 					else if(valid == 1'b1 && hwrite ==1'b1)
					next_state = wwait;
			end

		read:
		   begin
	 	 	psel = 1'b1;
		 	paddr = haddr;
			pwrite = 1'b0;
			penable = 1'b0;
			hready = 1'b0;

			next_state = renable;
		end


		renable :
		 	begin
				penable = 1'b1;
				hrdata = prdata;
				hready = 1'b1;
				if(valid == 1'b1 && hwrite ==1'b0)
 	 	 	 		next_state =read;
                                	else if(valid == 1'b1 && hwrite ==1'b1)
 	 	 	 			next_state =wwait;
						else if(valid == 1'b0)
 	 	 	 		next_state =idle;
			end
	
		wwait: 
		    begin
 	 	 	penable = 1'b0;
			haddr_temp = haddr;
			hwrite_temp = hwrite;
			if(valid == 1'b0)
				next_state = write;
				else if(valid == 1'b1)
				    next_state = write_p;

      		end

		write : 
		   begin
			psel = 1'b1;
			paddr = haddr_temp;
			pwdata = hwdata;
			pwrite = 1'b1;
			penable = 1'b0;
			hready = 1'b0;

			if(valid == 1'b0)
				next_state = wenable;
				else if(valid == 1'b1)
					next_state = wenable_p;
		end

		write_p :
			begin
			psel = 1'b1;
			paddr = haddr_temp;
			pwdata = hwdata;
			pwrite = 1'b1;
			penable = 1'b0;
			hready = 1'b0;
		
			hwrite_temp = hwrite;
	
			next_state = wenable_p;

		end

 	    wenable :
		begin
		     penable = 1'b1;
		     hready = 1'b1;
		     if(valid == 1'b1 && hwrite == 1'b0)
			next_state = read;
			else if(valid == 1'b1 && hwrite == 1'b1)
			  next_state = wwait;
			  else if(valid == 1'b0)
				next_state = idle;
		end


	 wenable_p :
		begin
		     penable = 1'b1;
		     hready = 1'b1;
		     if(valid == 1'b0 && hwrite == 1'b0)
			next_state = write;
			else if(valid == 1'b1 && hwrite == 1'b1)
			  next_state = write_p;
			  else if(hwrite == 1'b0)
				next_state = read;
		end
		endcase

	end
endmodule

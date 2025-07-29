class bike;
  virtual function bike_brand();
    $display("Bike_Brand");
  endfunction
  
  virtual task features();
    $display("Model & Engin_capacity");
  endtask
endclass

class royal_enfiled extends bike;
  function bike_brand();
    $display("Brand-->Royal Enfield");
  endfunction
  
  task features();
    $display("Model = Bullet 350 /n Engine_ca[acity = 349cc");
  endtask
endclass

class yamaha extends bike;
  function bike_brand();
    $display("Brand-->Yamaha");
  endfunction
  
  task features();
    $display("Model = FZ Version 3 /n Engine_ca[acity = 149cc");
  endtask
endclass

class scooter extends yamaha;
  function bike_brand();
    $display("Brand-->Yamaha (scooter)");
  endfunction
  
  task features();
    $display("Model = facino 125 Fi /n Engine_ca[acity = 125cc");
  endtask
endclass

module class_example;
  bike bikes;
  royal_enfiled r1;
  yamaha y1;
  scooter s1;
  
  initial begin
    r1 = new();
    y1 = new();
    s1 = new();
    bikes = r1;
    bikes.bike_brand();
    bikes = y1;
    bikes.bike_brand();
    y1 = s1;
    y1.features();
  end
endmodule

    
    

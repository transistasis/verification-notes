`include "uvm_macros.svh"
import uvm_pkg::*;

class object_class extends uvm_object;
  `uvm_object_utils( object_class )

  function new( string inst = "object_class" );
    super.new( inst );
  endfunction : new

endclass : object_class

class component_class extends uvm_component;
  `uvm_component_utils( component_class )

  function new( string inst = "component_class", uvm_component parent = null );
    super.new( inst, parent );
  endfunction : new

endclass : component_class

module testbench;

  object_class object;
  component_class component;

  initial begin
    object = new( "my_object" );
    `uvm_info( "TB_TOP", "A custom UVM object has been created", UVM_NONE );

    component = new( "my_component", null );
    `uvm_info( "TB_TOP", "A custom UVM component has been created", UVM_NONE );

  end

endmodule : testbench

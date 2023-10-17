# UVM Config DB

There are two methods available with a _UVM_CONFIG_DB_:

  1. `get`
  2. `set`

## Set

The `set` method of _UVM_CONFIG_DB_ is typically used at the top level of the testbench environment.

There are 4 arguments required, as seen in the following snippet:

  1. Context
  2. Instance name
  3. Key
  4. Value

### UVM Config DB Set and Get Example

#### Synthesizable Source

```sv
module adder (
  input  logic [3:0] a, b,
  output logic [4:0] c );

  assign c = a + b;

endmodule : adder

interface adder_if;

  logic [3:0] a;
  logic [3:0] b;
  logic [3:0] c;

endinterface : adder_if
```

#### Simulation Source

```sv
`include "uvm_macros.svh"
import uvm_pkg::*;

class drv extends uvm_driver;
  `uvm_component_utils( drv )

  virtual adder_if aif;
  
  function new( string inst = "drv", uvm_component parent = null );
    super.new( inst, parent );
  endfunction : new

  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );

    if ( !uvm_config_db #(virtual adder_if)::get(this, "", "aif", aif) )
      `uvm_error( "drv", "Unable to access virtual adder interface" )
  
  endfunction : build_phase

endclass : drv

module tb;

  adder_if aif();

  initial begin : uvm_test_block
    uvm_config_db #(virtual adder_if)::set(null, "uvm_test_top", "aif", aif);

    run_test("drv");

  end : uvm_test_block

  adder adder_i (
    .a ( aif.a ),
    .b ( aif.b ),
    .c ( aif.c ) );

endmodule : tb
```

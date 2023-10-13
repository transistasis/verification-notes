# UVM Object

## Extending uvm_object

```sv
class object_class extends uvm_object;
  `uvm_object_utils( object_class )

  function new( string inst = "object_class" );
    super.new( inst );
  endfunction : new

endclass : object_class
```

Note that macros do not require a semicolon at the end of them. Also, note that this code will not compile if a default argument value is not supplied to the constructor. 

## Method Implementations

A UVM object will automatically provide access to a number of _core methods_ that make verification easier:

  1. Print
  2. Deep copy
  3. Compare
  4. Clone
  5. Pack
  6. Unpack
  7. Record
  8. Create

There are two different ways to implement core methods for a UVM object:

  1. In-built implementation using field macros
  2. Do hooks

### In-built Implementation With Field Macros

When using field macros, it is not necessary to register the class with the factor, meaning that the `uvm_object_utils()` macro isn't needed, since it will be supplanted by `uvm_object_utils_begin()` and `uvm_object_utils_end()`.

```sv
class transaction extends uvm_sequence_item;

  rand bit [3:0] data;

  function new( string inst = "transaction" );
    super.new( inst );
  endfunction : new

  `uvm_object_utils_begin( transaction )
  `uvm_field_int( data, UVM_DEFAULT | UVM_DEC )
  `uvm_object_utils_end()

endclass : transaction

module tb;

  transaction t;

  initial begin
    t = new( "t" );
    t.randomize()

    // Can use uvm_default_line_printer or uvm_default_table_printer instead
    t.print( uvm_default_tree_printer );

endmodule : tb
```

In the above code, the `uvm_field_int()` macro will make all core methods available to operate on the data member, `data`. As a result, the `print()` method can be used for this field only.

### Do Hook Implementation

```sv
class transaction extends uvm_sequence_item;
  `uvm_object_utils( transaction )

  rand bit [3:0] data;

  function new( string inst = "transaction" );
    super.new( inst );
  endfunction : new

  virtual function void do_print( uvm_printer printer );
    super.do_print( printer );
    printer.print_field( "data", data, $bits(data), UVM_DEC );
  endfunction : do_print

endclass : transaction

module tb;

  transaction t;

  initial begin
    t = new("t");
    t.randomize();

    // Do hooks do not require a 'do_' prefix before method names
    t.print( uvm_default_line_printer );
  end

endmodule : tb
```

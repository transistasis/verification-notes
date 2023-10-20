# UVM Sequence

A _UVM Sequence_ will operate in tandem with a _UVM Driver_ in order to generate stimuli to send to the DUT. It is extended from the `uvm_object` class, like the `uvm_sequence_item` class.

When defining a sequence class, it will take a parameter that is the type of the data that should be sent to the DUT.

## UVM Sequence Definition

When defining a `uvm_sequence` class, note that there is a virtual task called `body` that must be overridden.

Within the `body` task, there are numerous housekeeping tasks that must be performed in order to send test data to the `driver`, which will in turn be sent to the DUT:

  1. Create a `transaction` object
  2. Randomize the `transaction` object
  3. Send the generated `transaction` object to the `driver`

### UVM Sequence Code

There are 2 main ways to implement a UVM sequence:

  1. Use the `uvm_do` macro
  2. Perform the steps manually

#### Using the uvm_do Macro

This is a simpler method to stand up a quick testbench, but is less flexible than the alternative method. It prevents the user from having any control over the transaction object after randomization is performed.

```sv
class sequence extends uvm_sequence #( transaction );
  `uvm_object_utils( sequence )

  transaction t;

  function new( string inst = "sequence" );
    super.new( inst );
  endfunction : new

  virtual task body();
    repeat (5) begin
      `uvm_do( trans )
    end
  endtask : body

endclass : sequence
```

#### Manual Sequencing Approach

This method removes the `uvm_do` macro and performs the necessary steps manually. This item utilizes the `start_item()` and `finish()` item functions instead. Randomization can be performed between these calls.

```sv
class sequence extends uvm_sequence #( transaction );
  `uvm_object_utils (sequence)

  transaction t;

  function new( string inst = "sequence" );
    super.new( inst );
  endfunction : new

  virtual task body();
    repeat (4) begin
      t == transaction::type_id::create( "t" );
      start_item( t );
      assert( t.randomize() );
      finish_item( t );
    end
  endtask : body

endclass : sequence
```

### UVM Driver Code

Note that rather than using `phase.raise_objection()` and `phase.drop_objection()` in the `run_phase` task, the `driver` now uses a `forever` loop. The `get_next_item()` method listens for a new transaction, while the `item_done()` method signals to the `sequencer` that the provided provided `sequence` has been processed.

```sv
class driver extends uvm_driver #( transaction );
  `uvm_component_utils( driver )

  transaction t;

  function new( string inst = "driver", uvm_component parent = null );
    super.new( inst, parent );
  endfunction : new

  virtual task run_phase( uvm_phase phase );
    t = transaction::type_id::create( "t" );

    forever begin 
      seq_item_port.get_next_item( t );
      `uvm_info( "driver", $sformatf( "a = %d\tb = %d", t.a, t.b), UVM_NONE )
      seq_item_port.item_done();
    end
  endtask : run_phase
endclass : driver
```

### UVM Agent Code

The _UVM Agent_ will usually serve as a container that creates and manages `driver`, `sequencer`, and `monitor` objects. In this example, a `monitor` is not used.

This is a typical UVM class implementation, with the most important part being in the `connect_phase` function, where the `d.seq_item_port` is connected to `s.seq_item_export`, allowing these objects to communicate with one another.

```sv
class agent extends uvm_agent;
  `uvm_component_utils( agent )

  driver d;
  uvm_sequencer #( transaction ) s;

  function new( string inst = "agent", uvm_component parent = null );
    super.new( inst, parent );
  endfunction : new

  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    d = driver::type_id::create( "d", this );
    s = sequencer #(transaction)::type_id::create( "s", this );
  endfunction : build_phase

  virtual function void connect_phase( uvm_phase phase );
    super.connect_phase( phase );
    d.seq_item_port.connect( s.seq_item_export );
  endfunction : connect_phase

endclass : agent
```

### UVM Environment Code

The `environment` class is pretty typical, with only `agent` and `sequence` objects declared and created.

Note that `phase.raise_objection` and `phase.drop_objection` are used in the `run_phase` of this class.

```sv
class environment extends uvm_env;
  `uvm_component_utils( environment )

  agent a;
  sequence s;

  function new( string inst = "environment", uvm_component parent = null );
    super.new( inst, parent );
  endfunction : new

  virtual function build_phase( uvm_phase phase );
    super.build_phase( phase );
    a = agent::type_id::create( "a", this );
    s = sequence::type_id::create( "s", this );
  endfunction : build_phase

  virtual task run_phase( uvm_phase phase );
    phase.raise_objection( this );
    s.start( a.s );
    phase.drop_objection( this );
  endtask : run_phase

endclass : environment
```

### UVM Test

The `test` class is a standard skeleton for extending `uvm_test`.

```sv
class test extends uvm_test;
  `uvm_component_utils( test )

  environment e;

  function new( string inst = "test", uvm_component parent = null );
  endfunction : new

  virtual function build_phase( uvm_phase phase );
    super.build_phase( phase );
    e = environment::type_id::create( "e", this );
  endfunction : build_phase

endclass : test
```

### Top-level Testbench

```sv
module tb;
  initial begin : uvm_test_block

    run_test( "test" );

  end : uvm_test_block

endmodule : tb
```

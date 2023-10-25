# TLM Ports

In a standard object-oriented SystemVerilog testbench, the designer can use _mailbox_ and _semaphore_ objects to send data between classes. The UVM simplifies these communication mechanisms by introducing the _Transaction Level Modeling (TLM) port_.

TLM allows communication between two nodes, one of which is the _port_ (initiator, sender) and another which is the _export_ (reponder, receiver). A port is denoted by a square in diagrams and an export is denoted by a circle.

## TLM Port Classifications

There are two main special types of TLM ports used commonly in UVM testbenches:

| Name              | Type of TLM Port  | Source -> Destination |
|:-----------------:|:-----------------:|:---------------------:|
| SEQ_ITEM_PORT     | Special TLM Port  | Sequencer -> Driver   |
| UVM_ANALYSIS_PORT | Standard TLM Port | Monitor -> Scoreboard |

There are 3 types of operations which can be implemented in TLM when data is passed between an initiator and a responder:

| Operation | Dataflow Direction      |
|:---------:|:-----------------------:|
| Put       | Initiator -> Reponder   |
| Get       | Responder -> Initiator  |
| Transport | Initiator <-> Responder |

These operations are implemented as class, of which there are both _blocking_ and _non-blocking_ variants.

## Using Put Ports

There are numerous steps required to establish a put port between a producer and a consumer.

First, in order to establish a _Blocking Put Port_, `uvm_blocking_put_port` and `uvm_blocking_put_imp` objects must be created in the producer and consumer, respectively. Both of these require a parameter that is the datatype that will be passed between them. The `uvm_blocking_put_imp` object requires a second argument, which is the type of class that the `put` implementation is located in. This will usually just be the name of the consumer class.

Second, each of the above objects need to be created in the constructors of the producer and consumer classes. Note that in this case, the `new` keyword is used, rather than the standard UVM constructor invocation.

Third, data put be passed through the put port. The producer will transfer data by using the `put()` method that is contained within the `uvm_blocking_put_port` object created above. The consumer will be able to receive data by overriding the `put` task in its class body. This task will take the type being transferred as an argument. This will be the same as the first parameter used when creating the `uvm_blocking_put_imp` object.

Finally, the `uvm_blocking_put_port` and `uvm_blocking_put_imp` objects must be connected in the `environment` that creates and manages the `consumer` and `receiver` objects.

### Put Port Transaction Class

```sv
class transaction extends uvm_sequence_item;

  rand bit [3:0] a;
  rand bit [3:0] b;

  function new( string inst = "transaction" );
    super.new( inst );
  endfunction : new

  `uvm_object_utils_begin( transaction )
    `uvm_field_int( a )
    `uvm_field_int( b )
  `uvm_object_utils_end

endclass : transaction
```

### Put Port Producer Class

```sv
class producer extends uvm_component;
  `uvm_component_utils( producer )

  transaction t;
  uvm_blocking_put_port #(transaction) send;

  function new( string inst = "producer", uvm_component parent = null );
    super.new( inst, parent );
  endfunction : new

  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    t = transaction::type_id::create( "t" );
    send = new( "send", this );
  endfunction : build_phase

  virtual task run_phase( uvm_phase phase );
    phase.raise_objection( this );
    send.put( t );
    phase.drop_objection( this );
  endtask : run_phase

endclass : producer
```

### Put Port Receiver Class

```sv
class receiver extends uvm_component;
  `uvm_component_utils( receiver )

  uvm_blocking_put_imp #(transaction, receiver) receive;

  function new( string inst = "receiver", uvm_component parent = null );
    super.new( inst, parent );
  endfunction : new

  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    receive = new( "receive", this );
  endfunction : build_phase

  virtual task put( transaction t );
    t.print( uvm_default_table_printer );
  endtask : put

endclass : receiver
```

### Put Port Environment Class

```sv
class environment extends uvm_env;
  `uvm_component_utils( environment)

  producer p;
  consumer c;

  function new( string inst = "environment", uvm_component parent = null);
  endfunction : new

  virtual function connect_phase( uvm_phase phase );
    super.connect_phase( phase );
    p.send.connect( c.receive );
  endfunction : connect_phase

endclass : environment
```

### Put Port Top-level Testbench

```sv
module tb;

  initial begin : uvm_test_block
    run_test( "environment" );
  end : uvm_test_block

endmodule : tb
```

## Using Get Ports

Establishing a get port between a producer and consumer is very similar to establishing a put port. In this case, the consumer will send data back to the producer instead. There are multiple steps to achieve this, which will be explained for a _Blocking Get Port_.

First, `uvm_blocking_get_port` and `uvm_blocking_get_imp` objects must be declared in the `producer` and `consumer` classes, respectively. This is the same process that was followed for the put port above. The parameter arguments will be the same as well.

Second, the `uvm_blocking_get_port` and `uvm_blocking_get_imp` objects must be created using the `new` keyword, as above. This is be performed in the overridden UVM `build_phase` functions in the `producer` and `consumer` classes.

Third, the `producer` will listen for data in the overridden `run_phase` task (in this example) by using the `get()` method contained within its `uvm_blocking_get_port` object. The `consumer` will override the `get` task with an `output` which is the type used as a parameter when declaring the `uvm_blocking_get_imp` object in this class. Data can be transferred by using a blocking assignment to this `get` task output signal.

Finally, the `uvm_blocking_get_port` and `uvm_blocking_get_imp` objects will be connected within the `environment` class in the same exact way as above.

### Get Port Producer Class

```sv
class producer extends uvm_component;
  `uvm_component_utils( producer )
  
  int data = 33;
  
  uvm_blocking_get_port #(int) receive;
  
  function new( string inst = "producer", uvm_component parent = null );
    super.new( inst, parent );
  endfunction : new
  
  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    receive = new( "receive", this );
  endfunction : build_phase
    
  virtual task main_phase( uvm_phase phase );
    phase.raise_objection( this );
    receive.get( data );
    `uvm_info( "producer", $sformatf("Data received: %d", data), UVM_NONE )
    phase.drop_objection( this );
  endtask : main_phase
  
endclass : producer
```

### Get Port Consumer Class

```sv
class consumer extends uvm_component;
  `uvm_component_utils( consumer )
  
  int data = 13;
  
  uvm_blocking_get_imp #(int, consumer) send;
  
  function new( string inst = "consumer", uvm_component parent = null );
    super.new( inst, parent );
  endfunction : new
  
  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    send = new( "send", this );
  endfunction : build_phase
  
  virtual task get( output int data_o );
    `uvm_info( "consumer", $sformatf("Data sent: %d", data), UVM_NONE )
    data_o = data;
  endtask: get
  
endclass : consumer
```

### Get Port Environment Class

```sv
class environment extends uvm_env;
  `uvm_component_utils( environment )
  
  producer p;
  consumer c;
  
  function new( string inst = "environment", uvm_component parent = null );
    super.new( inst, parent );
  endfunction : new
  
  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    p = producer::type_id::create( "p", this );
    c = consumer::type_id::create( "c", this );
  endfunction : build_phase
  
  virtual function void connect_phase( uvm_phase phase );
    super.connect_phase( phase );
    p.receive.connect( c.send );
  endfunction : connect_phase

  virtual function void end_of_elaboration_phase( uvm_phase phase );
    super.end_of_elaboration_phase( phase );
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase
  
endclass : environment
```

### Get Port Top-level Testbench

```sv
module tb;
  
  initial begin : uvm_test_block
    run_test( "environment" );
  end : uvm_test_block
  
endmodule : tb
```

## Sequencer-Driver Communication

TODO: Add Details

## UVM Subscriber Interaction

TODO: Add Details about `uvm_subscriber`

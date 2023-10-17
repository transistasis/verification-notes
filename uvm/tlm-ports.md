# TLM Ports

In a standard object-oriented SystemVerilog testbench, the designer can use _mailbox_ and _semaphore_ objects to send data between classes. The UVM simplifies these communication mechanisms by introducing the _Transaction Level Modeling (TLM) port_.

TLM allows communication between two nodes, one of which is the _port_ (initiator, sender) and another which is the _export_ (reponder, receiver). A port is denoted by a square in diagrama and an export is denoted by a circle.

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

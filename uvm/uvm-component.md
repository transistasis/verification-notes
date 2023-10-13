# UVM Component

## Extending uvm_component

```sv
class component_class extends uvm_component;
  `uvm_component_utils(component_class)

  function new( string inst = "component_class", uvm_component parent = null );
    super.new( inst, null );
  endfunction : new
  
endclass : component_class

```

# UVM Component

A _UVM Component_ is a static element of a UVM testbench, such as a _uvm_driver_, _uvm_monitor_, _uvm_test_, or _uvm_scoreboard_.

A _uvm_component_ is technically extended from the _uvm_object_ class, but adds additional functionality, such as _UVM_TREE_, _UVM Phases_, and the ability to raise and drop _objections_.

## Extending uvm_component

```sv
class component_class extends uvm_component;
  `uvm_component_utils(component_class)

  function new( string inst = "component_class", uvm_component parent = null );
    super.new( inst, null );
  endfunction : new

endclass : component_class
```

## UVM Phases

The UVM partitions the simulation process into separate temporal phases in order to manage complex testbench scenarios.

| Region          | Time Consumed | Number of Phases | Function or Task | Example Use          |
|:---------------:|:-------------:|:----------------:|:----------------:|:--------------------:|
| Pre-Simulation  | 0ns           | 4                | Function         | Creating objects     |
| Simulation      | > 0 ns        | 12               | Task             | Driving stimulus     |
| Post-Simulation | 0ns           | 4                | Function         | Calculating coverage |

### Pre-Simulation Phases

The 4 phases that occur before simulation are as follows:

  1. `build`
  2. `connect`
  3. `end_of_elaboration`
  4. `start_of_simulation`

### Simulation Phases

The 12 simulation phases are as follows:

  1. `pre_reset`
  2. `reset`
  3. `post_reset`
  4. `pre_configure`
  5. `configure`
  6. `post_configure`
  7. `pre_main`
  8. `main`
  9. `post_main`
  10. `pre_shutdown`
  11. `shutdown`
  12. `post_shutdown`

### Post-Simulation Phases

The 4 phases that occur after simulation are as follows:

  1. `extract`
  2. `check`
  3. `report`
  4. `final`

## UVM Tree

TODO: UPDATE SECTION

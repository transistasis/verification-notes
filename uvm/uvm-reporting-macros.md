# UVM Reporting Macros

This document contains information pertaining to UVM reporting macros.

## Reporting Macros

The UVM is capable of reporting different classes of messages to the console. Commercial simulators will normally color code these messages, making them easier to see.

This can be more useful than standard `$display()` messages, which are shown only in black.

```sv
`uvm_info( "TB_TOP", "Message to report", UVM_LOW )
`uvm_warning( "TB_TOP", "Warning message" )
`uvm_error( "TB_TOP", "Error message" )
`uvm_fatal( "TB_TOP", "Fatal warning message" )
```

The `ID` and `MESSAGE` parameters can be anything.

Note that semicolons are not needed when calling these macros. In addition, note that the only reporting macro that takes a `UVM_VERBOSITY` level as an argument.

### Severity Levels

There are multiple standard severity levels, defined in the `uvm_severity` enumeration:

| Enumeration | Description                                                                              |
|-------------|------------------------------------------------------------------------------------------|
| UVM_INFO    | Will display if the verbosity level is less than or equal to the default threshold value |
| UVM_WARNING | Will not be filtered out                                                                 |
| UVM_ERROR   | Number of error instances will be stored in `UVM_COUNT`                                  |
| UVM_FATAL   | Will call `UVM_EXIT`, which will call `$finish()`                                        |

### Verbosity Levels

There are multiple verbosity levels, defined in the `uvm_verbosity` enumeration:

| Enumeration | Value |
|-------------|-------|
| UVM_NONE    | 0     |
| UVM_LOW     | 100   |
| UVM_MEDIUM  | 200   |
| UVM_HIGH    | 300   |
| UVM_FULL    | 400   |
| UVM_DEBUG   | 500   |

Any message that is less than or equal to the default verbosity level will be reported. Anything that is higher will be filtered out.

Note that the default verbosity level is `UVM_MEDIUM`.

### Reporting Variable Values

There are 3 ways to report variable values:

  1. Use the `$sformatf()` system function
  2. Use UVM core methods
  3. Use UVM do hooks

#### 1. Using '$sformatf()`

```sv
logic [3:0] a = 4'hA;

`uvm_info( "TB_MROW", $sformatf("The value of a is : %0h", a), UVM_NONE )
```

#### 2. Using UVM Core Methods

UPDATE

#### 3. Using UVM Do Hooks

UPDATE

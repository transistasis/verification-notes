# Simulator Setup

This page describes setup procedures and scripts to perform various simulation tasks.

## Riviera Pro

### Code Coverage

Enabling code coverage in Riviera Pro 2022.04 can be done by using the following script:

#### Full Command Line Example

```tcl
vlib work && vlog '-timescale' '1ns/1ns' '-dbg' design.sv testbench.sv  && vsim -c -do run.do
```

#### Compile Options

```tcl
-timescale 1ns/1ns -dbg
```

#### Run Options

```tcl
+access+r
```

#### Example run.do

```tcl
# Report format can be "html" or "txt"
set REPORT_FORMAT "txt"

vsim +access+r -acdb -acdb_cov sbce -acdb_file mem_cov.acdb;
run -all;

acdb save;
acdb report -db mem_cov.acdb -$REPORT_FORMAT -o mem_cov.$REPORT_FORMAT -verbose

if { $REPORT_FORMAT == "txt" } {
  exec cat mem_cov.txt
}

exit
```

### Functional Coverage

TODO: REVISIT THIS SECTION

In order to enable functional coverage in Riviera Pro, the following `run.do` file can be used:

```riviera
vsim +access+r;
run -all;
acdb save;
acdb report -db  fcover.acdb -txt -o cov.txt -verbose  
exec cat cov.txt;
exit
```

### Enabling the Waves Database

The collection of waves can be enabled in the top-level testbench environment by adding the following code snippet:

```sv
  initial begin : vcd_capture
    $dumpfile( "dump.vcd" );
    $dumpvars;
  end : vcd_capture
```

Note that _.vcd_ is short for _Value Change Dump_.

# Simulator Setup

This page describes setup procedures and scripts to perform various simulation tasks.

## Riviera Pro

In order to enable functional coverage in Riviera Pro, the following `run.do` file can be used:

```riviera
vsim +access+r;
run -all;
acdb save;
acdb report -db  fcover.acdb -txt -o cov.txt -verbose  
exec cat cov.txt;
exit
```

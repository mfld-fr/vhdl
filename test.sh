#!/bin/sh

. ./env.sh

ghdl_mcode -a test-cpu.vhd
ghdl_mcode -e test-cpu
ghdl_mcode -r test_cpu --stop-time=1000ms --vcd=test.vcd

gtkwave test.vcd

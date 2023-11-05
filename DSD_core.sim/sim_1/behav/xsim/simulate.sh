#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2023.1 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Mon Nov 06 00:38:57 EET 2023
# SW Build 3865809 on Sun May  7 15:04:56 MDT 2023
#
# IP Build 3864474 on Sun May  7 20:36:21 MDT 2023
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# simulate design
echo "xsim reg_module_tb_behav -key {Behavioral:sim_1:Functional:reg_module_tb} -tclbatch reg_module_tb.tcl -log simulate.log"
xsim reg_module_tb_behav -key {Behavioral:sim_1:Functional:reg_module_tb} -tclbatch reg_module_tb.tcl -log simulate.log

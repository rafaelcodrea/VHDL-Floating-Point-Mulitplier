--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
--Date        : Thu Jan 19 19:01:26 2023
--Host        : DESKTOP-674A7QM running 64-bit major release  (build 9200)
--Command     : generate_target schema_bloc_wrapper.bd
--Design      : schema_bloc_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity schema_bloc_wrapper is
end schema_bloc_wrapper;

architecture STRUCTURE of schema_bloc_wrapper is
  component schema_bloc is
  end component schema_bloc;
begin
schema_bloc_i: component schema_bloc
 ;
end STRUCTURE;

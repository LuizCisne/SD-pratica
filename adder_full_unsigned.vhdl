LIBRARY ieee;
 USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

 ENTITY adder_full_unsigned IS
 GENERIC (
 N : INTEGER := 8);
 PORT (
 add1 : IN unsigned(N - 1 DOWNTO 0);
 add2 : IN unsigned(N - 1 DOWNTO 0);
 sum : OUT unsigned(N DOWNTO 0));
 END adder_full_unsigned;

 ARCHITECTURE rtl OF adder_full_unsigned IS
 BEGIN
 sum <= resize(add1, N + 1) + resize(add2, N + 1);
 END rtl;

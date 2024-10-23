LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY registrador IS
    GENERIC (N : INTEGER := 8); -- Número de bits do registrador
    PORT (
        clk : IN STD_LOGIC; -- Relógio
        D : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0); -- Dados de entrada
        Q : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0) -- Dados de saída
    );
END registrador;

ARCHITECTURE comportamento OF registrador IS
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            Q <= D;
        END IF;
    END PROCESS;
END comportamento;

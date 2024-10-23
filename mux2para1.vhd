LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux2para1 IS
    GENERIC (N : INTEGER := 8); -- Número de bits
    PORT (
        sel : IN STD_LOGIC; -- Sinal de seleção
        a, b : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0); -- Entradas do multiplexador
        y : OUT STD_LOGIC_VECTOR (N - 1 DOWNTO 0)    -- Saída do multiplexador
    );
END mux2para1;

ARCHITECTURE comportamento OF mux2para1 IS
BEGIN
    WITH sel SELECT
        y <= a WHEN '0',
             b WHEN OTHERS;
END comportamento;

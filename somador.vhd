LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;  -- Para permitir a soma de vetores de bits

ENTITY somador IS
    GENERIC (N : INTEGER := 8); -- Número de bits
    PORT (
        a, b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0); -- Entradas
        sum : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)  -- Saída (soma)
    );
END somador;

ARCHITECTURE comportamento OF somador IS
BEGIN
    sum <= a + b;
END comportamento;

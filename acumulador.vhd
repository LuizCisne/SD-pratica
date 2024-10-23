LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY acumulador IS
    GENERIC (N : INTEGER := 8); -- Número de bits
    PORT (
        clk : IN STD_LOGIC;
        sel : IN STD_LOGIC;
        a, b : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        q_out : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
    );
END acumulador;

ARCHITECTURE estrutura OF acumulador IS
    SIGNAL somador_out, mux_out, reg_out : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
BEGIN
    -- Instância do somador
    somador_inst : ENTITY work.somador
        GENERIC MAP (N => N)
        PORT MAP (
            a => a,
            b => b,
            sum => somador_out
        );

    -- Instância do multiplexador
    mux_inst : ENTITY work.mux2para1
        GENERIC MAP (N => N)
        PORT MAP (
            sel => sel,
            a => somador_out,
            b => reg_out,
            y => mux_out
        );

    -- Instância do registrador
    reg_inst : ENTITY work.registrador
        GENERIC MAP (N => N)
        PORT MAP (
            clk => clk,
            D => mux_out,
            Q => reg_out
        );

    -- Saída final
    q_out <= reg_out;

END estrutura;
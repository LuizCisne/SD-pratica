LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sad_top IS
    GENERIC (
        N : INTEGER := 8;   -- Número de bits por entrada
        P : INTEGER := 4    -- Número de pares de entradas
    );
    PORT (
        clk : IN std_logic;
        pA, pB : IN std_logic_vector(P*N-1 DOWNTO 0);  -- Vetores concatenados de entradas
        abs_out : OUT std_logic_vector(P*(N-1) DOWNTO 0)  -- Vetor de saídas com os valores absolutos
    );
END ENTITY;

ARCHITECTURE rtl OF sad_top IS

    -- Sinal para armazenar as diferenças
    SIGNAL diff : std_logic_vector(P*N-1 DOWNTO 0);

BEGIN

    -- Processo de geração de pares de subtração e instância do componente absolute
    gen_abs_diff : FOR i IN 0 TO P-1 GENERATE

        -- Subtração: pA[i] - pB[i]
        diff_proc : PROCESS (pA, pB)
        BEGIN
            diff((i+1)*N-1 DOWNTO i*N) <= std_logic_vector(signed(pA((i+1)*N-1 DOWNTO i*N)) - signed(pB((i+1)*N-1 DOWNTO i*N)));
        END PROCESS;
        
        -- Instância do componente absolute
        abs_inst : ENTITY work.absolute
            GENERIC MAP(N => N)
            PORT MAP (
                a => diff((i+1)*N-1 DOWNTO i*N),        -- Entrada da diferença
                s => abs_out((i+1)*(N-1)-1 DOWNTO i*(N-1))  -- Saída do valor absoluto
            );

    END GENERATE gen_abs_diff;

END ARCHITECTURE;

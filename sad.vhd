LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY sad IS
    GENERIC (
        B : POSITIVE := 8;  -- Número de bits por amostra
        N : POSITIVE := 64; -- Número de amostras por bloco
        P : POSITIVE := 4   -- Número de amostras lidas em paralelo
    );
    PORT (
        clk : IN std_logic;  -- Relógio
        enable : IN std_logic; -- Habilita o cálculo
        reset : IN std_logic;  -- Reset
        sample_ori : IN std_logic_vector(P*B-1 DOWNTO 0);  -- Amostras originais
        sample_can : IN std_logic_vector(P*B-1 DOWNTO 0);  -- Amostras candidatas
        read_mem : OUT std_logic;  -- Sinal para leitura de memória
        address : OUT std_logic_vector(integer(ceil(log2(real(N))))-1 DOWNTO 0);  -- Endereço da memória
        sad_value : OUT std_logic_vector(B+integer(ceil(log2(real(P))))-1 DOWNTO 0);  -- Valor final do SAD
        done: OUT std_logic  -- Sinaliza o término da operação
    );
END ENTITY sad;

ARCHITECTURE arch OF sad IS

    -- Função log2
    FUNCTION log2 (val : INTEGER) RETURN INTEGER IS
        VARIABLE result : INTEGER := 0;
        VARIABLE v : INTEGER := val;
    BEGIN
        WHILE v > 1 LOOP
            v := v / 2;
            result := result + 1;
        END LOOP;
        RETURN result;
    END FUNCTION;

    -- Definindo larguras de sinais
    CONSTANT address_width : INTEGER := integer(ceil(log2(real(N))));
    CONSTANT sad_width : INTEGER := B + integer(ceil(log2(real(P))));

    -- Sinais internos
    SIGNAL abs_out : std_logic_vector(P*B-1 DOWNTO 0);  -- Ajustado para P*B bits
    SIGNAL soma_out : std_logic_vector(sad_width-1 DOWNTO 0); -- Saída da árvore de soma
    SIGNAL csoma : std_logic_vector(sad_width-1 DOWNTO 0);  -- Saída final do acumulador
    SIGNAL done_signal : std_logic := '0'; -- Sinal de operação concluída
    SIGNAL addr_counter : unsigned(address_width-1 DOWNTO 0) := (OTHERS => '0');  -- Contador para endereços

BEGIN

    -- Gerador de endereços
    address_gen : PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            addr_counter <= (OTHERS => '0');
            read_mem <= '0';
            done_signal <= '0';
        ELSIF rising_edge(clk) THEN
            IF enable = '1' THEN
                read_mem <= '1';
                IF addr_counter = N-1 THEN
                    addr_counter <= (OTHERS => '0');
                    done_signal <= '1';
                ELSE
                    addr_counter <= addr_counter + 1;
                    done_signal <= '0';
                END IF;
            ELSE
                read_mem <= '0';
                done_signal <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Atribuição do endereço
    address <= std_logic_vector(addr_counter);

    -- Instância do componente SAD_TOP
    sad_inst : ENTITY work.sad_top
        GENERIC MAP (
            N => B,
            P => P
        )
        PORT MAP (
            clk => clk,
            pA => sample_ori,
            pB => sample_can,
            abs_out => abs_out
        );

    -- Instância da árvore de soma
    adder_tree_inst : ENTITY work.adderTree
        GENERIC MAP (
            N => B,  -- Número de bits por valor absoluto
            P => P   -- Número de valores a serem somados
        )
        PORT MAP (
            inputs => abs_out, 
            sum_out => soma_out 
        );

    -- Instância do acumulador
    acumulador_inst : ENTITY work.acumulador
        GENERIC MAP (
            N => sad_width
        )
        PORT MAP (
            clk => clk,
            sel => '1',  
            a => soma_out, 
            b => soma_out,  
            q_out => csoma  
        );

    -- Conectando a saída final
    sad_value <= csoma;
    done <= done_signal;

END ARCHITECTURE arch;

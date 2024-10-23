LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY sad IS
    GENERIC (
        B : POSITIVE := 8;  -- Number of bits per sample
        N : POSITIVE := 64; -- Number of samples per block
        P : POSITIVE := 4   -- Number of samples read in parallel
    );
    PORT (
        clk : IN std_logic;  -- Clock
        enable : IN std_logic; -- Enables calculation
        reset : IN std_logic;  -- Reset signal
        sample_ori : IN std_logic_vector(P*B-1 DOWNTO 0);  -- Original samples (P samples of B bits)
        sample_can : IN std_logic_vector(P*B-1 DOWNTO 0);  -- Candidate samples (P samples of B bits)
        read_mem : OUT std_logic;  -- Signal for memory read
        address : OUT std_logic_vector(integer(log2(real(N)))-1 DOWNTO 0);  -- Memory address
        sad_value : OUT std_logic_vector(B+integer(log2(real(P)))-1 DOWNTO 0);  -- Final SAD value
        done: OUT std_logic  -- Indicates operation completion
    );
END ENTITY sad;

ARCHITECTURE arch OF sad IS

    -- Function to calculate log2 of integers
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

    -- Internal signals
    SIGNAL abs_out : std_logic_vector(P*(B-1) DOWNTO 0) := (OTHERS => '0');  -- Outputs of absolute values
    SIGNAL soma_out : std_logic_vector(B+log2(P)-1 DOWNTO 0) := (OTHERS => '0'); -- Output from the summation tree
    SIGNAL csoma : std_logic_vector(B+log2(P)-1 DOWNTO 0) := (OTHERS => '0');  -- Final accumulator output
    SIGNAL done_signal : std_logic := '0'; -- Completion signal
    SIGNAL addr_counter : unsigned(log2(N)-1 DOWNTO 0) := (OTHERS => '0');  -- Address counter

BEGIN

    -- Address generator process
    address_gen : PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            addr_counter <= (OTHERS => '0');
            read_mem <= '0';
            done_signal <= '0';  -- Reset done signal
        ELSIF rising_edge(clk) THEN
            IF enable = '1' THEN
                read_mem <= '1';
                IF addr_counter = N-1 THEN
                    addr_counter <= (OTHERS => '0');
                    done_signal <= '1';  -- Operation complete
                ELSE
                    addr_counter <= addr_counter + 1;
                    done_signal <= '0';
                END IF;
            ELSE
                read_mem <= '0';
                done_signal <= '0';  -- Disable done signal
            END IF;
        END IF;
    END PROCESS;

    -- Address output assignment
    address <= std_logic_vector(addr_counter);

    -- Instance of the absolute difference calculation module
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

    -- Instance of the summation tree
    adder_tree_inst : ENTITY work.adderTree
        GENERIC MAP (
            N => B-1,  -- Input width (B-1 bits due to abs_out)
            P => P     -- Number of values to sum
        )
        PORT MAP (
            inputs => abs_out,  -- Connected to absolute outputs
            sum_out => soma_out -- Output from the summation tree
        );

    -- Instance of the accumulator for iterative summation
    acumulador_inst : ENTITY work.acumulador
        GENERIC MAP (
            N => B+log2(P) -- Considering bit increase during summation
        )
        PORT MAP (
            clk => clk,
            sel => '1',  -- Select accumulator mode
            a => soma_out,  -- Input from summation tree
            b => soma_out,  -- For simplicity, summing the same value
            q_out => csoma  -- Final output from the accumulator
        );

    -- Final output assignment
    sad_value <= csoma;
    done <= done_signal;

END ARCHITECTURE arch;

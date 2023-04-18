--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:20:55 04/17/2023
-- Design Name:   
-- Module Name:   U:/ece3561/Project3/test.vhd
-- Project Name:  Project3
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: elevator
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY test IS
END test;
 
ARCHITECTURE behavior OF test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component controller
    port(
        UP_REQ : in  STD_LOGIC_VECTOR(2 downto 0);
        DN_REQ : in  STD_LOGIC_VECTOR(3 downto 1);
        GO_REQ : in  STD_LOGIC_VECTOR(3 downto 0);
        POC : in  STD_LOGIC;
        SYSCLK : in  STD_LOGIC;
        FLOOR_IND : out  STD_LOGIC_VECTOR(3 downto 0);
        EMVUP : out  STD_LOGIC;
        EMVDN : out  STD_LOGIC;
        EOPEN : out  STD_LOGIC;
        ECLOSE : out  STD_LOGIC;
        ECOMP : in  STD_LOGIC;
        EF : in  STD_LOGIC_VECTOR(3 downto 0));
    end component;
    
    component simulator
    port(
        POC : in  STD_LOGIC;
        SYSCLK : in  STD_LOGIC;
        EMVUP : in  STD_LOGIC;
        EMVDN : in  STD_LOGIC;
        EOPEN : in  STD_LOGIC;
        ECLOSE : in  STD_LOGIC;
        ECOMP : buffer STD_LOGIC;
        EF : out  STD_LOGIC_VECTOR(3 downto 0));
    end component;

    -- Controller Inputs
    signal UP_REQ : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal DN_REQ : STD_LOGIC_VECTOR(3 downto 1) := (others => '0');
    signal GO_REQ : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal POC : STD_LOGIC := '1';
    signal SYSCLK : STD_LOGIC := '0';
    signal ECOMP : STD_LOGIC := '0';
    signal EF : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    -- Controller Outputs
    signal FLOOR_IND : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal EMVUP : STD_LOGIC := '0';
    signal EMVDN : STD_LOGIC := '0';
    signal EOPEN : STD_LOGIC := '0';
    signal ECLOSE : STD_LOGIC := '0';

    -- Clock period definitions
    constant SYSCLK_period : time := 500 ms;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
    con: controller port map(
        UP_REQ => UP_REQ,
        DN_REQ => DN_REQ,
        GO_REQ => GO_REQ,
        POC => POC,
        SYSCLK => SYSCLK,
        FLOOR_IND => FLOOR_IND,
        EMVUP => EMVUP,
        EMVDN => EMVDN,
        EOPEN => EOPEN,
        ECLOSE => ECLOSE,
        ECOMP => ECOMP,
        EF => EF );
        
    sim: simulator port map(
        POC => POC,
        SYSCLK => SYSCLK,
        EMVUP => EMVUP,
        EMVDN => EMVDN,
        EOPEN => EOPEN,
        ECLOSE => ECLOSE,
        ECOMP => ECOMP,
        EF => EF );
    

    -- Clock process definitions
    SYSCLK_process: process
    begin
        SYSCLK <= '0';
        wait for SYSCLK_period/2;
        SYSCLK <= '1';
        wait for SYSCLK_period/2;
    end process;
    
    
    -- Stimulus process
stim_proc: process
begin

    wait for SYSCLK_period;
    POC <= '0';

    wait for SYSCLK_period;

    -- Test 1: Simple Up Request
    UP_REQ(2) <= '1';
    wait for 1000 ms;
    assert (EMVUP = '1' and EMVDN = '0') report "Test 1 failed: Simple Up Request" severity ERROR;

    -- Test 2: Simple Down Request
    UP_REQ(2) <= '0';
    DN_REQ(3) <= '1';
    wait for 1000 ms;
    assert (EMVUP = '0' and EMVDN = '1') report "Test 2 failed: Simple Down Request" severity ERROR;

    -- Test 3: Go request while moving up
    UP_REQ(0) <= '1';
    GO_REQ(1) <= '1';
    wait for 1000 ms;
    assert (EMVUP = '1' and EOPEN = '0' and ECLOSE = '0') report "Test 3 failed: Go request while moving up" severity ERROR;

    -- Test 4: Go request while moving down
    UP_REQ(0) <= '0';
    DN_REQ(3) <= '1';
    GO_REQ(2) <= '1';
    wait for 1000 ms;
    assert (EMVDN = '1' and EOPEN = '0' and ECLOSE = '0') report "Test 4 failed: Go request while moving down" severity ERROR;

    -- Test 5: Door open and close sequence
    DN_REQ(3) <= '0';
    GO_REQ(0) <= '1';
    wait for 1000 ms;
    assert (EOPEN = '1' and ECLOSE = '0') report "Test 5 failed: Door open sequence" severity ERROR;
    
    wait for 1000 ms;
    assert (EOPEN = '0' and ECLOSE = '1') report "Test 5 failed: Door close sequence" severity ERROR;

    -- Test 6: Concurrent Up and Down requests
    UP_REQ(1) <= '1';
    DN_REQ(2) <= '1';
    wait for 1000 ms;
    assert (EMVUP = '1' and EMVDN = '0') report "Test 6 failed: Concurrent Up and Down requests" severity ERROR;

    -- Test 7: Concurrent Go requests
    UP_REQ(1) <= '0';
    DN_REQ(2) <= '0';
    GO_REQ(1) <= '1';
    GO_REQ(3) <= '1';
    wait for 1000 ms;
    assert (EOPEN = '1' and ECLOSE = '0') report "Test 7 failed: Concurrent Go requests" severity ERROR;

    wait;
end process;

END;

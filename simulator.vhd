----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:10:14 04/14/2023 
-- Design Name: 
-- Module Name:    simulator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity simulator is
	Port ( POC : in STD_LOGIC;
	SYSCLK : in STD_LOGIC;
	EMVUP : in STD_LOGIC;
	EMVDN : in STD_LOGIC;
	EOPEN : in STD_LOGIC;
	ECLOSE : in STD_LOGIC;
	ECOMP : buffer STD_LOGIC;
	EF : out STD_LOGIC_VECTOR (3 downto 0));
end simulator;

entity elevator_simulator is
    Port ( POC : in  STD_LOGIC;
           SYSCLK : in  STD_LOGIC;
           EMVUP : in  STD_LOGIC;
           EMVDN : in  STD_LOGIC;
           EOPEN : in  STD_LOGIC;
           ECLOSE : in  STD_LOGIC;
           ECOMP : buffer  STD_LOGIC;
           EF : out  STD_LOGIC_VECTOR (3 downto 0));
end elevator_simulator;

architecture Behavioral of elevator_simulator is
	 signal ELEVATOR_DOOR : STD_LOGIC;
    signal ELEVATOR_INPUT : STD_LOGIC;
    signal FLOOR_NUM : UNSIGNED(3 downto 0);
    signal OPERATION_COUNTER : UNSIGNED(2 downto 0);
architecture Behavioral of simulator is
	signal EDOOR, EINPUT : STD_LOGIC;
	signal EFLOOR : UNSIGNED(3 downto 0);
	signal COUNT : UNSIGNED(2 downto 0); -- Count is just a delay

begin
	EDOOR <= EOPEN or ECLOSE;
	EINPUT <= EMVUP or EMVDN or EDOOR;
	EF <= STD_LOGIC_VECTOR(EFLOOR);

-- Process starts on the rising edge of the SYSCLK
process (SYSCLK)
begin
-- Assign signals for elevator door operation, elevator input commands, and the current floor output
	 ELEVATOR_DOOR <= EOPEN or ECLOSE;
    ELEVATOR_INPUT <= EMVUP or EMVDN or ELEVATOR_DOOR;
    CURRENT_FLOOR <= STD_LOGIC_VECTOR(FLOOR_NUM);
    if rising_edge(SYSCLK) then
        -- Power on clear case
        if POC='1' then
            EFLOOR <= "0001"; -- Set EFLOOR to the 1st floor
            ECOMP <= '1'; -- Set ECOMP to '1'
        -- If ECOMP is '0'
        elsif ECOMP='0' then
            -- If COUNT reaches "000", set ECOMP to '1'
            if COUNT="000" then
                ECOMP <= '1';
            -- Otherwise, decrement COUNT
            else
                COUNT <= COUNT - 1;
            end if;
        -- If EINPUT is '1'
        elsif EINPUT='1' then
            ECOMP <= '0'; -- Set ECOMP to '0'
            -- If EDOOR is '1'
            if EDOOR='1' then
                COUNT <= "101"; -- Set COUNT to 5
            -- If EDOOR is '0'
            else
                COUNT <= "011"; -- Set COUNT to 3
                -- If EMVUP is '1' and not on the top floor, move up
                if EMVUP='1' and EFLOOR(3)='0' then
                    EFLOOR <= EFLOOR sll 1;
                -- If EMVDN is '1' and not on the bottom floor, move down
                elsif EMVDN='1' and EFLOOR(0)='0' then
                    EFLOOR <= EFLOOR srl 1;
                end if;
            end if;
        end if;
    end if;
end process;
end Behavioral;


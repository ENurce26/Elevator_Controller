----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:10:14 04/14/2023 
-- Design Name: 
-- Module Name:    elevator_simulator - Behavioral 
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


begin
-- Assign signals for elevator door operation, elevator input commands, and the current floor output
	 ELEVATOR_DOOR <= EOPEN or ECLOSE;
    ELEVATOR_INPUT <= EMVUP or EMVDN or ELEVATOR_DOOR;
    CURRENT_FLOOR <= STD_LOGIC_VECTOR(FLOOR_NUM);
end Behavioral;


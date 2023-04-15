----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:06:20 04/14/2023 
-- Design Name: 
-- Module Name:    controller - Behavioral 
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

entity controller is
    Port ( UP_REQ : in  STD_LOGIC_VECTOR(2 downto 0);
           DN_REQ : in  STD_LOGIC_VECTOR(3 downto 1);
           GO_REQ : in  STD_LOGIC_VECTOR(3 downto 0);
           POC : in  STD_LOGIC;
           SYSCLK : in  STD_LOGIC;
           FLOOR_IND : out  STD_LOGIC_VECTOR(3 downto 0);
           EMVUP : out  STD_LOGIC;
           EMVDN : out  STD_LOGIC;
           EOPEN : out  STD_LOGIC;
           ECLOSE : out  STD_LOGIC;
           ECOMP : out  STD_LOGIC;
           EF : in  STD_LOGIC_VECTOR(3 downto 0));
end controller;

architecture Behavioral of controller is
    type StateType is (IDLE, OPEN_DOOR, CLOSE_DOOR, MOVE_UP, MOVE_DOWN);
    signal state : StateType;
    signal EF_DOOR, AB_REQ, BL_REQ : STD_LOGIC;

begin
    FLOOR_IND <= EF; --current floor

    process (SYSCLK)
    begin
        if SYSCLK'event and SYSCLK = '1' then
            --add cases for each state

        end if;
    end process;



end Behavioral;


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

entity controller is
    Port ( UP_REQ : in  STD_LOGIC_VECTOR (2 downto 0);
           DN_REQ : in  STD_LOGIC_VECTOR (3 downto 1);
           GO_REQ : in  STD_LOGIC_VECTOR (3 downto 0);
           POC : in  STD_LOGIC;
           SYSCLK : in  STD_LOGIC;
           FLOOR_IND : out  STD_LOGIC_VECTOR (3 downto 0);
           EMVUP : out  STD_LOGIC;
           EMVDN : out  STD_LOGIC;
           EOPEN : out  STD_LOGIC;
           ECLOSE : out  STD_LOGIC;
           ECOMP : in  STD_LOGIC;
           EF : in  STD_LOGIC_VECTOR (3 downto 0));
end controller;

architecture Behavioral of controller is
    type elevator_state is (IDLE, MOVE_UP, MOVE_DOWN);
    signal state : elevator_state := IDLE;
    signal direction : STD_LOGIC; -- '0' for UP, '1' for DOWN
    signal pending_UP : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal pending_DOWN : STD_LOGIC_VECTOR(3 downto 1) := (others => '0');
    signal pending_GO : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal current_floor : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal temp_dn_req : STD_LOGIC_VECTOR(3 downto 1);

begin
    process (SYSCLK)
    begin
        if rising_edge(SYSCLK) then
				EMVUP <= '0';
				EMVDN <= '0';
				EOPEN <= '0';
				ECLOSE <= '0';
            if POC = '1' then
                -- Reset pending requests
                pending_UP <= (others => '0');
                pending_DOWN <= (others => '0');
                pending_GO <= (others => '0');
                current_floor <= EF;
                state <= IDLE;		               
            else
                -- Update pending requests
                pending_UP <= pending_UP or UP_REQ;
                pending_DOWN <= pending_DOWN or DN_REQ;
                pending_GO <= pending_GO or GO_REQ;

                temp_dn_req <= DN_REQ(3 downto 2) & '0'; -- 0th floor request is not valid for down

                case state is
                    when IDLE =>
                        if pending_UP /= "000" or pending_DOWN /= "000" or pending_GO /= "0000" then
                            if unsigned(EF) > unsigned(temp_dn_req) then
                                direction <= '0';
                                state <= MOVE_UP;
										 
                            else
                                direction <= '1';
                                state <= MOVE_DOWN;
                            end if;
                        end if;

                    when MOVE_UP =>
                        if direction = '0' then
                            EMVUP <= '1';
                            EMVDN <= '0';
                        else
                            EMVUP <= '0';
                            EMVDN <= '1';
                        end if;

                        if ECOMP = '1' and EF = current_floor then
                            if pending_UP(to_integer(unsigned(EF))) = '1' or
                               pending_DOWN(to_integer(unsigned(EF))) = '1' or
                               pending_GO(to_integer(unsigned(EF))) = '1' then
                                EOPEN <= '1';
                                ECLOSE <= '0';
                                pending_UP(to_integer(unsigned(EF))) <= '0';
                                pending_DOWN(to_integer(unsigned(EF))) <= '0';
                                pending_GO(to_integer(unsigned(EF))) <= '0';
                            else
                                EOPEN <= '0';
                                ECLOSE <= '1';
                            end if;
                        elsif ECOMP = '0' then
                            EOPEN <= '0';
                            ECLOSE <= '1';
                            current_floor <= EF;
                            if direction = '0' then
                                if pending_UP = "000" and pending_GO = "0000" then
                                    direction <= '1';
                                end if;
                            else
                                if pending_DOWN = "000" and pending_GO = "0000" then
                                    direction <= '0';
                                end if;
                            end if;
                            if pending_UP = "000" and pending_DOWN = "000" and pending_GO = "0000" then
                                state <= IDLE;
                            end if;
                        end if;

                    when MOVE_DOWN =>
                        if direction = '0' then
                            EMVUP <= '1';
                            EMVDN <= '0';
                        else
                            EMVUP <= '0';
                            EMVDN <= '1';
                        end if;

                        if ECOMP = '1' and EF = current_floor then
                            if pending_UP(to_integer(unsigned(EF))) = '1' or
                               pending_DOWN(to_integer(unsigned(EF))) = '1' or
                               pending_GO(to_integer(unsigned(EF))) = '1' then
                                EOPEN <= '1';
                                ECLOSE <= '0';
                                pending_UP(to_integer(unsigned(EF))) <= '0';
                                pending_DOWN(to_integer(unsigned(EF))) <= '0';
                                pending_GO(to_integer(unsigned(EF))) <= '0';
                            else
                                EOPEN <= '0';
                                ECLOSE <= '1';
                            end if;
                        elsif ECOMP = '0' then
                            EOPEN <= '0';
                            ECLOSE <= '1';
                            current_floor <= EF;
                            if direction = '1' then
                                if pending_DOWN = "000" and pending_GO = "0000" then
                                    direction <= '0';
                                end if;
                            else
                                if pending_UP = "000" and pending_GO = "0000" then
                                    direction <= '1';
                                end if;
                            end if;
                            if pending_UP = "000" and pending_DOWN = "000" and pending_GO = "0000" then
                                state <= IDLE;
                            end if;
                        end if;

                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    FLOOR_IND <= EF;

end Behavioral;

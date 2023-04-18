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
    -- Internal signals
    signal AB_MASK : UNSIGNED(3 downto 0); -- bitmask for floors above current
    signal BL_MASK : UNSIGNED(3 downto 0); -- bitmask for floors below current
    signal ALL_REQ : STD_LOGIC_VECTOR(3 downto 0); -- stores whether or not there is a
                                           -- request for each floor
    signal AB_REQ : STD_LOGIC; -- request above current floor
    signal BL_REQ : STD_LOGIC; -- request below current floor
    
    signal EF_UP_REQ : STD_LOGIC; -- up request at current floor
    signal EF_DN_REQ : STD_LOGIC; -- down request at current floor
    signal EF_GO_REQ : STD_LOGIC; -- go request at current floor
    
    signal EF_DOOR : STD_LOGIC; -- door needs to be opened at current floor
    
    signal QUP : STD_LOGIC; -- elevator travelling up
    signal QDOWN : STD_LOGIC; -- elevator travelling down
    
begin
    -- Process internal signals
    BL_MASK <= unsigned(EF) - 1;
    AB_MASK <= not(BL_MASK) sll 1;
    ALL_REQ <= ('0' & UP_REQ) or (DN_REQ & '0') or GO_REQ;
    AB_REQ <= '1' when (UNSIGNED(ALL_REQ) and AB_MASK) > 0 else '0';
    BL_REQ <= '1' when (UNSIGNED(ALL_REQ) and BL_MASK) > 0 else '0';
    
    EF_UP_REQ <= '1' when UNSIGNED(EF and ('0' & UP_REQ)) > 0 else '0';
    EF_DN_REQ <= '1' when UNSIGNED(EF and (DN_REQ & '0')) > 0 else '0';
    EF_GO_REQ <= '1' when UNSIGNED(EF and GO_REQ) > 0 else '0';
    
    EF_DOOR <= EF_GO_REQ or (EF_UP_REQ and not(QDOWN)) or (EF_DN_REQ and not(QUP));
    
    -- Output
    FLOOR_IND <= EF; -- indicates the floor in which the elevator is located
    
    -- Handle active clock edge
    process (SYSCLK)
    begin
        if rising_edge(SYSCLK) then
        
            -- Clear outputs
            EMVUP <= '0';
            EMVDN <= '0';
            EOPEN <= '0';
            ECLOSE <= '0';
            
            -- Power-on clear (clear elevator state)
            if POC='1' then
                QUP <= '0';
                QDOWN <= '0';
                
            -- Elevator has no running operations
            elsif ECOMP='1' then

                if EF_DOOR='1' then
                    EOPEN <= '1';
                    ECLOSE <= '0';
                else
                    EOPEN <= '0';
                    ECLOSE <= '1';

                    if AB_REQ='1' and QDOWN='0' then
                        EMVUP <= '1';
                        QUP <= '1';
                        QDOWN <= '0';

                    elsif BL_REQ='1' and QUP='0' then
                        EMVDN <= '1';
                        QDOWN <= '1';
                        QUP <= '0';

                    else
                        EMVUP <= '0';
                        EMVDN <= '0';
                        QUP <= '0';
                        QDOWN <= '0';
                    end if;
                end if;

            else
                EMVUP <= '0';
                EMVDN <= '0';
                EOPEN <= '0';
                ECLOSE <= '0';
            end if;
        end if;
    end process;
end Behavioral;


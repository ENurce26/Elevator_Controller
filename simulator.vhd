----------------------------------------------------------------------------------
-- Company: 
-- Engineer: ----------------------------------------------------------------------------------
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

ENTITY simulator IS
    PORT (
        POC : IN STD_LOGIC;
        SYSCLK : IN STD_LOGIC;
        EMVUP : IN STD_LOGIC;
        EMVDN : IN STD_LOGIC;
        EOPEN : IN STD_LOGIC;
        ECLOSE : IN STD_LOGIC;
        ECOMP : BUFFER STD_LOGIC;
        EF : OUT STD_LOGIC_VECTOR (3 downto 0)
    );
END simulator;

ARCHITECTURE behavioral OF simulator IS
    TYPE elevator_state IS (INIT, IDLE, MOVE_UP, MOVE_DOWN, DOOR_OPEN, DOOR_CLOSE);
    SIGNAL current_state : elevator_state;
    SIGNAL next_state : elevator_state;
    SIGNAL EFLOOR : UNSIGNED(3 downto 0);

BEGIN
    PROCESS (SYSCLK, POC)
    BEGIN
        IF (POC = '1') THEN
            current_state <= INIT;
        ELSIF rising_edge(SYSCLK) THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    PROCESS (current_state, EMVUP, EMVDN, EOPEN, ECLOSE)
    BEGIN
        CASE current_state IS
            WHEN INIT =>
                EFLOOR <= "0001";
                ECOMP <= '1';
                next_state <= IDLE;

            WHEN IDLE =>
                IF EMVUP = '1' THEN
						  ECOMP <= '0';
                    next_state <= MOVE_UP;
                ELSIF EMVDN = '1' THEN
						  ECOMP <= '0';
                    next_state <= MOVE_DOWN;
                ELSIF EOPEN = '1' THEN
						  ECOMP <= '0';
                    next_state <= DOOR_OPEN;
                ELSE
						  ECOMP <= '1';
                    next_state <= IDLE;
                END IF;

            WHEN MOVE_UP =>
                IF ECOMP = '1' THEN
                    next_state <= IDLE;
                ELSE
                    EFLOOR <= EFLOOR sll 1;
                    ECOMP <= '0';
                    next_state <= MOVE_UP;
                END IF;

            WHEN MOVE_DOWN =>
                IF ECOMP = '1' THEN
                    next_state <= IDLE;
                ELSE
                    EFLOOR <= EFLOOR srl 1;
                    ECOMP <= '0';
                    next_state <= MOVE_DOWN;
                END IF;

            WHEN DOOR_OPEN =>
                IF ECOMP = '1' THEN
                    next_state <= DOOR_CLOSE;
                ELSE
                    ECOMP <= '0';
                    next_state <= DOOR_OPEN;
                END IF;

            WHEN DOOR_CLOSE =>
                IF ECOMP = '1' THEN
                    next_state <= IDLE;
                ELSE
                    ECOMP <= '0';
                    next_state <= DOOR_CLOSE;
                END IF;

            WHEN OTHERS =>
                next_state <= IDLE;
        END CASE;
    END PROCESS;

    EF <= STD_LOGIC_VECTOR(EFLOOR);

END behavioral;

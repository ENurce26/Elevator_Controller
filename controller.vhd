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
    signal AB_MASK, BL_MASK : UNSIGNED(3 downto 0);
    signal ALL_REQ : STD_LOGIC_VECTOR(3 downto 0);
    signal AB_REQ, BL_REQ : STD_LOGIC;
    signal EF_UP_REQ, EF_DN_REQ, EF_GO_REQ : STD_LOGIC;
    signal EF_DOOR : STD_LOGIC;
    signal QOPEN, QUP, QDOWN : STD_LOGIC;
begin
   -- Internal signals
   -- This process block is sensitive to changes in the EF signal.
-- EF is the current floor of the elevator represented as a 4-bit STD_LOGIC_VECTOR.
process (EF) is
begin
    -- Compute the BL_MASK by converting EF to unsigned and subtracting 1.
    -- BL_MASK is used to filter requests for floors below the current floor.
    BL_MASK <= unsigned(EF) - 1;
    
    -- Compute the AB_MASK by bitwise negating BL_MASK and shifting left by 1 bit.
    -- AB_MASK is used to filter requests for floors above the current floor.
    AB_MASK <= not(BL_MASK) sll 1;
end process;

-- This process block is sensitive to changes in the UP_REQ, DN_REQ, and GO_REQ signals.
-- UP_REQ, DN_REQ, and GO_REQ are the elevator request signals for moving up, down, and going directly to a floor, respectively.
process (UP_REQ, DN_REQ, GO_REQ) is
begin
    -- Compute the ALL_REQ signal by concatenating '0' with UP_REQ, bitwise OR-ing it with DN_REQ concatenated with '0', and
    -- bitwise OR-ing the result with GO_REQ.
    -- ALL_REQ is used to represent all the floor requests in a single STD_LOGIC_VECTOR.
    ALL_REQ <= ('0' & UP_REQ) or (DN_REQ & '0') or GO_REQ;
end process;

-- This process block is sensitive to changes in the ALL_REQ, AB_MASK, and BL_MASK signals.
-- ALL_REQ represents all the floor requests, AB_MASK is the mask for above-floor requests, and BL_MASK is the mask for below-floor requests.
process (ALL_REQ, AB_MASK, BL_MASK) is
begin
    -- Compute the AB_REQ signal, which represents if there are any above-floor requests.
    -- It is set to '1' if the bitwise AND between UNSIGNED(ALL_REQ) and AB_MASK is greater than 0; otherwise, it is set to '0'.
    AB_REQ <= '1' when (UNSIGNED(ALL_REQ) and AB_MASK) > 0 else '0';

    -- Compute the BL_REQ signal, which represents if there are any below-floor requests.
    -- It is set to '1' if the bitwise AND between UNSIGNED(ALL_REQ) and BL_MASK is greater than 0; otherwise, it is set to '0'.
    BL_REQ <= '1' when (UNSIGNED(ALL_REQ) and BL_MASK) > 0 else '0';
end process;

-- EF is the current floor, UP_REQ represents up floor requests, DN_REQ represents down floor requests, and GO_REQ represents floor-specific requests.
process (EF, UP_REQ, DN_REQ, GO_REQ) is
begin
    -- Compute the EF_UP_REQ signal, which represents if there are any up requests on the current floor.
    -- It is set to '1' if the bitwise AND between UNSIGNED(EF) and the shifted UP_REQ is greater than 0; otherwise, it is set to '0'.
    EF_UP_REQ <= '1' when UNSIGNED(EF and ('0' & UP_REQ)) > 0 else '0';

    -- Compute the EF_DN_REQ signal, which represents if there are any down requests on the current floor.
    -- It is set to '1' if the bitwise AND between UNSIGNED(EF) and the shifted DN_REQ is greater than 0; otherwise, it is set to '0'.
    EF_DN_REQ <= '1' when UNSIGNED(EF and (DN_REQ & '0')) > 0 else '0';

    -- Compute the EF_GO_REQ signal, which represents if there are any floor-specific requests on the current floor.
    -- It is set to '1' if the bitwise AND between UNSIGNED(EF) and GO_REQ is greater than 0; otherwise, it is set to '0'.
    EF_GO_REQ <= '1' when UNSIGNED(EF and GO_REQ) > 0 else '0';
end process;

-- QDOWN indicates if the elevator is moving down, and QUP indicates if the elevator is moving up.
process (EF_UP_REQ, EF_DN_REQ, EF_GO_REQ, QDOWN, QUP) is
begin
    -- Compute the EF_DOOR signal, which represents if the elevator doors should be opened.
    -- The doors should be opened if any of the following conditions are met:
    -- 1. There is a floor-specific request (EF_GO_REQ = '1')
    -- 2. There is an up request on the current floor and the elevator is not moving down (EF_UP_REQ = '1' and QDOWN = '0')
    -- 3. There is a down request on the current floor and the elevator is not moving up (EF_DN_REQ = '1' and QUP = '0')
    EF_DOOR <= EF_GO_REQ or (EF_UP_REQ and not(QDOWN)) or (EF_DN_REQ and not(QUP));
end process;

-- This process block handles the active clock edge, SYSCLK.
process (SYSCLK) begin
    -- When there's an event (change) in the SYSCLK signal and it is equal to '1'.
    if SYSCLK'event and SYSCLK = '1' then
        -- Initialize output signals to '0'.
        EMVUP <= '0';
        EMVDN <= '0';
        EOPEN <= '0';
        ECLOSE <= '0';

        -- If POC is '1', reset internal signals.
        if POC = '1' then
            QOPEN <= '0';
            QUP <= '0';
            QDOWN <= '0';
        -- If ECOMP is '1', the elevator is at a valid floor.
        elsif ECOMP = '1' then
            -- If the doors are currently open (QOPEN = '1').
            if QOPEN = '1' then
                -- If EF_DOOR is '0', close the doors.
                if EF_DOOR = '0' then
                    ECLOSE <= '1';
                    QOPEN <= '0';
                end if;
            else
                -- Evaluate the elevator actions.
                if EF_DOOR = '1' then
                    EOPEN <= '1';      -- Open the doors.
                    QOPEN <= '1';
                elsif AB_REQ = '1' and QDOWN = '0' then
                    EMVUP <= '1';      -- Move the elevator up.
                    QUP <= '1';
                elsif BL_REQ = '1' and QUP = '0' then
                    EMVDN <= '1';      -- Move the elevator down.
                    QDOWN <= '1';
                else
                    QUP <= '0';        -- Reset QUP and QDOWN if no action is taken.
                    QDOWN <= '0';
                end if;
            end if;
        end if;
    end if;
end process;

end Behavioral;

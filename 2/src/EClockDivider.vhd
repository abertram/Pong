------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 2: EVGASignal
-- Entity: EClockDivider
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Teilt den Systemtakt in einem Verhaletnis 1:Divisor.
------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EClockDivider is
	generic (
		Divisor: positive
	);
	port (
		Clock,
		Reset: in std_logic;
		DividedClock: out std_logic
	);
end entity EClockDivider;

architecture AClockDivider of EClockDivider is
	-- interner Zaehler
	signal
		ClockCounter: unsigned(Divisor - 2 downto 0);
begin
	ClockCountProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			ClockCounter <= (others => '0');
		elsif rising_edge(Clock) then
			-- hoch zaehlen
			ClockCounter <= ClockCounter + 1;
		end if;
	end process ClockCountProcess;
	-- Ausgangssignal erzeugen
	DividedClock <= ClockCounter(Divisor - 2);
end architecture AClockDivider;
------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: EDelayCounter
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Zaehlt Systemtakte. Erreicht der Zaehler eine per Generic festgelegte
-- Grenze, so wird der Zaehler resettet und ein Ausgangssignal fuer einen Takt
-- auf '1' gesetzt.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EDelayCounter is
	generic (
		-- Zaehlgrenze
		Limit: TDelayPeriods
	);
	port (
		Clock,
		Reset,
		Enable: in std_logic;
		LimitReached: out std_logic
	);
end entity EDelayCounter;

architecture ADelayCounter of EDelayCounter is
	signal
		Counter: TDelayPeriods;
begin
	-- Zaehlprozess
	CountProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			Counter <= 0;
		elsif rising_edge(Clock) then
			-- Zaehlgrenze erreicht
			if (Reset = '0') and (Counter = Limit - 1) then
				Counter <= 0;
			-- hochzaehlen
			elsif Enable = '1' then
				Counter <= Counter + 1;
			end if;
		end if;
	end process CountProcess;

	-- Ausgangssignal setzen
	LimitReached <=
		'1' when (Reset = '0') and (Counter = Limit - 1) else
		'0';
end architecture ADelayCounter;
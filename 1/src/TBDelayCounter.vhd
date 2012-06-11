------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: TBDelayCounter
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Testbench fuer den Zaehler.
--
-- Simulationszeit: 400 ns
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use work.Types.all;

entity TBDelayCounter is
end entity TBDelayCounter;

architecture ATBDelayCounter of TBDelayCounter is
	signal
		SClock,
		SReset,
		SEnable,
		SLimitReached: std_logic;

	constant
		ClockPeriod: time := 20 ns;

	-- Zaehler
	component EDelayCounter is
		generic (
			Limit: TDelayPeriods
		);
		port (
			Clock,
			Reset,
			Enable: in std_logic;
			LimitReached: out std_logic
		);
	end component EDelayCounter;
begin
	-- Zaehler
	DelayCounter: EDelayCounter
		generic map (
			-- Zaehlgrenze
			10
		)
		port map (
			SClock,
			SReset,
			SEnable,
			SLimitReached
		);

	-- Systemtakt
	ClockProcess: process
	begin
		SClock <= '1';
		wait for ClockPeriod / 2;
		SClock <= '0';
		wait for ClockPeriod / 2;
	end process ClockProcess;

	-- Simulation
	SimulationProcess: process
	begin
		-- Reset
		SReset <= '1';
		SEnable <= '0';
		wait for ClockPeriod;

		-- Reset aus
		SReset <= '0';
		wait for ClockPeriod;

		-- Zaehler ein, zu Ende zaehlen
		SEnable <= '1';
		wait for 15 * ClockPeriod;

		-- Zaehler aus
		SEnable <= '0';
		wait for ClockPeriod;

		-- Zahler ein
		SEnable <= '1';
		wait for ClockPeriod;
		-- und gleich wieder aus, nicht zu Ende zaehlen lassen
		SEnable <= '0';
		wait for 9 * ClockPeriod;

		wait;
	end process SimulationProcess;
end;
------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: TBDebouncer
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Testbench fuer den Entpreller. Es wird ein Rechtecksignal mit einer
-- niedrigeren Frequenz als der Systemtakt erzeugt.
--
-- Simulationszeit: 1 us
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use work.Types.all;

entity TBDebouncer is
end entity TBDebouncer;

architecture ATBDebouncer of TBDebouncer is
	signal
		SClock,
		SReset,
		SInput,
		SOutput: std_logic;

	constant
		ClockPeriod: time := 20 ns;
	constant
		InputPeriod: time := 102 ns;

	-- Entpreller
	component EDebouncer is
		generic (
			-- Wartezeit
			DelayPeriods: TDelayPeriods
		);
		port (
			Clock,
			Reset,
			Input: in std_logic;
			Output: out std_logic
		);
	end component EDebouncer;
begin
	-- Entpreller
	Debouncer: EDebouncer
		generic map (
			-- Wartezeit
			5
		)
		port map (
			SClock,
			SReset,
			SInput,
			SOutput
		);

	-- Systemtaktsimulation
	ClockProcess: process
	begin
		SClock <= '1';
		wait for ClockPeriod / 2;
		SClock <= '0';
		wait for ClockPeriod / 2;
	end process ClockProcess;

	-- Simulation des zu entprellenden Signals
	InputProcess: process
	begin
		SInput <= '1';
		wait for InputPeriod / 2;
		SInput <= '0';
		wait for InputPeriod / 2;
	end process InputProcess;

	-- Simulationsprozess
	SimulationProcess: process
	begin
		-- Reset
		SReset <= '1';
		wait for ClockPeriod;

		-- Reset aus
		SReset <= '0';
		wait for 100 * ClockPeriod;

		wait;
	end process SimulationProcess;
end architecture ATBDebouncer;
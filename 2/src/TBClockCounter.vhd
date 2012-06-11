------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: TBClockCounter
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

entity TBClockCounter is
end entity TBClockCounter;

architecture ATBClockCounter of TBClockCounter is
	signal
		SClock,
		SDividedClock,
		SReset,
		SEnable,
		SLimitReached: std_logic;

	constant
		ClockPeriod: time := 20 ns;

	component EClockDivider is
		generic (
			Divisor: positive
		);
		port (
			Clock,
			Reset: in std_logic;
			DividedClock: out std_logic
		);
	end component EClockDivider;

	-- Zaehler
	component EClockCounter is
		generic (
			CountLimit: TClockPeriods
		);
		port (
			Clock,
			Reset,
			Enable: in std_logic;
			CountLimitReached: out std_logic
		);
	end component EClockCounter;
begin
	ClockDivider: EClockDivider
		generic map (
			2
		)
		port map (
			SClock,
			SReset,
			SDividedClock
		);

	-- Zaehler
	ClockCounter: EClockCounter
		generic map (
			-- Zaehlgrenze
			10
		)
		port map (
			SDividedClock,
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
		wait for 5 * ClockPeriod;

		-- Zaehler ein, zu Ende zaehlen
		SEnable <= '1';
		wait for 11 * ClockPeriod;

		-- Zaehler aus
		SEnable <= '0';
		wait for 5 * ClockPeriod;

		-- Zahler ein
		SEnable <= '1';
		wait for 11 * ClockPeriod;

		-- Zaehler aus
		SEnable <= '0';
		wait for ClockPeriod;

		wait;
	end process SimulationProcess;
end architecture ATBClockCounter;
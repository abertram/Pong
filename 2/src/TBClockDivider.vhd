------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 2: EVGASignal
-- Entity: TBClockDivider
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Testbench für den Frequenzteiler.
-- Simulationszeit: 1µs
------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;

entity TBClockDivider is
end entity TBClockDivider;

architecture AClockDivider of TBClockDivider is
	constant
		ClockPeriod: time := 20 ns;
	constant
		ClockDivisor: positive := 2;

	signal
		SClock,
		SReset: std_logic;
	signal
		SDividedClock: std_logic;

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
begin
	ClockDivider: EClockDivider
		generic map (
			ClockDivisor
		)
		port map (
			SClock,
			SReset,
			SDividedClock
		);

	ClockProcess: process
	begin
		SClock <= '1';
		wait for ClockPeriod / 2;
		SClock <= '0';
		wait for ClockPeriod / 2;
	end process ClockProcess;

	SimulationProcess: process
	begin
		SReset <= '1';
		wait for ClockPeriod;

		SReset <= '0';

		wait;
	end process SimulationProcess;
end architecture AClockDivider;
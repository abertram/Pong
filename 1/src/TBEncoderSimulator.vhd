------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: TBEncoderSimulator
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Testbench fuer den EncoderSimulator.
--
-- Simulationszeit: 10 us
------------------------------------------------------------------------------
library work;
library ieee;

use work.Types.all;
use ieee.std_logic_1164.all;

entity TBEncoderSimulator is

end entity TBEncoderSimulator;

architecture ATBEncoderSimulaltor of TBEncoderSimulator is
	signal
		SClock,
		SReset: std_logic;
	signal
		SRotationDirection: TRotationDirection;
	signal
		SSquareWaveHalfPeriod: natural;
	signal
		SASignal,
		SBSignal: std_logic;

	constant
		ClockPeriod: time := 20 ns;

	-- Encodersimulator
	component EEncoderSimulator is
		port (
			Clock,
			Reset: in std_logic;
			RotationDirection: in TRotationDirection;
			SquareWaveHalfPeriod: in natural;
			ASignal,
			BSignal: out std_logic
		);
	end component EEncoderSimulator;
begin
	-- Encodersimulator
	EncoderSimulator: EEncoderSimulator
		port map (
			SClock,
			SReset,
			SRotationDirection,
			SSquareWaveHalfPeriod,
			SASignal,
			SBSignal
		);

	-- Takt
	ClockProcess: process
	begin
		SClock <= '0';
		wait for ClockPeriod / 2;
		SClock <= '1';
		wait for ClockPeriod / 2;
	end process ClockProcess;

	-- Simulation
	SimulationProcess: process
	begin
		-- Reset
		SReset <= '1';
		SRotationDirection <= NoRotation;
		SSquareWaveHalfPeriod <= 0;
		wait for ClockPeriod;

		-- Reset aus
		SReset <= '0';
		wait for ClockPeriod;

		-- im Uhrzeigersinn drehen
		SRotationDirection <= Clockwise;
		SSquareWaveHalfPeriod <= 5;
		wait for 1 us;

		SSquareWaveHalfPeriod <= 0;
		-- lange genug warten, damit der Simulator seinen aktuellen Schritt beenden kann
		wait for 5 * ClockPeriod;

		-- gegen den Uhrzeigersinn drehen
		SRotationDirection <= CounterClockwise;
		SSquareWaveHalfPeriod <= 10;
		wait for 2 us;

		SSquareWaveHalfPeriod <= 0;
		-- lange genug warten, damit der Simulator seinen aktuellen Schritt beenden kann
		wait for 10 * ClockPeriod;

		-- gegen den Uhrzeigersinn drehen
		SRotationDirection <= CounterClockwise;
		SSquareWaveHalfPeriod <= 15;
		wait for 3 us;

		SSquareWaveHalfPeriod <= 0;
		-- lange genug warten, damit der Simulator seinen aktuellen Schritt beenden kann
		wait for 15 * ClockPeriod;

		-- im Uhrzeigersinn drehen
		SRotationDirection <= Clockwise;
		SSquareWaveHalfPeriod <= 20;
		wait for 4 us;

		wait;
	end process SimulationProcess;
end architecture ATBEncoderSimulaltor;
------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: EEncoderSimulator
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Simuliert einen Drehencoder, indem zwei zu einander phasenverschobene
-- Rechteckimpulse erzeugt werden.
------------------------------------------------------------------------------
library work;
library ieee;

use work.Types.all;
use ieee.std_logic_1164.all;

entity EEncoderSimulator is
	port (
		Clock,
		Reset: in std_logic;
		RotationDirection: in TRotationDirection;
		SquareWaveHalfPeriod: in natural;
		ASignal,
		BSignal: out std_logic
	);
end entity EEncoderSimulator;

architecture AEncoderSimulator of EEncoderSimulator is
	-- Rechteckimpulserzeuger
	component EEncoderSignalGenerator is
		generic (
			GenericRotationDirection: TRotationDirection
		);
		port (
			Clock,
			Reset: in std_logic;
			RotationDirection: TRotationDirection;
			SquareWaveHalfPeriod: in natural;
			OutSignal: out std_logic
		);
	end component EEncoderSignalGenerator;
begin
	-- Rechteckimpulserzeuger fuer Signal A
	ASignalGenerator: EEncoderSignalGenerator
		generic map (
			-- Verzoegerung, wenn gegen Uhrzeigersinn gedreht wird
			CounterClockwise
		)
		port map (
			Clock,
			Reset,
			RotationDirection,
			SquareWaveHalfPeriod,
			ASignal
		);

	-- Rechteckimpulserzeuger fuer Kanal B
	BSignalGenerator: EEncoderSignalGenerator
		generic map (
			-- Verzoegerung, wenn im Uhrzeigersinn gedreht wird
			Clockwise
		)
		port map (
			Clock,
			Reset,
			RotationDirection,
			SquareWaveHalfPeriod,
			BSignal
		);
end architecture AEncoderSimulator;
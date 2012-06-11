------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: TBEncoderInput
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Testbench fuer die Eingabe per Drehencoder. Es wird nur die rechte Anzeige
-- simuliert, da beide Anzeigen bis auf das Pinning gleich sind.
--
-- Hinweis: Die Wartezeiten des Entprellers in der ERotationDirectionDecoder
-- sollten angepasst werden! Empfehlung ist 4. Die empfohlene Simulationszeit
-- geht von diesem Wert aus.
--
-- Simulationszeit: 4010 us
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity TBEncoderInput is

end entity TBEncoderInput;

architecture ATBEncoderInput of TBEncoderInput is
	signal
		SClock,
		SReset,
		SKey0,
		SKey1,
		SKey2,
		SKey3,
		SASignal0,
		SBSignal0,
		SASignal1,
		SBSignal1: std_logic;
	signal
		SSevenSegmentVector0,
		SSevenSegmentVector1,
		SSevenSegmentVector2,
		SSevenSegmentVector3,
		SSevenSegmentVector4,
		SSevenSegmentVector5,
		SSevenSegmentVector6,
		SSevenSegmentVector7: TSevenSegmentVector;
	signal
		SVectorValue0,
		SVectorValue1: TVectorValue;
	signal
		SRotationDirection0,
		SRotationDirection1: TRotationDirection;
	signal
		SSquareWaveHalfPeriod0,
		SSquareWaveHalfPeriod1: natural;
	signal
		SEffectiveDirectionSwitch0,
		SEffectiveDirectionSwitch1: std_logic;

	constant
		ClockPeriod: time := 20 ns;

	-- IOModul
	component EIOModul is
		port (
			Clock,
			Reset,
			Key0,
			Key1,
			Key2,
			Key3,
			ASignal0,
			BSignal0,
			ASignal1,
			BSignal1,
			EffectiveDirectionSwitch0,
			EffectiveDirectionSwitch1: in std_logic;
			SevenSegmentVector0,
			SevenSegmentVector1,
			SevenSegmentVector2,
			SevenSegmentVector3,
			SevenSegmentVector4,
			SevenSegmentVector5,
			SevenSegmentVector6,
			SevenSegmentVector7: out TSevenSegmentVector;
			VectorValue0,
			VectorValue1: out TVectorValue
		);
	end component EIOModul;

	-- Drehencodersimulator
	component EEncoderSimulator is
		port (
			Clock,
			Reset: std_logic;
			RotationDirection: in TRotationDirection;
			SquareWaveHalfPeriod: in natural;
			ASignal,
			BSignal: out std_logic
		);
	end component EEncoderSimulator;

begin
	-- IOModul
	IOModul: EIOModul
		port map (
			SClock,
			SReset,
			SKey0,
			SKey1,
			SKey2,
			SKey3,
			SASignal0,
			SBSignal0,
			SASignal1,
			SBSignal1,
			SEffectiveDirectionSwitch0,
			SEffectiveDirectionSwitch1,
			SSevenSegmentVector0,
			SSevenSegmentVector1,
			SSevenSegmentVector2,
			SSevenSegmentVector3,
			SSevenSegmentVector4,
			SSevenSegmentVector5,
			SSevenSegmentVector6,
			SSevenSegmentVector7,
			SVectorValue0,
			SVectorValue1
		);

	-- Drehencodersimulator fuer die rechte Anzeige
	EncoderSimulator0: EEncoderSimulator
		port map (
			SClock,
			SReset,
			SRotationDirection0,
			SSquareWaveHalfPeriod0,
			-- Signale wie in der Hardware vertauschen
			SBSignal0,
			SASignal0
		);

	-- Drehencodersimulator fuer die linke Anzeige
	EncoderSimulator1: EEncoderSimulator
		port map (
			SClock,
			SReset,
			SRotationDirection1,
			SSquareWaveHalfPeriod1,
			-- Signale wie in der Hardware vertauschen
			SBSignal1,
			SASignal1
		);

	-- Systemtakt
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
		report "Die Wartezeiten in ERotationDirectionDecoder angepasst?";
		report "Die Signale A und B sind wie in der Hardware vertauscht.";

		-- Reset
		SReset <= '1';
		SKey0 <= '1';
		SKey1 <= '1';
		SKey2 <= '1';
		SKey3 <= '1';
		SRotationDirection0 <= NoRotation;
		SSquareWaveHalfPeriod0 <= 0;
		SEffectiveDirectionSwitch0 <= '0';
		SRotationDirection1 <= NoRotation;
		SSquareWaveHalfPeriod1 <= 0;
		SEffectiveDirectionSwitch1 <= '0';
		wait for ClockPeriod;

		-- Reset zu Ende
		SReset <= '0';
		wait for ClockPeriod;

		-- im Uhrzeigersinn drehen
		-- => hoch zaehlen
		SRotationDirection0 <= Clockwise;
		SSquareWaveHalfPeriod0 <= 5;
		wait for 1 us;

		SSquareWaveHalfPeriod0 <= 0;
		-- lange genug warten, damit der Simulator seinen aktuellen Schritt beenden kann
		wait for 5 * ClockPeriod;

		assert(SVectorValue0 = TVectorValue(to_unsigned(10, TVectorValue'length)));

		-- gegen den Uhrzeigersinn drehen
		-- => runter zaehlen
		SRotationDirection0 <= CounterClockwise;
		SSquareWaveHalfPeriod0 <= 10;
		wait for 1 us;

		SSquareWaveHalfPeriod0 <= 0;
		-- lange genug warten, damit der Simulator seinen aktuellen Schritt beenden kann
		wait for 10 * ClockPeriod;

		-- Wirkrichtung umkehren
		SEffectiveDirectionSwitch0 <= '1';

		assert(SVectorValue0 = TVectorValue(to_unsigned(4, TVectorValue'length)));

		-- im Uhrzeigersinn drehen
		-- => runter zaehlen
		SRotationDirection0 <= Clockwise;
		SSquareWaveHalfPeriod0 <= 15;
		wait for 3 us;

		SSquareWaveHalfPeriod0 <= 0;
		-- lange genug warten, damit der Simulator seinen aktuellen Schritt beenden kann
		wait for 15 * ClockPeriod;

		assert(SVectorValue0 = TVectorValue(to_unsigned(0, TVectorValue'length)));

		-- gegen den Uhrzeigersinn drehen
		-- => hoch zaehlen
		SRotationDirection0 <= CounterClockwise;
		SSquareWaveHalfPeriod0 <= 20;
		wait for 4000 us;
		assert(SVectorValue0 = TVectorValue(to_unsigned(9999, TVectorValue'length)));

		wait;
	end process SimulationProcess;
end architecture ATBEncoderInput;
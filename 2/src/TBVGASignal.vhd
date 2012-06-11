------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 2: EVGASignal
-- Entity: TBVGASignal
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Testbench für das gesamte Design. Bindet einen Drehencodersimulator ein und
-- simuliert einige Drehklicks, so dass sich die Balken runter bewegen. Eignet
-- sich sowohl für die funktionale als auch post-synthese Simulation. Enthält
-- keine richtigen Testfälle, da vorausgesetzt wird, dass die einzelnen
-- Komponenten bereits getestet wurden.
-- Simulationszeit: 11ms
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
use work.Types.all;

entity TBVGASignal is
end entity TBVGASignal;

architecture ATBVGASignal of TBVGASignal is
	signal
		SClock, -- Takt
		SReset, -- Reset
		-- Tasten
		SKey0,
		SKey1,
		SKey2,
		SKey3,
		-- Encodersignale
		SASignal0,
		SBSignal0,
		SASignal1,
		SBSignal1,
		-- Wirkrichtungsumchalter
		SEffectiveDirectionSwitch0,
		SEffectiveDirectionSwitch1: std_logic;
	signal
		-- Ansteuerung der 7 Segment Anzeigen
		SSevenSegmentVector0,
		SSevenSegmentVector1,
		SSevenSegmentVector2,
		SSevenSegmentVector3,
		SSevenSegmentVector4,
		SSevenSegmentVector5,
		SSevenSegmentVector6,
		SSevenSegmentVector7: TSevenSegmentVector;
	signal
		SVGARed,
		SVGAGreen,
		SVGABlue: TColor;
	signal
		SVGABlank,
		SVGAClock,
		SVGAHorizontalSync,
		SVGAVerticalSync: std_logic;
	signal
		SRotationDirection0,
		SRotationDirection1: TRotationDirection;
	signal
		SSquareWaveHalfPeriod0,
		SSquareWaveHalfPeriod1: natural;

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

	component EVGASignal is
		port (
			Clock, -- Takt
			Reset, -- Reset
			-- Tasten
			Key0,
			Key1,
			Key2,
			Key3,
			-- Encodersignale
			ASignal0,
			BSignal0,
			ASignal1,
			BSignal1,
			-- Wirkrichtungsumchalter
			EffectiveDirectionSwitch0,
			EffectiveDirectionSwitch1: in std_logic;
			-- Ansteuerung der 7 Segment Anzeigen
			SevenSegmentVector0,
			SevenSegmentVector1,
			SevenSegmentVector2,
			SevenSegmentVector3,
			SevenSegmentVector4,
			SevenSegmentVector5,
			SevenSegmentVector6,
			SevenSegmentVector7: out TSevenSegmentVector;
			VGARed,
			VGAGreen,
			VGABlue: out std_logic_vector (9 downto 0);
			VGABlank,
			VGAClock,
			VGAHorizontalSync,
			VGAVerticalSync: out std_logic
		);
	end component EVGASignal;
begin
	-- Drehencodersimulator fuer den rechten Balken
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

	-- Drehencodersimulator fuer den linken Balken
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

	VGASignal: EVGASignal
		port map (
			SClock, -- Takt
			SReset, -- Reset
			-- Tasten
			SKey0,
			SKey1,
			SKey2,
			SKey3,
			-- Encodersignale
			SASignal0,
			SBSignal0,
			SASignal1,
			SBSignal1,
			-- Wirkrichtungsumchalter
			SEffectiveDirectionSwitch0,
			SEffectiveDirectionSwitch1,
			-- Ansteuerung der 7 Segment Anzeigen
			SSevenSegmentVector0,
			SSevenSegmentVector1,
			SSevenSegmentVector2,
			SSevenSegmentVector3,
			SSevenSegmentVector4,
			SSevenSegmentVector5,
			SSevenSegmentVector6,
			SSevenSegmentVector7,
			SVGARed,
			SVGAGreen,
			SVGABlue,
			SVGABlank,
			SVGAClock,
			SVGAHorizontalSync,
			SVGAVerticalSync
		);

	ClockProcess: process
	begin
		SClock <= '1';
		wait for cClockPeriod / 2;
		SClock <= '0';
		wait for cClockPeriod / 2;
	end process ClockProcess;

	SimulationProcess: process
	begin
		-- Reset ein
		SReset <= '1';
		SKey0 <= '1';
		SKey1 <= '1';
		SKey2 <= '1';
		SKey3 <= '1';
		SEffectiveDirectionSwitch0 <= '0';
		SEffectiveDirectionSwitch1 <= '0';
		wait for cDesignClockPeriod;

		-- Reset aus
		SReset <= '0';
		wait for cDesignClockPeriod;

		-- im Uhrzeigersinn drehen
		-- => hoch zaehlen => Balken runter
		SRotationDirection0 <= Clockwise;
		SRotationDirection1 <= Clockwise;
		SSquareWaveHalfPeriod0 <= 5;
		SSquareWaveHalfPeriod1 <= 10;
		wait for 10 ms;

		SSquareWaveHalfPeriod0 <= 0;
		SSquareWaveHalfPeriod1 <= 0;

		wait;
	end process SimulationProcess;
end architecture ATBVGASignal;
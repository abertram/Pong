------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: TBPong
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Testbench für die Entity EPong. Bindet die Komponente zum Simulieren eines
-- Drehgebers ein und simuliert ein paar Drehklicks.
--
-- Simulationszeit: 300ms
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use work.Types.all;

entity TBPong is
end entity TBPong;

architecture ATBPong of TBPong is
	signal
		SClock,
		SReset,
		SKey0,
		SKey1,
		SASignal0,
		SBSignal0,
		SASignal1,
		SBSignal1,
		SEffectiveDirectionSwitch0,
		SEffectiveDirectionSwitch1: std_logic;
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

	component EPong is
		port (
			Clock,
			Reset,
			Key0,
			Key1,
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
			VGARed,
			VGAGreen,
			VGABlue: out std_logic_vector (9 downto 0);
			VGABlank,
			VGAClock,
			VGAHorizontalSync,
			VGAVerticalSync: out std_logic
		);
	end component EPong;
begin
	-- Drehencodersimulator fuer den rechten Schläger
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

	-- Drehencodersimulator fuer den linken Schläger
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

	Pong: EPong
		port map (
			SClock,
			SReset,
			SKey0,
			SKey1,
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
			SVGARed,
			SVGAGreen,
			SVGABlue,
			SVGABlank,
			SVGAClock,
			SVGAHorizontalSync,
			SVGAVerticalSync
		);

	-- Systemtakt
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
		SEffectiveDirectionSwitch0 <= '0';
		SEffectiveDirectionSwitch1 <= '0';
		wait for cDesignClockPeriod;
		-- Reset aus
		SReset <= '0';
		wait for cDesignClockPeriod;

		SKey1 <= '0';
		wait for cDesignClockPeriod;
		SKey1 <= '1';
		wait for cDesignClockPeriod;

		-- im Uhrzeigersinn drehen
		-- => hoch zaehlen => Schläger runter
		SRotationDirection0 <= CounterClockwise;
		SRotationDirection1 <= CounterClockwise;
		SSquareWaveHalfPeriod0 <= 5;
		SSquareWaveHalfPeriod1 <= 10;
		wait for 10 ms;

		SSquareWaveHalfPeriod0 <= 0;
		SSquareWaveHalfPeriod1 <= 0;

		wait;
	end process SimulationProcess;

end architecture ATBPong;
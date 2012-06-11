------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 2: EVGASignal
-- Entity: EIOModul
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Repraesentiert das EVGASignal nach aussen.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EVGASignal is
	port (
		-- Takt
		Clock,
		-- Reset
		Reset,
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
		-- Ansteuerung der 7-Segment-Anzeigen
		SevenSegmentVector0,
		SevenSegmentVector1,
		SevenSegmentVector2,
		SevenSegmentVector3,
		SevenSegmentVector4,
		SevenSegmentVector5,
		SevenSegmentVector6,
		SevenSegmentVector7: out TSevenSegmentVector;
		-- Farben
		VGARed,
		VGAGreen,
		VGABlue: out TColor;
		-- Sync-Signale
		VGABlank,
		VGAClock,
		VGAHorizontalSync,
		VGAVerticalSync: out std_logic
	);
end entity EVGASignal;

architecture AVGASignal of EVGASignal is
	signal
		Clock25MHz: std_logic;
	signal
		SVectorValue0,
		SVectorValue1: TVectorValue;

	-- Frequenzteiler
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

	-- Ein- / Ausgabemodul
	component EIOModul is
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
			-- Werte in Binaerform
			VectorValue0,
			VectorValue1: out TVectorValue
		);
	end component EIOModul;

	-- Balken zeichnen
	component EJoistsDraw is
		generic (
			JoistWidth: TJoistWidth;
			JoistHeight: TJoistHeight
		);
		port (
			Clock,
			Reset: in std_logic;
			-- momentane y-Position der Balken
			StartY0,
			StartY1: in TVectorValue;
			VGARed,
			VGAGreen,
			VGABlue: out TColor;
			VGABlank,
			VGAClock,
			VGAHorizontalSync,
			VGAVerticalSync: out std_logic
		);
	end component EJoistsDraw;
begin
	-- Frequenzteiler, Verhältnis 1:2
	ClockDivider: EClockDivider
		generic map (
			2
		)
		port map (
			Clock,
			Reset,
			Clock25MHz
		);

	-- Ein- / Ausgabemodul
	IOModul: EIOModul
		port map (
			Clock25MHz,
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
			EffectiveDirectionSwitch1,
			SevenSegmentVector0,
			SevenSegmentVector1,
			SevenSegmentVector2,
			SevenSegmentVector3,
			SevenSegmentVector4,
			SevenSegmentVector5,
			SevenSegmentVector6,
			SevenSegmentVector7,
			SVectorValue0,
			SVectorValue1
		);

	-- Balken zeichnen
	JoistsDraw: EJoistsDraw
		generic map (
			TJoistWidth'high,
			TJoistHeight'high
		)
		port map (
			Clock25MHz,
			Reset,
			-- momentane y-Position der Balken
			SVectorValue0,
			SVectorValue1,
			VGARed,
			VGAGreen,
			VGABlue,
			VGABlank,
			VGAClock,
			VGAHorizontalSync,
			VGAVerticalSync
		);
end architecture AVGASignal;
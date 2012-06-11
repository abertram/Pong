------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: EIOModul
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Repraesentiert das Ein- / Ausgabemodul nach aussen.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EIOModul is
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
		-- Werte im Binaerformat
		VectorValue0,
		VectorValue1: out TVectorValue
	);
end entity EIOModul;

architecture AIOModul of EIOModul is
	signal
		Operand0,
		Operand1: TVectorValue;

	-- Eingabekomponente
	component EInput is
		port (
			Clock,
			Reset,
			Key0,
			Key1,
			ASignal,
			BSignal,
			EffectiveDirectionSwitch: in std_logic;
			Operand: out TVectorValue
		);
	end component EInput;

	-- Ausgabekomponente
	component EOutput is
		generic (
			MinValue,
			MaxValue: TVectorValue
		);
		port (
			Clock,
			Reset: in std_logic;
			Operand: in TVectorValue;
			SevenSegmentVector0,
			SevenSegmentVector1,
			SevenSegmentVector2,
			SevenSegmentVector3: out TSevenSegmentVector;
			VectorValue: out TVectorValue
		);
	end component EOutput;
begin
	-- Eingabe 0 (rechts)
	Input0: EInput
		port map (
			Clock,
			Reset,
			Key0,
			Key1,
			-- Drehencodersignale umdrehen, da die Pins in der Hardware vertauscht sind
			BSignal0,
			ASignal0,
			EffectiveDirectionSwitch0,
			Operand0
		);

	-- Eingabe 1 (links)
	Input1: EInput
		port map (
			Clock,
			Reset,
			Key2,
			Key3,
			-- Drehencodersignale umdrehen, da die Pins in der Hardware vertauscht sind
			BSignal1,
			ASignal1,
			EffectiveDirectionSwitch1,
			Operand1
		);

	-- Ausgabe 0 (rechts)
	Output0: EOutput
		generic map (
			-- minimaler Wert
			TVectorValue(to_unsigned(0, TVectorValue'length)),
			-- maximaler Wert
			TVectorValue(to_unsigned(9999, TVectorValue'length))
		)
		port map (
			Clock,
			Reset,
			Operand0,
			SevenSegmentVector0,
			SevenSegmentVector1,
			SevenSegmentVector2,
			SevenSegmentVector3,
			VectorValue0
		);

	-- Ausgabe 1 (links)
	Output1: EOutput
		generic map (
			-- minimaler Wert
			TVectorValue(to_unsigned(0, TVectorValue'length)),
			-- maximaler Wert
			TVectorValue(to_unsigned(9999, TVectorValue'length))
		)
		port map (
			Clock,
			Reset,
			Operand1,
			SevenSegmentVector4,
			SevenSegmentVector5,
			SevenSegmentVector6,
			SevenSegmentVector7,
			VectorValue1
		);
end architecture AIOModul;
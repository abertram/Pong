library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EIOModul is
	port (
		Clock,
		Reset,
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
		VectorValue1: out TVectorValue;
		DebugLED0,
		DebugLED1: out std_logic
	);
end entity EIOModul;

architecture AIOModul of EIOModul is
	signal
		Operand0,
		Operand1: TVectorValue;

	-- Eingabekomponente
	component EInput is
		generic (
			DelayPeriods: in TDelayPeriods
		);
		port (
			Clock,
			Reset,
			ASignal,
			BSignal,
			EffectiveDirectionSwitch: std_logic;
			Operand: out TVectorValue;
			DebugLED: out std_logic
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
	-- Eingabe 0
	Input0: EInput
		generic map (
--			5
			500E3
		)
		port map (
			Clock,
			Reset,
			ASignal0,
			BSignal0,
			EffectiveDirectionSwitch0,
			Operand0,
			DebugLED0
		);

	-- Eingabe 1
	Input1: EInput
		generic map (
--			5
			500E3
		)
		port map (
			Clock,
			Reset,
			ASignal1,
			BSignal1,
			EffectiveDirectionSwitch1,
			Operand1,
			DebugLED1
		);

	-- Ausgabe 0
	Output0: EOutput
		generic map (
			TVectorValue(to_unsigned(0, TVectorValue'length)),
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

	-- Ausgabe 1
	Output1: EOutput
		generic map (
			TVectorValue(to_unsigned(0, TVectorValue'length)),
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
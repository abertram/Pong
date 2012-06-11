library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EIOModul is
	port (
		Clock,
		Reset,
		Key0,
		Key1,
		Key2,
		Key3: in std_logic;
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
end entity EIOModul;

architecture AIOModul of EIOModul is
	signal
		Operand: TVectorValue;
	signal
		DisplayIndex: TDisplayIndex;

	-- Eingabekomponente
	component EInput is
		port (
			Clock,
			Reset,
			Key0,
			Key1,
			Key2,
			Key3: in std_logic;
			DisplayIndex: out TDisplayIndex;
			Operand: out TVectorValue
		);
	end component EInput;

	-- Ausgabekomponente
	component EOutput is
		generic (
			GenericDisplayIndex: TDisplayIndex;
			MinValue,
			MaxValue: TVectorValue
		);
		port (
			Clock,
			Reset: in std_logic;
			PortDisplayIndex: TDisplayIndex;
			Operand: in TVectorValue;
			SevenSegmentVector0,
			SevenSegmentVector1,
			SevenSegmentVector2,
			SevenSegmentVector3: out TSevenSegmentVector;
			VectorValue: out TVectorValue
		);
	end component EOutput;
begin
	-- Eingabe
	Input: EInput
		port map (
			Clock,
			Reset,
			Key0,
			Key1,
			Key2,
			Key3,
			DisplayIndex,
			Operand
		);

	-- Ausgabe 0
	Output0: EOutput
		generic map (
			0,
			TVectorValue(to_unsigned(0, TVectorValue'length)),
			TVectorValue(to_unsigned(9999, TVectorValue'length))
		)
		port map (
			Clock,
			Reset,
			DisplayIndex,
			Operand,
			SevenSegmentVector0,
			SevenSegmentVector1,
			SevenSegmentVector2,
			SevenSegmentVector3,
			VectorValue0
		);

	-- Ausgabe 1
	Output1: EOutput
		generic map (
			1,
			TVectorValue(to_unsigned(0, TVectorValue'length)),
			TVectorValue(to_unsigned(9999, TVectorValue'length))
		)
		port map (
			Clock,
			Reset,
			DisplayIndex,
			Operand,
			SevenSegmentVector4,
			SevenSegmentVector5,
			SevenSegmentVector6,
			SevenSegmentVector7,
			VectorValue1
		);
end architecture AIOModul;
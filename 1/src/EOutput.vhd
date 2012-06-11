------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: EOutput
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Hat einen Operanden als Einganssignal. Dieser wird an andere eingebundene
-- Komponenten weitergereicht, die diesen verarbeiten. Die Ausgangssignale
-- dieser Komponenten werden nach aussen gefuehrt.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EOutput is
	generic (
		-- minimaler Wert, der angezeigt werden kann
		MinValue,
		-- maximaler Wert, der angezeigt werden kann
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
end entity EOutput;

architecture AOutput of EOutput is
	-- Wert nach draussen
	signal
		OutputVectorValue: TVectorValue;
	-- Ziffern
	signal
		Digits: TDigits;

	-- Addierer
	component EAdder is
		generic (
			MinValue,
			MaxValue: TVectorValue
		);
		port (
			Clock,
			Reset: in std_logic;
			Operand: in TVectorValue;
			Result: out TVectorValue
		);
	end component EAdder;

	-- Binaer-zu-7-Segment-Konvertierer
	component EBinaryToSevenSegmentConverter is
		port (
			Clock,
			Reset: in std_logic;
			VectorValue: in TVectorValue;
			Digits: out TDigits
		);
	end component EBinaryToSevenSegmentConverter;
begin
	-- Addierer
	Adder: EAdder
		generic map (
			MinValue,
			MaxValue
		)
		port map (
			Clock,
			Reset,
			Operand,
			OutputVectorValue
		);

	-- Binaer-zu-7-Segment-Konvertierer
	BinaryToSevenSegmentConverter: EBinaryToSevenSegmentConverter
		port map (
			Clock,
			Reset,
			OutputVectorValue,
			Digits
		);

	-- Signale nach draussen
	-- Wert im Binaerformat
	VectorValue <= OutputVectorValue;
	-- Ansteuerung der 7-Segment-Anzeige
	SevenSegmentVector0 <= cSegmentCodes(Digits(3));
	SevenSegmentVector1 <= cSegmentCodes(Digits(2));
	SevenSegmentVector2 <= cSegmentCodes(Digits(1));
	SevenSegmentVector3 <= cSegmentCodes(Digits(0));
end architecture AOutput;

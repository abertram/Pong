------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: ESevenSegmentOutput
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Ist für die Ausgabe auf den 7-Segment-Anzeigen zuständig.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity ESevenSegmentOutput is
	port (
		Clock,
		Reset: in std_logic;
		GameState: in TGameState;
		LeftPlayerScore,
		RightPlayerScore: in TScore;
		SevenSegmentVector0,
		SevenSegmentVector1,
		SevenSegmentVector2,
		SevenSegmentVector3,
		SevenSegmentVector4,
		SevenSegmentVector5,
		SevenSegmentVector6,
		SevenSegmentVector7: out TSevenSegmentVector
	);
end entity ESevenSegmentOutput;

architecture ASevenSegmentOutput of ESevenSegmentOutput is
	-- Ziffern
	signal
		LeftDigits,
		RightDigits: TDigits;
	signal
		LeftPlayerScoreAsVectorValue,
		RightPlayerScoreAsVectorValue: TVectorValue;

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
	-- Spielstand konvertieren
	LeftPlayerScoreAsVectorValue <= TVectorValue(to_unsigned(LeftPlayerScore, TVectorValue'length));
	RightPlayerScoreAsVectorValue <= TVectorValue(to_unsigned(RightPlayerScore, TVectorValue'length));

	-- Binaer-zu-7-Segment-Konvertierer
	LeftPlayerBinaryToSevenSegmentConverter: EBinaryToSevenSegmentConverter
		port map (
			Clock,
			Reset,
			LeftPlayerScoreAsVectorValue,
			LeftDigits
		);

	RightPlayerBinaryToSevenSegmentConverter: EBinaryToSevenSegmentConverter
		port map (
			Clock,
			Reset,
			RightPlayerScoreAsVectorValue,
			RightDigits
		);

	-- P für Player
	SevenSegmentVector0 <=
		cSegmentCodeP when GameState = LeftPlayerStart or GameState = LeftPlayerBreak or LeftPlayerScore = TScore'high or GameState = RightPlayerStart or GameState = RightPlayerBreak or RightPlayerScore = TScore'high else
		cSegmentCodeOff;
	-- r für right oder L für Left
	SevenSegmentVector1 <=
		cSegmentCodeL when GameState = LeftPlayerStart or GameState = LeftPlayerBreak or LeftPlayerScore = TScore'high else
		cSegmentCodeR when GameState = RightPlayerStart or GameState = RightPlayerBreak or RightPlayerScore = TScore'high else
		cSegmentCodeOff;
	-- t, L, r oder O
	SevenSegmentVector2 <=
		cSegmentCodeT when GameState = LeftPlayerStart or GameState = RightPlayerStart else
		cSegmentCodeL when GameState = Play else
		cSegmentCodeR when GameState = LeftPlayerBreak or GameState = RightPlayerBreak else
		cSegmentCodeO when GameState = GameOver else
		cSegmentCodeOff;
	-- S für Start, P für Play, b für break oder G für Game
	SevenSegmentVector3 <=
		cSegmentCodeStart when GameState = LeftPlayerStart or GameState = RightPlayerStart else
		cSegmentCodeP when GameState = Play else
		cSegmentCodeB when GameState = LeftPlayerBreak or GameState = RightPlayerBreak else
		cSegmentCodeG when GameState = GameOver else
		cSegmentCodeOff;
	-- Spielstand
	SevenSegmentVector4 <= cSegmentCodes(RightDigits(1));
	SevenSegmentVector5 <= cSegmentCodes(RightDigits(0));
	SevenSegmentVector6 <= cSegmentCodes(LeftDigits(1));
	SevenSegmentVector7 <= cSegmentCodes(LeftDigits(0));
end architecture ASevenSegmentOutput;
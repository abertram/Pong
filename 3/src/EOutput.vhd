------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: EOutput
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Kapselt die Komponenten für die Ausgabe.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EOutput is
	port (
		Clock,
		Reset: in std_logic;
		GameState: in TGameState;
		BallX: in TXPosition;
		BallY,
		RightRacketY,
		LeftRacketY: in TYPosition;
		LeftPlayerScore,
		RightPlayerScore: in TScore;
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
		VGABlue: out TColor;
		VGABlank,
		VGAClock,
		VGAHorizontalSync,
		VGAVerticalSync,
		NewFrame: out std_logic
	);
end entity EOutput;

architecture AOutput of EOutput is
	component EVGAOutput is
		port (
			Clock,
			Reset: in std_logic;
			BallX: in TXPosition;
			BallY,
			RightRacketY,
			LeftRacketY: in TYPosition;
			VGARed,
			VGAGreen,
			VGABlue: out TColor;
			VGABlank,
			VGAClock,
			VGAHorizontalSync,
			VGAVerticalSync,
			NewFrame: out std_logic
		);
	end component EVGAOutput;

	component ESevenSegmentOutput is
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
	end component ESevenSegmentOutput;
begin
	VGAOutput: EVGAOutput
		port map (
			Clock,
			Reset,
			BallX,
			BallY,
			RightRacketY,
			LeftRacketY,
			VGARed,
			VGAGreen,
			VGABlue,
			VGABlank,
			VGAClock,
			VGAHorizontalSync,
			VGAVerticalSync,
			NewFrame
		);

	SevenSegmentOutput: ESevenSegmentOutput
		port map (
			Clock,
			Reset,
			GameState,
			LeftPlayerScore,
			RightPlayerScore,
			SevenSegmentVector0,
			SevenSegmentVector1,
			SevenSegmentVector2,
			SevenSegmentVector3,
			SevenSegmentVector4,
			SevenSegmentVector5,
			SevenSegmentVector6,
			SevenSegmentVector7
		);
end architecture AOutput;
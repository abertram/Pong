------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: EVGAOutput
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Kapselt die Komponenten für die Darstellung auf dem Monitor.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
use work.Types.all;

entity EVGAOutput is
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
end entity EVGAOutput;

architecture AVGAOutput of EVGAOutput is
	component EDrawObject is
		generic (
			ScreenWidth: TScreenWidth;
			ScreenHeight: TScreenHeight;
			RacketWidth: TRacketWidth;
			RacketHeight: TRacketHeight;
			BallRadius: TBallRadius
		);
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
	end component EDrawObject;
begin
	DrawObject: EDrawObject
		generic map (
			TScreenWidth'high,
			TScreenHeight'high,
			TRacketWidth'high,
			TRacketHeight'high,
			TBallRadius'high
		)
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
end architecture AVGAOutput;
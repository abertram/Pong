------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: EDrawObject
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Kapselt die Komponenten, die für die Darstellung auf einem Monitor
-- notwendig sind.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
use work.Types.all;

entity EDrawObject is
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
end entity EDrawObject;

architecture ADrawObject of EDrawObject is
	signal
		SHBlank,
		SVBlank,
		DrawPixelEnable: std_logic;
	signal
		X: TXPosition;
	signal
		Y: TYPosition;
	signal
		RightRacketYAsPosition,
		LeftRacketYAsPosition: TYPosition;

	-- VGA-Synchronisation
	component EVGASync is
		generic (
			HSyncLength: THSyncLength;
			HBackPorchLength: THBackPorchLength;
			HDisplayIntervalLength: THDisplayIntervalLength;
			HFrontPorchLength: THFrontPorchLength;
			VSyncLength: TVSyncLength;
			VBackPorchLength: TVBackPorchLength;
			VDisplayIntervalLength: TVDisplayIntervalLength;
			VFrontPorchLength: TVFrontPorchLength
		);
		port (
			Clock,
			Reset: in std_logic;
			HSync,
			HBlank,
			VSync,
			VBlank: out std_logic;
			X: out TXposition;
			Y: out TYPosition
		);
	end component EVGASync;

	-- Pixel zeichnen
	component EDrawPixel is
		generic (
			-- Hintergrundfarbe
			BackgroundRedColor,
			BackgroundGreenColor,
			BackgroundBlueColor,
			-- Farbe des rechten Balkens
			RightRacketRedColor,
			RightRacketGreenColor,
			RightRacketBlueColor,
			-- Farbe des linken Balkens
			LeftRacketRedColor,
			LeftRacketGreenColor,
			LeftRacketBlueColor,
			BallRedColor,
			BallGreenColor,
			BallBlueColor: TColor;
			RacketWidth: TRacketWidth;
			RacketHeight: TRacketHeight;
			BallRadius: TBallRadius
		);
		port (
			Clock,
			Reset: in std_logic;
			X: TXPosition;
			Y: TYPosition;
			BallX: TXPosition;
			BallY,
			RightRacketY,
			LeftRacketY: TYPosition;
			DrawEnable: in std_logic;
			Red,
			Green,
			Blue: out TColor
		);
	end component EDrawPixel;
begin
	VGAClock <= Clock;

	-- VGA-Synchronisation
	VGASync: EVGASync
		generic map (
			-- Board
			95,
			47,
			635,
			15,
			2,
			33,
			480,
			10
			-- Simulation
--			95 / 10,
--			47 / 10,
--			635 / 10,
--			15 / 5,
--			2 / 2,
--			33 / 10,
--			480 / 10,
--			10 / 10
		)
		port map (
			Clock,
			Reset,
			VGAHorizontalSync,
			SHBlank,
			VGAVerticalSync,
			SVBlank,
			X,
			Y
		);

	VGABlank <= SHBlank or SVBlank;

	-- Berechnung eines neuen Bildes nach außen bekannt geben
	NewFrame <=
		'1' when (X = 0) and (Y = 0) and DrawPixelEnable = '1' else
		'0';

	DrawPixelEnable <= SHBlank and SVBlank;

	-- Pixel zeichnen
	DrawPixel: EDrawPixel
		generic map (
			-- Hintergrundfarbe
			-- rot
			(others => '0'),
			-- gruen
			(others => '0'),
			-- blau
			(others => '1'),
			-- Farbe des rechten Balkens
			-- rot
			(others => '1'),
			-- gruen
			(others => '0'),
			-- blau
			(others => '0'),
			-- Farbe des linken Balkens
			-- rot
			(others => '0'),
			-- gruen
			(others => '1'),
			-- blau
			(others => '0'),
			-- Ballfarbe
			-- rot
			(others => '1'),
			-- grün
			(others => '1'),
			-- blau
			(others => '1'),
			-- Schlägerbreite
			RacketWidth,
			-- Schlägerhöhe
			RacketHeight,
			-- Balldurchmesser
			BallRadius
		)
		port map (
			Clock,
			Reset,
			X,
			Y,
			BallX,
			BallY,
			RightRacketY,
			LeftRacketY,
			DrawPixelEnable,
			VGARed,
			VGAGreen,
			VGABlue
		);
end architecture ADrawObject;
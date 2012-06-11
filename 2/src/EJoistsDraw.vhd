------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 2: EVGASignal
-- Entity: EJoistsDraw
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Bindet die Komponenten ein, die für das Erzeugen der VGA-Signale nötig sind
-- und verknüpft diese miteinander.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EJoistsDraw is
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
		-- Farbsignale
		VGARed,
		VGAGreen,
		VGABlue: out TColor;
		-- Syncsignale
		VGABlank,
		VGAClock,
		VGAHorizontalSync,
		VGAVerticalSync: out std_logic
	);
end entity EJoistsDraw;

architecture AJoistsDraw of EJoistsDraw is
	signal
		SHBlank,
		SVBlank,
		CountLineEnable,
		HorizontalDrawEnable,
		VerticalDrawEnable,
		DrawPixelEnable: std_logic;
	signal
		X: TXPosition;
	signal
		Y: TYPosition;
	signal
		StartY0AsPosition,
		StartY1AsPosition: TYPosition;

	-- Sync-Komponente
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
			X: out TXPosition;
			Y: out TYPosition
		);
	end component EVGASync;

	-- Komponente zum Pixelzeichnen
	component EDrawPixel is
		generic (
			BackgroundRedColor,
			BackgroundGreenColor,
			BackgroundBlueColor,
			Joist0RedColor,
			Joist0GreenColor,
			Joist0BlueColor,
			Joist1RedColor,
			Joist1GreenColor,
			Joist1BlueColor: TColor;
			JoistWidth: TJoistWidth;
			JoistHeight: TJoistHeight
		);
		port (
			Clock,
			Reset: in std_logic;
			XPosition: in TXPosition;
			YPosition,
			StartY0,
			StartY1: in TYPosition;
			DrawEnable: in std_logic;
			Red,
			Green,
			Blue: out TColor
		);
	end component EDrawPixel;
begin
	-- Sync
	VGASync: EVGASync
		generic map (
			-- Board
			cHSyncClockPeriods,
			cHBackPorchClockPeriods,
			cHDisplayIntervalClockPeriods,
			cHFrontPorchClockPeriods,
			cVSyncLineCount,
			cVBackPorchLineCount,
			cVDisplayIntervalLineCount,
			cVFrontPorchLineCount
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

	-- Takt für VGA
	VGAClock <= Clock;

	-- Blank-Signal
	VGABlank <= SHBlank or SVBlank;

	-- Umwandeln der Werte in Integer
	process(Clock)
	begin
		if rising_edge(Clock) then
			StartY0AsPosition <= to_integer(unsigned(StartY0));
			StartY1AsPosition <= to_integer(unsigned(StartY1));
		end if;
	end process;

	-- Pixelzeichnen einschalten
	DrawPixelEnable <= SHBlank and SVBlank;
	-- Komponente zum Pixelzeichnen
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
			JoistWidth,
			JoistHeight
		)
		port map (
			Clock,
			Reset,
			X,
			Y,
			StartY0AsPosition,
			StartY1AsPosition,
			DrawPixelEnable,
			VGARed,
			VGAGreen,
			VGABlue
		);
end architecture AJoistsDraw;
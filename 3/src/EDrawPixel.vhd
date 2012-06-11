------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: EVGASignal
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Setzt die Farbsignale fuer das VGA-Signal abhaengig von der Position. Die
-- Farben fuer den Hintergrund, den rechten und den linken Balken werden ueber
-- Generics gesetzt.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use work.Types.all;

entity EDrawPixel is
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
end entity EDrawPixel;

architecture ADrawPixel of EDrawPixel is
	signal
		TmpBallX: TXPosition;
	signal
		TmpBallY,
		TmpRightRacketY,
		TmpLeftRacketY: TYPosition;
begin
	DrawProcess: process(Clock, Reset, DrawEnable)
	begin
		if Reset = '1' then
			Red <= (others => '0');
			Green <= (others => '0');
			Blue <= (others => '0');
		elsif rising_edge(Clock) then
			-- Pixel soll gezeichnet werden
			if DrawEnable = '1' then
				-- rechter Balken
				if ((X >= (TScreenWidth'high - RacketWidth)) and (X < TScreenWidth'high) and (Y >= RightRacketY) and (Y < (RightRacketY + RacketHeight))) then
					Red <= RightRacketRedColor;
					Green <= RightRacketGreenColor;
					Blue <= RightRacketBlueColor;
				-- linker Balken
				elsif ((X >= 0) and (X < RacketWidth) and (Y >= LeftRacketY) and (Y < (LeftRacketY + RacketHeight))) then
					Red <= LeftRacketRedColor;
					Green <= LeftRacketGreenColor;
					Blue <= LeftRacketBlueColor;
				-- Ball
				elsif (((X - BallX - BallRadius)**2 + (Y - BallY - BallRadius)**2) <= TBallRadius'high**2) then
--				elsif ((X >= BallX) and (X < (BallX + 2 * BallRadius)) and (Y >= BallY) and (Y < (BallY + 2 * BallRadius))) then
					Red <= BallRedColor;
					Green <= BallGreenColor;
					Blue <= BallBlueColor;
				-- Hintergrund
				else
					Red <= BackgroundRedColor;
					Green <= BackgroundGreenColor;
					Blue <= BackgroundBlueColor;
				end if;
			-- kein Pixel
			else
				Red <= (others => '0');
				Green <= (others => '0');
				Blue <= (others => '0');
			end if;
		end if;
	end process DrawProcess;
end architecture ADrawPixel;
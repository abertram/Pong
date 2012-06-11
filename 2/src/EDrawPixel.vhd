------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 2: EVGASignal
-- Entity: EDrawPixel
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
		Joist0RedColor,
		Joist0GreenColor,
		Joist0BlueColor,
		-- Farbe des linken Balkens
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
end entity EDrawPixel;

architecture ADrawPixel of EDrawPixel is
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
				if ((XPosition >= (TScreenWidth'high - JoistWidth)) and (XPosition < TScreenWidth'high) and (YPosition >= StartY0) and (YPosition < (StartY0 + JoistHeight))) then
					Red <= Joist0RedColor;
					Green <= Joist0GreenColor;
					Blue <= Joist0BlueColor;
				-- linker Balken
				elsif ((XPosition >= 0) and (XPosition < JoistWidth) and (YPosition >= StartY1) and (YPosition < (StartY1 + JoistHeight))) then
					Red <= Joist1RedColor;
					Green <= Joist1GreenColor;
					Blue <= Joist1BlueColor;
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
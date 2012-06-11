------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 2: EVGASignal
-- Entity: TBDrawPixel
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Testbench für die Entity EDrawPixel. Die einzelnen Testfälle sind weiter
-- unten beschrieben.
-- Simulationszeit: 400ns
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity TBDrawPixel is
end entity TBDrawPixel;

architecture ATBDrawPixel of TBDrawPixel is
	signal
		SClock,
		SReset: std_logic;
	signal
		SXPosition: TXPosition;
	signal
		SYPosition,
		SStartY0,
		SStartY1: TYPosition;
	signal
		SDrawEnable: std_logic;
	signal
		SRed,
		SGreen,
		SBlue: TColor;

	component EDrawPixel is
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
	end component EDrawPixel;
begin
	DrawPixel: EDrawPixel
		generic map (
			-- Hintergrundfarbe
			cBackgroundRedColor,
			cBackgroundGreenColor,
			cBackgroundBlueColor,
			-- Farbe des rechten Balkens
			cJoist0RedColor,
			cJoist0GreenColor,
			cJoist0BlueColor,
			-- Farbe des linken Balkens
			cJoist1RedColor,
			cJoist1GreenColor,
			cJoist1BlueColor,
			TJoistWidth'high,
			TJoistHeight'high
		)
		port map (
			SClock,
			SReset,
			SXPosition,
			SYPosition,
			SStartY0,
			SStartY1,
			SDrawEnable,
			SRed,
			SGreen,
			SBlue
		);

	ClockProcess: process
	begin
		SClock <= '1';
		wait for cClockPeriod / 2;
		SClock <= '0';
		wait for cClockPeriod / 2;
	end process ClockProcess;

	SimulationProcess: process
		procedure AssertColor(Red, Green, Blue: TColor) is
		begin
			assert(SRed = Red) report "Rot" severity failure;
			assert(SGreen = Green) report "Grün" severity failure;
			assert(SBlue = Blue) report "Blau" severity failure;
			report "OK";
		end procedure AssertColor;

		procedure AssertNoColor is
		begin
			AssertColor(TColor(to_unsigned(0, TColor'length)), TColor(to_unsigned(0, TColor'length)), TColor(to_unsigned(0, TColor'length)));
		end procedure AssertNoColor;

		procedure AssertBackgroundColor is
		begin
			AssertColor(cBackgroundRedColor, cBackgroundGreenColor, cBackgroundBlueColor);
		end procedure AssertBackgroundColor;

		procedure AssertJoist0Color is
		begin
			AssertColor(cJoist0RedColor, cJoist0GreenColor, cJoist0BlueColor);
		end procedure AssertJoist0Color;

		procedure AssertJoist1Color is
		begin
			AssertColor(cJoist1RedColor, cJoist1GreenColor, cJoist1BlueColor);
		end procedure AssertJoist1Color;
	begin
		report "Reset ein";
		SReset <= '1';
		SXPosition <= 0;
		SYPosition <= 0;
		SStartY0 <= 0;
		SStartY1 <= 0;
		SDrawEnable <= '0';
		wait for cClockPeriod;

		report "Farben beim Reset testen";
		AssertNoColor;

		report "Reset aus";
		SReset <= '0';
		wait for cClockPeriod;

		report "Farben testen, wenn nicht gezeichnet werden soll";
		AssertNoColor;

		report "DrawEnable ein";
		SDrawEnable <= '1';
		wait for cClockPeriod;

		report "Farbe an der Position (0; 0) testen (linker Balken)";
		AssertJoist1Color;

		report "Übergang rechte Kante des linken Balkens => Hintergrund";

		report "Farbe an der Position (" & integer'image(TJoistWidth'high - 1) & "; 0) testen (linker Balken)";
		SXPosition <= TJoistWidth'high - 1;
		wait for cClockPeriod;
		AssertJoist1Color;

		report "Farbe an der Position (" & integer'image(TJoistWidth'high) & "; 0) testen (Hintergrund)";
		SXPosition <= TJoistWidth'high;
		wait for cClockPeriod;
		AssertBackgroundColor;

		report "Übergang Hintergrund => linke Kante des rechten Balkens";

		report "Farbe an der Position (" & integer'image(TScreenWidth'high - TJoistWidth'high - 2) & "; 0) testen (Hintergrund)";
		SXPosition <= TScreenWidth'high - TJoistWidth'high - 2;
		wait for cClockPeriod;
		AssertBackgroundColor;

		report "Farbe an der Position (" & integer'image(TScreenWidth'high - TJoistWidth'high - 1) & "; 0) testen (rechter Balken)";
		SXPosition <= TScreenWidth'high - TJoistWidth'high - 1;
		wait for cClockPeriod;
		AssertJoist0Color;

		report "Übergang untere Kante des linken Balkens => Hintergrund";

		report "Farbe an der Position (0; " & integer'image(TJoistHeight'high - 1) & ") testen (linker Balken)";
		SXPosition <= 0;
		SYPosition <= TJoistHeight'high - 1;
		wait for cClockPeriod;
		AssertJoist1Color;

		report "Farbe an der Position (0; " & integer'image(TJoistHeight'high) & ") testen (Hintergrund)";
		SYPosition <= TJoistHeight'high;
		wait for cClockPeriod;
		AssertBackgroundColor;

		report "Übergang untere Kante des rechten Balkens => Hintergrund";

		report "Farbe an der Position (" & integer'image(TScreenWidth'high - 2) & "; " & integer'image(TJoistHeight'high - 1) & ") testen (Hintergrund)";
		SXPosition <= TScreenWidth'high - 2;
		SYPosition <= TJoistHeight'high - 1;
		wait for cClockPeriod;
		AssertJoist0Color;

		report "Farbe an der Position (" & integer'image(TScreenWidth'high - 2) & "; " & integer'image(TJoistHeight'high) & ") testen (rechter Balken)";
		SXPosition <= TScreenWidth'high - 2;
		SYPosition <= TJoistHeight'high;
		wait for cClockPeriod;
		AssertBackgroundColor;

		report "Linken Balken um einen Pixel nach unten bewegen";
		SStartY1 <= SStartY1 + 1;

		report "Rechten Balken an den unteren Bildschirmrand bewegen";
		SStartY0 <= TScreenHeight'high - TJoistHeight'high;

		wait for cClockPeriod;

		report "Übergang Hintergrund => obere Kante des linken Balkens";

		report "Farbe an der Position (0; 0) testen (Hintergrund)";
		SXPosition <= 0;
		SYPosition <= 0;
		wait for cClockPeriod;
		AssertBackgroundColor;

		report "Farbe an der Position (0; 1) testen (linker Balken)";
		SXPosition <= 0;
		SYPosition <= 1;
		wait for cClockPeriod;
		AssertJoist1Color;

		report "Übergang untere Kante des linken Balkens => Hintergrund";

		report "Farbe an der Position (0; " & integer'image(SStartY1 + TJoistHeight'high - 1) & ") testen (linker Balken)";
		SYPosition <= SStartY1 + TJoistHeight'high - 1;
		wait for cClockPeriod;
		AssertJoist1Color;

		report "Farbe an der Position (0; " & integer'image(SStartY1 + TJoistHeight'high) & ") testen (Hintergrund)";
		SYPosition <= SStartY1 + TJoistHeight'high;
		wait for cClockPeriod;
		AssertBackgroundColor;

		report "Übergang Hintergrund => obere Kante des rechten Balkens";

		report "Farbe an der Position (" & integer'image(TScreenWidth'high - 2) & "; " & integer'image(TScreenHeight'high - TJoistHeight'high - 1) & ") testen (Hintergrund)";
		SXPosition <= TScreenWidth'high - 2;
		SYPosition <= TScreenHeight'high - TJoistHeight'high - 1;
		wait for cClockPeriod;
		AssertBackgroundColor;

		report "Farbe an der Position (" & integer'image(TScreenWidth'high - 2) & "; " & integer'image(TScreenHeight'high - TJoistHeight'high) & ") testen (rechter Balken)";
		SYPosition <= TScreenHeight'high - TJoistHeight'high;
		wait for cClockPeriod;
		AssertJoist0Color;

		report "Farbe an der Position (" & integer'image(TScreenWidth'high - 1) & "; " & integer'image(TScreenHeight'high - 1) & " testen (rechter Blaken)";
		SYPosition <= TScreenHeight'high - 1;
		wait for cClockPeriod;
		AssertJoist0Color;

		wait;
	end process SimulationProcess;
end architecture ATBDrawPixel;
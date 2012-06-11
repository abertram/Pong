------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: EBinaryToSevenSegmentConverter
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Konvertiert eine binaere Zahl so, dass sie auf einer vierstelligen
-- 7-Segment-Anzeige darstellbar ist. Dies geschieht, in dem mit Hilfe einer
-- Statemachine zunaechst der hoechste Stellenwert so lange subtrahiert wird,
-- bis die Zahl kleiner als dieser Stellenwert ist. Dann wird mit dem
-- naechstniedrigeren Stellenwert weiter gerechnet. Dies wird so lange
-- fortgesetzt, bis das Ergebnis gleich Null ist.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EBinaryToSevenSegmentConverter is
	port (
		Clock,
		Reset: in std_logic;
		VectorValue: in TVectorValue;
		Digits: out TDigits
	);
end entity EBinaryToSevenSegmentConverter;

architecture ABinaryToSevenSegmentConverter of EBinaryToSevenSegmentConverter is
	-- Zustaende fuer die Statemachine
	signal
		CurrentState,
		NextState: TOutputState;
	-- temporaerer Wert, der fuer die Zerlegung in Ziffern verwendet wird
	signal
		StripVectorValue: TVectorValue;
	-- aktuelle Ziffernposition in der zu zerlegenden Zahl
	signal
		DigitPosition: TDigitPosition;
begin
	-- Prozess zum Zerlegen der Zahl in Ziffern
	ComputeDigitsProcess: process(Clock, Reset)
		-- Zwischenvariable fuer die Berechnung
		variable
			TmpDigits: TDigits;
	begin
		if Reset = '1' then
			Digits <= (others => 0);
		elsif rising_edge(Clock) then
			case CurrentState is
				-- Signale und Variablen initialisieren
				when Init =>
						StripVectorValue <= VectorValue;
						DigitPosition <= 0;
						TmpDigits := (others => 0);
				-- Zahl zerlegen
				when ComputeDigits =>
					-- wenn bei 0 angekommen, Ziffern aktualisieren
					if unsigned(StripVectorValue) = 0 then
							Digits <= TmpDigits;
					-- ueberpruefen, ob aktuelle Zahl groesser als der aktuelle Stellenwert ist
					elsif StripVectorValue >= TVectorValue(to_unsigned(cPlaceValues(DigitPosition), TVectorValue'length)) then
						-- aktuellen Stellenwert von der aktuellen Zahl abziehen
						StripVectorValue <= TVectorValue(unsigned(StripVectorValue) - to_unsigned(cPlaceValues(DigitPosition), TVectorValue'length));
						-- Zaehler hochzaehlen
						TmpDigits(DigitPosition) := TmpDigits(DigitPosition) + 1;
					else
						-- dafuer sorgen, dass die Ziffernposition nicht ueberlaeuft
						if DigitPosition < cPlaceValues'right then
							DigitPosition <= DigitPosition + 1;
						end if;
					end if;
			end case;
		end if;
	end process ComputeDigitsProcess;

	-- aktueller Zustand
	CurrentStateProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			CurrentState <= Init;
		elsif rising_edge(Clock) then
			CurrentState <= NextState;
		end if;
	end process CurrentStateProcess;

	-- naechster Zustand
	NextStateProcess: process(CurrentState, StripVectorValue)
	begin
		case CurrentState is
			when Init =>
				-- in jedem Fall in den naechsten Zustand wechseln
				NextState <= ComputeDigits;
			when ComputeDigits =>
				-- wenn Zahl zerlegt, wieder in den Zustand Init wechseln
				if unsigned(StripVectorValue) = 0 then
					NextState <= Init;
				else
					NextState <= CurrentState;
				end if;
		end case;
	end process NextStateProcess;
end architecture ABinaryToSevenSegmentConverter;
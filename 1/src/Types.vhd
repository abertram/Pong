------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: Types
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Beinhaltet die fuer das Projekt benoetigten Konstanten und Datentypen.
------------------------------------------------------------------------------
library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package Types is

	-- Wert als std_logic_vector
	subtype TVectorValue is std_logic_vector(13 downto 0);
	-- Zustaende fuer den Zustandsautomaten der Outputentity
	type TOutputState is (Init, ComputeDigits);
	-- Datentyp fuer die Stellenwerte einer Dezimalzahl
	type TPlaceValues is array(0 to 3) of positive range 1 to 1000;
	-- Stellenwerte einer Zahl
	constant cPlaceValues: TPlaceValues := (1000, 100, 10, 1);
	subtype TDigitPosition is natural range 0 to 3;
	-- Ziffern von 0 bis 9
	type TDigits is array(TDigitPosition) of natural range 0 to 9;

	-- Typen und Konstanten fuer die Ansteuerung der 7-Segment-Anzeige
	-- 7-Segment-Vektor
	subtype TSevenSegmentVector is std_logic_vector(0 to 6);
	-- Lookup-Tabelle fuer die Darstellung der Zahlen
	type TSegmentCodes is array (0 to 9) of TSevenSegmentVector;
	constant cSegmentCode0: TSevenSegmentVector := "0000001";
	constant cSegmentCode1: TSevenSegmentVector := "1001111";
	constant cSegmentCode2: TSevenSegmentVector := "0010010";
	constant cSegmentCode3: TSevenSegmentVector := "0000110";
	constant cSegmentCode4: TSevenSegmentVector := "1001100";
	constant cSegmentCode5: TSevenSegmentVector := "0100100";
	constant cSegmentCode6: TSevenSegmentVector := "0100000";
	constant cSegmentCode7: TSevenSegmentVector := "0001111";
	constant cSegmentCode8: TSevenSegmentVector := "0000000";
	constant cSegmentCode9: TSevenSegmentVector := "0000100";
	constant cSegmentCodes: TSegmentCodes := (
		cSegmentCode0,
		cSegmentCode1,
		cSegmentCode2,
		cSegmentCode3,
		cSegmentCode4,
		cSegmentCode5,
		cSegmentCode6,
		cSegmentCode7,
		cSegmentCode8,
		cSegmentCode9
	);

	-- Drehrichtung
	type TRotationDirection is (NoRotation, Clockwise, Counterclockwise);
	-- Zustaende fuer den Drehrichtungsdecoder
	type TRotationDirectionDecoderState is (WaitForAOrB, WaitForRisingA, WaitForFallingA, WaitForRisingB, WaitForFallingB, Delay);
	-- Wartezeit
	subtype TDelayPeriods is natural range 0 to 500E3;
	-- Zustaende fuer den Rechtecksignalgenerator
	type TEncoderSignalGeneratorState is (Init, Delay, HighLevel, LowLevel);
	-- Zustaende fuer den Entpreller
	type TDebounceState is (WaitForEdge, Delay);
	-- Schieberegisterbreite des Entprellers
	constant cDebouncerShiftRegisterWidth: natural := 2;
	-- Schieberegisterbreite des Drehdecoders
	constant cRotationDirectionDecoderShiftRegisterWidth: natural := 2;
end package Types;
library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package Types is
	-- Wert als std_logic_vector
	-- manuelle Zuweisung der Breite: ld(cScreenHeight - cRacketHeight)
	subtype TVectorValue is std_logic_vector(9 downto 0);
	-- Zustaende fuer den Zustandsautomaten der Outputentity
	type TOutputState is (Init, ComputeDigits);
	-- Datentyp fuer die Stellenwerte einer Dezimalzahl
	type TPlaceValues is array(0 to 1) of positive range 1 to 10;
	-- Stellenwerte einer Zahl
	constant cPlaceValues: TPlaceValues := (10, 1);
	subtype TDigitPosition is natural range 0 to 1;
	-- Ziffer von 0 bis 9
	type TDigits is array(TDigitPosition) of natural range 0 to 9;

	-- Typen und Konstanten fuer die Ansteuerung der 7-Segment-Anzeige
	-- 7-Segment-Vektor
	subtype TSevenSegmentVector is std_logic_vector(0 to 6);
	-- Lookup-Tabelle fuer die Darstellung der Zahlen und Zeichen
	type TSegmentCodes is array(0 to 9) of TSevenSegmentVector;
	constant cSegmentCodeOff: TSevenSegmentVector := "1111111";
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
	constant cSegmentCodeStart: TSevenSegmentVector := "0100100";
	constant cSegmentCodeP: TSevenSegmentVector := "0011000";
	constant cSegmentCodeB: TSevenSegmentVector := "1100000";
	constant cSegmentCodeG: TSevenSegmentVector := "0100001";
	constant cSegmentCodeO: TSevenSegmentVector := "0000001";
	constant cSegmentCodeL: TSevenSegmentVector := "1110001";
	constant cSegmentCodeR: TSevenSegmentVector := "1111010";
	constant cSegmentCodeT: TSevenSegmentVector := "1110000";
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
	-- Drehrichtunsdecoder-Zustände
	type TRotationDirectionDecoderState is (WaitForAOrB, WaitForRisingA, WaitForFallingA, WaitForRisingB, WaitForFallingB, Delay);
	-- Wartezeit
	subtype TClockPeriods is natural range 0 to 250E3;
	-- Zustände für den Drehencodersimulator
	type TEncoderSignalGeneratorState is (Init, Delay, HighLevel, LowLevel);
	-- Breite des Encoderschieberegisters
--	constant cEncoderShiftRegisterWidth: natural := 2;
	-- Zustände des Entprellers
	type TDebounceState is (WaitForEdge, Delay);

	-- durch die ungenaue Frequenz verlieren wir ein paar Pixel
	subtype TScreenWidth is natural range 0 to 636;
	subtype TScreenHeight is natural range 0 to 481;
	-- Schlägergröße
	subtype TRacketWidth is positive range 1 to 10;
	subtype TRacketHeight is positive range 1 to 200;
	-- Koordinaten
	subtype TXPosition is TScreenWidth range TScreenWidth'low to TScreenWidth'high - 1;
	subtype TYPosition is TScreenHeight range TScreenHeight'low to TScreenHeight'high - 1;
	-- Farbe
	subtype TColor is std_logic_vector(9 downto 0);
	-- Breite des Enpreller-Schieberegisters
	constant cDebouncerShiftRegisterWidth: positive := 2;
	-- Breite des Drehrichtungdecoder-Schieberegisters
	constant cRotationDirectionDecoderShiftRegisterWidth: positive := 2;
	-- Balldurchmesser
	subtype TBallDiameter is natural range 1 to 20;
	-- Zustände für die Ballpositionberechnung
	type TBallPositionState is (Init, UpdatePosition, UpdateMotionVectors, Delay);
	-- Bewegungsvektoren
	subtype TXMotionVector is integer range -200 to 200;
	subtype TYMotionVector is integer range -200 to 200;
	-- Ballradius
	subtype TBallRadius is positive range 1 to TBallDiameter'high / 2;
	-- Punkte
	subtype TScore is natural range 0 to 9;
	-- Periodenlänge des horizontalen VGA-Timings
	subtype THSyncLength is positive range 1 to 190;
	subtype THBackPorchLength is positive range 1 to 95;
	subtype THDisplayIntervalLength is positive range 1 to 1270;
	subtype THFrontPorchLength is positive range 1 to 30;
	-- Pixelszähler
	subtype THCounter is natural range 0 to (THSyncLength'high + THBackPorchLength'high + THDisplayIntervalLength'high + THFrontPorchLength'high) - 1;
	-- Zeilenanzahl des vertikalen VGA-Timings
	subtype TVSyncLength is positive range 1 to 2;
	subtype TVBackPorchLength is positive range 1 to 33;
	subtype TVDisplayIntervalLength is positive range 1 to 480;
	subtype TVFrontPorchLength is positive range 1 to 10;
	-- Zeilenzähler
	subtype TVCounter is natural range 0 to (TVSyncLength'high + TVBackPorchLength'high + TVDisplayIntervalLength'high + TVFrontPorchLength'high) - 1;
	-- Schlägerunterteilung in Bereiche
	constant cChangeBallSpeedAreaCount: natural := 3;
	-- Geschwindigkeitsänderung
	subtype TBallSpeedOffset is integer range -1 to 1;
	-- Geschwindigkeitsänderungsarray
	type TBallSpeedOffsets is array (0 to cChangeBallSpeedAreaCount - 1) of TBallSpeedOffset;
	-- Geschwindigkeitsänderung pro Schlägerbereich
	constant cBallSpeedOffsets: TBallSpeedOffsets := (-1, 0, 1);
	-- Beschleunigung für Schlägerkontakte
	subtype TRacketContactCountToIncrementXMotion is natural range 0 to 10;
	-- Beschleunigung für Wandkontakte
	subtype TFieldEdgeContactCountToIncrementYMotion is natural range 0 to 20;
	-- Spielstatus-Zustände
	type TGameState is (Init, InitLeftPlayer, InitRightPlayer, LeftPlayerStart, RightPlayerStart, Play, LeftPlayerBreak, RightPlayerBreak, GameOver);
	subtype TScoreToIncrementInitMotion is natural range 0 to 10;

	-- Konstanten für die Testbenches
	constant
		cClockPeriod: time := 20 ns;
	constant
		cDesignClockPeriod: time := 2 * cClockPeriod;

	constant
		cHSyncLength: time := 3.8 us;
	constant
		cHSyncClockPeriods: natural := cHSyncLength / cDesignClockPeriod;
	-- Timing angepasst, da das Design mit 25 MHz läuft und 1,9 us somit nicht möglich sind
	constant
		cHBackPorchLength: time := 1.88 us;
	constant
		cHBackPorchClockPeriods: natural := cHBackPorchLength / cDesignClockPeriod;
	constant
		cHDisplayIntervalLength: time := 25.4 us;
	constant
		cHDisplayIntervalClockPeriods: natural := cHDisplayIntervalLength / cDesignClockPeriod;
	constant
		cHFrontPorchLength: time := 0.6 us;
	constant
		cHFrontPorchClockPeriods: natural := cHFrontPorchLength / cDesignClockPeriod;
	constant
		cLineLength: time := cHSyncLength + cHBackPorchLength + cHDisplayIntervalLength + cHFrontPorchLength;
	constant
		cVSyncLineCount: natural := 2;
	constant
		cVBackPorchLineCount: natural := 33;
	constant
		cVDisplayIntervalLineCount: natural := 480;
	constant
		cVFrontPorchLineCount: natural := 10;
	constant
		cVSyncLength: time := cVSyncLineCount * cLineLength;
	constant
		cVBackPorchLength: time := cVBackPorchLineCount * cLineLength;
	constant
		cVDisplayIntervalLength: time := cVDisplayIntervalLineCount * cLineLength;
	constant
		cVFrontPorchLength: time := cVFrontPorchLineCount * cLineLength;
end package Types;
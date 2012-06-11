------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: TBBallPosition
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Testbench für die Entity EBall Position.
--
-- Simulationszeit: 40µs
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use work.Types.all;

entity TBBallPosition is
end entity TBBallPosition;

architecture ATBBallPosition of TBBallPosition is
	signal
		SClock,
		SReset,
		SUpdatePositionEnable,
		SResetBall: std_logic;
	signal
		SRightRacketY,
		SLeftRacketY: TYPosition;
	signal
		SX: TXPosition;
	signal
		SY: TYPosition;
	signal
		SBallLeftOutside,
		SBallRightOutside: boolean;


	constant
		cInitX: TXPosition := TXPosition'high / 2;
	constant
		cInitY: TYPosition := TYPosition'high / 2;
	constant
		cInitXMotionVector: TXMotionVector := 1;
	constant
		cInitYMotionVector: TYMotionVector := 1;

	component EBallPosition is
		generic (
			BallDiameter: TBallDiameter;
			InitX: TXPosition;
			InitY: TYPosition;
			ScreenWidth: TScreenWidth;
			ScreenHeight: TScreenHeight;
			RacketWidth: TRacketWidth;
			RacketHeight: TRacketHeight;
			InitXMotionVector: TXMotionVector;
			InitYMotionVector: TYMotionVector;
			RacketContactCountToIncrementXMotion: TRacketContactCountToIncrementXMotion;
			FieldEdgeContactCountToIncrementYMotion: TFieldEdgeContactCountToIncrementYMotion;
			ScoreToIncrementInitMotion: TScoreToIncrementInitMotion
		);
		port (
			Clock,
			Reset,
			UpdatePositionEnable,
			ResetBall: in std_logic;
			RightRacketY,
			LeftRacketY: in TYPosition;
			X: out TXPosition;
			Y: out TYPosition;
			BallLeftOutside,
			BallRightOutside: out boolean
		);
	end component EBallPosition;
begin
	BallPosition: EBallPosition
		generic map (
			10,
			cInitX,
			cInitY,
			TScreenWidth'high,
			TScreenHeight'high,
			10,
			TRacketHeight'high,
			cInitXMotionVector,
			cInitYMotionVector,
			1,
			1,
			1
		)
		port map (
			SClock,
			SReset,
			SUpdatePositionEnable,
			SResetBall,
			SRightRacketY,
			SLeftRacketY,
			SX,
			SY,
			SBallLeftOutside,
			SBallRightOutside
		);

	-- Systemtakt
	ClockProcess: process
	begin
		SClock <= '1';
		wait for cClockPeriod / 2;
		SClock <= '0';
		wait for cClockPeriod / 2;
	end process ClockProcess;

	SimulationProcess: process
	begin
		report "Reset ein";
		SReset <= '1';
		SUpdatePositionEnable <= '0';
		SResetBall <= '0';
		wait for cClockPeriod;

		report "Reset aus";
		SReset <= '0';
		wait for cClockPeriod;

		assert(SX = cInitX) report "X";
		assert(SY = cInitY) report "Y";

		report "10 Takte warten";
		wait for 10 * cClockPeriod;

		assert(SX = cInitX) report "X";
		assert(SY = cInitY) report "Y";

		report "UpdatePositionEnable ein";
		SUpdatePositionEnable <= '1';
		wait for cClockPeriod;
		report "UpdatePositionEnable aus";
		SUpdatePositionEnable <= '0';
		wait for cClockPeriod;

		wait for cClockPeriod;

		assert(SX = cInitX + cInitXMotionVector) report "X";
		assert(SY = cInitY + cInitYMotionVector) report "Y";

		report "10 Takte warten";
		wait for 10 * cClockPeriod;

		report "UpdatePositionEnable ein";
		SUpdatePositionEnable <= '1';
		wait for cClockPeriod;
		report "UpdatePositionEnable aus";
		SUpdatePositionEnable <= '0';
		wait for cClockPeriod;

		wait for cClockPeriod;

		assert(SX = cInitX + 2 * cInitXMotionVector) report "X";
		assert(SY = cInitY + 2 * cInitYMotionVector) report "Y";

		report "UpdatePositionEnable ein";
		SUpdatePositionEnable <= '1';

		report "Warten, bis der Ball an der unteren Kante abprallt";
		wait until SY + 10 = TYPosition'high;
		wait until SY'event;

		report "Vertikale Geschwindigkeit testen";
		assert(abs(SY - SY'last_value) = 2);

		report "Rechten Schläger nach unten bewegen";
		SRightRacketY <= 240;
		wait for cClockPeriod;

		report "Warten, bis der Ball am rechten Schläger abprallt";
		wait until SX + 10 + 10 = TXPosition'high;
		wait until SX'event;

		report "Horizontale Geschwindigkeit testen";
		assert(abs(SX - SX'last_value) = 2);

		report "Warten, bis der Ball am linken Schläger vorbei geht";
		wait until SBallLeftOutside;
		wait for 4 * cClockPeriod;
		wait until SX'event;

		report "Horizontale und vertikale Geschwindigkeit testen";
		assert(abs(SX - SX'last_value) = 2);
		assert(abs(SY - SY'last_value) = 2);

		report "UpdatePositionEnable aus";
		SUpdatePositionEnable <= '0';

		wait;
	end process SimulationProcess;
end architecture ATBBallPosition;
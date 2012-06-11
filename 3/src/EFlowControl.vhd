------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: EFlowControl
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Kapselt die Komponenten für den Spielablauf.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EFlowControl is
	port (
		Clock,
		Reset,
		UpdateBallPositionEnable,
		LeftPlayerKey,
		RightPlayerKey: in std_logic;
		VectorValue0,
		VectorValue1: in TVectorValue;
		GameState: out TGameState;
		BallX: out TXPosition;
		BallY,
		RightRacketY,
		LeftRacketY: out TYPosition;
		LeftPlayerScore,
		RightPlayerScore: out TScore
	);
end entity EFlowControl;

architecture AFlowControl of EFlowControl is
	signal
		SBallX: TXPosition;
	signal
		SBallY,
		SRightRacketY,
		SLeftRacketY: TYPosition;
	signal
		SBallLeftOutside,
		SBallRightOutside: boolean;
	signal
		SLeftPlayerScore,
		SRightPlayerScore: TScore;
	signal
		SGameState: TGameState;
	signal
		NewGame,
		GameEnable: std_logic;

	component EGameState is
		port (
			Clock,
			Reset,
			LeftPlayerKey,
			RightPlayerKey: in std_logic;
			LeftPlayerScore,
			RightPlayerScore: in TScore;
			GameState: out TGameState
		);
	end component EGameState;

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

	component EScore is
		port (
			Clock,
			Reset,
			Enable,
			ResetScore: in std_logic;
			BallLeftOutside,
			BallRightOutside: in boolean;
			LeftPlayerScore,
			RightPlayerScore: out TScore
		);
	end component EScore;
begin
	GameStateInstance: EGameState
		port map (
			Clock,
			Reset,
			LeftPlayerKey,
			RightPlayerKey,
			SLeftPlayerScore,
			SRightPlayerScore,
			SGameState
		);

	-- aktueller Spielzustand
	GameState <= SGameState;

	-- Berechnung eines neuen Spiels
	NewGame <=
		'1' when SGameState = Init or SGameState = InitLeftPlayer or SGameState = InitRightPlayer else
		'0';

	-- Berechnung, wann das Spiel läuft
	GameEnable <=
		'1' when (SGameState = Play) and (UpdateBallPositionEnable = '1') else
		'0';

	-- Casten der Schlägerpositionen nur bei einer Flanke
	process(Clock)
	begin
		if rising_edge(Clock) then
			SRightRacketY <= to_integer(unsigned(VectorValue0));
			SLeftRacketY <= to_integer(unsigned(VectorValue1));
		end if;
	end process;

	RightRacketY <= SRightRacketY;
	LeftRacketY <= SLeftRacketY;

	BallPosition: EBallPosition
		generic map (
			TBallDiameter'high,
			TScreenWidth'high / 2,
			TScreenHeight'high / 2,
			TScreenWidth'high,
			TScreenHeight'high,
			TRacketWidth'high,
			TRacketheight'high,
			1,
			1,
			10,
			20,
			2
		)
		port map (
			Clock,
			Reset,
			GameEnable,
			NewGame,
			SRightRacketY,
			SLeftRacketY,
			SBallX,
			SBallY,
			SBallLeftOutside,
			SBallRightOutside
		);

	-- Ballposition
	BallX <= SBallX;
	BallY <= SBallY;

	Score: EScore
		port map (
			Clock,
			Reset,
			GameEnable,
			NewGame,
			SBallLeftOutside,
			SBallRightOutside,
			SLeftPlayerScore,
			SRightPlayerScore
		);

	-- Spielstand
	LeftPlayerScore <= SLeftPlayerScore;
	RightPlayerScore <= SRightPlayerScore;
end architecture AFlowControl;
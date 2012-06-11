------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: EPong
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Repräsentiert das Spiel nach außen.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
use work.Types.all;

entity EPong is
	port (
		Clock,
		Reset,
		Key0,
		Key1,
		ASignal0,
		BSignal0,
		ASignal1,
		BSignal1,
		EffectiveDirectionSwitch0,
		EffectiveDirectionSwitch1: in std_logic;
		SevenSegmentVector0,
		SevenSegmentVector1,
		SevenSegmentVector2,
		SevenSegmentVector3,
		SevenSegmentVector4,
		SevenSegmentVector5,
		SevenSegmentVector6,
		SevenSegmentVector7: out TSevenSegmentVector;
		VGARed,
		VGAGreen,
		VGABlue: out TColor;
		VGABlank,
		VGAClock,
		VGAHorizontalSync,
		VGAVerticalSync: out std_logic
	);
end entity EPong;

architecture APong of EPong is
	signal
		SClock25MHz: std_logic;
	signal
		SVectorValue0,
		SVectorValue1: TVectorValue;
	signal
		SBallX: TXPosition;
	signal
		SBallY,
		SRightRacketY,
		SLeftRacketY: TYPosition;
	signal
		SNewFrame: std_logic;
	signal
		SLeftPlayerScore,
		SRightPlayerScore: TScore;
	signal
		SLeftPlayerKey,
		SRightPlayerKey: std_logic;
	signal
		SGameState: TGameState;

	component EClockDivider is
		generic (
			Divisor: positive
		);
		port (
			Clock,
			Reset: in std_logic;
			DividedClock: out std_logic
		);
	end component EClockDivider;

	component EInput
		port (
			Clock,
			Reset,
			Key0,
			Key1,
			ASignal0,
			BSignal0,
			ASignal1,
			BSignal1,
			EffectiveDirectionSwitch0,
			EffectiveDirectionSwitch1: in std_logic;
			Key0Pressed,
			Key1Pressed: out std_logic;
			VectorValue0,
			VectorValue1: out TVectorValue
		);
	end component EInput;

	component EFlowControl
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
	end component EFlowControl;

	component EOutput
		port (
			Clock,
			Reset: in std_logic;
			GameState: in TGameState;
			BallX: in TXPosition;
			BallY,
			RightRacketY,
			LeftRacketY: in TYPosition;
			LeftPlayerScore,
			RightPlayerScore: in TScore;
			SevenSegmentVector0,
			SevenSegmentVector1,
			SevenSegmentVector2,
			SevenSegmentVector3,
			SevenSegmentVector4,
			SevenSegmentVector5,
			SevenSegmentVector6,
			SevenSegmentVector7: out TSevenSegmentVector;
			VGARed,
			VGAGreen,
			VGABlue: out TColor;
			VGABlank,
			VGAClock,
			VGAHorizontalSync,
			VGAVerticalSync,
			NewFrame: out std_logic
		);
	end component EOutput;
begin
	-- Taktteiler => 25 MHz
	ClockDivider: EClockDivider
		generic map (
			2
		)
		port map (
			Clock,
			Reset,
			SClock25MHz
		);

	Input: EInput
		port map (
			SClock25MHz,
			Reset,
			Key0,
			Key1,
			ASignal0,
			BSignal0,
			ASignal1,
			BSignal1,
			EffectiveDirectionSwitch0,
			EffectiveDirectionSwitch1,
			SRightPlayerKey,
			SLeftPlayerKey,
			SVectorValue0,
			SVectorValue1
		);

	FlowControl: EFlowControl
		port map (
			SClock25MHz,
			Reset,
			SNewFrame,
			SLeftPlayerKey,
			SRightPlayerKey,
			SVectorValue0,
			SVectorValue1,
			SGameState,
			SBallX,
			SBallY,
			SRightRacketY,
			SLeftRacketY,
			SLeftPlayerScore,
			SRightPlayerScore
		);

	Output: EOutput
		port map (
			SClock25MHz,
			Reset,
			SGameState,
			SBallX,
			SBallY,
			SRightRacketY,
			SLeftRacketY,
			SLeftPlayerScore,
			SRightPlayerScore,
			SevenSegmentVector0,
			SevenSegmentVector1,
			SevenSegmentVector2,
			SevenSegmentVector3,
			SevenSegmentVector4,
			SevenSegmentVector5,
			SevenSegmentVector6,
			SevenSegmentVector7,
			VGARed,
			VGAGreen,
			VGABlue,
			VGABlank,
			VGAClock,
			VGAHorizontalSync,
			VGAVerticalSync,
			SNewFrame
		);
end architecture APong;
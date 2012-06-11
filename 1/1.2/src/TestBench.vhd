-- Simulation: 100 us
library ieee;
library work;

use ieee.std_logic_1164.all;
use work.Types.all;

entity TestBench is

end entity TestBench;

architecture ATestBench of TestBench is
	signal
		SClock,
		SReset,
		SKey0,
		SKey1,
		SKey2,
		SKey3: std_logic;
	signal
		SSevenSegmentVector0,
		SSevenSegmentVector1,
		SSevenSegmentVector2,
		SSevenSegmentVector3,
		SSevenSegmentVector4,
		SSevenSegmentVector5,
		SSevenSegmentVector6,
		SSevenSegmentVector7: TSevenSegmentVector;
	signal
		SVectorValue0,
		SVectorValue1: TVectorValue;
	signal
		SRotationDirection: TRotationDirection;
	signal
		SSquareWavePeriod: time;
	signal
		SASignal,
		SBSignal: std_logic;
	signal
		SEffectiveDirectionSwitch: std_logic;
	constant
		ClockPeriod: time := 20 ns;
	constant
		WaitPeriod: time := 2 * ClockPeriod;

	component EIOModul is
		port (
			Clock,
			Reset,
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
			VectorValue0,
			VectorValue1: out TVectorValue
		);
	end component EIOModul;

	component EEncoderSimulator is
		port (
			RotationDirection: in TRotationDirection;
			SquareWavePeriod: in time;
			ASignal,
			BSignal: out std_logic
		);
	end component EEncoderSimulator;

begin
	IOModul: EIOModul
		port map (
			SClock,
			SReset,
			SASignal,
			SBSignal,
			SASignal,
			SBSignal,
			SEffectiveDirectionSwitch,
			SEffectiveDirectionSwitch,
			SSevenSegmentVector0,
			SSevenSegmentVector1,
			SSevenSegmentVector2,
			SSevenSegmentVector3,
			SSevenSegmentVector4,
			SSevenSegmentVector5,
			SSevenSegmentVector6,
			SSevenSegmentVector7,
			SVectorValue0,
			SVectorValue1
		);

	EncoderSimulator: EEncoderSimulator
		port map (
			SRotationDirection,
			SSquareWavePeriod,
			SASignal,
			SBSignal
		);

	ClockProcess: process
	begin
		SClock <= '0';
		wait for ClockPeriod / 2;
		SClock <= '1';
		wait for ClockPeriod / 2;
	end process ClockProcess;

	SimulationProcess: process
	begin
		SReset <= '1';
		SRotationDirection <= NoRotation;
		SSquareWavePeriod <= 0 ns;
		SEffectiveDirectionSwitch <= '0';
		wait for WaitPeriod;

		SReset <= '0';
		wait for WaitPeriod;

		SRotationDirection <= Clockwise;
		SSquareWavePeriod <= 1 us;
		wait for 10 us;

		SSquareWavePeriod <= 0 ns;
		wait for WaitPeriod;

		SRotationDirection <= CounterClockwise;
		SSquareWavePeriod <= 2 us;
		wait for 20 us;

		SSquareWavePeriod <= 0 ns;
		wait for WaitPeriod;

		SEffectiveDirectionSwitch <= '1';
		SSquareWavePeriod <= 3 us;
		wait for 30 us;

		SSquareWavePeriod <= 0 ns;
		wait for WaitPeriod;

		SRotationDirection <= Clockwise;
		SSquareWavePeriod <= 4 us;
		wait for 40 us;

		wait;
	end process SimulationProcess;
end architecture ATestBench;
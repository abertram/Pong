library work;
library ieee;

use work.Types.all;
use ieee.std_logic_1164.all;

entity ETBEncoderSimulator is

end entity ETBEncoderSimulator;

architecture ATBEncoderSimulaltor of ETBEncoderSimulator is
	signal
		SRotationDirection: TRotationDirection;
	signal
		SSquareWavePeriod: time;
	signal
		SASignal,
		SBSignal: std_logic;

	component EEncoderSimulator is
		port (
			RotationDirection: in TRotationDirection;
			SquareWavePeriod: in time;
			ASignal,
			BSignal: out std_logic
		);
	end component EEncoderSimulator;
begin
	EncoderSimulator: EEncoderSimulator
		port map (
			SRotationDirection,
			SSquareWavePeriod,
			SASignal,
			SBSignal
		);

	SimulationProcess: process
	begin
		SRotationDirection <= NoRotation;
		SSquareWavePeriod <= 0 ns;
		wait for 1 ns;

		SRotationDirection <= Clockwise;
		SSquareWavePeriod <= 10 ns;
		wait for 100 ns;

		SSquareWavePeriod <= 0 ns;
		wait for 1 ns;

		SRotationDirection <= CounterClockwise;
		SSquareWavePeriod <= 15 ns;
		wait for 100 ns;

		SSquareWavePeriod <= 0 ns;
		wait for 1 ns;

		SRotationDirection <= Clockwise;
		SSquareWavePeriod <= 20 ns;
		wait for 100 ns;

		SSquareWavePeriod <= 0 ns;
		wait for 1 ns;

		SRotationDirection <= CounterClockwise;
		SSquareWavePeriod <= 25 ns;
		wait for 100 ns;

		wait;
	end process SimulationProcess;
end architecture ATBEncoderSimulaltor;
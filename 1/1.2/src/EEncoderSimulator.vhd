library work;
library ieee;

use work.Types.all;
use ieee.std_logic_1164.all;

entity EEncoderSimulator is
	port (
		RotationDirection: in TRotationDirection;
		SquareWavePeriod: in time;
		ASignal,
		BSignal: out std_logic
	);
end entity EEncoderSimulator;

architecture AEncoderSimulator of EEncoderSimulator is
	component EEncoderSignalGenerator is
		generic (
			GenericRotationDirection: TRotationDirection
		);
		port (
			RotationDirection: TRotationDirection;
			SquareWavePeriod: in time;
			OutSignal: out std_logic
		);
	end component EEncoderSignalGenerator;
begin
	ASignalGenerator: EEncoderSignalGenerator
		generic map (
			CounterClockwise
		)
		port map (
			RotationDirection,
			SquareWavePeriod,
			ASignal
		);

	BSignalGenerator: EEncoderSignalGenerator
		generic map (
			Clockwise
		)
		port map (
			RotationDirection,
			SquareWavePeriod,
			BSignal
		);

--	ASignalProcess: process
--		variable
--			TmpSquareWavePeriod: time;
--	begin
--		TmpSquareWavePeriod := SquareWavePeriod;
--		if TmpSquareWavePeriod > (0 * fs) then
--			if RotationDirection = CounterClockwise then
--				wait for TmpSquareWavePeriod / 4;
--			end if;
--			ASignal <= '1';
--			wait for TmpSquareWavePeriod / 2;
--			ASignal <= '0';
--			wait for TmpSquareWavePeriod / 2;
--		else
--			ASignal <= '0';
--			wait for 1 ps;
--		end if;
--	end process ASignalProcess;
--
--	BSignalProcess: process
--		variable
--			TmpSquareWavePeriod: time;
--	begin
--		TmpSquareWavePeriod := SquareWavePeriod;
--		if TmpSquareWavePeriod > (0 * fs) then
--			if RotationDirection = Clockwise then
--				wait for TmpSquareWavePeriod / 4;
--			end if;
--			BSignal <= '1';
--			wait for TmpSquareWavePeriod / 2;
--			BSignal <= '0';
--			wait for TmpSquareWavePeriod / 2;
--		else
--			BSignal <= '0';
--			wait for 1 ps;
--		end if;
--	end process BSignalProcess;

end architecture AEncoderSimulator;
library work;
library ieee;

use work.Types.all;
use ieee.std_logic_1164.all;

entity EEncoderSignalGenerator is
	generic (
		GenericRotationDirection: TRotationDirection
	);
	port (
		RotationDirection: TRotationDirection;
		SquareWavePeriod: in time;
		OutSignal: out std_logic
	);
end entity EEncoderSignalGenerator;

architecture AEncoderSignalGenerator of EEncoderSignalGenerator is
begin
	SignalProcess: process
		variable
			TmpSquareWavePeriod: time;
		variable
			TmpRotationDirection: TRotationDirection;
	begin
		TmpRotationDirection := RotationDirection;
		TmpSquareWavePeriod := SquareWavePeriod;
		if TmpSquareWavePeriod > (0 * fs) then
			if RotationDirection = GenericRotationDirection then
				wait for TmpSquareWavePeriod / 4;
			end if;
			while (TmpSquareWavePeriod = SquareWavePeriod) and (TmpRotationDirection = RotationDirection) loop
				OutSignal <= '1';
				wait for TmpSquareWavePeriod / 2;
				OutSignal <= '0';
				wait for TmpSquareWavePeriod / 2;
			end loop;
		else
			OutSignal <= '0';
			wait for 1 ps;
		end if;
	end process SignalProcess;
end architecture AEncoderSignalGenerator;
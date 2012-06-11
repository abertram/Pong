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
	constant
		ClockPeriod: time := 20 ns;
	constant
		WaitPeriod: time := 2 * ClockPeriod;

	component EIOModul is
		port (
			Clock,
			Reset,
			Key0,
			Key1,
			Key2,
			Key3: in std_logic;
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
begin
	IOModul: EIOModul
		port map (
			SClock,
			SReset,
			SKey0,
			SKey1,
			SKey2,
			SKey3,
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

	ClockProcess: process
	begin
		SClock <= '0';
		wait for ClockPeriod / 2;
		SClock <= '1';
		wait for ClockPeriod / 2;
	end process ClockProcess;

	SimulationProcess: process
	begin
		-- initialisieren
		SReset <= '1';
		SKey0 <= '1';
		SKey1 <= '1';
		SKey2 <= '1';
		SKey3 <= '1';
		wait for WaitPeriod;

		SReset <= '0';
		wait for WaitPeriod;

		-- alle Tasten nacheinander druecken und wieder los lassen
		SKey0 <= '0';
		wait for WaitPeriod;
		SKey0 <= '1';
		wait for 2 * WaitPeriod;
		SKey1 <= '0';
		wait for WaitPeriod;
		SKey1 <= '1';
		wait for 2 * WaitPeriod;
		SKey2 <= '0';
		wait for WaitPeriod;
		SKey2 <= '1';
		wait for 2 * WaitPeriod;
		SKey3 <= '0';
		wait for WaitPeriod;
		SKey3 <= '1';
		wait for 2 * WaitPeriod;

		-- Key0 druecken und 2 Takte gedrueckt halten
		SKey0 <= '0';
		wait for 2 * WaitPeriod;
		SKey0 <= '1';
		wait for 2 * WaitPeriod;

		-- Key0 und Key1 gleichzeitig druecken und los lassen
		SKey0 <= '0';
		SKey1 <= '0';
		wait for WaitPeriod;
		SKey0 <= '1';
		SKey1 <= '1';
		wait for 2 * WaitPeriod;

		-- Key0 und Key1 gleichzeitig druecken und 2 Takte gedrueckt halten
		SKey0 <= '0';
		SKey1 <= '0';
		wait for 2 * WaitPeriod;
		SKey0 <= '1';
		SKey1 <= '1';
		wait for 2 * WaitPeriod;

		-- Key0 druecken, gedrueckt halten, Key1 druecken und dann beide nacheinander los lassen
		SKey0 <= '0';
		wait for WaitPeriod;
		SKey1 <= '0';
		wait for WaitPeriod;
		SKey0 <= '1';
		wait for 2 * WaitPeriod;
		SKey1 <= '1';
		wait for 2 * WaitPeriod;

		-- Key0 druecken, gedrueckt halten, Key1 druecken und dann beide gleichzeitig los lassen
		SKey0 <= '0';
		wait for WaitPeriod;
		SKey1 <= '0';
		wait for WaitPeriod;
		SKey0 <= '1';
		SKey1 <= '1';
		wait for 2 * WaitPeriod;

		-- Taste mitten im Pegel drücken und nach einem halben Takt los lassen
--		SKey0 <= '0' after ClockPeriod / 4;
--		SKey0 <= '1' after ClockPeriod / 2;
--		wait for ClockPeriod / 4;

		-- negativen Wertebereich ueberschreiten
		for i in 0 to 9 loop
			SKey3 <= '0';
			wait for WaitPeriod;
			SKey3 <= '1';
			wait for WaitPeriod;
		end loop;

		-- positiven Wertebereich ueberschreiten
		for i in 0 to 9999 loop
			SKey2 <= '0';
			wait for WaitPeriod;
			SKey2 <= '1';
			wait for WaitPeriod;
		end loop;

		wait;
	end process SimulationProcess;
end architecture ATestBench;
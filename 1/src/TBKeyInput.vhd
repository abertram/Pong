------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: TBKeyInput
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Testbench fuer die Eingabe per Tasten.
--
-- Simulationszeit: 405 us
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity TBKeyInput is

end entity TBKeyInput;

architecture ATBKeyInput of TBKeyInput is
	signal
		SClock,
		SReset,
		SKey0,
		SKey1,
		SKey2,
		SKey3,
		SASignal,
		SBSignal: std_logic;
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
		SEffectiveDirectionSwitch: std_logic;

	constant
		ClockPeriod: time := 20 ns;

	-- IOModul
	component EIOModul is
		port (
			Clock,
			Reset,
			Key0,
			Key1,
			Key2,
			Key3,
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

begin
	-- IOModul
	IOModul: EIOModul
		port map (
			SClock,
			SReset,
			SKey0,
			SKey1,
			SKey2,
			SKey3,
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

	-- Systemtakt
	ClockProcess: process
	begin
		SClock <= '0';
		wait for ClockPeriod / 2;
		SClock <= '1';
		wait for ClockPeriod / 2;
	end process ClockProcess;

	-- Simulation
	SimulationProcess: process
	begin
		-- Reset
		SReset <= '1';
		SKey0 <= '1';
		SKey1 <= '1';
		SKey2 <= '1';
		SKey3 <= '1';
		SASignal <= '0';
		SBSignal <= '0';
		SRotationDirection <= NoRotation;
		SSquareWavePeriod <= 0 ns;
		SEffectiveDirectionSwitch <= '0';
		wait for ClockPeriod;

		-- Reset zu Ende
		SReset <= '0';
		wait for ClockPeriod;

		-- Tasten testen
		-- ein einfacher Test: alle Tasten nacheinander druecken und wieder los lassen
		SKey0 <= '0';
		wait for ClockPeriod;
		SKey0 <= '1';
		wait for 2 * ClockPeriod;
		assert(SVectorValue0 = TVectorValue(to_unsigned(1, TVectorValue'length)));
		SKey1 <= '0';
		wait for ClockPeriod;
		SKey1 <= '1';
		wait for 2 * ClockPeriod;
		assert(SVectorValue0 = TVectorValue(to_unsigned(0, TVectorValue'length)));
		SKey2 <= '0';
		wait for ClockPeriod;
		SKey2 <= '1';
		wait for 2 * ClockPeriod;
		assert(SVectorValue1 = TVectorValue(to_unsigned(1, TVectorValue'length)));
		SKey3 <= '0';
		wait for ClockPeriod;
		SKey3 <= '1';
		wait for 2 * ClockPeriod;
		assert(SVectorValue1 = TVectorValue(to_unsigned(0, TVectorValue'length)));

		-- Key2 druecken und 2 Takte gedrueckt halten
		-- Display 1 sollte nur um einen inkrementieren
		SKey2 <= '0';
		wait for 2 * ClockPeriod;
		SKey2 <= '1';
		wait for 2 * ClockPeriod;
		assert(SVectorValue1 = TVectorValue(to_unsigned(1, TVectorValue'length)));

		-- Key2 und Key3 gleichzeitig druecken und los lassen
		-- Display 1 sollte wieder um einen inkrementieren
		SKey2 <= '0';
		SKey3 <= '0';
		wait for ClockPeriod;
		SKey2 <= '1';
		SKey3 <= '1';
		wait for 2 * ClockPeriod;
		assert(SVectorValue1 = TVectorValue(to_unsigned(2, TVectorValue'length)));

		-- Key2 und Key3 gleichzeitig druecken und 2 Takte gedrueckt halten
		-- Display 1 sollte um einen inkrementieren
		SKey2 <= '0';
		SKey3 <= '0';
		wait for 2 * ClockPeriod;
		SKey2 <= '1';
		SKey3 <= '1';
		wait for 2 * ClockPeriod;
		assert(SVectorValue1 = TVectorValue(to_unsigned(3, TVectorValue'length)));

		-- Key2 druecken, gedrueckt halten, Key3 druecken und dann beide nacheinander los lassen
		-- Display 1 sollte erst um einen inkrementieren und dann gleich wieder dekrementieren
		SKey2 <= '0';
		wait for ClockPeriod;
		SKey3 <= '0';
		wait for ClockPeriod;
		SKey2 <= '1';
		wait for 2 * ClockPeriod;
		SKey3 <= '1';
		wait for 2 * ClockPeriod;
		assert(SVectorValue1 = TVectorValue(to_unsigned(3, TVectorValue'length)));

		-- Key2 druecken, gedrueckt halten, Key3 druecken und dann beide gleichzeitig los lassen
		-- Display 1 sollte sich im Endeffekt nicht veraendern
		SKey2 <= '0';
		wait for ClockPeriod;
		SKey3 <= '0';
		wait for ClockPeriod;
		SKey3 <= '1';
		SKey3 <= '1';
		wait for 2 * ClockPeriod;
		assert(SVectorValue1 = TVectorValue(to_unsigned(3, TVectorValue'length)));

		-- minimalen Wertebereich unterschreiten
		-- Display 1 sollte bei 0 stehen bleiben
		for i in 0 to 9 loop
			SKey3 <= '0';
			wait for ClockPeriod;
			SKey3 <= '1';
			wait for ClockPeriod;
		end loop;
		assert(SVectorValue1 = TVectorValue(to_unsigned(0, TVectorValue'length)));

		-- maximalen Wertebereich ueberschreiten
		-- Display 1 sollte bei 9999 stehen bleiben
		for i in 0 to 9999 loop
			SKey2 <= '0';
			wait for ClockPeriod;
			SKey2 <= '1';
			wait for ClockPeriod;
		end loop;
		assert(SVectorValue1 = TVectorValue(to_unsigned(9999, TVectorValue'length)));

		wait;
	end process SimulationProcess;
end architecture ATBKeyInput;
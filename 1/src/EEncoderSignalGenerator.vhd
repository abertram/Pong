------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: EEncoderSignalGenerator
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Erzeugt einen periodischen Rechteckimpuls fuer den Drehsimulator. Anhand
-- der per Generic gesetzten Drehrichtung wird eine Verzoegerung ausgegeben.
------------------------------------------------------------------------------
library work;
library ieee;

use work.Types.all;
use ieee.std_logic_1164.all;

entity EEncoderSignalGenerator is
	generic (
		-- Drehrichtung bei der der Impuls verzoegerunt wird
		GenericRotationDirection: TRotationDirection
	);
	port (
		-- Takt
		Clock,
		-- Reset
		Reset: std_logic;
		-- Drehrichtung
		RotationDirection: TRotationDirection;
		-- Anzahl der Systemtakte, die eine halbe Periode dauern soll
		SquareWaveHalfPeriod: in natural;
		-- Ausgangssignal
		OutSignal: out std_logic
	);
end entity EEncoderSignalGenerator;

architecture AEncoderSignalGenerator of EEncoderSignalGenerator is
	-- Zustaende fuer die Statemachine
	signal
		LastState,
		CurrentState,
		NextState: TEncoderSignalGeneratorState;
	-- Signal zur Zwischenspeicherung der Drehrichtung
	signal
		TmpRotationDirection: TRotationDirection;
	signal
		-- Zaehlsignale
		DelayClockCounter,
		HighLevelClockCounter,
		LowLevelClockCounter,
		-- Signal zur Zwischenspeicherung der halben Periodenlaenge
		TmpSquareWaveHalfPeriod: natural;
begin
	-- Zaehlprozess fuer die verstrichene Zeit einzelner Phasen
	CountProcess: process(Clock)
	begin
		if rising_edge(Clock) then
			case CurrentState is
				-- Wartephase
				when Delay =>
					DelayClockCounter <= DelayClockCounter + 1;
					HighLevelClockCounter <= 0;
					LowLevelClockCounter <= 0;
				-- Highlevelphase
				when HighLevel =>
					DelayClockCounter <= 0;
					HighLevelClockCounter <= HighLevelClockCounter + 1;
					LowLevelClockCounter <= 0;
				-- Lowlevelphase
				when LowLevel =>
					DelayClockCounter <= 0;
					HighLevelClockCounter <= 0;
					LowLevelClockCounter <= LowLevelClockCounter + 1;
				-- sonstiges
				when others =>
					DelayClockCounter <= 0;
					HighLevelClockCounter <= 0;
					LowLevelClockCounter <= 0;
			end case;
		end if;
	end process CountProcess;

	-- Statemachine

	-- Zustand weiter schalten
	CurrentStateProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			CurrentState <= Init;
			LastState <= LowLevel;
		elsif rising_edge(Clock) then
			-- merken, ob zuletzt High- oder Lowlevel erzeugt wurde
			if CurrentState = HighLevel or CurrentState = LowLevel then
				LastState <= CurrentState;
			end if;
			CurrentState <= NextState;
		end if;
	end process CurrentStateProcess;

	-- naechsten Zustand berechnen
	NextStateProcess: process(CurrentState, RotationDirection, SquareWaveHalfPeriod, LastState, DelayClockCounter, HighLevelClockCounter, LowLevelClockCounter)
	begin
		case CurrentState is
			-- Initialisierung
			when Init =>
				-- Drehrichtung zwischenspeichern
				TmpRotationDirection <= RotationDirection;
				-- halbe Periodenlaenge zwischenspeichern
				TmpSquareWaveHalfPeriod <= SquareWaveHalfPeriod;
				-- ueberpruefen, ob gedreht wird
				if (RotationDirection = NoRotation) or (SquareWaveHalfPeriod = 0) then
					NextState <= CurrentState;
				-- Drehrichtung ueberpruefen, um zu entscheiden, ob verzoegert werden soll
				elsif RotationDirection = GenericRotationDirection then
					NextState <= Delay;
				else
					-- nachsten Zustand anhand des letzten Zustandes setzen
					if LastState = LowLevel then
						NextState <= HighLevel;
					else
						NextState <= LowLevel;
					end if;
				end if;
			-- Verzoegerung
			when Delay =>
				-- Zaehler ueberpruefen
				if DelayClockCounter = (TmpSquareWaveHalfPeriod / 2) - 1 then
					-- nachsten Zustand anhand des letzten Zustandes setzen
					if LastState = LowLevel then
						NextState <= HighLevel;
					else
						NextState <= LowLevel;
					end if;
				else
					NextState <= CurrentState;
				end if;
			-- Highlevel
			when HighLevel =>
				-- Zaehler ueberpruefen und naechsten Zustand setzen
				if HighLevelClockCounter = TmpSquareWaveHalfPeriod - 1 then
					NextState <= LowLevel;
				else
					NextState <= CurrentState;
				end if;
			-- Lowlevel
			when LowLevel =>
				-- Zaehler ueberpruefen
				if LowLevelClockCounter = TmpSquareWaveHalfPeriod - 1 then
					-- ueberpruefen, ob sich die Drehrichtung oder die halbe Periodenlaenge geaendert haben, und naechsten Zustand setzen
					if (TmpSquareWaveHalfPeriod = SquareWaveHalfPeriod) and (TmpRotationDirection = RotationDirection) then
						NextState <= HighLevel;
					else
						NextState <= Init;
					end if;
				else
					NextState <= CurrentState;
				end if;
		end case;
	end process NextStateProcess;

	-- Ausgabeprozess
	OutputProcess: process(CurrentState)
	begin
		case CurrentState is
			when HighLevel =>
				OutSignal <= '1';
			when others =>
				OutSignal <= '0';
		end case;
	end process OutputProcess;
end architecture AEncoderSignalGenerator;
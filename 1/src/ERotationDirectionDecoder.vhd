------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: ERotationDirectionDecoder
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Berechnet anhand von zwei Einganssignalen eine Drehrichtung und setzt das
-- entsprechende Ausganssignal auf '1'.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use work.Types.all;

entity ERotationDirectionDecoder is
	port (
		Clock,
		Reset,
		ASignal,
		BSignal: in std_logic;
		ClockwiseRotation,
		CounterClockwiseRotation: out std_logic
	);
end entity ERotationDirectionDecoder;

architecture ARotationDirectionDecoder of ERotationDirectionDecoder is
	-- entprellte Signale
	signal
		ASignalDebounced,
		BSignalDebounced: std_logic;
	-- Zustaende fuer die Statemachine
	signal
		CurrentState,
		NextState: TRotationDirectionDecoderState;
	-- Ausgaenge der Schieberegister
	signal
		ASignalVector,
		BSignalVector: std_logic_vector(cRotationDirectionDecoderShiftRegisterWidth - 1 downto 0);
	-- Signal fuer die Verknuepfung der Ausgangsvektoren
	signal
		SignalVector: std_logic_vector(cRotationDirectionDecoderShiftRegisterWidth * 2 - 1 downto 0);

	-- Entpreller
	component EDebouncer is
		generic (
			DelayPeriods: positive
		);
		port (
			Clock,
			Reset,
			Input: in std_logic;
			Output: out std_logic
		);
	end component EDebouncer;

	-- Schieberegister
	component EShiftRegister is
		generic (
			Width: natural
		);
		port (
			Clock,
			Reset,
			Enable,
			ShiftDirection,
			Input: in std_logic;
			Output: out std_logic_vector(Width - 1 downto 0)
		);
	end component EShiftRegister;
begin
	-- Entpreller fuer das Signal A
	ASignalDebouncer: EDebouncer
		generic map (
			-- Simulation
			4
			-- Board
			-- 500E3
		)
		port map (
			Clock,
			Reset,
			ASignal,
			ASignalDebounced
		);

	-- Entpreller fuer das Signal B
	BSignalDebouncer: EDebouncer
		generic map (
			-- Simulation
			4
			-- Board
			-- 500E3
		)
		port map (
			Clock,
			Reset,
			BSignal,
			BSignalDebounced
		);

	-- Schieberegister fuer das Signal A
	AShiftRegister: EShiftRegister
		generic map (
			cRotationDirectionDecoderShiftRegisterWidth
		)
		port map (
			Clock,
			Reset,
			'1',
			'0',
			ASignalDebounced,
			SignalVector(3 downto 2)
		);

	-- Schieberegister fuer das Signal B
	BShiftRegister: EShiftRegister
		generic map (
			cRotationDirectionDecoderShiftRegisterWidth
		)
		port map (
			Clock,
			Reset,
			'1',
			'0',
			BSignalDebounced,
			SignalVector(1 downto 0)
		);

	-- State machine
	-- Weiterschalten des Zustandes
	CurrentStateProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			CurrentState <= WaitForAOrB;
		elsif rising_edge(Clock) then
			CurrentState <= NextState;
		end if;
	end process CurrentStateProcess;

	-- Berechnen des naechsten Zustandes
	NextStateProcess: process(CurrentState, SignalVector)
	begin
		case CurrentState is
			when WaitForAOrB =>
				case SignalVector is
					-- steigende Flanke von Signal A
					when "0100" =>
						-- auf steigende Flanke von Signal B warten, wir drehen im Uhrzeigersinn
						NextState <= WaitForRisingB;
					-- steigende Flanke von Signal B
					when "0001" =>
						-- auf steigende Flanke von Signal A warten, wir drehen gegen den Uhrzeigersinn
						NextState <= WaitForRisingA;
					-- fallende Flanke von Signal A
					when "1011" =>
						-- auf fallende Flanke von Signal B warten, wir drehen im Uhrzeigersinn
						NextState <= WaitForFallingB;
					-- fallende Flanke von Signal B
					when "1110" =>
						-- auf fallende Flanke von Signal A warten
						NextState <= WaitForFallingA;
					-- keine Flanke
					when others =>
						NextState <= CurrentState;
				end case;
			-- nach der steigenden Flanke von Signal B warten wir auf steigende Flanke von Signal A, wir drehen gegen den Uhrzeigersinn
			when WaitForRisingA =>
				case SignalVector is
					-- steigende A-Flanke
					when "0111" =>
						NextState <= Delay;
					-- der vor der A-Flanke gueltiger Zustand
					when "0011" =>
						NextState <= CurrentState;
					-- alles andere
					when others =>
						NextState <= WaitForAOrB;
				end case;
			-- nach der steigenden Flanke von Signal A warten wir auf steigende Flanke von Signal B, wir drehen im Uhrzeigersinn
			when WaitForRisingB =>
				case SignalVector is
					-- steigende B-Flanke
					when "1101" =>
						NextState <= Delay;
					-- der vor der B-Flanke gueltige Zustand
					when "1100" =>
						NextState <= CurrentState;
					-- alles andere
					when others =>
						NextState <= WaitForAOrB;
				end case;
			-- nach der fallenden Flanke von Signal B warten wir auf fallende Flanke von Signal A, wir drehen gegen den Uhrzeigersinn
			when WaitForFallingA =>
				case SignalVector is
					-- fallende A-Flanke
					when "1000" =>
						NextState <= Delay;
					-- der vor der A-Flanke gueltige Zustand
					when "1100" =>
						NextState <= CurrentState;
					-- alles andere
					when others =>
						NextState <= WaitForAOrB;
				end case;
			-- nach der fallenden Flanke von Signal A warten wir auf fallende Flanke von Signal B, wir drehen im Uhrzeigersinn
			when WaitForFallingB =>
				case SignalVector is
					-- fallende B-Flanke
					when "0010" =>
						NextState <= Delay;
					-- der vor der B-Flanke gueltige Zustand
					when "0011" =>
						NextState <= CurrentState;
					-- alles andere
					when others =>
						NextState <= WaitForAOrB;
				end case;
			-- Wartezustand, um die Drehrichtung richtig berechnen zu koennen
			when Delay =>
				NextState <= WaitForAOrB;
		end case;
	end process NextStateProcess;

	-- Uhrzeigersinn
	ClockwiseRotation <=
		'1' when
			-- warten auf eine B-Flanke
			(CurrentState = WaitForRisingB or CurrentState = WaitForFallingB) and
			-- naechster Zustand ist Wartezustand
			NextState = Delay else
		'0';
	-- gegen den Uhrzeigersinn
	CounterClockwiseRotation <=
		'1' when
			-- warten auf A-Flanke
			(CurrentState = WaitForRisingA or CurrentState = WaitForFallingA) and
			-- naechster Zustand ist Wartezustand
			NextState = Delay else
		'0';
end architecture ARotationDirectionDecoder;
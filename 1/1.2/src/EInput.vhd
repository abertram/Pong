library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EInput is
	generic (
		-- Warteperioden
		DelayPeriods: TDelayPeriods
	);
	port (
		Clock,
		Reset,
		ASignal,
		BSignal,
		EffectiveDirectionSwitch: in std_logic;
		Operand: out TVectorValue;
		DebugLED: out std_logic
	);
end entity EInput;

architecture AInput of EInput is
	signal
		CurrentASignal,
		CurrentBSignal,
		LastASignal,
		LastBSignal: std_logic;
	signal
		RotationDirection: TRotationDirection;
	signal
		CurrentState,
		NextState: TInputState;
	signal
		TmpOperand: TVectorValue;
	signal
		TmpDelayPeriods: TDelayPeriods;
begin
	-- Einsynchronisierung der Signale
	SynchronizeSignalsProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			CurrentASignal <= '0';
			LastASignal <= '0';
			CurrentBSignal <= '0';
			LastBSignal <= '0';
		elsif rising_edge(Clock) then
			CurrentASignal <= ASignal;
			LastASignal <= CurrentASignal;
			CurrentBSignal <= BSignal;
			LastBSignal <= CurrentBSignal;
		end if;
	end process SynchronizeSignalsProcess;

	-- Bestimmung der Drehrichtung
	RotationDirection <=
		-- im Uhrzeigersinn, wenn wir auf eine Flanke von Signal B warten
		-- und als naechstes in den Wartezustand wechseln
		Clockwise when (CurrentState = WaitForRisingB or CurrentState = WaitForFallingB) and (NextState = Delay) else
		-- gegen den Uhrzeigersinn, wenn wir auf eine Flanke von Signal A warten
		-- und als naechstes in den Wartezustand wechseln
		CounterClockwise when (CurrentState = WaitForRisingA or CurrentState = WaitForFallingA) and (NextState = Delay) else
		-- keine Drehung
		NoRotation;

	DebugLED <=
		'1' when CurrentState = Delay else
		'0';

	-- Bestimmung des Operanden
	OperandDeterminationProcess: process(RotationDirection, EffectiveDirectionSwitch)
	begin
		case RotationDirection is
			-- wir drehen im Uhrzeigersinn
			when Clockwise =>
				-- der Schalter ist unten
				if EffectiveDirectionSwitch = '0' then
					TmpOperand <= TVectorValue(to_signed(1, TVectorValue'Length));
				-- der Schalter ist oben
				elsif EffectiveDirectionSwitch = '1' then
					TmpOperand <= TVectorValue(to_signed(-1, TVectorValue'Length));
				else
					TmpOperand <= TVectorValue(to_signed(0, TVectorValue'Length));
				end if;
			-- wir drehen gegen den Uhrzeigersinn
			when CounterClockwise =>
				-- der Schalter ist unten
				if EffectiveDirectionSwitch = '0' then
					TmpOperand <= TVectorValue(to_signed(-1, TVectorValue'Length));
				-- der Schalter ist oben
				elsif EffectiveDirectionSwitch = '1' then
					TmpOperand <= TVectorValue(to_signed(1, TVectorValue'Length));
				else
					TmpOperand <= TVectorValue(to_signed(0, TVectorValue'Length));
				end if;
			when others =>
				TmpOperand <= TVectorValue(to_signed(0, TVectorValue'Length));
		end case;
	end process OperandDeterminationProcess;

	DelayProcess: process(Clock, CurrentState)
	begin
		if rising_edge(Clock) then
			if CurrentState = Delay then
				TmpDelayPeriods <= TmpDelayPeriods + 1;
			else
				TmpDelayPeriods <= 0;
			end if;
		end if;
	end process DelayProcess;

	-- State machine
	CurrentStateProcess: process(Clock, Reset, NextState)
	begin
		if Reset = '1' then
			CurrentState <= Init;
		elsif rising_edge(Clock) then
			CurrentState <= NextState;
		end if;
	end process CurrentStateProcess;

	NextStateProcess: process(CurrentState, LastASignal, CurrentASignal,
		LastBSignal, CurrentBSignal, TmpDelayPeriods)
	begin
		case CurrentState is
			when Init =>
				NextState <= WaitForAOrB;
			-- auf steigende oder fallende Flanke von Signal A oder B warten
			when WaitForAOrB =>
				-- steigende Flanke von Signal A
				if LastASignal = '0' and CurrentASignal = '1' then
					-- auf steigende Flanke von Signal B warten
					-- wir drehen im Uhrzeigersinn
					NextState <= WaitForRisingB;
				-- steigende Flanke von Signal B
				elsif LastBSignal = '0' and CurrentBSignal = '1' then
					-- auf steigende Flanke von Signal A warten
					-- wir drehen gegen den Uhrzeigersinn
					NextState <= WaitForRisingA;
				-- fallende Flanke von Signal A
				elsif LastASignal = '1' and CurrentASignal = '0' then
					-- auf fallende Flanke von Signal B warten
					-- wir drehen im Uhrzeigersinn
					NextState <= WaitForFallingB;
				-- fallende Flanke von Signal B
				elsif LastBSignal = '1' and CurrentBSignal = '0' then
					-- auf fallende Flanke von Signal A warten
					NextState <= WaitForFallingA;
				-- keine Flanke
				else
					NextState <= CurrentState;
				end if;
			-- nach der steigenden Flanke von Signal B warten wir auf steigende Flanke von Signal A
			-- wir drehen gegen den Uhrzeigersinn
			when WaitForRisingA =>
				-- steigende Flanke von Signal A
				if LastASignal = '0' and CurrentASignal = '1' then
					NextState <= Delay;
				else
					NextState <= CurrentState;
				end if;
			-- nach der steigenden Flanke von Signal A warten wir auf steigende Flanke von Signal B
			-- wir drehen im Uhrzeigersinn
			when WaitForRisingB =>
				-- steigende Flanke von Signal B
				if LastBSignal = '0' and CurrentBSignal = '1' then
					NextState <= Delay;
				else
					NextState <= CurrentState;
				end if;
			-- nach der fallenden Flanke von Signal B warten wir auf fallende Flanke von Signal A
			-- wir drehen gegen den Uhrzeigersinn
			when WaitForFallingA =>
				-- fallende Flanke von Signal A
				if LastASignal = '1' and CurrentASignal = '0' then
					NextState <= Delay;
				else
					NextState <= CurrentState;
				end if;
			-- nach der fallenden Flanke von Signal A warten wir auf fallende Flanke von Signal B
			-- wir drehen im Uhrzeigersinn
			when WaitForFallingB =>
				-- fallende Flanke von Signal B
				if LastBSignal = '1' and CurrentBSignal = '0' then
					NextState <= Delay;
				else
					NextState <= CurrentState;
				end if;
			-- warten
			when Delay =>
				if TmpDelayPeriods = (DelayPeriods - 1) then
					NextState <= WaitForAOrB;
				else
					NextState <= CurrentState;
				end if;
		end case;
	end process NextStateProcess;

	-- Ausgabe des Operanden
	OutputProcess: process(CurrentState, NextState, TmpOperand)
	begin
		if ((CurrentState = WaitForRisingA or CurrentState = WaitForRisingB or CurrentState = WaitForFallingA or CurrentState = WaitForFallingB)) and NextState = Delay  then
			Operand <= TmpOperand;
		else
			Operand <= TVectorValue(to_signed(0, TVectorValue'Length));
		end if;
	end process OutputProcess;
end architecture AInput;
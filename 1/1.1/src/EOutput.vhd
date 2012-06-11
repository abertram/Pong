library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EOutput is
	generic (
		GenericDisplayIndex: TDisplayIndex;
		MinValue,
		MaxValue: TVectorValue
	);
	port (
		Clock,
		Reset: in std_logic;
		PortDisplayIndex: TDisplayIndex;
		Operand: in TVectorValue;
		SevenSegmentVector0,
		SevenSegmentVector1,
		SevenSegmentVector2,
		SevenSegmentVector3: out TSevenSegmentVector;
		VectorValue: out TVectorValue
	);
end entity EOutput;

architecture AOutput of EOutput is
	signal
		CurrentState,
		NextState: TOutputState;
	signal
		-- Wert nach draussen
		OutputVectorValue,
		-- temporaerer Wert, der fuer die Zerlegung in Ziffern verwendet wird
		StripVectorValue: TVectorValue;
	signal
		-- aktuelle Ziffernposition in der zu zerlegenden Zahl
		DigitPosition: natural range 0 to 3;
	signal
		-- Ziffern
		Digits: TDigits;
begin

	-- Signale nach draussen
	VectorValue <= OutputVectorValue;
	SevenSegmentVector0 <= cSegmentCodes(Digits(3));
	SevenSegmentVector1 <= cSegmentCodes(Digits(2));
	SevenSegmentVector2 <= cSegmentCodes(Digits(1));
	SevenSegmentVector3 <= cSegmentCodes(Digits(0));

	-- Aktualisierung des Wertes
	UpdateValueProcess: process(Clock, Reset)
		variable
			TmpVectorValue: TVectorValue;
	begin
		if Reset = '1' then
			OutputVectorValue <= (others => '0');
		elsif rising_edge(Clock) then
			-- nur das richtige Display ansteuern
			if PortDisplayIndex = GenericDisplayIndex then
				-- neuen Wert berechnen
				TmpVectorValue := TVectorValue(signed(OutputVectorValue) + signed(Operand));
				-- sicherstellen, dass der Wert nicht zu gross wird
				if TmpVectorValue = TVectorValue(signed(MinValue) - to_signed(1, TVectorValue'length)) then
					OutputVectorValue <= MinValue;
				-- sicherstellen, dass der Wert nicht zu klein wird
				elsif TmpvectorValue = TVectorValue(signed(MaxValue) + to_signed(1, TVectorValue'length)) then
					OutputVectorValue <= MaxValue;
				else
					OutputVectorValue <= TmpvectorValue;
				end if;
			end if;
		end if;
	end process UpdateValueProcess;

	-- Prozess zum Zerlegen der Zahl in ziffern
	ComputeDigitsProcess: process(Clock, Reset)
		variable
			TmpDigits: TDigits;
	begin
		if Reset = '1' then
			Digits <= (others => 0);
		elsif rising_edge(Clock) then
			case CurrentState is
				-- Variablen, die zum Berechnen benoetigt werden, initialisieren
				when InitValue =>
					StripVectorValue <= OutputVectorValue;
					DigitPosition <= 0;
					TmpDigits := (others => 0);
				-- Zahl zerlegen
				when ComputeDigits =>
					-- wenn bei 0 angekommen, Ziffern aktualisieren
					if unsigned(StripVectorValue) = 0 then
							Digits <= TmpDigits;
					-- ueberpruefen, ob aktuelle Zahl groesser als der aktuelle Stellenwert ist
					elsif StripVectorValue >= TVectorValue(to_unsigned(cPlaceValues(DigitPosition), TVectorValue'length)) then
						-- aktuellen Stellenwert von der aktuellen Zahl abziehen
						StripVectorValue <= TVectorValue(unsigned(StripVectorValue) - to_unsigned(cPlaceValues(DigitPosition), TVectorValue'length));
						-- Zaehler hochzaehlen
						TmpDigits(DigitPosition) := TmpDigits(DigitPosition) + 1;
					else
						-- dafuer sorgen, dass die Ziffernposition nicht ueberlaeuft
						if DigitPosition < cPlaceValues'right then
							DigitPosition <= DigitPosition + 1;
						end if;
					end if;
			end case;
		end if;
	end process ComputeDigitsProcess;

	-- FSM
	CurrentStateProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			CurrentState <= InitValue;
		elsif rising_edge(Clock) then
			CurrentState <= NextState;
		end if;
	end process CurrentStateProcess;

	-- Sensitivitaetsliste ueberpruefen
	NextStateProcess: process(CurrentState, StripVectorValue)
	begin
		case CurrentState is
			when InitValue =>
				NextState <= ComputeDigits;
			when ComputeDigits =>
				if unsigned(StripVectorValue) = 0 then
					NextState <= InitValue;
				else
					NextState <= CurrentState;
				end if;
		end case;
	end process NextStateProcess;
end architecture AOutput;

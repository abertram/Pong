------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: EAdder
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Bekommt einen Operanden am Eingang und verknüpft ihn mit einer internen
-- Binärzahl. Das Ergebnis wird mittels zweier Generics auf einen minimalen
-- und maximalen Wert ueberprueft und nach aussen gefuehrt.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EAdder is
	generic (
		-- minimaler Wert
		MinValue,
		-- maximaler Wert
		MaxValue: TVectorValue
	);
	port (
		Clock,
		Reset: in std_logic;
		Operand: in TVectorValue;
		Result: out TVectorValue
	);
end entity EAdder;

architecture AAdder of EAdder is
	-- temporaeres signal fuer die Ausgabe
	signal
		OutputVectorValue: TVectorValue;
begin
	AddProcess: process(Clock, Reset)
		-- temporaere Variable fuer die Berechnung
		variable
			TmpVectorValue: TVectorValue;
	begin
		if Reset = '1' then
			OutputVectorValue <= MinValue;
		elsif rising_edge(Clock) then
			-- neuen Wert berechnen
			TmpVectorValue := TVectorValue(signed(OutputVectorValue) + signed(Operand));
			-- sicherstellen, dass der Wert nicht zu klein wird
			if TmpVectorValue = TVectorValue(signed(MinValue) - to_signed(1, TVectorValue'length)) then
				OutputVectorValue <= MinValue;
			-- sicherstellen, dass der Wert nicht zu gross wird
			elsif TmpvectorValue = TVectorValue(signed(MaxValue) + to_signed(1, TVectorValue'length)) then
				OutputVectorValue <= MaxValue;
			else
				OutputVectorValue <= TmpvectorValue;
			end if;
		end if;
	end process AddProcess;
	Result <= OutputVectorValue;
end architecture AAdder;
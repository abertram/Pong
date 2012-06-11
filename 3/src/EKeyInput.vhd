------------------------------------------------------------------------------
-- VHDL Praktikum
--
-- Aufgabe 1: Ein- / Ausgabemodul
-- Entity: EInput
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Es werden zwei Tastensignale als Eingangssignale entgegen genommen und
-- einsynchronisiert. Anhand der Tasten wird ein Operand bestimmt und als
-- Ausgangssignal ausgegeben.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EKeyInput is
	port (
		Clock,
		Reset,
		Key0,
		Key1: in std_logic;
		Key0Pressed,
		Key1Pressed: out std_logic
	);
end entity EKeyInput;

architecture AKeyInput of EKeyInput is
	signal
		CurrentKey0,
		LastKey0,
		CurrentKey1,
		LastKey1: std_logic;
begin
	-- Einsynchronisierung der Tasten
	SynchronizeKeysProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			CurrentKey0 <= '1';
			LastKey0 <= '1';
			CurrentKey1 <= '1';
			LastKey1 <= '1';
		elsif rising_edge(Clock) then
			CurrentKey0 <= Key0;
			LastKey0 <= CurrentKey0;
			CurrentKey1 <= Key1;
			LastKey1 <= CurrentKey1;
		end if;
	end process SynchronizeKeysProcess;

	Key0Pressed <=
		-- positiv, wenn fallende Flanke von Taste 0
		'1' when (LastKey0 = '1' and CurrentKey0 = '0') else
		'0';
	Key1Pressed <=
		-- negativ, wenn fallende Flanke von Taste 1
		'1' when (LastKey1 = '1' and CurrentKey1 = '0') else
		'0';
end architecture AKeyInput;
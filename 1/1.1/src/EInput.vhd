------------------------------------------------------------------------------
-- VHDL Praktikum
--
-- Aufgabe 1.1: Ein- / Ausgabemodul 1
-- Entity: EInput
--
-- Beschreibung:
--   Es werden vier Tasten als Eingangssignale entgegen genommen und
--   einsynchronisiert. Anhand der Tasten wird ein Operand bestimmt und
--   Signal ausgegeben.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EInput is
	port (
		Clock,
		Reset,
		Key0,
		Key1,
		Key2,
		Key3: in std_logic;
		DisplayIndex: out TDisplayIndex;
		Operand: out TVectorValue
	);
end entity EInput;

architecture AInput of EInput is
	signal
		CurrentKeyVector,
		LastKeyVector: TKeyVector;
	signal
		Key3Down,
		Key2Down,
		Key1Down,
		Key0Down: boolean;
begin
	-- Einsynchronisierung der Tasten
	SynchronizeKeysProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			CurrentKeyVector <= (others => '1');
			LastKeyVector <= (others => '1');
		elsif rising_edge(Clock) then
			CurrentKeyVector <= Key3 & Key2 & Key1 & Key0;
			LastKeyVector <= CurrentKeyVector;
		end if;
	end process SynchronizeKeysProcess;

	-- Bestimmung, welche Taste gedrueckt wurde
	Key3Down <= (CurrentKeyVector(3) = '0') and (LastKeyVector(3) = '1');
	Key2Down <= (CurrentKeyVector(2) = '0') and (LastKeyVector(2) = '1');
	Key1Down <= (CurrentKeyVector(1) = '0') and (LastKeyVector(1) = '1');
	Key0Down <= (CurrentKeyVector(0) = '0') and (LastKeyVector(0) = '1');

	-- Bestimmung der Displaynummer
	DisplayIndex <=
		0 when (Key1Down or Key0Down) else
		1 when (Key3Down or Key2Down) else
		-1;

	-- Bestimmung des Operanden: -1, 0, +1
	Operand <=
		TVectorValue(to_signed(+1, TVectorValue'Length)) when (Key2Down or Key0Down) else
		TVectorValue(to_signed(-1, TVectorValue'Length)) when (Key3Down or Key1Down) else
		TVectorValue(to_signed(0, TVectorValue'Length));
end architecture AInput;
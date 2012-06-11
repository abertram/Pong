------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: ESchiftRegister
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Ein Schieberegister mir generischer Breite und Schiebeweite. Die
-- Schieberichtung ist per Signal einstellbar.
------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;

entity EShiftRegister is
	generic (
		-- Breite des Registers
		Width: natural;
		-- Schiebeweite
		ShiftWidth: natural := 1
	);
	port (
		Clock, -- Takt
		Reset, -- Reset
		Enable, -- Schieben ein- / ausschalten
		ShiftDirection, -- Schieberichtung
		Input: in std_logic; -- Eingabe
		Output: out std_logic_vector(Width - 1 downto 0) -- Ausgabe
	);
end entity EShiftRegister;

architecture AShiftRegister of EShiftRegister is
signal
	TmpOutput: std_logic_vector(Width - 1 downto 0);
begin
	-- Ausgabesignal
	Output <= TmpOutput;

	-- Schiebeprozess
	ShiftProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			TmpOutput <= (others => '0');
		elsif rising_edge(Clock) then
			if Enable = '1' then
				if ShiftDirection = '0' then
					-- links schieben
					TmpOutput <= TmpOutput(Width - ShiftWidth - 1 downto 0) & Input;
				else
					-- rechts schieben
					TmpOutput <= Input & TmpOutput(Width - 1 downto ShiftWidth);
				end if;
			end if;
		end if;
	end process ShiftProcess;
end architecture AShiftRegister;
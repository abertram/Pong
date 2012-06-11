------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: EDebouncer
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Enprellt ein Signal mit Hilfe eines zweistelligen Schieberegisters. Wenn
-- die Werte im Schieberegister unterschiedlich sind, wird das Schieberegister
-- fuer eine per Generic festgelegte Zeit, die in Systemtakten gemessen wird,
-- ausgeschaltet.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use work.Types.all;

entity EDebouncer is
	generic (
		-- Wartezeit
		DelayPeriods: TClockPeriods
	);
	port (
		Clock,
		Reset,
		Input: in std_logic;
		Output: out std_logic
	);
end entity EDebouncer;

architecture ADebouncer of EDebouncer is
	-- Steuersignale
	signal
		DelayEnable,
		CountLimitReached,
		ShiftEnable: std_logic;
	signal
		OutputVector: std_logic_vector(cDebouncerShiftRegisterWidth - 1 downto 0);

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

	-- Zaehler
	component EClockCounter is
		generic (
			-- Zaehlgrenze
			CountLimit: TClockPeriods
		);
		port (
			Clock,
			Reset,
			Enable: in std_logic;
			CountLimitReached: out std_logic
		);
	end component EClockCounter;
begin
	-- Schieberegister
	ShiftRegister: EShiftRegister
		generic map (
			cDebouncerShiftRegisterWidth
		)
		port map (
			Clock,
			Reset,
			ShiftEnable,
			-- links schieben
			'0',
			Input,
			OutputVector
		);

	-- Taktzaehler
	ClockCounter: EClockCounter
		generic map (
			-- Wartezeit
			DelayPeriods
		)
		port map (
			Clock,
			Reset,
			DelayEnable,
			CountLimitReached
		);

	-- Zaehler ein- / auszuschalten
	DelayEnable <= (
		-- Flanke
		OutputVector(1) xor OutputVector(0)) and
		-- Zaehlgrenze wurde noch nicht erreicht
		not CountLimitReached;
	-- Shieberegister ein- / ausschalten
	-- immer schieben, wenn nicht gezaehtl / gewartet wird
	ShiftEnable <= not DelayEnable;

	-- Ausgangssignal
	Output <= OutputVector(0);
end architecture ADebouncer;
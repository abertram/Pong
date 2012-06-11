------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: EGameState
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Berechnet den aktuellen Spielstatus
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
use work.Types.all;

entity EGameState is
	port (
		Clock,
		Reset,
		LeftPlayerKey,
		RightPlayerKey: in std_logic;
		LeftPlayerScore,
		RightPlayerScore: in TScore;
		GameState: out TGameState
	);
end entity EGameState;

architecture AGameState of EGameState is
	signal
		CurrentState,
		NextState: TGameState;
begin
	-- State machine
	CurrentStateProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			CurrentState <= Init;
		elsif rising_edge(Clock) then
			CurrentState <= NextState;
		end if;
	end process CurrentStateProcess;

	NextStateProcess: process(CurrentState, LeftPlayerKey, RightPlayerKey, LeftPlayerScore, RightPlayerScore)
	begin
		case CurrentState is
			-- Startzustand
			when Init =>
				NextState <= LeftPlayerStart;
			-- linker Spieler soll beginnen
			when InitLeftPlayer =>
				NextState <= LeftPlayerStart;
			-- rechter Spieler soll beginnen
			when InitRightPlayer =>
				NextState <= RightPlayerStart;
			-- linker Spieler beginnt
			when LeftPlayerStart =>
				-- auf Tastensignal warten
				if LeftPlayerKey = '1' then
					NextState <= Play;
				else
					NextState <= CurrentState;
				end if;
			-- rechter Spieler beginnt
			when RightPlayerStart =>
				-- auf Tastensignal warten
				if RightPlayerKey = '1' then
					NextState <= Play;
				else
					NextState <= CurrentState;
				end if;
			-- Spiel läuft
			when Play =>
				-- Tastendruck vom linken Spieler
				if LeftPlayerKey = '1' then
					NextState <= LeftPlayerBreak;
				-- Tastendruck vom rechten Spieler
				elsif RightPlayerKey = '1' then
					NextState <= RightPlayerBreak;
				-- Spiel zu Ende
				elsif LeftPlayerScore = TScore'high or RightPlayerScore = TScore'high then
					NextState <= GameOver;
				else
					NextState <= CurrentState;
				end if;
			-- Pause vom linken Spieler
			when LeftPlayerBreak =>
				if LeftPlayerKey = '1' then
					NextState <= Play;
				else
					NextState <= CurrentState;
				end if;
			-- Pause vom Rechten Spieler
			when RightPlayerBreak =>
				if RightPlayerKey = '1' then
					NextState <= Play;
				else
					NextState <= CurrentState;
				end if;
			-- Spiel zu Ende
			when GameOver =>
				-- linker Spieler soll anfangen
				if LeftPlayerScore = TScore'high and LeftPlayerKey = '1' then
					NextState <= InitLeftPlayer;
				-- rechter Spieler soll anfangen
				elsif RightPlayerScore = TScore'high and RightPlayerKey = '1' then
					NextState <= InitRightPlayer;
				else
					NextState <= CurrentState;
				end if;
		end case;
	end process NextStateProcess;

	GameState <= CurrentState;
end architecture AGameState;
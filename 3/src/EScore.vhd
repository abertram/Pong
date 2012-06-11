------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: EScore
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Berechnet den aktuellen Spielstand.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
use work.Types.all;

entity EScore is
	port (
		Clock,
		Reset,
		Enable,
		ResetScore: in std_logic;
		BallLeftOutside,
		BallRightOutside: in boolean;
		LeftPlayerScore,
		RightPlayerScore: out TScore
	);
end entity EScore;

architecture AScore of EScore is
	signal
		TmpLeftPlayerScore,
		TmpRightPlayerScore: TScore;
begin
	process(Clock, Reset, ResetScore)
	begin
		-- Punkte resetten
		if (Reset or ResetScore) = '1' then
			TmpLeftPlayerScore <= 0;
			TmpRightPlayerScore <= 0;
		elsif rising_edge(Clock) then
			-- Spiel läuft
			if Enable = '1' then
				-- Ball ist links im Aus
				if BallLeftOutside then
					if TmpRightPlayerScore < TScore'high then
						TmpRightPlayerScore <= TmpRightPlayerScore + 1;
					else
						TmpRightPlayerScore <= 0;
					end if;
				-- Ball ist rechts im Aus
				elsif BallRightOutside then
					if TmpLeftPlayerScore < TScore'high then
						TmpLeftPlayerScore <= TmpLeftPlayerScore + 1;
					else
						TmpLeftPlayerScore <= 0;
					end if;
				end if;
			end if;
		end if;
	end process;
	LeftPlayerScore <= TmpLeftPlayerScore;
	RightPlayerScore <= TmpRightPlayerScore;
end architecture AScore;
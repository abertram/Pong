------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 2: EVGASignal
-- Entity: EVGASync
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Erzeugt die Signale für die VGA-Synchronisation.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use work.Types.all;

entity EVGASync is
	generic (
		-- Horizontale Signale (Anzahl der Takte)
		HSyncLength: THSyncLength;
		HBackPorchLength: THBackPorchLength;
		HDisplayIntervalLength: THDisplayIntervalLength;
		HFrontPorchLength: THFrontPorchLength;
		-- Vertikale Signale (Anzahl der Zeilen)
		VSyncLength: TVSyncLength;
		VBackPorchLength: TVBackPorchLength;
		VDisplayIntervalLength: TVDisplayIntervalLength;
		VFrontPorchLength: TVFrontPorchLength
	);
	port (
		Clock,
		Reset: in std_logic;
		HSync,
		HBlank,
		VSync,
		VBlank: out std_logic;
		X: out TXposition;
		Y: out TYPosition
	);
end entity EVGASync;

architecture AVGASync of EVGASync is
	signal
		HCounter: THCounter;
	signal
		VCounter: TVCounter;
	signal
		TmpHBlank,
		TmpVBlank: std_logic;
	signal
		TmpX: TXPosition;
	signal
		TmpY: TYPosition;
begin
	-- Pixelzähler
	HCountProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			HCounter <= 0;
		elsif rising_edge(Clock) then
			if HCounter < (HSyncLength +  HBackPorchLength + HDisplayIntervalLength + HFrontPorchLength - 1) then
				HCounter <= HCounter + 1;
				-- X-Koordinate berechnen
				if TmpHBlank = '1' then
					TmpX <= TmpX + 1;
				else
					TmpX <= 0;
				end if;
			else
				HCounter <= 0;
			end if;
		end if;
	end process HCountProcess;

	HSync <=
		'0' when (HCounter < HSyncLength) else
		'1';
	TmpHBlank <=
		'1' when HCounter >= HSyncLength + HBackPorchLength and HCounter < HSyncLength + HBackPorchLength + HDisplayIntervalLength else
		'0';
	HBlank <= TmpHBlank;
	X <= TmpX;

	-- Zeilenzähler
	VCountProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			VCounter <= 0;
		elsif rising_edge(Clock) then
			-- neue Zeile
			if HCounter = (HSyncLength +  HBackPorchLength + HDisplayIntervalLength + HFrontPorchLength - 1) then
				if VCounter < (VSyncLength +  VBackPorchLength + VDisplayIntervalLength + VFrontPorchLength - 1) then
					VCounter <= VCounter + 1;
					-- Y-Koordinate berechnen
					if TmpVBlank = '1' then
						TmpY <= TmpY + 1;
					else
						TmpY <= 0;
					end if;
				else
					VCounter <= 0;
				end if;
			end if;
		end if;
	end process VCountProcess;

	VSync <=
		'0' when (VCounter < VSyncLength) else
		'1';
	TmpVBlank <=
		'1' when VCounter >= VSyncLength + VBackPorchLength and VCounter < VSyncLength + VBackPorchLength + VDisplayIntervalLength else
		'0';
	VBlank <= TmpVBlank;
	Y <= TmpY;
end architecture AVGASync;

------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 2: EVGASignal
-- Entity: TBVGASync
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Testbench für die EVGASync. Sichert mit Asserts das richtige Timing in die
-- horizontale und in die vertikale Richtung.
-- Simulationszeit: 35ms
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use work.Types.all;

entity TBVGASync is
end TBVGASync;

architecture AVGASync of TBVGASync is
	signal
		SClock,
		SClock25MHz,
		SReset,
		SHSync,
		SHBlank,
		SVSync,
		SVBlank: std_logic;
	signal
		CurrentTime,
		HMeanTime,
		VMeanTime: time;

	-- Frequenzteiler
	component EClockDivider is
		generic (
			Divisor: positive
		);
		port (
			Clock,
			Reset: in std_logic;
			DividedClock: out std_logic
		);
	end component EClockDivider;

	-- VGA-Sync
	component EVGASync is
		generic (
			HSyncLength: THSyncLength;
			HBackPorchLength: THBackPorchLength;
			HDisplayIntervalLength: THDisplayIntervalLength;
			HFrontPorchLength: THFrontPorchLength;
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
			VBlank: out std_logic
		);
	end component EVGASync;
begin
	-- Freuqenzteiler
	ClockDivider: EClockDivider
		generic map (
			2
		)
		port map (
			SClock,
			SReset,
			SClock25MHz
		);

	-- VGA-Sync
	VGASync: EVGASync
		generic map (
			cHSyncClockPeriods,
			cHBackPorchClockPeriods,
			cHDisplayIntervalClockPeriods,
			cHFrontPorchClockPeriods,
			cVSyncLineCount,
			cVBackPorchLineCount,
			cVDisplayIntervalLineCount,
			cVFrontPorchLineCount
		)
		port map (
			SClock25MHz,
			SReset,
			SHSync,
			SHBlank,
			SVSync,
			SVBlank
		);

	-- Takt-Erzeuger
	ClockProcess: process
	begin
		SClock <= '1';
		wait for cClockPeriod / 2;
		SClock <= '0';
		wait for cClockPeriod / 2;
	end process ClockProcess;

	-- Berechnet die aktuelle Zeit
	CurrentTimeProcess: process(SClock, SReset)
	begin
		if SReset = '1' then
			CurrentTime <= 0 ns;
		elsif rising_edge(SClock) then
			CurrentTime <= CurrentTime + cClockPeriod;
		end if;
	end process CurrentTimeProcess;

	-- Reset
	ResetProcess: process
	begin
		SReset <= '1';
		wait for cClockPeriod;

		SReset <= '0';
		wait for cClockPeriod;

		wait;
	end process ResetProcess;

	-- sichert das horizontale Timing zu
	HAssertsProcess: process
	begin
		wait until SHSync'event and SHSync'last_value = '1' and SHSync = '0';
		HMeanTime <= CurrentTime;
		wait until SClock25MHz = '1' and SHSync'event and SHSync'last_value = '0' and SHSync = '1';
		assert(CurrentTime - HMeanTime = cHSyncLength) report "Horizontal Sync";
		HMeanTime <= CurrentTime;
		wait until SHBlank'event and SHBlank'last_value = '0' and SHBlank = '1';
		assert(CurrentTime - HMeanTime = cHBackPorchLength) report "Horizontal Back Porch (" & time'image(CurrentTime - HMeanTime) & ", " & time'image(cHBackPorchLength) & ")";
		HMeanTime <= CurrentTime;
		wait until SHBlank'event and SHBlank'last_value = '1' and SHBlank = '0';
		assert(CurrentTime - HMeanTime = cHDisplayIntervalLength) report "Horizontal Display Interval";
		HMeanTime <= CurrentTime;
		wait until SHSync'event and SHBlank'last_value = '1' and SHBlank = '0';
		assert(CurrentTime - HMeanTime = cHFrontPorchLength) report "Horizontal Front Porch";
	end process HAssertsProcess;

	-- sichert das vertikale Timing zu
	VAssertsProcess: process
	begin
		wait until SVSync'event and SVSync = '0' and SVSync'last_value = '1';
		VMeanTime <= CurrentTime;
		wait until SVSync'event and SVSync = '1';
		assert(CurrentTime - VMeanTime = cVSyncLength) report "Vertical Sync";
		VMeanTime <= CurrentTime;
		wait until SVBlank'event and SVBlank = '1';
		assert(CurrentTime - VMeanTime = cVBackPorchLength) report "Vertical Back Porch(" & time'image(CurrentTime - VMeanTime) & " | " & time'image(cVFrontPorchLength) & ")";
		VMeanTime <= CurrentTime;
		wait until SVBlank'event and SVBlank = '0';
		assert(CurrentTime - VMeanTime = cVDisplayIntervalLength) report "Vertical Display Interval";
		VMeanTime <= CurrentTime;
		wait until SVSync'event and SVBlank = '0';
		assert(CurrentTime - VMeanTime = cVFrontPorchLength) report "Vertical Front Porch(" & time'image(CurrentTime - VMeanTime) & " | " & time'image(cVFrontPorchLength) & ")";
	end process VAssertsProcess;
end architecture AVGASync;
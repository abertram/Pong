------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: EEncoderInput
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Bindet einen Drehrichtungsdecoder ein und berechnet anhand dessen
-- Ausgnagssignale einen Operanden.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EEncoderInput is
	generic (
		-- positiver Operand
		PlusOperand,
		-- negativer Operand
		MinusOperand: TVectorValue
	);
	port (
		Clock,
		Reset,
		ASignal,
		BSignal,
		EffectiveDirectionSwitch: in std_logic;
		Operand: out TVectorValue
	);
end entity EEncoderInput;

architecture AEncoderInput of EEncoderInput is
	-- Drehrichtung
	signal
		ClockwiseRotation,
		CounterClockwiseRotation: std_logic;

	-- Drehrichtungdecoder
	component ERotationDirectionDecoder is
		port (
			Clock,
			Reset,
			ASignal,
			BSignal: in std_logic;
			ClockwiseRotation,
			CounterClockwiseRotation: out std_logic
		);
	end component ERotationDirectionDecoder;
begin
	-- Drehrichtungdecoder
	RotationDirectionDecoder: ERotationDirectionDecoder
		port map (
			Clock,
			Reset,
			ASignal,
			BSignal,
			ClockwiseRotation,
			CounterClockwiseRotation
		);

	-- Bestimmung des Operanden
	Operand <=
		-- positiv
		PlusOperand when
			-- Uhrzeigersinn und Schalter unten
			(ClockwiseRotation = '1' and EffectiveDirectionSwitch = '0') or
			-- gegen den Uhrzeigersinn und Schalter oben
			(CounterClockwiseRotation = '1' and EffectiveDirectionSwitch = '1') else
		-- negativ
		MinusOperand when
			-- gegen den Uhrzeigersinn und Schalter unten
			(CounterClockwiseRotation = '1' and EffectiveDirectionSwitch = '0') or
			-- Uhrzeigersinn und Schalter oben
			(ClockwiseRotation = '1' and EffectiveDirectionSwitch = '1') else
		-- sonst
		TVectorValue(to_signed(0, TVectorValue'Length));
end architecture AEncoderInput;
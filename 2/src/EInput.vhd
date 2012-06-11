------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 1: EIOModul
-- Entity: EInput
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Ein Wrapper fuer die Komponenten EKeyInput und EEncoderInput. Berechnet
-- anhand deren Ausgangssignale den endgueltigen Operanden.
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
		ASignal,
		BSignal,
		EffectiveDirectionSwitch: in std_logic;
		Operand: out TVectorValue
	);
end entity EInput;

architecture AInput of EInput is
	signal
		KeyOperand,
		EncoderOperand: TVectorValue;

	-- Eingabe per Tastendruck
	component EKeyInput is
		generic (
			PlusOperand,
			MinusOperand: TVectorValue
		);
		port (
			Clock,
			Reset,
			Key0,
			Key1: in std_logic;
			Operand: out TVectorValue
		);
	end component EKeyInput;

	-- Eingabe per Drehencoder
	component EEncoderInput is
		generic (
			PlusOperand,
			MinusOperand: TVectorValue
		);
		port (
			Clock,
			Reset,
			ASignal,
			BSignal,
			EffectiveDirectionSwitch: std_logic;
			Operand: out TVectorValue
		);
	end component EEncoderInput;
begin
	-- endgueltige Operand
	Operand <=
		-- Operand der Tastenkomponente, wenn Encoderoperand = 0
		KeyOperand when EncoderOperand = TVectorValue(to_signed(0, TVectorValue'Length)) else
		-- Operand der Encoderkomponente, wenn Tastenoperand = 0
		EncoderOperand when KeyOperand = TVectorValue(to_signed(0, TVectorValue'Length)) else
		-- sonst 0
		TVectorValue(to_signed(0, TVectorValue'Length));

	-- Eingabe per Tastendruck
	KeyInput: EKeyInput
		generic map (
			TVectorValue(to_signed(+4, TVectorValue'Length)),
			TVectorValue(to_signed(-4, TVectorValue'Length))
		)
		port map (
			Clock,
			Reset,
			Key0,
			Key1,
			KeyOperand
		);

	-- Eingabe per Drehencoder
	EncoderInput: EEncoderInput
		generic map (
			TVectorValue(to_signed(+5, TVectorValue'Length)),
			TVectorValue(to_signed(-5, TVectorValue'Length))
		)
		port map (
			Clock,
			Reset,
			ASignal,
			BSignal,
			EffectiveDirectionSwitch,
			EncoderOperand
		);
end architecture;
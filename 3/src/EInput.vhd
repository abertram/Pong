------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: EInput
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Kapselt die Eingabekomponenten.
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
		ASignal0,
		BSignal0,
		ASignal1,
		BSignal1,
		EffectiveDirectionSwitch0,
		EffectiveDirectionSwitch1: in std_logic;
		Key0Pressed,
		Key1Pressed: out std_logic;
		VectorValue0,
		VectorValue1: out TVectorValue
	);
end entity EInput;

architecture AInput of EInput is
	signal
		SOperand0,
		SOperand1: TVectorValue;

	component EEncoderInput is
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
	end component EEncoderInput;

	component EAdder is
		generic (
			-- minimaler Wert
			MinValue,
			-- maximaler Wert
			MaxValue: TVectorValue
		);
		port (
			Clock,
			Reset: in std_logic;
			Operand: in TVectorValue;
			Result: out TVectorValue
		);
	end component EAdder;

	component EKeyInput is
		port (
			Clock,
			Reset,
			Key0,
			Key1: in std_logic;
			Key0Pressed,
			Key1Pressed: out std_logic
		);
	end component EKeyInput;
begin
	EncoderInput0: EEncoderInput
		generic map (
			TVectorValue(to_signed(+10, TVectorValue'Length)),
			TVectorValue(to_signed(-10, TVectorValue'Length))
		)
		port map (
			Clock,
			Reset,
			ASignal0,
			BSignal0,
			EffectiveDirectionSwitch0,
			SOperand0
		);

	EncoderInput1: EEncoderInput
		generic map (
			TVectorValue(to_signed(+10, TVectorValue'Length)),
			TVectorValue(to_signed(-10, TVectorValue'Length))
		)
		port map (
			Clock,
			Reset,
			ASignal1,
			BSignal1,
			EffectiveDirectionSwitch1,
			SOperand1
		);

	Adder0: EAdder
		generic map (
			-- minimaler Wert
			TVectorValue(to_signed(0, TVectorValue'length)),
			-- maximaler Wert
			TVectorValue(to_signed(TScreenHeight'high - TRacketHeight'high, TVectorValue'length))
		)
		port map (
			Clock,
			Reset,
			SOperand0,
			VectorValue0
		);

	Adder1: EAdder
		generic map (
			-- minimaler Wert
			TVectorValue(to_signed(0, TVectorValue'length)),
			-- maximaler Wert
			TVectorValue(to_signed(TScreenHeight'high - TRacketHeight'high, TVectorValue'length))
		)
		port map (
			Clock,
			Reset,
			SOperand1,
			VectorValue1
		);

	KeyInput: EKeyInput
		port map (
			Clock,
			Reset,
			Key0,
			Key1,
			Key0Pressed,
			Key1Pressed
		);
end architecture AInput;
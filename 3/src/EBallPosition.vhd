------------------------------------------------------------------------------
-- VHDL Praktikum SS08
--
-- Aufgabe 3: EPong
-- Entity: EBallPosition
--
-- Autor: Alexander Bertram (tinf2616)
--
-- Beschreibung:
-- Berechnet die aktuelle Ballposition, -richtung und -geschwindigkeit.
------------------------------------------------------------------------------
library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Types.all;

entity EBallPosition is
	generic (
		BallDiameter: TBallDiameter;
		-- Startposition
		InitX: TXPosition;
		InitY: TYPosition;
		-- Bildschirmmaße
		ScreenWidth: TScreenWidth;
		ScreenHeight: TScreenHeight;
		-- Schlägermaße
		RacketWidth: TRacketWidth;
		RacketHeight: TRacketHeight;
		-- Startrichtung
		InitXMotionVector: TXMotionVector;
		InitYMotionVector: TYMotionVector;
		-- Anzahl der Schlägerkontakte, um den Ball zu beschleunigen
		RacketContactCountToIncrementXMotion: TRacketContactCountToIncrementXMotion;
		-- Anzahl Wandkontakte, um den Ball zu beschleunigen
		FieldEdgeContactCountToIncrementYMotion: TFieldEdgeContactCountToIncrementYMotion;
		-- Anzahl Punkte, um die Startgeschwindigkeit zu erhöhen
		ScoreToIncrementInitMotion: TScoreToIncrementInitMotion
	);
	port (
		Clock,
		Reset,
		UpdatePositionEnable,
		ResetBall: in std_logic;
		RightRacketY,
		LeftRacketY: in TYPosition;
		X: out TXPosition;
		Y: out TYPosition;
		BallLeftOutside,
		BallRightOutside: out boolean
	);
end entity EBallPosition;

architecture ABallPosition of EBallPosition is
	signal
		CurrentState,
		NextState: TBallPositionState;
	signal
		dx: TXMotionVector;
	signal
		dy: TYMotionVector;
	signal
		TmpX: TXPosition;
	signal
		TmpY: TYPosition;
	signal
		TmpBallLeftOutside,
		TmpBallRightOutside,
		BallInsideLeftRacket,
		BallInsideRightRacket,
		BallOnLeftFieldEdge,
		BallOnRightFieldEdge,
		BallOnTopFieldEdge,
		BallOnBottomFieldEdge: boolean;
	signal
		RacketContactCounter: TRacketContactCountToIncrementXMotion;
	signal
		FieldEdgeContactCounter: TFieldEdgeContactCountToIncrementYMotion;
	signal
		ScoreCounter: TScoreToIncrementInitMotion;
begin
	-- State machine
	CurrentStatePocess: process(Clock, Reset)
	begin
		if Reset = '1' then
			CurrentState <= Init;
		elsif rising_edge(Clock) then
			CurrentState <= NextState;
		end if;
	end process CurrentStatePocess;

	NextStateProcess: process(CurrentState, UpdatePositionEnable, ResetBall)
	begin
		case CurrentState is
			when Init =>
				NextState <= Delay;
			when UpdatePosition =>
				if ResetBall = '1' then
					NextState <= Init;
				else
					NextState <= UpdateMotionVectors;
				end if;
			when UpdateMotionVectors =>
				if ResetBall = '1' then
					NextState <= Init;
				else
					NextState <= Delay;
				end if;
			when Delay =>
				if ResetBall = '1' then
					NextState <= Init;
				elsif UpdatePositionEnable = '1' then
					NextState <= UpdatePosition;
				else
					NextState <= CurrentState;
				end if;
		end case;
	end process NextStateProcess;

	-- Berechnet die neue Ballposition
	UpdatePositionProcess: process(Clock, Reset)
	begin
		if Reset = '1' then
			TmpX <= 0;
			TmpY <= 0;
		elsif rising_edge(Clock) then
			case CurrentState is
				-- Startwerte beim Spielstart
				when Init =>
					TmpX <= InitX;
					TmpY <= InitY;
					-- Zähler initialisieren
					RacketContactCounter <= 0;
					FieldEdgeContactCounter <= 0;
					ScoreCounter <= 0;
				when UpdatePosition =>
					-- Ball im Aus?
					if TmpBallLeftOutside or TmpBallRightOutside then
						-- Startwerte nach einem Punkt
						TmpX <= InitX;
						TmpY <= InitY;
					else
						-- Ballposition aktualisieren
						-- neue Position des Balles auf der x-Achse auf dem rechten Schläger?
						if (TmpX + dx) > (TXPosition'high - RacketWidth - BallDiameter) then
							-- Ball auf der y-Achse innerhalb des Schlägers?
							if BallInsideRightRacket then
								-- Ball links am Schläger positionieren (keine Überschneidung mit dem Schläger)
								TmpX <= TXPosition'high - RacketWidth - BallDiameter;
							else
								-- Ball mit der rechten "Kante" im Aus positionieren
								TmpX <= TXPosition'high - RacketWidth - BallDiameter + 1;
								-- Zähler initialisieren
								RacketContactCounter <= 0;
								FieldEdgeContactCounter <= 0;
							end if;
						-- mit dem linken Schläger analog zum rechten verfahren
						elsif (TmpX + dx) < (RacketWidth) then
							if BallInsideLeftRacket then
								TmpX <= RacketWidth;
							else
								TmpX <= RacketWidth - 1;
							end if;
						else
							TmpX <= TmpX + dx;
						end if;

						-- mit der oberen und der unteren Kante analog zu den Schlägern verfahren
						if (TmpY + dy) < TYPosition'low then
							TmpY <= TYPosition'low;
						elsif (TmpY + dy) > (TYPosition'high - BallDiameter) then
							TmpY <= TYPosition'high - BallDiameter;
						else
							TmpY <= TmpY + dy;
						end if;
					end if;

					-- Schlägerkontakte zählen
					if (BallOnLeftFieldEdge and BallInsideLeftRacket) or (BallOnRightFieldEdge and BallInsideRightRacket) then
						if RacketContactCounter < RacketContactCountToIncrementXMotion then
							RacketContactCounter <= RacketContactCounter + 1;
						end if;
					else
						if RacketContactCounter = RacketContactCountToIncrementXMotion then
							RacketContactCounter <= 0;
						end if;
					end if;
					-- Wandkontakte zählen
					if BallOnTopFieldEdge or BallOnBottomFieldEdge then
						if FieldEdgeContactCounter < FieldEdgeContactCountToIncrementYMotion then
							FieldEdgeContactCounter <= FieldEdgeContactCounter + 1;
						end if;
					else
						if FieldEdgeContactCounter = FieldEdgeContactCountToIncrementYMotion then
							FieldEdgeContactCounter <= 0;
						end if;
					end if;
					-- Punkte zählen
					if TmpBallLeftOutside or TmpBallRightOutside then
						if ScoreCounter < ScoreToIncrementInitMotion then
							ScoreCounter <= ScoreCounter + 1;
						end if;
					else
						if ScoreCounter = ScoreToIncrementInitMotion then
							ScoreCounter <= 0;
						end if;
					end if;
				when others =>
					null;
			end case;
		end if;
	end process UpdatePositionProcess;

	-- Zwischenwerte speichern
	AssignProcess: process(Clock, Reset)
	begin
		if rising_edge(Clock) then
			if CurrentState = Init then
				TmpBallLeftOutside <= false;
				TmpBallRightOutside <= false;
			else
				TmpBallLeftOutside <= TmpX < RacketWidth;
				TmpBallRightOutside <= (TmpX + BallDiameter + RacketWidth) > TXPosition'high;
				BallInsideLeftRacket <= (TmpY < LeftRacketY + RacketHeight) and (TmpY + BallDiameter >= LeftRacketY);
				BallInsideRightRacket <= (TmpY < RightRacketY + RacketHeight) and (TmpY + BallDiameter >= RightRacketY);
			end if;
		end if;
	end process AssignProcess;

	-- Ausgangssignale und Zwischenwerte berechnen
	X <= TmpX;
	Y <= TmpY;
	BallLeftOutside <= TmpBallLeftOutside;
	BallRightOutside <= TmpBallRightOutside;
	BallOnLeftFieldEdge <= TmpX = RacketWidth;
	BallOnRightFieldEdge <= TmpX + BallDiameter + RacketWidth = TXPosition'high;
	BallOnTopFieldEdge <= TmpY = 0;
	BallOnBottomFieldEdge <= TmpY + BallDiameter = TYPosition'high;

	-- Bewegunsvektor in x-Richtung berechnen
	ComputeXMotionVector: process(Clock, Reset, CurrentState)
		variable
			dxIncrement,
			TmpXInitMotionVector: TXMotionVector;
	begin
		if Reset = '1' then
			dx <= 0;
		elsif rising_edge(Clock) then
			-- Startwert
			if CurrentState = Init then
				dx <= InitXMotionVector;
				TmpXInitMotionVector := abs(InitXMotionVector);
			-- Vektor neu berechnen, wenn nötig
			elsif CurrentState = UpdateMotionVectors then
				-- Anzahl der Schlägerkontakte erreicht?
				if RacketContactCounter = RacketContactCountToIncrementXMotion - 1 then
					-- aktuelle Richtung überprüfen und Inkrement setzen
					if dx < 0 then
						dxIncrement := -1;
					else
						dxIncrement := +1;
					end if;
				else
					dxIncrement := 0;
				end if;
				-- Anzahl Punkte überprüfen und evtl. Startgeschwindigkeit inkrementieren
				if (TmpBallLeftOutside or TmpBallRightOutside) and (ScoreCounter = ScoreToIncrementInitMotion) and (TmpXInitMotionVector < TXMotionVector'high) then
						TmpXInitMotionVector := TmpXInitMotionVector + 1;
				end if;
				-- Startrichtung und -geschwindigkeit setzen, wenn der Ball im Aus ist
				if TmpBallLeftOutside then
						dx <= abs(TmpXInitMotionVector);
				elsif TmpBallRightOutside then
						dx <= 0 - abs(TmpXInitMotionVector);
				-- Ball am Schläger abprallen lassen
				elsif (BallOnLeftFieldEdge and BallInsideLeftRacket and (dx < 0)) or (BallOnRightFieldEdge and BallInsideRightRacket and (dx > 0)) then
						dx <= 0 - (dx + dxIncrement);
				end if;
			end if;
		end if;
	end process ComputeXMotionVector;

	-- Bewegungsvektor in y-Richtung berechnen
	ComputeYMotionVector: process(Clock, Reset, CurrentState)
		variable
			dyIncrement,
			TmpYInitMotionVector: TYMotionVector;
	begin
		if Reset = '1' then
			dy <= 0;
		elsif rising_edge(Clock) then
			if CurrentState = Init then
				dy <= InitYMotionVector;
				TmpYInitMotionVector := abs(InitYMotionVector);
			elsif CurrentState = UpdateMotionVectors then
				-- Anzahl Wandkontakte überprüfen und Geschwindigkeitsinkrement berechnen
				if FieldEdgeContactCounter = FieldEdgeContactCountToIncrementYMotion - 1 then
					if dy < 0 then
						dyIncrement := - 1;
					else
						dyIncrement := + 1;
					end if;
				else
					dyIncrement := 0;
				end if;
				-- Startgeschwindigkeit erhöhen, wenn der Ball im Aus ist
				if (TmpBallLeftOutside or TmpBallRightOutside) and (ScoreCounter = ScoreToIncrementInitMotion) and (TmpYInitMotionVector < TYMotionVector'high) then
					TmpYInitMotionVector := TmpYInitMotionVector + 1;
					if TmpYInitMotionVector > 0 then
						dy <= TmpYInitMotionVector;
					elsif TmpYInitMotionVector < 0 then
						dy <= 0 - TmpYInitMotionVector;
					else
						dy <= 0;
					end if;
				end if;
				-- Ball mit den Schlägern beschleunigen / abbremsen
				-- Ball ist am linken Schläger
				if BallOnLeftFieldEdge and BallInsideLeftRacket then
					-- Bereich überprüfen, mit dem der Schläger getroffen wird
					case TmpY + BallDiameter / 2 - LeftRacketY is
						-- oben
						when 1 - BallDiameter to RacketHeight / cChangeBallSpeedAreaCount - 1 =>
							dy <= dy + cBallSpeedOffsets(0);
						-- Mitte
						when RacketHeight / cChangeBallSpeedAreaCount to 2 * RacketHeight / cChangeBallSpeedAreaCount - 1 =>
							dy <= dy + cBallSpeedOffsets(1);
						-- unten
						when 2 * RacketHeight / cChangeBallSpeedAreaCount to 3 * RacketHeight / cChangeBallSpeedAreaCount + BallDiameter - 1 =>
							dy <= dy + cBallSpeedOffsets(2);
						when others =>
							null;
					end case;
				-- Ball ist am rechten Scläger
				-- analog zum linken Schläger verfahren
				elsif BallOnRightFieldEdge and BallInsideRightRacket then
					case TmpY + BallDiameter / 2 - RightRacketY is
						when 1 - BallDiameter to RacketHeight / cChangeBallSpeedAreaCount - 1 =>
							dy <= dy + cBallSpeedOffsets(0);
						when RacketHeight / cChangeBallSpeedAreaCount to 2 * RacketHeight / cChangeBallSpeedAreaCount - 1 =>
							dy <= dy + cBallSpeedOffsets(1);
						when 2 * RacketHeight / cChangeBallSpeedAreaCount to 3 * RacketHeight / cChangeBallSpeedAreaCount + BallDiameter - 1 =>
							dy <= dy + cBallSpeedOffsets(2);
						when others =>
							null;
					end case;
				-- Ball an den Wänden abprallen lassen
				elsif BallOnTopFieldEdge or BallOnBottomFieldEdge then
					dy <= 0 - (dy + dyIncrement);
				end if;
			end if;
		end if;
	end process ComputeYMotionVector;
end architecture ABallPosition;
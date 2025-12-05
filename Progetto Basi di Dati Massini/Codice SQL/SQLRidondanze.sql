-- Drop Event Procedure Trigger --
DROP TRIGGER IF EXISTS premiatoR_immediateRefresh_ ;
DROP TRIGGER IF EXISTS premiatoA_immediateRefresh_ ;
DROP TRIGGER IF EXISTS premiatoP_immediateRefresh_ ;
DROP PROCEDURE IF EXISTS calcolaValutazioneFilm;
DROP EVENT IF EXISTS aggiornaValutazione;
-- --------------------------------------------------
-- PremiatoR 
-- --------------------------------------------------
CREATE TRIGGER premiatoR_immediateRefresh_
AFTER INSERT ON PremiazioneR
FOR EACH ROW 
		UPDATE Film F
        SET F.PremiatoR = TRUE
        WHERE F.PremiatoR = FALSE AND F.ID IN (SELECT R.Film
												FROM Regia R
                                                WHERE R.Regista = NEW.Regista);
                                                
-- --------------------------------------------------
-- PremiatoA 
-- --------------------------------------------------
CREATE TRIGGER premiatoA_immediateRefresh_
AFTER INSERT ON PremiazioneA
FOR EACH ROW 
		UPDATE Film F
        SET F.PremiatoA = TRUE
        WHERE F.PremiatoA = FALSE AND F.ID IN (SELECT I.Film
												FROM Interpretazione I
                                                WHERE I.Attore = NEW.Attore);
                                                
-- --------------------------------------------------
-- PremiatoP 
-- --------------------------------------------------
CREATE TRIGGER premiatoP_immediateRefresh_
AFTER INSERT ON PremiazioneF
FOR EACH ROW 
		UPDATE Film F
        SET F.PremiatoP = TRUE
        WHERE F.PremiatoP = FALSE AND F.ID = NEW.Film;
        
-- --------------------------------------------------
-- Procedure Valutazione 
-- --------------------------------------------------
DELIMITER $$

CREATE PROCEDURE calcolaValutazioneFilm (
    IN filmID INT,
    OUT valutazioneFinale FLOAT
)
BEGIN
    DECLARE VU FLOAT DEFAULT 0;
    DECLARE VC FLOAT DEFAULT 0;
    DECLARE VR FLOAT DEFAULT 0;
    DECLARE VA FLOAT DEFAULT 0;
    DECLARE VP FLOAT DEFAULT 0;

    -- Calcolare la media delle recensioni degli utenti
    SELECT IFNULL(AVG(Voto), 0)
    INTO VU
    FROM RecensioneU
    WHERE FilmID = filmID;

    -- Calcolare la media delle recensioni dei critici
    SELECT IFNULL(AVG(Voto), 0)
    INTO VC
    FROM RecensioneC
    WHERE FilmID = filmID;

    -- Calcolare la valutazione dei registi
    SELECT CASE 
             WHEN PPR > 15 THEN 10
             WHEN PPR BETWEEN 1 AND 15 THEN 7
             ELSE 4
           END
    INTO VR
    FROM (
		  SELECT sum(P.Peso) AS PPR
		  FROM Premio P INNER JOIN PremiazioneR PR ON P.Nome = PR.NomePremio INNER JOIN Regia R ON  PR.Regista = R.Regista
		  WHERE R.Film = filmID)AS PremiR;
   
    
     -- Calcolare la valutazione degli attori
      SELECT CASE 
             WHEN PPA > 15 THEN 10
             WHEN PPA BETWEEN 9 AND 15 THEN 8
             WHEN PPA BETWEEN 1 AND 8 THEN 6
             ELSE 4
           END
    INTO VA 
    FROM (
		  SELECT sum(P.Peso) AS PPA
		  FROM Premio P INNER JOIN PremiazioneA PA ON P.Nome = PA.NomePremio INNER JOIN Interpretazione I ON PA.Attore = I.Attore
		  WHERE I.Film = filmID)AS PremiA;
  
    
    -- Calcolare la valutazione propria del film
    SELECT CASE 
             WHEN PPF > 10 THEN 10
             WHEN PPF BETWEEN 1 AND 10 THEN 7
             ELSE 4
           END
    INTO VP
    FROM(
		 SELECT sum(P.Peso) AS PPF
		 FROM Premio P INNER JOIN PremiazioneF PF ON P.Nome = PF.NomePremio
		 WHERE PF.Film = filmID) AS PremiF;
    
    -- Calcolare la valutazione finale
    SET valutazioneFinale = (VU + 5 * VC + VR + VA + 2 * VP) / 10;
END $$
DELIMITER ;

-- --------------------------------------------------
-- Event Valutazione 
-- --------------------------------------------------
DELIMITER $$
CREATE EVENT IF NOT EXISTS aggiornaValutazione
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 02:00:00' -- Esegui ogni notte alle 2:00
DO
BEGIN
    DECLARE finito INT DEFAULT 0;
    DECLARE filmID INT;
    DECLARE cur CURSOR FOR SELECT ID FROM Film;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

    OPEN cur;
    -- Itera su tutti i film e aggiorna la loro valutazione
    scan: LOOP
        FETCH cur INTO filmID;
        IF finito = 1 THEN
            LEAVE scan;
        END IF;

        SET @valutazione = 0;
        CALL calcolaValutazioneFilm(filmID, @valutazione);
        UPDATE Film SET Valutazione = @valutazione WHERE ID = filmID;
    END LOOP;
    CLOSE cur;
END $$

DELIMITER ;

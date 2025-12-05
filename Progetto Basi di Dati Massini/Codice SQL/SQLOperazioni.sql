-- Operazioni

-- --------------------------------------------------
-- Operazione 1  
-- Generi di un film
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS genere_film;
DELIMITER $$
CREATE PROCEDURE genere_film(IN idfilm_ INT)
BEGIN
SELECT G.Descrizione
FROM Genere G INNER JOIN Tipologia T ON G.ID = T.Genere
WHERE T.Film = idfilm_;
END $$
DELIMITER ;
call genere_film(18);

-- --------------------------------------------------
-- Operazione 2
-- Nuova Connessione
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS nuova_connessione;
DELIMITER $$
CREATE PROCEDURE nuova_connessione( IN _IP VARCHAR(15),
									IN inizio TIMESTAMP,
                                    IN fine TIMESTAMP,
                                    IN dispositivo VARCHAR(30),
                                    IN idutente INT,
                                    IN idfilm INT )
BEGIN
	INSERT INTO DettagliConnessione VALUES (_IP, inizio, fine, dispositivo, idutente, idfilm);
END $$
DELIMITER ;
call nuova_connessione('192.168.0.30',  DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 HOUR), CURRENT_TIMESTAMP, 'PC', 3, 16);

-- --------------------------------------------------
-- Operazione 3
-- Inserimento Fattura
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS inserimento_fattura;
DELIMITER $$
CREATE PROCEDURE inserimento_fattura (IN codiceutente INT)
BEGIN
	DECLARE tipoabb VARCHAR(30) DEFAULT '';
	DECLARE tarif FLOAT DEFAULT 0;
    DECLARE durat INT DEFAULT 0;
    
    SET tipoabb = (SELECT SottoscrizioneAbbonamento FROM Utente WHERE ID = codiceutente);
    
    IF tipoabb = '' THEN 
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Utente non abbonato';
	END IF;
    
    SET tarif = (SELECT Tariffa FROM Abbonamento WHERE Tipo = tipoabb);
    SET durat = (SELECT Durata FROM Abbonamento WHERE Tipo = tipoabb);
    
    INSERT INTO Fattura (DataEmissione, Quota, Scadenza, DataPagamento, FatturazioneUtente, CartaPagamento) VALUES
    (CURRENT_DATE, tarif, DATE_ADD(CURRENT_DATE, INTERVAL durat DAY), NULL, codiceutente, NULL);
    
END $$
DELIMITER ;
call inserimento_fattura(2);

-- --------------------------------------------------
-- Operazione 4
-- Lista Film Disponibili Per Lingua
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS listafilmdisponibili_;
DELIMITER $$
CREATE PROCEDURE listafilmdisponibili_ (IN nomel VARCHAR(20), 
										IN tipologiaL CHAR(1))
BEGIN
    SELECT F.Titolo
    FROM Film F
    WHERE F.ID IN ( SELECT L.Film
					FROM Linguaggio L 
                    WHERE L.NomeLingua = nomel AND TipologiaLingua = tipologiaL
				   );
END $$
DELIMITER ;
call listafilmdisponibili_('Inglese', 'S');

-- --------------------------------------------------
-- Operazione 5
-- Film Con Registi Premiati
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS filmconregistip_;
DELIMITER $$
CREATE PROCEDURE filmconregistip_ ()
BEGIN
	SELECT F.Titolo
    FROM Film F
    WHERE F.PremiatoR = TRUE;
END $$
DELIMITER ;
call filmconregistip_;


-- --------------------------------------------------
-- Operazione 6
-- Film Vietati in Base al Formato
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS filmvietatiF_;
DELIMITER $$
CREATE PROCEDURE filmvietatiF_ (IN nomestato VARCHAR(50), OUT idfilm_ VARCHAR(255))
BEGIN
	DECLARE finito INT DEFAULT 0;
	DECLARE codicef VARCHAR(10);
    DECLARE aggiornamentof DATE;
    DECLARE var VARCHAR(255) DEFAULT '';
    DECLARE cur CURSOR FOR
		SELECT CodiceFormato, AggiornamentoFormato
        FROM Esclusione
        WHERE StatoRestrittivo = nomestato;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    OPEN cur;
    scan: LOOP
		FETCH cur INTO codicef, aggiornamentof;
		IF finito = 1 THEN
			IF idfilm_ IS NULL THEN 
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Stato non vieta alcun tipo di Formato';
			END IF;
			LEAVE scan;
		END IF;
        SELECT GROUP_CONCAT(Film SEPARATOR ' ; ')
        INTO var
        FROM Specifiche
        WHERE CodiceFormato = codicef AND AggiornamentoFormato = aggiornamentof;
        IF var IS NOT NULL THEN
            IF idfilm_ IS NULL THEN
                SET idfilm_ = var;
            END IF;
        END IF;
    END LOOP scan;
    CLOSE cur;
END $$
DELIMITER ;

SET @filmvietati = '';
CALL filmvietatiF_('Angola', @filmvietati);
SELECT @filmvietati;

-- --------------------------------------------------
-- Operazione 7
-- Valutazione Film
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS valutazionefilm_;
DELIMITER $$
CREATE PROCEDURE valutazionefilm_ (IN idfilm INT)
BEGIN
	SELECT F.Valutazione
    FROM Film F
    WHERE F.ID = idfilm;
END $$
DELIMITER ;
call valutazionefilm_(14);

-- --------------------------------------------------
-- Operazione 8
-- Raccomandazione Contenuti
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS raccomandaFilm;
DELIMITER $$
CREATE PROCEDURE raccomandaFilm (
    IN idUtente INT
)
BEGIN
    WITH Ultimi5 AS (SELECT Film
            FROM DettagliConnessione
            WHERE Utente = idUtente
            ORDER BY InizioConnessione DESC
            LIMIT 5),
	GeneriUltimi5 AS (SELECT T.Genere, COUNT(Genere) / 5.0 AS GenerePerc
					  FROM Tipologia T INNER JOIN Ultimi5 U ON T.Film = U.Film
                      GROUP BY T.Genere
					 ),
	 RegistiUltimi5 AS (SELECT R.Regista, COUNT(Regista) / 5.0 AS RegistaPerc
						FROM Regia R INNER JOIN Ultimi5 U ON R.Film = U.Film
                        GROUP BY R.Regista
                        ),
	FilmMaiVisti AS (SELECT DISTINCT F.ID, F.Titolo, T.Genere, R.Regista
					FROM Film F
					LEFT JOIN Tipologia T ON F.ID = T.Film
					LEFT JOIN Regia R ON F.ID = R.Film
					WHERE F.ID NOT IN (
										SELECT Film
										FROM DettagliConnessione
										WHERE Utente = idUtente
										)
					),
	FilmConPercentuali AS (
        SELECT DISTINCT FMV.ID, FMV.Titolo,
               COALESCE(MAX(GU.GenerePerc), 0) AS GenerePerc,
               COALESCE(MAX(RU.RegistaPerc), 0) AS RegistaPerc,
               (COALESCE(MAX(GU.GenerePerc), 0) * 0.7 + COALESCE(MAX(RU.RegistaPerc), 0) * 0.3) AS PercentualeTotale
        FROM FilmMaiVisti FMV
        LEFT JOIN GeneriUltimi5 GU ON FMV.Genere = GU.Genere
        LEFT JOIN RegistiUltimi5 RU ON FMV.Regista = RU.Regista
        GROUP BY FMV.ID, FMV.Titolo
    ) 
   SELECT ID, 
           Titolo, 
           ROUND(PercentualeTotale * 100, 2) AS PercentualeNumerica,
           CONCAT(ROUND(PercentualeTotale * 100, 2), '%') AS PercentualeTotale
    FROM FilmConPercentuali
    GROUP BY ID, Titolo, PercentualeNumerica
    ORDER BY PercentualeNumerica DESC
    LIMIT 5;

END $$

DELIMITER ;

CALL raccomandaFilm(8);

-- --------------------------------------------------
-- Operazione 5.1 Classifiche
-- --------------------------------------------------
DROP PROCEDURE IF EXISTS Classifiche_per_Stato_;
DELIMITER $$
CREATE PROCEDURE Classifiche_per_Stato_ (
    IN _stato VARCHAR(255),
    IN _abbonamento VARCHAR(255)
)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS UtentiTarget;
    DROP TEMPORARY TABLE IF EXISTS NumeroVisualizzazioniFilm;
    DROP TEMPORARY TABLE IF EXISTS FilmPiuVisualizzati;
    DROP TABLE IF EXISTS FormatiFilm;
    DROP TEMPORARY TABLE IF EXISTS FormatiVideoPiuUtilizzati;
    DROP TEMPORARY TABLE IF EXISTS FormatiAudioPiuUtilizzati;
    -- Creo tabelle temporanee per risultati intermedi
    CREATE TEMPORARY TABLE UtentiTarget AS
    SELECT U.ID
    FROM Utente U INNER JOIN DettagliConnessione DC ON U.ID = DC.Utente INNER JOIN IPPaese IPP ON DC.IP = IPP.IP
    WHERE IPP.Paese = _stato AND U.SottoscrizioneAbbonamento = _abbonamento ;
    

    CREATE TEMPORARY TABLE NumeroVisualizzazioniFilm AS
    SELECT DC.Film, COUNT(*) AS NumeroVisual
    FROM DettagliConnessione DC INNER JOIN UtentiTarget UT ON DC.Utente = UT.ID
    GROUP BY DC.Film;

    CREATE TEMPORARY TABLE FilmPiuVisualizzati AS
    SELECT NVF.Film, F.Titolo, NVF.NumeroVisual
    FROM NumeroVisualizzazioniFilm NVF
    INNER JOIN Film F ON NVF.Film = F.ID
    ORDER BY NVF.NumeroVisual DESC;

    CREATE TABLE FormatiFilm AS
    SELECT S.Film, S.CodiceFormato, S.AggiornamentoFormato, F.TipoFormato, COUNT(*) AS ContoFormati
    FROM Specifiche S INNER JOIN Formato F ON S.CodiceFormato = F.Codice
    GROUP BY S.Film, S.CodiceFormato, S.AggiornamentoFormato, F.TipoFormato;

    CREATE TEMPORARY TABLE FormatiVideoPiuUtilizzati AS
    SELECT FF.Film, FF.CodiceFormato, FF.AggiornamentoFormato, FF.TipoFormato
    FROM FormatiFilm FF
    INNER JOIN (
        SELECT Film, MAX(ContoFormati) AS MaxCount
        FROM FormatiFilm
        WHERE TipoFormato = 'V'
        GROUP BY Film
    ) MF ON FF.Film = MF.Film AND FF.ContoFormati = MF.MaxCount;
   
    
    CREATE TEMPORARY TABLE FormatiAudioPiuUtilizzati AS
    SELECT FF.Film, FF.CodiceFormato, FF.AggiornamentoFormato, FF.TipoFormato
    FROM FormatiFilm FF
    INNER JOIN (
        SELECT Film, MAX(ContoFormati) AS MaxCount
        FROM FormatiFilm
        WHERE TipoFormato ='A'
        GROUP BY Film
    ) MF ON FF.Film = MF.Film AND FF.ContoFormati = MF.MaxCount;

    SELECT FPV.Film, FVU.CodiceFormato AS FormatoVideoPiuUtilizzato, FVU.AggiornamentoFormato AS AggiornamentoFormatoVideo, FAU.CodiceFormato AS FormatoAudioPiuUtilizzato, FAU.AggiornamentoFormato AS AggiornamentoFormatoAudio, FPV.NumeroVisual
    FROM FilmPiuVisualizzati FPV LEFT OUTER JOIN FormatiVideoPiuUtilizzati FVU ON FPV.Film = FVU.Film LEFT OUTER JOIN FormatiAudioPiuUtilizzati FAU ON FPV.Film = FAU.Film
    ORDER BY FPV.NumeroVisual DESC;
END $$
DELIMITER ;

call Classifiche_per_Stato_('Spagna', 'Ultimate')

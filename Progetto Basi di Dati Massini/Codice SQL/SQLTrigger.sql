-- DROP DEI TRIGGER --
DROP TRIGGER IF EXISTS validate_regista_before_insert;
DROP TRIGGER IF EXISTS validate_attore_before_insert;
DROP TRIGGER IF EXISTS check_anno_produzione_before_insert_premio;
DROP TRIGGER IF EXISTS check_anno_produzione_before_insert_specifiche;
DROP TRIGGER IF EXISTS check_anno_produzione_before_insert_visualizzazione;
DROP TRIGGER IF EXISTS check_categoria_premio_before_insert_premiazioneR;
DROP TRIGGER IF EXISTS check_categoria_premio_before_insert_premiazioneA;
DROP TRIGGER IF EXISTS check_categoria_premio_before_insert_premiazioneF;
DROP TRIGGER IF EXISTS SetDataFineAbb_before_insert;
DROP TRIGGER IF EXISTS CheckAge_;
DROP TRIGGER IF EXISTS trg_before_insert_restrizione;
DROP TRIGGER IF EXISTS before_insert_esclusione;
-- Regia --
DELIMITER //
CREATE TRIGGER validate_regista_before_insert
BEFORE INSERT ON Regia
FOR EACH ROW
BEGIN
    DECLARE ruol CHAR(1);
    -- Verifica se il Regista inserito ha il ruolo corretto
    SELECT Ruolo INTO ruol FROM Operatore WHERE ID = NEW.Regista;
    IF ruol IS NULL OR ruol != 'R' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Regista non valido: deve riferirsi a un regista con Ruolo = ''R''';
    END IF;
END //

DELIMITER ;

-- Interpretazione --
DELIMITER //
CREATE TRIGGER validate_attore_before_insert
BEFORE INSERT ON Interpretazione
FOR EACH ROW
BEGIN
    DECLARE ruol CHAR(1);
    -- Verifica se l'attore inserito ha il ruolo corretto
    SELECT Ruolo INTO ruol FROM Operatore WHERE ID = NEW.Attore;
    IF ruol IS NULL OR ruol != 'A' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attore non valido: deve riferirsi a un regista con Ruolo = ''A''';
    END IF;
END //

DELIMITER ;

-- AnnoProduzione < Anno Data Premio --
DELIMITER //

CREATE TRIGGER check_anno_produzione_before_insert_premio
BEFORE INSERT ON PremiazioneF
FOR EACH ROW
BEGIN
    DECLARE anno_produzione INT;
    SELECT AnnoProduzione INTO anno_produzione FROM Film WHERE ID = NEW.Film;
    
    IF YEAR(NEW.Data_) < anno_produzione THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AnnoProduzione deve essere minore o uguale dell\'anno della Data di Premiazione';
    END IF;
END //

-- AnnoProduzione < Anno Data Rilascio --
DELIMITER //

CREATE TRIGGER check_anno_produzione_before_insert_specifiche
BEFORE INSERT ON Specifiche
FOR EACH ROW
BEGIN
    DECLARE anno_produzione INT;
    SELECT AnnoProduzione INTO anno_produzione FROM Film WHERE ID = NEW.Film;
    
    IF YEAR(NEW.DataRilascio) < anno_produzione THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AnnoProduzione deve essere minore o uguale dell\'anno della Data di Rilascio';
    END IF;
END //

-- AnnoProduzione < Anno Data Visualizzazione --
DELIMITER //

CREATE TRIGGER check_anno_produzione_before_insert_visualizzazione
BEFORE INSERT ON DettagliConnessione
FOR EACH ROW
BEGIN
    DECLARE anno_produzione INT;
    SELECT AnnoProduzione INTO anno_produzione FROM Film WHERE ID = NEW.Film;
    
    IF (YEAR(NEW.InizioConnessione)) < anno_produzione THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AnnoProduzione deve essere minore o uguale dell\'anno della Data di Visualizzazione';
    END IF;
END //

-- PremiazioneR --
DELIMITER //

CREATE TRIGGER check_categoria_premio_before_insert_premiazioneR
BEFORE INSERT ON PremiazioneR
FOR EACH ROW
BEGIN
	IF NEW.CategoriaPremio <> 'R' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La Categoria deve essere R';
	END IF;
END //

-- PremiazioneA --
DELIMITER //

CREATE TRIGGER check_categoria_premio_before_insert_premiazioneA
BEFORE INSERT ON PremiazioneA
FOR EACH ROW
BEGIN
	IF NEW.CategoriaPremio <> 'A' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La Categoria deve essere A';
	END IF;
END //

-- PremiazioneF --
DELIMITER //

CREATE TRIGGER check_categoria_premio_before_insert_premiazioneF
BEFORE INSERT ON PremiazioneF
FOR EACH ROW
BEGIN
	IF NEW.CategoriaPremio <> 'F' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La Categoria deve essere F';
	END IF;
END //
    
-- Creazione del trigger per impostare automaticamente DataFineAbb
CREATE TRIGGER SetDataFineAbb_before_insert
BEFORE INSERT ON Utente
FOR EACH ROW
BEGIN
    IF NEW.SottoscrizioneAbbonamento IS NOT NULL THEN
        IF NEW.SottoscrizioneAbbonamento IN ('Basic', 'Premium', 'Pro') THEN
            SET NEW.DataFineAbb = DATE_ADD(NEW.DataInizioAbb, INTERVAL 365 DAY);
        ELSEIF NEW.SottoscrizioneAbbonamento IN ('Deluxe', 'Ultimate') THEN
            SET NEW.DataFineAbb = DATE_ADD(NEW.DataInizioAbb, INTERVAL 730 DAY);
        END IF;
    END IF;
END;

-- Controllo età minima
CREATE TRIGGER CheckAge_
BEFORE INSERT ON Utente
FOR EACH ROW
BEGIN
    DECLARE age INT;

    -- Calcola l'età dell'utente
    SET age = TIMESTAMPDIFF(YEAR, NEW.DataNascita, CURDATE());
    -- Controlla l'età dell'utente e il tipo di abbonamento
    IF age < 18 AND NEW.SottoscrizioneAbbonamento NOT IN ('Basic', 'Premium') THEN
        SET NEW.SottoscrizioneAbbonamento = NULL;
        SET NEW.DataInizioAbb = NULL;
        SET NEW.DataFineAbb = NULL;
    END IF;
END;

-- RESTRIZIONE FALSE
DELIMITER //
CREATE TRIGGER trg_before_insert_restrizione
BEFORE INSERT ON Restrizione
FOR EACH ROW
BEGIN
    DECLARE restrizioneA_ BOOLEAN;
    -- Controlla se lo stato ha RestrizioneA = TRUE
    SELECT RestrizioneA INTO restrizioneA_ 
    FROM StatoRestrittivo 
    WHERE Stato = NEW.StatoRestrittivo;
    
    IF restrizioneA_ = FALSE THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Non è permesso inserire uno stato con RestrizioneA = FALSE';
    END IF;
END;
//
DELIMITER ;

-- ESCLUSIONE FALSE
DELIMITER //
CREATE TRIGGER before_insert_esclusione
BEFORE INSERT ON Esclusione
FOR EACH ROW
BEGIN
    DECLARE restrizioneF_ BOOLEAN;
    -- Controlla se lo stato ha RestrizioneA = TRUE
    SELECT RestrizioneF INTO restrizioneF_
    FROM StatoRestrittivo 
    WHERE Stato = NEW.StatoRestrittivo;
    
    IF restrizioneF_ = FALSE THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Non è permesso inserire uno stato con RestrizioneF = FALSE';
    END IF;
END;
//
DELIMITER ;
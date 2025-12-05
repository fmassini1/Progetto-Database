-- DROP DEGLI EVENT --
DROP EVENT IF EXISTS ResetAbbonamentiScaduti_;
DROP EVENT IF EXISTS evento_cancellazioneconnessioni;

-- --------------------------------------------------
-- ResetAbbonamenti
-- --------------------------------------------------
CREATE EVENT ResetAbbonamentiScaduti_
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
    UPDATE Utente
    SET SottoscrizioneAbbonamento = NULL,
        DataInizioAbb = NULL,
        DataFineAbb = NULL
    WHERE DataFineAbb < CURRENT_DATE;
    
-- --------------------------------------------------
-- Evento Cancellazione Connessioni 
-- --------------------------------------------------
CREATE EVENT evento_cancellazioneconnessioni
ON SCHEDULE EVERY 1 DAY
STARTS current_timestamp
DO
DELETE FROM DettagliConnessione
WHERE InizioConnessione < CURRENT_DATE - INTERVAL 1 YEAR
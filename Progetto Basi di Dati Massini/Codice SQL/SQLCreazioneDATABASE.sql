-- --------------------------------------------------
-- Creazione DataBase 
-- --------------------------------------------------
DROP SCHEMA IF EXISTS FilmSphere ;
CREATE SCHEMA IF NOT EXISTS FilmSphere CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci; 
USE FilmSphere;

-- ------------------------------------------------
-- Tabella Paese
-- ------------------------------------------------
DROP TABLE IF EXISTS Paese;
CREATE TABLE IF NOT EXISTS Paese (
	Nome VARCHAR(50) NOT NULL PRIMARY KEY,
    Longitudine FLOAT NOT NULL,
    Latitudine FLOAT NOT NULL,
    CHECK (Longitudine >= -180.0 AND Longitudine <= 180.0),
    CHECK (Latitudine >= -90.0 AND Latitudine <= 90.0)
) Engine=InnoDB;

-- --------------------------------------------------
-- Tabella Film
-- --------------------------------------------------
DROP TABLE IF EXISTS Film;
CREATE TABLE IF NOT EXISTS Film (
	ID INT NOT NULL auto_increment PRIMARY KEY,
	Descrizione VARCHAR(500) NOT NULL,
    Durata INT NOT NULL,
    Titolo VARCHAR(100) NOT NULL,
    Valutazione FLOAT NOT NULL,
    PremiatoP BOOLEAN,
    PremiatoR BOOLEAN,
    PremiatoA BOOLEAN,
    PaeseProduzione VARCHAR(50) NOT NULL,
    AnnoProduzione INT NOT NULL,
    FOREIGN KEY (PaeseProduzione) REFERENCES Paese(Nome),
    CHECK (Valutazione >= 0 AND Valutazione <=10)
) Engine=InnoDB;

-- --------------------------------------------------
-- Tabella Operatore
-- --------------------------------------------------
DROP TABLE IF EXISTS Operatore;
CREATE TABLE IF NOT EXISTS Operatore (
	ID INT NOT NULL auto_increment PRIMARY KEY,
    Nome VARCHAR(20) NOT NULL,
    Cognome VARCHAR(20) NOT NULL,
    Popolarità INT NOT NULL,
    Ruolo CHAR(1) NOT NULL,
    CHECK (Popolarità >= 0 AND Popolarità <=5),
    CHECK (Ruolo IN ('R', 'A'))
) Engine=InnoDB;

-- --------------------------------------------------
-- Tabella Regia
-- --------------------------------------------------
DROP TABLE IF EXISTS Regia;
CREATE TABLE IF NOT EXISTS Regia (
	Film INT NOT NULL,
    Regista INT NOT NULL,
    PRIMARY KEY (Film, Regista),
    FOREIGN KEY (Film) REFERENCES Film(ID),
    FOREIGN KEY (Regista) REFERENCES Operatore(ID)
) Engine=InnoDB;

-- --------------------------------------------------
-- Tabella Interpretazione
-- --------------------------------------------------
DROP TABLE IF EXISTS Interpretazione;
CREATE TABLE IF NOT EXISTS Interpretazione (
	Film INT NOT NULL,
    Attore INT NOT NULL,
    PRIMARY KEY (Film, Attore),
    FOREIGN KEY (Film) REFERENCES Film(ID),
    FOREIGN KEY (Attore) REFERENCES Operatore(ID)
) Engine=InnoDB;

-- --------------------------------------------------
-- Tabella Premio
-- --------------------------------------------------
DROP TABLE IF EXISTS Premio;
CREATE TABLE IF NOT EXISTS Premio (
	Nome VARCHAR(20) NOT NULL,
    Categoria CHAR(1) NOT NULL,
    Peso INT NOT NULL,
    PRIMARY KEY (Nome, Categoria),
    CHECK (Categoria IN ('R','A','F')),
    CHECK (Peso >=1 AND Peso<=5)
) Engine=InnoDB;

-- --------------------------------------------------
-- Tabella PremiazioneR
-- --------------------------------------------------
DROP TABLE IF EXISTS PremiazioneR;
CREATE TABLE IF NOT EXISTS PremiazioneR (
	NomePremio VARCHAR(20) NOT NULL,
    CategoriaPremio CHAR(1) NOT NULL,
    Regista INT NOT NULL,
    Data_ DATE NOT NULL,
    PRIMARY KEY (NomePremio, CategoriaPremio, Regista, Data_),
    FOREIGN KEY (NomePremio, CategoriaPremio) REFERENCES Premio(Nome, Categoria),
    FOREIGN KEY (Regista) REFERENCES Operatore(ID)
) Engine=InnoDB;

-- --------------------------------------------------
-- Tabella PremiazioneA
-- --------------------------------------------------
DROP TABLE IF EXISTS PremiazioneA;
CREATE TABLE IF NOT EXISTS PremiazioneA (
	NomePremio VARCHAR(20) NOT NULL,
    CategoriaPremio CHAR(1) NOT NULL,
    Attore INT NOT NULL,
    Data_ DATE NOT NULL,
    PRIMARY KEY (NomePremio, CategoriaPremio, Attore, Data_),
    FOREIGN KEY (NomePremio, CategoriaPremio) REFERENCES Premio(Nome, Categoria),
    FOREIGN KEY (Attore) REFERENCES Operatore(ID)
) Engine=InnoDB;

-- --------------------------------------------------
-- Tabella PremiazioneF
-- --------------------------------------------------
DROP TABLE IF EXISTS PremiazioneF;
CREATE TABLE IF NOT EXISTS PremiazioneF (
	NomePremio VARCHAR(20) NOT NULL,
    CategoriaPremio CHAR(1) NOT NULL,
    Film INT NOT NULL,
    Data_ DATE NOT NULL,
    PRIMARY KEY (NomePremio, CategoriaPremio, Film, Data_),
   FOREIGN KEY (NomePremio, CategoriaPremio) REFERENCES Premio(Nome, Categoria),
    FOREIGN KEY (Film) REFERENCES Film(ID)
) Engine=InnoDB;

-- -------------------------------------------------
-- Tabella Critico
-- -------------------------------------------------
DROP TABLE IF EXISTS Critico;
CREATE TABLE IF NOT EXISTS Critico (
	ID INT NOT NULL auto_increment PRIMARY KEY,
    Nome VARCHAR(20),
    Cognome VARCHAR(20)
) Engine=InnoDB;

-- ------------------------------------------------
-- Tabella RecensioneC 
-- ------------------------------------------------
DROP TABLE IF EXISTS RecensioneC;
CREATE TABLE IF NOT EXISTS RecensioneC (
	Film INT NOT NULL,
    Critico INT NOT NULL,
    Voto INT NOT NULL,
    Testo VARCHAR(255) NOT NULL,
    PRIMARY KEY (Film, Critico),
    FOREIGN KEY (Film) REFERENCES Film(ID),
    FOREIGN KEY (Critico) REFERENCES Critico(ID),
    CHECK (Voto >= 0 AND Voto <= 10)
) Engine=InnoDB;

-- ------------------------------------------------
-- Tabella Lingua
-- ------------------------------------------------
DROP TABLE IF EXISTS Lingua;
CREATE TABLE IF NOT EXISTS Lingua (
	NomeLingua VARCHAR(20) NOT NULL,
    Tipologia CHAR(1) NOT NULL,
    PRIMARY KEY (NomeLingua, Tipologia),
    CHECK (Tipologia IN('S','D'))
) Engine=InnoDB;

-- ------------------------------------------------
-- Tabella Linguaggio
-- ------------------------------------------------
DROP TABLE IF EXISTS Linguaggio;
CREATE TABLE IF NOT EXISTS Linguaggio (
	Film INT NOT NULL,
    NomeLingua VARCHAR(20) NOT NULL,
    TipologiaLingua CHAR(1) NOT NULL,
    PRIMARY KEY (Film, NomeLingua, TipologiaLingua),
    FOREIGN KEY (Film) REFERENCES Film(ID),
    FOREIGN KEY (NomeLingua, TipologiaLingua) REFERENCES Lingua(NomeLingua, Tipologia)
) Engine=InnoDB;

-- ------------------------------------------------
-- Tabella Genere
-- ------------------------------------------------
DROP TABLE IF EXISTS Genere;
CREATE TABLE IF NOT EXISTS Genere (
	ID INT NOT NULL auto_increment PRIMARY KEY,
    Descrizione VARCHAR (30) NOT NULL
) Engine=InnoDB;

-- ------------------------------------------------
-- Tabella Tipologia
-- ------------------------------------------------
DROP TABLE IF EXISTS Tipologia;
CREATE TABLE IF NOT EXISTS Tipologia (
	Film INT NOT NULL,
    Genere INT NOT NULL,
    PRIMARY KEY (Film, Genere),
    FOREIGN KEY (Film) REFERENCES Film(ID),
    FOREIGN KEY (Genere) REFERENCES Genere(ID)
) Engine=InnoDB;

-- ----------------------------------------------
-- Tabella Abbonamento
-- ----------------------------------------------
DROP TABLE IF EXISTS Abbonamento;
CREATE TABLE IF NOT EXISTS Abbonamento (
	Tipo VARCHAR(30) NOT NULL PRIMARY KEY,
    Tariffa FLOAT NOT NULL,
    Durata INT NOT NULL,
    MaxOre INT NULL,
    MaxGB INT NULL,
    EtaMin BOOLEAN NULL
) Engine = InnoDB;

-- ------------------------------------------------
-- Tabella Utente
-- ------------------------------------------------
DROP TABLE IF EXISTS Utente;
CREATE TABLE IF NOT EXISTS Utente (
	ID INT NOT NULL auto_increment PRIMARY KEY,
    Nome VARCHAR(30) NOT NULL,
    Cognome VARCHAR(30) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Password_ VARCHAR(30) NOT NULL,
    DataNascita DATE NOT NULL,
    SottoscrizioneAbbonamento VARCHAR(30) NULL,
    DataInizioAbb DATE NULL,
    DataFineAbb DATE NULL,
    FOREIGN KEY (SottoscrizioneAbbonamento) REFERENCES Abbonamento(Tipo),
    CHECK (DataInizioAbb < DataFineAbb OR (DataInizioAbb IS NULL AND DataFineAbb IS NULL))
) Engine=InnoDB;

-- ------------------------------------------------
-- Tabella IPPaese
-- ------------------------------------------------
DROP TABLE IF EXISTS IPPaese;
CREATE TABLE IF NOT EXISTS IPPaese (
	IP VARCHAR(15) PRIMARY KEY,
    Paese VARCHAR(50) NOT NULL,
    CHECK (IP REGEXP '^(([0-9]{1,3}\\.){3}[0-9]{1,3})$' AND INET_ATON(IP) IS NOT NULL),
    FOREIGN KEY (Paese) REFERENCES Paese(Nome)
) Engine=InnoDB;
-- ------------------------------------------------
-- Tabella DettagliConnessione
-- ------------------------------------------------
DROP TABLE IF EXISTS DettagliConnessione;
CREATE TABLE IF NOT EXISTS DettagliConnessione (
	IP VARCHAR(15),
    InizioConnessione TIMESTAMP NOT NULL,
    FineConnessione TIMESTAMP NOT NULL,
    Hardware VARCHAR(30) NOT NULL,
    Utente INT NOT NULL,
    Film INT NOT NULL,
	PRIMARY KEY (IP, InizioConnessione, FineConnessione),
    FOREIGN KEY (IP) REFERENCES IPPaese (IP),
    FOREIGN KEY (Utente) REFERENCES Utente(ID),
    FOREIGN KEY (Film) REFERENCES Film(ID),
    CHECK (InizioConnessione < FineConnessione)
) Engine=InnoDB;

-- ------------------------------------------------
-- Tabella RecensioneU
-- ------------------------------------------------
DROP TABLE IF EXISTS RecensioneU;
CREATE TABLE IF NOT EXISTS RecensioneU (
	Film INT NOT NULL,
    Utente INT NOT NULL,
    Voto INT NOT NULL,
    Testo VARCHAR(255) NOT NULL,
    PRIMARY KEY (Film, Utente),
    FOREIGN KEY (Film) REFERENCES Film(ID),
    FOREIGN KEY (Utente) REFERENCES Utente(ID),
    CHECK (Voto >= 0 AND Voto <= 10)
) Engine=InnoDB;

-- -----------------------------------------------
-- Tabella Carta
-- -----------------------------------------------
DROP TABLE IF EXISTS Carta;
CREATE TABLE IF NOT EXISTS Carta (
	PAN CHAR(19) PRIMARY KEY,
    CVV CHAR(4) NOT NULL,
    DataScadenza DATE,
    NomeIntestatario VARCHAR(30) NOT NULL,
    CognomeIntestatario VARCHAR(30) NOT NULL,
    UtenteProprietario INT NOT NULL,
    FOREIGN KEY (UtenteProprietario) REFERENCES Utente(ID),
	CHECK (PAN REGEXP '^[0-9]{13,19}$'),
    CHECK (CVV REGEXP '^[0-9]{3,4}$')
) Engine=InnoDB;

-- ------------------------------------------------
-- Tabella Fattura
-- ------------------------------------------------
DROP TABLE IF EXISTS Fattura;
CREATE TABLE IF NOT EXISTS Fattura (
	Codice INT NOT NULL auto_increment PRIMARY KEY,
    DataEmissione DATE NOT NULL,
    Quota FLOAT NOT NULL,
    Scadenza DATE NOT NULL,
	DataPagamento DATE NULL,
    FatturazioneUtente INT NOT NULL,
    CartaPagamento CHAR(19) NULL,
    FOREIGN KEY (FatturazioneUtente) REFERENCES Utente(ID),
    FOREIGN KEY (CartaPagamento) REFERENCES Carta(PAN),
    CHECK (DataEmissione < Scadenza),
    CHECK (DataEmissione < DataPagamento) 
) Engine=InnoDB;

-- ----------------------------------------------
-- Tabella Funzionalità 
-- ----------------------------------------------
DROP TABLE IF EXISTS Funzionalità;
CREATE TABLE IF NOT EXISTS Funzionalità (
	Nome VARCHAR(40) NOT NULL PRIMARY KEY,
    Descrizione VARCHAR(255) NOT NULL
) Engine = InnoDB;

-- ----------------------------------------------
-- Tabella Offerta
-- ----------------------------------------------
DROP TABLE IF EXISTS Offerta;
CREATE TABLE IF NOT EXISTS Offerta (
	Abbonamento VARCHAR(30) NOT NULL,
    Funzionalità VARCHAR(40) NOT NULL,
    PRIMARY KEY (Abbonamento, Funzionalità),
    FOREIGN KEY(Abbonamento) REFERENCES Abbonamento(Tipo),
    FOREIGN KEY (Funzionalità) REFERENCES Funzionalità(Nome)
) Engine=InnoDB;

-- ----------------------------------------------
-- Tabella StatoRestrittivo
-- ----------------------------------------------
DROP TABLE IF EXISTS StatoRestrittivo;
CREATE TABLE IF NOT EXISTS StatoRestrittivo (
	Stato VARCHAR(50) NOT NULL PRIMARY KEY,
    RestrizioneF BOOLEAN,
    RestrizioneA BOOLEAN
) Engine = InnoDB;

-- ----------------------------------------------
-- Tabella Restrizione
-- ----------------------------------------------
DROP TABLE IF EXISTS Restrizione;
CREATE TABLE IF NOT EXISTS Restrizione (
	Abbonamento VARCHAR(30) NOT NULL,
    StatoRestrittivo VARCHAR(50) NOT NULL,
    PRIMARY KEY (Abbonamento, StatoRestrittivo),
    FOREIGN KEY (Abbonamento) REFERENCES Abbonamento(Tipo),
    FOREIGN KEY (StatoRestrittivo) REFERENCES StatoRestrittivo(Stato)
    ) Engine = InnoDB;

-- ---------------------------------------------
-- Tabella Formato
-- ---------------------------------------------
DROP TABLE IF EXISTS Formato;
CREATE TABLE IF NOT EXISTS Formato (
	Codice VARCHAR(10) NOT NULL,
    DataAggiornamento DATE NOT NULL,
    Bitrate FLOAT NOT NULL,
    TipoFormato CHAR(1) NOT NULL,
    QualitàA INT NOT NULL,
    QualitàV INT NOT NULL,
    DimensioneFile FLOAT NOT NULL,
    Lunghezza INT NOT NULL,
    RapportoAspetto FLOAT NOT NULL,
    Risoluzione INT NOT NULL,
    PRIMARY KEY(Codice, DataAggiornamento),
    CHECK (Bitrate >= 400 AND Bitrate <= 14000),
    CHECK (Risoluzione >= 480 AND Risoluzione <= 9999),
    CHECK (TipoFormato IN ('V', 'A'))
) Engine = InnoDB;

-- ----------------------------------------------
-- Tabella Esclusione
-- ----------------------------------------------
DROP TABLE IF EXISTS Esclusione;
CREATE TABLE IF NOT EXISTS Esclusione (
	StatoRestrittivo VARCHAR(50) NOT NULL,
    CodiceFormato VARCHAR(10) NOT NULL,
    AggiornamentoFormato DATE NOT NULL,
    PRIMARY KEY(StatoRestrittivo, CodiceFormato, AggiornamentoFormato),
    FOREIGN KEY (StatoRestrittivo) REFERENCES StatoRestrittivo(Stato),
    FOREIGN KEY (CodiceFormato, AggiornamentoFormato) REFERENCES Formato(Codice, DataAggiornamento)
) Engine = InnoDB;


-- -------------------------------------------
-- Tabella Codec
-- -------------------------------------------
DROP TABLE IF EXISTS Codec;
CREATE TABLE IF NOT EXISTS Codec (
	FileCodec VARCHAR(50) NOT NULL PRIMARY KEY,
    Specifiche VARCHAR(255) NOT NULL
) Engine = InnoDB;

-- --------------------------------------------
-- Tabella Aggiornamento
-- --------------------------------------------
DROP TABLE IF EXISTS Aggiornamento;
CREATE TABLE IF NOT EXISTS Aggiornamento (
	CodiceFormato VARCHAR(10) NOT NULL,
    Codec VARCHAR(50) NOT NULL,
    Data_ DATE NOT NULL,
    PRIMARY KEY(CodiceFormato, Codec),
    FOREIGN KEY (CodiceFormato) REFERENCES Formato(Codice),
    FOREIGN KEY (Codec) REFERENCES Codec(FileCodec)
) Engine = InnoDB;

-- -------------------------------------------
-- Tabella Specifiche
-- -------------------------------------------
DROP TABLE IF EXISTS Specifiche;
CREATE TABLE IF NOT EXISTS Specifiche (
	Film INT NOT NULL,
    CodiceFormato VARCHAR(10) NOT NULL,
    AggiornamentoFormato DATE NOT NULL,
    DataRilascio DATE,
    PRIMARY KEY (Film, CodiceFormato, AggiornamentoFormato),
    FOREIGN KEY (Film) REFERENCES Film(ID),
    FOREIGN KEY (CodiceFormato, AggiornamentoFormato) REFERENCES Formato(Codice, DataAggiornamento)	
) Engine = InnoDB;
    
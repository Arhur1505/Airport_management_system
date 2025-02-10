CREATE SCHEMA zarzadzanie_lotniskiem_v2;
SET search_path TO zarzadzanie_lotniskiem_v2;

CREATE TABLE LinieLotnicze (
    linia_id SERIAL PRIMARY KEY,
    nazwa VARCHAR(100) NOT NULL UNIQUE,
    kraj VARCHAR(100) NOT NULL
);

CREATE TABLE Samoloty (
    samolot_id SERIAL PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    pojemnosc INT NOT NULL,
    linia_id INT NOT NULL,
    CONSTRAINT samoloty_linia_id_fkey FOREIGN KEY (linia_id) REFERENCES LinieLotnicze(linia_id) ON DELETE CASCADE
);

CREATE TABLE Terminale (
    terminal_id SERIAL PRIMARY KEY,
    nazwa VARCHAR(50) NOT NULL,
    pojemnosc INT NOT NULL
);

CREATE TABLE Loty (
    lot_id SERIAL PRIMARY KEY,
    numer_lotu VARCHAR(10) NOT NULL,
    linia_id INT NOT NULL,
    samolot_id INT NOT NULL,
    poczatek VARCHAR(100) NOT NULL,
    cel VARCHAR(100) NOT NULL,
    czas_odlotu TIMESTAMP NOT NULL,
    czas_przylotu TIMESTAMP NOT NULL,
    status VARCHAR(50) DEFAULT 'Zaplanowany',
    terminal_id INT,
    CONSTRAINT loty_linia_id_fkey FOREIGN KEY (linia_id) REFERENCES LinieLotnicze(linia_id) ON DELETE CASCADE,
    CONSTRAINT loty_samolot_id_fkey FOREIGN KEY (samolot_id) REFERENCES Samoloty(samolot_id) ON DELETE CASCADE,
    CONSTRAINT loty_terminal_id_fkey FOREIGN KEY (terminal_id) REFERENCES Terminale(terminal_id) ON DELETE CASCADE
);

CREATE TABLE Zaloga (
    zaloga_id SERIAL PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    rola VARCHAR(50) NOT NULL,
    linia_id INT NOT NULL,
    samolot_id INT NOT NULL,
    CONSTRAINT zaloga_linia_id_fkey FOREIGN KEY (linia_id) REFERENCES LinieLotnicze(linia_id) ON DELETE CASCADE,
    CONSTRAINT zaloga_samolot_id_fkey FOREIGN KEY (samolot_id) REFERENCES Samoloty(samolot_id) ON DELETE CASCADE
);

-- Tworzenie tabeli Uzytkownicy
CREATE TABLE Uzytkownicy (
    u_id SERIAL PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefon VARCHAR(20),
    haslo VARCHAR(255) NOT NULL,
    rola VARCHAR(20) NOT NULL CHECK (rola IN ('admin', 'klient')), 
    data_rejestracji TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Rezerwacje (
    rezerwacja_id SERIAL PRIMARY KEY,
    u_id INT NOT NULL,
    lot_id INT NOT NULL,
    klasa_miejsca VARCHAR(20) DEFAULT 'Ekonomiczna',
    status VARCHAR(50) DEFAULT 'Potwierdzona',
    CONSTRAINT rezerwacje_u_id_fkey FOREIGN KEY (u_id) REFERENCES Uzytkownicy(u_id) ON DELETE CASCADE,
    CONSTRAINT rezerwacje_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES Loty(lot_id) ON DELETE CASCADE
);
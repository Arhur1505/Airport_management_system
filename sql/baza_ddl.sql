-- DROP SCHEMA zarzadzanie_lotniskiem_v2;

CREATE SCHEMA zarzadzanie_lotniskiem_v2 AUTHORIZATION postgres;

-- DROP SEQUENCE zarzadzanie_lotniskiem_v2.linielotnicze_linia_id_seq;

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.linielotnicze_linia_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE zarzadzanie_lotniskiem_v2.loty_lot_id_seq;

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.loty_lot_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE zarzadzanie_lotniskiem_v2.rezerwacje_rezerwacja_id_seq;

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.rezerwacje_rezerwacja_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE zarzadzanie_lotniskiem_v2.samoloty_samolot_id_seq;

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.samoloty_samolot_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE zarzadzanie_lotniskiem_v2.terminale_terminal_id_seq;

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.terminale_terminal_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE zarzadzanie_lotniskiem_v2.uzytkownicy_u_id_seq;

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.uzytkownicy_u_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE zarzadzanie_lotniskiem_v2.zaloga_zaloga_id_seq;

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.zaloga_zaloga_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;-- zarzadzanie_lotniskiem_v2.linielotnicze definition

-- Drop table

-- DROP TABLE zarzadzanie_lotniskiem_v2.linielotnicze;

CREATE TABLE zarzadzanie_lotniskiem_v2.linielotnicze (
	linia_id serial4 NOT NULL,
	nazwa varchar(100) NOT NULL,
	kraj varchar(100) NOT NULL,
	CONSTRAINT linielotnicze_nazwa_key UNIQUE (nazwa),
	CONSTRAINT linielotnicze_pkey PRIMARY KEY (linia_id)
);

-- Table Triggers

create trigger trigger_waliduj_unikalnosc_linii before
insert
    or
update
    on
    zarzadzanie_lotniskiem_v2.linielotnicze for each row execute function zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_linii();
create trigger trigger_waliduj_kraj_linii before
insert
    or
update
    on
    zarzadzanie_lotniskiem_v2.linielotnicze for each row execute function zarzadzanie_lotniskiem_v2.waliduj_kraj_linii();


-- zarzadzanie_lotniskiem_v2.terminale definition

-- Drop table

-- DROP TABLE zarzadzanie_lotniskiem_v2.terminale;

CREATE TABLE zarzadzanie_lotniskiem_v2.terminale (
	terminal_id serial4 NOT NULL,
	nazwa varchar(50) NOT NULL,
	pojemnosc int4 NOT NULL,
	CONSTRAINT terminale_pkey PRIMARY KEY (terminal_id)
);

-- Table Triggers

create trigger trigger_waliduj_pojemnosc_terminalu before
insert
    or
update
    on
    zarzadzanie_lotniskiem_v2.terminale for each row execute function zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_terminalu();
create trigger trigger_waliduj_unikalnosc_terminalu before
insert
    or
update
    on
    zarzadzanie_lotniskiem_v2.terminale for each row execute function zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_terminalu();


-- zarzadzanie_lotniskiem_v2.uzytkownicy definition

-- Drop table

-- DROP TABLE zarzadzanie_lotniskiem_v2.uzytkownicy;

CREATE TABLE zarzadzanie_lotniskiem_v2.uzytkownicy (
	u_id serial4 NOT NULL,
	imie varchar(50) NOT NULL,
	nazwisko varchar(50) NOT NULL,
	email varchar(100) NOT NULL,
	telefon varchar(20) NULL,
	haslo varchar(255) NOT NULL,
	rola varchar(20) NOT NULL,
	data_rejestracji timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT uzytkownicy_email_key UNIQUE (email),
	CONSTRAINT uzytkownicy_pkey PRIMARY KEY (u_id),
	CONSTRAINT uzytkownicy_rola_check CHECK (((rola)::text = ANY ((ARRAY['admin'::character varying, 'klient'::character varying])::text[])))
);


-- zarzadzanie_lotniskiem_v2.samoloty definition

-- Drop table

-- DROP TABLE zarzadzanie_lotniskiem_v2.samoloty;

CREATE TABLE zarzadzanie_lotniskiem_v2.samoloty (
	samolot_id serial4 NOT NULL,
	model varchar(50) NOT NULL,
	pojemnosc int4 NOT NULL,
	linia_id int4 NOT NULL,
	CONSTRAINT samoloty_pkey PRIMARY KEY (samolot_id),
	CONSTRAINT samoloty_linia_id_fkey FOREIGN KEY (linia_id) REFERENCES zarzadzanie_lotniskiem_v2.linielotnicze(linia_id) ON DELETE CASCADE
);

-- Table Triggers

create trigger trigger_waliduj_pojemnosc_samolotu before
insert
    or
update
    on
    zarzadzanie_lotniskiem_v2.samoloty for each row execute function zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_samolotu();


-- zarzadzanie_lotniskiem_v2.zaloga definition

-- Drop table

-- DROP TABLE zarzadzanie_lotniskiem_v2.zaloga;

CREATE TABLE zarzadzanie_lotniskiem_v2.zaloga (
	zaloga_id serial4 NOT NULL,
	imie varchar(50) NOT NULL,
	nazwisko varchar(50) NOT NULL,
	rola varchar(50) NOT NULL,
	linia_id int4 NOT NULL,
	samolot_id int4 NOT NULL,
	CONSTRAINT zaloga_pkey PRIMARY KEY (zaloga_id),
	CONSTRAINT zaloga_linia_id_fkey FOREIGN KEY (linia_id) REFERENCES zarzadzanie_lotniskiem_v2.linielotnicze(linia_id) ON DELETE CASCADE,
	CONSTRAINT zaloga_samolot_id_fkey FOREIGN KEY (samolot_id) REFERENCES zarzadzanie_lotniskiem_v2.samoloty(samolot_id) ON DELETE CASCADE
);

-- Table Triggers

create trigger trigger_waliduj_imie_nazwisko_zalogi before
insert
    or
update
    on
    zarzadzanie_lotniskiem_v2.zaloga for each row execute function zarzadzanie_lotniskiem_v2.waliduj_imie_nazwisko_zalogi();


-- zarzadzanie_lotniskiem_v2.loty definition

-- Drop table

-- DROP TABLE zarzadzanie_lotniskiem_v2.loty;

CREATE TABLE zarzadzanie_lotniskiem_v2.loty (
	lot_id serial4 NOT NULL,
	numer_lotu varchar(10) NOT NULL,
	linia_id int4 NOT NULL,
	samolot_id int4 NOT NULL,
	poczatek varchar(100) NOT NULL,
	cel varchar(100) NOT NULL,
	czas_odlotu timestamp NOT NULL,
	czas_przylotu timestamp NOT NULL,
	status varchar(50) DEFAULT 'Zaplanowany'::character varying NULL,
	terminal_id int4 NULL,
	CONSTRAINT loty_pkey PRIMARY KEY (lot_id),
	CONSTRAINT unique_numer_lotu UNIQUE (numer_lotu),
	CONSTRAINT loty_linia_id_fkey FOREIGN KEY (linia_id) REFERENCES zarzadzanie_lotniskiem_v2.linielotnicze(linia_id) ON DELETE CASCADE,
	CONSTRAINT loty_samolot_id_fkey FOREIGN KEY (samolot_id) REFERENCES zarzadzanie_lotniskiem_v2.samoloty(samolot_id) ON DELETE CASCADE,
	CONSTRAINT loty_terminal_id_fkey FOREIGN KEY (terminal_id) REFERENCES zarzadzanie_lotniskiem_v2.terminale(terminal_id) ON DELETE CASCADE
);

-- Table Triggers

create trigger trigger_waliduj_czas_lotu before
insert
    or
update
    on
    zarzadzanie_lotniskiem_v2.loty for each row execute function zarzadzanie_lotniskiem_v2.waliduj_czas_lotu();
create trigger trigger_waliduj_poczatek_i_cel before
insert
    or
update
    on
    zarzadzanie_lotniskiem_v2.loty for each row execute function zarzadzanie_lotniskiem_v2.waliduj_poczatek_i_cel();
create trigger trigger_waliduj_dostepnosc_samolotu before
insert
    or
update
    on
    zarzadzanie_lotniskiem_v2.loty for each row execute function zarzadzanie_lotniskiem_v2.waliduj_dostepnosc_samolotu();
create trigger trigger_waliduj_zaloge_samolotu before
insert
    or
update
    on
    zarzadzanie_lotniskiem_v2.loty for each row execute function zarzadzanie_lotniskiem_v2.waliduj_zaloge_samolotu();


-- zarzadzanie_lotniskiem_v2.rezerwacje definition

-- Drop table

-- DROP TABLE zarzadzanie_lotniskiem_v2.rezerwacje;

CREATE TABLE zarzadzanie_lotniskiem_v2.rezerwacje (
	rezerwacja_id serial4 NOT NULL,
	u_id int4 NOT NULL,
	lot_id int4 NOT NULL,
	klasa_miejsca varchar(20) DEFAULT 'Ekonomiczna'::character varying NULL,
	status varchar(50) DEFAULT 'Potwierdzona'::character varying NULL,
	CONSTRAINT rezerwacje_pkey PRIMARY KEY (rezerwacja_id),
	CONSTRAINT rezerwacje_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES zarzadzanie_lotniskiem_v2.loty(lot_id) ON DELETE CASCADE,
	CONSTRAINT rezerwacje_u_id_fkey FOREIGN KEY (u_id) REFERENCES zarzadzanie_lotniskiem_v2.uzytkownicy(u_id) ON DELETE CASCADE
);


-- zarzadzanie_lotniskiem_v2.widok_linie_lotnicze source

CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_linie_lotnicze
AS SELECT linia_id,
    nazwa,
    kraj
   FROM zarzadzanie_lotniskiem_v2.linielotnicze;


-- zarzadzanie_lotniskiem_v2.widok_loty source

CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_loty
AS SELECT l.lot_id,
    l.numer_lotu,
    lin.nazwa AS nazwa_linii,
    sam.model AS model_samolotu,
    sam.pojemnosc AS pojemnosc_samolotu,
    ( SELECT count(*) AS count
           FROM zarzadzanie_lotniskiem_v2.rezerwacje r
          WHERE r.lot_id = l.lot_id) AS liczba_rezerwacji,
    l.poczatek,
    l.cel,
    l.czas_odlotu,
    l.czas_przylotu,
    t.nazwa AS terminal
   FROM zarzadzanie_lotniskiem_v2.loty l
     JOIN zarzadzanie_lotniskiem_v2.linielotnicze lin ON l.linia_id = lin.linia_id
     JOIN zarzadzanie_lotniskiem_v2.samoloty sam ON l.samolot_id = sam.samolot_id
     LEFT JOIN zarzadzanie_lotniskiem_v2.terminale t ON l.terminal_id = t.terminal_id;


-- zarzadzanie_lotniskiem_v2.widok_loty_na_linie source

CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_loty_na_linie
AS SELECT lin.linia_id,
    lin.nazwa AS linia_lotnicza,
    count(l.lot_id) AS liczba_lotow
   FROM zarzadzanie_lotniskiem_v2.loty l
     JOIN zarzadzanie_lotniskiem_v2.linielotnicze lin ON l.linia_id = lin.linia_id
  GROUP BY lin.linia_id, lin.nazwa;


-- zarzadzanie_lotniskiem_v2.widok_loty_na_terminal source

CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_loty_na_terminal
AS SELECT t.terminal_id,
    t.nazwa AS nazwa_terminalu,
    count(l.lot_id) AS liczba_lotow
   FROM zarzadzanie_lotniskiem_v2.terminale t
     LEFT JOIN zarzadzanie_lotniskiem_v2.loty l ON t.terminal_id = l.terminal_id
  GROUP BY t.terminal_id, t.nazwa;


-- zarzadzanie_lotniskiem_v2.widok_rezerwacje_dla_lotu source

CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_rezerwacje_dla_lotu
AS SELECT r.rezerwacja_id,
    u.imie,
    u.nazwisko,
    u.email,
    u.telefon,
    r.klasa_miejsca,
    r.status,
    r.lot_id
   FROM zarzadzanie_lotniskiem_v2.rezerwacje r
     JOIN zarzadzanie_lotniskiem_v2.uzytkownicy u ON r.u_id = u.u_id;


-- zarzadzanie_lotniskiem_v2.widok_samoloty source

CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_samoloty
AS SELECT s.samolot_id,
    s.model,
    s.pojemnosc,
    s.linia_id,
    l.nazwa AS nazwa_linii
   FROM zarzadzanie_lotniskiem_v2.samoloty s
     JOIN zarzadzanie_lotniskiem_v2.linielotnicze l ON s.linia_id = l.linia_id;


-- zarzadzanie_lotniskiem_v2.widok_terminali source

CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_terminali
AS SELECT terminal_id,
    nazwa,
    pojemnosc
   FROM zarzadzanie_lotniskiem_v2.terminale;


-- zarzadzanie_lotniskiem_v2.widok_uzytkownicy source

CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_uzytkownicy
AS SELECT u_id,
    imie,
    nazwisko,
    email,
    telefon,
    rola,
    date(data_rejestracji) AS data_rejestracji,
    COALESCE(( SELECT count(*) AS count
           FROM zarzadzanie_lotniskiem_v2.rezerwacje r
          WHERE r.u_id = u.u_id), 0::bigint) AS liczba_rezerwacji
   FROM zarzadzanie_lotniskiem_v2.uzytkownicy u;


-- zarzadzanie_lotniskiem_v2.widok_zaloga source

CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_zaloga
AS SELECT z.zaloga_id,
    z.imie,
    z.nazwisko,
    z.rola,
    l.nazwa AS nazwa_linii,
    z.samolot_id
   FROM zarzadzanie_lotniskiem_v2.zaloga z
     JOIN zarzadzanie_lotniskiem_v2.linielotnicze l ON z.linia_id = l.linia_id;


-- zarzadzanie_lotniskiem_v2.widok_zaloga_na_samolot source

CREATE OR REPLACE VIEW zarzadzanie_lotniskiem_v2.widok_zaloga_na_samolot
AS SELECT s.samolot_id,
    s.model AS model_samolotu,
    count(z.zaloga_id) AS liczba_zalogi
   FROM zarzadzanie_lotniskiem_v2.samoloty s
     LEFT JOIN zarzadzanie_lotniskiem_v2.zaloga z ON s.samolot_id = z.samolot_id
  GROUP BY s.samolot_id, s.model;



-- DROP FUNCTION zarzadzanie_lotniskiem_v2.waliduj_czas_lotu();

CREATE OR REPLACE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_czas_lotu()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.czas_przylotu <= NEW.czas_odlotu THEN
        RAISE EXCEPTION 'Czas przylotu musi być późniejszy niż czas odlotu!';
    END IF;

    RETURN NEW;
END;
$function$
;

-- DROP FUNCTION zarzadzanie_lotniskiem_v2.waliduj_dostepnosc_samolotu();

CREATE OR REPLACE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_dostepnosc_samolotu()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM zarzadzanie_lotniskiem_v2.Loty
        WHERE samolot_id = NEW.samolot_id
          AND (
              (NEW.czas_odlotu BETWEEN czas_odlotu AND czas_przylotu) OR
              (NEW.czas_przylotu BETWEEN czas_odlotu AND czas_przylotu) OR
              (czas_odlotu BETWEEN NEW.czas_odlotu AND NEW.czas_przylotu) OR
              (czas_przylotu BETWEEN NEW.czas_odlotu AND NEW.czas_przylotu)
          )
          AND lot_id != NEW.lot_id
    ) THEN
        RAISE EXCEPTION 'Samolot jest już przypisany do innego lotu w tym czasie!';
    END IF;

    RETURN NEW;
END;
$function$
;

-- DROP FUNCTION zarzadzanie_lotniskiem_v2.waliduj_imie_nazwisko_zalogi();

CREATE OR REPLACE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_imie_nazwisko_zalogi()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NOT NEW.imie ~ '^[a-zA-ZąćęłńóśźżĄĘŁŃÓŚŹŻ\s]+$' THEN
        RAISE EXCEPTION 'Imię % zawiera niedozwolone znaki!', NEW.imie;
    END IF;

    IF NOT NEW.nazwisko ~ '^[a-zA-ZąćęłńóśźżĄĘŁŃÓŚŹŻ\s]+$' THEN
        RAISE EXCEPTION 'Nazwisko % zawiera niedozwolone znaki!', NEW.nazwisko;
    END IF;

    RETURN NEW;
END;
$function$
;

-- DROP FUNCTION zarzadzanie_lotniskiem_v2.waliduj_kraj_linii();

CREATE OR REPLACE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_kraj_linii()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NOT NEW.kraj ~ '^[a-zA-ZąćęłńóśźżĄĘüŁŃÓŚŹŻ\s]+$' THEN
        RAISE EXCEPTION 'Niepoprawny format kraju!';
    END IF;

    RETURN NEW;
END;
$function$
;

-- DROP FUNCTION zarzadzanie_lotniskiem_v2.waliduj_poczatek_i_cel();

CREATE OR REPLACE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_poczatek_i_cel()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF LOWER(NEW.poczatek) = LOWER(NEW.cel) THEN
        RAISE EXCEPTION 'Początek i cel lotu nie mogą być takie same!';
    END IF;

    RETURN NEW;
END;
$function$
;

-- DROP FUNCTION zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_samolotu();

CREATE OR REPLACE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_samolotu()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.pojemnosc <= 0 THEN
        RAISE EXCEPTION 'Pojemność samolotu musi być liczbą dodatnią!';
    END IF;

    RETURN NEW;
END;
$function$
;

-- DROP FUNCTION zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_terminalu();

CREATE OR REPLACE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_terminalu()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.pojemnosc <= 0 THEN
        RAISE EXCEPTION 'Pojemność terminalu musi być liczbą dodatnią!';
    END IF;

    RETURN NEW;
END;
$function$
;

-- DROP FUNCTION zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_linii();

CREATE OR REPLACE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_linii()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM zarzadzanie_lotniskiem_v2.LinieLotnicze
        WHERE LOWER(nazwa) = LOWER(NEW.nazwa)
    ) THEN
        RAISE EXCEPTION 'Linia lotnicza o nazwie % już istnieje!', NEW.nazwa;
    END IF;

    RETURN NEW;
END;
$function$
;

-- DROP FUNCTION zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_terminalu();

CREATE OR REPLACE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_terminalu()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM zarzadzanie_lotniskiem_v2.Terminale
        WHERE LOWER(nazwa) = LOWER(NEW.nazwa)
    ) THEN
        RAISE EXCEPTION 'Terminal o nazwie % już istnieje!', NEW.nazwa;
    END IF;

    RETURN NEW;
END;
$function$
;

-- DROP FUNCTION zarzadzanie_lotniskiem_v2.waliduj_zaloge_samolotu();

CREATE OR REPLACE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_zaloge_samolotu()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM zarzadzanie_lotniskiem_v2.Zaloga
        WHERE samolot_id = NEW.samolot_id AND rola = 'Kapitan'
    ) THEN
        RAISE EXCEPTION 'Samolot musi mieć przypisanego Kapitana!';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM zarzadzanie_lotniskiem_v2.Zaloga
        WHERE samolot_id = NEW.samolot_id AND rola = 'Drugi Pilot'
    ) THEN
        RAISE EXCEPTION 'Samolot musi mieć przypisanego Drugiego Pilota!';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM zarzadzanie_lotniskiem_v2.Zaloga
        WHERE samolot_id = NEW.samolot_id AND rola = 'Obsługa Kabiny'
    ) THEN
        RAISE EXCEPTION 'Samolot musi mieć przynajmniej jednego członka Obsługi Kabiny!';
    END IF;

    RETURN NEW;
END;
$function$
;
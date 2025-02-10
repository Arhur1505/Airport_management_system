--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6
-- Dumped by pg_dump version 17.2

-- Started on 2025-01-14 21:06:08

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3577 (class 1262 OID 5)
-- Name: postgres; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C';


ALTER DATABASE postgres OWNER TO postgres;

\connect postgres

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 3577
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- TOC entry 9 (class 2615 OID 18137)
-- Name: zarzadzanie_lotniskiem_v2; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA zarzadzanie_lotniskiem_v2;


ALTER SCHEMA zarzadzanie_lotniskiem_v2 OWNER TO postgres;

--
-- TOC entry 298 (class 1255 OID 18303)
-- Name: waliduj_czas_lotu(); Type: FUNCTION; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_czas_lotu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.czas_przylotu <= NEW.czas_odlotu THEN
        RAISE EXCEPTION 'Czas przylotu musi być późniejszy niż czas odlotu!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION zarzadzanie_lotniskiem_v2.waliduj_czas_lotu() OWNER TO postgres;

--
-- TOC entry 291 (class 1255 OID 18307)
-- Name: waliduj_dostepnosc_samolotu(); Type: FUNCTION; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_dostepnosc_samolotu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION zarzadzanie_lotniskiem_v2.waliduj_dostepnosc_samolotu() OWNER TO postgres;

--
-- TOC entry 297 (class 1255 OID 18293)
-- Name: waliduj_imie_nazwisko_zalogi(); Type: FUNCTION; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_imie_nazwisko_zalogi() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
BEGIN
    IF NOT NEW.imie ~ '^[a-zA-ZąćęłńóśźżĄĘŁŃÓŚŹŻ\s]+$' THEN
        RAISE EXCEPTION 'Imię % zawiera niedozwolone znaki!', NEW.imie;
    END IF;

    IF NOT NEW.nazwisko ~ '^[a-zA-ZąćęłńóśźżĄĘŁŃÓŚŹŻ\s]+$' THEN
        RAISE EXCEPTION 'Nazwisko % zawiera niedozwolone znaki!', NEW.nazwisko;
    END IF;

    RETURN NEW;
END;
$_$;


ALTER FUNCTION zarzadzanie_lotniskiem_v2.waliduj_imie_nazwisko_zalogi() OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 18289)
-- Name: waliduj_kraj_linii(); Type: FUNCTION; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_kraj_linii() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
BEGIN
    IF NOT NEW.kraj ~ '^[a-zA-ZąćęłńóśźżĄĘüŁŃÓŚŹŻ\s]+$' THEN
        RAISE EXCEPTION 'Niepoprawny format kraju!';
    END IF;

    RETURN NEW;
END;
$_$;


ALTER FUNCTION zarzadzanie_lotniskiem_v2.waliduj_kraj_linii() OWNER TO postgres;

--
-- TOC entry 299 (class 1255 OID 18305)
-- Name: waliduj_poczatek_i_cel(); Type: FUNCTION; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_poczatek_i_cel() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF LOWER(NEW.poczatek) = LOWER(NEW.cel) THEN
        RAISE EXCEPTION 'Początek i cel lotu nie mogą być takie same!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION zarzadzanie_lotniskiem_v2.waliduj_poczatek_i_cel() OWNER TO postgres;

--
-- TOC entry 296 (class 1255 OID 18291)
-- Name: waliduj_pojemnosc_samolotu(); Type: FUNCTION; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_samolotu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.pojemnosc <= 0 THEN
        RAISE EXCEPTION 'Pojemność samolotu musi być liczbą dodatnią!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_samolotu() OWNER TO postgres;

--
-- TOC entry 290 (class 1255 OID 18277)
-- Name: waliduj_pojemnosc_terminalu(); Type: FUNCTION; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_terminalu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.pojemnosc <= 0 THEN
        RAISE EXCEPTION 'Pojemność terminalu musi być liczbą dodatnią!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_terminalu() OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 18285)
-- Name: waliduj_unikalnosc_linii(); Type: FUNCTION; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_linii() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_linii() OWNER TO postgres;

--
-- TOC entry 293 (class 1255 OID 18281)
-- Name: waliduj_unikalnosc_terminalu(); Type: FUNCTION; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_terminalu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_terminalu() OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 18313)
-- Name: waliduj_zaloge_samolotu(); Type: FUNCTION; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_zaloge_samolotu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Sprawdzenie, czy istnieje przynajmniej jeden kapitan dla danego samolotu
    IF NOT EXISTS (
        SELECT 1
        FROM zarzadzanie_lotniskiem_v2.Zaloga
        WHERE samolot_id = NEW.samolot_id AND rola = 'Kapitan'
    ) THEN
        RAISE EXCEPTION 'Samolot musi mieć przypisanego Kapitana!';
    END IF;

    -- Sprawdzenie, czy istnieje przynajmniej jeden drugi pilot dla danego samolotu
    IF NOT EXISTS (
        SELECT 1
        FROM zarzadzanie_lotniskiem_v2.Zaloga
        WHERE samolot_id = NEW.samolot_id AND rola = 'Drugi Pilot'
    ) THEN
        RAISE EXCEPTION 'Samolot musi mieć przypisanego Drugiego Pilota!';
    END IF;

    -- Sprawdzenie, czy istnieje przynajmniej jeden członek obsługi kabiny dla danego samolotu
    IF NOT EXISTS (
        SELECT 1
        FROM zarzadzanie_lotniskiem_v2.Zaloga
        WHERE samolot_id = NEW.samolot_id AND rola = 'Obsługa Kabiny'
    ) THEN
        RAISE EXCEPTION 'Samolot musi mieć przynajmniej jednego członka Obsługi Kabiny!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION zarzadzanie_lotniskiem_v2.waliduj_zaloge_samolotu() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 249 (class 1259 OID 18139)
-- Name: linielotnicze; Type: TABLE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TABLE zarzadzanie_lotniskiem_v2.linielotnicze (
    linia_id integer NOT NULL,
    nazwa character varying(100) NOT NULL,
    kraj character varying(100) NOT NULL
);


ALTER TABLE zarzadzanie_lotniskiem_v2.linielotnicze OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 18138)
-- Name: linielotnicze_linia_id_seq; Type: SEQUENCE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.linielotnicze_linia_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE zarzadzanie_lotniskiem_v2.linielotnicze_linia_id_seq OWNER TO postgres;

--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 248
-- Name: linielotnicze_linia_id_seq; Type: SEQUENCE OWNED BY; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER SEQUENCE zarzadzanie_lotniskiem_v2.linielotnicze_linia_id_seq OWNED BY zarzadzanie_lotniskiem_v2.linielotnicze.linia_id;


--
-- TOC entry 255 (class 1259 OID 18167)
-- Name: loty; Type: TABLE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TABLE zarzadzanie_lotniskiem_v2.loty (
    lot_id integer NOT NULL,
    numer_lotu character varying(10) NOT NULL,
    linia_id integer NOT NULL,
    samolot_id integer NOT NULL,
    poczatek character varying(100) NOT NULL,
    cel character varying(100) NOT NULL,
    czas_odlotu timestamp without time zone NOT NULL,
    czas_przylotu timestamp without time zone NOT NULL,
    status character varying(50) DEFAULT 'Zaplanowany'::character varying,
    terminal_id integer
);


ALTER TABLE zarzadzanie_lotniskiem_v2.loty OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 18166)
-- Name: loty_lot_id_seq; Type: SEQUENCE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.loty_lot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE zarzadzanie_lotniskiem_v2.loty_lot_id_seq OWNER TO postgres;

--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 254
-- Name: loty_lot_id_seq; Type: SEQUENCE OWNED BY; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER SEQUENCE zarzadzanie_lotniskiem_v2.loty_lot_id_seq OWNED BY zarzadzanie_lotniskiem_v2.loty.lot_id;


--
-- TOC entry 261 (class 1259 OID 18220)
-- Name: rezerwacje; Type: TABLE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TABLE zarzadzanie_lotniskiem_v2.rezerwacje (
    rezerwacja_id integer NOT NULL,
    u_id integer NOT NULL,
    lot_id integer NOT NULL,
    klasa_miejsca character varying(20) DEFAULT 'Ekonomiczna'::character varying,
    status character varying(50) DEFAULT 'Potwierdzona'::character varying
);


ALTER TABLE zarzadzanie_lotniskiem_v2.rezerwacje OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 18219)
-- Name: rezerwacje_rezerwacja_id_seq; Type: SEQUENCE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.rezerwacje_rezerwacja_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE zarzadzanie_lotniskiem_v2.rezerwacje_rezerwacja_id_seq OWNER TO postgres;

--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 260
-- Name: rezerwacje_rezerwacja_id_seq; Type: SEQUENCE OWNED BY; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER SEQUENCE zarzadzanie_lotniskiem_v2.rezerwacje_rezerwacja_id_seq OWNED BY zarzadzanie_lotniskiem_v2.rezerwacje.rezerwacja_id;


--
-- TOC entry 251 (class 1259 OID 18148)
-- Name: samoloty; Type: TABLE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TABLE zarzadzanie_lotniskiem_v2.samoloty (
    samolot_id integer NOT NULL,
    model character varying(50) NOT NULL,
    pojemnosc integer NOT NULL,
    linia_id integer NOT NULL
);


ALTER TABLE zarzadzanie_lotniskiem_v2.samoloty OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 18147)
-- Name: samoloty_samolot_id_seq; Type: SEQUENCE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.samoloty_samolot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE zarzadzanie_lotniskiem_v2.samoloty_samolot_id_seq OWNER TO postgres;

--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 250
-- Name: samoloty_samolot_id_seq; Type: SEQUENCE OWNED BY; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER SEQUENCE zarzadzanie_lotniskiem_v2.samoloty_samolot_id_seq OWNED BY zarzadzanie_lotniskiem_v2.samoloty.samolot_id;


--
-- TOC entry 253 (class 1259 OID 18160)
-- Name: terminale; Type: TABLE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TABLE zarzadzanie_lotniskiem_v2.terminale (
    terminal_id integer NOT NULL,
    nazwa character varying(50) NOT NULL,
    pojemnosc integer NOT NULL
);


ALTER TABLE zarzadzanie_lotniskiem_v2.terminale OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 18159)
-- Name: terminale_terminal_id_seq; Type: SEQUENCE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.terminale_terminal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE zarzadzanie_lotniskiem_v2.terminale_terminal_id_seq OWNER TO postgres;

--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 252
-- Name: terminale_terminal_id_seq; Type: SEQUENCE OWNED BY; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER SEQUENCE zarzadzanie_lotniskiem_v2.terminale_terminal_id_seq OWNED BY zarzadzanie_lotniskiem_v2.terminale.terminal_id;


--
-- TOC entry 259 (class 1259 OID 18207)
-- Name: uzytkownicy; Type: TABLE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TABLE zarzadzanie_lotniskiem_v2.uzytkownicy (
    u_id integer NOT NULL,
    imie character varying(50) NOT NULL,
    nazwisko character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    telefon character varying(20),
    haslo character varying(255) NOT NULL,
    rola character varying(20) NOT NULL,
    data_rejestracji timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uzytkownicy_rola_check CHECK (((rola)::text = ANY ((ARRAY['admin'::character varying, 'klient'::character varying])::text[])))
);


ALTER TABLE zarzadzanie_lotniskiem_v2.uzytkownicy OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 18206)
-- Name: uzytkownicy_u_id_seq; Type: SEQUENCE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.uzytkownicy_u_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE zarzadzanie_lotniskiem_v2.uzytkownicy_u_id_seq OWNER TO postgres;

--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 258
-- Name: uzytkownicy_u_id_seq; Type: SEQUENCE OWNED BY; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER SEQUENCE zarzadzanie_lotniskiem_v2.uzytkownicy_u_id_seq OWNED BY zarzadzanie_lotniskiem_v2.uzytkownicy.u_id;


--
-- TOC entry 268 (class 1259 OID 18263)
-- Name: widok_linie_lotnicze; Type: VIEW; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE VIEW zarzadzanie_lotniskiem_v2.widok_linie_lotnicze AS
 SELECT linia_id,
    nazwa,
    kraj
   FROM zarzadzanie_lotniskiem_v2.linielotnicze;


ALTER VIEW zarzadzanie_lotniskiem_v2.widok_linie_lotnicze OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 18242)
-- Name: widok_loty; Type: VIEW; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE VIEW zarzadzanie_lotniskiem_v2.widok_loty AS
 SELECT l.lot_id,
    l.numer_lotu,
    lin.nazwa AS nazwa_linii,
    sam.model AS model_samolotu,
    sam.pojemnosc AS pojemnosc_samolotu,
    ( SELECT count(*) AS count
           FROM zarzadzanie_lotniskiem_v2.rezerwacje r
          WHERE (r.lot_id = l.lot_id)) AS liczba_rezerwacji,
    l.poczatek,
    l.cel,
    l.czas_odlotu,
    l.czas_przylotu,
    t.nazwa AS terminal
   FROM (((zarzadzanie_lotniskiem_v2.loty l
     JOIN zarzadzanie_lotniskiem_v2.linielotnicze lin ON ((l.linia_id = lin.linia_id)))
     JOIN zarzadzanie_lotniskiem_v2.samoloty sam ON ((l.samolot_id = sam.samolot_id)))
     LEFT JOIN zarzadzanie_lotniskiem_v2.terminale t ON ((l.terminal_id = t.terminal_id)));


ALTER VIEW zarzadzanie_lotniskiem_v2.widok_loty OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 18259)
-- Name: widok_loty_na_linie; Type: VIEW; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE VIEW zarzadzanie_lotniskiem_v2.widok_loty_na_linie AS
 SELECT lin.linia_id,
    lin.nazwa AS linia_lotnicza,
    count(l.lot_id) AS liczba_lotow
   FROM (zarzadzanie_lotniskiem_v2.loty l
     JOIN zarzadzanie_lotniskiem_v2.linielotnicze lin ON ((l.linia_id = lin.linia_id)))
  GROUP BY lin.linia_id, lin.nazwa;


ALTER VIEW zarzadzanie_lotniskiem_v2.widok_loty_na_linie OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 18247)
-- Name: widok_loty_na_terminal; Type: VIEW; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE VIEW zarzadzanie_lotniskiem_v2.widok_loty_na_terminal AS
 SELECT t.terminal_id,
    t.nazwa AS nazwa_terminalu,
    count(l.lot_id) AS liczba_lotow
   FROM (zarzadzanie_lotniskiem_v2.terminale t
     LEFT JOIN zarzadzanie_lotniskiem_v2.loty l ON ((t.terminal_id = l.terminal_id)))
  GROUP BY t.terminal_id, t.nazwa;


ALTER VIEW zarzadzanie_lotniskiem_v2.widok_loty_na_terminal OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 18309)
-- Name: widok_rezerwacje_dla_lotu; Type: VIEW; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE VIEW zarzadzanie_lotniskiem_v2.widok_rezerwacje_dla_lotu AS
 SELECT r.rezerwacja_id,
    u.imie,
    u.nazwisko,
    u.email,
    u.telefon,
    r.klasa_miejsca,
    r.status,
    r.lot_id
   FROM (zarzadzanie_lotniskiem_v2.rezerwacje r
     JOIN zarzadzanie_lotniskiem_v2.uzytkownicy u ON ((r.u_id = u.u_id)));


ALTER VIEW zarzadzanie_lotniskiem_v2.widok_rezerwacje_dla_lotu OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 18271)
-- Name: widok_samoloty; Type: VIEW; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE VIEW zarzadzanie_lotniskiem_v2.widok_samoloty AS
 SELECT s.samolot_id,
    s.model,
    s.pojemnosc,
    s.linia_id,
    l.nazwa AS nazwa_linii
   FROM (zarzadzanie_lotniskiem_v2.samoloty s
     JOIN zarzadzanie_lotniskiem_v2.linielotnicze l ON ((s.linia_id = l.linia_id)));


ALTER VIEW zarzadzanie_lotniskiem_v2.widok_samoloty OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 18267)
-- Name: widok_terminali; Type: VIEW; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE VIEW zarzadzanie_lotniskiem_v2.widok_terminali AS
 SELECT terminal_id,
    nazwa,
    pojemnosc
   FROM zarzadzanie_lotniskiem_v2.terminale;


ALTER VIEW zarzadzanie_lotniskiem_v2.widok_terminali OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 18238)
-- Name: widok_uzytkownicy; Type: VIEW; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE VIEW zarzadzanie_lotniskiem_v2.widok_uzytkownicy AS
 SELECT u_id,
    imie,
    nazwisko,
    email,
    telefon,
    rola,
    date(data_rejestracji) AS data_rejestracji,
    COALESCE(( SELECT count(*) AS count
           FROM zarzadzanie_lotniskiem_v2.rezerwacje r
          WHERE (r.u_id = u.u_id)), (0)::bigint) AS liczba_rezerwacji
   FROM zarzadzanie_lotniskiem_v2.uzytkownicy u;


ALTER VIEW zarzadzanie_lotniskiem_v2.widok_uzytkownicy OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 18190)
-- Name: zaloga; Type: TABLE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TABLE zarzadzanie_lotniskiem_v2.zaloga (
    zaloga_id integer NOT NULL,
    imie character varying(50) NOT NULL,
    nazwisko character varying(50) NOT NULL,
    rola character varying(50) NOT NULL,
    linia_id integer NOT NULL,
    samolot_id integer NOT NULL
);


ALTER TABLE zarzadzanie_lotniskiem_v2.zaloga OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 18251)
-- Name: widok_zaloga; Type: VIEW; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE VIEW zarzadzanie_lotniskiem_v2.widok_zaloga AS
 SELECT z.zaloga_id,
    z.imie,
    z.nazwisko,
    z.rola,
    l.nazwa AS nazwa_linii,
    z.samolot_id
   FROM (zarzadzanie_lotniskiem_v2.zaloga z
     JOIN zarzadzanie_lotniskiem_v2.linielotnicze l ON ((z.linia_id = l.linia_id)));


ALTER VIEW zarzadzanie_lotniskiem_v2.widok_zaloga OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 18255)
-- Name: widok_zaloga_na_samolot; Type: VIEW; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE VIEW zarzadzanie_lotniskiem_v2.widok_zaloga_na_samolot AS
 SELECT s.samolot_id,
    s.model AS model_samolotu,
    count(z.zaloga_id) AS liczba_zalogi
   FROM (zarzadzanie_lotniskiem_v2.samoloty s
     LEFT JOIN zarzadzanie_lotniskiem_v2.zaloga z ON ((s.samolot_id = z.samolot_id)))
  GROUP BY s.samolot_id, s.model;


ALTER VIEW zarzadzanie_lotniskiem_v2.widok_zaloga_na_samolot OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 18189)
-- Name: zaloga_zaloga_id_seq; Type: SEQUENCE; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE SEQUENCE zarzadzanie_lotniskiem_v2.zaloga_zaloga_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE zarzadzanie_lotniskiem_v2.zaloga_zaloga_id_seq OWNER TO postgres;

--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 256
-- Name: zaloga_zaloga_id_seq; Type: SEQUENCE OWNED BY; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER SEQUENCE zarzadzanie_lotniskiem_v2.zaloga_zaloga_id_seq OWNED BY zarzadzanie_lotniskiem_v2.zaloga.zaloga_id;


--
-- TOC entry 3345 (class 2604 OID 18142)
-- Name: linielotnicze linia_id; Type: DEFAULT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.linielotnicze ALTER COLUMN linia_id SET DEFAULT nextval('zarzadzanie_lotniskiem_v2.linielotnicze_linia_id_seq'::regclass);


--
-- TOC entry 3348 (class 2604 OID 18170)
-- Name: loty lot_id; Type: DEFAULT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.loty ALTER COLUMN lot_id SET DEFAULT nextval('zarzadzanie_lotniskiem_v2.loty_lot_id_seq'::regclass);


--
-- TOC entry 3353 (class 2604 OID 18223)
-- Name: rezerwacje rezerwacja_id; Type: DEFAULT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.rezerwacje ALTER COLUMN rezerwacja_id SET DEFAULT nextval('zarzadzanie_lotniskiem_v2.rezerwacje_rezerwacja_id_seq'::regclass);


--
-- TOC entry 3346 (class 2604 OID 18151)
-- Name: samoloty samolot_id; Type: DEFAULT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.samoloty ALTER COLUMN samolot_id SET DEFAULT nextval('zarzadzanie_lotniskiem_v2.samoloty_samolot_id_seq'::regclass);


--
-- TOC entry 3347 (class 2604 OID 18163)
-- Name: terminale terminal_id; Type: DEFAULT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.terminale ALTER COLUMN terminal_id SET DEFAULT nextval('zarzadzanie_lotniskiem_v2.terminale_terminal_id_seq'::regclass);


--
-- TOC entry 3351 (class 2604 OID 18210)
-- Name: uzytkownicy u_id; Type: DEFAULT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.uzytkownicy ALTER COLUMN u_id SET DEFAULT nextval('zarzadzanie_lotniskiem_v2.uzytkownicy_u_id_seq'::regclass);


--
-- TOC entry 3350 (class 2604 OID 18193)
-- Name: zaloga zaloga_id; Type: DEFAULT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.zaloga ALTER COLUMN zaloga_id SET DEFAULT nextval('zarzadzanie_lotniskiem_v2.zaloga_zaloga_id_seq'::regclass);


--
-- TOC entry 3559 (class 0 OID 18139)
-- Dependencies: 249
-- Data for Name: linielotnicze; Type: TABLE DATA; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

INSERT INTO zarzadzanie_lotniskiem_v2.linielotnicze VALUES (19, 'Ryanair', 'Irlandia');
INSERT INTO zarzadzanie_lotniskiem_v2.linielotnicze VALUES (20, 'Lufthansa', 'Niemcy');
INSERT INTO zarzadzanie_lotniskiem_v2.linielotnicze VALUES (21, 'LOT Polish Airlines', 'Polska');
INSERT INTO zarzadzanie_lotniskiem_v2.linielotnicze VALUES (22, 'Wizz Air', 'Węgry');
INSERT INTO zarzadzanie_lotniskiem_v2.linielotnicze VALUES (23, 'Air France', 'Francja');


--
-- TOC entry 3565 (class 0 OID 18167)
-- Dependencies: 255
-- Data for Name: loty; Type: TABLE DATA; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

INSERT INTO zarzadzanie_lotniskiem_v2.loty VALUES (39, 'FR101', 19, 15, 'Dublin', 'Warszawa', '2025-01-06 08:00:00', '2025-01-06 10:30:00', 'Zaplanowany', 36);
INSERT INTO zarzadzanie_lotniskiem_v2.loty VALUES (40, 'FR102', 19, 15, 'Warszawa', 'Londyn', '2025-01-06 15:00:00', '2025-01-06 16:30:00', 'Zaplanowany', 36);
INSERT INTO zarzadzanie_lotniskiem_v2.loty VALUES (41, 'LH201', 20, 16, 'Frankfurt', 'Nowy Jork', '2025-01-07 12:00:00', '2025-01-07 20:00:00', 'Zaplanowany', 37);
INSERT INTO zarzadzanie_lotniskiem_v2.loty VALUES (42, 'LH202', 20, 16, 'Nowy Jork', 'Frankfurt', '2025-01-08 14:00:00', '2025-01-08 22:00:00', 'Zaplanowany', 37);
INSERT INTO zarzadzanie_lotniskiem_v2.loty VALUES (43, 'LO301', 21, 17, 'Warszawa', 'Chicago', '2025-01-07 09:00:00', '2025-01-07 17:30:00', 'Zaplanowany', 38);
INSERT INTO zarzadzanie_lotniskiem_v2.loty VALUES (44, 'LO302', 21, 17, 'Chicago', 'Warszawa', '2025-01-08 19:00:00', '2025-01-09 03:30:00', 'Zaplanowany', 38);
INSERT INTO zarzadzanie_lotniskiem_v2.loty VALUES (45, 'WZ401', 22, 18, 'Budapeszt', 'Londyn', '2025-01-06 11:00:00', '2025-01-06 13:00:00', 'Zaplanowany', 36);
INSERT INTO zarzadzanie_lotniskiem_v2.loty VALUES (46, 'WZ402', 22, 18, 'Londyn', 'Budapeszt', '2025-01-06 17:00:00', '2025-01-06 19:00:00', 'Zaplanowany', 36);
INSERT INTO zarzadzanie_lotniskiem_v2.loty VALUES (47, 'AF501', 23, 19, 'Paryż', 'Tokio', '2025-01-08 07:00:00', '2025-01-08 21:00:00', 'Zaplanowany', 37);
INSERT INTO zarzadzanie_lotniskiem_v2.loty VALUES (48, 'AF502', 23, 19, 'Tokio', 'Paryż', '2025-01-10 10:00:00', '2025-01-10 22:00:00', 'Zaplanowany', 37);


--
-- TOC entry 3571 (class 0 OID 18220)
-- Dependencies: 261
-- Data for Name: rezerwacje; Type: TABLE DATA; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

INSERT INTO zarzadzanie_lotniskiem_v2.rezerwacje VALUES (1, 8, 39, 'Ekonomiczna', 'Potwierdzona');
INSERT INTO zarzadzanie_lotniskiem_v2.rezerwacje VALUES (2, 8, 39, 'Biznes', 'Potwierdzona');


--
-- TOC entry 3561 (class 0 OID 18148)
-- Dependencies: 251
-- Data for Name: samoloty; Type: TABLE DATA; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

INSERT INTO zarzadzanie_lotniskiem_v2.samoloty VALUES (15, 'Boeing 737', 180, 19);
INSERT INTO zarzadzanie_lotniskiem_v2.samoloty VALUES (16, 'Airbus A320', 200, 20);
INSERT INTO zarzadzanie_lotniskiem_v2.samoloty VALUES (17, 'Boeing 787', 240, 21);
INSERT INTO zarzadzanie_lotniskiem_v2.samoloty VALUES (18, 'Airbus A321', 220, 22);
INSERT INTO zarzadzanie_lotniskiem_v2.samoloty VALUES (19, 'Airbus A380', 850, 23);


--
-- TOC entry 3563 (class 0 OID 18160)
-- Dependencies: 253
-- Data for Name: terminale; Type: TABLE DATA; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

INSERT INTO zarzadzanie_lotniskiem_v2.terminale VALUES (36, 'Terminal A', 6);
INSERT INTO zarzadzanie_lotniskiem_v2.terminale VALUES (37, 'Terminal B', 6);
INSERT INTO zarzadzanie_lotniskiem_v2.terminale VALUES (38, 'Terminal C', 6);


--
-- TOC entry 3569 (class 0 OID 18207)
-- Dependencies: 259
-- Data for Name: uzytkownicy; Type: TABLE DATA; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

INSERT INTO zarzadzanie_lotniskiem_v2.uzytkownicy VALUES (7, 'Anna', 'Nowak', 'anna.nowak@admin.com', '123456789', '$2y$10$3WXAh/knmuHjNUO6aHimR.TehK7G54oA8hz19cvY8/r851NRATwVm', 'admin', '2025-01-06 09:00:20.863646');
INSERT INTO zarzadzanie_lotniskiem_v2.uzytkownicy VALUES (8, 'Jan', 'Kowalski', 'jan.kowalski@admin.com', '987654321', '$2y$10$nTgoN8fy2effPI5nq1Q4p.rywc96RM0TBtlTa/1h78C2WI6DkLh7O', 'admin', '2025-01-06 09:00:57.69652');
INSERT INTO zarzadzanie_lotniskiem_v2.uzytkownicy VALUES (9, 'Piotr', 'Wiśniewski', 'piotr.wisniewski@klient.com', '123123123', '$2y$10$jhwQaRlW0iyqMgxipDWA9.sycMBQjEoeeb.AQGUDP0iRGr7IBJ2Be', 'klient', '2025-01-06 09:02:42.530568');
INSERT INTO zarzadzanie_lotniskiem_v2.uzytkownicy VALUES (10, 'Maria', 'Kowalczyk', 'maria.kowalczyk@klient.com', '321321321', '$2y$10$FY7Hj.yX1c11RvkMaH1BY.Fmexp8YUXHppAaamgrkA8pb4Drthguq', 'klient', '2025-01-06 09:04:36.280922');
INSERT INTO zarzadzanie_lotniskiem_v2.uzytkownicy VALUES (11, 'Jan1', 'Nowak1', 'jan.kowalski@example.com', '123', '$2y$10$/2bBFvzpJX5uziARu.S1SOXwOOWRa1hLu952DxhnzsF9hKlzBXCEu', 'admin', '2025-01-14 11:09:09.462874');


--
-- TOC entry 3567 (class 0 OID 18190)
-- Dependencies: 257
-- Data for Name: zaloga; Type: TABLE DATA; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (16, 'Marek', 'Wiśniewski', 'Drugi Pilot', 19, 15);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (17, 'Anna', 'Nowak', 'Obsługa Kabiny', 19, 15);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (18, 'Peter', 'Schmidt', 'Kapitan', 20, 16);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (19, 'Hans', 'Muller', 'Drugi Pilot', 20, 16);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (20, 'Laura', 'Meier', 'Obsługa Kabiny', 20, 16);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (21, 'Piotr', 'Wiśniewski', 'Kapitan', 21, 17);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (22, 'Michał', 'Kowalczyk', 'Drugi Pilot', 21, 17);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (23, 'Katarzyna', 'Zielińska', 'Obsługa Kabiny', 21, 17);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (24, 'Gabor', 'Nagy', 'Kapitan', 22, 18);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (25, 'Istvan', 'Kovacs', 'Drugi Pilot', 22, 18);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (26, 'Zsófia', 'Kiss', 'Obsługa Kabiny', 22, 18);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (27, 'Jacques', 'Dupont', 'Kapitan', 23, 19);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (28, 'Henri', 'Lemoine', 'Drugi Pilot', 23, 19);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (29, 'Marie', 'Curie', 'Obsługa Kabiny', 23, 19);
INSERT INTO zarzadzanie_lotniskiem_v2.zaloga VALUES (30, 'Jan', 'Kowalski', 'Kapitan', 19, 15);


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 248
-- Name: linielotnicze_linia_id_seq; Type: SEQUENCE SET; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

SELECT pg_catalog.setval('zarzadzanie_lotniskiem_v2.linielotnicze_linia_id_seq', 23, true);


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 254
-- Name: loty_lot_id_seq; Type: SEQUENCE SET; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

SELECT pg_catalog.setval('zarzadzanie_lotniskiem_v2.loty_lot_id_seq', 49, true);


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 260
-- Name: rezerwacje_rezerwacja_id_seq; Type: SEQUENCE SET; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

SELECT pg_catalog.setval('zarzadzanie_lotniskiem_v2.rezerwacje_rezerwacja_id_seq', 2, true);


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 250
-- Name: samoloty_samolot_id_seq; Type: SEQUENCE SET; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

SELECT pg_catalog.setval('zarzadzanie_lotniskiem_v2.samoloty_samolot_id_seq', 19, true);


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 252
-- Name: terminale_terminal_id_seq; Type: SEQUENCE SET; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

SELECT pg_catalog.setval('zarzadzanie_lotniskiem_v2.terminale_terminal_id_seq', 39, true);


--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 258
-- Name: uzytkownicy_u_id_seq; Type: SEQUENCE SET; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

SELECT pg_catalog.setval('zarzadzanie_lotniskiem_v2.uzytkownicy_u_id_seq', 11, true);


--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 256
-- Name: zaloga_zaloga_id_seq; Type: SEQUENCE SET; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

SELECT pg_catalog.setval('zarzadzanie_lotniskiem_v2.zaloga_zaloga_id_seq', 30, true);


--
-- TOC entry 3358 (class 2606 OID 18146)
-- Name: linielotnicze linielotnicze_nazwa_key; Type: CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.linielotnicze
    ADD CONSTRAINT linielotnicze_nazwa_key UNIQUE (nazwa);


--
-- TOC entry 3360 (class 2606 OID 18144)
-- Name: linielotnicze linielotnicze_pkey; Type: CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.linielotnicze
    ADD CONSTRAINT linielotnicze_pkey PRIMARY KEY (linia_id);


--
-- TOC entry 3366 (class 2606 OID 18173)
-- Name: loty loty_pkey; Type: CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.loty
    ADD CONSTRAINT loty_pkey PRIMARY KEY (lot_id);


--
-- TOC entry 3376 (class 2606 OID 18227)
-- Name: rezerwacje rezerwacje_pkey; Type: CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.rezerwacje
    ADD CONSTRAINT rezerwacje_pkey PRIMARY KEY (rezerwacja_id);


--
-- TOC entry 3362 (class 2606 OID 18153)
-- Name: samoloty samoloty_pkey; Type: CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.samoloty
    ADD CONSTRAINT samoloty_pkey PRIMARY KEY (samolot_id);


--
-- TOC entry 3364 (class 2606 OID 18165)
-- Name: terminale terminale_pkey; Type: CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.terminale
    ADD CONSTRAINT terminale_pkey PRIMARY KEY (terminal_id);


--
-- TOC entry 3368 (class 2606 OID 18302)
-- Name: loty unique_numer_lotu; Type: CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.loty
    ADD CONSTRAINT unique_numer_lotu UNIQUE (numer_lotu);


--
-- TOC entry 3372 (class 2606 OID 18218)
-- Name: uzytkownicy uzytkownicy_email_key; Type: CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.uzytkownicy
    ADD CONSTRAINT uzytkownicy_email_key UNIQUE (email);


--
-- TOC entry 3374 (class 2606 OID 18216)
-- Name: uzytkownicy uzytkownicy_pkey; Type: CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.uzytkownicy
    ADD CONSTRAINT uzytkownicy_pkey PRIMARY KEY (u_id);


--
-- TOC entry 3370 (class 2606 OID 18195)
-- Name: zaloga zaloga_pkey; Type: CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.zaloga
    ADD CONSTRAINT zaloga_pkey PRIMARY KEY (zaloga_id);


--
-- TOC entry 3390 (class 2620 OID 18304)
-- Name: loty trigger_waliduj_czas_lotu; Type: TRIGGER; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TRIGGER trigger_waliduj_czas_lotu BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.loty FOR EACH ROW EXECUTE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_czas_lotu();


--
-- TOC entry 3391 (class 2620 OID 18308)
-- Name: loty trigger_waliduj_dostepnosc_samolotu; Type: TRIGGER; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TRIGGER trigger_waliduj_dostepnosc_samolotu BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.loty FOR EACH ROW EXECUTE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_dostepnosc_samolotu();


--
-- TOC entry 3394 (class 2620 OID 18294)
-- Name: zaloga trigger_waliduj_imie_nazwisko_zalogi; Type: TRIGGER; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TRIGGER trigger_waliduj_imie_nazwisko_zalogi BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.zaloga FOR EACH ROW EXECUTE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_imie_nazwisko_zalogi();


--
-- TOC entry 3385 (class 2620 OID 18290)
-- Name: linielotnicze trigger_waliduj_kraj_linii; Type: TRIGGER; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TRIGGER trigger_waliduj_kraj_linii BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.linielotnicze FOR EACH ROW EXECUTE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_kraj_linii();


--
-- TOC entry 3392 (class 2620 OID 18306)
-- Name: loty trigger_waliduj_poczatek_i_cel; Type: TRIGGER; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TRIGGER trigger_waliduj_poczatek_i_cel BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.loty FOR EACH ROW EXECUTE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_poczatek_i_cel();


--
-- TOC entry 3387 (class 2620 OID 18292)
-- Name: samoloty trigger_waliduj_pojemnosc_samolotu; Type: TRIGGER; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TRIGGER trigger_waliduj_pojemnosc_samolotu BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.samoloty FOR EACH ROW EXECUTE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_samolotu();


--
-- TOC entry 3388 (class 2620 OID 18278)
-- Name: terminale trigger_waliduj_pojemnosc_terminalu; Type: TRIGGER; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TRIGGER trigger_waliduj_pojemnosc_terminalu BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.terminale FOR EACH ROW EXECUTE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_pojemnosc_terminalu();


--
-- TOC entry 3386 (class 2620 OID 18286)
-- Name: linielotnicze trigger_waliduj_unikalnosc_linii; Type: TRIGGER; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TRIGGER trigger_waliduj_unikalnosc_linii BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.linielotnicze FOR EACH ROW EXECUTE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_linii();


--
-- TOC entry 3389 (class 2620 OID 18282)
-- Name: terminale trigger_waliduj_unikalnosc_terminalu; Type: TRIGGER; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TRIGGER trigger_waliduj_unikalnosc_terminalu BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.terminale FOR EACH ROW EXECUTE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_unikalnosc_terminalu();


--
-- TOC entry 3393 (class 2620 OID 18314)
-- Name: loty trigger_waliduj_zaloge_samolotu; Type: TRIGGER; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

CREATE TRIGGER trigger_waliduj_zaloge_samolotu BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.loty FOR EACH ROW EXECUTE FUNCTION zarzadzanie_lotniskiem_v2.waliduj_zaloge_samolotu();


--
-- TOC entry 3378 (class 2606 OID 18174)
-- Name: loty loty_linia_id_fkey; Type: FK CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.loty
    ADD CONSTRAINT loty_linia_id_fkey FOREIGN KEY (linia_id) REFERENCES zarzadzanie_lotniskiem_v2.linielotnicze(linia_id) ON DELETE CASCADE;


--
-- TOC entry 3379 (class 2606 OID 18179)
-- Name: loty loty_samolot_id_fkey; Type: FK CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.loty
    ADD CONSTRAINT loty_samolot_id_fkey FOREIGN KEY (samolot_id) REFERENCES zarzadzanie_lotniskiem_v2.samoloty(samolot_id) ON DELETE CASCADE;


--
-- TOC entry 3380 (class 2606 OID 18184)
-- Name: loty loty_terminal_id_fkey; Type: FK CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.loty
    ADD CONSTRAINT loty_terminal_id_fkey FOREIGN KEY (terminal_id) REFERENCES zarzadzanie_lotniskiem_v2.terminale(terminal_id) ON DELETE CASCADE;


--
-- TOC entry 3383 (class 2606 OID 18233)
-- Name: rezerwacje rezerwacje_lot_id_fkey; Type: FK CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.rezerwacje
    ADD CONSTRAINT rezerwacje_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES zarzadzanie_lotniskiem_v2.loty(lot_id) ON DELETE CASCADE;


--
-- TOC entry 3384 (class 2606 OID 18228)
-- Name: rezerwacje rezerwacje_u_id_fkey; Type: FK CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.rezerwacje
    ADD CONSTRAINT rezerwacje_u_id_fkey FOREIGN KEY (u_id) REFERENCES zarzadzanie_lotniskiem_v2.uzytkownicy(u_id) ON DELETE CASCADE;


--
-- TOC entry 3377 (class 2606 OID 18154)
-- Name: samoloty samoloty_linia_id_fkey; Type: FK CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.samoloty
    ADD CONSTRAINT samoloty_linia_id_fkey FOREIGN KEY (linia_id) REFERENCES zarzadzanie_lotniskiem_v2.linielotnicze(linia_id) ON DELETE CASCADE;


--
-- TOC entry 3381 (class 2606 OID 18196)
-- Name: zaloga zaloga_linia_id_fkey; Type: FK CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.zaloga
    ADD CONSTRAINT zaloga_linia_id_fkey FOREIGN KEY (linia_id) REFERENCES zarzadzanie_lotniskiem_v2.linielotnicze(linia_id) ON DELETE CASCADE;


--
-- TOC entry 3382 (class 2606 OID 18201)
-- Name: zaloga zaloga_samolot_id_fkey; Type: FK CONSTRAINT; Schema: zarzadzanie_lotniskiem_v2; Owner: postgres
--

ALTER TABLE ONLY zarzadzanie_lotniskiem_v2.zaloga
    ADD CONSTRAINT zaloga_samolot_id_fkey FOREIGN KEY (samolot_id) REFERENCES zarzadzanie_lotniskiem_v2.samoloty(samolot_id) ON DELETE CASCADE;


-- Completed on 2025-01-14 21:06:15

--
-- PostgreSQL database dump complete
--


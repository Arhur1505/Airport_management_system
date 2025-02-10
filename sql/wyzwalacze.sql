-- Wyzwalacz weryfikujący przypisanie załogi do samolotu
-- Sprawdza, czy każdy samolot ma przypisanego Kapitana, Drugiego Pilota oraz Obsługę Kabiny
CREATE OR REPLACE FUNCTION waliduj_zaloge_samolotu()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_waliduj_zaloge_samolotu
BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.Loty
FOR EACH ROW
EXECUTE FUNCTION waliduj_zaloge_samolotu();

-- Wyzwalacz weryfikujący poprawność pojemności terminalu
-- Zapobiega wprowadzeniu terminalu o pojemności <= 0
CREATE OR REPLACE FUNCTION waliduj_pojemnosc_terminalu()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pojemnosc <= 0 THEN
        RAISE EXCEPTION 'Pojemność terminalu musi być liczbą dodatnią!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Wyzwalacz sprawdzający unikalność nazwy terminalu
-- Zapobiega duplikacji nazw terminali
CREATE OR REPLACE FUNCTION waliduj_unikalnosc_terminalu()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_waliduj_unikalnosc_terminalu
BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.Terminale
FOR EACH ROW
EXECUTE FUNCTION waliduj_unikalnosc_terminalu();

-- Wyzwalacz sprawdzający unikalność nazwy linii lotniczej
CREATE OR REPLACE FUNCTION waliduj_unikalnosc_linii()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_waliduj_unikalnosc_linii
BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.LinieLotnicze
FOR EACH ROW
EXECUTE FUNCTION waliduj_unikalnosc_linii();

-- Wyzwalacz weryfikujący poprawność nazwy kraju linii lotniczej
CREATE OR REPLACE FUNCTION waliduj_kraj_linii()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT NEW.kraj ~ '^[a-zA-ZąćęłńóśźżĄĘŁŃÓŚŹŻ\s]+$' THEN
        RAISE EXCEPTION 'Niepoprawny format kraju!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_waliduj_kraj_linii
BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.LinieLotnicze
FOR EACH ROW
EXECUTE FUNCTION waliduj_kraj_linii();

-- Wyzwalacz sprawdzający poprawność pojemności samolotu
CREATE OR REPLACE FUNCTION waliduj_pojemnosc_samolotu()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pojemnosc <= 0 THEN
        RAISE EXCEPTION 'Pojemność samolotu musi być liczbą dodatnią!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_waliduj_pojemnosc_samolotu
BEFORE INSERT OR UPDATE ON zarzadzanie_lotniskiem_v2.Samoloty
FOR EACH ROW
EXECUTE FUNCTION waliduj_pojemnosc_samolotu();

-- Wyzwalacz sprawdzający poprawność imienia i nazwiska członków załogi
CREATE OR REPLACE FUNCTION waliduj_imie_nazwisko_zalogi()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT NEW.imie ~ '^[a-zA-ZąćęłńóśźżĄĘŁŃÓŚŹŻ\s]+$' THEN
        RAISE EXCEPTION 'Imię % zawiera niedozwolone znaki!', NEW.imie;
    END IF;

    IF NOT NEW.nazwisko ~ '^[a-zA-ZąćęłńóśźżĄĘŁŃÓŚŹŻ\s]+$' THEN
        RAISE EXCEPTION 'Nazwisko % zawiera niedozwolone znaki!', NEW.nazwisko;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_waliduj_imie_nazwisko_zalogi
BEFORE INSERT OR UPDATE ON Zaloga
FOR EACH ROW
EXECUTE FUNCTION waliduj_imie_nazwisko_zalogi();

-- Wyzwalacz sprawdzający poprawność czasów odlotu i przylotu lotu
CREATE OR REPLACE FUNCTION waliduj_czas_lotu()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.czas_przylotu <= NEW.czas_odlotu THEN
        RAISE EXCEPTION 'Czas przylotu musi być późniejszy niż czas odlotu!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_waliduj_czas_lotu
BEFORE INSERT OR UPDATE ON Loty
FOR EACH ROW
EXECUTE FUNCTION waliduj_czas_lotu();

-- Wyzwalacz sprawdzający, czy początek i cel lotu nie są takie same
CREATE OR REPLACE FUNCTION waliduj_poczatek_i_cel()
RETURNS TRIGGER AS $$
BEGIN
    IF LOWER(NEW.poczatek) = LOWER(NEW.cel) THEN
        RAISE EXCEPTION 'Początek i cel lotu nie mogą być takie same!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_waliduj_poczatek_i_cel
BEFORE INSERT OR UPDATE ON Loty
FOR EACH ROW
EXECUTE FUNCTION waliduj_poczatek_i_cel();

-- Wyzwalacz weryfikujący dostępność samolotu dla nowego lotu w określonym czasie
CREATE OR REPLACE FUNCTION waliduj_dostepnosc_samolotu()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_waliduj_dostepnosc_samolotu
BEFORE INSERT OR UPDATE ON Loty
FOR EACH ROW
EXECUTE FUNCTION waliduj_dostepnosc_samolotu();

-- Dodanie unikalności numeru lotu w tabeli Loty
ALTER TABLE zarzadzanie_lotniskiem_v2.Loty
ADD CONSTRAINT unique_numer_lotu UNIQUE (numer_lotu);
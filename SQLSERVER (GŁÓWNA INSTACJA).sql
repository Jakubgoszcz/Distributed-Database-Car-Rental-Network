use Test

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
EXEC sp_addlinkedserver 
    @server = 'OracleLinkedServer', 
    @srvproduct = 'Oracle', 
    @provider = 'OraOLEDB.Oracle', 
    @datasrc = 'pd19';

EXEC sp_addlinkedsrvlogin 
    @rmtsrvname = 'OracleLinkedServer', 
    @useself = 'false', 
    @locallogin = NULL, 
    @rmtuser = 'SCOTT', 
    @rmtpassword = '12345';

EXEC sp_addlinkedserver 
    @server = 'OracleLinkedServer2', 
    @srvproduct = 'Oracle', 
    @provider = 'OraOLEDB.Oracle', 
    @datasrc = 'pd20';

EXEC sp_addlinkedsrvlogin 
    @rmtsrvname = 'OracleLinkedServer2', 
    @useself = 'false', 
    @locallogin = NULL, 
    @rmtuser = 'SCOTT', 
    @rmtpassword = '12345';


EXEC sp_serveroption @server = 'OracleLinkedServer', @optname = 'rpc out', @optvalue = 'true';
EXEC sp_serveroption @server = 'OracleLinkedServer', @optname = 'data access', @optvalue = 'true';
EXEC sp_serveroption @server = 'OracleLinkedServer2', @optname = 'rpc out', @optvalue = 'true';
EXEC sp_serveroption @server = 'OracleLinkedServer2', @optname = 'data access', @optvalue = 'true';


exec sp_linkedservers

CREATE OR ALTER VIEW WypozyczeniaView AS
SELECT * 
FROM OPENQUERY(OracleLinkedServer, 'select * from TABLE(pobierz_wszystkie_wypozyczenia)');

CREATE OR ALTER VIEW SamochodyView AS
SELECT * 
FROM OPENQUERY(OracleLinkedServer, 'SELECT * FROM TABLE(pobierz_wszystkie_samochody)');

CREATE OR ALTER VIEW PracownicyView AS
SELECT * 
FROM OPENQUERY(OracleLinkedServer, 'SELECT * FROM TABLE(pobierz_wszystkich_pracownikow)');

CREATE OR ALTER VIEW TypySamochodowView AS
SELECT * 
FROM OPENQUERY(OracleLinkedServer, 'SELECT * FROM TYPY_SAMOCHODOW');

CREATE OR ALTER VIEW KlienciView AS
SELECT * 
FROM OPENQUERY(OracleLinkedServer, 'SELECT * FROM TABLE(pobierz_wszystkich_klientow)');



CREATE OR ALTER VIEW WypozyczeniaView2 AS
SELECT * 
FROM OPENQUERY(OracleLinkedServer2, 'select * from TABLE(pobierz_wszystkie_wypozyczenia)');

CREATE OR ALTER VIEW SamochodyView2 AS
SELECT * 
FROM OPENQUERY(OracleLinkedServer2, 'SELECT * FROM TABLE(pobierz_wszystkie_samochody)');

CREATE OR ALTER VIEW PracownicyView2 AS
SELECT * 
FROM OPENQUERY(OracleLinkedServer2, 'SELECT * FROM TABLE(pobierz_wszystkich_pracownikow)');

CREATE OR ALTER VIEW TypySamochodowView2 AS
SELECT * 
FROM OPENQUERY(OracleLinkedServer2, 'SELECT * FROM TYPY_SAMOCHODOW');

CREATE OR ALTER VIEW KlienciView2 AS
SELECT * 
FROM OPENQUERY(OracleLinkedServer2, 'SELECT * FROM TABLE(pobierz_wszystkich_klientow)');


select * from SamochodyView;
go
select * from WypozyczeniaView;
go
select * from PracownicyView;
go
select * from TypySamochodowView;
go
select * from KlienciView;
go


SET XACT_ABORT ON


SELECT * 
FROM OPENQUERY(OracleLinkedServer, 'SELECT INSTANCE_NAME FROM V$INSTANCE');




CREATE TABLE Klienci (
    klient_id INT PRIMARY KEY,
    imie NVARCHAR(50),
    nazwisko NVARCHAR(50),
    id NVARCHAR(20),
    dokument NVARCHAR(20),
    ilosc_wypozyczen INT,
    nazwaInstancji NVARCHAR(100)
);

CREATE TABLE Typy_samochodow (
    TYP_ID INT PRIMARY KEY,
    NAZWA VARCHAR(50),
	nazwaInstancji NVARCHAR(100)
);



CREATE TABLE Pracownicy (
    PRACOWNIK_ID INT PRIMARY KEY,
    IMIE VARCHAR(50),
    NAZWISKO VARCHAR(50),
    DATA_ZATRUDNIENIA DATE,
    DATA_ZWOLNIENIA DATE,
    STANOWISKO VARCHAR(100),
    PENSJA DECIMAL(10, 2),
    ILOSC_KLIENTOW INT,
	nazwaInstancji NVARCHAR(100)
);

CREATE TABLE Samochody (
    SAMOCHOD_ID INT PRIMARY KEY,
    MARKA VARCHAR(50),
    MODEL_SAMOCHODU VARCHAR(50),
    ROK_PRODUKCJI INT,
    NR_REJESTRACYJNY VARCHAR(20),
    TYP_ID INT,
    KOLOR VARCHAR(20),
    PRZEBIEG INT,
    POJEMNOSC_SILNIKA INT,
    STAN_PALIWA INT,
    CENA_ZA_DZIEN DECIMAL(10, 2),
    LICZBA_MIEJSCA INT,
    STATUS INT,
	nazwaInstancji NVARCHAR(100),
	FOREIGN KEY (TYP_ID) REFERENCES Typy_samochodow(TYP_ID)
);

CREATE TABLE Wypozyczenia (
    ID_WYPOZYCZENIA INT,
    KLIENT_ID INT,
    SAMOCHOD_ID INT,
    PRACOWNIK_ID INT,
    DATA_WYPOZYCZENIA DATE,
    DATA_ZWROTU DATE,
    CENA DECIMAL(10, 2),
    STATUS INT,
	nazwaInstancji NVARCHAR(100),
	FOREIGN KEY (KLIENT_ID) REFERENCES Klienci(klient_id),
    FOREIGN KEY (SAMOCHOD_ID) REFERENCES Samochody(SAMOCHOD_ID),
    FOREIGN KEY (PRACOWNIK_ID) REFERENCES Pracownicy(PRACOWNIK_ID)
);





CREATE OR ALTER PROCEDURE aktualizuj_dane_klienci AS
DECLARE
	@v_nazwaInstancji NVARCHAR(100),
	@v_nazwaInstancji2 NVARCHAR(100);
BEGIN
    SELECT @v_nazwaInstancji = INSTANCE_NAME
    FROM OPENQUERY(OracleLinkedServer, 'SELECT INSTANCE_NAME FROM V$INSTANCE');
	SELECT @v_nazwaInstancji2 = INSTANCE_NAME
    FROM OPENQUERY(OracleLinkedServer2, 'SELECT INSTANCE_NAME FROM V$INSTANCE');

    INSERT INTO Klienci (klient_id, imie, nazwisko, id, dokument, ilosc_wypozyczen, nazwaInstancji)
    SELECT KLIENT_ID, IMIE, NAZWISKO, ID, DOKUMENT_PRAWA_JAZDY, ilosc_wypozyczen, @v_nazwaInstancji FROM KlienciView;
	INSERT INTO Klienci (klient_id, imie, nazwisko, id, dokument, ilosc_wypozyczen, nazwaInstancji)
    SELECT KLIENT_ID, IMIE, NAZWISKO, ID, DOKUMENT_PRAWA_JAZDY, ilosc_wypozyczen, @v_nazwaInstancji2 FROM KlienciView2;
END;


CREATE OR ALTER PROCEDURE aktualizuj_dane_samochody AS
DECLARE
    @v_nazwaInstancji NVARCHAR(100),
	@v_nazwaInstancji2 NVARCHAR(100);
BEGIN

    SELECT @v_nazwaInstancji = INSTANCE_NAME
    FROM OPENQUERY(OracleLinkedServer, 'SELECT INSTANCE_NAME FROM V$INSTANCE');
	SELECT @v_nazwaInstancji2 = INSTANCE_NAME
    FROM OPENQUERY(OracleLinkedServer2, 'SELECT INSTANCE_NAME FROM V$INSTANCE');


    INSERT INTO SAMOCHODY (SAMOCHOD_ID, MARKA, MODEL_SAMOCHODU, ROK_PRODUKCJI, NR_REJESTRACYJNY, TYP_ID, KOLOR, PRZEBIEG, POJEMNOSC_SILNIKA, STAN_PALIWA, CENA_ZA_DZIEN, LICZBA_MIEJSCA, [STATUS],nazwaInstancji)
    SELECT SAMOCHOD_ID, MARKA, MODEL_SAMOCHODU, ROK_PRODUKCJI, NR_REJESTRACYJNY, TYP_ID, KOLOR, PRZEBIEG, POJEMNOSC_SILNIKA, STAN_PALIWA, CENA_ZA_DZIEN, LICZBA_MIEJSCA, [STATUS],@v_nazwaInstancji
    FROM SamochodyView;
	INSERT INTO SAMOCHODY (SAMOCHOD_ID, MARKA, MODEL_SAMOCHODU, ROK_PRODUKCJI, NR_REJESTRACYJNY, TYP_ID, KOLOR, PRZEBIEG, POJEMNOSC_SILNIKA, STAN_PALIWA, CENA_ZA_DZIEN, LICZBA_MIEJSCA, [STATUS],nazwaInstancji)
    SELECT SAMOCHOD_ID, MARKA, MODEL_SAMOCHODU, ROK_PRODUKCJI, NR_REJESTRACYJNY, TYP_ID, KOLOR, PRZEBIEG, POJEMNOSC_SILNIKA, STAN_PALIWA, CENA_ZA_DZIEN, LICZBA_MIEJSCA, [STATUS],@v_nazwaInstancji2
    FROM SamochodyView2;
END;

CREATE OR ALTER PROCEDURE aktualizuj_dane_wypozyczenia AS
DECLARE
    @v_nazwaInstancji NVARCHAR(100),
	@v_nazwaInstancji2 NVARCHAR(100);
BEGIN
    SELECT @v_nazwaInstancji = INSTANCE_NAME
    FROM OPENQUERY(OracleLinkedServer, 'SELECT INSTANCE_NAME FROM V$INSTANCE');
	SELECT @v_nazwaInstancji2 = INSTANCE_NAME
    FROM OPENQUERY(OracleLinkedServer2, 'SELECT INSTANCE_NAME FROM V$INSTANCE');


    INSERT INTO WYPOZYCZENIA (ID_WYPOZYCZENIA, KLIENT_ID, SAMOCHOD_ID, PRACOWNIK_ID,  DATA_WYPOZYCZENIA, DATA_ZWROTU, CENA, STATUS, nazwaInstancji)
    SELECT ID_WYPOZYCZENIA, KLIENT_ID, SAMOCHOD_ID, PRACOWNIK_ID,  DATA_WYPOZYCZENIA, DATA_ZWROTU, CENA, STATUS, @v_nazwaInstancji
    FROM WypozyczeniaView;
	INSERT INTO WYPOZYCZENIA (ID_WYPOZYCZENIA, KLIENT_ID, SAMOCHOD_ID, PRACOWNIK_ID,  DATA_WYPOZYCZENIA, DATA_ZWROTU, CENA, STATUS, nazwaInstancji)
    SELECT ID_WYPOZYCZENIA, KLIENT_ID, SAMOCHOD_ID, PRACOWNIK_ID,  DATA_WYPOZYCZENIA, DATA_ZWROTU, CENA, STATUS, @v_nazwaInstancji2
    FROM WypozyczeniaView2;
END;

CREATE OR ALTER PROCEDURE aktualizuj_dane_pracownicy AS
DECLARE
    @v_nazwaInstancji NVARCHAR(100),
	@v_nazwaInstancji2 NVARCHAR(100);
BEGIN
    SELECT @v_nazwaInstancji = INSTANCE_NAME
    FROM OPENQUERY(OracleLinkedServer, 'SELECT INSTANCE_NAME FROM V$INSTANCE');
	SELECT @v_nazwaInstancji2 = INSTANCE_NAME
    FROM OPENQUERY(OracleLinkedServer2, 'SELECT INSTANCE_NAME FROM V$INSTANCE');


    INSERT INTO PRACOWNICY (PRACOWNIK_ID, IMIE, NAZWISKO, DATA_ZATRUDNIENIA, DATA_ZWOLNIENIA, STANOWISKO, PENSJA, ILOSC_KLIENTOW, nazwaInstancji)
    SELECT PRACOWNIK_ID, IMIE, NAZWISKO, DATA_ZATRUDNIENIA, DATA_ZWOLNIENIA, STANOWISKO, PENSJA, ILOSC_KLIENTOW, @v_nazwaInstancji
    FROM PracownicyView;
	INSERT INTO PRACOWNICY (PRACOWNIK_ID, IMIE, NAZWISKO, DATA_ZATRUDNIENIA, DATA_ZWOLNIENIA, STANOWISKO, PENSJA, ILOSC_KLIENTOW, nazwaInstancji)
    SELECT PRACOWNIK_ID, IMIE, NAZWISKO, DATA_ZATRUDNIENIA, DATA_ZWOLNIENIA, STANOWISKO, PENSJA, ILOSC_KLIENTOW, @v_nazwaInstancji2
    FROM PracownicyView2;
END;

CREATE OR ALTER PROCEDURE aktualizuj_dane_typy_samochodow AS
DECLARE
    @v_nazwaInstancji NVARCHAR(100),
	@v_nazwaInstancji2 NVARCHAR(100);
BEGIN
    SELECT @v_nazwaInstancji = INSTANCE_NAME
    FROM OPENQUERY(OracleLinkedServer, 'SELECT INSTANCE_NAME FROM V$INSTANCE');
	SELECT @v_nazwaInstancji2 = INSTANCE_NAME
    FROM OPENQUERY(OracleLinkedServer2, 'SELECT INSTANCE_NAME FROM V$INSTANCE');

    INSERT INTO TYPY_SAMOCHODOW (TYP_ID, NAZWA, nazwaInstancji)
    SELECT TYP_ID, NAZWA, @v_nazwaInstancji
    FROM TypySamochodowView;
	INSERT INTO TYPY_SAMOCHODOW (TYP_ID, NAZWA, nazwaInstancji)
    SELECT TYP_ID, NAZWA, @v_nazwaInstancji2
    FROM TypySamochodowView2;
END;

CREATE OR ALTER PROCEDURE Aktualizuj_Dane_Wszystkie AS
BEGIN
	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Wypozyczenia')
        DROP TABLE Wypozyczenia;
	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Samochody')
        DROP TABLE Samochody;
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Klienci')
        DROP TABLE Klienci;
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pracownicy')
        DROP TABLE Pracownicy;
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Typy_samochodow')
        DROP TABLE Typy_samochodow;

    CREATE TABLE Klienci (
    klient_id INT PRIMARY KEY,
    imie NVARCHAR(50),
    nazwisko NVARCHAR(50),
    id NVARCHAR(20),
    dokument NVARCHAR(20),
    ilosc_wypozyczen INT,
    nazwaInstancji NVARCHAR(100)
);

CREATE TABLE Typy_samochodow (
    TYP_ID INT PRIMARY KEY,
    NAZWA VARCHAR(50),
	nazwaInstancji NVARCHAR(100)
);

CREATE TABLE Pracownicy (
    PRACOWNIK_ID INT PRIMARY KEY,
    IMIE VARCHAR(50),
    NAZWISKO VARCHAR(50),
    DATA_ZATRUDNIENIA DATE,
    DATA_ZWOLNIENIA DATE,
    STANOWISKO VARCHAR(100),
    PENSJA DECIMAL(10, 2),
    ILOSC_KLIENTOW INT,
	nazwaInstancji NVARCHAR(100)
);

CREATE TABLE Samochody (
    SAMOCHOD_ID INT PRIMARY KEY,
    MARKA VARCHAR(50),
    MODEL_SAMOCHODU VARCHAR(50),
    ROK_PRODUKCJI INT,
    NR_REJESTRACYJNY VARCHAR(20),
    TYP_ID INT,
    KOLOR VARCHAR(20),
    PRZEBIEG INT,
    POJEMNOSC_SILNIKA INT,
    STAN_PALIWA INT,
    CENA_ZA_DZIEN DECIMAL(10, 2),
    LICZBA_MIEJSCA INT,
    STATUS INT,
	nazwaInstancji NVARCHAR(100),
	FOREIGN KEY (TYP_ID) REFERENCES Typy_samochodow(TYP_ID)
);

CREATE TABLE Wypozyczenia (
    ID_WYPOZYCZENIA INT,
    KLIENT_ID INT,
    SAMOCHOD_ID INT,
    PRACOWNIK_ID INT,
    DATA_WYPOZYCZENIA DATE,
    DATA_ZWROTU DATE,
    CENA DECIMAL(10, 2),
    STATUS INT,
	nazwaInstancji NVARCHAR(100),
	FOREIGN KEY (KLIENT_ID) REFERENCES Klienci(klient_id),
    FOREIGN KEY (SAMOCHOD_ID) REFERENCES Samochody(SAMOCHOD_ID),
    FOREIGN KEY (PRACOWNIK_ID) REFERENCES Pracownicy(PRACOWNIK_ID)
);


    EXECUTE aktualizuj_dane_klienci;
    EXECUTE aktualizuj_dane_pracownicy;
	EXECUTE aktualizuj_dane_typy_samochodow;
    EXECUTE aktualizuj_dane_samochody;
    EXECUTE aktualizuj_dane_wypozyczenia;
	
END;

EXEC Aktualizuj_Dane_Wszystkie;



select * from Klienci;
select * from Samochody;
select * from Typy_samochodow;
select * from Wypozyczenia;




CREATE OR ALTER PROCEDURE CheckLinkedServer
    @ServerName NVARCHAR(128)
AS
BEGIN
    PRINT 'Konfiguracja Linked Server:';
    EXEC sp_helpserver @ServerName;

    PRINT 'Testowanie połączenia z Linked Server:';
    EXEC sp_testlinkedserver @servername = @ServerName;
END
GO

EXEC dbo.CheckLinkedServer @ServerName = N'OracleLinkedServer';
EXEC dbo.CheckLinkedServer @ServerName = N'OracleLinkedServer2';

CREATE SCHEMA Pracownik;
GO

CREATE OR ALTER PROCEDURE Pracownik.WynikiWypozyczen
    @NazwaInstancji NVARCHAR(255) = NULL
AS
BEGIN
    SELECT 
        YEAR(w.DATA_WYPOZYCZENIA) AS Rok,
        MONTH(w.DATA_WYPOZYCZENIA) AS Miesiac,
        w.nazwaInstancji,
        COUNT(*) AS IloscWypozyczen,
        SUM((DATEDIFF(DAY, w.DATA_WYPOZYCZENIA, w.DATA_ZWROTU) + 1) * CENA) AS Dochod
    FROM 
        Wypozyczenia AS w
    WHERE
        (@NazwaInstancji IS NULL OR w.nazwaInstancji = @NazwaInstancji)
    GROUP BY 
        YEAR(w.DATA_WYPOZYCZENIA),
        MONTH(w.DATA_WYPOZYCZENIA),
        w.nazwaInstancji
    ORDER BY 
        Rok DESC, 
        Miesiac DESC, 
        Dochod DESC;
END;
GO


EXEC Pracownik.WynikiWypozyczen;
EXEC Pracownik.WynikiWypozyczen @NazwaInstancji = 'pd20';


select * from Wypozyczenia


CREATE OR ALTER PROCEDURE Pracownik.WydatkiKlientow
AS
BEGIN
    SELECT 
        k.imie + ' ' + k.nazwisko AS Klient,
        k.nazwaInstancji,
        SUM((DATEDIFF(DAY, w.DATA_WYPOZYCZENIA, w.DATA_ZWROTU) + 1) * w.CENA) AS SumaWydatkow
    FROM 
        Wypozyczenia w
    INNER JOIN 
        Klienci k ON w.KLIENT_ID = k.klient_id
    GROUP BY 
        k.imie, 
        k.nazwisko,
        k.nazwaInstancji
    ORDER BY 
        k.nazwaInstancji,
        SumaWydatkow DESC;
END;


exec Pracownik.WydatkiKlientow;


CREATE OR ALTER PROCEDURE Pracownik.WyswietlSamochody
    @SortColumn NVARCHAR(50) = NULL
AS
BEGIN
    DECLARE @SqlQuery NVARCHAR(MAX);
    SET @SqlQuery = '
        SELECT
            s.nazwaInstancji,
            s.STATUS,
            s.MARKA,
            s.MODEL_SAMOCHODU,
            s.ROK_PRODUKCJI,
            t.NAZWA AS TYP_NAZWA,
            s.KOLOR,
            s.PRZEBIEG,
            s.POJEMNOSC_SILNIKA,
            s.CENA_ZA_DZIEN,
            s.LICZBA_MIEJSCA,
            s.SAMOCHOD_ID
        FROM 
            Samochody s
        JOIN
            Typy_samochodow t ON s.TYP_ID = t.TYP_ID
        ORDER BY 
            s.nazwaInstancji';

    IF @SortColumn IS NOT NULL AND @SortColumn IN ('MARKA', 'MODEL_SAMOCHODU', 'ROK_PRODUKCJI', 'TYP_NAZWA', 'KOLOR', 'PRZEBIEG', 'POJEMNOSC_SILNIKA', 'CENA_ZA_DZIEN', 'LICZBA_MIEJSCA', 'SAMOCHOD_ID')
    BEGIN
        SET @SqlQuery = @SqlQuery + ', ' + @SortColumn;
    END

    EXEC sp_executesql @SqlQuery;
END;


EXEC Pracownik.WyswietlSamochody @SortColumn = 'CENA_ZA_DZIEN';




CREATE OR ALTER PROCEDURE Pracownik.DodajSamochod
    @LinkedServerName NVARCHAR(100),
    @SamochodID INT
AS
BEGIN
    DECLARE @Marka NVARCHAR(50);
    DECLARE @ModelSamochodu NVARCHAR(50);
    DECLARE @RokProdukcji INT;
    DECLARE @NrRejestracyjny NVARCHAR(20);
    DECLARE @TypID INT;
    DECLARE @Kolor NVARCHAR(20);
    DECLARE @Przebieg INT;
    DECLARE @PojemnoscSilnika INT;
    DECLARE @StanPaliwa INT;
    DECLARE @CenaZaDzien DECIMAL(10, 2);
    DECLARE @LiczbaMiejsca INT;
    DECLARE @Status INT;
    DECLARE @SqlQuery NVARCHAR(MAX);
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @RowCount INT;
    DECLARE @InstanceName NVARCHAR(100);
    DECLARE @MaxSamochodID INT;

    BEGIN TRY
        BEGIN DISTRIBUTED TRANSACTION;

        SET @SqlQuery = '
            SELECT @InstanceName = INSTANCE_NAME
            FROM OPENQUERY(' + QUOTENAME(@LinkedServerName) + ', ''SELECT INSTANCE_NAME FROM V$INSTANCE'')';

        EXEC sp_executesql @SqlQuery, N'@InstanceName NVARCHAR(100) OUTPUT', @InstanceName OUTPUT;

        SET @SqlQuery = '
            SELECT @MaxSamochodID = COALESCE(MAX(SAMOCHOD_ID), 0) + 1
            FROM OPENQUERY(' + QUOTENAME(@LinkedServerName) + ', ''SELECT SAMOCHOD_ID FROM Samochody'')';

        EXEC sp_executesql @SqlQuery, N'@MaxSamochodID INT OUTPUT', @MaxSamochodID OUTPUT;

        SELECT
            @Marka = MARKA,
            @ModelSamochodu = MODEL_SAMOCHODU,
            @RokProdukcji = ROK_PRODUKCJI,
            @NrRejestracyjny = NR_REJESTRACYJNY,
            @TypID = TYP_ID,
            @Kolor = KOLOR,
            @Przebieg = PRZEBIEG,
            @PojemnoscSilnika = POJEMNOSC_SILNIKA,
            @StanPaliwa = STAN_PALIWA,
            @CenaZaDzien = CENA_ZA_DZIEN,
            @LiczbaMiejsca = LICZBA_MIEJSCA,
            @Status = STATUS
        FROM Samochody_EXCEL
        WHERE SAMOCHOD_ID = @SamochodID;

        SET @SqlQuery = '
            EXEC (''BEGIN Pracownik.DodajSamochod(''''' + 
                REPLACE(@Marka, '''', '''''') + ''''', ''''' + 
                REPLACE(@ModelSamochodu, '''', '''''') + ''''', ' + 
                CAST(@RokProdukcji AS NVARCHAR(10)) + ', ''''' + 
                REPLACE(@NrRejestracyjny, '''', '''''') + ''''', ' + 
                CAST(@TypID AS NVARCHAR(10)) + ', ''''' + 
                REPLACE(@Kolor, '''', '''''') + ''''', ' + 
                CAST(@Przebieg AS NVARCHAR(10)) + ', ' + 
                CAST(@PojemnoscSilnika AS NVARCHAR(10)) + ', ' + 
                CAST(@StanPaliwa AS NVARCHAR(10)) + ', ' + 
                CAST(@CenaZaDzien AS NVARCHAR(10)) + ', ' + 
                CAST(@LiczbaMiejsca AS NVARCHAR(10)) + ', ' + 
                CAST(@Status AS NVARCHAR(10)) + '); END;'') AT ' + @LinkedServerName;

        PRINT 'Constructed SQL Query: ' + @SqlQuery;

        EXEC sp_executesql @SqlQuery;

        SET @SqlQuery = '
            INSERT INTO Samochody (SAMOCHOD_ID, MARKA, MODEL_SAMOCHODU, ROK_PRODUKCJI, NR_REJESTRACYJNY, TYP_ID, KOLOR, PRZEBIEG, POJEMNOSC_SILNIKA, STAN_PALIWA, CENA_ZA_DZIEN, LICZBA_MIEJSCA, STATUS, nazwaInstancji)
            VALUES (' + CAST(@MaxSamochodID AS NVARCHAR(10)) + ', ''' + @Marka + ''', ''' + @ModelSamochodu + ''', ' + CAST(@RokProdukcji AS NVARCHAR(10)) + ', ''' + @NrRejestracyjny + ''', ' + CAST(@TypID AS NVARCHAR(10)) + ', ''' + @Kolor + ''', ' + CAST(@Przebieg AS NVARCHAR(10)) + ', ' + CAST(@PojemnoscSilnika AS NVARCHAR(10)) + ', ' + CAST(@StanPaliwa AS NVARCHAR(10)) + ', ' + CAST(@CenaZaDzien AS NVARCHAR(10)) + ', ' + CAST(@LiczbaMiejsca AS NVARCHAR(10)) + ', ' + CAST(@Status AS NVARCHAR(10)) + ', ''' + @InstanceName + ''')';

        EXEC sp_executesql @SqlQuery;

        PRINT 'Executed Oracle Procedure';

        DELETE FROM Samochody_EXCEL WHERE SAMOCHOD_ID = @SamochodID;

        PRINT 'Deleted Car from Samochody_EXCEL';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        PRINT 'Error: ' + @ErrorMessage;

        ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;

EXEC Pracownik.DodajSamochod @LinkedServerName = 'ORACLELINKEDSERVER', @SamochodID = 1

select * from samochody;
select * from SamochodyView;
select * from Samochody_EXCEL;


CREATE OR ALTER PROCEDURE Pracownik.DodajPracownika
    @LinkedServerName NVARCHAR(100),
    @p_imie NVARCHAR(50),
    @p_nazwisko NVARCHAR(50),
    @p_data_zatrudnienia DATE,
    @p_data_zwolnienia DATE,
    @p_ulica NVARCHAR(100),
    @p_numer_domu NVARCHAR(10),
    @p_numer_mieszkania NVARCHAR(10),
    @p_miasto NVARCHAR(50),
    @p_kod_pocztowy NVARCHAR(20),
    @p_kraj NVARCHAR(50),
    @p_telefon BIGINT,
    @p_stanowisko NVARCHAR(100),
    @p_wynagrodzenie DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @sql NVARCHAR(MAX);

        SET @sql = 'EXEC (''BEGIN Szef.DodajPracownika(
                            ''''' + @p_imie + ''''',
                            ''''' + @p_nazwisko + ''''',
                            DATE ''''' + CONVERT(VARCHAR(10), @p_data_zatrudnienia, 120) + ''''',
                            ' + ISNULL('DATE ''''' + CONVERT(VARCHAR(10), @p_data_zwolnienia, 120) + '''''', 'NULL') + ',
                            ''''' + @p_ulica + ''''',
                            ''''' + @p_numer_domu + ''''',
                            ''''' + @p_numer_mieszkania + ''''',
                            ''''' + @p_miasto + ''''',
                            ''''' + @p_kod_pocztowy + ''''',
                            ''''' + @p_kraj + ''''',
                            ' + CAST(@p_telefon AS NVARCHAR(20)) + ',
                            ''''' + @p_stanowisko + ''''',
                            ' + CAST(@p_wynagrodzenie AS NVARCHAR(10)) + '
                        ); END;'') AT ' + @LinkedServerName;


        EXEC sp_executesql @sql;


        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;


EXEC Pracownik.DodajPracownika 
    @LinkedServerName = 'OracleLinkedServer',
    @p_imie = 'Piotr',
    @p_nazwisko = 'Wiśniewski',
    @p_data_zatrudnienia = '2023-03-01',
    @p_data_zwolnienia = NULL,
    @p_ulica = 'Słoneczna',
    @p_numer_domu = '7',
    @p_numer_mieszkania = '16',
    @p_miasto = 'Gdańsk',
    @p_kod_pocztowy = '80090',
    @p_kraj = 'Polska',
    @p_telefon = 567890123,
    @p_stanowisko = 'Specjalista ds. sprzedaży',
    @p_wynagrodzenie = 4000.00;



CREATE OR ALTER PROCEDURE Pracownik.DodajWypozyczenie 
    @LinkedServerName NVARCHAR(100),
    @p_klient_id INT,
    @p_samochod_id INT,
    @p_pracownik_id INT,
    @p_data_wypozyczenia DATE,
    @p_data_zwrotu DATE
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @sql NVARCHAR(MAX);


        SET @sql = 'EXEC (''BEGIN Pracownik.DodajWypozyczenie(
                            p_klient_id         => ' + CAST(@p_klient_id AS NVARCHAR(10)) + ',
                            p_samochod_id       => ' + CAST(@p_samochod_id AS NVARCHAR(10)) + ',
                            p_pracownik_id      => ' + CAST(@p_pracownik_id AS NVARCHAR(10)) + ',
                            p_data_wypozyczenia => TO_DATE(''''' + CONVERT(VARCHAR(10), @p_data_wypozyczenia, 120) + ''''', ''''YYYY-MM-DD''''),
                            p_data_zwrotu       => TO_DATE(''''' + CONVERT(VARCHAR(10), @p_data_zwrotu, 120) + ''''', ''''YYYY-MM-DD'''')
                        ); END;'') AT ' + @LinkedServerName;

 
        EXEC sp_executesql @sql;


        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;


        THROW;
    END CATCH
END;


EXEC Pracownik.DodajWypozyczenie 
    @LinkedServerName = 'OracleLinkedServer',
    @p_klient_id = 2,
    @p_samochod_id = 2,
    @p_pracownik_id = 1,
    @p_data_wypozyczenia = '2023-02-01',
    @p_data_zwrotu = '2023-02-10';



select * from Samochody_EXCEL


select a.* from openrowset('OraOLEDB.Oracle', 'pd19'; 'SCOTT'; '12345', 'SELECT * FROM TABLE(pobierz_wszystkie_samochody)') as a 
join openrowset('OraOLEDB.Oracle', 'pd20'; 'SCOTT'; '12345', 'SELECT * FROM TABLE(pobierz_wszystkie_samochody)') as o on a.Model_SAMOCHODU = o.MODEL_SAMOCHODU




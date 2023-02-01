--Fatura Ücreti için indirimli veya indirimsiz olacak þekilde fatura ücreti hesaplayan trigger.
--Bu trigger Satislar tablosuna veri eklendiðinde, Turlar tablosundaki TurID'si eþleþen turlarýn toplam ücretini alýr ve eðer turist 60 yaþ üzerinde ise %15 indirim uygular.
--Daha sonra faturalar tablosuna bu bilgileri ekler.
CREATE TRIGGER tr_Satislar_Faturalar
ON SatislarTablosu
AFTER INSERT
AS
BEGIN
    DECLARE @TuristID INT, @TurID INT, @RehberID INT, @Tarih DATE, @FaturaUcreti MONEY

    SELECT @TuristID = i.TuristID, @TurID = i.TurID, @RehberID = i.RehberID, @Tarih = i.Tarih
    FROM inserted i

    SELECT @FaturaUcreti = SUM(TurUcreti)
    FROM Turlar
    WHERE TurID = @TurID

    -- 60 yaþ üzeri olanlar için indirim uygulanýr
    IF EXISTS (SELECT 1 FROM Turistler WHERE TuristID = @TuristID AND DATEDIFF(YEAR, DogumTarihi, @Tarih) > 60)
    BEGIN
        SET @FaturaUcreti = @FaturaUcreti - (@FaturaUcreti * 0.15)
    END

    INSERT INTO Faturalar ( TuristID, FaturaUcreti)
    VALUES ( @TuristID, @FaturaUcreti)
END
--Triggerýn yaptýðý iþlemi gösteren insert sorgusu
INSERT INTO SatislarTablosu (TurID , TuristID, RehberID, Tarih,TuristAdSoyad, TuristCinsiyet, TuristDogumTarihi,TuristUyruk,TuristUlke,RehberAdSoyad,RehberTel,TürkiyeyeGelmeTarihi,GidilecekYerler)
VALUES (8,3,5,'11.01.12','Levi Acevedo','Kadýn' ,'06.11.91'	,'Japanese'	,'Italy',	'Ozan Temiz'	,'7773204562'	,'11.01.12','Ayasofya, Yerebatan Sarnýcý')
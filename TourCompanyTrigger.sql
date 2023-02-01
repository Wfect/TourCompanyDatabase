--Fatura �creti i�in indirimli veya indirimsiz olacak �ekilde fatura �creti hesaplayan trigger.
--Bu trigger Satislar tablosuna veri eklendi�inde, Turlar tablosundaki TurID'si e�le�en turlar�n toplam �cretini al�r ve e�er turist 60 ya� �zerinde ise %15 indirim uygular.
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

    -- 60 ya� �zeri olanlar i�in indirim uygulan�r
    IF EXISTS (SELECT 1 FROM Turistler WHERE TuristID = @TuristID AND DATEDIFF(YEAR, DogumTarihi, @Tarih) > 60)
    BEGIN
        SET @FaturaUcreti = @FaturaUcreti - (@FaturaUcreti * 0.15)
    END

    INSERT INTO Faturalar ( TuristID, FaturaUcreti)
    VALUES ( @TuristID, @FaturaUcreti)
END
--Trigger�n yapt��� i�lemi g�steren insert sorgusu
INSERT INTO SatislarTablosu (TurID , TuristID, RehberID, Tarih,TuristAdSoyad, TuristCinsiyet, TuristDogumTarihi,TuristUyruk,TuristUlke,RehberAdSoyad,RehberTel,T�rkiyeyeGelmeTarihi,GidilecekYerler)
VALUES (8,3,5,'11.01.12','Levi Acevedo','Kad�n' ,'06.11.91'	,'Japanese'	,'Italy',	'Ozan Temiz'	,'7773204562'	,'11.01.12','Ayasofya, Yerebatan Sarn�c�')
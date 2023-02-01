---------------------------------STORE PROCEDURE---------------------------------------
--Daha önce tur satýþý yaptýðý turist için bilgeri girmeden ekleme yapmayý saðlayan store procedure.
--Eðer daha önce de tur sattýðý bir turistse, bu bilgileri tekrar girmemeli ve turisti sistemden bulup eklemelidir.
CREATE PROCEDURE sp_AddSaleTable (@TurID INT, @TuristID INT, @RehberID INT, @Tarih DATE, @GidilecekYerler NVARCHAR(90),@TürkiyeyeGelmeTarihi DATE)
AS
BEGIN
IF NOT EXISTS (SELECT * FROM Turlar WHERE TurID = @TurID)
BEGIN
RAISERROR('Invalid TurID.', 16, 1)
RETURN
END
IF NOT EXISTS (SELECT * FROM Turistler WHERE TuristID = @TuristID)
BEGIN
RAISERROR('Invalid TuristID.', 16, 1)
RETURN
END
IF NOT EXISTS (SELECT * FROM Rehberler WHERE RehberID = @RehberID)
BEGIN
RAISERROR('Invalid RehberID.', 16, 1)
RETURN
END
INSERT INTO SatislarTablosu (TurID, TuristID, RehberID, Tarih, GidilecekYerler,TürkiyeyeGelmeTarihi )
VALUES (@TurID, @TuristID, @RehberID, @Tarih,@GidilecekYerler,@TürkiyeyeGelmeTarihi)
END
--Store procedure çalýþmasý için exec 
EXEC sp_AddSaleTable 1, 10, 1, '2022-01-08' ,'Ayasofya,Kýz Kulesi,PierreLoti' ,'2022-01-08'

-----------------

--Þirket yetkilisi yeni bölgeler girebilir, olan bölgeleri silebilir.
--Ayrýca bölgeler için geçerli hizmet ücretlerini deðiþtirebilir. Satýþý yapýlmamýþ turlar üzerinde deðiþiklik yapabilir veya turu iptal edebilir.
--Admin için kullanýcý oluþturdum. Bölge silme ve bölge ekleme için store procedure yazdým.
CREATE TABLE Kullanicilar (
KullaniciID INT PRIMARY KEY IDENTITY(1,1),
KullaniciAdi NVARCHAR(50) NOT NULL,
Sifre NVARCHAR(50) NOT NULL,
YetkiSeviyesi INT NOT NULL,
YetkiAdi NVARCHAR(50) NOT NULL
);
--Kullanýcýlar tablosuna admin deðerini ekledim.
INSERT INTO Kullanicilar(KullaniciAdi,Sifre,YetkiSeviyesi,YetkiAdi)
VALUES ('Kullanýcý1','000000000',1,'Admin')

--Admin yeni bölgeler girebilir ve yeni bölgeler ekleyebilir.
--Yeni Bölgeler girebilir ve silebilir. 
CREATE PROCEDURE sp_AddBolgeler(@BolgeAdi NVARCHAR(50), @HizmetUcreti DECIMAL)
AS
BEGIN
IF NOT EXISTS (SELECT * FROM Kullanicilar WHERE YetkiAdi = 'Admin')
BEGIN
RAISERROR('Access Denied. Only Admin can perform this action.', 16, 1)
RETURN
END

INSERT INTO Bolgeler (BolgeAdi, HizmetUcreti)
VALUES (@BolgeAdi, @HizmetUcreti)
END
--Store procedürü çalýþtýran exec
EXEC AddBolgeler 'Istanbul', 20

--Admin Bölge Silebilir
CREATE PROCEDURE sp_DeleteBolgeler (@BolgeID INT)
AS
BEGIN
IF NOT EXISTS (SELECT * FROM Kullanicilar WHERE YetkiAdi = 'Admin')
BEGIN
RAISERROR('Access Denied. Only Admin can perform this action.', 16, 1)
RETURN
END
DELETE FROM Bolgeler WHERE BolgeID = @BolgeID
END
--Store procedürü çalýþtýran kod.
EXEC DeleteBolgeler 17

--Satýþý yapýlmamýþ turlar üzerinde deðiþiklik yapabilir veya turu iptal edebilir. 
--Turlar Tablosuna Tur Durumu sütunu ekledim.
--Aþaðýdaki 2 procedürün çalýþmasý için turlar tablosuna örnek ekleme--
  INSERT INTO Turlar (Turadi,BolgeID1,BolgeID2,BolgeID3,TurUcreti,RehberID,TurTarihi,TurDurumu)
  VALUES ('ProcedureDeneme',2,3,5,250,2,'2022.01.01','Belirsiz')

--Satýlmamýþ turlar için Tur Ýptali store procedürü
CREATE PROCEDURE sp_CancelTur (@TurID INT)
AS
BEGIN
IF NOT EXISTS (SELECT * FROM Kullanicilar WHERE YetkiAdi = 'Admin')
BEGIN
RAISERROR('Access Denied. Only Admin can perform this action.', 16, 1)
RETURN
END

IF NOT EXISTS (SELECT * FROM Turlar WHERE TurID = @TurID AND TurDurumu != 'Satýldý')
BEGIN
RAISERROR('Invalid Tour ID or Tour has already been sold.', 16, 1)
RETURN
END
UPDATE Turlar
SET TurDurumu = 'Ýptal Edildi'
WHERE TurID = @TurID
END
--Tur iptalini yapan store procedure
 EXEC CancelTur 18

--Satýlmamýþ turlar için güncelleme Store Procedürü

 CREATE PROCEDURE UpdateTur (@TurID INT, @TurAdi NVARCHAR(150), @BolgeID1 INT,@BolgeID2 INT,@BolgeID3 INT,@TurÜcreti INT, @RehberID INT, @TurTarihi DATE, @TurDurumu NVARCHAR(50) )
AS
BEGIN
IF NOT EXISTS (SELECT * FROM Kullanicilar WHERE YetkiAdi = 'Admin')
BEGIN
RAISERROR('Access Denied. Only Admin can perform this action.', 16, 1)
RETURN
END

IF NOT EXISTS (SELECT * FROM Turlar WHERE TurID = @TurID)
BEGIN
RAISERROR('Invalid Tour ID.', 16, 1)
RETURN
END

IF NOT EXISTS (SELECT * FROM SatislarTablosu WHERE TurID = @TurID)
BEGIN
UPDATE Turlar
SET TurAdi = @TurAdi, BolgeID1 = @BolgeID1,BolgeID2 = @BolgeID2,BolgeID3 = @BolgeID3, TurUcreti=@TurÜcreti, RehberID=@RehberID, TurTarihi=@TurTarihi,TurDurumu=@TurDurumu
WHERE TurID = @TurID
END
ELSE
BEGIN
RAISERROR('Cannot update the tour as it has been sold.', 16, 1)
END
END
--Store procedure çalýþtýrýlmasý
EXEC UpdateTur 18, 'Yeni Tur', 1, 2, 3, 500, 1, '2022-05-01', 'TurDurumuDegistirildi'
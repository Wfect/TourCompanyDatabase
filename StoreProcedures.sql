---------------------------------STORE PROCEDURE---------------------------------------
--Daha �nce tur sat��� yapt��� turist i�in bilgeri girmeden ekleme yapmay� sa�layan store procedure.
--E�er daha �nce de tur satt��� bir turistse, bu bilgileri tekrar girmemeli ve turisti sistemden bulup eklemelidir.
CREATE PROCEDURE sp_AddSaleTable (@TurID INT, @TuristID INT, @RehberID INT, @Tarih DATE, @GidilecekYerler NVARCHAR(90),@T�rkiyeyeGelmeTarihi DATE)
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
INSERT INTO SatislarTablosu (TurID, TuristID, RehberID, Tarih, GidilecekYerler,T�rkiyeyeGelmeTarihi )
VALUES (@TurID, @TuristID, @RehberID, @Tarih,@GidilecekYerler,@T�rkiyeyeGelmeTarihi)
END
--Store procedure �al��mas� i�in exec 
EXEC sp_AddSaleTable 1, 10, 1, '2022-01-08' ,'Ayasofya,K�z Kulesi,PierreLoti' ,'2022-01-08'

-----------------

--�irket yetkilisi yeni b�lgeler girebilir, olan b�lgeleri silebilir.
--Ayr�ca b�lgeler i�in ge�erli hizmet �cretlerini de�i�tirebilir. Sat��� yap�lmam�� turlar �zerinde de�i�iklik yapabilir veya turu iptal edebilir.
--Admin i�in kullan�c� olu�turdum. B�lge silme ve b�lge ekleme i�in store procedure yazd�m.
CREATE TABLE Kullanicilar (
KullaniciID INT PRIMARY KEY IDENTITY(1,1),
KullaniciAdi NVARCHAR(50) NOT NULL,
Sifre NVARCHAR(50) NOT NULL,
YetkiSeviyesi INT NOT NULL,
YetkiAdi NVARCHAR(50) NOT NULL
);
--Kullan�c�lar tablosuna admin de�erini ekledim.
INSERT INTO Kullanicilar(KullaniciAdi,Sifre,YetkiSeviyesi,YetkiAdi)
VALUES ('Kullan�c�1','000000000',1,'Admin')

--Admin yeni b�lgeler girebilir ve yeni b�lgeler ekleyebilir.
--Yeni B�lgeler girebilir ve silebilir. 
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
--Store proced�r� �al��t�ran exec
EXEC AddBolgeler 'Istanbul', 20

--Admin B�lge Silebilir
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
--Store proced�r� �al��t�ran kod.
EXEC DeleteBolgeler 17

--Sat��� yap�lmam�� turlar �zerinde de�i�iklik yapabilir veya turu iptal edebilir. 
--Turlar Tablosuna Tur Durumu s�tunu ekledim.
--A�a��daki 2 proced�r�n �al��mas� i�in turlar tablosuna �rnek ekleme--
  INSERT INTO Turlar (Turadi,BolgeID1,BolgeID2,BolgeID3,TurUcreti,RehberID,TurTarihi,TurDurumu)
  VALUES ('ProcedureDeneme',2,3,5,250,2,'2022.01.01','Belirsiz')

--Sat�lmam�� turlar i�in Tur �ptali store proced�r�
CREATE PROCEDURE sp_CancelTur (@TurID INT)
AS
BEGIN
IF NOT EXISTS (SELECT * FROM Kullanicilar WHERE YetkiAdi = 'Admin')
BEGIN
RAISERROR('Access Denied. Only Admin can perform this action.', 16, 1)
RETURN
END

IF NOT EXISTS (SELECT * FROM Turlar WHERE TurID = @TurID AND TurDurumu != 'Sat�ld�')
BEGIN
RAISERROR('Invalid Tour ID or Tour has already been sold.', 16, 1)
RETURN
END
UPDATE Turlar
SET TurDurumu = '�ptal Edildi'
WHERE TurID = @TurID
END
--Tur iptalini yapan store procedure
 EXEC CancelTur 18

--Sat�lmam�� turlar i�in g�ncelleme Store Proced�r�

 CREATE PROCEDURE UpdateTur (@TurID INT, @TurAdi NVARCHAR(150), @BolgeID1 INT,@BolgeID2 INT,@BolgeID3 INT,@Tur�creti INT, @RehberID INT, @TurTarihi DATE, @TurDurumu NVARCHAR(50) )
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
SET TurAdi = @TurAdi, BolgeID1 = @BolgeID1,BolgeID2 = @BolgeID2,BolgeID3 = @BolgeID3, TurUcreti=@Tur�creti, RehberID=@RehberID, TurTarihi=@TurTarihi,TurDurumu=@TurDurumu
WHERE TurID = @TurID
END
ELSE
BEGIN
RAISERROR('Cannot update the tour as it has been sold.', 16, 1)
END
END
--Store procedure �al��t�r�lmas�
EXEC UpdateTur 18, 'Yeni Tur', 1, 2, 3, 500, 1, '2022-05-01', 'TurDurumuDegistirildi'
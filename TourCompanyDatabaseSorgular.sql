-RAPORLAR

--1.En çok gezilen yer/yerler neresidir?
SELECT TOP 1 BolgeAdi, COUNT(BolgeID1) + COUNT(BolgeID2) + COUNT(BolgeID3) as TotalVisits
FROM SatislarTablosu
JOIN Bolgeler ON (Bolgeler.BolgeID = SatislarTablosu.BolgeID1 OR Bolgeler.BolgeID = SatislarTablosu.BolgeID2 OR Bolgeler.BolgeID = SatislarTablosu.BolgeID3)
GROUP BY  BolgeAdi
ORDER BY TotalVisits DESC
--2.Agustos ayinda en çok çalisan rehber/rehberler kimdir/kimlerdir?
SELECT TOP 1 Rehberler.RehberAdi, COUNT(*) as CalismaSayisi FROM SatislarTablosu
JOIN Rehberler ON SatislarTablosu.RehberID = Rehberler.RehberID
WHERE MONTH(Tarih) = 8
GROUP BY Rehberler.RehberAdi
ORDER BY CalismaSayisi DESC

--3.Kadin turistlerin gezdiði yerleri, toplam ziyaret edilme sayilariyla beraber listeleyin.
SELECT BolgeAdi, COUNT(SatislarTablosu.TuristID) as ZiyaretEdilmeSayisi
FROM Bolgeler
INNER JOIN SatislarTablosu ON Bolgeler.BolgeID = SatislarTablosu.BolgeID1 OR Bolgeler.BolgeID = SatislarTablosu.BolgeID2 OR Bolgeler.BolgeID = SatislarTablosu.BolgeID3
INNER JOIN Turistler ON Turistler.TuristID = SatislarTablosu.TuristID
WHERE Turistler.Cinsiyet = 'Kadýn'
GROUP BY BolgeAdi
ORDER BY ZiyaretEdilmeSayisi DESC;

--4. Ingiltere’den gelip de Kiz Kulesi’ni gezen turistler kimlerdir?
SELECT t.TuristAdi, t.TuristSoyadi
FROM Turistler t
JOIN SatislarTablosu s ON t.TuristID = s.TuristID
JOIN Turlar tr ON s.TurID = tr.TurID
WHERE t.GelenUlke = 'English' AND tr.BolgeID1 = (SELECT BolgeID FROM Bolgeler WHERE BolgeAdi = 'Kýz Kulesi')
OR tr.BolgeID2 = (SELECT BolgeID FROM Bolgeler WHERE BolgeAdi = 'Kýz Kulesi')
OR tr.BolgeID3 = (SELECT BolgeID FROM Bolgeler WHERE BolgeAdi = 'Kýz Kulesi')

--5. Gezilen yerler hangi yýlda kaç defa gezilmistir?
SELECT COUNT(SatislarTablosu.TurID) as 'Tour Count',Yillar.Yil as 'Year', Bolgeler.BolgeAdi as 'Region Name'
FROM SatislarTablosu
JOIN Turlar ON SatislarTablosu.TurID = Turlar.TurID
JOIN Bolgeler ON Turlar.BolgeID1 = Bolgeler.BolgeID OR Turlar.BolgeID2 = Bolgeler.BolgeID OR Turlar.BolgeID3 = Bolgeler.BolgeID
JOIN (SELECT DISTINCT YEAR(Tarih) as Yil FROM SatislarTablosu) as Yillar ON YEAR(SatislarTablosu.Tarih) = Yillar.Yil
GROUP BY Yillar.Yil, Bolgeler.BolgeAdi
ORDER BY Yillar.Yil, 'Tour Count' DESC;

--6. 2’den fazla tura rehberlik eden rehberlerin en çok tanittiklari yerler nelerdir?
SELECT RehberAdi, RehberSoyadi, COUNT(TurID) AS "Tur Sayisi", GROUP_CONCAT(DISTINCT BolgeAdi) AS "En Cok Tanittigi Yerler"
FROM Rehberler
JOIN Turlar ON Rehberler.RehberID = Turlar.RehberID
JOIN Bolgeler ON Turlar.BolgeID1 = Bolgeler.BolgeID OR Turlar.BolgeID2 = Bolgeler.BolgeID OR Turlar.BolgeID3 = Bolgeler.BolgeID
GROUP BY Rehberler.RehberID
HAVING COUNT(TurID) > 2
ORDER BY COUNT(TurID) DESC
--7.Italyan turistler en çok nereyi gezmistir? 
SELECT b.BolgeAdi, COUNT(*) as "Ziyaret Sayisi"
FROM SatislarTablosu s
JOIN Turlar t ON s.TurID = t.TurID
JOIN Bolgeler b ON t.BolgeID1 = b.BolgeID OR t.BolgeID2 = b.BolgeID OR t.BolgeID3 = b.BolgeID
JOIN Turistler tr ON s.TuristID = tr.TuristID
WHERE tr.GelenUlke = 'Italy'
GROUP BY b.BolgeAdi
ORDER BY "Ziyaret Sayisi" ASC

--8.Kapali Çarsi'yi gezen en yasli turist kimdir? 
SELECT tr.TuristAdi, tr.TuristSoyadi, tr.DogumTarihi
FROM SatislarTablosu s
JOIN Turlar t ON s.TurID = t.TurID
JOIN Bolgeler b ON t.BolgeID1 = b.BolgeID OR t.BolgeID2 = b.BolgeID OR t.BolgeID3 = b.BolgeID  
JOIN Turistler tr ON s.TuristID = tr.TuristID
WHERE b.BolgeAdi = 'Kapalý Çarþý'
ORDER BY tr.DogumTarihi ASC


--9.Yunanistan'dan gelen Finlandiyali turistin gezdigi yerler nerelerdir?
SELECT b.BolgeAdi,TuristAdSoyad
FROM SatislarTablosu s
JOIN Turlar t ON s.TurID = t.TurID
JOIN Bolgeler b ON t.BolgeID1 = b.BolgeID OR t.BolgeID2 = b.BolgeID OR t.BolgeID3 = b.BolgeID
JOIN Turistler tr ON s.TuristID = tr.TuristID
WHERE tr.Uyruk = 'Finnish' AND tr.GelenUlke = 'Greek'
GROUP BY b.BolgeAdi,TuristAdSoyad

--10.Dolmabahçe Sarayi’na en son giden turistler ve rehberi listeleyin.
SELECT tr.TuristAdi, tr.TuristSoyadi, r.RehberAdi, r.RehberSoyadi
FROM SatislarTablosu s
JOIN Turlar t ON s.TurID = t.TurID
JOIN Bolgeler b ON t.BolgeID1 = b.BolgeID OR t.BolgeID2 = b.BolgeID OR t.BolgeID3 = b.BolgeID
JOIN Turistler tr ON s.TuristID = tr.TuristID
JOIN Rehberler r ON s.RehberID = r.RehberID
WHERE b.BolgeAdi = 'Dolmabahce Sarayý'
ORDER BY s.Tarih DESC

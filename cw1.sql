--1
/*prawym przyciskiem klikamy na Databases -> New Databases -> dajemy nazwê firma -> i klikamy ok*/

--2
create schema ksiegowosc

--3
create table Pracownicy(
	id_pracownika int primary key,
	imie varchar(30),
	nazwisko varchar(40),
	adres varchar(50),
	telefon varchar(11))
comment on table Pracownicy is 'tabela z danymi pracowników firmy'

create table Godziny(
	id_godziny int primary key,
	data date,
	liczba_godziny decimal(4,2),
	id_pracownika int,
	foreign key (id_pracownika) references Pracownicy(id_pracownika))
comment on table Godziny is 'tabela z wypracowanymi godzinami przez pracowników'

create table Pensja(
	id_pensji int primary key,
	stanowisko varchar(30),
	kwota decimal(10,2))
comment on table Pensja is 'tabela z pensjami na odpowiadaj¹cym stanowisku'

create table Premia(
	id_premii int primary key,
	rodzaj varchar(30),
	kwota decimal(10,2))
comment on table Premia is 'tabela z przyznanimi premiami'

create table Wynagrodenie(
	id_wynagrodzenia int primary key,
	data date,
	id_pracownika int,
	foreign key (id_pracownika) references Pracownicy(id_pracownika),
	id_godziny int,
	foreign key (id_godziny) references Godziny(id_godziny),
	id_pensji int,
	foreign key (id_pensji) references Pensja(id_pensji),
	id_premii int,
	foreign key (id_premii) references Premia(id_premii))
comment on table Wynagrodzenie is 'tabela z wynagrodzeniami dla pracowników'

--4
insert into Pracownicy (id_pracownika, imie, nazwisko, adres, telefon)
values
(1,'Jan', 'Kowalski', 'Warszawa ul. Lipowa 5', '123456789'),
(2,'Anna', 'Nowak', 'Kraków ul. D³uga 10', '987654321'),
(3,'Piotr', 'Wiœniewski' ,'Gdañsk ul. Leœna 2', '123654789'),
(4,'Katarzyna', 'Mazur', 'Poznañ ul. Polna 8', '123456987'),
(5,'Tomasz', 'Wójcik', 'Wroc³aw ul. Krótka 3', '321456789'),
(6,'Ewa', 'Kowalczyk', '£ódŸ ul. Cicha 9', '321654789'),
(7,'Micha³', 'Zieliñski', 'Lublin ul. Lipowa 11', '321456987'),
(8,'Agniszka', 'Szymañska', 'Szczecin ul. Kwiatowa 7', '678000123'),
(9,'Pawe³', 'D¹browski', 'Katowice ul. S³oneczna 6', '098765432'),
(10,'Iwona', 'Adamczewska', 'Toruñ ul. Parkowa 4', '510514505')

insert into Godziny (id_godziny, data, liczba_godziny,id_pracownika)
values
(1, '01-10-2025', '8.00', 1),
(2, '01-10-2025', '7.50', 2),
(3, '01-10-2025', '8.00', 3),
(4, '02-10-2025', '6.00', 4),
(5, '02-10-2025', '8.00', 5),
(6, '03-10-2025', '8.00', 6),
(7, '03-10-2025', '7.00', 7),
(8, '04-10-2025', '5.00', 8),
(9, '04-10-2025', '8.00', 9),
(10, '05-10-2025', '7.50', 10)

insert into Pensja (id_pensji, stanowisko, kwota)
values
(1,'Ksiêgowy', 5000.00),
(2,'Asystent', 3500.00),
(3,'Kierownik', 7000.00),
(4,'Specjalista IT', 6500.00),
(5,'Magazynier', 4000.00),
(6,'Handlowiec', 4800.00),
(7,'Sekretarka', 3200.00),
(8,'Programista', 8000.00),
(9,'Analityk', 6200.00),
(10,'Dyrektor', 10000.00)

insert into Premia (id_premii, rodzaj, kwota)
values
(1,'Brak', 0.00),
(2,'Premia kwartalna', 500.00),
(3,'Premia œwi¹teczna', 800.00),
(4,'Premia uznaniowa', 1000.00),
(5,'Premia za wyniki', 1200.00),
(6,'Premia frekwencyjna', 300.00),
(7,'Premia lojalnoœciowa', 600.00),
(8,'Premia roczna', 1500.00),
(9,'Premia specjalna', 2000.00),
(10,'Premia szkoleniowa', 700.00)

insert into Wynagrodenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii)
values
(1,'10-10-2025',1,1,1,2),
(2,'10-10-2025',2,2,2,1),
(3,'10-10-2025',3,3,3,4),
(4,'10-10-2025',4,4,4,5),
(5,'10-10-2025',5,5,5,3),
(6,'10-10-2025',6,6,6,8),
(7,'10-10-2025',7,7,7,6),
(8,'10-10-2025',8,8,8,7),
(9,'10-10-2025',9,9,9,10),
(10,'10-10-2025',10,10,10,9)

--5a
select id_pracownika, nazwisko
from Pracownicy

--5b
select distinct w.id_pracownika
from Wynagrodenie w
join Pensja p on p.id_pensji = w.id_pensji
where p.kwota > 1000

--5c
select distinct w.id_pracownika
from Wynagrodenie w
join Pensja p on p.id_pensji = w.id_pensji
join Premia pr on pr.id_premii = w.id_premii
where pr.kwota = 0 And p.kwota > 2000 

--5d
select imie
from Pracownicy
where imie like 'J%'

--5e
select imie, nazwisko
from Pracownicy
where nazwisko like '%n%' and imie like '%a'

--5f
select p.imie, p.nazwisko, year(g.data) as rok, month(g.data) as miesiac,
	case when sum(g.liczba_godziny) > 160 then sum(g.liczba_godziny) - 160
	else 0 end as nadgodziny
from Pracownicy p
join Godziny g on g.id_pracownika = p.id_pracownika
group by p.imie, p.nazwisko, year(g.data), month(g.data)

--5g
select p.imie, p.nazwisko
from Pracownicy p
join Wynagrodenie w on w.id_pracownika = p.id_pracownika
join Pensja pe on pe.id_pensji = w.id_pensji
where pe.kwota between 1500 and 3000

--5h
select p.imie, p.nazwisko
from Pracownicy p
join Godziny g on g.id_pracownika = p.id_pracownika
join Wynagrodenie w on w.id_pracownika = p.id_pracownika
join Premia pr on pr.id_premii = w.id_premii
group by p.imie, p.nazwisko, pr.id_premii, pr.kwota
having sum(g.liczba_godziny) > 160 and (pr.id_premii is null or pr.kwota = 0)

--5i
select p.imie, p.nazwisko, pe.kwota as pensja
from Pracownicy p
join Wynagrodenie w on w.id_pracownika = p.id_pracownika
join pensja pe on pe.id_pensji = w.id_pensji
order by pe.kwota asc

--5j
select p.imie, p.nazwisko, sum(pe.kwota + pr.kwota) as wynagrodzenia
from Pracownicy p
join Wynagrodenie w on w.id_pracownika = p.id_pracownika
join Pensja pe on pe.id_pensji = w.id_pensji
join Premia pr on pr.id_premii = w.id_premii
group by p.imie, p.nazwisko
order by wynagrodzenia desc

--5k
select pe.stanowisko, count (*) as liczba_pracowników
from Wynagrodenie w
join Pensja pe on pe.id_pensji = w.id_pensji
group by pe.stanowisko

--5l
select avg(pe.kwota) as œrednia, min(pe.kwota) as minimalna, max(pe.kwota) as maksymalna
from Wynagrodenie w
join Pensja pe on pe.id_pensji = w.id_pensji
where pe.stanowisko = 'Kierownik'

--5m
select sum(pe.kwota + pr.kwota) as suma_wynagrodzeñ
from Wynagrodenie w 
join Pensja pe on pe.id_pensji = w.id_pensji
join Premia pr on pr.id_premii = w.id_premii

--5n
select pe.stanowisko, sum(pe.kwota + pr.kwota) as suma_wynagrodzenia
from Wynagrodenie w
join Pensja pe on pe.id_pensji = w.id_pensji
join Premia pr on pr.id_premii = w.id_premii
group by pe.stanowisko

--5o
select pe.stanowisko, count(pr.id_premii) as liczba_premii
from Wynagrodenie w
join Pensja pe on pe.id_pensji = w.id_pensji
join Premia pr on pr.id_premii = w.id_premii
group by pe.stanowisko

--5p
delete w
from Wynagrodenie w
join Pensja pe on pe.id_pensji = w.id_pensji
where pe.kwota < 1200
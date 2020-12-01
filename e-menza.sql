-- phpMyAdmin SQL Dump
-- version 4.9.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jun 12, 2020 at 06:29 PM
-- Server version: 8.0.18
-- PHP Version: 7.3.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `e-menza`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `kupovina`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `kupovina` (IN `id_usr` INT, IN `cena` FLOAT, OUT `stat` INT)  begin
declare trenutni_budzet float default 0.0;
select budzet into trenutni_budzet from studenti where id=id_usr;
if trenutni_budzet >= cena
then
set stat=1;
update studenti set budzet=trenutni_budzet-cena where id=id_usr;
ELSE
set stat=0;
end if;
end$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `ime_prezimeStudenta`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `ime_prezimeStudenta` (`id_studenta` INT(11)) RETURNS VARCHAR(200) CHARSET utf8 BEGIN
	DECLARE ime_prezime_s varchar(200);
		SELECT ime_prezime INTO ime_prezime_s FROM studenti WHERE id=id_studenta;
	RETURN ime_prezime_s;
END$$

DROP FUNCTION IF EXISTS `nazivBanke`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `nazivBanke` (`id_banke` INT(11)) RETURNS VARCHAR(200) CHARSET utf8 BEGIN
	DECLARE nazivbanke varchar(200);
		SELECT naziv INTO nazivbanke FROM banka WHERE id=id_banke;
	RETURN nazivbanke;
END$$

DROP FUNCTION IF EXISTS `nazivObroka`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `nazivObroka` (`id_obroka` INT(11)) RETURNS VARCHAR(200) CHARSET utf8 BEGIN
	DECLARE nazivOB varchar(200);
		SELECT naziv INTO nazivOB FROM obroci WHERE id=id_obroka;
	RETURN nazivOB;
END$$

DROP FUNCTION IF EXISTS `nazivRestorana`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `nazivRestorana` (`id_restorana` INT(11)) RETURNS VARCHAR(200) CHARSET utf8 BEGIN
	DECLARE nazivRE varchar(200);
		SELECT naziv_objekta INTO nazivRE FROM menza WHERE id=id_restorana;
	RETURN nazivRE;
END$$

DROP FUNCTION IF EXISTS `putanjaSlike`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `putanjaSlike` (`id_restorana` INT(11)) RETURNS VARCHAR(200) CHARSET utf8 BEGIN
	DECLARE putanja_s varchar(200);
		SELECT putanja INTO putanja_s FROM slike WHERE id=id_restorana;
	RETURN putanja_s;
END$$

DROP FUNCTION IF EXISTS `VrstaObroka`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `VrstaObroka` (`id_vo` INT(11)) RETURNS VARCHAR(200) CHARSET utf8 BEGIN
	DECLARE nazivVO varchar(200);
		SELECT naziv INTO nazivVO FROM vrsta_obroka WHERE id=id_vo;
	RETURN nazivVO;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
CREATE TABLE IF NOT EXISTS `admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `korisnicko_ime` varchar(100) NOT NULL,
  `lozinka` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id`, `korisnicko_ime`, `lozinka`) VALUES
(1, 'admin', 'admin');

-- --------------------------------------------------------

--
-- Stand-in structure for view `admin_porudzbine`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `admin_porudzbine`;
CREATE TABLE IF NOT EXISTS `admin_porudzbine` (
`id` int(11)
,`fk_menza` int(11)
,`fk_obrok` int(11)
,`fk_student` int(11)
,`datum` varchar(200)
,`vreme` varchar(200)
,`nazivRestorana` varchar(200)
,`nazivObroka` varchar(200)
,`ime_p_s` varchar(200)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `admin_studenti`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `admin_studenti`;
CREATE TABLE IF NOT EXISTS `admin_studenti` (
`id` int(11)
,`adresa` varchar(200)
,`naziv` varchar(200)
);

-- --------------------------------------------------------

--
-- Table structure for table `banka`
--

DROP TABLE IF EXISTS `banka`;
CREATE TABLE IF NOT EXISTS `banka` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `adresa` varchar(200) NOT NULL,
  `naziv` varchar(200) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `banka`
--

INSERT INTO `banka` (`id`, `adresa`, `naziv`) VALUES
(1, 'Adresa 1', 'Banka 1'),
(2, 'Adresa 2', 'Banka 2'),
(5, 'Adresa 3', 'Banka 3');

-- --------------------------------------------------------

--
-- Table structure for table `menza`
--

DROP TABLE IF EXISTS `menza`;
CREATE TABLE IF NOT EXISTS `menza` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `adresa` varchar(200) NOT NULL,
  `naziv_objekta` varchar(200) NOT NULL,
  `radno_vreme` varchar(200) NOT NULL,
  `fk_slike` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_slike` (`fk_slike`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `menza`
--

INSERT INTO `menza` (`id`, `adresa`, `naziv_objekta`, `radno_vreme`, `fk_slike`) VALUES
(1, 'Topličina 2', 'Linijski restoran 1', '07:00 - 20:00', 1),
(2, 'Gradsko polje kod Tehničkih fakulteta', 'Linijski restoran 2', '07:00 - 20:00', 2),
(6, 'Velikotrnavska 20', 'Linijski restoran 3', '07:00 - 19:00', 3);

-- --------------------------------------------------------

--
-- Table structure for table `obroci`
--

DROP TABLE IF EXISTS `obroci`;
CREATE TABLE IF NOT EXISTS `obroci` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `naziv` varchar(200) NOT NULL,
  `sastav` varchar(200) NOT NULL,
  `nutritivna_vrednost` varchar(200) NOT NULL,
  `cena` double NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `obroci`
--

INSERT INTO `obroci` (`id`, `naziv`, `sastav`, `nutritivna_vrednost`, `cena`) VALUES
(2, 'Gulaš', 'Meso, povrće', '200 kcal', 800),
(4, 'Pilav', 'Pirinac, piletina', '320kcal', 240);

-- --------------------------------------------------------

--
-- Table structure for table `podela_obroka`
--

DROP TABLE IF EXISTS `podela_obroka`;
CREATE TABLE IF NOT EXISTS `podela_obroka` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fk_menza` int(11) NOT NULL,
  `fk_obrok` int(11) NOT NULL,
  `fk_student` int(11) NOT NULL,
  `datum` varchar(200) NOT NULL,
  `vreme` varchar(200) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_menza` (`fk_menza`),
  KEY `fk_obrok` (`fk_obrok`),
  KEY `fk_student_podaci` (`fk_student`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `podela_obroka`
--

INSERT INTO `podela_obroka` (`id`, `fk_menza`, `fk_obrok`, `fk_student`, `datum`, `vreme`) VALUES
(38, 1, 2, 12, '2020-06-12', '14:34');

-- --------------------------------------------------------

--
-- Table structure for table `racun_studenta`
--

DROP TABLE IF EXISTS `racun_studenta`;
CREATE TABLE IF NOT EXISTS `racun_studenta` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fk_student` int(11) NOT NULL,
  `fk_banka` int(11) NOT NULL,
  `stanje` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_student` (`fk_student`),
  KEY `fk_banka` (`fk_banka`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `racun_studenta`
--

INSERT INTO `racun_studenta` (`id`, `fk_student`, `fk_banka`, `stanje`) VALUES
(43, 12, 2, 1000),
(44, 12, 2, 1000);

-- --------------------------------------------------------

--
-- Table structure for table `slike`
--

DROP TABLE IF EXISTS `slike`;
CREATE TABLE IF NOT EXISTS `slike` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `putanja` varchar(200) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `slike`
--

INSERT INTO `slike` (`id`, `putanja`) VALUES
(1, '/static/img/1.jpg'),
(2, '/static/img/2.jpg'),
(3, '/static/img/3.jpg');

-- --------------------------------------------------------

--
-- Stand-in structure for view `slike_pogled`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `slike_pogled`;
CREATE TABLE IF NOT EXISTS `slike_pogled` (
`id` int(11)
,`adresa` varchar(200)
,`naziv_objekta` varchar(200)
,`radno_vreme` varchar(200)
,`fk_slike` int(11)
,`putanjaSlike` varchar(200)
);

-- --------------------------------------------------------

--
-- Table structure for table `studenti`
--

DROP TABLE IF EXISTS `studenti`;
CREATE TABLE IF NOT EXISTS `studenti` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ime_prezime` varchar(200) NOT NULL,
  `korisnicko_ime` varchar(200) NOT NULL,
  `lozinka` varchar(200) NOT NULL,
  `fakultet` varchar(200) NOT NULL,
  `broj_indeksa` varchar(200) NOT NULL,
  `budzet` float DEFAULT NULL,
  `fk_banka` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_banka_studenta` (`fk_banka`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `studenti`
--

INSERT INTO `studenti` (`id`, `ime_prezime`, `korisnicko_ime`, `lozinka`, `fakultet`, `broj_indeksa`, `budzet`, `fk_banka`) VALUES
(12, 'Aleksa Nejković', 'nejkovic', 'pbkdf2:sha256:150000$ClUxple8$d063c5280678ecc76e728f3a6095927c03ff598f548b81214dae5982ac6c7b8f', 'Visoka tehnička škola strukovnih studija ', 'PEp2/17', 400, 2);

--
-- Triggers `studenti`
--
DROP TRIGGER IF EXISTS `budzet_nula`;
DELIMITER $$
CREATE TRIGGER `budzet_nula` BEFORE INSERT ON `studenti` FOR EACH ROW BEGIN
  SET NEW.budzet = 0;
End
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `studenti_porudzbine`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `studenti_porudzbine`;
CREATE TABLE IF NOT EXISTS `studenti_porudzbine` (
`id` int(11)
,`fk_menza` int(11)
,`fk_obrok` int(11)
,`fk_student` int(11)
,`datum` varchar(200)
,`vreme` varchar(200)
,`nazivRestorana` varchar(200)
,`nazivObroka` varchar(200)
,`ime_p_s` varchar(200)
);

-- --------------------------------------------------------

--
-- Table structure for table `vrsta_obroka`
--

DROP TABLE IF EXISTS `vrsta_obroka`;
CREATE TABLE IF NOT EXISTS `vrsta_obroka` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `naziv` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `vrsta_obroka`
--

INSERT INTO `vrsta_obroka` (`id`, `naziv`) VALUES
(1, 'Predjelo'),
(2, 'Glavno jelo'),
(3, 'Desert');

-- --------------------------------------------------------

--
-- Structure for view `admin_porudzbine`
--
DROP TABLE IF EXISTS `admin_porudzbine`;

CREATE ALGORITHM=MERGE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `admin_porudzbine`  AS  select `podela_obroka`.`id` AS `id`,`podela_obroka`.`fk_menza` AS `fk_menza`,`podela_obroka`.`fk_obrok` AS `fk_obrok`,`podela_obroka`.`fk_student` AS `fk_student`,`podela_obroka`.`datum` AS `datum`,`podela_obroka`.`vreme` AS `vreme`,`nazivRestorana`(`podela_obroka`.`fk_menza`) AS `nazivRestorana`,`nazivObroka`(`podela_obroka`.`fk_obrok`) AS `nazivObroka`,`ime_prezimeStudenta`(`podela_obroka`.`fk_student`) AS `ime_p_s` from `podela_obroka` ;

-- --------------------------------------------------------

--
-- Structure for view `admin_studenti`
--
DROP TABLE IF EXISTS `admin_studenti`;

CREATE ALGORITHM=TEMPTABLE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `admin_studenti`  AS  select `banka`.`id` AS `id`,`banka`.`adresa` AS `adresa`,`banka`.`naziv` AS `naziv` from `banka` where `banka`.`naziv` in (select `nazivBanke`(`studenti`.`fk_banka`) AS `nazivbanke` from `studenti`) is false ;

-- --------------------------------------------------------

--
-- Structure for view `slike_pogled`
--
DROP TABLE IF EXISTS `slike_pogled`;

CREATE ALGORITHM=MERGE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `slike_pogled`  AS  select `menza`.`id` AS `id`,`menza`.`adresa` AS `adresa`,`menza`.`naziv_objekta` AS `naziv_objekta`,`menza`.`radno_vreme` AS `radno_vreme`,`menza`.`fk_slike` AS `fk_slike`,`putanjaSlike`(`menza`.`fk_slike`) AS `putanjaSlike` from `menza` ;

-- --------------------------------------------------------

--
-- Structure for view `studenti_porudzbine`
--
DROP TABLE IF EXISTS `studenti_porudzbine`;

CREATE ALGORITHM=MERGE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `studenti_porudzbine`  AS  select `podela_obroka`.`id` AS `id`,`podela_obroka`.`fk_menza` AS `fk_menza`,`podela_obroka`.`fk_obrok` AS `fk_obrok`,`podela_obroka`.`fk_student` AS `fk_student`,`podela_obroka`.`datum` AS `datum`,`podela_obroka`.`vreme` AS `vreme`,`nazivRestorana`(`podela_obroka`.`fk_menza`) AS `nazivRestorana`,`nazivObroka`(`podela_obroka`.`fk_obrok`) AS `nazivObroka`,`ime_prezimeStudenta`(`podela_obroka`.`fk_student`) AS `ime_p_s` from `podela_obroka` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `menza`
--
ALTER TABLE `menza`
  ADD CONSTRAINT `fk_slike` FOREIGN KEY (`fk_slike`) REFERENCES `slike` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `podela_obroka`
--
ALTER TABLE `podela_obroka`
  ADD CONSTRAINT `fk_menza` FOREIGN KEY (`fk_menza`) REFERENCES `menza` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_obrok` FOREIGN KEY (`fk_obrok`) REFERENCES `obroci` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_student_podaci` FOREIGN KEY (`fk_student`) REFERENCES `studenti` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `racun_studenta`
--
ALTER TABLE `racun_studenta`
  ADD CONSTRAINT `fk_banka` FOREIGN KEY (`fk_banka`) REFERENCES `banka` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_student` FOREIGN KEY (`fk_student`) REFERENCES `studenti` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `studenti`
--
ALTER TABLE `studenti`
  ADD CONSTRAINT `fk_banka_studenta` FOREIGN KEY (`fk_banka`) REFERENCES `banka` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

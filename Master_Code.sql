
SET GLOBAL local_infile=1;


CREATE SCHEMA imdb;
use imdb;



LOAD DATA LOCAL INFILE '/Users/JinSoung/Desktop/Ass 4/title.basics.csv' INTO TABLE basics
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


 

DROP TABLE IF EXISTS basics;
CREATE TABLE basics (
  tconst VARCHAR(45) NOT NULL, #PK
  titleType VARCHAR(45),
  primaryTitle VARCHAR(45),
  originalTitle VARCHAR(45),
  isAdult boolean,
  startYear YEAR,
  endYear YEAR,
  runtimeMinutes INT,
  genres VARCHAR(50),
  PRIMARY KEY (tconst)
  );

  Select * FROM basics;


LOAD DATA LOCAL INFILE '/Users/JinSoung/Desktop/Ass 4/Name_data2.csv' INTO TABLE name
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;   


DROP TABLE IF EXISTS name;
CREATE TABLE name (
  nconst VARCHAR(45) NOT NULL,
  primaryName VARCHAR(45),
  birthYear YEAR,
  deathYear YEAR,
  primaryProfession VARCHAR(45), 
  knownForTitles VARCHAR(45),
  PRIMARY KEY  (nconst)
  );


select * from name;


#  CONSTRAINT fk_has_tconst54 FOREIGN KEY (titleID) REFERENCES basics(tconst)
  

LOAD DATA LOCAL INFILE '/Users/JinSoung/Desktop/Ass 4/title.akas.csv' INTO TABLE akas
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


DROP TABLE IF EXISTS akas;
CREATE TABLE akas (
  titleID VARCHAR(45),
  ordering INT , 
  title VARCHAR(45),
  region VARCHAR(45),
  language VARCHAR(45),
  types set ('alternative', 'dvd', 'festival', 'tv', 'video', 'working', 'original', 'imdbDisplay'),
  attributes varchar(50),
  isOriginalTitle boolean,
  PRIMARY KEY  (titleID,ordering)
  );


  Select * FROM akas;


LOAD DATA LOCAL INFILE '/Users/JinSoung/Desktop/Ass 4/title.crew.csv' INTO TABLE crew
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

DROP TABLE IF EXISTS crew;
CREATE TABLE crew (
  tconst VARCHAR(45) NOT NULL, #PK
  directors VarChar(50),
  writers VarChar(50),
  PRIMARY KEY  (tconst, directors, writers)
  );
  
  Select * from crew;
  
  
LOAD DATA LOCAL INFILE '/Users/JinSoung/Desktop/Ass 4/title.episode.csv' INTO TABLE episode
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
 
DROP TABLE IF EXISTS episode;
CREATE TABLE episode (
  tconst VARCHAR(45) NOT NULL,
  parentTconst VARCHAR(45),
  seasonNumber INT, 
  episodeNumber INT, 
  PRIMARY KEY  (tconst),
   CONSTRAINT fk_has_tconst2 FOREIGN KEY (tconst) REFERENCES basics(tconst),
   constraint fk_has_parentconst FOREIGN KEY (parentTconst) REFERENCES basics(tconst)
  );
  

  select * from episode;
  
  
 LOAD DATA LOCAL INFILE '/Users/JinSoung/Desktop/Ass 4/title.principals.csv' INTO TABLE principals
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES; 
  
DROP TABLE IF EXISTS principals;
CREATE TABLE principals (
  tconst VARCHAR(45),
  ordering INT, 
  nconst VARCHAR(45), 
  category VARCHAR(45),
  job VARCHAR(45),
  characters VARCHAR(45),
  PRIMARY KEY(tconst, ordering), ###mention to steven
   CONSTRAINT fk_has_tconst1 FOREIGN KEY (tconst) REFERENCES basics(tconst),
     CONSTRAINT fk_has_nconst FOREIGN KEY (nconst) REFERENCES name(nconst)
  );

select * from principals;
  
  
 LOAD DATA LOCAL INFILE '/Users/JinSoung/Desktop/Ass 4/title.ratings.csv' INTO TABLE ratings
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;   
  
  
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
  tconst VARCHAR(45) NOT NULL,
  averageRating DECIMAL(5,2), 
  numVotes INT,
  PRIMARY KEY  (tconst),
   CONSTRAINT fk_has_tconst3 FOREIGN KEY (tconst) REFERENCES basics(tconst)
  );

select * from ratings;








#BASICS_GENRES
DROP TABLE IF EXISTS basics_genres;
CREATE TABLE basics_genres(
	tconst VARCHAR(45) NOT NULL,
	genres VARCHAR(50),
    PRIMARY KEY (tconst,genres),
		CONSTRAINT fk_has_tconst FOREIGN KEY (tconst) REFERENCES basics(tconst)
    );
    
INSERT INTO basics_genres(tconst, genres) (
	SELECT tconst, SUBSTRING_INDEX(genres, ",", 1) as number from basics
	UNION	
	(SELECT tconst, SUBSTRING_INDEX(genres,",", -1)as number from basics)
	UNION
	(SELECT tconst, SUBSTRING_INDEX(SUBSTRING_INDEX(genres, ',', 2), ',', -1)as number from basics)
);

SELECT * FROM basics_genres;

ALTER TABLE basics
DROP COLUMN genres;

select * from basics;

  


#AKAS_TYPES. Assumption Every single value in the excel document is single valued, so no need to make every cell atomic. However, the code to seperate an array or multivalued cells is below.
DROP TABLE IF EXISTS akas_types;
CREATE TABLE akas_types(
	titleID VARCHAR(45),
	ordering INT , 
	types set ('alternative', 'dvd', 'festival', 'tv', 'video', 'working', 'original', 'imdbDisplay'),
    PRIMARY KEY (titleID, ordering),
		CONSTRAINT fk_has_tconst12 FOREIGN KEY (titleID) REFERENCES akas(titleID)
    );

INSERT INTO akas_types(titleID, ordering, types) (
SELECT titleID, ordering, types as number from akas
);

/*
INSERT INTO akas_types(titleID, ordering, types) (
	SELECT titleID, ordering, SUBSTRING_INDEX(types, ",", 1) as number from akas
	UNION	
	(SELECT titleID, ordering, SUBSTRING_INDEX(types,",", -1)as number from akas)
	UNION
	(SELECT titleID, ordering, SUBSTRING_INDEX(SUBSTRING_INDEX(types, ',', 2), ',', -1)as number from akas)#gets dvd
    UNION
	(SELECT titleID, ordering, SUBSTRING_INDEX(SUBSTRING_INDEX(types, ',', 3), ',', -1)as number from akas) #gets festival
    UNION
	(SELECT titleID, ordering, SUBSTRING_INDEX(SUBSTRING_INDEX(types, ',', 4), ',', -1)as number from akas)
    UNION
	(SELECT titleID, ordering, SUBSTRING_INDEX(SUBSTRING_INDEX(types, ',', 5), ',', -1)as number from akas)
    UNION
	(SELECT titleID, ordering, SUBSTRING_INDEX(SUBSTRING_INDEX(types, ',', 6), ',', -1)as number from akas)
    UNION
	(SELECT titleID, ordering, SUBSTRING_INDEX(SUBSTRING_INDEX(types, ',', 7), ',', -1)as number from akas) #gets original
);
*/

SELECT * FROM akas_types;

#AKAS_ATTRIBUTES. Every single value in the excel document is single valued, so no need to make every cell atomic

SELECT DISTINCT attributes FROM akas;

select * from akas;

DROP TABLE IF EXISTS akas_attributes;
CREATE TABLE akas_attributes(
  titleID VARCHAR(45),
  ordering INT , 
  attributes varchar(50),
    PRIMARY KEY (titleID, ordering),
		CONSTRAINT fk_has_tconst13 FOREIGN KEY (titleID) REFERENCES akas(titleID)
    );
 
 
INSERT INTO akas_attributes(titleID, ordering, attributes) (
SELECT titleID, ordering, attributes as number from akas
);

SELECT * FROM akas_attributes;

ALTER TABLE akas
DROP COLUMN types;

ALTER TABLE akas
DROP COLUMN attributes;

select * from basics;



#had_role from principals

SELECT DISTINCT characters FROM principals;

DROP TABLE IF EXISTS had_role;
  CREATE TABLE had_role(
	tconst VARCHAR(45),
	nconst VARCHAR(45), 
	characters VARCHAR(45),
  Primary Key (nconst, tconst, characters), 
  CONSTRAINT fk_has_23 FOREIGN KEY (nconst) REFERENCES name(nconst),
  CONSTRAINT fk_has_24 FOREIGN KEY (tconst) REFERENCES basics(tconst)
  );
  
  
INSERT INTO had_role(tconst, nconst, characters) (
	SELECT tconst, nconst, SUBSTRING_INDEX(characters, ",", 1) as number from principals
	UNION	
	(SELECT tconst, nconst, SUBSTRING_INDEX(characters,",", -1)as number from principals)
	UNION
	(SELECT tconst, nconst, SUBSTRING_INDEX(SUBSTRING_INDEX(characters, ',', 2), ',', -1)as number from principals)#gets dvd
);

select * from had_role;

ALTER TABLE principals
DROP COLUMN characters;

select * from name;


#name_worked_as on name table

DROP TABLE IF EXISTS name_worked_as;
  CREATE TABLE name_worked_as (
	nconst VARCHAR(45) NOT NULL,
	primaryProfession VARCHAR(45), 
  Primary Key (nconst, primaryProfession), 
  CONSTRAINT fk_has_27 FOREIGN KEY (nconst) REFERENCES name(nconst)
  );
  
  INSERT INTO name_worked_as(nconst,primaryProfession) (
  	SELECT nconst, SUBSTRING_INDEX(primaryProfession, ",", 1) as number from name
	UNION	
	(SELECT nconst, SUBSTRING_INDEX(primaryProfession,",", -1)as number from name)
	UNION
	(SELECT nconst, SUBSTRING_INDEX(SUBSTRING_INDEX(primaryProfession, ',', 2), ',', -1)as number from name)
);

select * from name_worked_as;

ALTER TABLE name
DROP COLUMN primaryProfession;

select * from name;


#known for on name table
select * from name;


DROP TABLE IF EXISTS Known_for;
  CREATE TABLE Known_for(
  nconst VARCHAR(45),
  knownForTitles VARCHAR(45),
  Primary Key (nconst, knownForTitles), 
  CONSTRAINT fk_has_1 FOREIGN KEY (nconst) REFERENCES name(nconst)
  );
 
  
INSERT INTO Known_for(nconst, knownForTitles) (
	SELECT nconst,  SUBSTRING_INDEX(knownForTitles, ",", 1) as KF from name
	UNION	
	(SELECT nconst, SUBSTRING_INDEX(knownForTitles,",", -1)as KF from name)
	UNION
	(SELECT nconst, SUBSTRING_INDEX(SUBSTRING_INDEX(knownForTitles, ',', 2), ',', -1)as KF from name)
    UNION
	(SELECT nconst, SUBSTRING_INDEX(SUBSTRING_INDEX(knownForTitles, ',', 3), ',', -1)as KF from name)
     UNION
	(SELECT nconst, SUBSTRING_INDEX(SUBSTRING_INDEX(knownForTitles, ',', 4), ',', -1)as KF from name)
);

select * from known_for;

ALTER TABLE name
DROP COLUMN knownForTitles;

select * from name;



#crew and directors

  DROP TABLE IF EXISTS Directors;
  CREATE TABLE Directors(
  tconst VARCHAR(45) NOT NULL, #PK
  directors VarChar(50),
  PRIMARY KEY  (tconst, directors),
  CONSTRAINT director_tconst FOREIGN KEY (tconst) REFERENCES basics(tconst)
  );
  
    INSERT INTO Directors(tconst, directors) (
	SELECT tconst,  SUBSTRING_INDEX(directors, ",", 1) as d from crew
	UNION	
	(SELECT tconst, SUBSTRING_INDEX(directors,",", -1)as d from crew)
	UNION
	(SELECT tconst, SUBSTRING_INDEX(SUBSTRING_INDEX(directors, ',', 2), ',', -1)as d from crew)
);
  
  select * from Directors;
  
  
  #Drop Director
  DROP TABLE IF EXISTS Writers;
  
  Create table Writers(
  tconst VARCHAR(45),
  writers VARCHAR(45),
  PRIMARY KEY (tconst,writers),
  CONSTRAINT fk_writer_tconst FOREIGN KEY (tconst) REFERENCES basics(tconst)
  );
  
INSERT INTO Writers(tconst, writers) (
	SELECT tconst,  SUBSTRING_INDEX(writers, ",", 1) as w from crew
	UNION	
	(SELECT tconst, SUBSTRING_INDEX(writers,",", -1)as w from crew)
	UNION
	(SELECT tconst, SUBSTRING_INDEX(SUBSTRING_INDEX(writers, ',', 2), ',', -1)as w from crew)
);

Select * from writers;
  
DROP TABLE CREW;

  
  
## final answer is goldfinger for movie and the runtime is 110 minutes
SELECT n.primaryName,b.primaryTitle, MAX(averageRating) as max, b.runtimeMinutes FROM ratings r JOIN basics b
ON r.tconst = b.tconst
JOIN Principals p
ON p.tconst = b.tconst
JOIN name n
ON p.nconst = n.nconst
JOIN had_role h
ON n.nconst = h.nconst
WHERE h.characters LIKE "%James Bond%"
AND n.primaryName LIKE "%Sean Connery%"
GROUP BY n.primaryName, b.primaryTitle , b.runtimeMinutes
Order by max desc
limit 1;


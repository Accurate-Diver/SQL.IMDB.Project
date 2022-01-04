# SQL.IMDB.Project
Using the IMDB database, I cleaned and imported the data to create ERD's and made the dataset functional for queries.

# Dataset Details

name.basics.tsv.gz

Contains the following information for names:

nconst (string) - alphanumeric unique identifier of the name/person.
primaryName (string)– name by which the person is most often credited.
birthYear – in YYYY format.
deathYear – in YYYY format if applicable, else "\N".
primaryProfession (array of strings) – the top-3 professions of the person.
knownForTitles (array of tconsts) – titles the person is known for.


title.basics.tsv.gz

Contains the following information for titles:

tconst (string) - alphanumeric unique identifier of the title.
titleType (string) – the type/format of the title (e.g. movie, short, tvseries, tvepisode, video, etc).
primaryTitle (string) – the more popular title / the title used by the filmmakers on promotional materials at the point of release.
originalTitle (string) - original title, in the original language.
isAdult (boolean) - 0: non-adult title; 1: adult title.
startYear (YYYY) – represents the release year of a title. In the case of TV Series, it is the series start year.
endYear (YYYY) – TV Series end year. "\N" for all other title types.
runtimeMinutes – primary runtime of the title, in minutes.
genres (string array) – includes up to three genres associated with the title.


title.akas.tsv.gz

Contains the following information for titles:

titleId (string) - a tconst which is an alphanumeric unique identifier of the title.

ordering (integer) – a number to uniquely identify rows for a given titleId.

title (string) – the localised title.

region (string) - the region for this version of the title.

language (string) - the language of the title.

types (array) - Enumerated set of attributes for this alternative title. One or more of the following: "alternative", "dvd", "festival", "tv", "video", "working", "original", "imdbDisplay". New values may be added in the future without warning. Please note that types is said to be an array. In the data we have this appears to not be true. There appears to be only one string for each pair of titleId and ordering values. Also, there are many NULL (\N) values in this field (~95%).

attributes (array) - Additional terms to describe this alternative title, not enumerated. Please note that attributes is said to be an array. In the data we have this appears to not be true. There appears to be only one string for each pair of titleId and ordering values. There are many NULL (\N) values in this field (~99%).

isOriginalTitle (boolean) – 0: not original title; 1: original title.



title.crew.tsv.gz

Contains the director and writer information for all the titles in IMDb. Fields include:

tconst (string) - alphanumeric unique identifier of the title.
directors (array of nconsts) - director(s) of the given title.
writers (array of nconsts) – writer(s) of the given title.


title.episode.tsv.gz

Contains the tv episode information. Fields include:

tconst (string) - alphanumeric identifier of episode.
parentTconst (string) - alphanumeric identifier of the parent TV Series.
seasonNumber (integer) – season number the episode belongs to.
episodeNumber (integer) – episode number of the tconst in the TV series.


title.principals.tsv.gz

Contains the principal cast/crew for titles

tconst (string) - alphanumeric unique identifier of the title.
ordering (integer) – a number to uniquely identify rows for a given titleId.
nconst (string) - alphanumeric unique identifier of the name/person.
category (string) - the category of job that person was in.
job (string) - the specific job title if applicable, else "\N".
characters (string) - the name of the character played if applicable, else "\N" (It is really "[role1,role2,....]" or "\N").


title.ratings.tsv.gz

Contains the IMDb rating and votes information for titles

tconst (string) - alphanumeric unique identifier of the title.
averageRating – weighted average of all the individual user ratings.
numVotes - number of votes the title has received.

# LEGEND FOR TABLE NAMING
Title.akas.tsv.gz -> akas
Title.basics.tsv.gz -> basics
Title.crew.tsv.gz -> crew
Title.episode.tsv.gz -> episode
Title.principals.tsv.gz -> principals
Title.ratings.tsv.gz -> ratings
Name.basics.tsv.gz -> name

# ERD
The data is not normalised 

# Schema Before Normalization
![image](https://user-images.githubusercontent.com/77642434/148001946-26416401-6813-445f-ab29-b09a13425da3.png)


# Tables after Normalization (in attached code)
![image](https://user-images.githubusercontent.com/77642434/148001999-786b60e4-634f-42c6-8685-80a94ab430ec.png)



# SQL Query

1. Query that lists the title and runtime for the highest rated James Bond starring SeanConnery.

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

#/////////////////////////////////////////////////////
#/////// 1) Create local database ////////////////////
#/////////////////////////////////////////////////////
CREATE SCHEMA `movie`;

CREATE TABLE `movie`.`movie`(
	mov_id INT PRIMARY KEY,
    mov_title CHAR(50),
    mov_year INT,
    mov_time INT,
    mov_lang CHAR(50),
    mov_dt_rel DATE DEFAULT NULL,
    mov_rel_country CHAR(5)
) ENGINE = INNODB;

CREATE TABLE `movie`.`actor`(
	act_id INT PRIMARY KEY,
    act_fname CHAR(20),
    act_lname CHAR(20),
    act_gender CHAR(1)
) ENGINE = INNODB;

CREATE TABLE `movie`.`movie_cast`(
	act_id INT,
    mov_id INT,
    role CHAR(30),
    FOREIGN KEY (mov_id) 
		REFERENCES movie (mov_id) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	FOREIGN KEY (act_id) 
		REFERENCES actor (act_id) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT
) ENGINE = INNODB;

CREATE TABLE `movie`.`director`(
	dir_id INT PRIMARY KEY,
    dir_fname CHAR(20),
    dir_lname CHAR(20)
);

CREATE TABLE `movie`.`movie_direction`(
	dir_id INT,
    mov_id INT,
    FOREIGN KEY (mov_id) 
		REFERENCES movie (mov_id) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	FOREIGN KEY (dir_id) 
		REFERENCES director (dir_id) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT
) ENGINE = INNODB;

CREATE TABLE `movie`.`genres`(
	gen_id INT PRIMARY KEY,
    gen_title CHAR(20)
);

CREATE TABLE `movie`.`movie_genres`(
    mov_id INT,
	gen_id INT,
    FOREIGN KEY (mov_id) 
		REFERENCES movie (mov_id) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	FOREIGN KEY (gen_id) 
		REFERENCES genres (gen_id) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT
) ENGINE = INNODB;

CREATE TABLE `movie`.`reviewer`(
	rev_id INT PRIMARY KEY,
    rev_name CHAR(30)
);

CREATE TABLE `movie`.`rating`(
	mov_id INT,
    rev_id INT,
    rev_stars FLOAT DEFAULT NULL,
    num_o_ratings INT DEFAULT NULL,
    FOREIGN KEY (mov_id) 
		REFERENCES movie (mov_id) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT,
	FOREIGN KEY (rev_id) 
		REFERENCES reviewer (rev_id) 
		ON UPDATE CASCADE 
		ON DELETE RESTRICT
) ENGINE = INNODB;

#/////////////////////////////////////////////////////
#/////// 2) Import data to tables ////////////////////
#/////////////////////////////////////////////////////

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 'ON';
SHOW GLOBAL VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE '~/Downloads/data/actor_table' 
INTO TABLE `movie`.`actor` 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

LOAD DATA LOCAL INFILE '~/Downloads/data/movie' 
INTO TABLE `movie`.`movie` 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

LOAD DATA LOCAL INFILE '~/Downloads/data/director' 
INTO TABLE `movie`.`director` 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

LOAD DATA LOCAL INFILE '~/Downloads/data/genres' 
INTO TABLE `movie`.`genres` 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

LOAD DATA LOCAL INFILE '~/Downloads/data/reviewer' 
INTO TABLE `movie`.`reviewer` 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

LOAD DATA LOCAL INFILE '~/Downloads/data/rating' 
INTO TABLE `movie`.`rating` 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

LOAD DATA LOCAL INFILE '~/Downloads/data/movie_genres' 
INTO TABLE `movie`.`movie_genres` 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

LOAD DATA LOCAL INFILE '~/Downloads/data/movie_direction' 
INTO TABLE `movie`.`movie_direction` 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

LOAD DATA LOCAL INFILE '~/Downloads/data/movie_cast' 
INTO TABLE `movie`.`movie_cast` 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

#/////////////////////////////////////////////////////
#/////// 3) Create tables ////////////////////////////
#/////////////////////////////////////////////////////

# 3.1) How many movies released during a year?

CREATE VIEW `movie`.`rel_movies_by_year` AS
SELECT 
	m.mov_year, 
	count(*) as movies_count
FROM `movie`.`movie` as m
group by 1
order by 1 asc;

# 3.2) How many actors played in a movie

CREATE VIEW `movie`.`actors_in_movies` AS
SELECT 
	m.mov_id, 
    count(mc.act_id) as actors_count
FROM `movie`.`movie` as m
LEFT JOIN `movie`.`movie_cast` as mc on mc.mov_id = m.mov_id
group by 1
order by 1 asc;

# 3.3) How many different genres of movies were released?

CREATE VIEW `movie`.`diff_genres_count` AS
SELECT 
	count(distinct mg.gen_id) as actors_count
FROM `movie`.`movie_genres` as mg;

#/////////////////////////////////////////////////////
#/////// 4) Data reload process //////////////////////
#/////////////////////////////////////////////////////

/* 
If we want to have updated tables after each insert/update in this DB easiest way would be to have
views as i have done in (3).

If we want to have static tables we can set tables reload every n minutes using
programs like Talend, python script.
For performance it would be best to not reload full data but only the newset parts if possible.
If we know that data for movies can not be inserted retrospectively counting movies by year
we can update only current year or just to be safe current and last year.
*/

#/////////////////////////////////////////////////////
#/////// 4) Rating query /////////////////////////////
#/////////////////////////////////////////////////////

SELECT 
	mov_title,
	rev_name
FROM `movie`.`rating` as r
LEFT JOIN `movie`.`reviewer` as re on re.rev_id = r.rev_id
LEFT JOIN `movie`.`movie` as m on m.mov_id = r.mov_id
where rev_stars >= 7;
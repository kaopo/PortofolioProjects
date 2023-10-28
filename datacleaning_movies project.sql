
create database Movies;
use movies;

-- Date Insert

Create table tainies(
MOVIES varchar(255), 
YEAR int,
 RATING decimal(2,1),
 VOTES int,
 RunTime int,
 Gross varchar(255)
);




SET GLOBAL local_infile=1;



LOAD DATA LOCAL INFILE "C:/Users/csv/tainies.csv"
INTO TABLE tainies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
-- LINES TERMINATED BY 'n'
IGNORE 1 ROWS;

select * from tainies;

truncate tainies;

alter table tainies

-- Set YearOfProduction to all the movies

RENAME Column YearOfProduction to ALLYEAR;

-- the original column was year to YearOfProduction ALLYEAR=YearOfProduction

select replace(YearOfProduction,'-','')
from tainies;

update tainies 
set YearOfProduction = replace(YearOfProduction,'-','') ;

select replace(YearOfProduction,'(','')
from tainies;

update tainies 
set YearOfProduction = replace(YearOfProduction,'(','') ;

select replace(YearOfProduction,')','')
from tainies;

update tainies 
set YearOfProduction = replace(YearOfProduction,')','') ;

select replace(YearOfProduction,'– ','')
from tainies;

update tainies 
set YearOfProduction = replace(YearOfProduction,'– ','') ;

-- 'I 2018'

select replace(YearOfProduction,'I ','')
from tainies;

update tainies 
set YearOfProduction = replace(YearOfProduction,'I ','') ;

ALTER TABLE tainies ADD YearOfEND varchar(255) AFTER YearOfProduction;

ALTER TABLE tainies ADD YearOfProduction varchar(255) AFTER ALLYEAR;

select 

If(  length(ALLYEAR) - length(replace(ALLYEAR, '–', ''))>1,  
       SUBSTRING_INDEX(ALLYEAR, '–', -1) ,NULL) from tainies;

select SUBSTRING_INDEX(ALLYEAR, '–', 1) from tainies;

update tainies set
YearOfEND = If(  length(ALLYEAR) - length(replace(ALLYEAR, '–', ''))>1,  
       SUBSTRING_INDEX(ALLYEAR, '–', -1) ,NULL);

select YearOfEND from tainies;

update tainies set
YearOfProduction = SUBSTRING_INDEX(ALLYEAR, '–', 1) ;

select ALLYEAR, YearOfProduction, YearOfEND from tainies;

-- Search for dublicates and delete while keeping the avg of the other columns

SELECT movies, ROW_NUMBER () Over (PARTITION BY MOVIES ORDER BY MOVIES) as dublicate_movies from tainies;


select movies, avg(rating), avg(votes), avg(RUNTIME) from tainies
 
group by movies
order by movies;

select * from tainies order by movies;

alter table tainies 
add AVG_Rating decimal(6,5) after RATING,
add AVG_Votes decimal(15,10) AFTER VOTES,
add AVG_Runtime decimal(15,10) after runtime;

alter table tainies drop column AVG_Runtime ;

 
UPDATE tainies as r JOIN
       (SELECT movies, avg(RATING) AS AVG_Rating
        FROM tainies
        GROUP BY movies
       ) as u 
       ON r.movies = u.movies 
    SET r.AVG_Rating = u.AVG_Rating;

UPDATE tainies as r JOIN
       (SELECT movies, avg(VOTES) AS AVG_Votes
        FROM tainies
        GROUP BY movies
       ) as u 
       ON r.movies = u.movies 
    SET r.AVG_Votes = u.AVG_Votes;

UPDATE tainies as r JOIN
       (SELECT movies, avg(runtime) AS AVG_Runtime
        FROM tainies
        GROUP BY movies
       ) as u 
       ON r.movies = u.movies 
    SET r.AVG_Runtime = u.AVG_Runtime;
-- find and delete dublicates
SELECT movies, ROW_NUMBER()   
OVER (PARTITION BY movies ORDER BY movies) AS row_num   
FROM tainies;  

DELETE FROM tainies WHERE movies IN(  
    SELECT movies FROM (SELECT movies, ROW_NUMBER()   
       OVER (PARTITION BY movies ORDER BY movies) AS row_num   
    FROM tainies) AS temp_table WHERE row_num>1  
);  




select allyear from tainies where yearofproduction like '%game'
order by allyear;

select allyear from tainies order by allyear;

update tainies 
set YearOfProduction = replace(YearOfProduction,'I','') ;

update tainies 
set YearOfProduction = replace(YearOfProduction,'V','') ;

update tainies 
set allyear = replace(allyear,'I','') ;

update tainies 
set allyear = replace(allyear,'X ','') ;

update tainies 
set YearOfProduction = replace(YearOfProduction,'X ','') ;


update tainies 
set allyear = replace(allyear,'  Game','');

update tainies 
set YearOfProduction = null where YearOfProduction = 'X';



-- fix data types

alter table tainies 
modify YearOfProduction year(4);

alter table tainies 
modify YearOfEND year(4);

select * from tainies order by avg_votes desc;

/*
Fixing Mistake

select Concat(YearOfProduction,'-',YearOfEnd) from tainies;

update tainies set
allyear = Concat(YearOfProduction,'-',YearOfEnd);

update tainies set
allyear = yearofproduction where 
allyear is null;
*/

alter table tainies 
modify avg_rating decimal(2,1);


alter table tainies 
modify avg_votes int;

alter table tainies 
modify avg_runtime int;








/* We have alot of data but lets first figure out whats usable data thats not decreasing our 
accuracy. I want to look at players that had sesaons with a small amount of games played as we 
we shouldnt include that when analyzing statistics. We first take a look at players with games 
played of 1 becuase this can affect statistics 
like net rating and points per game.*/

SELECT *
FROM nbastats
WHERE gp=1;

/* You can clearly see that there are many cases in this table recorded when a player only 
played 1 game. To not negatevily affect the overall accuracy of analyzing this data, we will 
remove any rows when the player played less than 5 games in a season.*/

DELETE FROM nbastats
WHERE gp<5;

/* Lets now take a look at the unique draft classes in the data set*/

SELECT DISTINCT draft_year 
FROM nbastats;

/*Theres a label for undrafted players, lets take a look at how many 
players actually went undrafted in the year 2017-18 as an example*/

SELECT  draft_year, COUNT(draft_year)
FROM nbastats
WHERE season='2017-18'
GROUP BY draft_year
order by COUNT(draft_year) DESC;

/* Suprisingly, a big margin of players actually go undrafted and are signed after the draft,
We will assign a value to all undrafted labels to clean up the data later on.*/

/* Since this dataset contains all players record form the 1996 seasons, we shouldnt include 
players that were drafted far beyond the 1996 season as we would only get a couple seasons from them included. 
For that reason I chose to drop all players that were drafted before the 1995 season. However, first we need to 
clean up the some outlying numbers in the draft number, round and year.*/

UPDATE nbastats
SET draft_number= REPLACE(draft_number, 'Undrafted','61')
WHERE draft_number= 'Undrafted';

UPDATE nbastats
SET draft_number= REPLACE(draft_number, '82','61')
WHERE draft_number= '82';  

UPDATE nbastats
SET draft_round= REPLACE(draft_round, 'Undrafted','3')
WHERE draft_round= 'Undrafted'; 

DELETE FROM nbastats
WHERE draft_year='Undrafted';

DELETE FROM nbastats
WHERE draft_year<1995;

/* Now that our data is cleaned, lets take a look at average statistics per draft pick and create 
a table from that. Im curious of draft number actually lines up well with average statistics.*/
 CREATE TABLE DraftNumberAverage
  AS (SELECT  draft_number,
sum(pts)/count(draft_number) as Average_Pts,
sum(reb)/count(draft_number) as Average_reb,
sum(ast)/count(draft_number) as Average_ast
FROM nbastats
GROUP BY draft_number
order by draft_year DESC);

/* The trend is actually very well corealated with draft number but there is more we can interpret from this data. 
For example we can see historically the secound round pick has the lowest ppg out of the top 5. Interestigly, 
we also have a spike of ppg on draft picks 57 and 60. Lets take a look at the 57th picks to see any notable names. */

SELECT *
FROM nbastats
WHERE draft_number='57';

/* The first name certainly catching my eye is the great Manu Ginobili, one of the greatest 
spur of all time and defintely a steal at that draft number. He is most definetely the reason 
for the increase in average stats for the 57th picks. We can take a look at his amazing career. */

SELECT *
FROM nbastats
WHERE player_name= 'Manu Ginobili';

/* Amazing to see that his prime aligns with the championship year the spurs had in 07. That was a great series watching as a kid
and Manu was very impactful in their victory vs the Cleavland Cavaliers*/

/* Lets implimenting a score metric created by a user that creates a rating based on the 
difference of a players stats vs the average of the same draft number (We created that table earlier), with that we can 
take a look at the best players of each draft class. */

SELECT n.player_name, n.draft_number,
(sum(n.pts)/count(n.draft_number)- Average_Pts)+
(sum(n.reb)/count(n.draft_number)- Average_reb)+
(sum(n.ast)/count(n.draft_number)- Average_ast) as score
FROM nbastats n
JOIN draftnumberaverage d ON d.draft_number=n.draft_number
WHERE n.draft_number= '1'
GROUP BY n.player_name
ORDER BY score DESC;

/* Hes not my favourite player all time (Kobe) but its no suprise to see Lebron James as the 
greatest first pick within the last 2 decades. Although this is certainly a flawed method of 
finding the best player, its a good sign that Lebron came up #1 */

/* We can also use this to look at the best steals of all time according to their corrosponding draft
number, ones that are able to outscore everyone when compared by the same draft number*/
SELECT n.player_name, n.draft_number,
(sum(n.pts)/count(n.draft_number)- Average_Pts)+
(sum(n.reb)/count(n.draft_number)- Average_reb)+
(sum(n.ast)/count(n.draft_number)- Average_ast) as score
FROM nbastats n
JOIN draftnumberaverage d ON d.draft_number=n.draft_number
GROUP BY n.player_name
ORDER BY score DESC
LIMIT 10;

/* We have observed the relation of draft number with the average statistics and found some 
very interesting results. We also looked at draft steals and best players of corrosponding 
draft numbers. However, we must note that this is not the most accurate method and many 
assumptions were made. For the futue, we can take a look at more detaileed statistcs like 
steals, reb, assists, 3pts, and PER. We can also look at the statistics and create
an Algorithm to predict the optimal draft number and compare it to the actual. I hope you 
enjoyed this project! */



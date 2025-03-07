/*
GROUP #1
MICHAEL
*/


SELECT *
FROM collegeplaying

WITH vandy_players AS (
    SELECT DISTINCT playerid
    FROM collegeplaying
    WHERE schoolid = 'vandy'
)
SELECT 
    namefirst || ' ' || namelast AS fullname, 
    SUM(salary)::int::MONEY AS total_salary
FROM salaries
INNER JOIN vandy_players
USING(playerid)
INNER JOIN people
USING(playerid)
GROUP BY fullname
ORDER BY total_salary DESC
LIMIT 5;

-- 1- Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT  p.namefirst || ' ' || p.namelast AS fullname, sum(sal.salary) AS Major_League_Earnings
FROM people AS p
INNER JOIN collegeplaying AS cp
ON p.playerid = cp.playerid
INNER JOIN schools AS s
ON cp.schoolid = s.schoolid
INNER JOIN salaries AS sal
ON sal.playerid = p.playerid
WHERE s.schoolname = 'Vanderbilt University'
GROUP BY fullname
ORDER BY Major_League_Earnings DESC;


-- David Price earned the most money in majors, earning 245,553,888.


/*
GROUP #2




*/



-- 2- Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.


SELECT
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS','1B', '2B','3B') THEN 'Infield'
	WHEN pos IN ('P', 'C') THEN 'Battery'
	ELSE 'N/A'
	END AS player_position,
	SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY player_position
ORDER BY total_putouts DESC;

-- Battery position got 41424 putouts, infield got 58,932 putouts, and outfield got 29,560 putouts all in 2016.


/*
GROUP #3




*/




/*
3- Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends? (Hint: For this question, you might find it helpful to look at 
the generate_series function (https://www.postgresql.org/docs/9.1/functions-srf.html). If you want to see an example of this in action, 
check out this DataCamp video: https://campus.datacamp.com/courses/exploratory-data-analysis-in-sql/summarizing-and-aggregating-numeric-data?ex=6)
*/



SELECT generate_series
FROM generate_series(1920,2020,10);

SELECT *
FROM appearances;

WITH decades AS (
	SELECT generate_series AS decade_value
	FROM generate_series(1920,2020,10)
 )
SELECT
	ROUND((SUM(hr)/(SUM(g)/2.0)),3) AS avg_homeruns_per_game, 
	ROUND((SUM(so)/(SUM(g)/2.0)),3) AS avg_strikeouts_per_game, 
	d.decade_value AS decade
FROM teams
LEFT JOIN decades AS d
ON yearid >= d.decade_value 
AND yearid < d.decade_value + 10
WHERE yearid >=1920
GROUP BY decade
ORDER BY decade;

-- Both values for homeruns and strikeouts generally get larger as time goes on. 

/*
#4 - Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases. 
Report the players' names, number of stolen bases, number of attempts, and stolen base percentage.
*/

SELECT p.namefirst || ' ' || p.namelast AS fullname, sb AS stolen_base, (sb + cs) AS stolen_base_attempts, ROUND(100 * (CAST(sb AS NUMERIC)/CAST((sb + cs) AS NUMERIC)), 2) AS stealing_base_success
FROM batting
LEFT JOIN people AS p
ON p.playerid = batting.playerid
WHERE yearid = 2016 AND sb+cs >=20
ORDER BY stealing_base_success DESC
LIMIT 1;


/*
#5 - From 1970 to 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team 
that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion; determine why this is the case. 
Then redo your query, excluding the problem year. How often from 1970 to 2016 was it the case that a team with the most wins also won the world series? 
What percentage of the time?
*/

-- From 1970 to 2016, what is the largest number of wins for a team that did not win the world series?
SELECT 
	yearid, 
	teamid, 
	name AS team_name, 
	w AS wins, 
	wswin AS world_series_win
FROM teams
WHERE 
	yearid >=1970 AND 
	yearid <= 2016 AND
	wswin = 'N'
ORDER BY w DESC
LIMIT 1;
-- The largest number of wins for a team between 1970 and 2016 to not win was the Seattle Mariners with 116 wins.



-- What is the smallest number of wins for a team that did win the world series?
SELECT 
	yearid, 
	teamid, 
	name AS team_name, 
	w AS wins, 
	wswin AS world_series_win
FROM teams
WHERE 
	yearid >=1970 AND 
	yearid <= 2016 AND
	wswin = 'Y'
ORDER BY w;
-- The smallest number of wins for a team between 1970 and 2016 to win was the Los Angeles Dodgers with 63 wins.


-- That is weird, why is it such a low win count? 
SELECT 
	yearid, 
	AVG(g), 
	AVG(w), 
	(SUM(g)/2) AS total_games_played, 
	COUNT(DISTINCT(name)) AS number_of_teams
FROM teams
WHERE yearid >=1970 AND yearid <= 2016
GROUP BY yearid
ORDER BY total_games_played; 
-- This above query shows that the total games played and avg games played across the whole season was much lower than all of the other seasons.

SELECT 
	yearid, 
	teamid, 
	name AS team_name, 
	w AS wins, 
	wswin AS world_series_win
FROM teams
WHERE 
	yearid >=1970 AND 
	yearid <= 2016 AND
	yearid != 1981 AND
	wswin = 'Y'
ORDER BY w;

-- From redoing the query, we get the St. Louis Cardinals in 2006 with 83 wins being the lowest amount with a world series win.


--How often from 1970 to 2016 was it the case that a team with the most wins also won the world series? 

WITH maxwins AS(
	SELECT yearid, MAX(w) AS max_wins
	FROM teams
	WHERE
		yearid >= 1970 AND
		yearid <= 2016
	GROUP BY yearid
	ORDER BY yearid	
)
SELECT 
	t.name AS team_name, 
	t.yearid, t.w AS team_wins,
	CASE WHEN t.w = mw.max_wins AND t.wswin = 'Y' THEN 'Y'
	ELSE 'N'
	END AS max_wins_wswin,
	mw.max_wins AS max_season_wins,
	t.wswin AS world_series_win
FROM teams AS t
LEFT JOIN maxwins AS mw
ON mw.yearid = t.yearid
WHERE 
	t.yearid >= 1970 AND 
	t.yearid <= 2016 AND
	t.w = mw.max_wins AND
	t.wswin = 'Y';

-- It happened 12 times between 1970 and 2016.

-- What percentage of the time?

SELECT COUNT(DISTINCT(yearid))
FROM teams
WHERE
	yearid >= 1970 AND 
	yearid <= 2016;

-- With the above query showing there are 47 total years
	
-- And the previous query showing that there were 12 years where the team with the most wins won the world series,
-- it occured 12/47 percent of the time (25.53%)

SELECT ROUND(((12.0/47.0) * 100),2) AS percent
FROM teams
LIMIT 1;



-------------------------------------------------

WITH most_wins AS (
    SELECT
        yearid,
        MAX(w) AS w
    FROM teams
    WHERE yearid >= 1970
    GROUP BY yearid
    ORDER BY yearid
    ),
ws_winners_with_most_wins AS (
    SELECT 
        yearid,
        teamid,
        w
    FROM teams
    INNER JOIN most_wins
    USING(yearid, w)
    WHERE wswin = 'Y'
),
ws_years AS (
    SELECT COUNT(DISTINCT yearid)
    FROM teams
    WHERE wswin = 'Y' AND yearid >= 1970
)
SELECT 
    (SELECT COUNT(*) FROM ws_winners_with_most_wins) AS num_most_win_ws_winners,
    (SELECT * FROM ws_years) as years_with_ws,
    ROUND((SELECT COUNT(*)
     FROM ws_winners_with_most_wins
    ) * 100.0 /
    (SELECT *
     FROM ws_years
    ), 2) AS most_wins_ws_pct
    ;



/*
#6 Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)?
Give their full name and the teams that they were managing when they won the award.
*/	

SELECT *
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND (playerid = 'coxbo01' OR playerid = 'larusto01')


WITH multi_league_winner AS (
	SELECT playerid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND (lgid = 'NL' OR lgid = 'AL')
	GROUP BY playerid
	HAVING COUNT(DISTINCT lgid) = 2
),
all_instances_mlw AS(
	SELECT am.playerid, am.awardid, am.yearid, am.lgid
	FROM awardsmanagers AS am
	RIGHT JOIN multi_league_winner AS mlw
	ON mlw.playerid = am.playerid
),
no_names AS(
	SELECT m.playerid, m.yearid, m.teamid, aim.lgid
	FROM managers AS m
	RIGHT JOIN all_instances_mlw AS aim
	ON m.playerid = aim.playerid AND m.yearid = aim.yearid
)
SELECT p.namefirst || ' ' || p.namelast AS fullname, nn.yearid, nn.teamid AS team, nn.lgid AS league
FROM people AS p
RIGHT JOIN no_names AS nn
ON nn.playerid = p.playerid
ORDER BY fullname;

-- The two managers to win TSN manager of the year in the american and national league were Jim leyland and Davey Johnson.


/*
#7

Which pitcher was the least efficient in 2016 in terms of salary / strikeouts? Only consider pitchers who started at least 10 games (across all teams). 
Note that pitchers often play for more than one team in a season, so be sure that you are counting all stats for each player.

*/


WITH q1 AS(
	SELECT playerid, SUM(gs) AS games_started, SUM(so) AS total_strikeouts_2016 
	FROM pitching
	WHERE yearid = 2016
	GROUP BY playerid
	HAVING SUM(gs) >= 10
),
new_salaries AS(
	SELECT *
	FROM salaries
	WHERE yearid = 2016
),
no_names AS (
	SELECT q1.playerid, q1.total_strikeouts_2016, s.salary, (s.salary / q1.total_strikeouts_2016) AS price_per_strikeout
	FROM q1 
	INNER JOIN new_salaries AS s 
	ON s.playerid = q1.playerid 
	ORDER BY price_per_strikeout DESC
)
SELECT p.namefirst || ' ' || p.namelast AS fullname, nn.total_strikeouts_2016, nn.salary, nn.price_per_strikeout
FROM no_names AS nn
LEFT JOIN people AS p
ON p.playerid = nn.playerid
ORDER BY price_per_strikeout DESC;

-- The least efficient player for stikeouts to salary was Matt Cain, costing around 289,351 for every strikeout he threw. 
-- (And if I misunderstood and I should have done "ipouts" rather than so it was still Matt Cain)


/*

#8
Find all players who have had at least 3000 career hits. Report those players' names, total number of hits, and the year 
they were inducted into the hall of fame (If they were not inducted into the hall of fame, put a null in that column.) 
Note that a player being inducted into the hall of fame is indicated by a 'Y' in the inducted column of the halloffame table.

*/


WITH pnames AS(
	SELECT playerid, SUM(h) AS total_career_hits   -- I think its only h and we only have to group by playerid to cover all years and potential teams.
	FROM batting
	GROUP BY playerid
	HAVING sum(h) >= 3000
),
fullnames AS(
	SELECT pn.playerid, pn.total_career_hits, p.namefirst || ' ' || p.namelast AS fullname
	FROM pnames AS pn
	LEFT JOIN people AS p
	ON p.playerid = pn.playerid
)
SELECT fn.fullname, fn.total_career_hits, hof.yearid AS year_inducted_hof
FROM fullnames AS fn
LEFT JOIN halloffame AS hof
ON fn.playerid = hof.playerid;


/*

#9

Find all players who had at least 1,000 hits for two different teams. Report those players' full names.


*/ 


WITH teams_and_hits AS(
	SELECT playerid, teamid, SUM(h) AS hits
	FROM batting
	GROUP BY playerid, teamid
	HAVING SUM(h) >= 1000
),
nonames AS (
	SELECT playerid, COUNT(playerid) AS number_teams_1000hits
	FROM teams_and_hits
	GROUP BY playerid
	HAVING COUNT(playerid) >= 2
)
SELECT p.namefirst || ' ' || p.namelast AS fullname
FROM nonames AS nn
LEFT JOIN people AS p
ON p.playerid = nn.playerid


/*

#10

Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league 
for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

*/


WITH players_ten_years AS(
	SELECT playerid
	FROM batting
	GROUP BY playerid
	HAVING COUNT(DISTINCT(yearid)) >= 10	
),
players_2016 AS(
	SELECT playerid, hr, yearid
	FROM batting
	WHERE yearid = 2016 AND hr >=1
	 
),
elig_players AS(
	SELECT p2016.playerid
	FROM players_2016 AS p2016
	INNER JOIN players_ten_years AS pty
	ON pty.playerid = p2016.playerid
),
yearly_homerun_counts AS (
	SELECT b.playerid, b.yearid, SUM(hr) AS yearly_hr_count
	FROM elig_players AS ep
	LEFT JOIN batting AS b
	ON b.playerid = ep.playerid
	GROUP BY b.playerid, b.yearid
),
carrer_high_hr AS (
	SELECT yhc.playerid, MAX(yhc.yearly_hr_count)
	FROM yearly_homerun_counts AS yhc
	GROUP BY playerid
),
almost_final_df AS (
	SELECT yhc.*, chhr.max AS hr_year_high,
		CASE WHEN (yhc.yearly_hr_count = chhr.max) AND (yhc.yearid = 2016) THEN 'Y'
		ELSE 'N'
		END AS peak_in_2016
	FROM carrer_high_hr AS chhr
	LEFT JOIN yearly_homerun_counts AS yhc
	ON yhc.playerid = chhr.playerid
)
SELECT p.namefirst || ' ' || p.namelast AS fullname, afd.yearly_hr_count AS hr_count_2016
FROM almost_final_df AS afd
LEFT JOIN people AS p
ON p.playerid = afd.playerid
WHERE afd.peak_in_2016 = 'Y'
ORDER BY hr_count_2016 DESC













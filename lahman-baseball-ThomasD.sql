

-- 1- Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?



SELECT p.playerid, namefirst, namelast, namegiven, schoolid, yearid
FROM people AS p
INNER JOIN collegeplaying AS cp
ON p.playerid = cp.playerid



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
3- Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends? (Hint: For this question, you might find it helpful to look at 
the generate_series function (https://www.postgresql.org/docs/9.1/functions-srf.html). If you want to see an example of this in action, 
check out this DataCamp video: https://campus.datacamp.com/courses/exploratory-data-analysis-in-sql/summarizing-and-aggregating-numeric-data?ex=6)
*/


-- I believe that for whichever table, batting or pitching, that the number of strikeouts and homeruns would be the same so I only have 
-- to use one. If i used both, it would double up (since a batter can hit a home run and a pitcher can throw a ball for a homerun?)


SELECT * AS year
FROM generate_series(1920,2020,10)

SELECT DISTINCT(stint)
FROM batting

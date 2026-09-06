-- Rank teams within each season by number of matches won , showing season year, team name, wins, and rank.
    
SELECT s.year, t.team_name, COUNT(*) AS wins,
		RANK() OVER (PARTITION BY s.year ORDER BY COUNT(*) DESC) AS season_rank
FROM matches m
JOIN seasons s ON m.season_id = s.season_id
JOIN teams t   ON m.winner_team_id = t.team_id
GROUP BY s.year, t.team_name
ORDER BY s.year, season_rank;

-- For each batsman, calculate a running total of runs scored across their matches in chronological order (use SUM() OVER (... ORDER BY match_date)).

SELECT p.player_name, m.match_date, st.runs_scored,
		sum(st.runs_scored) over(PARTITION BY st.player_id ORDER BY m.match_date) as running_runs
FROM player_match_stats as st
JOIN players as p ON st.player_id = p.player_id
JOIN matches as m ON st.match_id = m.match_id
ORDER BY p.player_id, m.match_id;

-- Find the top 3 highest run-scorers in player_match_stats for each season using DENSE_RANK() or ROW_NUMBER().

WITH top_runscorer as ( 
		SELECT p.player_name, s.year, sum(st.runs_scored) as total_runs,
			dense_rank() over(PARTITION BY year ORDER BY sum(st.runs_scored) DESC) as rnk
			FROM player_match_stats as st
			JOIN players as p ON st.player_id = p.player_id
			JOIN matches as m ON st.match_id = m.match_id
			JOIN seasons as s ON m.season_id = s.season_id
			GROUP BY s.year, p.player_name
)
SELECT year, player_name, total_runs, rnk
FROM top_runscorer
WHERE rnk <= 3
ORDER BY year, rnk;

-- Using LAG()/LEAD(), compare each team's win count in the current season vs the previous season, and flag whether their performance improved, declined, or stayed the same.

WITH team_wins AS (
    SELECT s.year, t.team_id, t.team_name, COUNT(*) AS wins
    FROM matches m
    JOIN seasons s ON m.season_id = s.season_id
    JOIN teams t   ON m.winner_team_id = t.team_id
    GROUP BY s.year, t.team_id, t.team_name
)
SELECT year, team_name, wins,
       LAG(wins) OVER (PARTITION BY team_id ORDER BY year) AS previous_season_wins,
       CASE
           WHEN LAG(wins) OVER (PARTITION BY team_id ORDER BY year) IS NULL THEN 'No Prior Data'
           WHEN wins > LAG(wins) OVER (PARTITION BY team_id ORDER BY year) THEN 'Improved'
           WHEN wins < LAG(wins) OVER (PARTITION BY team_id ORDER BY year) THEN 'Declined'
           ELSE 'Same'
       END AS trend
FROM team_wins
ORDER BY team_name, year;

-- Find all players whose total career runs are above the overall average runs per player (use a subquery or CTE).

WITH player_totals AS (
    SELECT player_id, SUM(runs_scored) AS total_runs
    FROM player_match_stats
    GROUP BY player_id
)
SELECT p.player_name, pt.total_runs
FROM player_totals pt
JOIN players p ON pt.player_id = p.player_id
WHERE pt.total_runs > (SELECT AVG(total_runs) FROM player_totals)
ORDER BY pt.total_runs DESC;

-- Using a CTE, calculate each team's net run rate proxy: (total runs scored while batting − total runs conceded while bowling) / matches played, then rank teams by this metric.

WITH batting_runs AS (
    SELECT batting_team_id AS team_id, SUM(total_runs) AS runs_scored
    FROM innings GROUP BY batting_team_id
),
bowling_runs AS (
    SELECT bowling_team_id AS team_id, SUM(total_runs) AS runs_conceded
    FROM innings GROUP BY bowling_team_id
),
matches_played AS (
    SELECT team_id, COUNT(*) AS matches
    FROM (
        SELECT team1_id AS team_id FROM matches
        UNION ALL
        SELECT team2_id FROM matches
    ) x
    GROUP BY team_id
)
SELECT t.team_name,
       ROUND((br.runs_scored - bw.runs_conceded) * 1.0 / mp.matches, 2) AS nrr_proxy
FROM teams t
JOIN batting_runs br    ON t.team_id = br.team_id
JOIN bowling_runs bw    ON t.team_id = bw.team_id
JOIN matches_played mp  ON t.team_id = mp.team_id
ORDER BY nrr_proxy DESC;

-- Write a query using a correlated subquery to find the "Player of the Match" who has won the award the most number of times, along with the count.

SELECT p.player_name, t.cnt AS pom_awards
FROM (
    SELECT player_of_match_id, COUNT(*) AS cnt
    FROM matches
    GROUP BY player_of_match_id
) t
JOIN players p ON t.player_of_match_id = p.player_id
WHERE t.cnt = (
    SELECT MAX(cnt) FROM (
        SELECT COUNT(*) AS cnt FROM matches GROUP BY player_of_match_id
    ) x
);
-- Using a CTE, identify players who were bought in an auction for a price higher than their team's average sold price that season — a simple "overpriced signing" detector.

WITH team_season_avg AS (
    SELECT season_id, team_id, AVG(sold_price) AS avg_price
    FROM auctions
    GROUP BY season_id, team_id
)
SELECT p.player_name, s.year, t.team_name, a.sold_price, ROUND(tsa.avg_price,0) AS team_avg_price
FROM auctions a
JOIN team_season_avg tsa ON a.season_id = tsa.season_id AND a.team_id = tsa.team_id
JOIN players p ON a.player_id = p.player_id
JOIN teams t   ON a.team_id = t.team_id
JOIN seasons s ON a.season_id = s.season_id
WHERE a.sold_price > tsa.avg_price
ORDER BY s.year, a.sold_price DESC;

-- Build a multi-step CTE that computes: 
-- (a) runs per innings per player
-- (b) average runs per player
-- (c) then filters for players who scored above their own average in at least 3 di
WITH player_match_runs AS (
    SELECT player_id, match_id, runs_scored
    FROM player_match_stats
),
player_avg AS (
    SELECT player_id, AVG(runs_scored) AS avg_runs
    FROM player_match_runs
    GROUP BY player_id
),
above_avg_matches AS (
    SELECT pmr.player_id, pmr.match_id
    FROM player_match_runs pmr
    JOIN player_avg pa ON pmr.player_id = pa.player_id
    WHERE pmr.runs_scored > pa.avg_runs
)
SELECT p.player_name, COUNT(*) AS matches_above_own_avg
FROM above_avg_matches aam
JOIN players p ON aam.player_id = p.player_id
GROUP BY p.player_name
HAVING COUNT(*) >= 3
ORDER BY matches_above_own_avg DESC;
--  List all matches played at "Eden Gardens, Kolkata" along with the two competing team names and the winning team name.

SELECT m.match_id, m.match_date, t1.team_name as team1, t2.team_name as team2, tw.team_name as winners
FROM matches as m
JOIN teams AS t1 ON m.team1_id = t1.team_id
JOIN teams AS t2 ON m.team2_id = t2.team_id
JOIN teams AS tw ON m.winner_team_id = tw.team_id
WHERE m.venue = 'Eden Gardens, Kolkata';

-- Find all players who are "All-Rounder"s and belong to "Mumbai Indians", along with their nationality and batting style.

SELECT p.player_name, p.role, t.team_name, p.nationality, p.batting_style
FROM players as p 
JOIN teams as t ON  p.current_team_id = t.team_id
WHERE role = 'all-rounder' AND team_name = 'mumbai indians';

-- Show the season year, winner team name, and the orange cap holder's name for every season.

SELECT s.year, t.team_name, p.player_name
FROM seasons as s 
JOIN teams as t ON s.winner_team_id = t.team_id
JOIN players as p on s.orange_cap_player_id = p.player_id
ORDER BY s.year;

-- List all matches where the team that won the toss also went on to win the match, along with the toss decision they made.

SELECT m.match_id, m.toss_decision, t.team_name
FROM matches AS m
JOIN teams as t ON t.team_id = m.toss_winner_id
WHERE toss_winner_id = winner_team_id;

-- For each team, find the total number of matches won across all seasons, sorted from most to least wins.

SELECT t.team_name, count(m.winner_team_id) as total_wins
FROM teams as t
JOIN matches as m ON t.team_id = m.winner_team_id
GROUP BY t.team_name
ORDER BY total_wins desc;

-- Calculate the average total runs scored per innings for each team (as the batting team), rounded to 2 decimal places.

SELECT t.team_name, round(avg(i.total_runs),2) as avg_run_per_inin
FROM innings as i 
JOIN teams AS t ON t.team_id = i.batting_team_id
GROUP BY batting_team_id
ORDER BY avg_run_per_inin desc;

-- Find the number of matches played at each venue, and identify the venue that hosted the most matches.

SELECT venue, count(venue) AS matches_played
FROM matches
GROUP BY  venue
ORDER BY venue_matches DESC;

-- For each player, calculate total runs scored and total wickets taken across all matches (from player_match_stats), and list the top 10 all-rounders by combined runs + (wickets × 20).

SELECT p.player_name, 
	   sum(st.runs_scored) as total_runs, 
       sum(st.wickets_taken) as wikets_taken,
       sum(st.runs_scored) + sum(st.wickets_taken) * 20 as most_valuable
FROM player_match_stats as st
JOIN players AS p ON p.player_id = st.player_id
WHERE p.role = 'all-rounder'
GROUP BY p.player_name
ORDER BY most_valuable DESC
LIMIT 10;

-- Q9. Determine the toss-decision split (Bat vs Field) per venue — which venues favor batting first after winning the toss?

SELECT venue,
		sum(CASE WHEN toss_decision = 'bat'  THEN 1 ELSE 0 END) AS bat_first_count,
        sum(CASE WHEN toss_decision = 'field' THEN 1 ELSE 0 END ) as field_first_count
FROM matches
GROUP BY venue;

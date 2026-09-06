CREATE DATABASE IPL_Analytics_database;
USE IPL_Analytics_database;

CREATE TABLE teams ( 
   team_id      INT PRIMARY KEY,
   team_name    VARCHAR(100) NOT NULL,
   city         VARCHAR(50),
   owner        VARCHAR(100),
   founded_year INT
);
   
   SELECT * FROM teams;
   
CREATE TABLE players (
   player_id        INT PRIMARY KEY,
   player_name       VARCHAR(100) NOT NULL,
   current_team_id   INT,
   role              VARCHAR(20),
   batting_style     VARCHAR(30),
   bowling_style     VARCHAR(30),
   nationality       VARCHAR(30),
   date_of_birth     DATE,
   FOREIGN KEY (current_team_id) REFERENCES teams(team_id)
);

SELECT * FROM players;

CREATE TABLE seasons (
    season_id             INT PRIMARY KEY,
    year                  INT NOT NULL,
    winner_team_id        INT,
    orange_cap_player_id  INT,
    purple_cap_player_id  INT,
    FOREIGN KEY (winner_team_id) REFERENCES teams(team_id),
    FOREIGN KEY (orange_cap_player_id) REFERENCES players(player_id),
    FOREIGN KEY (purple_cap_player_id) REFERENCES players(player_id)
);

SELECT * FROM seasons;

CREATE TABLE matches (
    match_id            INT PRIMARY KEY,
    season_id            INT NOT NULL,
    team1_id             INT NOT NULL,
    team2_id             INT NOT NULL,
    venue                VARCHAR(100),
    match_date           DATE,
    toss_winner_id       INT,
    toss_decision        VARCHAR(10),
    winner_team_id       INT,
    win_by_type          VARCHAR(10),
    win_margin           INT,
    player_of_match_id   INT,
    FOREIGN KEY (season_id) REFERENCES seasons(season_id),
    FOREIGN KEY (team1_id) REFERENCES teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES teams(team_id),
    FOREIGN KEY (toss_winner_id) REFERENCES teams(team_id),
    FOREIGN KEY (winner_team_id) REFERENCES teams(team_id),
    FOREIGN KEY (player_of_match_id) REFERENCES players(player_id)
);
    
SELECT * FROM matches;

CREATE TABLE innings (
    innings_id       INT PRIMARY KEY,
    match_id         INT NOT NULL,
    batting_team_id  INT NOT NULL,
    bowling_team_id  INT NOT NULL,
    total_runs       INT,
    total_wickets    INT,
    overs            DECIMAL(4,1),
    FOREIGN KEY (match_id) REFERENCES matches(match_id),
    FOREIGN KEY (batting_team_id) REFERENCES teams(team_id),
    FOREIGN KEY (bowling_team_id) REFERENCES teams(team_id)
);

SELECT * FROM innings;

CREATE TABLE ball_by_ball (
	ball_id              INT PRIMARY KEY,
	innings_id           INT NOT NULL,
	over_number          INT,
	ball_number           INT,
	batsman_id            INT,
	bowler_id             INT,
	runs_scored           INT,
	extras                INT,
	is_wicket             TINYINT,
	dismissal_type        VARCHAR(20),
	dismissed_player_id   INT,
	FOREIGN KEY (innings_id) REFERENCES innings(innings_id),
	FOREIGN KEY (batsman_id) REFERENCES players(player_id),
	FOREIGN KEY (bowler_id) REFERENCES players(player_id),
	FOREIGN KEY (dismissed_player_id) REFERENCES players(player_id)
);

SELECT * FROM ball_by_ball;

CREATE TABLE player_match_stats (
    stat_id         INT PRIMARY KEY,
    player_id        INT NOT NULL,
    match_id         INT NOT NULL,
    team_id          INT NOT NULL,
    runs_scored      INT,
    balls_faced      INT,
    wickets_taken    INT,
    overs_bowled     DECIMAL(4,1),
    runs_conceded    INT,
    catches          INT,
    stumpings        INT,
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

SELECT * FROM player_match_stats;


CREATE TABLE auctions (
    auction_id     INT PRIMARY KEY,
    player_id       INT NOT NULL,
    season_id       INT NOT NULL,
    team_id         INT NOT NULL,
    sold_price      BIGINT,
    base_price      BIGINT,
    is_retained     TINYINT,
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (season_id) REFERENCES seasons(season_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

SELECT * FROM auctions;
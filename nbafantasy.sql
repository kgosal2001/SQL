-- 1 Players highest scoring season by MVP winner, ranked by PPG
SELECT m1.Player, ROUND(m1.PTS, 2) AS PTS, m1.Season
FROM MVP m1
INNER JOIN (
    SELECT Player, MAX(PTS) AS MaxPTS
    FROM MVP
    GROUP BY Player
) AS m2
ON m1.Player = m2.Player AND m1.PTS = m2.MaxPTS
ORDER BY ROUND(m1.PTS, 2) DESC;



-- 2 Players highest assists season by MVP winner, ranked by assists
SELECT m1.Player, ROUND(m1.AST, 2) AS AST, m1.Season
FROM MVP m1
INNER JOIN (
    SELECT Player, MAX(AST) AS MaxAST
    FROM MVP
    GROUP BY Player
) AS m2
ON m1.Player = m2.Player AND m1.AST = m2.MaxAST
ORDER BY ROUND(m1.AST, 2) DESC;



-- 3. Finds best fantasy season of all time using todays methods using a CTE to fill in NULLS
WITH bestplayersv2 AS (
SELECT
    Player,
    Season,
    Team,
    ISNULL(PTS, 0) AS Points,
    ISNULL([3PM], 0) AS Three_Pointers,
    ISNULL(FGM, 0) AS Field_Goals_Made,
    ISNULL(FGA, 0) AS Field_Goals_Attempted,
    ISNULL(FTM, 0) AS Free_Throws_Made,
    ISNULL(FTA, 0) AS Free_Throws_Attempted,
    ISNULL(REB, 0) AS Rebounds,
    ISNULL(AST, 0) AS Assists,
    ISNULL(STL, 0) AS Steals,
    ISNULL(BLK, 0) AS Blocks,
    ISNULL(TOV, 0) AS Turnovers
FROM bestplayers
)

SELECT Player,
    Season,
    Team, 
    ROUND((SUM(Points) + SUM(Three_Pointers) + SUM(Field_Goals_Made * 2) - SUM(Field_Goals_Attempted) + SUM(Free_Throws_Made) - SUM(Free_Throws_Attempted) + SUM(Rebounds) + (SUM(Assists) * 2) + (SUM(Steals) * 4) + (SUM(Blocks) * 4) - (SUM(Turnovers) * 2)), 3)
         as Total_Fantasy_Points,
    SUM(Points) as Total_Points,
    SUM(Three_Pointers) as Total_Three_Pointers,
    SUM(Field_Goals_Made) as Total_Field_Goals_Made,
    SUM(Field_Goals_Attempted) as Total_Field_Goals_Attempted,
    SUM(Free_Throws_Made) as Total_Free_Throws_Made,
    SUM(Free_Throws_Attempted) as Total_Free_Throws_Attempted,
    SUM(Rebounds) as Total_Rebounds,
    SUM(Assists) as Total_Assists,
    SUM(Steals) as Total_Steals,
    SUM(Blocks) as Total_Blocks,
    SUM(Turnovers) as Total_Turnovers
FROM bestplayersv2
GROUP BY Player, Season, Team
ORDER BY Total_Fantasy_Points DESC;



-- 4. (FILTERS OUT SEASONS WHERE THEY DIDNT TRACK STLs, BLKs, TOVs)
WITH bestplayersv2 AS (
SELECT
    Player,
    Season,
    Team,
    ISNULL(PTS, 0) AS Points,
    ISNULL([3PM], 0) AS Three_Pointers,
    ISNULL(FGM, 0) AS Field_Goals_Made,
    ISNULL(FGA, 0) AS Field_Goals_Attempted,
    ISNULL(FTM, 0) AS Free_Throws_Made,
    ISNULL(FTA, 0) AS Free_Throws_Attempted,
    ISNULL(REB, 0) AS Rebounds,
    ISNULL(AST, 0) AS Assists,
    ISNULL(STL, 0) AS Steals,
    ISNULL(BLK, 0) AS Blocks,
    ISNULL(TOV, 0) AS Turnovers
FROM bestplayers
)

SELECT Player,
    Season,
    Team, 
    ROUND((SUM(Points) + SUM(Three_Pointers) + SUM(Field_Goals_Made * 2) - SUM(Field_Goals_Attempted) + SUM(Free_Throws_Made) - SUM(Free_Throws_Attempted) + SUM(Rebounds) + (SUM(Assists) * 2) + (SUM(Steals) * 4) + (SUM(Blocks) * 4) - (SUM(Turnovers) * 2)), 3)
         as Total_Fantasy_Points,
    SUM(Points) as Total_Points,
    SUM(Three_Pointers) as Total_Three_Pointers,
    SUM(Field_Goals_Made) as Total_Field_Goals_Made,
    SUM(Field_Goals_Attempted) as Total_Field_Goals_Attempted,
    SUM(Free_Throws_Made) as Total_Free_Throws_Made,
    SUM(Free_Throws_Attempted) as Total_Free_Throws_Attempted,
    SUM(Rebounds) as Total_Rebounds,
    SUM(Assists) as Total_Assists,
    SUM(Steals) as Total_Steals,
    SUM(Blocks) as Total_Blocks,
    SUM(Turnovers) as Total_Turnovers
FROM bestplayersv2
GROUP BY Player, Season, Team
HAVING SUM(Steals) > 0 AND SUM(Turnovers) > 0 AND SUM(Steals) > 0
ORDER BY Total_Fantasy_Points DESC;



-- 5. Exploring fantasy scoring trends over time
WITH bestplayersv2 AS (
SELECT
    Player,
    Season,
    Team,
    ISNULL(PTS, 0) AS Points,
    ISNULL([3PM], 0) AS Three_Pointers,
    ISNULL(FGM, 0) AS Field_Goals_Made,
    ISNULL(FGA, 0) AS Field_Goals_Attempted,
    ISNULL(FTM, 0) AS Free_Throws_Made,
    ISNULL(FTA, 0) AS Free_Throws_Attempted,
    ISNULL(REB, 0) AS Rebounds,
    ISNULL(AST, 0) AS Assists,
    ISNULL(STL, 0) AS Steals,
    ISNULL(BLK, 0) AS Blocks,
    ISNULL(TOV, 0) AS Turnovers
FROM bestplayers
)
Select 
    Season,
    ROUND((AVG(Points) + AVG(Three_Pointers) + AVG(Field_Goals_Made * 2) - AVG(Field_Goals_Attempted) + AVG(Free_Throws_Made) - AVG(Free_Throws_Attempted) + AVG(Rebounds) + (AVG(Assists) * 2) + (AVG(Steals) * 4) + (AVG(Blocks) * 4) - (AVG(Turnovers) * 2)), 3)
         as AVG_Fantasy_Points
FROM bestplayersv2
GROUP BY Season
ORDER BY Season;



-- 6. Players with most seasons in the top 1000 seasons
WITH bestplayersv2 AS (
SELECT
    Player,
    Season,
    Team,
    ISNULL(PTS, 0) AS Points,
    ISNULL([3PM], 0) AS Three_Pointers,
    ISNULL(FGM, 0) AS Field_Goals_Made,
    ISNULL(FGA, 0) AS Field_Goals_Attempted,
    ISNULL(FTM, 0) AS Free_Throws_Made,
    ISNULL(FTA, 0) AS Free_Throws_Attempted,
    ISNULL(REB, 0) AS Rebounds,
    ISNULL(AST, 0) AS Assists,
    ISNULL(STL, 0) AS Steals,
    ISNULL(BLK, 0) AS Blocks,
    ISNULL(TOV, 0) AS Turnovers
FROM bestplayers
),

bestplayersv3 AS(
    SELECT Player,
    Season,
    Team, 
    ROUND((SUM(Points) + SUM(Three_Pointers) + SUM(Field_Goals_Made * 2) - SUM(Field_Goals_Attempted) + SUM(Free_Throws_Made) - SUM(Free_Throws_Attempted) + SUM(Rebounds) + (SUM(Assists) * 2) + (SUM(Steals) * 4) + (SUM(Blocks) * 4) - (SUM(Turnovers) * 2)), 3)
         as Total_Fantasy_Points,
    SUM(Points) as Total_Points,
    SUM(Three_Pointers) as Total_Three_Pointers,
    SUM(Field_Goals_Made) as Total_Field_Goals_Made,
    SUM(Field_Goals_Attempted) as Total_Field_Goals_Attempted,
    SUM(Free_Throws_Made) as Total_Free_Throws_Made,
    SUM(Free_Throws_Attempted) as Total_Free_Throws_Attempted,
    SUM(Rebounds) as Total_Rebounds,
    SUM(Assists) as Total_Assists,
    SUM(Steals) as Total_Steals,
    SUM(Blocks) as Total_Blocks,
    SUM(Turnovers) as Total_Turnovers
FROM bestplayersv2
GROUP BY Player, Season, Team)


Select Player, COUNT(*) AS GreatFantasySeasons
FROM bestplayersv3
GROUP BY Player
ORDER BY COUNT(*) DESC;




-- 7. Positional Analysis
WITH bestplayersv2 AS (
SELECT
    Player,
    Season,
    Team,
    ISNULL(PTS, 0) AS Points,
    ISNULL([3PM], 0) AS Three_Pointers,
    ISNULL(FGM, 0) AS Field_Goals_Made,
    ISNULL(FGA, 0) AS Field_Goals_Attempted,
    ISNULL(FTM, 0) AS Free_Throws_Made,
    ISNULL(FTA, 0) AS Free_Throws_Attempted,
    ISNULL(REB, 0) AS Rebounds,
    ISNULL(AST, 0) AS Assists,
    ISNULL(STL, 0) AS Steals,
    ISNULL(BLK, 0) AS Blocks,
    ISNULL(TOV, 0) AS Turnovers
FROM bestplayers
)
, fantasystats AS(
    SELECT Player,
    Season,
    Team, 
    ROUND((SUM(Points) + SUM(Three_Pointers) + SUM(Field_Goals_Made * 2) - SUM(Field_Goals_Attempted) + SUM(Free_Throws_Made) - SUM(Free_Throws_Attempted) + SUM(Rebounds) + (SUM(Assists) * 2) + (SUM(Steals) * 4) + (SUM(Blocks) * 4) - (SUM(Turnovers) * 2)), 3)
         as Total_Fantasy_Points,
    SUM(Points) as Total_Points,
    SUM(Three_Pointers) as Total_Three_Pointers,
    SUM(Field_Goals_Made) as Total_Field_Goals_Made,
    SUM(Field_Goals_Attempted) as Total_Field_Goals_Attempted,
    SUM(Free_Throws_Made) as Total_Free_Throws_Made,
    SUM(Free_Throws_Attempted) as Total_Free_Throws_Attempted,
    SUM(Rebounds) as Total_Rebounds,
    SUM(Assists) as Total_Assists,
    SUM(Steals) as Total_Steals,
    SUM(Blocks) as Total_Blocks,
    SUM(Turnovers) as Total_Turnovers
FROM bestplayersv2
GROUP BY Player, Season, Team)

SELECT 
    AVG(Total_Fantasy_Points) AS AVG_FPTS, 
    (CASE 
        WHEN POSITION = 'Forward-Center' THEN 'Forward'
        WHEN POSITION = 'Center-Forward' THEN 'Center'
        WHEN POSITION = 'Forward-Guard' THEN 'Forward'
        WHEN POSITION = 'Guard-Forward' THEN 'Guard' 
        ELSE POSITION END) as POSITION
FROM fantasystats 
INNER JOIN common_player_info as c
ON CONCAT(c.first_name, ' ', c.last_name) = fantasystats.Player
GROUP BY (CASE 
        WHEN POSITION = 'Forward-Center' THEN 'Forward'
        WHEN POSITION = 'Center-Forward' THEN 'Center'
        WHEN POSITION = 'Forward-Guard' THEN 'Forward'
        WHEN POSITION = 'Guard-Forward' THEN 'Guard' 
        ELSE POSITION END)
ORDER BY AVG(Total_Fantasy_Points) DESC
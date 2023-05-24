--exploring and cleaning data to verify that ride ids are unique

 SELECT DISTINCT COUNT(ride_id) AS total_rides,  COUNT (ride_id) AS not_distinct
  FROM [Cyclistic_Trip_Data].[dbo].[1_22]

 
  -- check how many of each bike type are used 

  SELECT rideable_type AS bike_type, COUNT(rideable_type) AS total_by_type 
  FROM [Cyclistic_Trip_Data].[dbo].[1_22]
  GROUP BY rideable_type

  --investigate how many of each type of user there is

  SELECT DISTINCT member_casual AS member_type, COUNT(member_casual) AS total_members
  FROM [Cyclistic_Trip_Data].[dbo].[1_22]
  GROUP BY member_casual

--union for whole year data 

CREATE TABLE [Cyclistic_Trip_Data].[dbo].full_[year22] 
	(ride_id nvarchar(50)
      ,[rideable_type] nvarchar(50)
      ,[started_at] datetime2
      ,[ended_at] datetime2
      ,[start_station_name] nvarchar(100)
      ,[start_station_id] nvarchar(100)
      ,[end_station_name] nvarchar(100)
      ,[end_station_id] nvarchar(100)
      ,[start_lat] float
      ,[start_lng] float
      ,[end_lat] float
      ,[end_lng] float
      ,[member_casual] nvarchar(50))

INSERT INTO [Cyclistic_Trip_Data].[dbo].full_year22 
 SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[1_22]
     UNION ALL 
     SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[2_22]
     UNION ALL SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[3_22]
     UNION ALL SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[4_22]
     UNION ALL SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[5_22]
     UNION ALL SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[6_22]
     UNION ALL SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[7_22]
     UNION ALL SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[8_22]
     UNION ALL SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[9_22]
     UNION ALL SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[10_22]
     UNION ALL SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[11_22]
     UNION ALL SELECT * 
	 FROM [Cyclistic_Trip_Data].[dbo].[12_22]
    

SELECT *
FROM [Cyclistic_Trip_Data].[dbo].full_year22;

-- calculate duration 
  SELECT 
  ride_id
  started_at,
  ended_at,
  DATEDIFF(minute, started_at, ended_at) AS duration_in_minutes
  FROM [Cyclistic_Trip_Data].[dbo].full_year22


  --query for no null stations, date and time or trip, and the duration of trip in minutes

  SELECT start_station_name, end_station_name,
  CAST(started_at AS date) AS start_date,
  CAST(ended_at AS date) AS end_date,
  DATEDIFF(minute, started_at, ended_at) AS duration_in_minutes
  FROM [Cyclistic_Trip_Data].[dbo].[full_year22]
  WHERE start_station_name IS NOT NULL AND end_station_name IS NOT NULL

  --to exclude the less than 0 min rides
  WITH clean_data AS
  (
  SELECT ride_id, member_casual, rideable_type, start_station_name, end_station_name,
  CAST(started_at AS date) AS start_date,
  CAST(ended_at AS date) AS end_date,
  DATEDIFF(minute, started_at, ended_at) AS duration_in_minutes
  FROM [Cyclistic_Trip_Data].[dbo].[full_year22]
  WHERE start_station_name IS NOT NULL AND end_station_name IS NOT NULL
  )

SELECT *
FROM clean_data
WHERE duration_in_minutes > 0


  -- calculate distance traveled using Haversine formula

SELECT 
    [start_lat],
    [start_lng],
    [end_lat],
    [end_lng],
    2 * 6371 * ASIN(
        SQRT(
            POWER(
                SIN(RADIANS([end_lat] - [start_lat]) / 2), 2) +
            COS(RADIANS([start_lat])) *
            COS(RADIANS([end_lat])) *
            POWER(SIN(RADIANS([end_lng] - [start_lng]) / 2), 2)
        )
    ) AS [distance_in_km]
FROM [Cyclistic_Trip_Data].[dbo].[full_year22]

SELECT AVG([distance_in_km]) AS [average_distance]
FROM [Cyclistic_Trip_Data].[dbo].[full_year22]
GROUP BY member_casual

--find average distance to see what differences exist between membership types 
SELECT AVG([distance_in_km]) AS [average_distance]
FROM (
    SELECT 
        2 * 6371 * ASIN(
            SQRT(
                POWER(
                    SIN(RADIANS([end_lat] - [start_lat]) / 2), 2) +
                COS(RADIANS([start_lat])) *
                COS(RADIANS([end_lat])) *
                POWER(SIN(RADIANS([end_lng] - [start_lng]) / 2), 2)
            )
        ) AS [distance_in_km]
    FROM [Cyclistic_Trip_Data].[dbo].[full_year22]
) AS avg_distance_in_km

SELECT 
    member_casual,
    AVG([distance_in_km]) AS [average_distance]
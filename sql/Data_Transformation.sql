-- Step 1: Combine the two bike share tables
WITH combined_bike AS (
  SELECT
    CAST(dteday AS DATE) AS ride_date,
    season,
    yr,
    mnth,
    hr,
    holiday,
    weekday,
    workingday,
    weathersit,
    temp,
    atemp,
    hum,
    windspeed,
    rider_type,
    riders
  FROM bike_share_year_0
  UNION ALL
  SELECT
    CAST(dteday AS DATE) AS ride_date,
    season,
    yr,
    mnth,
    hr,
    holiday,
    weekday,
    workingday,
    weathersit,
    temp,
    atemp,
    hum,
    windspeed,
    rider_type,
    riders
  FROM bike_share_year_1
),

-- Step 2: Preprocess the cost table
-- (Assuming that the imported cost_table has a date column (dteday) and hour column (hr)
-- along with a cost value; adjust the column names as needed.)
processed_cost AS (
  SELECT
    CAST(dteday AS DATE) AS ride_date,
    hr,
    cost
  FROM cost_table
  -- You could add more cleaning steps here if needed (for example, filtering out nulls)
)

-- Step 3: Join the combined bike data with the cost data and add derived columns.
SELECT
  cb.ride_date,
  cb.hr,
  cb.season,
  cb.yr,
  cb.mnth,
  cb.weekday,
  cb.workingday,
  cb.weathersit,
  cb.rider_type,
  cb.riders,
  cb.temp,
  cb.atemp,
  cb.hum,
  cb.windspeed,
  pc.cost,
  -- Example: derive a day type based on holiday/working day flags
  CASE 
    WHEN cb.holiday = 1 THEN 'Holiday'
    WHEN cb.workingday = 1 THEN 'Working Day'
    ELSE 'Weekend'
  END AS day_type,
  -- Example: convert normalized temperature to an estimated Celsius value 
  ROUND(cb.temp * 41.0, 2) AS actual_temperature
FROM combined_bike cb
LEFT JOIN processed_cost pc
  ON cb.ride_date = pc.ride_date
  AND cb.hr = pc.hr;
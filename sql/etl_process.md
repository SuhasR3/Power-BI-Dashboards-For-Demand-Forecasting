# ETL Process Documentation

This document briefly outlines the steps used to extract, transform, and load our raw data from CSV files (stored in the `Dataset` folder) into our MySQL database. The three main files are:

- `bike_share_year_0.csv`
- `bike_share_year_1.csv`
- `profit_table.csv`

## Extraction

We load the CSV files into their corresponding MySQL tables. For example, the bike share data is loaded with:
```
LOAD DATA INFILE '/absolute/path/to/Dataset/bike_share_year_0.csv'
INTO TABLE bike_share_year_0
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
```

Repeat similar commands for `cost_table.csv` and `profit_table.csv`.

## Transformation

Next, we merge the data from the three tables. We convert the date string into a proper DATE type and join on the common `dteday` field. For example:
```
CREATE OR REPLACE VIEW merged_data AS
SELECT
STR_TO_DATE(bs.dteday, '%c/%e/%Y') AS date,
bs.season,
bs.yr,
bs.mnth,
bs.hr,
bs.holiday,
bs.weekday,
bs.workingday,
bs.weathersit,
bs.temp,
bs.atemp,
bs.hum,
bs.windspeed,
bs.rider_type,
bs.riders,
IFNULL(ct.cost, 0) AS cost,
IFNULL(pt.profit, 0) AS profit
FROM bike_share_year_0 AS bs
LEFT JOIN cost_table AS ct
ON STR_TO_DATE(bs.dteday, '%c/%e/%Y') = STR_TO_DATE(ct.dteday, '%c/%e/%Y')
LEFT JOIN profit_table AS pt
ON STR_TO_DATE(bs.dteday, '%c/%e/%Y') = STR_TO_DATE(pt.dteday, '%c/%e/%Y');
```


## Loading

Finally, we filter out any incomplete or irrelevant records and load the data into a final table ready for analysis:
```
CREATE TABLE cleaned_merged_data AS
SELECT *
FROM merged_data
WHERE riders IS NOT NULL
AND riders > 0
AND temp IS NOT NULL;
```


## Summary

- **Extraction:** Load raw CSV files into MySQL tables using `LOAD DATA INFILE`.
- **Transformation:** Create a merged view by standardizing dates, joining tables, and handling missing values with `IFNULL`.
- **Loading:** Create a cleaned table with filters to ensure the data is ready for analysis in Power BI.

This concise document covers the core steps of the ETL process and includes well-formatted SQL code blocks for clarity. You can adjust file paths, table names, and filtering criteria as needed for your specific project.

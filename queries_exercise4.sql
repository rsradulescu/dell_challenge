-----------------------------------------------------------------------------------
-- EXCERSISE 4: ---
-- queries
-----------------------------------------------------------------------------------
-- 4.1 What is the country with the highest number of Covid-19 cases per 100 000 Habitants at 31/07/2020?
create or replace temp view cumulative_population_total as (
	SELECT country, country_code,continent, population, (cumulative_count/population)*100000 AS cumulative_population_100000_hab, (weekly_count/population)*100000 AS cumulative_week_100000_hab 
	FROM public.covid_notifications
	where
		-- get week number by date
		(DATE_PART('year','31/07/2020'::date)||'-'||DATE_PART('week', '31/07/2020'::date)) = year_week
		AND indicator = 'cases'
)	
SELECT country, country_code,continent, cumulative_population_100000_hab 
FROM cumulative_population_total
order by cumulative_population_100000_hab desc
limit 1


-- 4.2 What is the top 10 countries with the lowest number of Covid-19 cases per 100 000 Habitants at 31/07/2020?
SELECT country, country_code,continent, cumulative_population_100000_hab 
FROM cumulative_population_total
order by cumulative_population_100000_hab asc
limit 10


-- 4.3 What is the top 10 countries with the highest number of cases among the top 20 richest countries (by GDP per capita)?
-- PROBLEM: the union column is a text column, not recommended, I use trim and lower to best match
SELECT
	distinct country ,
	first_value(weekly_count) OVER(PARTITION BY country ORDER BY weekly_count desc  ) max_weekly_count
FROM public.covid_notifications AS cn
	JOIN (SELECT "Country", "Region",  "GDP ($ per capita)"
			FROM
				public.countries
			WHERE "GDP ($ per capita)" is not null 
			ORDER BY "GDP ($ per capita)" desc
			LIMIT 20) AS richest_countries ON lower(trim(cn.country)) = lower(trim(richest_countries."Country"))
WHERE 
	 weekly_count IS NOT NULL
	 AND indicator = 'cases'
ORDER BY 2 DESC
LIMIT 10


-- 4.4 List all the regions with the number of cases per million of inhabitants and display information on population density, for 31/07/2020.
-- PROBLEM1: not all countries have a region in "countries" table
-- PROBLEM2: need changing comma to decimal in density and transform interger value
WITH values_by_region as
(	
	SELECT distinct "Region" , "Country", "Population" , cumulative_count , replace("Pop. Density (per sq. mi.)", ',', '.')::numeric AS density
	FROM public.countries 
		JOIN covid_notifications cn ON lower(trim(cn.country)) = lower(trim(countries."Country"))
	WHERE
		-- get week number by date
		(DATE_PART('year','31/07/2020'::date)||'-'||DATE_PART('week', '31/07/2020'::date)) = year_week
		AND indicator = 'cases'
) SELECT 
	"Region", 
	(sum(cumulative_count)/sum("Population"))*1000000 AS cumulative_pop_region,
	sum(density) as regional_density
FROM values_by_region
GROUP BY "Region"
ORDER BY 2,1
	

-- 4.5 Query the data to find duplicated records
-- If there is a row  with count >1 is duplicated. 

------- Table countries
SELECT 
	"Country", "Region", "Population", "Area (sq. mi.)", "Pop. Density (per sq. mi.)",  count(*)
	--"Coastline (coast/area ratio)", "Net migration", "Infant mortality (per 1000 births)", "GDP ($ per capita)", "Literacy (%)", "Phones (per 1000)", "Arable (%)", "Crops (%)", "Other (%)", "Climate", "Birthrate", "Deathrate", "Agriculture", "Industry", "Service" , count(*)
FROM
	public.countries 
GROUP BY
	"Country", "Region", "Population", "Area (sq. mi.)", "Pop. Density (per sq. mi.)"
	-- , "Coastline (coast/area ratio)", "Net migration", "Infant mortality (per 1000 births)", "GDP ($ per capita)", "Literacy (%)", "Phones (per 1000)", "Arable (%)", "Crops (%)", "Other (%)", "Climate", "Birthrate", "Deathrate", "Agriculture", "Industry", "Service"
HAVING count(*)>1

------- Table covid_notifications
SELECT
	country, country_code, continent, population, indicator, year_week, source, note, weekly_count, cumulative_count, rate_14_day, count(*)
FROM
	public.covid_notifications
GROUP BY
	country, country_code, continent, population, indicator, year_week, source, note, weekly_count, cumulative_count, rate_14_day
HAVING count(*)>1


-- 4.6 Analyze the performance of all the queries and describes what you see. Get improvements suggestions
-- Personal Recommendations:
	-- [4.1 and 4.2]: the date formats do not match between what we are looking for and what we have in the table. We could obtain a confusing or unwanted result.
	-- [4.3]: the join columns between tables are text columns, not recommended, I use trim and lower to best match.
	-- [4.4]: PROBLEM1: not all countries have a region in "countries" table.
		-- 	PROBLEM2: need changing comma to decimal in density and transform interger value.
	-- DATASET: I see in covid_notifications that country_code sometimes is empty, and one country name is "EU/EEA (total)". Some columns need to be cleaned.

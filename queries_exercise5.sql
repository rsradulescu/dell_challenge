-----------------------------------------------------------------------------------
-- EXCERSISE 5: ---
-- enrich the information
-- source: https://www.kaggle.com/datasets/mashrurayon/gender-metrics-by-country
-- reccomend try correlation matrix
-----------------------------------------------------------------------------------

-- get top 10 cumulative_count deaths the last week reported 
CREATE OR REPLACE VIEW cumulated_deaths_last_week AS 
(
	SELECT country, country_code, continent, population, indicator, year_week, weekly_count, cumulative_count
	FROM  
		public.covid_notifications
	WHERE
		year_week = (select max(year_week) from public.covid_notifications)
		AND indicator = 'deaths'
		AND cumulative_count is not null
		AND country not like '%total%' 
	order by cumulative_count desc
	LIMIT 10
)



-- DEATHS: get female and male life_expectancy compared with cumulative_count 
SELECT
	cdlw.country, cdlw.continent,cumulative_count , female_life_expectancy, male_life_expectancy, expected_schooling_female, expected_schooling_male 
FROM 
	gender_metrics_by_country gmc
	JOIN cumulated_deaths_last_week cdlw ON LOWER(TRIM(cdlw.country)) = LOWER(TRIM(gmc.country))
order by cumulative_count desc

	
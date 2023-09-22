-----------------------------------------------------------------------------------
-- EXCERSISE 3: ---
-- VIEW WITH: latest number of cases, “Cumulative_number_for_14_days_of_COVID-19_cases_per_100000” and date
-- The formula to calculate the 14-day cumulative number of reported COVID-19 cases per 100 000 population is  (New cases over 14 day period)/Population)*100 000.
-----------------------------------------------------------------------------------
CREATE VIEW cumulative_14_days_covid as 
	WITH latest_14_days_cases AS
	(
		SELECT 
			country, continent, population, indicator,year_week,	
			sum(weekly_count) OVER (ORDER BY country , year_week DESC ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING ) as "sum_14days_cases" 
		FROM 
			public.covid_notifications
		WHERE 
			indicator = 'cases'
		ORDER 
			BY country , year_week DESC
	)
	SELECT 
		country, continent, population, indicator,year_week,
		(sum_14days_cases/population)*100000 as Cumulative_number_for_14_days_of_COVID,
		NOW()::date AS "updated_day"
	FROM latest_14_days_cases


----------------
-- Validate
-- select * from cumulative_14_days_covid
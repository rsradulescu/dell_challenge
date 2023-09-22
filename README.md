# Dell Technologies
## Data Engineering Challenge 



In this challenge I have applied knowledge of data engineering and data analysis with PostgreSQL database and Python code.

# Exercise 1


I Developed a Python pipeline to extract data from different sources into Postgres. The library used to connect and write in Postgres is SQLALchemy.

- DATA SOURCE 1: json URL 
- DATA SOURCE 1: kaggle csv dataset. This requires downloading the Kaggle API to be able to download the datasets locally.

The resolution of this exercise is in loading_data.py. In the file you will find different functions to generate the connection to PostgreSQL, create the dataframes with the information of the sources, and save the dataframes in database tables.
To test the pipeline you must execute the main function handler_main()

NOTE: Kaggle API Documentation: https://github.com/Kaggle/kaggle-api
To use the Kaggle API we must download the json token from our Kaggle account, preferably save it in the repository and execute the following command:
	
$pip install kaggle --upgrade



# Exercise 2

Updating new data can be done in many ways, for example using merge or upsert functions, on the SQL side or in Python development.

For the solution of this exercise I decided to use the "upsert" function of SQLAlchemy compatible with “INSERT ON CONFLICT” of PostgreSQL, where if new records are found the library creates them, otherwise it updates them.

Before executing the pipeline we need to previously define an index in the database, which will be used as a unique key to perform the update. In this case I use:
CREATE UNIQUE INDEX covid_notifications_index on public.covid_notifications (year_week, country, indicator)

The pipeline with the solution is called upsert_notification_covid.py and it has no main function, so we can run it directly from any code editor.

### Documentation:
- https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.to_sql.html
- https://docs.sqlalchemy.org/en/20/dialects/postgresql.html#postgresql-insert-on-conflict



# Exercise 3
The solution to this exercise uses a temporal view with a windows function where you obtain for each “country” and “year_week” the sum of the “weekly_counts” of the last 14 days.
With this result I could perform the calculation of Cumulative_number_for_14_days_of_COVID. 

The solution file is cumulative_14_days_covid_view.sql 



# Exercise 4
I solved the queries in exercise 4 in SQL, with functions and views, trying to apply good data analysis practices.

I would recommend doing them in a Python notebook or with R to get a better visualization and understanding of the results. In order not to extend the delivery time of the solution, I only developed it in SQL.

The queries are in the queries_exercise4.sql file.

# Exercise 5
To enrich the information, I decided to adapt the script from exercise 1 to create a new SQL table from a new Kaggle dataset. This table is “gender_metrics_by_country”.

This dataset contains information obtained between 12/31/2020 and 11/01/2022, and you can find information about countries and gender metrics such as life expectancy or expected schooling.

I only included an example query with this new dataset. The query can be found in the queries_exercise5.sql file.

In the solution I created a view that gets the data for the 10 countries that have the most deaths recorded in the last reported week. Based on these data, it is compared how aspects of gender influence the number of deaths.

A possible positive correlation is observed between the number of deaths registered and the life expectancy of the inhabitants. As the number of registered deaths increases, there is also a greater tendency towards longer life expectancy. With this sample we can infer that countries where the population is mostly elderly, and life expectancy is greater, will also have a greater chance of dying when contracting covid.



SOURCE: https://www.kaggle.com/datasets/mashrurayon/gender-metrics-by-country

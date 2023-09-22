import sys
from zipfile import ZipFile
import kaggle.cli
import pandas as pd
import requests
from sqlalchemy import create_engine
import opendatasets as od


# ----------------------------------------------------------------------
#   Exercise 1: Loading Data
# ----------------------------------------------------------------------
def loading_covid_json():
    """
    Create new df with JSON data from URL Covid
    :return: dataframe
    """
    response_covid = requests.get(url='https://opendata.ecdc.europa.eu/covid19/nationalcasedeath/json', timeout=10,
                                  headers={'Content-Type': 'application/json'})
    df_covid19_json = pd.read_json(response_covid.text)
    return df_covid19_json


def get_engine():
    """
    Create Postgres engine
    :return: engine
    """
    conn_string = 'postgresql+psycopg2://postgres:micentos@localhost:5432/dell_challenge'
    db = create_engine(conn_string)
    return db


def postgres_connect():
    """
    Postgres connection with sqlalchemy
    :return: connection string
    """
    db = get_engine()
    conn = db.connect()

    if conn:
        print("Connected to the database")
        return conn


def df_to_postgres(df, table_name, conn):
    """
    Save df data in postgres table
    :param df: df to save in sql table
    :param table_name: table in postgresql
    :param conn: conn string
    """
    try:
        df.to_sql(table_name, conn, if_exists='replace')
        print("Rows inserted in table:", table_name)
    except Exception as e:
        print("Problem inserting rows:", e)


def loading_countries_kaggle():
    """
    Get csv from kaggle with kaggle API. Save csv in df.
    Configure kaggle.api
    :return dataframe
    """
    od.download(
        "https://www.kaggle.com/fernandol/countries-of-the-world/data?select=countries+of+the+world.csv")

    df_contries_csv = pd.read_csv('countries-of-the-world/countries of the world.csv')
    # print(df_contries_csv.head())
    return df_contries_csv

def loading_gender_metrics_kaggle():
    """
    Get csv from kaggle with kaggle API. Save csv in df.
    Configure kaggle.api
    :return dataframe
    """
    od.download(
        "https://www.kaggle.com/datasets/mashrurayon/gender-metrics-by-country/download?datasetVersionNumber=1")

    df_gender_metrics_csv = pd.read_csv('gender-metrics-by-country/real-data.csv')
    # print(df_contries_csv.head())
    return df_gender_metrics_csv


def handler_main():
    """
    Principal main
    """
    # Create connection string
    connection = postgres_connect()

    # Create df with URL
    df_covid19 = loading_covid_json()
    df_countries = loading_countries_kaggle()
    #df to exercise 5
    df_gender_metrics = loading_gender_metrics_kaggle()

    # Save df to postgres tables
    df_to_postgres(df_covid19, 'covid_notifications', connection)
    df_to_postgres(df_countries, 'countries', connection)
    df_to_postgres(df_gender_metrics, 'gender_metrics_by_country', connection)

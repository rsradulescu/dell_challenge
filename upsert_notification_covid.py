from sqlalchemy import Integer
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy import MetaData, Table, Column
import loading_data


# ----------------------------------------------------------------------
#   Exercise 2: Get new values from notifications covid and upsert results in Postgres
#   Use loading_data.py
# ----------------------------------------------------------------------
def get_metadata():
    engine = loading_data.get_engine()
    metadata = MetaData()
    return metadata


def create_upsert_method(meta: MetaData):
    """
    SOLUTION: Use "ON CONFLICT" (upsert) alternative from SQLAlchemy library
    https://docs.sqlalchemy.org/en/13/dialects/postgresql.html#insert-on-conflict-upsert
    :param metadata sqlalchemy
    :return: method for to_sql
    """

    def method(table, conn, keys, data_iter):
        """
        Main upsert method
        """
        # list of dictionaries {col_name: value} of data to insert
        values_to_insert = [dict(zip(keys, data)) for data in data_iter]
        print(values_to_insert)

        insert_stmt = insert(table.table).values(values_to_insert) # insert(sql_table, values_to_insert)
        # create update statement for excluded fields on conflict
        update_stmt = {exc_k.key: exc_k for exc_k in insert_stmt.excluded}

        # create upsert statement.
        upsert_stmt = insert_stmt.on_conflict_do_update(
            index_elements=["year_week", "country", "indicator"],  # index elements are primary keys of a table
            set_= update_stmt  # the SET part of an INSERT statement
        )

        # execute upsert statement
        conn.execute(upsert_stmt)

    return method


#----------------------------------------
# first exec:CREATE UNIQUE INDEX covid_notifications_index on public.covid_notifications (year_week, country, indicator)

# create upsert method that is accepted by pandas API
meta = get_metadata()
upsert_method = create_upsert_method(meta)

# Get new df notifications from URL
df_actual_covid19 = loading_data.loading_covid_json()

#recomend upsert method with sqlalchemy and postgresql
#https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.to_sql.html
#https://docs.sqlalchemy.org/en/20/dialects/postgresql.html#postgresql-insert-on-conflict
df_actual_covid19.to_sql(
  'covid_notifications',
  loading_data.get_engine(),
  schema='public',
  index=False,
  if_exists="append",
  chunksize=200, # Recommended to insert data in chunks
  method=upsert_method
)
print("New values upserted")

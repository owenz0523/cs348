# cs348

Make sure to download PostgreSQL locally, spin up a local DB cluster, and initialize the env variables first with a local PostgreSQL database. Also make sure psql is added to path so that you can start a terminal session anywhere (or you can just use the psql shell straight from your pc).

### Loading the (sample) dataset

1. Start a psql terminal session with:  
   `psql -U postgres -h localhost -p 5432 -d postgres`

2. Enter your local password that you set up earlier when prompted  
3. Initialize the tables with:  
   `\i queries/init/reset.sql`

4. Open a new terminal session in the `/cs348` folder (where `poetry.lock` is located)

5. (This may take 10-15 seconds) Load the data with:  
   `poetry run python data/load.py`

# cs348

Make sure to download PostgreSQL locally, spin up a local DB cluster, and initialize the env variables first with a local PostgreSQL database. Also make sure psql is added to path so that you can start a terminal session anywhere (or you can just use the psql shell straight from your pc).

### Environment variables setup

Create a `.env` file in the root of the project directory with the following content:
```env
DB_NAME=nba_stats
DB_USER=postgres
DB_PASSWORD=your_postgres_password_here
DB_HOST=localhost
DB_PORT=5432
```

### Loading the (sample) dataset

1. Start a psql terminal session from the `cs348` directory with:  
   `psql -U postgres -h localhost -p 5432 -d postgres`

2. Enter your local password that you set up earlier when prompted  
3. (Re)Initialize the tables with:  
   `\i queries/init/reset.sql`

4. Open a new terminal session and `cd` to the `/cs348/data` folder

5. Install the dependencies with:  
   `poetry install`

6. (This may take 10-15 seconds) Load the data with:  
   `poetry run python load.py`

## Testing the (sample) dataset

1. Run the command `psql -d nba_stats -f queries/test-sample.sql > queries/test-sample.out`

### Running backend application

1. Open a new terminal session and `cd` to the `/cs348/backend` folder

2. Install the dependencies with:  
   `poetry install`

3. Run the application with:  
   `poetry run uvicorn main:app`

4. (For testing) You can send requests to the backend at `http://localhost:8000` using a tool like Postman or curl

### Running frontend application

1. cd `/cs348/frontend` folder

2. Install the dependencies with:  
   `npm install`

3. Run the application with:  
   `npm run dev`

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

1. Start a psql terminal session with:  
   `psql -U postgres -h localhost -p 5432 -d postgres`

2. Enter your local password that you set up earlier when prompted  
3. Initialize the tables with:  
   `\i queries/init/reset.sql`

4. Open a new terminal session in the `/cs348` folder (where `poetry.lock` is located)

5. (This may take 10-15 seconds) Load the data with:  
   `poetry run python data/load.py`

### Running backend application

1. Open a terminal session in the `/cs348` folder

2. Install the dependencies with:  
   `poetry install`

3. Run the application with:  
   `poetry run uvicorn backend.main:app`

4. You can send requests to the backend at `http://localhost:8000` using a tool like Postman or curl

### Running frontend application

1. cd `/cs348/frontend` folder

2. Install the dependencies with:  
   `npm install`

3. Run the application with:  
   `npm run dev`

# cs348

### Basic features
We have tic tac toe with teams as criteria on both rows and columns as the only game mode. Players must first enter an NBA player who has played for both the column and row teams, in order to play on that square. Players may request a hint by right clicking on the square, and four players will be displayed as hints, of which only one has played for both teams, and one or more others may have played for one of the teams. Once the game is complete, a query panel will appear on the left, allowing users to search for all players who have played for two selected teams. Users can also view the history of previous tic-tac-toe matches on the left hand side of the app.

### Environment variables setup

Create a `.env` file in the root of the project directory with the following content:
```env
DB_NAME=nba_stats
DB_USER=postgres
DB_PASSWORD=your_postgres_password_here
DB_HOST=localhost
DB_PORT=5432
```

### Setup

Make sure to download PostgreSQL locally, spin up a local DB cluster, and initialize the env variables first with a local PostgreSQL database. Also make sure psql is added to path so that you can start a terminal session anywhere (or you can just use the psql shell straight from your pc). Also make sure to have Poetry and Node installed and add them to your PATH. After loading the dataset, follow the steps to run the backend and frontend applications. The app should then be accessible at `http://localhost:5173`.

### Loading the dataset

1. Start a psql terminal session from the `cs348` directory with:  
   `psql -U postgres -h localhost -p 5432 -d postgres`

2. Enter your local password that you set up earlier when prompted  
3. (Re)Initialize the tables with:  
   `\i queries/init/reset.sql`

4. Open a new terminal session and `cd` to the `/cs348/data` folder

5. Install the dependencies with:  
   `poetry install`

6. (This may take ~3-4 minutes) Load the data with:  
   `poetry run python load.py`

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

### Testing the (sample) dataset

1. Run the command `psql -d nba_stats -f queries/tests/test-sample.sql > queries/tests/test-sample.out`

### Testing the (production) dataset

1. Run the command `psql -d nba_stats -f queries/tests/test-production.sql > queries/tests/test-production.out`

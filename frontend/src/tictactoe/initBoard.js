const teams = [
    "ATL", "BOS", "BRK", "CHI", "CHO", "CLE", "DAL", "DEN",
    "DET", "GSW", "HOU", "IND", "LAC", "LAL", "MEM", "MIA",
    "MIL", "MIN", "NOP", "NYK", "OKC", "ORL", "PHI", "PHO",
    "POR", "SAC", "SAS", "TOR", "UTA", "WAS"
];
let available = [...teams];

const getRandomTeam = () => {
    const index = Math.floor(Math.random() * available.length);
    const team = available[index];
    available.splice(index, 1);
    return team;
};

const generateStats = () => {
    // 1. Played for team and averaged the most PPG on their team
    // 2. Played for team and recorded the most total steals+blocks on their team 
    // 3. Played for team and has the highest free throw percentage on their team
}

const initBoard = () => {
    const size = 4;
    const board = Array.from({ length: size }, (_, row) =>
        Array.from({ length: size }, (_, col) => {
            if (row === 0 && col === 0) return "";
            if (row === 0) return `${getRandomTeam()}`;
            if (col === 0) return `${getRandomTeam()}`;
            return null;
        })
    );
    return board;
};

export default initBoard;

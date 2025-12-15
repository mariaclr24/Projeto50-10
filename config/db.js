require('dotenv').config(); // Carrega as variáveis do ficheiro .env
const mysql = require('mysql2');

// Cria um "pool" de conexões (é mais eficiente que criar uma conexão nova a cada pedido)
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Transforma em promessas para podermos usar async/await (código mais limpo)
const db = pool.promise();

console.log("Configuração da Base de Dados carregada.");

module.exports = db;
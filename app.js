const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config(); // Lê o .env

const app = express();

// --- Middlewares (Funções que correm antes das rotas) ---
app.use(cors()); // Permite que o frontend fale com o backend
app.use(bodyParser.json()); // Permite ler dados JSON enviados pelo frontend
app.use(express.static('public')); // Diz que a pasta 'public' tem o site (HTML/CSS)

// --- NOVO: Teste de Conexão ao arrancar ---
// Isto faz uma pergunta simples à base de dados ("Estás aí?")
db.execute('SELECT 1')
    .then(() => {
        console.log('✅ SUCESSO: Ligação à Base de Dados estabelecida!');
    })
    .catch((erro) => {
        console.error('❌ ERRO: Não foi possível ligar à Base de Dados.');
        console.error(erro); // Mostra o erro detalhado
    });

// --- Teste Simples ---
// Isto serve apenas para veres se o servidor responde, antes de criarmos rotas complexas
app.get('/teste', (req, res) => {
    res.send('O servidor está a funcionar!');
});

// --- Arrancar o Servidor ---
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`---------------------------------------`);
    console.log(`Servidor a correr na porta ${PORT}`);
    console.log(`Acede a: http://localhost:${PORT}`);
    console.log(`---------------------------------------`);
});
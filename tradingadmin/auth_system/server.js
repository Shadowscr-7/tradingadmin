//=============================================================================
// SERVIDOR DE AUTORIZACIÓN PARA CLOSECUSTOM BOT
// Node.js + Express + SQLite + Telegram notifications
//=============================================================================

const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const TelegramBot = require('node-telegram-bot-api');

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración
const TELEGRAM_BOT_TOKEN = '8478877011:AAHfZWqq8NZaqCtE1pQlN3eGKuMcU9Q42Es'; // Token de @BotFather
const TELEGRAM_CHAT_ID = '5467882117'; // Tu chat ID de Telegram
const ADMIN_PASSWORD = '49618553Bmb328873!'; // Password para proteger acciones de admin

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Inicializar Telegram Bot (opcional)
let telegramBot = null;
if (TELEGRAM_BOT_TOKEN && TELEGRAM_BOT_TOKEN !== 'TU_TELEGRAM_BOT_TOKEN') {
    try {
        telegramBot = new TelegramBot(TELEGRAM_BOT_TOKEN);
        console.log('✅ Telegram Bot inicializado');
    } catch (error) {
        console.log('⚠️ Error inicializando Telegram Bot:', error.message);
    }
}

// Inicializar base de datos SQLite
const db = new sqlite3.Database('./bot_auth.db', (err) => {
    if (err) {
        console.error('❌ Error conectando a la base de datos:', err.message);
    } else {
        console.log('✅ Conectado a la base de datos SQLite');
        initializeDatabase();
    }
});

// Crear tablas si no existen
function initializeDatabase() {
    db.run(`
        CREATE TABLE IF NOT EXISTS user_requests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hwid TEXT UNIQUE NOT NULL,
            userName TEXT NOT NULL,
            computerName TEXT NOT NULL,
            windowsUser TEXT,
            botName TEXT NOT NULL,
            botVersion TEXT NOT NULL,
            requestDate DATETIME DEFAULT CURRENT_TIMESTAMP,
            status TEXT DEFAULT 'pending',
            approvedDate DATETIME,
            ipAddress TEXT,
            lastSeen DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `, (err) => {
        if (err) {
            console.error('❌ Error creando tabla:', err.message);
        } else {
            console.log('✅ Tabla user_requests lista');
        }
    });
    
    // Tabla para logs de acceso
    db.run(`
        CREATE TABLE IF NOT EXISTS access_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hwid TEXT NOT NULL,
            accessDate DATETIME DEFAULT CURRENT_TIMESTAMP,
            success BOOLEAN NOT NULL,
            ipAddress TEXT
        )
    `);
}

//=============================================================================
// RUTAS API PARA EL BOT (C#)
//=============================================================================

// 1. Registrar nueva solicitud de autorización
app.post('/api/register-request', async (req, res) => {
    try {
        const { hwid, userName, computerName, windowsUser, botName, botVersion } = req.body;
        const clientIP = req.ip || req.connection.remoteAddress;
        
        console.log(`📝 Nueva solicitud: ${userName} (${computerName}) - HWID: ${hwid}`);
        
        // Verificar si ya existe
        db.get(
            'SELECT * FROM user_requests WHERE hwid = ?',
            [hwid],
            (err, row) => {
                if (err) {
                    console.error('❌ Error consultando DB:', err.message);
                    return res.status(500).json({ error: 'Error de base de datos' });
                }
                
                if (row) {
                    // Actualizar última vista
                    db.run(
                        'UPDATE user_requests SET lastSeen = CURRENT_TIMESTAMP WHERE hwid = ?',
                        [hwid]
                    );
                    return res.json({ 
                        success: true, 
                        message: 'Solicitud ya registrada',
                        status: row.status 
                    });
                }
                
                // Insertar nueva solicitud
                db.run(
                    `INSERT INTO user_requests 
                     (hwid, userName, computerName, windowsUser, botName, botVersion, ipAddress) 
                     VALUES (?, ?, ?, ?, ?, ?, ?)`,
                    [hwid, userName, computerName, windowsUser, botName, botVersion, clientIP],
                    function(err) {
                        if (err) {
                            console.error('❌ Error insertando:', err.message);
                            return res.status(500).json({ error: 'Error guardando solicitud' });
                        }
                        
                        console.log(`✅ Solicitud registrada con ID: ${this.lastID}`);
                        
                        // Enviar notificación por Telegram
                        sendTelegramNotification({
                            userName,
                            computerName,
                            hwid: hwid.substring(0, 8) + '...',
                            botName,
                            botVersion
                        });
                        
                        res.json({ 
                            success: true, 
                            message: 'Solicitud enviada correctamente',
                            requestId: this.lastID
                        });
                    }
                );
            }
        );
        
    } catch (error) {
        console.error('❌ Error procesando solicitud:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// 2. Verificar autorización (llamado por el bot)
app.post('/api/check-authorization', (req, res) => {
    try {
        const { hwid } = req.body;
        const clientIP = req.ip || req.connection.remoteAddress;
        
        db.get(
            'SELECT * FROM user_requests WHERE hwid = ? AND status = "approved"',
            [hwid],
            (err, row) => {
                const authorized = !err && row !== undefined;
                
                // Registrar intento de acceso
                db.run(
                    'INSERT INTO access_logs (hwid, success, ipAddress) VALUES (?, ?, ?)',
                    [hwid, authorized, clientIP]
                );
                
                if (authorized) {
                    // Actualizar última vista
                    db.run(
                        'UPDATE user_requests SET lastSeen = CURRENT_TIMESTAMP WHERE hwid = ?',
                        [hwid]
                    );
                }
                
                res.json({ 
                    authorized,
                    message: authorized ? 'Usuario autorizado' : 'Usuario no autorizado'
                });
            }
        );
        
    } catch (error) {
        console.error('❌ Error verificando autorización:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

//=============================================================================
// RUTAS API PARA EL PANEL ADMIN
//=============================================================================

// 3. Obtener todas las solicitudes (para panel admin)
app.get('/api/get-requests', (req, res) => {
    try {
        // Obtener estadísticas
        db.all(`
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
                SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected
            FROM user_requests
        `, (err, stats) => {
            if (err) {
                return res.status(500).json({ error: 'Error obteniendo estadísticas' });
            }
            
            // Obtener solicitudes
            db.all(
                'SELECT * FROM user_requests ORDER BY requestDate DESC LIMIT 50',
                (err, rows) => {
                    if (err) {
                        return res.status(500).json({ error: 'Error obteniendo solicitudes' });
                    }
                    
                    res.json({
                        success: true,
                        total: stats[0]?.total || 0,
                        pending: stats[0]?.pending || 0,
                        approved: stats[0]?.approved || 0,
                        rejected: stats[0]?.rejected || 0,
                        requests: rows || []
                    });
                }
            );
        });
        
    } catch (error) {
        console.error('❌ Error obteniendo solicitudes:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// 4. Aprobar usuario
app.post('/api/approve-user', (req, res) => {
    try {
        const { hwid, adminPassword } = req.body;
        
        // Verificar password admin
        if (adminPassword !== ADMIN_PASSWORD) {
            return res.status(401).json({ error: 'Password admin incorrecto' });
        }
        
        db.run(
            'UPDATE user_requests SET status = "approved", approvedDate = CURRENT_TIMESTAMP WHERE hwid = ?',
            [hwid],
            function(err) {
                if (err) {
                    console.error('❌ Error aprobando usuario:', err.message);
                    return res.status(500).json({ error: 'Error aprobando usuario' });
                }
                
                if (this.changes === 0) {
                    return res.status(404).json({ error: 'Usuario no encontrado' });
                }
                
                console.log(`✅ Usuario aprobado: ${hwid}`);
                
                // Obtener info del usuario para notificación
                db.get('SELECT * FROM user_requests WHERE hwid = ?', [hwid], (err, row) => {
                    if (row) {
                        sendTelegramNotification({
                            userName: row.userName,
                            computerName: row.computerName,
                            hwid: hwid.substring(0, 8) + '...',
                            action: 'APROBADO'
                        });
                    }
                });
                
                res.json({ 
                    success: true, 
                    message: 'Usuario aprobado correctamente' 
                });
            }
        );
        
    } catch (error) {
        console.error('❌ Error aprobando usuario:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// 5. Rechazar usuario
app.post('/api/reject-user', (req, res) => {
    try {
        const { hwid } = req.body;
        
        db.run(
            'UPDATE user_requests SET status = "rejected" WHERE hwid = ?',
            [hwid],
            function(err) {
                if (err) {
                    console.error('❌ Error rechazando usuario:', err.message);
                    return res.status(500).json({ error: 'Error rechazando usuario' });
                }
                
                if (this.changes === 0) {
                    return res.status(404).json({ error: 'Usuario no encontrado' });
                }
                
                console.log(`❌ Usuario rechazado: ${hwid}`);
                res.json({ 
                    success: true, 
                    message: 'Usuario rechazado' 
                });
            }
        );
        
    } catch (error) {
        console.error('❌ Error rechazando usuario:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

//=============================================================================
// FUNCIONES AUXILIARES
//=============================================================================

async function sendTelegramNotification(data) {
    if (!telegramBot || !TELEGRAM_CHAT_ID || TELEGRAM_CHAT_ID === 'TU_CHAT_ID') {
        console.log('📱 Notificación (Telegram no configurado):', data);
        return;
    }
    
    try {
        let message;
        
        if (data.action === 'APROBADO') {
            message = `✅ *USUARIO APROBADO*\n\n` +
                     `👤 Usuario: ${data.userName}\n` +
                     `💻 PC: ${data.computerName}\n` +
                     `🔐 HWID: \`${data.hwid}\`\n\n` +
                     `El usuario ya puede usar el bot.`;
        } else {
            message = `🔔 *NUEVA SOLICITUD DE ACCESO*\n\n` +
                     `👤 Usuario: ${data.userName}\n` +
                     `💻 PC: ${data.computerName}\n` +
                     `🤖 Bot: ${data.botName} v${data.botVersion}\n` +
                     `🔐 HWID: \`${data.hwid}\`\n\n` +
                     `Revisa el panel de administración para autorizar.`;
        }
        
        await telegramBot.sendMessage(TELEGRAM_CHAT_ID, message, { 
            parse_mode: 'Markdown' 
        });
        
        console.log('📱 Notificación Telegram enviada');
        
    } catch (error) {
        console.error('❌ Error enviando notificación Telegram:', error.message);
    }
}

// Servir panel de administración
app.get('/admin', (req, res) => {
    res.sendFile(path.join(__dirname, 'admin_panel.html'));
});

// Ruta raíz
app.get('/', (req, res) => {
    res.json({
        service: 'CloseCustom Bot - Authorization Server',
        version: '1.0',
        status: 'running',
        endpoints: {
            'POST /api/register-request': 'Registrar solicitud de bot',
            'POST /api/check-authorization': 'Verificar autorización',
            'GET /api/get-requests': 'Obtener solicitudes (admin)',
            'POST /api/approve-user': 'Aprobar usuario (admin)',
            'POST /api/reject-user': 'Rechazar usuario (admin)',
            'GET /admin': 'Panel de administración'
        }
    });
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log('\n🚀 =====================================');
    console.log(`   SERVIDOR DE AUTORIZACIÓN INICIADO`);
    console.log('=====================================');
    console.log(`🌐 Servidor: http://localhost:${PORT}`);
    console.log(`👨‍💼 Panel Admin: http://localhost:${PORT}/admin`);
    console.log(`📊 API Status: http://localhost:${PORT}/`);
    console.log('=====================================\n');
});

// Cerrar DB al terminar proceso
process.on('SIGINT', () => {
    console.log('\n🛑 Cerrando servidor...');
    db.close((err) => {
        if (err) {
            console.error('❌ Error cerrando DB:', err.message);
        } else {
            console.log('✅ Base de datos cerrada');
        }
        process.exit(0);
    });
});

module.exports = app;
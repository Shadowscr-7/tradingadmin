//=============================================================================
// SERVIDOR DE AUTORIZACIÓN PARA CLOSECUSTOM BOT - VERCEL + SUPABASE
// Node.js + Express + Supabase (PostgreSQL) + Telegram notifications
//=============================================================================

const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración - Variables de entorno para Vercel
const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN || '8478877011:AAHfZWqq8NZaqCtE1pQlN3eGKuMcU9Q42Es';
const TELEGRAM_CHAT_ID = process.env.TELEGRAM_CHAT_ID || '5467882117';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || '49618553Bmb328873!';

// Configuración Supabase
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://vxcwezxgtmnpbicgphet.supabase.co';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4Y3dlenhndG1ucGJpY2dwaGV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5NTg4NjcsImV4cCI6MjA2MDUzNDg2N30.b1Xg-nWbBqM_B1J6bKm1g1S3-VLhHgqsVNNPD-1Aq0A';

// Inicializar Supabase
let supabase = null;
if (SUPABASE_URL !== 'https://tu-proyecto.supabase.co') {
    supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    console.log('✅ Supabase conectado');
} else {
    console.log('⚠️ Supabase no configurado - usando modo desarrollo');
}

// Middleware
app.use(cors({
    origin: ['https://tradingadmin-q36j.vercel.app', 'http://localhost:3000'],
    credentials: true
}));
app.use(express.json());
app.use(express.static('public'));

// Inicializar Telegram Bot (opcional)
let telegramBot = null;
if (TELEGRAM_BOT_TOKEN && TELEGRAM_BOT_TOKEN !== 'TU_TELEGRAM_BOT_TOKEN') {
    try {
        // En Vercel, importamos dinámicamente para evitar errores
        const TelegramBot = require('node-telegram-bot-api');
        telegramBot = new TelegramBot(TELEGRAM_BOT_TOKEN);
        console.log('✅ Telegram Bot inicializado');
    } catch (error) {
        console.log('⚠️ Error inicializando Telegram Bot:', error.message);
    }
}

//=============================================================================
// FUNCIONES DE BASE DE DATOS (SUPABASE)
//=============================================================================

async function initializeDatabase() {
    if (!supabase) {
        console.log('⚠️ Base de datos no configurada');
        return;
    }

    try {
        // Verificar si las tablas existen consultando una
        const { data, error } = await supabase
            .from('trading_user_requests')
            .select('count')
            .limit(1);

        if (error && error.code === '42P01') {
            console.log('📋 Creando tablas en Supabase...');
            console.log('💡 Ejecuta este SQL en tu dashboard de Supabase:');
            console.log(`
-- Tabla para solicitudes de usuarios del trading bot
CREATE TABLE IF NOT EXISTS trading_user_requests (
    id SERIAL PRIMARY KEY,
    hwid TEXT UNIQUE NOT NULL,
    user_name TEXT NOT NULL,
    computer_name TEXT NOT NULL,
    windows_user TEXT,
    bot_name TEXT NOT NULL,
    bot_version TEXT NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'pending',
    approved_date TIMESTAMP,
    ip_address TEXT,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para logs de acceso del trading bot
CREATE TABLE IF NOT EXISTS trading_access_logs (
    id SERIAL PRIMARY KEY,
    hwid TEXT NOT NULL,
    access_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN NOT NULL,
    ip_address TEXT
);

-- Índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_trading_user_requests_hwid ON trading_user_requests(hwid);
CREATE INDEX IF NOT EXISTS idx_trading_user_requests_status ON trading_user_requests(status);
CREATE INDEX IF NOT EXISTS idx_trading_access_logs_hwid ON trading_access_logs(hwid);
            `);
        } else {
            console.log('✅ Tablas de Supabase verificadas');
        }
    } catch (error) {
        console.error('❌ Error verificando base de datos:', error.message);
    }
}

//=============================================================================
// RUTAS API PARA EL BOT (C#)
//=============================================================================

// 1. Registrar nueva solicitud de autorización
app.post('/api/register-request', async (req, res) => {
    if (!supabase) {
        return res.status(503).json({ error: 'Base de datos no configurada' });
    }

    try {
        const { hwid, userName, computerName, windowsUser, botName, botVersion } = req.body;
        const clientIP = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
        
        console.log(`📝 Nueva solicitud: ${userName} (${computerName}) - HWID: ${hwid}`);
        
        // Verificar si ya existe
        const { data: existingUser, error: selectError } = await supabase
            .from('trading_user_requests')
            .select('*')
            .eq('hwid', hwid)
            .single();

        if (selectError && selectError.code !== 'PGRST116') {
            console.error('❌ Error consultando usuario:', selectError.message);
            return res.status(500).json({ error: 'Error de base de datos' });
        }

        if (existingUser) {
            // Actualizar última vista
            await supabase
                .from('user_requests')
                .update({ last_seen: new Date().toISOString() })
                .eq('hwid', hwid);

            return res.json({ 
                success: true, 
                message: 'Solicitud ya registrada',
                status: existingUser.status 
            });
        }

        // Insertar nueva solicitud
        const { data: newUser, error: insertError } = await supabase
            .from('trading_user_requests')
            .insert([
                {
                    hwid,
                    user_name: userName,
                    computer_name: computerName,
                    windows_user: windowsUser,
                    bot_name: botName,
                    bot_version: botVersion,
                    ip_address: clientIP
                }
            ])
            .select()
            .single();

        if (insertError) {
            console.error('❌ Error insertando usuario:', insertError.message);
            return res.status(500).json({ error: 'Error guardando solicitud' });
        }

        console.log(`✅ Solicitud registrada con ID: ${newUser.id}`);
        
        // Enviar notificación por Telegram
        await sendTelegramNotification({
            userName,
            computerName,
            hwid: hwid.substring(0, 8) + '...',
            botName,
            botVersion
        });
        
        res.json({ 
            success: true, 
            message: 'Solicitud enviada correctamente',
            requestId: newUser.id
        });

    } catch (error) {
        console.error('❌ Error procesando solicitud:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// 2. Verificar autorización (llamado por el bot)
app.post('/api/check-authorization', async (req, res) => {
    if (!supabase) {
        return res.status(503).json({ error: 'Base de datos no configurada' });
    }

    try {
        const { hwid } = req.body;
        const clientIP = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
        
        // Buscar usuario autorizado
        const { data: user, error } = await supabase
            .from('trading_user_requests')
            .select('*')
            .eq('hwid', hwid)
            .eq('status', 'approved')
            .single();

        const authorized = !error && user !== null;
        
        // Registrar intento de acceso
        await supabase
            .from('trading_access_logs')
            .insert([
                {
                    hwid,
                    success: authorized,
                    ip_address: clientIP
                }
            ]);

        if (authorized) {
            // Actualizar última vista
            await supabase
                .from('trading_user_requests')
                .update({ last_seen: new Date().toISOString() })
                .eq('hwid', hwid);
        }
        
        res.json({ 
            authorized,
            message: authorized ? 'Usuario autorizado' : 'Usuario no autorizado'
        });

    } catch (error) {
        console.error('❌ Error verificando autorización:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

//=============================================================================
// RUTAS API PARA EL PANEL ADMIN
//=============================================================================

// 3. Obtener todas las solicitudes (para panel admin)
app.get('/api/get-requests', async (req, res) => {
    if (!supabase) {
        return res.status(503).json({ error: 'Base de datos no configurada' });
    }

    try {
        // Obtener estadísticas
        const { data: allRequests, error: statsError } = await supabase
            .from('trading_user_requests')
            .select('status');

        if (statsError) {
            return res.status(500).json({ error: 'Error obteniendo estadísticas' });
        }

        const stats = {
            total: allRequests.length,
            pending: allRequests.filter(r => r.status === 'pending').length,
            approved: allRequests.filter(r => r.status === 'approved').length,
            rejected: allRequests.filter(r => r.status === 'rejected').length
        };
        
        // Obtener solicitudes recientes
        const { data: requests, error: requestsError } = await supabase
            .from('trading_user_requests')
            .select('*')
            .order('request_date', { ascending: false })
            .limit(50);

        if (requestsError) {
            return res.status(500).json({ error: 'Error obteniendo solicitudes' });
        }

        res.json({
            success: true,
            ...stats,
            requests: requests || []
        });

    } catch (error) {
        console.error('❌ Error obteniendo solicitudes:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// 4. Aprobar usuario
app.post('/api/approve-user', async (req, res) => {
    if (!supabase) {
        return res.status(503).json({ error: 'Base de datos no configurada' });
    }

    try {
        const { hwid, adminPassword } = req.body;
        
        // Verificar password admin
        if (!adminPassword || adminPassword !== ADMIN_PASSWORD) {
            console.log(`❌ Password incorrecto. Recibido: '${adminPassword}', Esperado: '${ADMIN_PASSWORD}'`);
            return res.status(401).json({ error: 'Password admin incorrecto' });
        }
        
        console.log(`✅ Password correcto para aprobar HWID: ${hwid}`);
        
        const { data: updatedUser, error } = await supabase
            .from('trading_user_requests')
            .update({ 
                status: 'approved', 
                approved_date: new Date().toISOString() 
            })
            .eq('hwid', hwid)
            .select()
            .single();

        if (error) {
            console.error('❌ Error aprobando usuario:', error.message);
            return res.status(500).json({ error: 'Error aprobando usuario' });
        }

        if (!updatedUser) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        console.log(`✅ Usuario aprobado: ${hwid}`);
        
        // Enviar notificación por Telegram
        await sendTelegramNotification({
            userName: updatedUser.user_name,
            computerName: updatedUser.computer_name,
            hwid: hwid.substring(0, 8) + '...',
            action: 'APROBADO'
        });
        
        res.json({ 
            success: true, 
            message: 'Usuario aprobado correctamente' 
        });

    } catch (error) {
        console.error('❌ Error aprobando usuario:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// 5. Rechazar usuario
app.post('/api/reject-user', async (req, res) => {
    if (!supabase) {
        return res.status(503).json({ error: 'Base de datos no configurada' });
    }

    try {
        const { hwid } = req.body;
        
        const { data: updatedUser, error } = await supabase
            .from('trading_user_requests')
            .update({ status: 'rejected' })
            .eq('hwid', hwid)
            .select()
            .single();

        if (error) {
            console.error('❌ Error rechazando usuario:', error.message);
            return res.status(500).json({ error: 'Error rechazando usuario' });
        }

        if (!updatedUser) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        console.log(`❌ Usuario rechazado: ${hwid}`);
        res.json({ 
            success: true, 
            message: 'Usuario rechazado' 
        });

    } catch (error) {
        console.error('❌ Error rechazando usuario:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// 6. Eliminar autorización (nuevo)
app.post('/api/delete-user', async (req, res) => {
    if (!supabase) {
        return res.status(503).json({ error: 'Base de datos no configurada' });
    }

    try {
        const { hwid, adminPassword } = req.body;
        
        // Verificar password admin
        if (!adminPassword || adminPassword !== ADMIN_PASSWORD) {
            return res.status(401).json({ error: 'Password admin incorrecto' });
        }
        
        // Obtener datos del usuario antes de eliminarlo
        const { data: user, error: selectError } = await supabase
            .from('trading_user_requests')
            .select('*')
            .eq('hwid', hwid)
            .single();
            
        if (selectError || !user) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        
        // Eliminar el usuario completamente
        const { error: deleteError } = await supabase
            .from('trading_user_requests')
            .delete()
            .eq('hwid', hwid);

        if (deleteError) {
            console.error('❌ Error eliminando usuario:', deleteError.message);
            return res.status(500).json({ error: 'Error eliminando usuario' });
        }

        console.log(`🗑️ Usuario eliminado: ${hwid} (${user.user_name})`);
        
        // Enviar notificación por Telegram
        await sendTelegramNotification({
            userName: user.user_name,
            computerName: user.computer_name,
            hwid: hwid.substring(0, 8) + '...',
            action: 'ELIMINADO'
        });
        
        res.json({ 
            success: true, 
            message: 'Autorización eliminada correctamente' 
        });

    } catch (error) {
        console.error('❌ Error eliminando usuario:', error);
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
        } else if (data.action === 'ELIMINADO') {
            message = `🗑️ *AUTORIZACIÓN ELIMINADA*\n\n` +
                     `👤 Usuario: ${data.userName}\n` +
                     `💻 PC: ${data.computerName}\n` +
                     `🔐 HWID: \`${data.hwid}\`\n\n` +
                     `El usuario deberá solicitar autorización nuevamente.`;
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
    const fs = require('fs');
    const adminPath = path.join(__dirname, 'admin_panel.html');
    
    try {
        const html = fs.readFileSync(adminPath, 'utf8');
        res.setHeader('Content-Type', 'text/html');
        res.send(html);
    } catch (error) {
        console.error('Error serving admin panel:', error);
        res.status(404).send('Admin panel not found');
    }
});

// Ruta raíz
app.get('/', (req, res) => {
    res.json({
        service: 'CloseCustom Bot - Authorization Server (Vercel + Supabase)',
        version: '1.0',
        status: 'running',
        database: supabase ? 'Supabase Connected' : 'No Database',
        endpoints: {
            'POST /api/register-request': 'Registrar solicitud de bot',
            'POST /api/check-authorization': 'Verificar autorización',
            'GET /api/get-requests': 'Obtener solicitudes (admin)',
            'POST /api/approve-user': 'Aprobar usuario (admin)',
            'POST /api/reject-user': 'Rechazar usuario (admin)',
            'POST /api/delete-user': 'Eliminar autorización (admin)',
            'GET /admin': 'Panel de administración'
        }
    });
});

// Inicializar base de datos al arrancar
initializeDatabase();

// Para Vercel, exportar la app
module.exports = app;

// Para desarrollo local
if (require.main === module) {
    app.listen(PORT, () => {
        console.log('\n🚀 =====================================');
        console.log(`   SERVIDOR DE AUTORIZACIÓN INICIADO`);
        console.log('=====================================');
        console.log(`🌐 Servidor: http://localhost:${PORT}`);
        console.log(`👨‍💼 Panel Admin: http://localhost:${PORT}/admin`);
        console.log(`📊 API Status: http://localhost:${PORT}/`);
        console.log(`🗄️ Base de datos: ${supabase ? 'Supabase' : 'No configurada'}`);
        console.log('=====================================\n');
    });
}
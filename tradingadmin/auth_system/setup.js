const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

console.log('\n🤖 =====================================');
console.log('   CONFIGURACIÓN DEL SISTEMA DE AUTH');
console.log('=====================================\n');

console.log('Este script te ayudará a configurar el sistema de autorización.');
console.log('Puedes presionar ENTER para usar los valores por defecto.\n');

const questions = [
    {
        key: 'TELEGRAM_BOT_TOKEN',
        question: '📱 Token del Bot de Telegram (opcional): ',
        default: 'TU_TELEGRAM_BOT_TOKEN',
        description: 'Obtén tu token de @BotFather en Telegram'
    },
    {
        key: 'TELEGRAM_CHAT_ID',
        question: '💬 Tu Chat ID de Telegram (opcional): ',
        default: 'TU_CHAT_ID',
        description: 'Envía /start a @userinfobot para obtener tu chat ID'
    },
    {
        key: 'ADMIN_PASSWORD',
        question: '🔐 Password de administrador (opcional): ',
        default: 'admin123',
        description: 'Password para proteger las acciones de admin'
    },
    {
        key: 'SERVER_URL',
        question: '🌐 URL del servidor (ej: https://tu-dominio.com): ',
        default: 'https://tu-servidor-auth.com',
        description: 'URL donde estará alojado el servidor'
    }
];

let config = {};
let questionIndex = 0;

function askQuestion() {
    if (questionIndex >= questions.length) {
        generateConfig();
        return;
    }
    
    const q = questions[questionIndex];
    console.log(`\n💡 ${q.description}`);
    
    rl.question(`${q.question}[${q.default}] `, (answer) => {
        config[q.key] = answer.trim() || q.default;
        questionIndex++;
        askQuestion();
    });
}

function generateConfig() {
    console.log('\n🔧 Generando archivos de configuración...\n');
    
    // 1. Actualizar server.js con la configuración
    updateServerConfig();
    
    // 2. Actualizar el archivo C# con la URL del servidor
    updateCSharpConfig();
    
    // 3. Crear archivo de configuración
    createConfigFile();
    
    // 4. Crear scripts de deployment
    createDeploymentScripts();
    
    console.log('✅ Configuración completada!\n');
    console.log('📋 PRÓXIMOS PASOS:');
    console.log('1. Ejecuta: npm install');
    console.log('2. Ejecuta: npm start');
    console.log('3. Ve a: http://localhost:3000/admin');
    console.log('4. Compila y distribuye el bot C# actualizado\n');
    
    if (config.TELEGRAM_BOT_TOKEN !== 'TU_TELEGRAM_BOT_TOKEN') {
        console.log('📱 Telegram configurado:');
        console.log(`   - Recibirás notificaciones en: ${config.TELEGRAM_CHAT_ID}`);
        console.log('   - Configura el webhook si usas un servidor público\n');
    }
    
    console.log('🚀 ¡Listo para autorizar usuarios!');
    rl.close();
}

function updateServerConfig() {
    const serverPath = path.join(__dirname, 'server.js');
    let serverContent = fs.readFileSync(serverPath, 'utf8');
    
    // Reemplazar tokens
    serverContent = serverContent.replace(
        "const TELEGRAM_BOT_TOKEN = 'TU_TELEGRAM_BOT_TOKEN';",
        `const TELEGRAM_BOT_TOKEN = '${config.TELEGRAM_BOT_TOKEN}';`
    );
    
    serverContent = serverContent.replace(
        "const TELEGRAM_CHAT_ID = 'TU_CHAT_ID';",
        `const TELEGRAM_CHAT_ID = '${config.TELEGRAM_CHAT_ID}';`
    );
    
    serverContent = serverContent.replace(
        "const ADMIN_PASSWORD = 'tu_password_admin';",
        `const ADMIN_PASSWORD = '${config.ADMIN_PASSWORD}';`
    );
    
    fs.writeFileSync(serverPath, serverContent);
    console.log('✅ server.js actualizado');
}

function updateCSharpConfig() {
    const csharpPath = path.join(__dirname, '..', 'trading_strategies', 'closecustom.cs');
    
    if (fs.existsSync(csharpPath)) {
        let csharpContent = fs.readFileSync(csharpPath, 'utf8');
        
        csharpContent = csharpContent.replace(
            'private readonly string authServerUrl = "https://tu-servidor-auth.com/api";',
            `private readonly string authServerUrl = "${config.SERVER_URL}/api";`
        );
        
        fs.writeFileSync(csharpPath, csharpContent);
        console.log('✅ closecustom.cs actualizado con URL del servidor');
    }
}

function createConfigFile() {
    const configContent = {
        server: {
            port: process.env.PORT || 3000,
            url: config.SERVER_URL
        },
        telegram: {
            botToken: config.TELEGRAM_BOT_TOKEN,
            chatId: config.TELEGRAM_CHAT_ID,
            enabled: config.TELEGRAM_BOT_TOKEN !== 'TU_TELEGRAM_BOT_TOKEN'
        },
        admin: {
            password: config.ADMIN_PASSWORD,
            passwordEnabled: config.ADMIN_PASSWORD !== 'admin123'
        },
        bot: {
            name: 'CloseCustom Bot',
            version: '1.0'
        },
        createdAt: new Date().toISOString()
    };
    
    fs.writeFileSync(
        path.join(__dirname, 'config.json'), 
        JSON.stringify(configContent, null, 2)
    );
    console.log('✅ config.json creado');
}

function createDeploymentScripts() {
    // Script para Windows
    const windowsScript = `@echo off
echo 🚀 Iniciando servidor de autorizacion...
echo.
if not exist node_modules (
    echo 📦 Instalando dependencias...
    npm install
    echo.
)
echo ✅ Iniciando servidor en http://localhost:3000
echo 👨‍💼 Panel admin: http://localhost:3000/admin
echo.
echo Presiona Ctrl+C para detener el servidor
echo.
npm start
pause`;

    fs.writeFileSync(path.join(__dirname, 'start.bat'), windowsScript);
    
    // Script para Linux/Mac
    const unixScript = `#!/bin/bash
echo "🚀 Iniciando servidor de autorización..."
echo ""
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
    echo ""
fi
echo "✅ Iniciando servidor en http://localhost:3000"
echo "👨‍💼 Panel admin: http://localhost:3000/admin"
echo ""
echo "Presiona Ctrl+C para detener el servidor"
echo ""
npm start`;

    fs.writeFileSync(path.join(__dirname, 'start.sh'), unixScript);
    fs.chmodSync(path.join(__dirname, 'start.sh'), 0o755);
    
    console.log('✅ Scripts de inicio creados (start.bat / start.sh)');
}

// Iniciar configuración
askQuestion();
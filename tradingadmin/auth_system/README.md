# 🤖 CloseCustom Bot - Sistema de Autorización

Sistema completo de autorización para el trading bot CloseCustom, con panel web de administración y notificaciones automáticas.

## 🎯 ¿Cómo Funciona?

### Para el Usuario Final (Sin conocimientos técnicos):

1. **Descarga e instala** el bot en NinjaTrader
2. **Agrega el bot** a un gráfico 
3. **Automáticamente se envía** una solicitud de autorización
4. **El bot muestra** un mensaje esperando autorización
5. **Una vez autorizado**, el bot funciona normalmente

### Para Ti (Desarrollador):

1. **Recibes notificación** automática (Telegram/Panel web)
2. **Revisas la solicitud** en el panel de administración
3. **Apruebes/Rechazas** con un click
4. **El usuario queda autorizado** inmediatamente

---

## 🚀 Instalación Rápida

### 1. Configurar el Servidor

```bash
# Navegar a la carpeta del sistema
cd auth_system

# Ejecutar configuración automática
node setup.js

# Instalar dependencias
npm install

# Iniciar servidor
npm start
```

### 2. Acceder al Panel de Administración

Abrir en el navegador: `http://localhost:3000/admin`

### 3. Distribuir el Bot

El archivo `closecustom.cs` ya está configurado automáticamente con el sistema de autorización.

---

## 📋 Configuración Detallada

### Telegram (Opcional pero Recomendado)

1. **Crear bot en Telegram:**
   - Envía `/newbot` a [@BotFather](https://t.me/botfather)
   - Copia el token del bot

2. **Obtener tu Chat ID:**
   - Envía `/start` a [@userinfobot](https://t.me/userinfobot)
   - Copia tu chat ID

3. **Configurar en el servidor:**
   - Ejecuta `node setup.js` y proporciona los datos

### Servidor en la Nube (Producción)

#### Opción 1: Heroku (Gratis/Fácil)
```bash
# 1. Instalar Heroku CLI
# 2. Crear app
heroku create tu-app-auth

# 3. Configurar variables
heroku config:set TELEGRAM_BOT_TOKEN=tu_token
heroku config:set TELEGRAM_CHAT_ID=tu_chat_id

# 4. Deploy
git add .
git commit -m "Deploy auth system"
git push heroku main
```

#### Opción 2: Railway (Recomendado)
1. Conectar repo GitHub a [Railway](https://railway.app)
2. Configurar variables de entorno
3. Deploy automático

#### Opción 3: VPS Propio
```bash
# En tu servidor
git clone tu-repo
cd auth_system
npm install
npm start

# Usar PM2 para mantener activo
npm install -g pm2
pm2 start server.js --name "auth-server"
pm2 startup
pm2 save
```

---

## 🛡️ Características de Seguridad

### Protección Hardware-Based
- **Hardware ID único** por PC (CPU + Motherboard + Usuario)
- **Hash SHA256** para proteger la identidad del hardware
- **Imposible de falsificar** sin acceso físico al hardware

### Protección Temporal
- **Fecha de expiración** configurable
- **Control de versiones** del bot
- **Blacklist automática** si es necesario

### Protección de Red
- **Servidor centralizado** de autorización
- **Logs de acceso** completos
- **Detección de uso múltiple** (mismo HWID desde múltiples IPs)

---

## 💼 Panel de Administración

### Dashboard Principal
- 📊 **Estadísticas en tiempo real**
- 📋 **Lista de solicitudes pendientes**
- ✅ **Usuarios autorizados activos**
- 📱 **Notificaciones push**

### Acciones Disponibles
- ✅ **Aprobar usuario** (1 click)
- ❌ **Rechazar solicitud** (1 click)
- 👁️ **Ver detalles** del hardware
- 🚫 **Revocar acceso** (si es necesario)
- 📊 **Ver logs de actividad**

### Información por Usuario
- 👤 **Nombre de usuario Windows**
- 💻 **Nombre del equipo**
- 🔐 **Hardware ID hasheado**
- 📅 **Fecha de solicitud**
- 📊 **Última actividad**
- 🌐 **Dirección IP**

---

## 📱 Notificaciones Automáticas

### Telegram (Configurado)
```
🔔 NUEVA SOLICITUD DE ACCESO

👤 Usuario: Juan Pérez
💻 PC: DESKTOP-ABC123
🤖 Bot: CloseCustom v1.0
🔐 HWID: AB12CD34...

Revisa el panel para autorizar.
```

### Email (Opcional)
Se puede agregar notificaciones por email configurando un servicio SMTP.

---

## 🔧 Personalización Avanzada

### Modificar Tiempo de Expiración
```csharp
// En closecustom.cs, línea ~12
private readonly DateTime expirationDate = new DateTime(2026, 12, 31);
```

### Cambiar URL del Servidor
```csharp
// En closecustom.cs, línea ~15
private readonly string authServerUrl = "https://tu-dominio.com/api";
```

### Agregar Validaciones Extras
Puedes agregar validaciones adicionales como:
- **Límite de instalaciones** por usuario
- **Geolocalización** por IP
- **Blacklist** de dominios/empresas
- **Validación de licencia** por tiempo

---

## 📊 Base de Datos

El sistema usa **SQLite** (archivo local) que incluye:

### Tabla: user_requests
- `hwid` - Hardware ID hasheado
- `userName` - Usuario de Windows  
- `computerName` - Nombre del PC
- `botName` - Nombre del bot
- `botVersion` - Versión del bot
- `status` - pending/approved/rejected
- `requestDate` - Fecha de solicitud
- `lastSeen` - Última actividad

### Tabla: access_logs
- `hwid` - Hardware ID
- `accessDate` - Fecha/hora de acceso
- `success` - Si fue autorizado
- `ipAddress` - IP del usuario

---

## 🐛 Troubleshooting

### El bot no se conecta al servidor
1. **Verificar URL** en el archivo C#
2. **Verificar firewall** del servidor
3. **Revisar logs** del servidor: `npm start`

### No llegan notificaciones de Telegram
1. **Verificar token** del bot
2. **Verificar chat ID** personal
3. **Iniciar conversación** con el bot primero

### El panel admin no carga
1. **Verificar puerto 3000** esté libre
2. **Abrir** `http://localhost:3000/admin`
3. **Revisar logs** de la consola del navegador

### Error de base de datos
1. **Verificar permisos** de escritura en la carpeta
2. **Eliminar** `bot_auth.db` y reiniciar
3. **Ejecutar** `npm start` de nuevo

---

## 📞 Soporte

### Logs del Sistema
```bash
# Ver logs en tiempo real
npm start

# Logs con más detalle  
DEBUG=* npm start
```

### Información de Debug
- El sistema muestra **todos los intentos** de autorización
- **Logs detallados** de cada solicitud
- **Errores específicos** para troubleshooting

### Contacto
Para soporte técnico o personalizaciones:
- **Panel de admin**: Información completa de cada usuario
- **Logs del servidor**: Detalles técnicos de errores
- **Base de datos**: Respaldo completo de usuarios

---

## 🎉 ¡Listo!

Con este sistema:
1. ✅ **Control total** sobre quién usa tu bot
2. 📱 **Notificaciones automáticas** de nuevos usuarios  
3. 🛡️ **Protección robusta** contra distribución no autorizada
4. 💼 **Panel profesional** de administración
5. 🚀 **Escalable** a miles de usuarios

**¡Tu bot está protegido y listo para distribuir con confianza!**
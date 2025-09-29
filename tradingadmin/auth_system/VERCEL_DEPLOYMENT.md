# 🚀 Guía de Deployment en Vercel + Supabase

Guía paso a paso para subir tu sistema de autorización a Vercel con base de datos Supabase (gratis).

## 📋 Prerequisitos

- Cuenta GitHub (ya tienes ✅)
- Cuenta Vercel (crear gratis)
- Cuenta Supabase (crear gratis)

## 🗄️ Paso 1: Configurar Supabase (Base de Datos)

### 1.1 Crear cuenta y proyecto
1. Ve a [supabase.com](https://supabase.com)
2. **Sign up** con GitHub
3. **New Project**
4. Elige nombre: `closecustom-auth`
5. **Create new project** (tarda ~2 minutos)

### 1.2 Crear las tablas
1. Ve a **SQL Editor** en el dashboard de Supabase
2. Copia el contenido de `create_tables.sql` O pega este código:

```sql
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
```

3. Click **RUN** ▶️

### 1.3 Obtener credenciales
1. Ve a **Settings** → **API**
2. Copia:
   - **Project URL**: `https://xxx.supabase.co`
   - **anon/public key**: `eyJhbGc...`

## 🌐 Paso 2: Configurar Vercel

### 2.1 Crear cuenta
1. Ve a [vercel.com](https://vercel.com)
2. **Sign up** con GitHub
3. Autorizar acceso a repositorios

### 2.2 Importar proyecto
1. **Import Git Repository**
2. Buscar: `Shadowscr-7/tradingadmin`
3. **Import**

### 2.3 Configurar variables de entorno
En Vercel, ve a **Settings** → **Environment Variables**:

```env
SUPABASE_URL=https://vxcwezxgtmnpbicgphet.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4Y3dlenhndG1ucGJpY2dwaGV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5NTg4NjcsImV4cCI6MjA2MDUzNDg2N30.b1Xg-nWbBqM_B1J6bKm1g1S3-VLhHgqsVNNPD-1Aq0A
TELEGRAM_BOT_TOKEN=8478877011:AAHfZWqq8NZaqCtE1pQlN3eGKuMcU9Q42Es
TELEGRAM_CHAT_ID=5467882117
ADMIN_PASSWORD=49618553Bmb328873!
NODE_ENV=production
```

### 2.4 Deploy
1. **Deploy** (tarda ~2 minutos)
2. Tu URL será: `https://tu-proyecto.vercel.app`

## ⚙️ Paso 3: Actualizar el Bot C#

Cambiar la URL en `closecustom.cs`:

```csharp
// Cambiar de:
private readonly string authServerUrl = "http://localhost:3000/api";

// A:
private readonly string authServerUrl = "https://tu-proyecto.vercel.app/api";
```

## ✅ Paso 4: Probar el Sistema

### 4.1 Verificar APIs
- **Status**: `https://tu-proyecto.vercel.app/`
- **Panel Admin**: `https://tu-proyecto.vercel.app/admin`

### 4.2 Probar con el bot
1. Compilar `closecustom.cs` con nueva URL
2. Agregar a gráfico NinjaTrader
3. Ver solicitud en Supabase dashboard
4. Aprobar desde panel web

## 🔧 Comandos Útiles

### Ver logs de Vercel:
```bash
# Instalar Vercel CLI
npm i -g vercel

# Ver logs en tiempo real
vercel logs tu-proyecto.vercel.app --follow
```

### Ver datos en Supabase:
1. Dashboard → **Table Editor**
2. Ver tablas `user_requests` y `access_logs`

## 🐛 Troubleshooting

### Error de conexión a Supabase:
- Verificar URL y API Key en variables de entorno
- Comprobar que las tablas existen

### Bot no se conecta:
- Verificar URL en `closecustom.cs`
- Revisar logs en Vercel
- Comprobar que el bot compile sin errores

### Panel admin no carga:
- Ir a `https://tu-proyecto.vercel.app/admin`
- Verificar en logs de Vercel si hay errores
- Comprobar variables de entorno

## 💰 Costos

- **Supabase**: Gratis hasta 500MB + 50,000 requests/mes
- **Vercel**: Gratis hasta 100GB bandwidth
- **Telegram**: Gratis

¡Perfecto para empezar sin costos!

## 🔄 Actualizaciones

Para actualizar el sistema:
```bash
git add .
git commit -m "Actualización"
git push
# Vercel hace auto-deploy automáticamente
```

## 📊 Monitoreo

### Supabase Dashboard:
- Ver usuarios registrados
- Ver logs de acceso
- Estadísticas de uso

### Vercel Analytics:
- Requests por minuto
- Tiempo de respuesta
- Errores del servidor

---

**¡Ya tienes tu sistema de autorización 100% online y escalable!** 🎉
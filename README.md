# 🤖 TradingAdmin - Sistema Completo de Trading

Sistema integral que incluye trading bot para NinjaTrader con sistema de autorización avanzado.

## 📋 Contenido del Repositorio

### 🤖 Trading Bot
- **closecustom.cs**: Estrategia de trading automatizada para NinjaTrader
- **TradeMonitor.cs**: Monitor adicional de trades
- Protección por hardware con sistema de autorización online

### 🛡️ Sistema de Autorización
- **Servidor Node.js**: Sistema backend para gestión de usuarios
- **Panel Web**: Interfaz de administración en tiempo real
- **Base de datos SQLite**: Almacenamiento de usuarios y logs
- **Notificaciones Telegram**: Alertas automáticas de nuevas solicitudes

### 📱 Aplicación Flutter
- **tradingadmin/**: App móvil para gestión del sistema
- Dashboard con estadísticas
- Control remoto del bot

## 🚀 Instalación Rápida

### 1. Trading Bot (NinjaTrader)
```bash
# Copiar closecustom.cs a:
# Documents\NinjaTrader 8\bin\Custom\Strategies\
```

### 2. Sistema de Autorización
```bash
cd tradingadmin/auth_system
npm install
npm start
# Acceder a: http://localhost:3000/admin
```

### 3. App Flutter
```bash
cd tradingadmin
flutter pub get
flutter run
```

## ⚙️ Configuración

### Variables de Entorno
- `TELEGRAM_BOT_TOKEN`: Token del bot de Telegram
- `TELEGRAM_CHAT_ID`: ID del chat para notificaciones
- `ADMIN_PASSWORD`: Password para acciones administrativas

### URLs importantes
- Panel Admin: `http://localhost:3000/admin`
- API Status: `http://localhost:3000/`
- Bot URL: Configurado en `closecustom.cs`

## 🔧 Características

### Trading Bot
✅ Estrategia automática basada en prior close  
✅ Gestión de riesgo avanzada  
✅ Soporte para Micros y Minis  
✅ Targets múltiples (1:1, 2:1, 3:1)  
✅ Protección por hardware único  

### Sistema de Autorización  
✅ Registro automático de nuevos usuarios  
✅ Panel web de administración  
✅ Notificaciones Telegram en tiempo real  
✅ Base de datos con logs completos  
✅ API REST completa  

### Seguridad
✅ Hardware ID único por PC  
✅ Hash SHA256 para protección  
✅ Fecha de expiración configurable  
✅ Logs de acceso detallados  
✅ Protección contra distribución no autorizada  

## 📊 Estructura del Proyecto

```
tradingadmin/
├── trading_strategies/          # Bots de NinjaTrader
│   ├── closecustom.cs          # Bot principal
│   └── TradeMonitor.cs         # Monitor de trades
├── auth_system/                # Sistema de autorización
│   ├── server.js               # Servidor Node.js
│   ├── admin_panel.html        # Panel de administración
│   ├── package.json            # Dependencias
│   └── README.md               # Documentación detallada
├── lib/                        # App Flutter
├── assets/                     # Recursos
└── README.md                   # Este archivo
```

## 🛠️ Tecnologías

- **Backend**: Node.js + Express + SQLite
- **Frontend**: HTML5 + CSS3 + JavaScript
- **Mobile**: Flutter + Dart
- **Trading**: C# + NinjaTrader 8 API
- **Notificaciones**: Telegram Bot API
- **Base de datos**: SQLite (local)

## 📞 Soporte

### Logs del Sistema
```bash
# Ver logs del servidor
npm start

# Ver logs de la app
flutter logs
```

### Troubleshooting
- Verificar configuración de URLs
- Revisar tokens de Telegram
- Comprobar permisos de base de datos
- Validar conexión a internet

## 🎯 Próximas Características

- [ ] Dashboard web mejorado
- [ ] Notificaciones push móviles
- [ ] Análisis de rendimiento
- [ ] Backup automático de base de datos
- [ ] Integración con más plataformas de trading

## 📄 Licencia

Uso privado. Todos los derechos reservados.

---

**Desarrollado por**: TradingAdmin Team  
**Última actualización**: Septiembre 2025  
**Versión**: 1.0
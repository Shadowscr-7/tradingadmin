-- ============================================================================
-- SQL PARA SUPABASE - SISTEMA DE AUTORIZACIÓN TRADING BOT
-- Ejecutar en SQL Editor de Supabase
-- ============================================================================

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

-- Comentarios para documentación
COMMENT ON TABLE trading_user_requests IS 'Solicitudes de autorización para el trading bot';
COMMENT ON TABLE trading_access_logs IS 'Logs de acceso e intentos de uso del trading bot';

-- Verificar que las tablas se crearon correctamente
SELECT 
    'trading_user_requests' as table_name,
    COUNT(*) as record_count
FROM trading_user_requests

UNION ALL

SELECT 
    'trading_access_logs' as table_name,
    COUNT(*) as record_count  
FROM trading_access_logs;
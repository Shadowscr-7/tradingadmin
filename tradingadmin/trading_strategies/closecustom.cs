using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Management;
using System.Net.Http;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Xml.Serialization;
using NinjaTrader.Cbi;
using NinjaTrader.Core.FloatingPoint;
using NinjaTrader.Data;
using NinjaTrader.Gui;
using NinjaTrader.Gui.Chart;
using NinjaTrader.Gui.SuperDom;
using NinjaTrader.Gui.Tools;
using NinjaTrader.NinjaScript;
using NinjaTrader.NinjaScript.DrawingTools;
using NinjaTrader.NinjaScript.Indicators;
using Newtonsoft.Json;

namespace NinjaTrader.NinjaScript.Strategies.TradingSimple
{
    public class closecustom : Strategy
    {
        // === SISTEMA DE PROTECCIÓN AVANZADO ===
        private bool isAuthorized = false;
        private bool registrationSent = false;
        private readonly DateTime expirationDate = new DateTime(2025, 12, 31);
        private DateTime lastAuthCheck = DateTime.MinValue;
        
        // URL de tu servidor de autorización (puedes usar Firebase, Supabase, o tu propio servidor)
        private readonly string authServerUrl = "https://tradingadmin-q36j.vercel.app/api";
        private readonly string botVersion = "1.0";
        private readonly string botName = "CloseCustom Bot";
        
        private double priorClose = 0;
        private bool orderPlaced = false;
        private bool breakEvenMoved = false;
        private bool advancedTrail1Moved = false;
        private bool advancedTrail2Moved = false;
        private DateTime entryTime;
        private string entryOrderName = "EntryOrder";
        private Order entryOrder;

        private PriorDayOHLC priorDayOHLC;

        private double entryPrice = 0;
        private double stopTicks = 0;
        private double takeProfitTicks = 0;

        // Variables para gestión de múltiples contratos
        private int contracts60Percent = 0;  // 60% para target 1:1
        private int contracts20Percent1 = 0; // 20% para target 2:1
        private int contracts20Percent2 = 0; // 20% para target 3:1
        
        // Variables para indicadores visuales
        private bool startLineDrawn = false;
        private bool endLineDrawn = false;
        private bool unauthorizedMessageShown = false;
        private bool authorizedMessageShown = false;
        
        // Control de día para reset automático
        private DateTime lastTradingDay = DateTime.MinValue;

        // Configuración fija (no modificable por usuario)
        private bool UseBreakEven = true;
        private int BreakEvenTriggerRatio = 1;
        private bool UseAdvancedTrail = true;
        private double rewardRatio = 3;

        // Solo esta propiedad será visible al usuario
        [NinjaScriptProperty]
        [Display(Name = "Cantidad de Contratos", GroupName = "Configuración", Order = 1)]
        public int ContractQuantity { get; set; } = 5;
		
        private double riskDollars = 300;

        protected override void OnStateChange()
        {
            if (State == State.SetDefaults)
            {
                Name = "closecustom";
                Calculate = Calculate.OnEachTick;  // Cambiar a OnEachTick para targets inmediatos
                EntriesPerDirection = 3;  // Permitir múltiples entradas (una por cada target)
                EntryHandling = EntryHandling.AllEntries;
                IsExitOnSessionCloseStrategy = true;
                ExitOnSessionCloseSeconds = 30;
                IncludeCommission = true;

                // Los valores por defecto ya están establecidos en las variables privadas
                ContractQuantity = 5;
            }
            else if (State == State.Configure)
            {
                priorDayOHLC = PriorDayOHLC(Close);
                AddChartIndicator(priorDayOHLC);
            }
            else if (State == State.Realtime)
            {
                // Inicializar autorización cuando empiece tiempo real
                Task.Run(async () => 
                {
                    bool authResult = await ValidateAuthorization();
                });
            }

        }

        protected void OnOrderUpdate(Order order, double limitPrice, double stopPrice,
            int quantity, int filled, double averageFillPrice,
            OrderState orderState, DateTime time)
        {
            // Monitorear todas las órdenes de entrada
            if ((order.Name == "Entry60" || order.Name == "Entry20_1" || order.Name == "Entry20_2") && order.OrderState == OrderState.Working)
            {
                Print($"📦 Orden registrada: {order.Name} - {order.OrderAction} {order.Quantity} @ {order.LimitPrice}");
            }
            
            // Monitorear cuando se llenan las órdenes
            if ((order.Name == "Entry60" || order.Name == "Entry20_1" || order.Name == "Entry20_2") && order.OrderState == OrderState.Filled)
            {
                Print($"✅ FILL: {order.Name} - {order.Quantity} contratos @ {averageFillPrice:F2}");
            }
        }

        protected override void OnBarUpdate()
        {
            // RESET AUTOMÁTICO DIARIO: Detectar cambio de día para resetear variables
            DateTime currentDay = Times[0][0].Date;
            if (lastTradingDay != DateTime.MinValue && currentDay > lastTradingDay)
            {
                // Nuevo día detectado - resetear todas las variables de trading
                orderPlaced = false;
                priorClose = 0;
                entryOrder = null;
                entryPrice = 0;
                breakEvenMoved = false;
                advancedTrail1Moved = false;
                advancedTrail2Moved = false;
                startLineDrawn = false;
                endLineDrawn = false;
                
                Print($"🔄 NUEVO DÍA DETECTADO: {currentDay:yyyy-MM-dd} | Reset completo de variables");
            }
            lastTradingDay = currentDay;
            
            // SEPARACIÓN COMPLETA: Autorización solo afecta órdenes en tiempo real
            bool isHistoricalData = State == State.Historical;
            bool isRealTime = State == State.Realtime;
            
            // Manejo de autorización solo en tiempo real
            if (isRealTime)
            {
                // Iniciar validación si no se ha hecho
                if (lastAuthCheck == DateTime.MinValue)
                {
                    lastAuthCheck = DateTime.Now;
                    Task.Run(async () => { await ValidateAuthorization(); });
                }
                
                // Mostrar mensajes de autorización
                if (!isAuthorized && !unauthorizedMessageShown)
                {
                    Draw.TextFixed(this, "UnauthorizedMessage", "🛑 BOT NO AUTORIZADO\n⏳ Esperando aprobación del desarrollador", 
                                 TextPosition.Center, Brushes.Red, new SimpleFont("Arial", 16), 
                                 Brushes.Black, Brushes.Yellow, 10);
                    unauthorizedMessageShown = true;
                    Print("🛑 Bot no autorizado - solo mostrará histórico");
                }
                
                if (isAuthorized && !authorizedMessageShown)
                {
                    RemoveDrawObject("UnauthorizedMessage");
                    Draw.TextFixed(this, "AuthorizedMessage", "✅ BOT AUTORIZADO\n🚀 Sistema activo y operativo", 
                                 TextPosition.TopRight, Brushes.LimeGreen, new SimpleFont("Arial", 14), 
                                 Brushes.Black, Brushes.DarkGreen, 5);
                    authorizedMessageShown = true;
                    Task.Run(async () => { await Task.Delay(10000); RemoveDrawObject("AuthorizedMessage"); });
                }
                
                // Verificar autorización periódicamente
                if (DateTime.Now.Subtract(lastAuthCheck).TotalSeconds >= 30)
                {
                    lastAuthCheck = DateTime.Now;
                    Task.Run(async () => { await ValidateAuthorization(); });
                }
            }
            
            // PROCESAMIENTO CONTINÚA SIEMPRE (histórico y tiempo real)
            

            
            if (BarsInProgress != 0 || CurrentBar < 20)
            {

                return;
            }
            


            DateTime nyTime = Times[0][0].ToUniversalTime().AddHours(-4);
            int currentTime = ToTime(nyTime);
            


            // Capturar priorClose más temprano - cualquier hora después de las 6 AM
            if (nyTime.Hour >= 6 && priorClose == 0)
            {
                if (priorDayOHLC.PriorClose[0] != 0)
                {
                    priorClose = priorDayOHLC.PriorClose[0];
                    Print($"🕘 [{nyTime:yyyy-MM-dd HH:mm} NY] PriorClose capturado: {priorClose:F2}");
                }
            }
            


            // DEBUG: Verificar todas las condiciones
            bool timeOk = currentTime >= 80000 && currentTime <= 150000;
            bool noOrderPlaced = !orderPlaced;
            bool hasPriorClose = priorClose != 0;
            
            // MODO PRODUCCIÓN: Solo trading en horario 8:00-15:00 NY
            bool testMode = false; // Modo producción activado
            
            if (!(timeOk && noOrderPlaced && hasPriorClose))
            {
                // Debug: Mostrar por qué no se ejecuta (solo una vez por día)
                if (timeOk && !noOrderPlaced && CurrentBar % 100 == 0)
                {
                    Print($"⏸️ [{nyTime:yyyy-MM-dd HH:mm}] Ya se ejecutó orden hoy | orderPlaced={orderPlaced}");
                }
                return; // Salir silenciosamente si no cumple condiciones
            }
            
            // DEBUG DURANTE HORARIO DE TRADING (8-15 NY) - Solo cuando bot está activo
            if (timeOk && CurrentBar % 50 == 0) // Debug cada 50 barras durante horario activo
            {
                string mode = isHistoricalData ? "BACKTEST" : (isRealTime ? "TIEMPO REAL" : "PROCESANDO");
                Print($"🤖 BOT ACTIVO [{nyTime:yyyy-MM-dd HH:mm:ss} NY] | Modo: {mode} | PriorClose: {priorClose:F2} | Precio actual: {Close[0]:F2}");
            }
            
            if (timeOk && !orderPlaced && priorClose != 0)
            {
                // Dibujar línea de inicio de trading si no se ha dibujado
                if (!startLineDrawn)
                {
                    Draw.VerticalLine(this, "TradingStart_" + CurrentBar, 0, Brushes.White, DashStyleHelper.Solid, 2);
                    Draw.TextFixed(this, "TradingStartText", "🤖 BOT INICIO - 8:00 NY", TextPosition.TopLeft, Brushes.White, new SimpleFont("Arial", 12), Brushes.Transparent, Brushes.Transparent, 0);
                    startLineDrawn = true;
                    string mode = isHistoricalData ? "BACKTEST" : (isRealTime ? "TIEMPO REAL" : "PROCESANDO");
                    Print($"🟢 BOT ACTIVADO A LAS 8:00 NY [{nyTime:yyyy-MM-dd HH:mm:ss}] | Modo: {mode}");
                    Print($"📊 DATOS INICIALES: PriorClose={priorClose:F2} | Precio actual={Close[0]:F2} | Diferencia={(Close[0] - priorClose):F2} puntos");
                }

                // Stop Loss y Targets FIJOS según especificaciones
                stopTicks = 60;    // Stop fijo en 60 ticks
                double breakEvenTicks = 115; // Break even en 115 ticks para targets 120t y 180t
                
                Print($"�️ CONFIGURACIÓN FIJA: Stop=60t | Targets=60t/120t/180t | BreakEven=115t");

                // Calcular distribución de contratos más precisa
                contracts60Percent = (int)Math.Round(ContractQuantity * 0.6);  // 60% = 3 contratos
                contracts20Percent1 = (int)Math.Round(ContractQuantity * 0.2); // 20% = 1 contrato  
                contracts20Percent2 = (int)Math.Round(ContractQuantity * 0.2); // 20% = 1 contrato
                
                // Ajustar si la suma no es exacta
                int totalCalculated = contracts60Percent + contracts20Percent1 + contracts20Percent2;
                if (totalCalculated != ContractQuantity)
                {
                    // Añadir la diferencia al grupo del 60%
                    contracts60Percent += (ContractQuantity - totalCalculated);
                }

                Print($"📊 Distribución contratos: 60%={contracts60Percent} | 20%={contracts20Percent1} | 20%={contracts20Percent2} | Total={ContractQuantity}");

                // Determinar dirección y calcular entrada - LÓGICA DE REBOTES
                if (Close[0] > priorClose)
                {
                    // Precio ARRIBA del priorClose → buscar REBOTE hacia abajo → LONG entry 20 ticks ABAJO del priorClose
                    entryPrice = priorClose - (20 * TickSize);  // 20 ticks = 20 × 0.25 = 5 puntos
                    
                    // DEBUG: Mostrar cálculo de entrada
                    Print($"🔢 DEBUG LONG: PriorClose={priorClose:F2} | TickSize={TickSize:F2} | 20 ticks={(20 * TickSize):F2} puntos | Entry={entryPrice:F2}");
                    
                    // Targets fijos: 60 ticks, 120 ticks, 180 ticks desde entrada (usar CalculationMode.Ticks)
                    // No calcular precios manualmente - NinjaTrader lo hará automáticamente
                    
                    // CONTROL DE ÓRDENES: Histórico siempre ejecuta, tiempo real solo si está autorizado
                    bool canPlaceOrders = isHistoricalData || (isRealTime && isAuthorized);
                    
                    if (canPlaceOrders)
                    {
                        // Crear órdenes LONG con targets y stops correctos
                        if (contracts60Percent > 0)
                        {
                            EnterLongLimit(0, true, contracts60Percent, entryPrice, "Entry60"); // Siempre limit para LONG
                                
                            SetStopLoss("Entry60", CalculationMode.Ticks, 60, false);  // Stop fijo en 60 ticks
                            SetProfitTarget("Entry60", CalculationMode.Ticks, 60); // Target 60 ticks
                        }
                        
                        if (contracts20Percent1 > 0)
                        {
                            EnterLongLimit(0, true, contracts20Percent1, entryPrice, "Entry20_1"); // Siempre limit para LONG
                                
                            SetStopLoss("Entry20_1", CalculationMode.Ticks, 60, false);  // Stop fijo en 60 ticks
                            SetProfitTarget("Entry20_1", CalculationMode.Ticks, 120); // Target 120 ticks
                        }
                        
                        if (contracts20Percent2 > 0)
                        {
                            EnterLongLimit(0, true, contracts20Percent2, entryPrice, "Entry20_2"); // Siempre limit para LONG
                                
                            SetStopLoss("Entry20_2", CalculationMode.Ticks, 60, false);  // Stop fijo en 60 ticks
                            SetProfitTarget("Entry20_2", CalculationMode.Ticks, 180); // Target 180 ticks
                        }
                    }
                    
                    orderPlaced = true;
                    entryTime = nyTime;
                    string orderType = "LIMIT"; // Siempre LIMIT
                    string status = canPlaceOrders ? "EJECUTADO" : "BLOQUEADO (sin autorización)";
                    Print($"✅ LONG {orderType} {status}: {contracts60Percent}@60t + {contracts20Percent1}@120t + {contracts20Percent2}@180t | Precio:{Close[0]:F2} PriorClose:{priorClose:F2} Entry:{entryPrice:F2}");
                    Print($"🎯 Targets LONG: Entry+60t | Entry+120t | Entry+180t");
                    Print($"🛡️ Stop Loss: 60 ticks | Break Even: 115 ticks (para 120t y 180t)");
                }
                else if (Close[0] < priorClose)
                {
                    // Precio ABAJO del priorClose → buscar REBOTE hacia arriba → SHORT entry 20 ticks ARRIBA del priorClose
                    entryPrice = priorClose + (20 * TickSize);  // 20 ticks = 20 × 0.25 = 5 puntos
                    
                    // DEBUG: Mostrar cálculo de entrada
                    Print($"🔢 DEBUG SHORT: PriorClose={priorClose:F2} | TickSize={TickSize:F2} | 20 ticks={(20 * TickSize):F2} puntos | Entry={entryPrice:F2}");
                    
                    // Targets fijos: 60 ticks, 120 ticks, 180 ticks desde entrada (usar CalculationMode.Ticks)
                    // No calcular precios manualmente - NinjaTrader lo hará automáticamente
                    
                    // CONTROL DE ÓRDENES: Histórico siempre ejecuta, tiempo real solo si está autorizado
                    bool canPlaceOrders = isHistoricalData || (isRealTime && isAuthorized);
                    
                    if (canPlaceOrders)
                    {
                        // Crear órdenes SHORT con targets y stops correctos
                        if (contracts60Percent > 0)
                        {
                            EnterShortLimit(0, true, contracts60Percent, entryPrice, "Entry60"); // Siempre limit para SHORT
                                
                            SetStopLoss("Entry60", CalculationMode.Ticks, 60, false);  // Stop fijo en 60 ticks
                            SetProfitTarget("Entry60", CalculationMode.Ticks, 60); // Target 60 ticks
                        }
                        
                        if (contracts20Percent1 > 0)
                        {
                            EnterShortLimit(0, true, contracts20Percent1, entryPrice, "Entry20_1"); // Siempre limit para SHORT
                                
                            SetStopLoss("Entry20_1", CalculationMode.Ticks, 60, false);  // Stop fijo en 60 ticks
                            SetProfitTarget("Entry20_1", CalculationMode.Ticks, 120); // Target 120 ticks
                        }
                        
                        if (contracts20Percent2 > 0)
                        {
                            EnterShortLimit(0, true, contracts20Percent2, entryPrice, "Entry20_2"); // Siempre limit para SHORT
                                
                            SetStopLoss("Entry20_2", CalculationMode.Ticks, 60, false);  // Stop fijo en 60 ticks
                            SetProfitTarget("Entry20_2", CalculationMode.Ticks, 180); // Target 180 ticks
                        }
                    }
                    
                    orderPlaced = true;
                    entryTime = nyTime;
                    string orderType = "LIMIT"; // Siempre LIMIT
                    string status = canPlaceOrders ? "EJECUTADO" : "BLOQUEADO (sin autorización)";
                    Print($"✅ SHORT {orderType} {status}: {contracts60Percent}@60t + {contracts20Percent1}@120t + {contracts20Percent2}@180t | Precio:{Close[0]:F2} PriorClose:{priorClose:F2} Entry:{entryPrice:F2}");
                    Print($"🎯 Targets SHORT: Entry-60t | Entry-120t | Entry-180t");
                    Print($"🛡️ Stop Loss: 60 ticks | Break Even: 115 ticks (para 120t y 180t)");
                }
                else
                {
                    Print($"⏸️ PRECIO IGUAL: Close[0]={Close[0]:F2} == PriorClose={priorClose:F2} - Esperando movimiento");
                    Print($"🔍 Info: Precio actual vs PriorClose | Diferencia: {(Close[0] - priorClose):F2} puntos");
                }
            }

            // Dibujar línea de fin de trading cuando se cierre la ventana
            if (currentTime > 150000 && !endLineDrawn && startLineDrawn)
            {
                Draw.VerticalLine(this, "TradingEnd_" + CurrentBar, 0, Brushes.White, DashStyleHelper.Solid, 2);
                Draw.TextFixed(this, "TradingEndText", "🛑 BOT FIN - 15:00 NY", TextPosition.TopRight, Brushes.White, new SimpleFont("Arial", 12), Brushes.Transparent, Brushes.Transparent, 0);
                endLineDrawn = true;
                Print($"🔴 FIN ventana de trading [{nyTime:yyyy-MM-dd}] - 15:00 NY");
            }

            if (Position.MarketPosition != MarketPosition.Flat)
            {
                // Solo logging para monitorear el progreso - los targets son automáticos
                double oneToOne = stopTicks * TickSize;
                double currentProfit = Close[0] - entryPrice;
                if (Position.MarketPosition == MarketPosition.Short)
                    currentProfit = entryPrice - Close[0];

                // Debug información cada 100 barras
                if (CurrentBar % 100 == 0)
                {
                    Print($"📊 DEBUG: Profit={currentProfit:F2} | Target 1:1={oneToOne:F2} | Posición: {Position.Quantity} contratos");
                }
            }

            if (orderPlaced && (nyTime.Hour == 23 && nyTime.Minute >= 59) && Position.MarketPosition == MarketPosition.Flat)
            {
                if (entryOrder != null && entryOrder.OrderState == OrderState.Working)
                {
                    CancelOrder(entryOrder);
                    Print("⏹️ Orden cancelada por ventana de tiempo (pasó 15:00 NY sin ejecución)");
                }

                // Reset completo de variables
                orderPlaced = false;
                priorClose = 0;
                entryOrder = null;
                entryPrice = 0;
                breakEvenMoved = false;
                advancedTrail1Moved = false;
                advancedTrail2Moved = false;
                startLineDrawn = false;
                endLineDrawn = false;
                Print("🔄 Reset completo por fin de sesión");
            }

            if (Position.MarketPosition == MarketPosition.Flat && (breakEvenMoved || advancedTrail1Moved || advancedTrail2Moved))
            {
                // Reset ALL flags when position is flat
                breakEvenMoved = false;
                advancedTrail1Moved = false;
                advancedTrail2Moved = false;
                entryPrice = 0;
                Print("🔄 Posición cerrada - Reset completo de flags y variables");
            }
        }
        
        // === MÉTODOS DE PROTECCIÓN AVANZADO ===
        
        private async Task<bool> ValidateAuthorization()
        {
            try
            {
                // 1. Verificar fecha de expiración
                if (DateTime.Now > expirationDate)
                {
                    Print($"❌ Bot expirado. Válido hasta: {expirationDate:yyyy-MM-dd}");
                    return false;
                }
                
                // 2. Obtener información del usuario
                var userInfo = GetUserInfo();
                
                // 3. Verificar autorización online
                bool authorized = await CheckOnlineAuthorization(userInfo);
                
                if (!authorized && !registrationSent)
                {
                    // 4. Si no está autorizado, enviar solicitud automáticamente
                    await SendRegistrationRequest(userInfo);
                    registrationSent = true;
                }
                
                if (authorized)
                {
                    isAuthorized = true;
                    Print("✅ Bot autorizado. ¡Bienvenido!");
                    
                    // Limpiar flag para mostrar mensaje de autorizado
                    authorizedMessageShown = false;
                    
                    return true;
                }
                else
                {
                    Print("⏳ Esperando autorización del desarrollador...");
                    Print($"📧 Solicitud enviada para: {userInfo.UserName} ({userInfo.ComputerName})");
                    Print("� El bot estará activo una vez que seas autorizado.");
                    return false;
                }
            }
            catch (Exception ex)
            {
                Print($"❌ Error en validación: {ex.Message}");
                return false;
            }
        }
        
        private async Task<bool> CheckOnlineAuthorization(UserInfo userInfo)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromSeconds(10);
                    
                    var requestData = new
                    {
                        hwid = userInfo.HardwareHash,
                        action = "check_auth"
                    };
                    
                    string jsonData = JsonConvert.SerializeObject(requestData);
                    var content = new StringContent(jsonData, Encoding.UTF8, "application/json");
                    
                    var response = await client.PostAsync($"{authServerUrl}/check-authorization", content);
                    
                    if (response.IsSuccessStatusCode)
                    {
                        string responseData = await response.Content.ReadAsStringAsync();
                        var result = JsonConvert.DeserializeObject<dynamic>(responseData);
                        bool authorized = result.authorized == true;
                        
                        // IMPORTANTE: Si no está autorizado, resetear registrationSent 
                        // para permitir re-envío de solicitudes (por ejemplo, si se eliminó la autorización)
                        if (!authorized)
                        {
                            registrationSent = false;
                        }
                        
                        return authorized;
                    }
                }
            }
            catch (Exception ex)
            {
                Print($"⚠️ No se pudo verificar autorización online: {ex.Message}");
                // En caso de error de conexión, permitir ejecución temporal
                return false;
            }
            
            return false;
        }
        
        private async Task SendRegistrationRequest(UserInfo userInfo)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromSeconds(15);
                    
                    var requestData = new
                    {
                        hwid = userInfo.HardwareHash,
                        userName = userInfo.UserName,
                        computerName = userInfo.ComputerName,
                        botName = botName,
                        botVersion = botVersion,
                        requestDate = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
                        action = "register_request"
                    };
                    
                    string jsonData = JsonConvert.SerializeObject(requestData);
                    var content = new StringContent(jsonData, Encoding.UTF8, "application/json");
                    
                    var response = await client.PostAsync($"{authServerUrl}/register-request", content);
                    
                    if (response.IsSuccessStatusCode)
                    {
                        Print("📤 Solicitud de autorización enviada correctamente.");
                        Print("📱 El desarrollador recibirá una notificación automáticamente.");
                    }
                    else
                    {
                        Print("⚠️ Error enviando solicitud. Reintentando en próxima ejecución.");
                    }
                }
            }
            catch (Exception ex)
            {
                Print($"⚠️ Error enviando registro: {ex.Message}");
            }
        }
        
        private UserInfo GetUserInfo()
        {
            try
            {
                string hardwareId = GetHardwareId();
                string hashedHwid = ComputeHash(hardwareId);
                
                return new UserInfo
                {
                    HardwareHash = hashedHwid,
                    UserName = Environment.UserName,
                    ComputerName = Environment.MachineName,
                    WindowsUser = $"{Environment.UserDomainName}\\{Environment.UserName}"
                };
            }
            catch (Exception ex)
            {
                Print($"Error obteniendo info usuario: {ex.Message}");
                return new UserInfo
                {
                    HardwareHash = "ERROR",
                    UserName = "Unknown",
                    ComputerName = "Unknown"
                };
            }
        }
        
        private string GetHardwareId()
        {
            try
            {
                string hardwareId = "";
                
                // Obtener ID del procesador
                using (ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT ProcessorId FROM Win32_Processor"))
                {
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        hardwareId += obj["ProcessorId"]?.ToString() ?? "";
                        break; // Solo el primero
                    }
                }
                
                // Obtener ID de la placa base
                using (ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT SerialNumber FROM Win32_BaseBoard"))
                {
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        hardwareId += obj["SerialNumber"]?.ToString() ?? "";
                        break;
                    }
                }
                
                // Obtener nombre de usuario de Windows
                hardwareId += Environment.UserName;
                
                return hardwareId;
            }
            catch
            {
                // Fallback: usar nombre de PC + usuario
                return Environment.MachineName + Environment.UserName;
            }
        }
        
        private string ComputeHash(string input)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(input));
                return Convert.ToBase64String(hashBytes).Substring(0, 16); // Primeros 16 caracteres
            }
        }
    }
    
    // === CLASE AUXILIAR PARA INFORMACIÓN DEL USUARIO ===
    public class UserInfo
    {
        public string HardwareHash { get; set; }
        public string UserName { get; set; }
        public string ComputerName { get; set; }
        public string WindowsUser { get; set; }
    }
}
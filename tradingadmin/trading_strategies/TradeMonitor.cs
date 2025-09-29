using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using System.Xml.Serialization;
using System.Net.Http;
using System.IO;
using NinjaTrader.Cbi;
using NinjaTrader.Gui;
using NinjaTrader.Gui.Chart;
using NinjaTrader.Gui.SuperDom;
using NinjaTrader.Gui.Tools;
using NinjaTrader.Data;
using NinjaTrader.NinjaScript;
using NinjaTrader.Core.FloatingPoint;
using NinjaTrader.NinjaScript.Indicators;
using NinjaTrader.NinjaScript.DrawingTools;

namespace NinjaTrader.NinjaScript.Indicators
{
    public class TradeMonitor : Indicator
    {
        private Account tradingAccount;
        private List<Account> allAccounts = new List<Account>();
        private Dictionary<string, TradeInfo> activeTrades = new Dictionary<string, TradeInfo>();
        private List<Order> pendingOrders = new List<Order>();
        private DateTime lastReportTime = DateTime.MinValue;
        private int tickCounter = 0;
        
        // Webhook y control de mensajes enviados
        private readonly string webhookUrl = "https://n8n.contacthouse.com.uy/webhook/trading_signals";
        private HashSet<string> sentMessages = new HashSet<string>();
        private static readonly HttpClient httpClient = new HttpClient();

        // Estructura para almacenar información del trade
        private class TradeInfo
        {
            public double EntryPrice { get; set; }
            public int Quantity { get; set; }
            public MarketPosition Direction { get; set; }
            public DateTime EntryTime { get; set; }
            public double StopPrice { get; set; }
            public List<double> TargetPrices { get; set; } = new List<double>();
            public string TradeSource { get; set; } // "BOT" o "MANUAL"
            public bool IsReported { get; set; }
            public bool EntryWebhookSent { get; set; }
            public bool StopTargetWebhookSent { get; set; }
        }

        protected override void OnStateChange()
        {
            if (State == State.SetDefaults)
            {
                Description = @"Monitor de Trades - Detecta operaciones del bot y manuales";
                Name = "TradeMonitor";
                Calculate = Calculate.OnEachTick;
                IsOverlay = false;
                DisplayInDataBox = true;
                DrawOnPricePanel = false;
                DrawHorizontalGridLines = true;
                DrawVerticalGridLines = true;
                PaintPriceMarkers = true;
                ScaleJustification = NinjaTrader.Gui.Chart.ScaleJustification.Right;
                IsSuspendedWhileInactive = true;
                
                // Configurar colores
                AddPlot(Brushes.Transparent, "Dummy");
            }
            else if (State == State.Configure)
            {
                // Encontrar la cuenta de trading activa - priorizar Sim101
                lock (Account.All)
                {
                    // Primero buscar Sim101 (simulación)
                    tradingAccount = Account.All.FirstOrDefault(a => a.DisplayName.Contains("Sim101"));
                    
                    // Si no encuentra Sim101, buscar otras cuentas
                    if (tradingAccount == null)
                    {
                        tradingAccount = Account.All.FirstOrDefault(a => a.Provider.ToString().Contains("Playback") || 
                                                                          a.Provider.ToString().Contains("Live") ||
                                                                          a.Provider.ToString().Contains("Sim"));
                    }
                }
                
                // Suscribirse a TODAS las cuentas para capturar órdenes manuales
                allAccounts.Clear();
                foreach (var account in Account.All)
                {
                    allAccounts.Add(account);
                    account.OrderUpdate += OnOrderUpdate;
                    account.ExecutionUpdate += OnExecutionUpdate;
                    account.PositionUpdate += OnPositionUpdate;
                }
                
                if (tradingAccount == null && Account.All.Count > 0)
                {
                    tradingAccount = Account.All.First();
                }
            }
            else if (State == State.Terminated)
            {
                // Desuscribirse de eventos de todas las cuentas
                foreach (var account in allAccounts)
                {
                    if (account != null)
                    {
                        account.OrderUpdate -= OnOrderUpdate;
                        account.ExecutionUpdate -= OnExecutionUpdate;
                        account.PositionUpdate -= OnPositionUpdate;
                    }
                }
                allAccounts.Clear();
            }
        }

        protected override void OnBarUpdate()
        {
            // Solo para mantener el indicador activo
            Values[0][0] = 0;
            
            // Cada 10 ticks, intentar detectar stops y targets pendientes
            tickCounter++;
            if (tickCounter % 10 == 0)
            {
                foreach (var trade in activeTrades.Values.Where(t => t.StopPrice == 0 && t.TargetPrices.Count == 0))
                {
                    DetectStopsAndTargets(trade);
                }
                
                // Revisar órdenes activas manualmente cada 50 ticks
                if (tickCounter % 50 == 0)
                {
                    CheckForManualOrders();
                }
                
                // Limpiar trades antiguos
                CleanupOldTrades();
            }
        }

        private void OnOrderUpdate(object sender, OrderEventArgs e)
        {
            Order order = e.Order;
            
            // Detectar órdenes del bot por los nombres específicos
            bool isBotOrder = order.Name.Contains("Entry60") || order.Name.Contains("Entry20_1") || 
                             order.Name.Contains("Entry20_2") || order.Name.Contains("closecustom");
            
            string source = isBotOrder ? "🤖 BOT" : "👤 MANUAL";
            
            // Monitorear órdenes pendientes - solo para Entry orders
            if (order.OrderState == OrderState.Working && (order.OrderAction == OrderAction.Buy || order.OrderAction == OrderAction.Sell))
            {
                // Solo reportar órdenes de entrada (Entry), no stops ni targets
                if (order.Name == "Entry" || order.Name.Contains("Entry60") || order.Name.Contains("Entry20"))
                {
                    if (!pendingOrders.Any(o => o.Id == order.Id))
                    {
                        pendingOrders.Add(order);
                        string pendingMessage = $"📋 {source} - Orden pendiente: {order.OrderAction} {order.Quantity} @ {order.LimitPrice:F2} | Instrumento: {order.Instrument.MasterInstrument.Name}";
                        Print(pendingMessage);
                        
                        // Enviar webhook para órdenes manuales
                        if (!isBotOrder)
                        {
                            SendWebhook(pendingMessage);
                        }
                    }
                }
            }
            
            // Limpiar órdenes canceladas/completadas
            if (order.OrderState == OrderState.Cancelled || order.OrderState == OrderState.Filled)
            {
                pendingOrders.RemoveAll(o => o.Id == order.Id);
                
                if (order.OrderState == OrderState.Cancelled && (order.Name == "Entry" || order.Name.Contains("Entry60") || order.Name.Contains("Entry20")))
                {
                    Print($"❌ {source} - Orden cancelada: {order.OrderAction} {order.Quantity} @ {order.LimitPrice:F2}");
                }
            }
        }

        private void OnExecutionUpdate(object sender, ExecutionEventArgs e)
        {
            Execution execution = e.Execution;
            
            // Solo procesar fills (Buy/Sell)
            if (execution.Order.OrderAction != OrderAction.Buy && execution.Order.OrderAction != OrderAction.Sell) return;
            
            // Detectar si es del bot
            bool isBotTrade = execution.Order.Name.Contains("Entry60") || execution.Order.Name.Contains("Entry20_1") || 
                             execution.Order.Name.Contains("Entry20_2") || execution.Order.Name.Contains("closecustom");
            
            string source = isBotTrade ? "🤖 BOT" : "👤 MANUAL";
            
            // Procesar órdenes de ENTRADA
            if (execution.Order.Name.Equals("Entry") || execution.Order.Name.Contains("Entry60") || execution.Order.Name.Contains("Entry20"))
            {
                string tradeId = $"{execution.Order.Id}_{DateTime.Now.Ticks}";
                
                // Crear información del trade
                TradeInfo tradeInfo = new TradeInfo
                {
                    EntryPrice = execution.Price,
                    Quantity = execution.Quantity,
                    Direction = execution.Order.OrderAction == OrderAction.Buy ? MarketPosition.Long : MarketPosition.Short,
                    EntryTime = execution.Time,
                    TradeSource = source,
                    IsReported = false
                };
                
                // Agregar a trades activos
                activeTrades[tradeId] = tradeInfo;
                
                // Reportar entrada inmediatamente
                ReportTradeEntry(tradeInfo);
            }
            // Procesar órdenes de TARGET
            else if (execution.Order.Name.Contains("Target"))
            {
                string targetMessage = $"🎯 {source} - TARGET EJECUTADO: {execution.Order.Name} | {execution.Quantity} contratos @ {execution.Price:F2} | Instrumento: {execution.Instrument.MasterInstrument.Name}";
                Print(targetMessage);
                
                // Enviar webhook para targets manuales
                if (!isBotTrade)
                {
                    SendWebhook(targetMessage);
                }
            }
            // Procesar órdenes de STOP
            else if (execution.Order.Name.Contains("Stop"))
            {
                string stopMessage = $"🛡️ {source} - STOP EJECUTADO: {execution.Order.Name} | {execution.Quantity} contratos @ {execution.Price:F2} | Instrumento: {execution.Instrument.MasterInstrument.Name}";
                Print(stopMessage);
                
                // Enviar webhook para stops manuales
                if (!isBotTrade)
                {
                    SendWebhook(stopMessage);
                }
            }
        }

        private void OnPositionUpdate(object sender, PositionEventArgs e)
        {
            // Cuando la posición cambia, intentar detectar stops y targets
            foreach (var trade in activeTrades.Values.Where(t => t.StopPrice == 0 && t.TargetPrices.Count == 0))
            {
                DetectStopsAndTargets(trade);
            }
        }

        private void ReportTradeEntry(TradeInfo trade)
        {
            string direction = trade.Direction == MarketPosition.Long ? "LONG" : "SHORT";
            
            Print($"🚀 {trade.TradeSource} - ENTRADA EJECUTADA:");
            Print($"   💰 {direction} {trade.Quantity} contratos @ {trade.EntryPrice:F2}");
            Print($"   🕒 Hora: {trade.EntryTime:HH:mm:ss}");
            Print($"   📊 Instrumento: {Instrument.MasterInstrument.Name}");
            
            // Enviar webhook para entradas manuales
            if (trade.TradeSource.Contains("MANUAL") && !trade.EntryWebhookSent)
            {
                string entryMessage = $"🚀 {trade.TradeSource} - ENTRADA EJECUTADA:\\n   🕒 Hora: {trade.EntryTime:HH:mm:ss}";
                SendWebhook(entryMessage);
                trade.EntryWebhookSent = true;
            }
            
            // Intentar detectar stops y targets inmediatamente
            DetectStopsAndTargets(trade);
            
            // Marcar como reportado para la entrada
            trade.IsReported = true;
        }

        private void DetectStopsAndTargets(TradeInfo trade)
        {
            // Solo detectar si aún no se han reportado
            if (trade.StopPrice > 0 || trade.TargetPrices.Count > 0) return;
            
            // Buscar en todas las cuentas para encontrar stops y targets
            List<double> detectedTargets = new List<double>();
            double detectedStop = 0;
            
            foreach (var account in allAccounts)
            {
                if (account == null) continue;
                
                // Buscar TODAS las órdenes activas incluyendo estado Accepted
                var allOrders = account.Orders.Where(o => 
                    o.OrderState == OrderState.Working || 
                    o.OrderState == OrderState.Accepted ||
                    o.OrderState == OrderState.PartFilled ||
                    o.OrderState == OrderState.Submitted).ToList();
                
                foreach (var order in allOrders)
                {
                    // Excluir órdenes de entrada
                    if (order.Name.Equals("Entry") || order.Name.Contains("Entry60") || order.Name.Contains("Entry20")) 
                        continue;
                    
                    // Detectar stop loss - buscar cualquier orden StopMarket o StopLimit
                    if (order.OrderType == OrderType.StopMarket || order.OrderType == OrderType.StopLimit)
                    {
                        // Para long: stop debe estar abajo de la entrada
                        // Para short: stop debe estar arriba de la entrada
                        bool isValidStop = (trade.Direction == MarketPosition.Long && order.StopPrice < trade.EntryPrice) ||
                                          (trade.Direction == MarketPosition.Short && order.StopPrice > trade.EntryPrice);
                        
                        if (isValidStop)
                        {
                            detectedStop = order.StopPrice;
                        }
                    }
                    // Detectar profit targets - cualquier orden Limit en dirección correcta
                    else if (order.OrderType == OrderType.Limit)
                    {
                        // Para long: target debe estar arriba de la entrada
                        // Para short: target debe estar abajo de la entrada
                        bool isValidTarget = (trade.Direction == MarketPosition.Long && order.LimitPrice > trade.EntryPrice) ||
                                            (trade.Direction == MarketPosition.Short && order.LimitPrice < trade.EntryPrice);
                        
                        if (isValidTarget && !detectedTargets.Contains(order.LimitPrice))
                        {
                            detectedTargets.Add(order.LimitPrice);
                        }
                    }
                }
            }
            
            // Reportar stops y targets si se encontraron
            if (detectedStop > 0 || detectedTargets.Count > 0)
            {
                ReportStopsAndTargets(trade, detectedStop, detectedTargets);
                trade.StopPrice = detectedStop;
                trade.TargetPrices = detectedTargets.OrderBy(t => Math.Abs(t - trade.EntryPrice)).ToList();
            }
        }

        private void ReportStopsAndTargets(TradeInfo trade, double stopPrice, List<double> targetPrices)
        {
            StringBuilder message = new StringBuilder();
            
            // Reportar targets
            if (targetPrices.Count > 0)
            {
                Print($"🎯 {trade.TradeSource} - Targets detectados:");
                message.AppendLine($"🎯 {trade.TradeSource} - Targets detectados:");
                for (int i = 0; i < targetPrices.Count; i++)
                {
                    string targetLine = $"   Target {i + 1}: {targetPrices[i]:F2}";
                    Print(targetLine);
                    message.AppendLine(targetLine);
                }
            }
            
            // Reportar stop
            if (stopPrice > 0)
            {
                string stopLine = $"🛡️ {trade.TradeSource} - Stop Loss: {stopPrice:F2}";
                Print(stopLine);
                message.AppendLine(stopLine);
            }
            else
            {
                Print($"⚠️ {trade.TradeSource} - No se detectó Stop Loss");
            }
            
            // Enviar webhook para trades manuales con stops/targets
            if (trade.TradeSource.Contains("MANUAL") && !trade.StopTargetWebhookSent && message.Length > 0)
            {
                SendWebhook(message.ToString().Trim());
                trade.StopTargetWebhookSent = true;
            }
        }

        // Método para revisar órdenes manuales que pueden haberse perdido
        private void CheckForManualOrders()
        {
            foreach (var account in allAccounts)
            {
                if (account == null) continue;
                
                var currentOrders = account.Orders.Where(o => o.OrderState == OrderState.Working && 
                    (o.Name == "Entry" || o.Name.Contains("Entry60") || o.Name.Contains("Entry20"))).ToList();
                
                foreach (var order in currentOrders)
                {
                    // Si no es del bot y no está en nuestra lista de órdenes pendientes
                    bool isBotOrder = order.Name.Contains("Entry60") || order.Name.Contains("Entry20_1") || 
                                     order.Name.Contains("Entry20_2") || order.Name.Contains("closecustom");
                    
                    if (!isBotOrder && !pendingOrders.Any(o => o.Id == order.Id))
                    {
                        pendingOrders.Add(order);
                        Print($"� 👤 MANUAL - Orden pendiente: {order.OrderAction} {order.Quantity} @ {order.LimitPrice:F2} | Instrumento: {order.Instrument.MasterInstrument.Name}");
                    }
                }
            }
        }

        // Método para limpiar trades antiguos
        private void CleanupOldTrades()
        {
            var cutoffTime = DateTime.Now.AddHours(-1);
            var oldTrades = activeTrades.Where(t => t.Value.EntryTime < cutoffTime).ToList();
            
            foreach (var oldTrade in oldTrades)
            {
                activeTrades.Remove(oldTrade.Key);
            }
            
            // Limpiar mensajes enviados antiguos (más de 4 horas)
            if (sentMessages.Count > 1000)
            {
                sentMessages.Clear();
            }
        }

        // Método para enviar webhook
        private async void SendWebhook(string message)
        {
            try
            {
                // Crear hash del mensaje para evitar duplicados
                string messageHash = message.GetHashCode().ToString();
                
                // Si ya se envió este mensaje, no enviarlo de nuevo
                if (sentMessages.Contains(messageHash))
                {
                    return;
                }
                
                // Crear contenido JSON
                var jsonContent = $"{{\"message\": \"{message.Replace("\"", "\\\"")}\"}}";
                var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");
                
                // Enviar webhook
                var response = await httpClient.PostAsync(webhookUrl, content);
                
                if (response.IsSuccessStatusCode)
                {
                    // Marcar mensaje como enviado
                    sentMessages.Add(messageHash);
                    Print($"📡 Webhook enviado: {message.Substring(0, Math.Min(50, message.Length))}...");
                }
                else
                {
                    Print($"❌ Error enviando webhook: {response.StatusCode}");
                }
            }
            catch (Exception ex)
            {
                Print($"❌ Excepción enviando webhook: {ex.Message}");
            }
        }

        public override string DisplayName
        {
            get { return Name; }
        }
    }
}
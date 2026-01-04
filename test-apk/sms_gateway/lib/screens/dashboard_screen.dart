import 'package:flutter/material.dart';
import 'package:sim_data/sim_data.dart';
import '../models/sms_transaction.dart';
import '../services/permission_service.dart';
import '../services/sim_service.dart';
import '../services/storage_service.dart';
import '../services/sms_service.dart';
import '../services/foreground_service.dart';
import '../services/counter_reset_service.dart';
import '../widgets/transaction_log_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PermissionService _permissionService = PermissionService();
  final SimService _simService = SimService();
  final StorageService _storage = StorageService();
  final SmsService _smsService = SmsService();
  final ForegroundService _foregroundService = ForegroundService();
  final CounterResetService _counterResetService = CounterResetService();

  final TextEditingController _filterNumbersController =
      TextEditingController();
  final TextEditingController _prefixFilterController = TextEditingController();
  final TextEditingController _webhookUrlController = TextEditingController();

  bool _isServiceRunning = false;
  int _smsCounter = 0;
  int _totalReceivedCounter = 0;
  List<SmsTransaction> _transactions = [];
  SimCard? _selectedSim;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check and reset counter if needed
    await _counterResetService.checkAndResetIfNeeded();

    // Load saved settings
    await _loadSettings();

    // Request permissions
    final hasPermissions = await _permissionService.hasAllPermissions();
    if (!hasPermissions) {
      await _requestPermissions();
    }

    // Initialize SIM
    await _initializeSim();

    // Load counter and transactions
    await _loadData();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestPermissions() async {
    final granted = await _permissionService.requestAllPermissions();
    if (!granted) {
      _showSnackBar(
          'Some permissions were not granted. App may not function properly.');
    }
  }

  Future<void> _initializeSim() async {
    final savedSubscriptionId = await _storage.getSubscriptionId();
    final sim = await _simService.getSelectedSim(savedSubscriptionId);

    if (sim != null) {
      setState(() {
        _selectedSim = sim;
      });
    } else {
      _showSnackBar('No SIM card found');
    }
  }

  Future<void> _loadSettings() async {
    final settings = await _storage.getSettings();
    _filterNumbersController.text = settings.filterNumbers.join(', ');
    _prefixFilterController.text = settings.prefixFilter;
    _webhookUrlController.text = settings.webhookUrl;

    final isRunning = await _storage.getServiceRunning();
    setState(() {
      _isServiceRunning = isRunning;
    });
  }

  Future<void> _loadData() async {
    final counter = await _storage.getSmsCounter();
    final totalReceived = await _storage.getTotalReceived();
    final transactions = await _storage.getTransactions();

    setState(() {
      _smsCounter = counter;
      _totalReceivedCounter = totalReceived;
      _transactions = transactions;
    });
  }

  Future<void> _saveSettings() async {
    final filterNumbers = _filterNumbersController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    await _storage.saveFilterNumbers(filterNumbers);
    await _storage.savePrefixFilter(_prefixFilterController.text.trim());
    await _storage.saveWebhookUrl(_webhookUrlController.text.trim());
  }

  Future<void> _toggleService() async {
    if (_isServiceRunning) {
      // Stop service
      await _foregroundService.stopService();
      await _storage.saveServiceRunning(false);
      setState(() {
        _isServiceRunning = false;
      });
      _showSnackBar('Service stopped');
    } else {
      // Validate webhook URL
      if (_webhookUrlController.text.trim().isEmpty) {
        _showSnackBar('Please enter a webhook URL');
        return;
      }

      // Save settings
      await _saveSettings();

      // Initialize SMS listener
      await _smsService.initializeSmsListener();

      // Start foreground service
      await _foregroundService.startService();
      await _storage.saveServiceRunning(true);

      setState(() {
        _isServiceRunning = true;
      });
      _showSnackBar('Service started');
    }
  }

  Future<void> _selectSim() async {
    final sims = await _simService.getAvailableSims();

    if (sims.isEmpty) {
      if (mounted) _showSnackBar('No SIM cards found');
      return;
    }

    if (sims.length == 1) {
      if (mounted) _showSnackBar('Only one SIM available');
      return;
    }

    if (!mounted) return;

    final selected = await showDialog<SimCard>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select SIM Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sims.map((sim) {
            return ListTile(
              title: Text(_simService.getSimDisplayName(sim)),
              onTap: () => Navigator.pop(context, sim),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && mounted) {
      await _storage.saveSubscriptionId(selected.subscriptionId);
      setState(() {
        _selectedSim = selected;
      });
      _showSnackBar('SIM card selected');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Gateway'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sim_card),
            onPressed: _selectSim,
            tooltip: 'Select SIM',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SIM Card Info
              if (_selectedSim != null)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.sim_card, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _simService.getSimDisplayName(_selectedSim!),
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Filter Numbers
              TextField(
                controller: _filterNumbersController,
                decoration: const InputDecoration(
                  labelText: 'Filter Numbers (comma-separated)',
                  hintText: 'e.g., +1234567890, +0987654321',
                  helperText: 'Leave empty to process all numbers',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                enabled: !_isServiceRunning,
              ),
              const SizedBox(height: 16),

              // Prefix Filter
              TextField(
                controller: _prefixFilterController,
                decoration: const InputDecoration(
                  labelText: 'Prefix Filter',
                  hintText: 'e.g., /bot',
                  helperText: 'Only process messages starting with this prefix',
                  prefixIcon: Icon(Icons.label),
                ),
                enabled: !_isServiceRunning,
              ),
              const SizedBox(height: 16),

              // Webhook URL
              TextField(
                controller: _webhookUrlController,
                decoration: const InputDecoration(
                  labelText: 'Webhook URL *',
                  hintText: 'https://yourdomain.com/sms',
                  helperText: 'Required - FastAPI endpoint URL',
                  prefixIcon: Icon(Icons.webhook),
                ),
                keyboardType: TextInputType.url,
                enabled: !_isServiceRunning,
              ),
              const SizedBox(height: 24),

              // SMS Counters
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 3,
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Total Received',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_totalReceivedCounter',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 3,
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'To Webhook',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_smsCounter',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Start/Stop Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _toggleService,
                  icon: Icon(
                    _isServiceRunning ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isServiceRunning ? 'STOP SERVICE' : 'START SERVICE',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isServiceRunning ? Colors.red : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Transaction Log
              TransactionLogWidget(transactions: _transactions),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _filterNumbersController.dispose();
    _prefixFilterController.dispose();
    _webhookUrlController.dispose();
    super.dispose();
  }
}

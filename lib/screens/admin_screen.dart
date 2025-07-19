import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/bluetooth_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final TextEditingController _smsNumberController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPinChange = false;
  bool _showSmsChange = false;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _smsNumberController.dispose();
    super.dispose();
  }

  Future<void> _changeAdminPin() async {
    if (_currentPinController.text.isEmpty || 
        _newPinController.text.isEmpty || 
        _confirmPinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all PIN fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New PINs do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN must be 4 digits'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
      
      // Verify current PIN
      bool pinValid = await authProvider.authenticateWithPin(_currentPinController.text);
      if (!pinValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current PIN is incorrect'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update PIN in app
      bool appSuccess = await authProvider.changeAdminPin(_currentPinController.text, _newPinController.text);
      
      // Update PIN in Arduino Mega
      bool arduinoSuccess = await bluetoothProvider.updateAdminPin(_newPinController.text);
      
      if (appSuccess && arduinoSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin PIN updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _showPinChange = false;
        });
        _clearPinFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update PIN'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSmsNumber() async {
    if (_smsNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter SMS number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
      bool success = await bluetoothProvider.updateSmsNumber(_smsNumberController.text);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS number updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _showSmsChange = false;
        });
        _smsNumberController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update SMS number'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearPinFields() {
    _currentPinController.clear();
    _newPinController.clear();
    _confirmPinController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Configuration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // PIN Management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Admin PIN Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(_showPinChange ? Icons.expand_less : Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              _showPinChange = !_showPinChange;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_showPinChange) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _currentPinController,
                        decoration: const InputDecoration(
                          labelText: 'Current PIN',
                          border: OutlineInputBorder(),
                          hintText: '0000',
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPinController,
                        decoration: const InputDecoration(
                          labelText: 'New PIN',
                          border: OutlineInputBorder(),
                          hintText: '0000',
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPinController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm New PIN',
                          border: OutlineInputBorder(),
                          hintText: '0000',
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _changeAdminPin,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Update PIN'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // SMS Management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sms, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'SMS Number Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(_showSmsChange ? Icons.expand_less : Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              _showSmsChange = !_showSmsChange;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_showSmsChange) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _smsNumberController,
                        decoration: const InputDecoration(
                          labelText: 'SMS Number',
                          border: OutlineInputBorder(),
                          hintText: '+1234567890',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateSmsNumber,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Update SMS Number'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Current Status
            Consumer<BluetoothProvider>(
              builder: (context, bluetoothProvider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.lock, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text('Admin PIN: ${bluetoothProvider.adminPin.isNotEmpty ? "***" : "Not set"}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.sms, color: Colors.green),
                            const SizedBox(width: 8),
                            Text('SMS Number: ${bluetoothProvider.smsNumber.isNotEmpty ? bluetoothProvider.smsNumber : "Not set"}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Connection Status
            Consumer<BluetoothProvider>(
              builder: (context, bluetoothProvider, child) {
                return Card(
                  color: bluetoothProvider.isConnected ? Colors.green : Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          bluetoothProvider.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bluetoothProvider.isConnected 
                              ? 'Connected to Arduino Mega' 
                              : 'Not connected to Arduino Mega',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
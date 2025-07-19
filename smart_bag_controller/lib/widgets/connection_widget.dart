import 'package:flutter/material.dart';

class ConnectionWidget extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;
  final String connectionStatus;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const ConnectionWidget({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    required this.connectionStatus,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isConnected
                ? [
                    Colors.green.shade50,
                    Colors.green.shade100,
                  ]
                : [
                    Colors.grey.shade50,
                    Colors.grey.shade100,
                  ],
          ),
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isConnected
                    ? Colors.green
                    : isConnecting
                        ? Colors.orange
                        : Colors.grey,
              ),
              child: Icon(
                isConnected
                    ? Icons.bluetooth_connected
                    : isConnecting
                        ? Icons.bluetooth_searching
                        : Icons.bluetooth_disabled,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Status Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected
                        ? 'Connected'
                        : isConnecting
                            ? 'Connecting...'
                            : 'Disconnected',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isConnected
                          ? Colors.green.shade800
                          : isConnecting
                              ? Colors.orange.shade800
                              : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    connectionStatus,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Button
            if (isConnected)
              OutlinedButton(
                onPressed: onDisconnect,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Disconnect'),
              )
            else
              ElevatedButton(
                onPressed: isConnecting ? null : onConnect,
                child: isConnecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Connect'),
              ),
          ],
        ),
      ),
    );
  }
}
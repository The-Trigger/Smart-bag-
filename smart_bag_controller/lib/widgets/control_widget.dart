import 'package:flutter/material.dart';

class ControlWidget extends StatelessWidget {
  final bool umbrellaOpen;
  final bool bagLocked;
  final VoidCallback onUmbrellaToggle;
  final VoidCallback onBagLockToggle;

  const ControlWidget({
    super.key,
    required this.umbrellaOpen,
    required this.bagLocked,
    required this.onUmbrellaToggle,
    required this.onBagLockToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bag Controls',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            // Umbrella Control
            Expanded(
              child: _buildControlCard(
                context,
                title: 'Umbrella',
                subtitle: umbrellaOpen ? 'Open' : 'Closed',
                icon: Icons.beach_access,
                color: umbrellaOpen ? Colors.blue : Colors.grey,
                isActive: umbrellaOpen,
                onTap: onUmbrellaToggle,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Bag Lock Control
            Expanded(
              child: _buildControlCard(
                context,
                title: 'Bag Lock',
                subtitle: bagLocked ? 'Locked' : 'Unlocked',
                icon: Icons.lock,
                color: bagLocked ? Colors.red : Colors.green,
                isActive: bagLocked,
                onTap: onBagLockToggle,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Fingerprint Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.fingerprint,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Use fingerprint to control bag functions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [
                      color.withOpacity(0.1),
                      color.withOpacity(0.2),
                    ]
                  : [
                      Colors.grey.shade50,
                      Colors.grey.shade100,
                    ],
            ),
          ),
          child: Column(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? color : Colors.grey,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              // Subtitle
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive ? color : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Action Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive ? 'Deactivate' : 'Activate',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
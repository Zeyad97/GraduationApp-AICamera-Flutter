import 'package:flutter/material.dart';
import '../../utils/app_localization.dart';

class CameraIntegrationScreen extends StatelessWidget {
  const CameraIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization?.translate('camera_setup') ?? 'Camera Setup',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Integration Status Card
            Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 40,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localization?.translate('camera_status') ??
                                'Camera Status',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            localization?.translate('disconnected') ??
                                'Disconnected',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Integration Guide
            Text(
              localization?.translate('integration_guide') ??
                  'Integration Guide',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localization?.translate('integration_desc') ??
                  'To connect your AI camera system:',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Step Cards
            _StepCard(
              number: '1',
              title: 'Install AI Detection Server',
              description:
                  'Install the Python-based AI detection server on your computer running the camera system. The server uses MediaPipe Pose, OpenCV, and TensorFlow.',
              icon: Icons.download,
              color: Colors.blue,
            ),
            _StepCard(
              number: '2',
              title: 'Configure Camera Feed',
              description:
                  'Configure the server with your camera feed (webcam, USB camera, or RTSP stream from smartphone). Set detection thresholds and enable required features.',
              icon: Icons.videocam,
              color: Colors.green,
            ),
            _StepCard(
              number: '3',
              title: 'Connect Via API',
              description:
                  'Get your server API key and URL. Enter them in the form below to establish connection between this app and your AI camera system.',
              icon: Icons.key,
              color: Colors.orange,
            ),
            _StepCard(
              number: '4',
              title: 'Receive Real-Time Alerts',
              description:
                  'Once connected, this app will receive real-time alerts from the AI system via WebSocket or REST API whenever emergency situations are detected.',
              icon: Icons.notifications_active,
              color: Colors.red,
            ),
            const SizedBox(height: 32),

            // Connection Form
            Text(
              'Server Configuration',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText:
                            localization?.translate('server_url') ?? 'Server URL',
                        hintText: 'http://192.168.1.100:5000',
                        prefixIcon: const Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText:
                            localization?.translate('api_key') ?? 'API Key',
                        hintText: 'Enter your API key',
                        prefixIcon: const Icon(Icons.vpn_key),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Connection feature will be available in the full version',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.link),
                        label: Text(
                          localization?.translate('connect_camera') ??
                              'Connect Camera',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Technical Details
            Card(
              color: theme.colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Technical Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• AI Detection: MediaPipe Pose, TensorFlow, OpenCV\n'
                      '• Communication: REST API / WebSocket\n'
                      '• Supported Cameras: Webcam, USB, RTSP (IP Camera)\n'
                      '• Detection Types: Falls, Gestures, Immobility, Abnormal Activity\n'
                      '• Alert Delivery: Real-time push notifications\n'
                      '• Privacy: All processing done locally on your server',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Developer Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.code, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'For Developers',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This app serves as the mobile companion. The AI detection system runs separately using Python. Integration will be completed when connecting to the backend server API.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:visitor_management_task/bloc/visitor_bloc.dart';
import 'package:visitor_management_task/bloc/visitor_event.dart';
import 'package:visitor_management_task/bloc/visitor_state.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});
  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handling = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scan(BarcodeCapture capture) async {
    if (_handling) return;
    final raw = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;
    setState(() => _handling = true);
    await _controller.stop();
    if (!mounted) return;
    final bloc = context.read<VisitorBloc>();
    try {
      final visitor = await bloc.lookupVisitor(raw);
      if (!mounted) return;
      bloc.add(const VisitorsRequested());
      try {
        await bloc.stream.firstWhere(
          (s) =>
              s.status == VisitorStatus.loaded ||
              s.status == VisitorStatus.failure,
        );
      } catch (_) {}
      if (!mounted) return;
      await context.push('/visitor/${visitor.id}', extra: visitor);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid QR or visitor not found: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _handling = false);
        await _controller.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: NavigationBar(
      selectedIndex: 2,
      onDestinationSelected: (index) {
        if (index == 0) context.go('/dashboard');
        if (index == 1) context.go('/visitors');
        if (index == 2) context.go('/scan');
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Visitors',
        ),
        NavigationDestination(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan QR',
        ),
      ],
    ),
    appBar: AppBar(
      title: const Text('Scan visitor QR'),
      actions: [
        IconButton(
          onPressed: () => _controller.toggleTorch(),
          icon: const Icon(Icons.flash_on),
        ),
        IconButton(
          onPressed: () => _controller.switchCamera(),
          icon: const Icon(Icons.cameraswitch),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _scan,
                errorBuilder: (context, error) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Camera unavailable. Please allow camera permission in Android settings.\n${error.errorCode.name}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
              if (_handling)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Text(
                'Position the visitor QR code inside the frame.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'The visitor record will open after a valid code is detected.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

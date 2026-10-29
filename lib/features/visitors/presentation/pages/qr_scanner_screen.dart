import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:visitor_management_task/app/theme/app_theme.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_bloc.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_event.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_state.dart';

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
          (state) =>
              state.status == VisitorStatus.loaded ||
              state.status == VisitorStatus.failure,
        );
      } catch (_) {}
      if (!mounted) return;
      await context.push('/visitor/${visitor.id}', extra: visitor);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Visitor not found. ${error.toString().replaceFirst('Exception: ', '')}',
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
    appBar: AppBar(
      title: const Text('Scan visitor QR'),
      actions: [
        IconButton(
          tooltip: 'Toggle torch',
          onPressed: () => _controller.toggleTorch(),
          icon: const Icon(Icons.flashlight_on_rounded),
        ),
        IconButton(
          tooltip: 'Switch camera',
          onPressed: () => _controller.switchCamera(),
          icon: const Icon(Icons.cameraswitch_rounded),
        ),
        const SizedBox(width: 6),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: 2,
      onDestinationSelected: (index) {
        if (index == 0) context.go('/dashboard');
        if (index == 1) context.go('/visitors');
        if (index == 2) context.go('/scan');
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.space_dashboard_outlined),
          selectedIcon: Icon(Icons.space_dashboard_rounded),
          label: 'Overview',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_alt_outlined),
          selectedIcon: Icon(Icons.people_alt_rounded),
          label: 'Visitors',
        ),
        NavigationDestination(
          icon: Icon(Icons.qr_code_scanner_rounded),
          label: 'Scan QR',
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
                errorBuilder: (context, error) => Container(
                  color: const Color(0xFF111827),
                  padding: const EdgeInsets.all(28),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.no_photography_outlined,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Camera unavailable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Allow camera access in Android settings, then reopen the scanner.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFD0D7E2),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          error.errorCode.name,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: CustomPaint(painter: _ScannerOverlayPainter()),
              ),
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _handling
                              ? Icons.hourglass_top_rounded
                              : Icons.center_focus_strong_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _handling
                              ? 'Looking up visitor…'
                              : 'Align the QR code in the frame',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_handling)
                Container(
                  color: Colors.black.withValues(alpha: .42),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: brandColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to scan',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'The visitor profile opens automatically after a valid scan.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 17,
                    color: mutedColor,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Keep the QR code flat, avoid glare and hold the phone steady until the code is recognised.',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.width < size.height
        ? size.width * .66
        : size.height * .48;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side.clamp(220, 300).toDouble(),
      height: side.clamp(220, 300).toDouble(),
    );
    final dim = Paint()..color = Colors.black.withValues(alpha: .28);
    final clearPath = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(clearPath, dim);

    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const corner = 30.0;
    final path = Path()
      ..moveTo(rect.left, rect.top + corner)
      ..lineTo(rect.left, rect.top + 10)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + 10, rect.top)
      ..lineTo(rect.left + corner, rect.top)
      ..moveTo(rect.right - corner, rect.top)
      ..lineTo(rect.right - 10, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + 10)
      ..lineTo(rect.right, rect.top + corner)
      ..moveTo(rect.right, rect.bottom - corner)
      ..lineTo(rect.right, rect.bottom - 10)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right - 10, rect.bottom)
      ..lineTo(rect.right - corner, rect.bottom)
      ..moveTo(rect.left + corner, rect.bottom)
      ..lineTo(rect.left + 10, rect.bottom)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - 10)
      ..lineTo(rect.left, rect.bottom - corner);
    canvas.drawPath(path, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

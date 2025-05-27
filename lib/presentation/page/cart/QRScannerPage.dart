import 'package:e_kantin/core/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Nomer Meja'),
        backgroundColor: AppColors.white,
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (BarcodeCapture barcodeCapture) {
                    print(
                        'Barcode detected: ${barcodeCapture.barcodes.length}');

                    if (!isScanned) {
                      final List<Barcode> barcodes = barcodeCapture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final String? code = barcodes.first.rawValue;
                        if (code != null && code.isNotEmpty) {
                          setState(() {
                            isScanned = true;
                          });

                          // Vibrate or play sound (optional)
                          // HapticFeedback.vibrate();

                          // Show success dialog or directly return
                          _showSuccessDialog(context, code);
                        }
                      }
                    }
                  },
                ),
                // Overlay dengan frame scanning
                Container(
                  decoration: ShapeDecoration(
                    shape: QrScannerOverlayShape(
                      borderColor: Colors.red,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 250,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Arahkan kamera ke QR Code pada meja',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Berhasil!'),
          content: Text('Kode QR berhasil dipindai: $code'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context)
                    .pop(code); // Return to previous page with result
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// Custom overlay shape untuk frame QR
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path();
    path.addRect(rect);
    path.addRRect(RRect.fromRectAndRadius(
        _getScannerRect(rect), Radius.circular(borderRadius)));
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final borderRadius = this.borderRadius > 25.0 ? 25.0 : this.borderRadius;
    final borderLength = this.borderLength > cutOutSize / 2 + borderRadius
        ? borderRadius + (cutOutSize / 2)
        : this.borderLength;
    final cutOutRect = _getScannerRect(rect);

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final backgroundPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(
          RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)));

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw corner borders
    _drawCornerBorder(
        canvas, cutOutRect, borderPaint, borderRadius, borderLength);
  }

  void _drawCornerBorder(Canvas canvas, Rect rect, Paint paint,
      double borderRadius, double borderLength) {
    final path = Path();

    // Top-left corner
    path.moveTo(rect.left, rect.top + borderRadius + borderLength);
    path.lineTo(rect.left, rect.top + borderRadius);
    path.quadraticBezierTo(
        rect.left, rect.top, rect.left + borderRadius, rect.top);
    path.lineTo(rect.left + borderRadius + borderLength, rect.top);

    // Top-right corner
    path.moveTo(rect.right - borderRadius - borderLength, rect.top);
    path.lineTo(rect.right - borderRadius, rect.top);
    path.quadraticBezierTo(
        rect.right, rect.top, rect.right, rect.top + borderRadius);
    path.lineTo(rect.right, rect.top + borderRadius + borderLength);

    // Bottom-right corner
    path.moveTo(rect.right, rect.bottom - borderRadius - borderLength);
    path.lineTo(rect.right, rect.bottom - borderRadius);
    path.quadraticBezierTo(
        rect.right, rect.bottom, rect.right - borderRadius, rect.bottom);
    path.lineTo(rect.right - borderRadius - borderLength, rect.bottom);

    // Bottom-left corner
    path.moveTo(rect.left + borderRadius + borderLength, rect.bottom);
    path.lineTo(rect.left + borderRadius, rect.bottom);
    path.quadraticBezierTo(
        rect.left, rect.bottom, rect.left, rect.bottom - borderRadius);
    path.lineTo(rect.left, rect.bottom - borderRadius - borderLength);

    canvas.drawPath(path, paint);
  }

  Rect _getScannerRect(Rect rect) {
    final scannerSize = cutOutSize;
    final scannerLeft = rect.center.dx - scannerSize / 2;
    final scannerTop = rect.center.dy - scannerSize / 2;
    return Rect.fromLTWH(scannerLeft, scannerTop, scannerSize, scannerSize);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}

// Usage tetap sama:
/*
GestureDetector(
  onTap: () async {
    String? scannedResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerPage()
      ),
    );
    if (scannedResult != null) {
      _tableNumberController.text = scannedResult;
    }
  },
  child: Container(
    // ... same container code
  ),
)
*/

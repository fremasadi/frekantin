import 'package:e_kantin/core/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with TickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController(
    // Optimized settings for better detection
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
    returnImage: false,
    // Enable auto focus for better clarity
    autoStart: true,
    formats: [BarcodeFormat.qrCode], // Focus only on QR codes
  );

  bool isScanned = false;
  bool isFlashOn = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Start camera when widget initializes
    _startCamera();
  }

  void _startCamera() async {
    try {
      await cameraController.start();
    } catch (e) {
      throw ('Error starting camera: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    try {
      await cameraController.toggleTorch();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    } catch (e) {
      throw ('Error toggling flash: $e');
    }
  }

  void _switchCamera() async {
    try {
      await cameraController.switchCamera();
    } catch (e) {
      throw ('Error switching camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Nomer Meja'),
        backgroundColor: AppColors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: isFlashOn ? Colors.yellow : Colors.grey,
            ),
            iconSize: 28.0,
            onPressed: _toggleFlash,
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.grey),
            iconSize: 28.0,
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full screen camera
          MobileScanner(
            controller: cameraController,
            fit: BoxFit.cover,
            onDetect: (BarcodeCapture barcodeCapture) {
              if (!isScanned && mounted) {
                final List<Barcode> barcodes = barcodeCapture.barcodes;

                for (final barcode in barcodes) {
                  final String? code = barcode.rawValue;
                  if (code != null && code.isNotEmpty) {
                    setState(() {
                      isScanned = true;
                    });

                    // Haptic feedback for better UX
                    HapticFeedback.lightImpact();

                    // Show success dialog
                    _showSuccessDialog(context, code);
                    break;
                  }
                }
              }
            },
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Camera Error: ${error.toString()}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _startCamera(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          ),
          // Full screen overlay with cutout
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Colors.green,
                borderRadius: 12,
                borderLength: 40,
                borderWidth: 4,
                cutOutSize: 280,
                overlayColor: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
          // Add scanning animation
          if (!isScanned) _buildScanningAnimation(),
          // Bottom instruction panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 32,
                      color: Colors.green,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Arahkan kamera ke QR Code yang pada meja anda saat ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningAnimation() {
    return Positioned.fill(
      child: Center(
        child: SizedBox(
          width: 280.w,
          height: 280.h,
          child: Stack(
            children: [
              // Animated scanning line
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    top: (280 * _animationController.value),
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 2,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.green,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              SizedBox(width: 8),
              Text('Berhasil!'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('QR Code berhasil dipindai'),
              // const SizedBox(height: 8),
              // Container(
              //   padding: const EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     color: Colors.grey[100],
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Text(
              //     code,
              //     style: const TextStyle(
              //       fontWeight: FontWeight.bold,
              //       fontFamily: 'monospace',
              //     ),
              //   ),
              // ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(code); // Return with result
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Enhanced overlay shape with better visibility
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.green,
    this.borderWidth = 4.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 178),
    this.borderRadius = 12,
    this.borderLength = 40,
    this.cutOutSize = 280,
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
    final height = rect.height;
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
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round; // Rounded caps for better look

    final backgroundPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(
          RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)));

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw enhanced corner borders with glow effect
    _drawCornerBorder(
        canvas, cutOutRect, borderPaint, borderRadius, borderLength);

    // Add subtle glow effect
    final glowPaint = Paint()
      ..color = borderColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 2
      ..strokeCap = StrokeCap.round;

    _drawCornerBorder(
        canvas, cutOutRect, glowPaint, borderRadius, borderLength);
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
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutSize: cutOutSize,
    );
  }
}

// Usage example with enhanced UI:
/*
GestureDetector(
  onTap: () async {
    // Show loading indicator while opening scanner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Small delay to show loading
    await Future.delayed(const Duration(milliseconds: 300));
    Navigator.pop(context); // Close loading

    String? scannedResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerPage(),
      ),
    );

    if (scannedResult != null && scannedResult.isNotEmpty) {
      _tableNumberController.text = scannedResult;
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meja $scannedResult berhasil dipilih'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  },
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0), // Increased radius
      border: Border.all(
        color: _tableNumberController.text.isEmpty
            ? Colors.grey.withOpacity(0.3)
            : Colors.green.withOpacity(0.5),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((255 * 0.1).toInt()),
          blurRadius: 8.0,
          spreadRadius: 0.0,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _tableNumberController.text.isEmpty
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: 24,
              color: _tableNumberController.text.isEmpty
                  ? Colors.grey
                  : Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tableNumberController.text.isEmpty
                      ? 'Scan QR Code Meja'
                      : 'Meja ${_tableNumberController.text}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _tableNumberController.text.isEmpty
                        ? Colors.grey[600]
                        : Colors.black87,
                  ),
                ),
                if (_tableNumberController.text.isEmpty)
                  Text(
                    'Tap untuk memindai',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    ),
  ),
),
*/

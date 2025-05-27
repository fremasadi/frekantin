import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QrisPaymentPage extends StatelessWidget {
  final dynamic response;

  const QrisPaymentPage({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final payment = response['payment'];
    return Scaffold(
      appBar: AppBar(title: const Text('Bayar dengan QRIS')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (payment['payment_qr_url'] != null)
              Image.network(payment['payment_qr_url'], width: 200),
            const SizedBox(height: 20),
            if (payment['payment_deeplink'] != null)
              ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse(payment['payment_deeplink']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Tidak dapat membuka aplikasi')),
                    );
                  }
                },
                child: const Text("Bayar via Aplikasi"),
              ),
          ],
        ),
      ),
    );
  }
}

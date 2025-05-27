import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GopayPaymentPage extends StatelessWidget {
  final dynamic response;

  const GopayPaymentPage({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final payment = response['payment'];
    return Scaffold(
      appBar: AppBar(title: const Text('Bayar dengan GoPay')),
      body: Center(
        child: Column(
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
                  }
                },
                child: const Text("Bayar via Aplikasi GoPay"),
              )
          ],
        ),
      ),
    );
  }
}

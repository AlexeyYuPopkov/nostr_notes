// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class LightningInvoiceQrDialog extends StatelessWidget {
//   const LightningInvoiceQrDialog({super.key, required this.invoice});

//   final String invoice;

//   static Future<void> show(BuildContext context, String invoice) {
//     return showDialog<void>(
//       context: context,
//       builder: (_) => LightningInvoiceQrDialog(invoice: invoice),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       // title: const Text('Scan with Lightning wallet'),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text('Scan with Lightning wallet'),
//           QrImageView(data: 'lightning:$invoice', size: 240),
//           const SizedBox(height: 16),
//           Text(
//             'Open your Lightning wallet and scan the QR code',
//             style: Theme.of(context).textTheme.bodySmall,
//             textAlign: TextAlign.center,
//           ),
//           Row(
//             children: [
//               TextButton.icon(
//                 onPressed: () async {
//                   await Clipboard.setData(ClipboardData(text: invoice));
//                   if (context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Invoice copied to clipboard'),
//                       ),
//                     );
//                   }
//                 },
//                 icon: const Icon(Icons.copy, size: 18),
//                 label: const Text('Copy invoice'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Close'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

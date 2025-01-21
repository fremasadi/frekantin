// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
//
// extension ScrollControllerVisibility on ScrollController {
//   /// Mengatur visibilitas navbar berdasarkan arah scroll.
//   void handleVisibilityOnScroll(Function(bool) setVisible) {
//     Timer? scrollTimer;
//
//     this.addListener(() {
//       if (this.position.userScrollDirection == ScrollDirection.reverse) {
//         setVisible(false); // Sembunyikan navbar
//       } else if (this.position.userScrollDirection == ScrollDirection.forward) {
//         setVisible(true); // Tampilkan navbar
//       }
//
//       // Reset timer setiap kali ada scroll
//       if (scrollTimer != null) {
//         scrollTimer?.cancel();
//       }
//
//       // Set timer untuk 2 detik
//       scrollTimer = Timer(const Duration(seconds: 1), () {
//         setVisible(true); // Tampilkan kembali navbar jika scroll berhenti
//       });
//     });
//
//     // Dispose timer saat tidak digunakan lagi
//     void dispose() {
//       scrollTimer?.cancel();
//     }
//   }
// }

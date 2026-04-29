// import 'package:flutter/material.dart';


// // Data model for reports
// class Report {
//   final String time;
//   final String location;
//   final String status;
//   final Color statusColor;
//   final String description;

//   Report({
//     required this.time,
//     required this.location,
//     required this.status,
//     required this.statusColor,
//     required this.description,
//   });
// }

// class ReportsListScreen extends StatelessWidget {
//   const ReportsListScreen({super.key});

//   // Sample reports data
//   List<Report> get reports => [
//         Report(
//           time: '3 days ago',
//           location: 'Giza',
//           status: 'Needs help',
//           statusColor: Colors.red,
//           description:
//               'Broken leg, deep wounds, or severe infection. Needs immediate veterinary care and urgent support.',
//         ),
//         Report(
//           time: '5 days ago',
//           location: 'Maadi',
//           status: 'Undercare',
//           statusColor: Colors.orange,
//           description:
//               'Recovering from surgery, injury, or skin disease. Receiving treatment and regular follow-up.',
//         ),
//         Report(
//           time: '5 hours ago',
//           location: 'Giza',
//           status: 'Rescued',
//           statusColor: Colors.green,
//           description:
//               'Recovered from injury or illness (e.g., healed fracture or treated infection). Now safe and stable.',
//         ),
//       ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           // Purple slanted background
//           Positioned.fill(child: CustomPaint(painter: BackgroundPainter())),

//           // Main content
//           SafeArea(
//             child: Column(
//               children: [
//                 _buildHeader(context),
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(20, 40, 20, 80),
//                     itemCount: reports.length,
//                     itemBuilder: (context, index) {
//                       final report = reports[index];
//                       return ReportItem(report: report);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Decorative icons
//           const Positioned(
//             top: 10,
//             right: 20,
//             child: SafeArea(
//               child: Icon(Icons.pets, color: Colors.white70, size: 35),
//             ),
//           ),
//           const Positioned(
//             bottom: 25,
//             right: 20,
//             child: Icon(Icons.pets, color: Colors.white, size: 45),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.white,
//             radius: 18,
//             child: IconButton(
//               padding: EdgeInsets.zero,
//               icon: const Icon(Icons.arrow_back_ios_new,
//                   size: 18, color: Color(0xFF4A148C)),
//               tooltip: 'Go back',
//               onPressed: () => Navigator.of(context).maybePop(),
//             ),
//           ),
//           const SizedBox(width: 20),
//           const Text(
//             'Reports',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Widget for individual report cards
// class ReportItem extends StatelessWidget {
//   final Report report;

//   const ReportItem({super.key, required this.report});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // Gray container card
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE0E0E0),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(color: Colors.grey.shade500, width: 2),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Placeholder for animal image
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Container(
//                           width: 85,
//                           height: 65,
//                           color: Colors.grey.shade400,
//                           child: const Icon(Icons.image, color: Colors.white),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       // Description text
//                       Expanded(
//                         child: Text(
//                           report.description,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   // Footer info
//                   Text(
//                     '${report.time}, ${report.location}',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontStyle: FontStyle.italic,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Floating status badge
//             Positioned(
//               top: -12,
//               right: 10,
//               child: Chip(
//                 label: Text(
//                   report.status,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13,
//                   ),
//                 ),
//                 backgroundColor: report.statusColor,
//                 elevation: 4,
//               ),
//             ),
//           ],
//         ),
//         // Donate button
//         Padding(
//           padding: const EdgeInsets.only(top: 8, bottom: 30),
//           child: SizedBox(
//             height: 30,
//             child: ElevatedButton(
//               onPressed: () {
//                 // Donation logic here
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFE0E0E0),
//                 foregroundColor: Colors.black,
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 25),
//               ),
//               child: const Text(
//                 'Donate Now',
//                 style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Painter for purple slanted background
// class BackgroundPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFF4A148C)
//       ..style = PaintingStyle.fill;

//     // Top slant
//     var pathTop = Path();
//     pathTop.lineTo(0, size.height * 0.22);
//     pathTop.lineTo(size.width, size.height * 0.08);
//     pathTop.lineTo(size.width, 0);
//     pathTop.close();
//     canvas.drawPath(pathTop, paint);

//     // Bottom slant
//     var pathBottom = Path();
//     pathBottom.moveTo(0, size.height);
//     pathBottom.lineTo(size.width, size.height);
//     pathBottom.lineTo(size.width, size.height * 0.82);
//     pathBottom.lineTo(0, size.height * 0.98);
//     pathBottom.close();
//     canvas.drawPath(pathBottom, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

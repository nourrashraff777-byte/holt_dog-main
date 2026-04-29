import 'dart:io';
import 'dart:math' as math; // المسافات بين اليوزر والعيادات
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

// =================================================================
// 1. role definitions
// =================================================================
enum UserRole { USER, DOCTOR, CHARITY, RETAILER, INSURANCE }

// =================================================================
// 2. (Entities / Models)
// =================================================================

class UserEntity {
  final String uid;
  final String email;
  final String name;
  final String role;
  final bool isSubscribed;
  final DateTime createdAt;

  UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.isSubscribed = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'name': name,
        'role': role,
        'isSubscribed': isSubscribed,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class ScanRecordEntity {
  final String? userId;
  final String imageUrl;
  final String? imageHash;
  final String disease;
  final double confidence;
  final bool isDog;
  final String mood;
  final GeoPoint location;
  final String address;
  final String status;
  final DateTime timestamp;

  ScanRecordEntity({
    this.userId,
    required this.imageUrl,
    this.imageHash,
    required this.disease,
    required this.confidence,
    required this.isDog,
    required this.mood,
    required this.location,
    required this.address,
    this.status = 'Need Help',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'imageUrl': imageUrl,
        'imageHash': imageHash,
        'analysis': {
          'disease': disease,
          'confidence': confidence,
          'isDog': isDog,
          'mood': mood,
        },
        'location': location,
        'address': address,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      };
}

class OrderEntity {
  final String buyerId;
  final String retailerId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  OrderEntity({
    required this.buyerId,
    required this.retailerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'buyerId': buyerId,
        'retailerId': retailerId,
        'items': items,
        'totalAmount': totalAmount,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

// =================================================================
// 3. (Database Service)
// =================================================================

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Dio _dio = Dio();

  final String _cloudName = "dk7um4nir";
  final String _uploadPreset = "url_default";

  // --- [ تسجيل مستخدم جديد ] ---
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    Map<String, dynamic>? extraProfileData,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserEntity newUser = UserEntity(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: role.name,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(newUser.uid).set({
        ...newUser.toMap(),
        if (extraProfileData != null) 'extraData': extraProfileData,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- [ تسجيل الدخول وجلب الرول ] ---
  Future<String?> loginAndGetRole(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      DocumentSnapshot doc =
          await _db.collection('users').doc(userCredential.user!.uid).get();
      return doc.exists ? doc.get('role') as String : null;
    } catch (e) {
      return null;
    }
  }

  // --- [ AI ] ---
  Future<void> saveAiScanResult({
    required String imageUrl,
    required String? imageHash,
    required String disease,
    required double confidence,
    required bool isDog,
    required String mood,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    ScanRecordEntity scan = ScanRecordEntity(
      userId: _auth.currentUser?.uid,
      imageUrl: imageUrl,
      imageHash: imageHash,
      disease: disease,
      confidence: confidence,
      isDog: isDog,
      mood: mood,
      location: GeoPoint(latitude, longitude),
      address: address,
      timestamp: DateTime.now(),
    );
    await _db.collection('scans').add(scan.toMap());
  }

  // --- [ Nearby Logic ] ---

  Stream<List<Map<String, dynamic>>> getNearbyProviders({
    required double userLat,
    required double userLon,
    required String targetRole, //
    double radiusInKm = 50.0, //
  }) {
    return _db
        .collection('users')
        .where('role', isEqualTo: targetRole)
        .snapshots()
        .map((snapshot) {
      List<Map<String, dynamic>> providers = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();

        double? providerLat;
        double? providerLon;

        if (data.containsKey('lat') && data['lat'] != null) {
          providerLat = double.tryParse(data['lat'].toString());
          providerLon = double.tryParse(data['lng'].toString());
        } else if (data.containsKey('location')) {
          GeoPoint point = data['location'];
          providerLat = point.latitude;
          providerLon = point.longitude;
        }

        if (providerLat != null && providerLon != null) {
          double distance = _calculateDistanceInKm(
            userLat,
            userLon,
            providerLat,
            providerLon,
          );

          if (distance <= radiusInKm) {
            data['distance'] = distance;
            data['id'] = doc.id;
            providers.add(data);
          }
        }
      }

      // ترتيب النتائج من الأقرب للأبعد
      providers.sort((a, b) => a['distance'].compareTo(b['distance']));
      return providers;
    });
  }

  double _calculateDistanceInKm(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  // --- [ Retailer Logic ] ---

  Future<void> addProduct({
    required String name,
    required String price,
    required String imageUrl,
    required String category,
  }) async {
    await _db.collection('products').add({
      'retailerId': _auth.currentUser!.uid,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'inStock': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMyProducts() {
    return _db
        .collection('products')
        .where('retailerId', isEqualTo: _auth.currentUser?.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getRetailerOrders() {
    return _db
        .collection('orders')
        .where('retailerId', isEqualTo: _auth.currentUser?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({'status': newStatus});
  }

  // --- [ الصور وتسجيل الخروج ] ---
  Future<String?> uploadImage(File imageFile) async {
    try {
      String url = "https://api.cloudinary.com/v1_1/$_cloudName/image/upload";
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path),
        "upload_preset": _uploadPreset,
      });
      Response res = await _dio.post(url, data: formData);
      return res.statusCode == 200 ? res.data['secure_url'] : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async => await _auth.signOut();
}

// =================================================================
// 4. (Dynamic Home Wrapper & Screens)
// =================================================================

class DynamicHomeWrapper extends StatelessWidget {
  final String role;
  const DynamicHomeWrapper({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case 'DOCTOR':
        return const DoctorDashboard();
      case 'CHARITY':
        return const CharityDashboard();
      case 'RETAILER':
        return const RetailerShopScreen();
      case 'INSURANCE':
        return const InsuranceAnalytics();
      case 'USER':
      default:
        return const UserHomeScreen();
    }
  }
}

class RetailerShopScreen extends StatelessWidget {
  const RetailerShopScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Retailer Panel")),
      body: Column(
        children: [
          const ListTile(title: Text("Order Overview & Activity")),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child:
                  const Center(child: Text("هنا بتظهر الأوردرات و المنتجات")),
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text("Doctor Emergency Calls Screen")));
}

class CharityDashboard extends StatelessWidget {
  const CharityDashboard({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
      body: Center(child: Text("Charity Rescue & Funds Screen")));
}

class InsuranceAnalytics extends StatelessWidget {
  const InsuranceAnalytics({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Insurance Claims Screen")));
}

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("User Pet Care Screen")));
}

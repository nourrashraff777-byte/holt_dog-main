import '../../features/user_side/user_home/models/vet_model.dart';
import '../../features/user_side/user_home/models/shelter_model.dart';
import '../../features/user_side/user_home/models/report_model.dart';

class FirestoreService {
  // FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Generic method to add data to a collection
  Future<void> addData(String collection, Map<String, dynamic> data) async {
    // try {
    //   await _db.collection(collection).add(data);
    // } catch (e) {
    //   debugPrint('Firestore Add Error: $e');
    // }
  }

  // Get stream of Vets
  Stream<List<Vet>> getVets() {
    // return _db.collection('vets').snapshots().map((snapshot) {
    //   return snapshot.docs.map((doc) => Vet.fromMap(doc.data(), doc.id)).toList();
    // });
    return const Stream.empty();
  }

  // Get stream of Shelters
  Stream<List<Shelter>> getShelters() {
    // return _db.collection('shelters').snapshots().map((snapshot) {
    //   return snapshot.docs.map((doc) => Shelter.fromMap(doc.data(), doc.id)).toList();
    // });
    return const Stream.empty();
  }

  // Get stream of Reports
  Stream<List<Report>> getReports() {
    // return _db.collection('reports').orderBy('date', descending: true).snapshots().map((snapshot) {
    //   return snapshot.docs.map((doc) => Report.fromMap(doc.data(), doc.id)).toList();
    // });
    return const Stream.empty();
  }

  // Method to update a document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    // try {
    //   await _db.collection(collection).doc(docId).update(data);
    // } catch (e) {
    //   debugPrint('Firestore Update Error: $e');
    // }
  }
}

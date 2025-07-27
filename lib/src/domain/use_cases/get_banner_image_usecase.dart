import 'package:cloud_firestore/cloud_firestore.dart';

class GetCarouselImagesUseCase {
  Future<List<String>> call() async {
    final snapshot = await FirebaseFirestore.instance.collection('websiteBuilder').get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data();
      if (data['courouselImages'] != null) {
        return List<String>.from(data['courouselImages']);
      }
    }
    return [];
  }
}

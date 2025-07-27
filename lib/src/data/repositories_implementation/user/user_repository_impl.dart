import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/repositories/user/user_repository.dart';

import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore firestore;

  UserRepositoryImpl({required this.firestore});

  @override
  Future<Either<String, UserModel>> fetchUser(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return Left('User not found');
      }
      return Right(UserModel.fromJson(doc.data()!));
    } catch (e) {
      return Left('Error fetching user: ${e.toString()}');
    }
  }

  ///fetch user by phone number
  @override
  Future<Either<String, UserModel>> fetchUserByPhoneNumber(
    String phoneNumber,
  ) async {
    try {
      final querySnapshot =
          await firestore
              .collection('users')
              .where('phone', isEqualTo: phoneNumber)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return Left('User not found');
      }

      final userDoc = querySnapshot.docs.first;
      return Right(UserModel.fromJson(userDoc.data()));
    } catch (e) {
      return Left('Error fetching user: ${e.toString()}');
    }
  }

  ///add user
  @override
  Future<Either<String, UserModel>> addUser(UserModel userModel) async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final docRef = await firestore
          .collection('users')
          .doc(firebaseAuth.currentUser?.uid)
          .set(userModel.toJson());
      final doc =
          await firestore
              .collection('users')
              .doc(firebaseAuth.currentUser?.uid)
              .get();

      /// Check if the document exists and for null also
      if (!doc.exists || doc.data() == null) {
        return Left('User not found');
      }
      return Right(UserModel.fromJson(doc.data()!));
    } catch (e) {
      return Left('Error adding user: ${e.toString()}');
    }
  }
}

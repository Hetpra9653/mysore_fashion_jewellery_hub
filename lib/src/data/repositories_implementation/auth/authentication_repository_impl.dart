import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';

import '../../../domain/repositories/auth/authentication_repository.dart';
import '../../dependencyInjector/dependency_injector.dart';
import '../../entity/user_session.dart';

class AuthenticationRepositoryImplement implements AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserSession _userSession = sl<UserSession>();
  String _verificationId = '';

  @override
  Future<Either<String, void>> verifyPhoneNumber(String phoneNumber) async {
    try {
      final completer = Completer<Either<String, void>>();

      await _auth.verifyPhoneNumber(
        timeout: const Duration(seconds: 60),
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          log("Verification completed automatically");
          try {
            await _auth.signInWithCredential(credential);
            if (!completer.isCompleted) {
              completer.complete(const Right(null));
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.complete(Left(e.toString()));
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          log("Verification failed: ${e.message}");
          if (!completer.isCompleted) {
            completer.complete(Left(e.message ?? 'Verification failed'));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          log("Verification code sent to $phoneNumber");
          if (!completer.isCompleted) {
            completer.complete(const Right(null));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log("Auto retrieval timeout for $verificationId");
          // Only complete if it hasn't been completed by one of the other callbacks
          if (!completer.isCompleted) {
            completer.complete(const Right(null));
          }
        },
      );

      return completer.future;
    } catch (e) {
      log("Error in verifyPhoneNumber: $e");
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> verifyOTPCode(String smsCode) async {
    try {
      if (_verificationId.isEmpty) {
        return const Left(
          'Verification ID not found. Please request OTP first.',
        );
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        log(
          "Phone authentication successful for user: ${userCredential.user!.uid}",
        );
        // You might want to store user information in UserSession here
        return const Right(null);
      } else {
        return const Left('Failed to authenticate user');
      }
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth Exception in verifyOTPCode: ${e.message}");
      return Left(e.message ?? 'Authentication failed');
    } catch (e) {
      log("Error in verifyOTPCode: $e");
      return Left(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Clear any user session data if needed
      log("User signed out successfully");
    } catch (e) {
      log("Error signing out: $e");
      rethrow;
    }
  }
}

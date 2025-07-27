import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/entity/user_session.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/auth/verify_number_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/auth/verify_otp_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/user/fetch_user_by_phone_number_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_event.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_state.dart';

import '../../../data/dependencyInjector/dependency_injector.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final VerifyPhoneUseCase verifyPhoneUseCase;
  final VerifyOTPUseCase verifyOTPUseCase;
  final FetchUserByPhoneNumberUseCase fetchUserByPhoneNumberUseCase;

  AuthenticationBloc({
    required this.verifyPhoneUseCase,
    required this.verifyOTPUseCase,
    required this.fetchUserByPhoneNumberUseCase,
  }) : super(AuthenticationInitial()) {
    on<VerifyPhoneNumberEvent>(_verifyPhoneNumberEvent);
    on<VerifyOTPCodeEvent>(_verifyOtpCodeEvent);
  }

  Future<void> _verifyPhoneNumberEvent(
    VerifyPhoneNumberEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoadingState());
    try {
      if (event.isFromLogin) {
        final userResult = await fetchUserByPhoneNumberUseCase.call(
          event.phoneNumber,
        );

        if (userResult.isRight()) {
          final result = await verifyPhoneUseCase.call(event.phoneNumber);
          result.fold(
            (error) {
              return emit(PhoneAuthenticationFailureState(error));
            },

            (_) {
              // Right case - success
              return emit(
                PhoneNumberVerifiedState(phoneNumber: event.phoneNumber),
              );
            },
          );
        } else {
          // User does not exist
          emit(UserNotExistsState(phoneNumber: event.phoneNumber));
        }
      } else {
        final result = await verifyPhoneUseCase.call(event.phoneNumber);
        result.fold(
          (error) {
            return emit(PhoneAuthenticationFailureState(error));
          },

          (_) {
            // Right case - success
            return emit(
              PhoneNumberVerifiedState(phoneNumber: event.phoneNumber),
            );
          },
        );
      }
    } catch (e) {
      emit(PhoneAuthenticationFailureState('An unexpected error occurred'));
    }
  }

  Future<void> _verifyOtpCodeEvent(
    VerifyOTPCodeEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoadingState());
    try {
      final result = await verifyOTPUseCase.call(event.smsCode);

      result.fold(
        (errorMessage) {
          // Left case - error occurred
          emit(PhoneAuthenticationFailureState(errorMessage));
        },
        (_) {
          // Right case - success
          if (event.isFromLogin) {
            emit(
              PhoneAuthenticationSuccessState(
                phoneNumber: event.phoneNumber,
                isFromLogin: event.isFromLogin,
              ),
            );
          } else {
            final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

            final UserSession userSession = sl<UserSession>();
            userSession.setUserId(firebaseAuth.currentUser?.uid ?? '');

            emit(
              PhoneAuthenticationSuccessState(
                phoneNumber: event.phoneNumber,
                isFromLogin: event.isFromLogin,
                userModel: userSession.user,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(PhoneAuthenticationFailureState('An unexpected error occurred'));
    }
  }
}

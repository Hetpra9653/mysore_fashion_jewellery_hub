import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/models/user_model.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/user/add_user_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/user/user_event.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/user/user_state.dart';

import '../../../domain/use_cases/user/fetch_user_usecase.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FetchUserUseCase fetchUserUseCase;
  final AddUserUseCase addUserUseCase;

  UserBloc({required this.fetchUserUseCase, required this.addUserUseCase})
    : super(UserInitialState()) {
    on<FetchUserEvent>(_fetchUserEvent);
    on<AddUserEvent>(_addUserEvent);

  }

  Future<void> _fetchUserEvent(
    FetchUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoadingState());
    final result = await fetchUserUseCase.call(event.userId);

    result.fold(
      (failure) => emit(UserErrorState(failure)),
      (user) => emit(UserLoadedState(user)),
    );
  }

  /// add user
  Future<void> _addUserEvent(
    AddUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoadingState());
    final result = await addUserUseCase.call(event.userModel);

    return result.fold(
      (error) => emit(UserErrorState(error)),
      (user) => emit(UserAddedState(user)),
    );
  }
}

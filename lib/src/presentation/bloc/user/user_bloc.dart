import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  UserBloc({required this.fetchUserUseCase, required this.addUserUseCase})
    : super(UserInitialState()) {
    on<FetchUserEvent>(_fetchUserEvent);
    on<AddUserEvent>(_addUserEvent);
    on<AddAddressEvent>(_addAddressEvent);
    on<EditAddressEvent>(_editAddressEvent);
    on<DeleteAddressEvent>(_deleteAddressEvent);
    on<FetchAddressesEvent>(_fetchAddressesEvent);

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


  Future<void> _addAddressEvent(AddAddressEvent event, Emitter<UserState> emit) async {
    if (state is UserLoadedState) {
      emit(UserLoadingState());
      try {
        final currentUser = (state as UserLoadedState).user;

        // Add new address to the list
        final List<AddressModel> updatedAddresses = List.from(currentUser.addresses ?? []);

        // If new address is default, set all others isPrimary to false
        if(event.makeDefault) {
          for(var i=0; i<updatedAddresses.length; i++){
            updatedAddresses[i] = AddressModel(
              addressID: updatedAddresses[i].addressID,
              label: updatedAddresses[i].label,
              phoneNumber: updatedAddresses[i].phoneNumber,
              street: updatedAddresses[i].street,
              city: updatedAddresses[i].city,
              state: updatedAddresses[i].state,
              postalCode: updatedAddresses[i].postalCode,
              isPrimary: false,
            );
          }
        }

        final newAddress = event.makeDefault
            ? AddressModel(
          addressID: event.newAddress.addressID,
          label: event.newAddress.label,
          phoneNumber: event.newAddress.phoneNumber,
          street: event.newAddress.street,
          city: event.newAddress.city,
          state: event.newAddress.state,
          postalCode: event.newAddress.postalCode,
          isPrimary: true,
        )
            : event.newAddress;

        updatedAddresses.add(newAddress);

        final updatedUser = currentUser.copyWith(addresses: updatedAddresses);

        // You should call useCase method that updates user with new address list
        final result = await addUserUseCase.call(updatedUser);

        result.fold(
              (error) => emit(UserErrorState(error)),
              (user) => emit(UserLoadedState(user)),
        );
      } catch (e) {
        emit(UserErrorState(e.toString()));
      }
    }
  }

  Future<void> _editAddressEvent(EditAddressEvent event, Emitter<UserState> emit) async {
    if (state is UserLoadedState) {
      emit(UserLoadingState());
      try {
        final currentUser = (state as UserLoadedState).user;
        final List<AddressModel> updatedAddresses = List.from(currentUser.addresses ?? []);

        if (event.makeDefault) {
          for (int i = 0; i < updatedAddresses.length; i++) {
            final isCurrent = updatedAddresses[i].addressID == event.updatedAddress.addressID;
            updatedAddresses[i] = AddressModel(
              addressID: updatedAddresses[i].addressID,
              label: isCurrent ? event.updatedAddress.label : updatedAddresses[i].label,
              phoneNumber: isCurrent ? event.updatedAddress.phoneNumber : updatedAddresses[i].phoneNumber,
              street: isCurrent ? event.updatedAddress.street : updatedAddresses[i].street,
              city: isCurrent ? event.updatedAddress.city : updatedAddresses[i].city,
              state: isCurrent ? event.updatedAddress.state : updatedAddresses[i].state,
              postalCode: isCurrent ? event.updatedAddress.postalCode : updatedAddresses[i].postalCode,
              isPrimary: isCurrent,
            );
            if (!isCurrent) {
              updatedAddresses[i] = AddressModel(
                addressID: updatedAddresses[i].addressID,
                label: updatedAddresses[i].label,
                phoneNumber: updatedAddresses[i].phoneNumber,
                street: updatedAddresses[i].street,
                city: updatedAddresses[i].city,
                state: updatedAddresses[i].state,
                postalCode: updatedAddresses[i].postalCode,
                isPrimary: false,
              );
            }
          }
        } else {
          // Just update matching address without changing others' isPrimary
          for (int i = 0; i < updatedAddresses.length; i++) {
            if (updatedAddresses[i].addressID == event.updatedAddress.addressID) {
              updatedAddresses[i] = event.updatedAddress;
            }
          }
        }

        final updatedUser = currentUser.copyWith(addresses: updatedAddresses);

        final result = await addUserUseCase.call(updatedUser);

        result.fold(
              (error) => emit(UserErrorState(error)),
              (user) => emit(UserLoadedState(user)),
        );
      } catch (e) {
        emit(UserErrorState(e.toString()));
      }
    }
  }

  Future<void> _deleteAddressEvent(DeleteAddressEvent event, Emitter<UserState> emit) async {
    if (state is UserLoadedState) {
      emit(UserLoadingState());
      try {
        final currentUser = (state as UserLoadedState).user;
        final updatedAddresses = (currentUser.addresses ?? [])
            .where((address) => address.addressID != event.addressId)
            .toList();

        final updatedUser = currentUser.copyWith(addresses: updatedAddresses);

        final result = await addUserUseCase.call(updatedUser);

        result.fold(
                (error) => emit(UserErrorState(error)),
                (user) => emit(UserLoadedState(user))
        );
      } catch (e) {
        emit(UserErrorState(e.toString()));
      }
    }
  }

  Future<void> _fetchAddressesEvent(
      FetchAddressesEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());

    try {
      final userDoc =
      await _firestore.collection('users').doc(event.userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;

        List<AddressModel> addresses = [];
        if (userData.containsKey('addresses') && userData['addresses'] is List) {
          List<dynamic> rawAddresses = userData['addresses'];
          addresses = rawAddresses
              .map((addrJson) => AddressModel.fromJson(addrJson))
              .toList();
        }

        final userModel = UserModel.fromJson(userData);
        emit(UserLoadedState(userModel));
      } else {
        emit(UserErrorState('No user data found'));
      }
    } catch (e) {
      emit(UserErrorState('Failed to fetch addresses: ${e.toString()}'));
    }
  }
}


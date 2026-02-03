import 'package:dartz/dartz.dart';
import 'package:collection/collection.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../datasources/payment_method_local_data_source.dart';
import '../datasources/payment_method_remote_data_source.dart';
import '../models/payment_method_model.dart';

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final PaymentMethodLocalDataSource localDataSource;
  final PaymentMethodRemoteDataSource? remoteDataSource;
  final NetworkInfo networkInfo;

  PaymentMethodRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods() async {
    try {
      // Try to fetch from remote API first
      if (remoteDataSource != null && await networkInfo.isConnected) {
        try {
          final remoteMethods = await remoteDataSource!.getPaymentMethods();
          
          // Load default preference from local storage
          final localMethods = await localDataSource.getPaymentMethods();
          final defaultMethodId = localMethods
              .where((m) => m.isDefault)
              .map((m) => m.id)
              .firstOrNull;
          
          // Apply default preference to remote methods
          final methodsWithDefault = remoteMethods.map((method) {
            final isDefault = defaultMethodId != null && method.id == defaultMethodId;
            return PaymentMethodModel(
              id: method.id,
              name: method.name,
              type: method.type,
              isDefault: isDefault,
              createdAt: method.createdAt,
            );
          }).toList();
          
          // Check if the saved default exists in API response
          final defaultExists = defaultMethodId != null && 
              methodsWithDefault.any((m) => m.id == defaultMethodId);
          
          // If no default was set or saved default doesn't exist, make the first one default
          if ((defaultMethodId == null || !defaultExists) && methodsWithDefault.isNotEmpty) {
            // Clear any existing defaults first
            for (int i = 0; i < methodsWithDefault.length; i++) {
              methodsWithDefault[i] = PaymentMethodModel(
                id: methodsWithDefault[i].id,
                name: methodsWithDefault[i].name,
                type: methodsWithDefault[i].type,
                isDefault: false,
                createdAt: methodsWithDefault[i].createdAt,
              );
            }
            // Set first as default
            methodsWithDefault[0] = PaymentMethodModel(
              id: methodsWithDefault[0].id,
              name: methodsWithDefault[0].name,
              type: methodsWithDefault[0].type,
              isDefault: true,
              createdAt: methodsWithDefault[0].createdAt,
            );
          }
          
          return Right(methodsWithDefault);
        } catch (e) {
          // Fall back to local if remote fails
          final localMethods = await localDataSource.getPaymentMethods();
          if (localMethods.isNotEmpty) {
            return Right(localMethods);
          }
          return Left(ServerFailure('Failed to fetch payment methods: ${e.toString()}'));
        }
      }
      
      // Fall back to local storage if no remote or no connection
      final paymentMethods = await localDataSource.getPaymentMethods();
      return Right(paymentMethods);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod>> addPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      final paymentMethodModel = PaymentMethodModel.fromEntity(paymentMethod);
      final result = await localDataSource.addPaymentMethod(paymentMethodModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod>> updatePaymentMethod(PaymentMethod paymentMethod) async {
    try {
      final paymentMethodModel = PaymentMethodModel.fromEntity(paymentMethod);
      final result = await localDataSource.updatePaymentMethod(paymentMethodModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePaymentMethod(String id) async {
    try {
      final result = await localDataSource.deletePaymentMethod(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod>> setDefaultPaymentMethod(String id) async {
    try {
      // Try to set default in local storage
      // If method doesn't exist locally (e.g., it's from API), create a minimal entry
      try {
        final result = await localDataSource.setDefaultPaymentMethod(id);
        return Right(result);
      } catch (e) {
        // Method doesn't exist in local storage - need to create a minimal entry
        // First, remove default from all existing methods
        final localMethods = await localDataSource.getPaymentMethods();
        for (final method in localMethods) {
          if (method.isDefault && method.id != id) {
            await localDataSource.updatePaymentMethod(
              PaymentMethodModel.fromEntity(method.copyWith(isDefault: false)),
            );
          }
        }
        
        // Create a minimal entry for the API method with default=true
        final defaultMethod = PaymentMethodModel(
          id: id,
          name: 'Default Payment Method', // Placeholder name - will be replaced by API data on next fetch
          type: PaymentMethodType.creditCard, // Placeholder type - will be replaced by API data on next fetch
          isDefault: true,
          createdAt: DateTime.now(),
        );
        
        // Add the method to local storage
        await localDataSource.addPaymentMethod(defaultMethod);
        
        return Right(defaultMethod);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

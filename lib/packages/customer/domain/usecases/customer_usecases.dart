import '../entities/customer_entity.dart';
import '../entities/customer_loyalty_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;
  GetCustomersUseCase(this.repository);

  Future<List<CustomerEntity>> call({
    int limit = 20,
    int pageNumber = 1,
    String? search,
  }) async {
    return await repository.getCustomers(
      limit: limit,
      pageNumber: pageNumber,
      search: search,
    );
  }
}

class AddCustomerUseCase {
  final CustomerRepository repository;
  AddCustomerUseCase(this.repository);

  Future<int> call(CustomerEntity customer) async {
    return await repository.addCustomer(customer);
  }
}

class UpdateCustomerUseCase {
  final CustomerRepository repository;
  UpdateCustomerUseCase(this.repository);

  Future<bool> call(CustomerEntity customer) async {
    return await repository.updateCustomer(customer);
  }
}

class DeleteCustomerUseCase {
  final CustomerRepository repository;
  DeleteCustomerUseCase(this.repository);

  Future<bool> call(int id) async {
    return await repository.deleteCustomer(id);
  }
}

class GetCustomerLoyaltyUseCase {
  final CustomerRepository repository;
  GetCustomerLoyaltyUseCase(this.repository);

  Future<CustomerLoyaltyEntity?> call(int customerId) async {
    return await repository.getCustomerLoyalty(customerId);
  }
}

class AddLoyaltyPointsUseCase {
  final CustomerRepository repository;
  AddLoyaltyPointsUseCase(this.repository);

  Future<void> call({
    required int customerId,
    required int points,
    required double billAmount,
    int? orderId,
    int? invoiceId,
    String? notes,
  }) async {
    await repository.addLoyaltyPoints(
      customerId: customerId,
      points: points,
      billAmount: billAmount,
      orderId: orderId,
      invoiceId: invoiceId,
      notes: notes,
    );
  }
}

class RedeemLoyaltyPointsUseCase {
  final CustomerRepository repository;
  RedeemLoyaltyPointsUseCase(this.repository);

  Future<bool> call({
    required int customerId,
    required int pointsToRedeem,
    int? orderId,
    int? invoiceId,
  }) async {
    return await repository.redeemLoyaltyPoints(
      customerId: customerId,
      pointsToRedeem: pointsToRedeem,
      orderId: orderId,
      invoiceId: invoiceId,
    );
  }
}

class GetLoyaltyTransactionsUseCase {
  final CustomerRepository repository;
  GetLoyaltyTransactionsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(int customerId) async {
    return await repository.getLoyaltyTransactions(customerId);
  }
}

class UpdateCustomerTierUseCase {
  final CustomerRepository repository;
  UpdateCustomerTierUseCase(this.repository);

  Future<void> call({
    required int customerId,
    required String tier,
  }) async {
    await repository.updateCustomerTier(customerId: customerId, tier: tier);
  }
}


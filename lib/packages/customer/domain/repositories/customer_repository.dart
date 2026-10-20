import '../entities/customer_entity.dart';
import '../entities/customer_loyalty_entity.dart';

abstract class CustomerRepository {
  Future<List<CustomerEntity>> getCustomers({
    int limit = 20,
    int pageNumber = 1,
    String? search,
  });
  Future<CustomerEntity?> getCustomer(int id);
  Future<int> addCustomer(CustomerEntity customer);
  Future<bool> updateCustomer(CustomerEntity customer);
  Future<bool> deleteCustomer(int id);
  Future<CustomerLoyaltyEntity?> getCustomerLoyalty(int customerId);
  Future<void> addLoyaltyPoints({
    required int customerId,
    required int points,
    required double billAmount,
    int? orderId,
    int? invoiceId,
    String? notes,
  });
  Future<bool> redeemLoyaltyPoints({
    required int customerId,
    required int pointsToRedeem,
    int? orderId,
    int? invoiceId,
  });
  Future<List<Map<String, dynamic>>> getLoyaltyTransactions(int customerId);
  Future<void> updateCustomerTier({
    required int customerId,
    required String tier,
  });
}


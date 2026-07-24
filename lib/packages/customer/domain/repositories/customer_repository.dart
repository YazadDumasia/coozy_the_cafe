import '../entities/customer_entity.dart';

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
}

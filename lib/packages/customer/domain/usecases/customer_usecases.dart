import '../entities/customer_entity.dart';
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

import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import 'package:coozy_the_cafe/packages/database/src/database_dao/customers_dao.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomersDao _customersDao;

  CustomerRepositoryImpl(this._customersDao);

  CustomerEntity _mapToEntity(Customer customer) {
    return CustomerEntity(
      id: customer.id,
      hashId: customer.hashId,
      name: customer.name,
      phoneNumber: customer.phoneNumber,
      isoCode: customer.isoCode,
      createdDate: customer.createdDate,
    );
  }

  CustomersTableCompanion _mapToCompanion(CustomerEntity entity) {
    return CustomersTableCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      name: entity.name != null ? Value(entity.name) : const Value.absent(),
      phoneNumber: entity.phoneNumber != null
          ? Value(entity.phoneNumber)
          : const Value.absent(),
      isoCode: entity.isoCode != null
          ? Value(entity.isoCode)
          : const Value.absent(),
      createdDate: entity.createdDate != null
          ? Value(entity.createdDate)
          : const Value.absent(),
    );
  }

  @override
  Future<List<CustomerEntity>> getCustomers({
    int limit = 20,
    int pageNumber = 1,
    String? search,
  }) async {
    final results = await _customersDao.searchCustomers(
      limit: limit,
      pageNumber: pageNumber,
      search: search,
    );
    return results?.map(_mapToEntity).toList() ?? [];
  }

  @override
  Future<CustomerEntity?> getCustomer(int id) async {
    final customer = await _customersDao.getCustomer(id);
    return customer != null ? _mapToEntity(customer) : null;
  }

  @override
  Future<int> addCustomer(CustomerEntity customer) async {
    return await _customersDao.createCustomer(_mapToCompanion(customer));
  }

  @override
  Future<bool> updateCustomer(CustomerEntity customer) async {
    final result = await _customersDao.updateCustomer(
      _mapToCompanion(customer),
    );
    return result != null && result > 0;
  }

  @override
  Future<bool> deleteCustomer(int id) async {
    final result = await _customersDao.deleteCustomer(id);
    return result != null && result > 0;
  }
}

import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import 'package:coozy_the_cafe/packages/database/src/database_dao/customers_dao.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_loyalty_entity.dart';
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

  @override
  Future<CustomerLoyaltyEntity?> getCustomerLoyalty(int customerId) async {
    final map = await _customersDao.getCustomerLoyalty(customerId);
    if (map == null) return null;
    final rate = shared.LocalManager.instance
            .getDoubleValue(key: shared.PreferencesKeys.loyaltyPointsExchangeRate) ??
        0.50;
    return CustomerLoyaltyEntity.fromMap(map, exchangeRate: rate);
  }

  @override
  Future<void> addLoyaltyPoints({
    required int customerId,
    required int points,
    required double billAmount,
    int? orderId,
    int? invoiceId,
    String? notes,
  }) async {
    final defaultTier = shared.LocalManager.instance.getLocaleKeys(
          key: shared.PreferencesKeys.loyaltyDefaultTier,
        ) ??
        'Bronze';
    await _customersDao.addLoyaltyPoints(
      customerId: customerId,
      points: points,
      billAmount: billAmount,
      orderId: orderId,
      invoiceId: invoiceId,
      notes: notes,
      defaultTier: defaultTier.isNotEmpty ? defaultTier : 'Bronze',
    );
  }

  @override
  Future<bool> redeemLoyaltyPoints({
    required int customerId,
    required int pointsToRedeem,
    int? orderId,
    int? invoiceId,
  }) async {
    return await _customersDao.redeemLoyaltyPoints(
      customerId: customerId,
      pointsToRedeem: pointsToRedeem,
      orderId: orderId,
      invoiceId: invoiceId,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getLoyaltyTransactions(int customerId) async {
    return await _customersDao.getLoyaltyTransactions(customerId);
  }

  @override
  Future<void> updateCustomerTier({
    required int customerId,
    required String tier,
  }) async {
    await _customersDao.updateCustomerTier(customerId: customerId, tier: tier);
  }
}

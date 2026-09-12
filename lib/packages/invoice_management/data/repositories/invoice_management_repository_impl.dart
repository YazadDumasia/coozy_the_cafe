import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../../domain/entities/invoice_management_entity.dart';
import '../../domain/repositories/invoice_management_repository.dart';
import '../datasources/invoice_management_remote_datasource.dart';

class InvoiceManagementRepositoryImpl implements InvoiceManagementRepository {
  final InvoiceManagementRemoteDataSource remoteDataSource;

  InvoiceManagementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedInvoicesEntity>> getPaginatedInvoices({
    required int limit,
    required int pageNo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    List<String>? paymentMethods,
  }) async {
    try {
      final invoiceRows = await remoteDataSource.getPaginatedInvoices(
        limit: limit,
        pageNo: pageNo,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
        paymentMethods: paymentMethods,
      );

      final totalCount = await remoteDataSource.getInvoicesCount(
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
        paymentMethods: paymentMethods,
      );

      final entities =
          invoiceRows.map((row) => InvoiceEntity.fromDrift(row)).toList();

      return Right(
        PaginatedInvoicesEntity(
          invoices: entities,
          totalCount: totalCount,
        ),
      );
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvoiceDetailsEntity>> getInvoiceDetails(
    int invoiceId,
  ) async {
    try {
      final invoiceRow = await remoteDataSource.getInvoiceById(invoiceId);
      if (invoiceRow == null) {
        return const Left(UnexpectedFailure(message: 'Invoice not found'));
      }

      final itemRows =
          await remoteDataSource.getInvoiceItemsByInvoiceId(invoiceId);
      final paymentRows =
          await remoteDataSource.getPaymentTransactionsByInvoiceId(invoiceId);

      final invoiceEntity = InvoiceEntity.fromDrift(invoiceRow);
      final itemEntities =
          itemRows.map((item) => InvoiceItemEntity.fromDrift(item)).toList();

      String? tableName;
      if (invoiceRow.orderId != null) {
        try {
          final order = await remoteDataSource.getOrderById(invoiceRow.orderId!);
          if (order != null && order.tableNameText != null && order.tableNameText!.isNotEmpty) {
            tableName = order.tableNameText;
          }
        } catch (_) {}
      }

      return Right(
        InvoiceDetailsEntity(
          invoice: invoiceEntity,
          items: itemEntities,
          paymentTransactions: paymentRows,
          tableName: tableName,
        ),
      );
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvoiceDetailsEntity>> getInvoiceDetailsByOrderId(
    int orderId,
  ) async {
    try {
      final invoiceRow = await remoteDataSource.getInvoiceByOrderId(orderId);
      if (invoiceRow == null) {
        return const Left(
          UnexpectedFailure(message: 'No invoice found for this order'),
        );
      }
      return getInvoiceDetails(invoiceRow.id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvoiceDetailsEntity>> getInvoiceDetailsByHashId(
    String hashId,
  ) async {
    try {
      final invoiceRow = await remoteDataSource.getInvoiceByHashId(hashId);
      if (invoiceRow == null) {
        return const Left(
          UnexpectedFailure(message: 'No invoice found for this hash ID'),
        );
      }
      return getInvoiceDetails(invoiceRow.id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvoiceDetailsEntity>> getInvoiceDetailsByOrderHashId(
    String orderHashId,
  ) async {
    try {
      final invoiceRow =
          await remoteDataSource.getInvoiceByOrderHashId(orderHashId);
      if (invoiceRow == null) {
        return const Left(
          UnexpectedFailure(message: 'No invoice found for this order'),
        );
      }
      return getInvoiceDetails(invoiceRow.id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateInvoice({
    required InvoiceEntity invoice,
    required List<InvoiceItemEntity> items,
  }) async {
    try {
      final companion = InvoicesTableCompanion(
        customerName: Value(invoice.customerName),
        phoneNumber: Value(invoice.phoneNumber),
        paymentMethodName: Value(invoice.paymentMethodName),
        taxPercentage: Value(invoice.taxPercentage),
        discountType: Value(invoice.discountType),
        discountAmount: Value(invoice.discountAmount),
        totalCost: Value(invoice.totalCost),
        taxCost: Value(invoice.taxCost),
        taxableAmount: Value(invoice.taxableAmount),
        netPaymentAmount: Value(invoice.netPaymentAmount),
        recordAmountPaid: Value(invoice.recordAmountPaid),
        modifiedDate: Value(DateTime.now().toIso8601String()),
      );

      final itemCompanions = items.map((item) {
        return InvoiceItemsTableCompanion(
          invoiceId: Value(item.invoiceId ?? invoice.id),
          orderItemId: Value(item.orderItemId),
          itemId: Value(item.itemId),
          itemName: Value(item.itemName),
          quantity: Value(item.quantity),
          sellingPrice: Value(item.unitPrice),
          totalPrice: Value(item.totalPrice),
          createdDate: Value(DateTime.now().toIso8601String()),
        );
      }).toList();

      final success = await remoteDataSource.updateInvoice(
        invoice.id,
        companion,
        items: itemCompanions,
      );
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteInvoice(int invoiceId) async {
    try {
      final rows = await remoteDataSource.deleteInvoice(invoiceId);
      return Right(rows > 0);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMode>>> getPaymentModes() async {
    try {
      final modes = await remoteDataSource.getPaymentModes();
      return Right(modes);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

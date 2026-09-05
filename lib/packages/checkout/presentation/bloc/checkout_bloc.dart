import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/customer_details.dart';
import '../../domain/entities/discount.dart';
import '../../domain/entities/extra_charge.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/tax.dart';
import '../../domain/usecases/checkout_calculator.dart';
import '../../domain/usecases/get_order_checkout_data.dart';
import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutCalculator calculator;
  final GetOrderCheckoutData? getOrderCheckoutData;

  CheckoutBloc({
    this.calculator = const CheckoutCalculator(),
    this.getOrderCheckoutData,
  }) : super(CheckoutState.initial()) {



    on<CheckoutStarted>(_onStarted);
    on<CheckoutFetchStarted>(_onFetchStarted);
    on<CheckoutItemAdded>(_onItemAdded);

    on<CheckoutItemUpdated>(_onItemUpdated);
    on<CheckoutItemRemoved>(_onItemRemoved);
    on<CheckoutTaxAdded>(_onTaxAdded);
    on<CheckoutTaxRemoved>(_onTaxRemoved);
    on<CheckoutDiscountAdded>(_onDiscountAdded);
    on<CheckoutDiscountRemoved>(_onDiscountRemoved);
    on<CheckoutOtherChargeAdded>(_onOtherChargeAdded);
    on<CheckoutOtherChargeRemoved>(_onOtherChargeRemoved);
    on<CheckoutRoundOffToggled>(_onRoundOffToggled);
    on<CheckoutCleared>(_onCleared);
    on<CheckoutCustomerDetailsUpdated>(_onCustomerDetailsUpdated);
    on<CheckoutPaymentMethodAdded>(_onPaymentMethodAdded);
    on<CheckoutPaymentMethodToggled>(_onPaymentMethodToggled);
    on<CheckoutPaymentSelected>(_onPaymentSelected);
    on<CheckoutPaymentConfirmed>(_onPaymentConfirmed);
  }

  void _onStarted(CheckoutStarted event, Emitter<CheckoutState> emit) {
    _recalculateAndEmit(emit, state);
  }

  Future<void> _onFetchStarted(
    CheckoutFetchStarted event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, orderId: event.orderId, errorMessage: null));
    if (getOrderCheckoutData == null) {
      // Fallback if no remote/local repository provided
      emit(state.copyWith(isLoading: false));
      _recalculateAndEmit(emit, state);
      return;
    }

    final result = await getOrderCheckoutData!.call(event.orderId);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (data) {
        final newState = state.copyWith(
          isLoading: false,
          cartItems: data.items,
          customerDetails: data.customerDetails,
        );
        _recalculateAndEmit(emit, newState);
      },
    );
  }


  void _onItemAdded(CheckoutItemAdded event, Emitter<CheckoutState> emit) {
    final updatedCart = List<CartItem>.from(state.cartItems);
    final index = updatedCart.indexWhere((i) => i.id == event.item.id);
    if (index >= 0) {
      final existing = updatedCart[index];
      updatedCart[index] = existing.copyWith(quantity: existing.quantity + event.item.quantity);
    } else {
      updatedCart.add(event.item);
    }
    _recalculateAndEmit(emit, state.copyWith(cartItems: updatedCart));
    _persistOrderCart(state.orderId, updatedCart);
  }

  void _onItemUpdated(CheckoutItemUpdated event, Emitter<CheckoutState> emit) {
    final updatedCart = List<CartItem>.from(state.cartItems);
    final index = updatedCart.indexWhere((i) => i.id == event.item.id);
    if (index >= 0) {
      if (event.item.quantity <= 0) {
        updatedCart.removeAt(index);
      } else {
        updatedCart[index] = event.item;
      }
      _recalculateAndEmit(emit, state.copyWith(cartItems: updatedCart));
      _persistOrderCart(state.orderId, updatedCart);
    }
  }

  void _onItemRemoved(CheckoutItemRemoved event, Emitter<CheckoutState> emit) {
    final updatedCart = state.cartItems.where((i) => i.id != event.itemId).toList();
    _recalculateAndEmit(emit, state.copyWith(cartItems: updatedCart));
    _persistOrderCart(state.orderId, updatedCart);
  }

  Future<void> _persistOrderCart(String? orderIdStr, List<CartItem> cartItems) async {
    if (orderIdStr == null || orderIdStr.isEmpty) return;
    final orderId = int.tryParse(orderIdStr);
    if (orderId == null) return;

    try {
      final db = sl<CoozyDatabase>();
      await db.transaction(() async {
        await (db.delete(db.orderItemsTable)
              ..where((t) => t.orderId.equals(orderId)))
            .go();

        for (final cartItem in cartItems) {
          final isVar = cartItem.id.startsWith('var_');
          final rawIdStr = cartItem.id.replaceAll('var_', '').replaceAll('item_', '');
          final idInt = int.tryParse(rawIdStr);

          await db.into(db.orderItemsTable).insert(
                OrderItemsTableCompanion.insert(
                  orderId: Value(orderId),
                  itemId: Value(idInt),
                  menuItemId: Value(isVar ? null : idInt),
                  selectedVariationId: Value(isVar ? idInt : null),
                  isMenuItem: Value(!isVar),
                  quantity: Value(cartItem.quantity),
                  sellingPrice: Value(cartItem.unitPrice),
                  status: const Value('newOrder'),
                  creationDate: Value(DateTime.now().toUtc().toIso8601String()),
                ),
              );
        }
      });
    } catch (_) {}
  }

  void _onTaxAdded(CheckoutTaxAdded event, Emitter<CheckoutState> emit) {
    final updated = List<Tax>.from(state.appliedTaxes)..add(event.tax);
    _recalculateAndEmit(emit, state.copyWith(appliedTaxes: updated));
  }

  void _onTaxRemoved(CheckoutTaxRemoved event, Emitter<CheckoutState> emit) {
    final updated = state.appliedTaxes.where((t) => t.id != event.taxId).toList();
    _recalculateAndEmit(emit, state.copyWith(appliedTaxes: updated));
  }

  void _onDiscountAdded(CheckoutDiscountAdded event, Emitter<CheckoutState> emit) {
    final updated = List<Discount>.from(state.appliedDiscounts)..add(event.discount);
    _recalculateAndEmit(emit, state.copyWith(appliedDiscounts: updated));
  }

  void _onDiscountRemoved(CheckoutDiscountRemoved event, Emitter<CheckoutState> emit) {
    final updated = state.appliedDiscounts.where((d) => d.id != event.discountId).toList();
    _recalculateAndEmit(emit, state.copyWith(appliedDiscounts: updated));
  }

  void _onOtherChargeAdded(CheckoutOtherChargeAdded event, Emitter<CheckoutState> emit) {
    final updated = List<ExtraCharge>.from(state.appliedOtherCharges)..add(event.extraCharge);
    _recalculateAndEmit(emit, state.copyWith(appliedOtherCharges: updated));
  }

  void _onOtherChargeRemoved(CheckoutOtherChargeRemoved event, Emitter<CheckoutState> emit) {
    final updated = state.appliedOtherCharges.where((c) => c.id != event.chargeId).toList();
    _recalculateAndEmit(emit, state.copyWith(appliedOtherCharges: updated));
  }

  void _onRoundOffToggled(CheckoutRoundOffToggled event, Emitter<CheckoutState> emit) {
    final newValue = !state.isRoundOffEnabled;
    _recalculateAndEmit(emit, state.copyWith(isRoundOffEnabled: newValue));
  }

  void _onCleared(CheckoutCleared event, Emitter<CheckoutState> emit) {
    _recalculateAndEmit(
      emit,
      state.copyWith(
        cartItems: [],
        appliedTaxes: [],
        appliedDiscounts: [],
        appliedOtherCharges: [],
        isRoundOffEnabled: false,
      ),
    );
  }

  void _onCustomerDetailsUpdated(
    CheckoutCustomerDetailsUpdated event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(customerDetails: event.customerDetails));
  }

  void _onPaymentMethodAdded(CheckoutPaymentMethodAdded event, Emitter<CheckoutState> emit) {
    final updatedMethods = List<PaymentMethod>.from(state.availablePaymentMethods)..add(event.method);
    emit(state.copyWith(availablePaymentMethods: updatedMethods));
  }

  void _onPaymentMethodToggled(CheckoutPaymentMethodToggled event, Emitter<CheckoutState> emit) {
    final updatedMethods = state.availablePaymentMethods.map((m) {
      if (m.id == event.methodId) {
        return m.copyWith(isEnabled: !m.isEnabled);
      }
      return m;
    }).toList();

    PaymentMethod? currentSelected = state.selectedPaymentMethod;
    if (currentSelected != null && currentSelected.id == event.methodId) {
      final updatedSel = updatedMethods.firstWhere((m) => m.id == event.methodId);
      if (!updatedSel.isEnabled) {
        currentSelected = updatedMethods.firstWhere((m) => m.isEnabled, orElse: () => updatedMethods.first);
      }
    }

    emit(state.copyWith(
      availablePaymentMethods: updatedMethods,
      selectedPaymentMethod: currentSelected,
    ));
  }

  void _onPaymentSelected(CheckoutPaymentSelected event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(selectedPaymentMethod: event.method));
  }

  Future<void> _onPaymentConfirmed(
    CheckoutPaymentConfirmed event,
    Emitter<CheckoutState> emit,
  ) async {
    final orderIdStr = state.orderId;
    if (orderIdStr != null && orderIdStr.isNotEmpty) {
      final orderId = int.tryParse(orderIdStr);
      if (orderId != null) {
        try {
          final db = sl<CoozyDatabase>();
          final summary = state.summary;
          final paymentName = state.selectedPaymentMethod?.name ?? 'Cash';
          final currentDate = DateTime.now().toUtc().toIso8601String();

          final breakdownDetails = jsonEncode({
            'taxDetails': summary.taxDetails
                .map((t) => {
                      'name': t.name,
                      'ratePercent': t.ratePercent,
                      'amount': t.calculatedAmount,
                    })
                .toList(),
            'discountDetails': summary.discountDetails
                .map((d) => {
                      'name': d.name,
                      'amount': d.calculatedAmount,
                    })
                .toList(),
            'chargeDetails': summary.chargeDetails
                .map((c) => {
                      'name': c.name,
                      'amount': c.calculatedAmount,
                    })
                .toList(),
            'roundingAmount': summary.roundingAmount,
            'cashReceived': event.cashReceived,
            'changeAmount': event.changeAmount,
            'note': event.note,
          });

          await db.ordersDao.markOrderCompleted(orderId);

          await (db.update(db.ordersTable)..where((t) => t.id.equals(orderId))).write(
            OrdersTableCompanion(
              paymentMethodName: Value(paymentName),
              paymentMethodDetails: Value(breakdownDetails),
              cashReceived: Value(event.cashReceived ?? 0.0),
              changeAmount: Value(event.changeAmount ?? 0.0),
              subtotalAmount: Value(summary.subtotal),
              discountAmount: Value(summary.totalDiscounts),
              taxAmount: Value(summary.totalTaxes),
              otherChargesAmount: Value(summary.totalOtherCharges),
              grandTotal: Value(summary.grandTotal),
              modificationDate: Value(currentDate),
            ),
          );

          final existingInvoices = await (db.select(db.invoicesTable)
                ..where((t) => t.orderId.equals(orderId)))
              .get();

          final amountPaid = event.cashReceived != null && event.cashReceived! > 0
              ? event.cashReceived!
              : summary.grandTotal;

          int targetInvoiceId;
          if (existingInvoices.isNotEmpty) {
            targetInvoiceId = existingInvoices.first.id;
            await (db.update(db.invoicesTable)..where((t) => t.id.equals(targetInvoiceId))).write(
              InvoicesTableCompanion(
                totalCost: Value(summary.subtotal),
                discountAmount: Value(summary.totalDiscounts),
                taxCost: Value(summary.totalTaxes),
                taxableAmount: Value(summary.taxableBase),
                netPaymentAmount: Value(summary.grandTotal),
                recordAmountPaid: Value(amountPaid),
                cashReceived: Value(event.cashReceived ?? 0.0),
                changeAmount: Value(event.changeAmount ?? 0.0),
                paymentMethodName: Value(paymentName),
                paymentMethodDetails: Value(breakdownDetails),
                modifiedDate: Value(currentDate),
              ),
            );
          } else {
            targetInvoiceId = await db.into(db.invoicesTable).insert(
                  InvoicesTableCompanion.insert(
                    orderId: Value(orderId),
                    totalCost: Value(summary.subtotal),
                    discountAmount: Value(summary.totalDiscounts),
                    taxCost: Value(summary.totalTaxes),
                    taxableAmount: Value(summary.taxableBase),
                    netPaymentAmount: Value(summary.grandTotal),
                    recordAmountPaid: Value(amountPaid),
                    cashReceived: Value(event.cashReceived ?? 0.0),
                    changeAmount: Value(event.changeAmount ?? 0.0),
                    paymentMethodName: Value(paymentName),
                    paymentMethodDetails: Value(breakdownDetails),
                    createdDate: Value(currentDate),
                  ),
                );
          }

          // Insert explicit payment transaction into payment_transactions DB table
          await db.into(db.paymentTransactionsTable).insert(
                PaymentTransactionsTableCompanion.insert(
                  invoiceId: Value(targetInvoiceId),
                  paymentMethodName: Value(paymentName),
                  amount: Value(amountPaid),
                  transactionReference: Value(
                    event.note != null && event.note!.isNotEmpty
                        ? '${event.note} (Cash: $amountPaid, Change: ${event.changeAmount ?? 0.0})'
                        : 'Cash Paid: $amountPaid, Change: ${event.changeAmount ?? 0.0}',
                  ),
                  paymentStatus: const Value('completed'),
                  createdDate: Value(currentDate),
                ),
              );
        } catch (_) {}
      }
    }
  }

  void _recalculateAndEmit(Emitter<CheckoutState> emit, CheckoutState newState) {
    final newSummary = calculator.calculate(
      cartItems: newState.cartItems,
      appliedTaxes: newState.appliedTaxes,
      appliedDiscounts: newState.appliedDiscounts,
      appliedOtherCharges: newState.appliedOtherCharges,
      isRoundOffEnabled: newState.isRoundOffEnabled,
    );
    emit(newState.copyWith(summary: newSummary));
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../bloc/invoice_management_bloc.dart';
import '../pages/invoice_list/invoice_list_screen.dart';
import '../pages/invoice_detail/invoice_detail_screen.dart';
import '../pages/edit_invoice/edit_invoice_screen.dart';
import '../../domain/entities/invoice_management_entity.dart';

class InvoiceManagementRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: AppRoutePath.invoiceListScreenRoute,
      name: 'invoice-list',
      builder: (context, state) => BlocProvider<InvoiceManagementBloc>(
        create: (_) => sl<InvoiceManagementBloc>()
          ..add(const LoadInvoicesEvent(isRefresh: true)),
        child: const InvoiceListScreen(),
      ),
      routes: [
        GoRoute(
          path: AppRoutePath.invoiceInfoScreenRoute,
          name: 'invoice-info',
          builder: (context, state) {
            final idStr = state.pathParameters['id'];
            final fromCheckoutStr = state.uri.queryParameters['fromCheckout'];
            final fromCheckout = fromCheckoutStr == 'true';

            final extra = state.extra;
            InvoiceEntity? extraInvoice;
            int invoiceId = 0;
            String? hashId;

            if (idStr != null && idStr.isNotEmpty) {
              final parsedInt = int.tryParse(idStr);
              if (parsedInt != null) {
                invoiceId = parsedInt;
              } else {
                hashId = idStr;
              }
            }

            if (extra is InvoiceEntity) {
              extraInvoice = extra;
              if (hashId == null && (extra.hashId.isNotEmpty)) {
                hashId = extra.hashId;
              }
              if (invoiceId == 0) {
                invoiceId = extra.id;
              }
            }

            return BlocProvider<InvoiceManagementBloc>(
              create: (_) => sl<InvoiceManagementBloc>(),
              child: InvoiceDetailScreen(
                invoiceId: invoiceId,
                hashId: hashId,
                initialInvoice: extraInvoice,
                fromCheckout: fromCheckout,
              ),
            );
          },
          routes: [
            GoRoute(
              path: AppRoutePath.invoiceAddOrEditScreenRoute,
              name: 'invoice-info-edit',
              builder: (context, state) {
                final extraDetails = state.extra is InvoiceDetailsEntity
                    ? state.extra as InvoiceDetailsEntity
                    : null;
                if (extraDetails != null) {
                  return BlocProvider<InvoiceManagementBloc>(
                    create: (_) => sl<InvoiceManagementBloc>(),
                    child: EditInvoiceScreen(
                      details: extraDetails,
                    ),
                  );
                }
                final idStr = state.pathParameters['id'] ??
                    state.uri.queryParameters['id'];
                final invoiceId = int.tryParse(idStr ?? '') ?? 0;
                return BlocProvider<InvoiceManagementBloc>(
                  create: (_) => sl<InvoiceManagementBloc>()
                    ..add(LoadInvoiceDetailsEvent(invoiceId)),
                  child: Builder(
                    builder: (context) {
                      return BlocBuilder<InvoiceManagementBloc,
                          InvoiceManagementState>(
                        builder: (context, state) {
                          if (state is InvoiceManagementLoadedState &&
                              state.selectedInvoiceDetails != null) {
                            return EditInvoiceScreen(
                              details: state.selectedInvoiceDetails!,
                            );
                          }
                          return const shared.LoadingPage();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutePath.invoiceAddOrEditScreenRoute,
          name: 'invoice-edit',
          builder: (context, state) {
            final extraDetails = state.extra is InvoiceDetailsEntity
                ? state.extra as InvoiceDetailsEntity
                : null;
            if (extraDetails != null) {
              return BlocProvider<InvoiceManagementBloc>(
                create: (_) => sl<InvoiceManagementBloc>(),
                child: EditInvoiceScreen(
                  details: extraDetails,
                ),
              );
            }
            final idStr = state.uri.queryParameters['id'];
            final invoiceId = int.tryParse(idStr ?? '') ?? 0;
            return BlocProvider<InvoiceManagementBloc>(
              create: (_) => sl<InvoiceManagementBloc>()
                ..add(LoadInvoiceDetailsEvent(invoiceId)),
              child: Builder(
                builder: (context) {
                  return BlocBuilder<InvoiceManagementBloc,
                      InvoiceManagementState>(
                    builder: (context, state) {
                      if (state is InvoiceManagementLoadedState &&
                          state.selectedInvoiceDetails != null) {
                        return EditInvoiceScreen(
                          details: state.selectedInvoiceDetails!,
                        );
                      }
                      return const shared.LoadingPage();
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    ),
  ];
}

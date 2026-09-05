import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
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
            int invoiceId = int.tryParse(idStr ?? '') ?? 1;

            if (extra is InvoiceEntity) {
              extraInvoice = extra;
              invoiceId = extra.id;
            }

            return BlocProvider<InvoiceManagementBloc>(
              create: (_) => sl<InvoiceManagementBloc>(),
              child: InvoiceDetailScreen(
                invoiceId: invoiceId,
                initialInvoice: extraInvoice,
                fromCheckout: fromCheckout,
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutePath.invoiceAddOrEditScreenRoute,
          name: 'invoice-edit',
          builder: (context, state) {
            final extraDetails = state.extra as InvoiceDetailsEntity;
            return BlocProvider<InvoiceManagementBloc>(
              create: (_) => sl<InvoiceManagementBloc>(),
              child: EditInvoiceScreen(
                details: extraDetails,
              ),
            );
          },
        ),
      ],
    ),
  ];
}

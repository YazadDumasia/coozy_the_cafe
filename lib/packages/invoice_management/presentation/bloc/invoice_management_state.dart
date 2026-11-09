part of 'invoice_management_bloc.dart';

sealed class InvoiceManagementState extends Equatable {
  const InvoiceManagementState();

  @override
  List<Object?> get props => [];
}

class InvoiceManagementInitialState extends InvoiceManagementState {
  const InvoiceManagementInitialState();
}

class InvoiceManagementLoadingState extends InvoiceManagementState {
  const InvoiceManagementLoadingState();
}

class InvoiceManagementLoadedState extends InvoiceManagementState {
  final List<InvoiceEntity> invoices;
  final int totalCount;
  final int currentPage;
  final bool hasReachedMax;
  final bool isFetchingMore;
  final String searchQuery;
  final DateTimeRange? dateRange;
  final InvoiceDetailsEntity? selectedInvoiceDetails;
  final bool isLoadingDetails;
  final String? errorMessage;
  final List<PaymentMode> paymentModes;
  final List<String> selectedPaymentMethods;
  final Uint8List? prebuiltThermalBytes;
  final Uint8List? prebuiltA4Bytes;
  final bool isGeneratingPdf;

  const InvoiceManagementLoadedState({
    required this.invoices,
    required this.totalCount,
    required this.currentPage,
    required this.hasReachedMax,
    this.isFetchingMore = false,
    this.searchQuery = '',
    this.dateRange,
    this.selectedInvoiceDetails,
    this.isLoadingDetails = false,
    this.errorMessage,
    this.paymentModes = const [],
    this.selectedPaymentMethods = const [],
    this.prebuiltThermalBytes,
    this.prebuiltA4Bytes,
    this.isGeneratingPdf = false,
  });

  InvoiceManagementLoadedState copyWith({
    List<InvoiceEntity>? invoices,
    int? totalCount,
    int? currentPage,
    bool? hasReachedMax,
    bool? isFetchingMore,
    String? searchQuery,
    DateTimeRange? dateRange,
    InvoiceDetailsEntity? selectedInvoiceDetails,
    bool? isLoadingDetails,
    String? errorMessage,
    List<PaymentMode>? paymentModes,
    List<String>? selectedPaymentMethods,
    Uint8List? prebuiltThermalBytes,
    Uint8List? prebuiltA4Bytes,
    bool? isGeneratingPdf,
  }) {
    return InvoiceManagementLoadedState(
      invoices: invoices ?? this.invoices,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      dateRange: dateRange ?? this.dateRange,
      selectedInvoiceDetails:
          selectedInvoiceDetails ?? this.selectedInvoiceDetails,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      errorMessage: errorMessage,
      paymentModes: paymentModes ?? this.paymentModes,
      selectedPaymentMethods:
          selectedPaymentMethods ?? this.selectedPaymentMethods,
      prebuiltThermalBytes: prebuiltThermalBytes ?? this.prebuiltThermalBytes,
      prebuiltA4Bytes: prebuiltA4Bytes ?? this.prebuiltA4Bytes,
      isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
    );
  }

  @override
  List<Object?> get props => [
    invoices,
    totalCount,
    currentPage,
    hasReachedMax,
    isFetchingMore,
    searchQuery,
    dateRange,
    selectedInvoiceDetails,
    isLoadingDetails,
    errorMessage,
    paymentModes,
    selectedPaymentMethods,
    prebuiltThermalBytes,
    prebuiltA4Bytes,
    isGeneratingPdf,
  ];
}

class InvoiceManagementErrorState extends InvoiceManagementState {
  final String message;

  const InvoiceManagementErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class InvoiceDeletedSuccessState extends InvoiceManagementState {
  const InvoiceDeletedSuccessState();
}

class InvoiceUpdatedSuccessState extends InvoiceManagementState {
  const InvoiceUpdatedSuccessState();
}

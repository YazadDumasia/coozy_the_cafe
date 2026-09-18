import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../domain/entities/expenditure_entity.dart';
import '../../../domain/entities/expenditure_category_entity.dart';
import '../../../domain/usecases/get_expenditure_categories_usecase.dart';
import '../../../domain/usecases/expenditure_mutation_usecases.dart';
import 'widget/add_custom_category_dialog.dart';
import 'widget/category_grid_item.dart';
import '../../widgets/add_entry_bottom_sheet/add_entry_bottom_sheet.dart';

class CategorySelectionScreen extends StatefulWidget {
  final String initialType; // 'EXPENSE' or 'INCOME'

  const CategorySelectionScreen({super.key, this.initialType = 'EXPENSE'});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ValueNotifier<bool> _isSearchingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');

  static const List<String> _defaultExpenses = [
    'Tax',
    'Fuel',
    'Food',
    'Bill',
    'Transportation',
    'Insurance',
    'Salary',
    'Rent',
    'Repairs',
    'Commissions',
    'Advertising',
    'Fee',
    'Interest',
    'Loan',
    'Supplies',
    'Transfer',
    'Contract',
    'Miscellaneous',
    'Disposable',
    'Bread',
    'Vegetables',
    'Milk',
    'Cold Drinks',
    'Sauce',
  ];

  static const List<String> _defaultIncomes = [
    'Profit',
    'Salary',
    'Awards',
    'Rental',
    'Sale',
    'Refund',
    'Lottery',
    'Dividend',
    'Investment',
    'Interest',
    'Commission',
    'Fee',
    'Loan',
    'Miscellaneous',
  ];

  late final ValueNotifier<List<ExpenditureCategoryEntity>>
  _expenseCategoriesNotifier;
  late final ValueNotifier<List<ExpenditureCategoryEntity>>
  _incomeCategoriesNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialType == 'INCOME' ? 1 : 0,
    );
    _expenseCategoriesNotifier = ValueNotifier<List<ExpenditureCategoryEntity>>(
      _defaultExpenses
          .map((name) => ExpenditureCategoryEntity(name: name, type: 'EXPENSE'))
          .toList(),
    );
    _incomeCategoriesNotifier = ValueNotifier<List<ExpenditureCategoryEntity>>(
      _defaultIncomes
          .map((name) => ExpenditureCategoryEntity(name: name, type: 'INCOME'))
          .toList(),
    );
    _loadSavedCategories();
  }

  Future<void> _loadSavedCategories() async {
    final useCase = GetIt.instance<GetExpenditureCategoriesUseCase>();

    final expenseRes = await useCase('EXPENSE');
    if (mounted) {
      expenseRes.fold(
        (failure) {
          debugPrint('Error loading expense categories: ${failure.message}');
        },
        (categories) {
          if (categories.isNotEmpty) {
            _expenseCategoriesNotifier.value = categories;
          } else {
            _expenseCategoriesNotifier.value = _defaultExpenses
                .map(
                  (name) =>
                      ExpenditureCategoryEntity(name: name, type: 'EXPENSE'),
                )
                .toList();
          }
        },
      );
    }

    final incomeRes = await useCase('INCOME');
    if (mounted) {
      incomeRes.fold(
        (failure) {
          debugPrint('Error loading income categories: ${failure.message}');
        },
        (categories) {
          if (categories.isNotEmpty) {
            _incomeCategoriesNotifier.value = categories;
          } else {
            _incomeCategoriesNotifier.value = _defaultIncomes
                .map(
                  (name) =>
                      ExpenditureCategoryEntity(name: name, type: 'INCOME'),
                )
                .toList();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _expenseCategoriesNotifier.dispose();
    _incomeCategoriesNotifier.dispose();
    _isSearchingNotifier.dispose();
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleCategoryTap(
    String categoryName,
    String type, {
    int? categoryId,
  }) async {
    final result = await showModalBottomSheet<ExpenditureEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEntryBottomSheet(
        categoryName: categoryName,
        type: type,
        categoryId: categoryId,
      ),
    );

    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _handleAddCustomCategory(String type) async {
    final customName = await showDialog<String>(
      context: context,
      builder: (_) => AddCustomCategoryDialog(type: type),
    );

    if (customName != null && customName.trim().isNotEmpty && mounted) {
      final trimmedName = customName.trim();
      final currentList = type == 'EXPENSE'
          ? _expenseCategoriesNotifier.value
          : _incomeCategoriesNotifier.value;

      final existingMatch = currentList.where(
        (c) => c.name.trim().toLowerCase() == trimmedName.toLowerCase(),
      );

      if (existingMatch.isNotEmpty) {
        final existingCat = existingMatch.first;
        _handleCategoryTap(existingCat.name, type, categoryId: existingCat.id);
        return;
      }

      // 1. Persist to Database via AddCustomCategoryUseCase
      final addUseCase = GetIt.instance<AddCustomCategoryUseCase>();
      final result = await addUseCase(
        ExpenditureCategoryEntity(
          name: trimmedName,
          type: type,
          isCustom: true,
          isEnabled: true,
        ),
      );

      if (!mounted) return;

      await result.fold(
        (failure) async {
          debugPrint('Failed to save custom category: ${failure.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        (newId) async {
          debugPrint('Successfully saved custom category with id: $newId');
          // 2. Reload categories directly from DB so state is fully synchronized
          await _loadSavedCategories();

          // 3. Immediately open bottom sheet for the newly added category
          if (mounted) {
            _handleCategoryTap(trimmedName, type, categoryId: newId);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<bool>(
          valueListenable: _isSearchingNotifier,
          builder: (context, isSearching, _) {
            if (!isSearching) {
              return Text(
                context.tr(
                      shared.LocaleKeys.expenditureSelectCategory,
                      track: shared.TrackConstants.expenditurePageTrack,
                    ) ??
                    'Select Category',
              );
            }
            return TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText:
                    context.tr(
                      shared.LocaleKeys.expenditureSearchCategory,
                      track: shared.TrackConstants.expenditurePageTrack,
                    ) ??
                    'Search category...',
                border: InputBorder.none,
              ),
              onChanged: (val) {
                _searchQueryNotifier.value = val;
              },
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: theme.scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: [
                Tab(
                  text:
                      (context.tr(
                                shared.LocaleKeys.expenditureExpense,
                                track:
                                    shared.TrackConstants.expenditurePageTrack,
                              ) ??
                              'EXPENSE')
                          .toUpperCase(),
                ),
                Tab(
                  text:
                      (context.tr(
                                shared.LocaleKeys.expenditureIncome,
                                track:
                                    shared.TrackConstants.expenditurePageTrack,
                              ) ??
                              'INCOME')
                          .toUpperCase(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isSearchingNotifier,
            builder: (context, isSearching, _) {
              return IconButton(
                icon: Icon(isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  _isSearchingNotifier.value = !isSearching;
                  if (isSearching) {
                    _searchController.clear();
                    _searchQueryNotifier.value = '';
                  }
                },
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryGrid('EXPENSE', _expenseCategoriesNotifier),
          _buildCategoryGrid('INCOME', _incomeCategoriesNotifier),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(
    String type,
    ValueNotifier<List<ExpenditureCategoryEntity>> categoriesNotifier,
  ) {
    return RefreshIndicator(
      onRefresh: _loadSavedCategories,
      child: ValueListenableBuilder<List<ExpenditureCategoryEntity>>(
        valueListenable: categoriesNotifier,
        builder: (context, categories, _) {
          return ValueListenableBuilder<String>(
            valueListenable: _searchQueryNotifier,
            builder: (context, query, _) {
              final trimmedQuery = query.trim().toLowerCase();
              final filtered = trimmedQuery.isEmpty
                  ? categories
                  : categories
                        .where(
                          (c) => c.name.toLowerCase().contains(trimmedQuery),
                        )
                        .toList();

              return GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filtered.length + 1, // +1 for Custom button
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemBuilder: (context, index) {
                  if (index == filtered.length) {
                    return CategoryGridItem(
                      title:
                          context.tr(
                            shared.LocaleKeys.expenditureCustom,
                            track: shared.TrackConstants.expenditurePageTrack,
                          ) ??
                          'Custom',
                      type: type,
                      isCustomAddButton: true,
                      onTap: () => _handleAddCustomCategory(type),
                    );
                  }
                  final cat = filtered[index];
                  return CategoryGridItem(
                    title: cat.name,
                    type: type,
                    onTap: () =>
                        _handleCategoryTap(cat.name, type, categoryId: cat.id),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

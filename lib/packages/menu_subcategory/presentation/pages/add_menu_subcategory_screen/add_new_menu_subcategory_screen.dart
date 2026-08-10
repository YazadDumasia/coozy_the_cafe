import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/menu_category/domain/usecases/menu_category_usecases.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/pages/add_menu_category_screen/dynamic_text_form_field_for_sub_category_widget.dart';
import '../../bloc/add_menu_subcategory_cubit/add_new_menu_subcategory_cubit.dart';
import 'add_new_menu_subcategory_screen_actions.dart';

class AddNewMenuSubcategoryScreen extends StatefulWidget {
  final int? initialCategoryId;

  const AddNewMenuSubcategoryScreen({super.key, this.initialCategoryId});

  @override
  State<AddNewMenuSubcategoryScreen> createState() =>
      _AddNewMenuSubcategoryScreenState();
}

class _AddNewMenuSubcategoryScreenState
    extends State<AddNewMenuSubcategoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AddNewMenuSubcategoryCubit _cubit;
  ScrollController? _scrollController;

  List<MenuCategory> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _cubit = context.read<AddNewMenuSubcategoryCubit>();
    _cubit.resetData();
    if (widget.initialCategoryId != null) {
      _cubit.setSelectedCategory(MenuCategory(id: widget.initialCategoryId));
    }
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final getCategoriesUseCase = core.sl<GetMenuCategoriesUseCase>();
      final list = await getCategoriesUseCase();
      if (mounted) {
        setState(() {
          _categories = list;
          _isLoadingCategories = false;
        });

        // Pre-select category if initialCategoryId was passed
        if (widget.initialCategoryId != null) {
          final matched = _categories.cast<MenuCategory?>().firstWhere(
            (c) => c?.id == widget.initialCategoryId,
            orElse: () => null,
          );
          if (matched != null) {
            _cubit.setSelectedCategory(matched);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            context.tr(
                  shared.LocaleKeys.menuSubCategoryAppbarTitle,
                  track: shared.TrackConstants.menuSubCategoryPageTrack,
                ) ??
                'Add new subcategory',
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () =>
                  AddNewMenuSubcategoryScreenActions.handleSaveSubcategories(
                    context,
                    _formKey,
                    _cubit,
                  ),
              icon: const Icon(Icons.check_circle),
              tooltip:
                  context.tr(
                    shared.LocaleKeys.commonSave,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Save',
            ),
          ],
        ),
        body: BlocConsumer<AddNewMenuSubcategoryCubit, AddNewMenuSubcategoryState>(
          listener: (context, state) {},
          builder: (context, state) {
            return SingleChildScrollView(
              primary: false,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              controller: _scrollController,
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    // Category Selection / Creation Section
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: _isLoadingCategories
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<dynamic>(
                                  key: ValueKey(
                                    '${_cubit.isCreatingNewCategory}_${_cubit.selectedCategory?.id}',
                                  ),
                                  initialValue: _cubit.isCreatingNewCategory
                                      ? 'NEW_CATEGORY_OPTION'
                                      : _categories
                                            .cast<MenuCategory?>()
                                            .firstWhere(
                                              (c) =>
                                                  c?.id ==
                                                  _cubit.selectedCategory?.id,
                                              orElse: () => null,
                                            ),
                                  decoration: InputDecoration(
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    labelText:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .menuCategoryLabelText,
                                          track: shared
                                              .TrackConstants
                                              .menuCategoryPageTrack,
                                        ) ??
                                        'Select Category',
                                    hintText:
                                        context.tr(
                                          shared.LocaleKeys.selectACategoryHint,
                                          track: shared
                                              .TrackConstants
                                              .menuSubCategoryPageTrack,
                                        ) ??
                                        'Select a category',
                                  ),
                                  items: [
                                    ..._categories.map((cat) {
                                      return DropdownMenuItem<dynamic>(
                                        value: cat,
                                        child: Text(cat.name ?? ''),
                                      );
                                    }),
                                    DropdownMenuItem<dynamic>(
                                      value: 'NEW_CATEGORY_OPTION',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Add New Category',
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (dynamic value) {
                                    if (value == 'NEW_CATEGORY_OPTION') {
                                      _cubit.toggleCreatingNewCategory(true);
                                    } else if (value is MenuCategory) {
                                      _cubit.setSelectedCategory(value);
                                    }
                                  },
                                  onSaved: (dynamic value) {
                                    if (value is MenuCategory) {
                                      _cubit.setSelectedCategory(value);
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null &&
                                        !_cubit.isCreatingNewCategory) {
                                      return 'Category is required.';
                                    }
                                    return null;
                                  },
                                ),
                                if (_cubit.isCreatingNewCategory) ...[
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller:
                                        _cubit.newCategoryNameController,
                                    focusNode: _cubit.newCategoryNameFocusNode,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      labelText:
                                          context.tr(
                                            shared
                                                .LocaleKeys
                                                .menuCategoryLabelText,
                                            track: shared
                                                .TrackConstants
                                                .menuCategoryPageTrack,
                                          ) ??
                                          'Category Name',
                                      hintText:
                                          context.tr(
                                            shared
                                                .LocaleKeys
                                                .enterNewCategoryNameHint,
                                            track: shared
                                                .TrackConstants
                                                .menuSubCategoryPageTrack,
                                          ) ??
                                          'Enter new category name',
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.close),
                                        tooltip:
                                            context.tr(
                                              shared
                                                  .LocaleKeys
                                                  .cancelNewCategoryTooltip,
                                              track: shared
                                                  .TrackConstants
                                                  .menuSubCategoryPageTrack,
                                            ) ??
                                            'Cancel new category',
                                        onPressed: () {
                                          _cubit.toggleCreatingNewCategory(
                                            false,
                                          );
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_cubit.isCreatingNewCategory &&
                                          (value == null ||
                                              value.trim().isEmpty)) {
                                        return 'Category name is required.';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ],
                            ),
                    ).inExpandedRow(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    // Dynamic Subcategory text fields list
                    BlocConsumer<
                          AddNewMenuSubcategoryCubit,
                          AddNewMenuSubcategoryState
                        >(
                          listener: (context, state) {},
                          builder: (context, state) {
                            List<String> list = [];
                            if (state is AddNewMenuSubcategoryUpdated) {
                              list = state.subCategoryList;
                            }
                            if (list.isEmpty) {
                              return Container();
                            }
                            return ListView.separated(
                              itemCount: list.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              primary: false,
                              addAutomaticKeepAlives: false,
                              addRepaintBoundaries: true,
                              itemBuilder: (context, index) => Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 5,
                                        bottom: index == list.length - 1
                                            ? 10
                                            : 0,
                                      ),
                                      child:
                                          DynamicTextFormFieldForSubCategoryWidget(
                                            index: index,
                                            key: ValueKey(
                                              'sub_category_$index',
                                            ),
                                            initialValue: list[index],
                                            onChanged: (value) async {
                                              _cubit.onChangeSubCategory(
                                                value,
                                                index,
                                              );
                                            },
                                            onDelete: () async {
                                              _cubit.removeSubCategory(index);
                                              FocusScope.of(context).unfocus();
                                            },
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                            );
                          },
                        )
                        .inExpandedRow(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 0,
                        bottom: 5,
                        right: 10,
                        left: 10,
                      ),
                      child: ElevatedButton(
                        onPressed: () =>
                            AddNewMenuSubcategoryScreenActions.handleAddSubCategory(
                              _cubit,
                              _scrollController,
                            ),
                        child: Text(
                          context.tr(
                                shared.LocaleKeys.addMenuSubCategoryBtnText,
                                track:
                                    shared.TrackConstants.menuCategoryPageTrack,
                              ) ??
                              'Add new sub-category',
                        ),
                      ),
                    ).inExpandedRow(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}

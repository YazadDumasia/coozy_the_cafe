import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/add_menu_sub_categories_bloc/add_menu_categories_cubit.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/pages/add_menu_category_screen/dynamic_text_form_field_for_sub_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_new_menu_category_screen_actions.dart';

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class AddNewMenuCategoryScreen extends StatefulWidget {
  const AddNewMenuCategoryScreen({super.key});

  @override
  State<AddNewMenuCategoryScreen> createState() =>
      _AddNewMenuCategoryScreenState();
}

class _AddNewMenuCategoryScreenState extends State<AddNewMenuCategoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AddMenuCategoryCubit _menuCategoryCubit;
  ScrollController? primaryScrollController;

  @override
  void initState() {
    super.initState();
    primaryScrollController = ScrollController();
    _menuCategoryCubit = context.read<AddMenuCategoryCubit>();
    _menuCategoryCubit.resetData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) async => () async {
          Navigator.pop(context);
          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              context.tr(
                    shared.LocaleKeys.addMenuCategoryAppbarText,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Add new menu category',
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () =>
                    AddNewMenuCategoryScreenActions.handleSaveCategory(
                      context,
                      _formKey,
                      _menuCategoryCubit,
                    ),
                icon: Icon(Icons.check_circle),
                tooltip: 'Save',
              ),
            ],
          ),
          body: BlocConsumer<AddMenuCategoryCubit, AddMenuCategoryState>(
            listener: (context, state) {
              // State handling — navigate back after a successful save
              // handled inside the cubit via Navigator.pop or route
            },
            builder: (context, state) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                controller: primaryScrollController,
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
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller:
                              _menuCategoryCubit.menuCategoryNameController,
                          focusNode:
                              _menuCategoryCubit.menuCategoryNameFocusNode,
                          autofocus: false,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText:
                                context.tr(
                                  shared.LocaleKeys.menuCategoryLabelText,
                                  track: shared
                                      .TrackConstants
                                      .menuCategoryPageTrack,
                                ) ??
                                'Category Name',
                            hintText:
                                context.tr(
                                  shared.LocaleKeys.menuCategoryHintText,
                                  track: shared
                                      .TrackConstants
                                      .menuCategoryPageTrack,
                                ) ??
                                'Enter the category name',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.tr(
                                    shared.LocaleKeys.menuCategoryNameErrorMsg,
                                    track: shared
                                        .TrackConstants
                                        .menuCategoryPageTrack,
                                  ) ??
                                  'Category name is required.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (String value) {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ).inExpandedRow(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      BlocConsumer<AddMenuCategoryCubit, AddMenuCategoryState>(
                        listener: (context, state) {},
                        builder: (context, state) {
                          if (state is AddMenuCategoryInitial) {
                            return Container();
                          } else if (state is AddMenuCategoryUpdated) {
                            return ListView.separated(
                              itemCount: state.subCategoryList.length,
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
                                        bottom:
                                            index ==
                                                state.subCategoryList.length - 1
                                            ? 10
                                            : 0,
                                      ),
                                      child:
                                          DynamicTextFormFieldForSubCategoryWidget(
                                            index: index,
                                            key: ValueKey('sub_category_$index'),
                                            initialValue:
                                                state.subCategoryList[index],
                                            onChanged: (value) async {
                                              _menuCategoryCubit
                                                  .onChangeSubCategory(
                                                    value,
                                                    index,
                                                  );
                                            },
                                            onDelete: () async {
                                              _menuCategoryCubit
                                                  .removeSubCategory(index);
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
                          } else {
                            return Container();
                          }
                        },
                      ).inExpandedRow(
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
                              AddNewMenuCategoryScreenActions.handleAddSubCategory(
                                _menuCategoryCubit,
                                primaryScrollController,
                              ),
                          // style: ElevatedButton.styleFrom(
                          //   padding: const EdgeInsets.all(10),
                          //   elevation: 5,
                          // ),
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.addMenuSubCategoryBtnText,
                                  track: shared
                                      .TrackConstants
                                      .menuCategoryPageTrack,
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

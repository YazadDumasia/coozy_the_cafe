import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'edit_menu_category_screen_actions.dart';

import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/edit_menu_category_bloc/edit_menu_category_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';

class EditMenuCategoryScreen extends StatefulWidget {
  final MenuCategory? category;
  const EditMenuCategoryScreen({required this.category, super.key});

  @override
  State<EditMenuCategoryScreen> createState() => _EditMenuCategoryScreenState();
}

class _EditMenuCategoryScreenState extends State<EditMenuCategoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode? menuCategoryNameFocusNode = FocusNode();
  TextEditingController? menuCategoryNameController = TextEditingController(
    text: '',
  );

  @override
  void initState() {
    super.initState();
    menuCategoryNameController = TextEditingController(text: '');
    menuCategoryNameFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<EditMenuCategoryBloc>(
        context,
      ).add(LoadEditMenuCategoryDataEvent(category: widget.category));
    });
  }

  Future<void> reload() async {
    BlocProvider.of<EditMenuCategoryBloc>(
      context,
    ).add(LoadEditMenuCategoryDataEvent(category: widget.category));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && context.mounted) {
            Navigator.pop(context, result);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              context.tr(
                    shared.LocaleKeys.editMenuCategoryAppbarText,
                    track: shared.TrackConstants.menuCategoryPageTrack,
                  ) ??
                  'Edit Menu Category',
            ),
            centerTitle: false,
            actions: <Widget>[
              IconButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  EditMenuCategoryScreenActions.handleSaveCategory(
                    context,
                    _formKey,
                    menuCategoryNameController!.text,
                    BlocProvider.of<EditMenuCategoryBloc>(context),
                  );
                },
                icon: Icon(Icons.check_circle),
                tooltip:
                    context.tr(
                      shared.LocaleKeys.commonSave,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Save',
              ),
            ],
          ),
          body: BlocConsumer<EditMenuCategoryBloc, EditMenuCategoryState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is EditMenuCategoryInitial ||
                  state is EditMenuCategoryLoadingState) {
                return const shared.LoadingPage();
              } else if (state is EditMenuCategoryLoadedState) {
                menuCategoryNameController!.text =
                    state.initialCategory?.name ?? '';
                return body();
              } else {
                return shared.ErrorPage(
                  onPressedRetryButton: () async {
                    BlocProvider.of<EditMenuCategoryBloc>(context).add(
                      LoadEditMenuCategoryDataEvent(category: widget.category),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: menuCategoryNameController,
                    focusNode: menuCategoryNameFocusNode,
                    autofocus: false,
                    decoration: InputDecoration(
                      labelText:
                          context.tr(
                            shared.LocaleKeys.menuCategoryLabelText,
                            track: shared.TrackConstants.menuCategoryPageTrack,
                          ) ??
                          'Category Name',
                      hintText:
                          context.tr(
                            shared.LocaleKeys.menuCategoryHintText,
                            track: shared.TrackConstants.menuCategoryPageTrack,
                          ) ??
                          'Enter the category name',
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.tr(
                              shared.LocaleKeys.menuCategoryNameErrorMsg,
                              track:
                                  shared.TrackConstants.menuCategoryPageTrack,
                            ) ??
                            'Category name is required.';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[Expanded(child: listView())],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      EditMenuCategoryScreenActions.handleAddSubCategory(
                        context,
                        BlocProvider.of<EditMenuCategoryBloc>(context),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      elevation: 5,
                    ),
                    child: Text(
                      context.tr(
                            shared.LocaleKeys.addMenuSubCategoryBtnText,
                            track: shared.TrackConstants.menuCategoryPageTrack,
                          ) ??
                          'Add new sub-category',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget listView() {
    return BlocConsumer<EditMenuCategoryBloc, EditMenuCategoryState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is EditMenuCategoryLoadedState) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Visibility(
              visible:
                  (state.listController == null ||
                      state.listController!.isEmpty)
                  ? false
                  : true,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount:
                    state.listController == null ||
                        state.listController!.isEmpty
                    ? 0
                    : state.listController!.length,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 15,
                            bottom:
                                index == (state.listController?.length ?? 0) - 1
                                ? 10
                                : 5,
                          ),
                          child: TextFormField(
                            controller: state.listController![index],
                            autofocus: false,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText:
                                  context.tr(
                                    shared
                                        .LocaleKeys
                                        .addNewMenuSubCategoryLabelText,
                                    track: shared
                                        .TrackConstants
                                        .menuCategoryPageTrack,
                                  ) ??
                                  'Sub-category Name',
                              hintText:
                                  context.tr(
                                    shared
                                        .LocaleKeys
                                        .addNewMenuSubCategoryLabelText,
                                    track: shared
                                        .TrackConstants
                                        .menuCategoryPageTrack,
                                  ) ??
                                  'Sub-category Name',
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  EditMenuCategoryScreenActions.handleDeleteSubCategory(
                                    context,
                                    BlocProvider.of<EditMenuCategoryBloc>(
                                      context,
                                    ),
                                    index,
                                  );
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ),
                            onChanged: (value) {
                              EditMenuCategoryScreenActions.handleUpdateSubCategory(
                                context,
                                BlocProvider.of<EditMenuCategoryBloc>(context),
                                index,
                                value,
                              );
                            },
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return context.tr(
                                      shared
                                          .LocaleKeys
                                          .addNewMenuSubCategoryErrorText,
                                      track: shared
                                          .TrackConstants
                                          .menuCategoryPageTrack,
                                    ) ??
                                    'Enter your sub-category name';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  //
  // Future<void> onSubmit() async {
  //   String? categoryName = menuCategoryNameController.text;
  //   debugPrint(
  //       EditMenuCategoryScreen, "onSubmit:categoryName:$categoryName");
  //   List<String?>? list =
  //       listController!.map((controller) => controller.text).toList();
  //   debugPrint(EditMenuCategoryScreen,
  //       "onSubmit:MenuSubcategory:${listController!.isEmpty ? null : json.encode(list)}");
  //   MenuCategory category = MenuCategory(
  //       id: initialCategory!.id,
  //       name: categoryName,
  //       createdDate:  DateUtil.CURRENT_TIMESTAMP;
  //
  //   debugPrint(EditMenuCategoryScreen,
  //       "onSubmit:initialCategory:${json.encode(category)}");
  //   var resCategory = await RestaurantRepository().updateCategory(category!);
  //   debugPrint(
  //       EditMenuCategoryScreen, "onSubmit:resCategory:${resCategory}");
  //
  //   var resDelete = await RestaurantRepository()
  //       .deleteAllSubcategoryBasedOnCategoryId(categoryId: initialCategory!.id);
  //   debugPrint(
  //       EditMenuCategoryScreen, "onSubmit:resDelete:${resDelete}");
  //
  //   if (list != null && list.isNotEmpty) {
  //     var res = await RestaurantRepository().insertSubCategoriesForCategoryId(
  //         categoryId: initialCategory!.id, subCategoriesList: list);
  //     debugPrint(EditMenuCategoryScreen, "onSubmit:res:${res}");
  //   }
  //   Navigator.of(context).pop();
  // }

  @override
  void dispose() {
    BlocProvider.of<EditMenuCategoryBloc>(context).close();
    super.dispose();
  }
}

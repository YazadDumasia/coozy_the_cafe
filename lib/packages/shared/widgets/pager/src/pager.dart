import 'package:coozy_the_cafe/packages/shared/config/app_extensions.dart';
import 'package:coozy_the_cafe/packages/shared/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/l10n/track_constants.dart';

class Pager extends StatefulWidget {
  Pager({
    required this.totalPages,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
    required this.itemsPerPageList,
    super.key,
    this.showItemsPerPage = false,
    this.currentItemsPerPage,
    this.pagesView = 3,
    this.currentPage = 1,
    this.numberButtonSelectedColor = Colors.blue,
    this.numberTextSelectedColor = Colors.white,
    this.numberTextUnselectedColor = Colors.black,
    this.pageChangeIconColor = Colors.grey,
    this.itemsPerPageText,
    this.itemsPerPageTextStyle,
    this.dropDownMenuItemTextStyle,
    this.itemsPerPageAlignment = Alignment.center,
  }) : assert(
         currentPage > 0 && totalPages > 0 && pagesView > 0,
         'Fatal Error: Make sure the currentPage, totalPages and pagesView fields are greater than zero.',
       ) {
    if (showItemsPerPage) {
      assert(
        currentItemsPerPage != null &&
            itemsPerPageList != null &&
            itemsPerPageList!.isNotEmpty,
        'Fatal error: OnItemsPerPageChanged must be implemented or itemsPerPageList is null or empty.',
      );
    }
    itemsPerPageListLocal = itemsPerPageList ?? <int>[];
  }

  late final List<int> itemsPerPageListLocal;

  final int pagesView;
  final int totalPages;
  final Function(int) onPageChanged;
  final bool showItemsPerPage;
  final int? currentItemsPerPage;
  final List<int>? itemsPerPageList;
  final Function(int?) onItemsPerPageChanged;
  final int currentPage;
  final Color numberButtonSelectedColor;
  final Color numberTextUnselectedColor;
  final Color numberTextSelectedColor;
  final Color pageChangeIconColor;
  final String? itemsPerPageText;
  final TextStyle? itemsPerPageTextStyle;
  final TextStyle? dropDownMenuItemTextStyle;
  final Alignment itemsPerPageAlignment;

  @override
  State<Pager> createState() => _PagerState();
}

class _PagerState extends State<Pager> {
  late int _currentPage;
  late int _pagesView;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
    _pagesView = widget.pagesView;
    if (widget.totalPages < _pagesView) {
      _pagesView = widget.totalPages;
    }
  }

  @override
  void didUpdateWidget(Pager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _currentPage = widget.currentPage;
    }
    if (oldWidget.pagesView != widget.pagesView) {
      _pagesView = widget.pagesView;
      if (widget.totalPages < _pagesView) {
        _pagesView = widget.totalPages;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  tooltip:
                      context.tr(
                        LocaleKeys.pagerFirstPage,
                        track: TrackConstants.commonTrack,
                      ) ??
                      'First Page',
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage = 1;
                            widget.onPageChanged(_currentPage);
                          });
                        }
                      : null,
                  splashRadius: 25,
                  icon: Icon(
                    Icons.first_page,
                    color: widget.pageChangeIconColor,
                  ),
                ),
                IconButton(
                  tooltip:
                      context.tr(
                        LocaleKeys.pagerPrevious,
                        track: TrackConstants.commonTrack,
                      ) ??
                      'Previous',
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage = _currentPage > 1
                                ? _currentPage - 1
                                : 1;
                            widget.onPageChanged(_currentPage);
                          });
                        }
                      : null,
                  splashRadius: 25,
                  icon: Icon(
                    Icons.chevron_left,
                    color: widget.pageChangeIconColor,
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (
                        int i = getPageStart(getPageEnd());
                        i < getPageEnd();
                        i++
                      )
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _currentPage = i;
                              widget.onPageChanged(_currentPage);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: _currentPage == i
                                ? widget.numberButtonSelectedColor
                                : null,
                          ),
                          child: Text(
                            '$i',
                            style: TextStyle(
                              color: _currentPage == i
                                  ? widget.numberTextSelectedColor
                                  : widget.numberTextUnselectedColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip:
                      context.tr(
                        LocaleKeys.pagerNextPage,
                        track: TrackConstants.commonTrack,
                      ) ??
                      'Next Page',
                  onPressed: _currentPage < widget.totalPages
                      ? () {
                          setState(() {
                            _currentPage = _currentPage < widget.totalPages
                                ? _currentPage + 1
                                : widget.totalPages;
                            widget.onPageChanged(_currentPage);
                          });
                        }
                      : null,
                  splashRadius: 25,
                  icon: Icon(
                    Icons.chevron_right,
                    color: widget.pageChangeIconColor,
                  ),
                ),
                IconButton(
                  tooltip:
                      context.tr(
                        LocaleKeys.pagerLastPage,
                        track: TrackConstants.commonTrack,
                      ) ??
                      'Last Page',
                  onPressed: _currentPage < widget.totalPages
                      ? () {
                          setState(() {
                            _currentPage = widget.totalPages;
                            widget.onPageChanged(_currentPage);
                          });
                        }
                      : null,
                  splashRadius: 25,
                  icon: Icon(
                    Icons.last_page,
                    color: widget.pageChangeIconColor,
                  ),
                ),
              ],
            ),
          ),
          if (widget.showItemsPerPage)
            Align(
              alignment: widget.itemsPerPageAlignment,
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: ItemsPerPage(
                  currentItemsPerPage: widget.currentItemsPerPage!,
                  itemsPerPage: widget.itemsPerPageListLocal,
                  onChanged: widget.onItemsPerPageChanged,
                  itemsPerPageText: widget.itemsPerPageText,
                  itemsPerPageTextStyle: widget.itemsPerPageTextStyle,
                  dropDownMenuItemTextStyle: widget.dropDownMenuItemTextStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  int getPageEnd() {
    return _currentPage + _pagesView > widget.totalPages
        ? widget.totalPages + 1
        : _currentPage + _pagesView;
  }

  int getPageStart(int pageEnd) {
    return pageEnd == widget.totalPages + 1
        ? pageEnd - _pagesView
        : _currentPage;
  }
}

class ItemsPerPage extends StatelessWidget {
  const ItemsPerPage({
    required this.currentItemsPerPage,
    required this.itemsPerPage,
    required this.onChanged,
    super.key,
    this.itemsPerPageText,
    this.itemsPerPageTextStyle,
    this.dropDownMenuItemTextStyle,
  });

  final int currentItemsPerPage;
  final List<int>? itemsPerPage;
  final void Function(int?) onChanged; // Updated type to accept nullable int
  final String? itemsPerPageText;
  final TextStyle? itemsPerPageTextStyle;
  final TextStyle? dropDownMenuItemTextStyle;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: currentItemsPerPage,
      onChanged: onChanged,
      items: itemsPerPage?.map((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(
            itemsPerPageText != null ? '$itemsPerPageText $value' : '$value',
            style: dropDownMenuItemTextStyle,
          ),
        );
      }).toList(),
      style: itemsPerPageTextStyle,
    );
  }
}

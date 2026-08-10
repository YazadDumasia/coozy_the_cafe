import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'az_common.dart';
import 'az_listview.dart';
import 'index_bar.dart';

/// Callback for loading more data. Should return true if more data was loaded, false if no more data.
typedef LoadMoreCallback = Future<bool> Function();

/// Callback for refreshing data.
typedef RefreshCallback = Future<void> Function();

/// Callback for retrying after error.
typedef RetryCallback = Future<void> Function();

/// PaginatedAzListView: AzListView with lazy loading, bottom loading/error, and pull-to-refresh.
class PaginatedAzListView extends StatefulWidget {
  const PaginatedAzListView({
    super.key,
    required this.data,
    required this.itemCount,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    this.susItemBuilder,
    this.susItemHeight = 40,
    this.susPosition,
    this.indexHintBuilder,
    this.indexBarData = const [],
    this.indexBarWidth = 30,
    this.indexBarHeight,
    this.indexBarItemHeight = 16,
    this.hapticFeedback = false,
    this.indexBarAlignment = Alignment.centerRight,
    this.indexBarMargin,
    this.indexBarOptions = const IndexBarOptions(),
    this.physics,
    this.padding,
    this.bottomErrorMessage = 'Failed to load more data.',
    this.bottomNoDataMessage = 'No more data.',
  });

  final List<ISuspensionBean> data;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final LoadMoreCallback onLoadMore;
  final RefreshCallback onRefresh;
  final IndexedWidgetBuilder? susItemBuilder;
  final double susItemHeight;
  final Offset? susPosition;
  final IndexHintBuilder? indexHintBuilder;
  final List<String> indexBarData;
  final double indexBarWidth;
  final double? indexBarHeight;
  final double indexBarItemHeight;
  final bool hapticFeedback;
  final AlignmentGeometry indexBarAlignment;
  final EdgeInsetsGeometry? indexBarMargin;
  final IndexBarOptions indexBarOptions;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final String bottomErrorMessage;
  final String bottomNoDataMessage;

  @override
  State<PaginatedAzListView> createState() => _PaginatedAzListViewState();
}

class _PaginatedAzListViewState extends State<PaginatedAzListView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _hasMore = true;
      _hasError = false;
    });
    await widget.onRefresh();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        _hasMore &&
        !_hasError) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _isLoadingMore = true;
      _hasError = false;
    });
    try {
      final bool loaded = await widget.onLoadMore();
      setState(() {
        _isLoadingMore = false;
        _hasMore = loaded;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _hasError = true;
      });
    }
  }

  Widget _buildBottomWidget() {
    if (_isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_hasError) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            children: [
              Text(
                widget.bottomErrorMessage,
                style: const TextStyle(color: Colors.red),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadMore,
                child: Text(
                  context.tr(
                        shared.LocaleKeys.commonRetry,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    } else if (!_hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text(widget.bottomNoDataMessage)),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: widget.physics,
        slivers: [
          SliverToBoxAdapter(
            child: AzListView(
              data: widget.data,
              itemCount: widget.itemCount,
              itemBuilder: widget.itemBuilder,
              susItemBuilder: widget.susItemBuilder,
              susItemHeight: widget.susItemHeight,
              susPosition: widget.susPosition,
              indexHintBuilder: widget.indexHintBuilder,
              indexBarData: widget.indexBarData,
              indexBarWidth: widget.indexBarWidth,
              indexBarHeight: widget.indexBarHeight,
              indexBarItemHeight: widget.indexBarItemHeight,
              hapticFeedback: widget.hapticFeedback,
              indexBarAlignment: widget.indexBarAlignment,
              indexBarMargin: widget.indexBarMargin,
              indexBarOptions: widget.indexBarOptions,
              physics: const NeverScrollableScrollPhysics(),
              padding: widget.padding,
            ),
          ),
          SliverToBoxAdapter(child: _buildBottomWidget()),
        ],
      ),
    );
  }
}

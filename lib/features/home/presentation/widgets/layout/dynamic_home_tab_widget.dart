import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zalando_clone_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:zalando_clone_app/features/home/domain/entities/page.dart' as home_page;
import 'dynamic_tab_widget.dart';
import '../dynamic_page_widget.dart'; // for HomeSkeleton

class DynamicHomeTabWidget extends StatefulWidget {
  final TabController outerTabController;
  final int outerTabIndex;
  final ScrollController? scrollController;

  const DynamicHomeTabWidget({
    super.key,
    required this.outerTabController,
    required this.outerTabIndex,
    this.scrollController,
  });

  @override
  State<DynamicHomeTabWidget> createState() => _DynamicHomeTabWidgetState();
}

class _DynamicHomeTabWidgetState extends State<DynamicHomeTabWidget>
    with TickerProviderStateMixin {
  TabController? _innerTabController;
  List<home_page.Page> _currentPages = [];
  final Set<int> _fetchedPageIds = <int>{};
  bool _listenerAttached = false;

  @override
  void initState() {
    super.initState();
    _createInnerTabController();
    
    // Load pages immediately if not already loaded
    // Add small delay to avoid simultaneous requests with other widgets
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_currentPages.isEmpty) {
        // Small delay to let welcome section load first
        await Future.delayed(const Duration(milliseconds: 100));
        const userId = 1; // In real app, get from auth state
        context.read<HomeBloc>().add(LoadPages(userId));
      }
    });
  }

  @override
  void dispose() {
    _innerTabController?.dispose();
    super.dispose();
  }

  void _createInnerTabController() {
    _innerTabController?.dispose();
    _listenerAttached = false; // reset so new controller gets a listener
    
    // Use current pages or default tabs
    final tabCount = _currentPages.isNotEmpty 
        ? _currentPages.length 
        : 1; // Default to 1 tab minimum to avoid mismatch
    
    _innerTabController = TabController(
      length: tabCount,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );

    _attachTabListener();
  }

  void _updateTabs(List<home_page.Page> pages) {
    if (!mounted) return;
    final incoming = List<home_page.Page>.from(pages)
      ..sort((a, b) => ((a.order ?? a.id).compareTo(b.order ?? b.id)));
    final current = List<home_page.Page>.from(_currentPages)
      ..sort((a, b) => ((a.order ?? a.id).compareTo(b.order ?? b.id)));

    bool changed = false;
    if (incoming.length != current.length) {
      changed = true;
    } else {
      for (int i = 0; i < incoming.length; i++) {
        final ia = incoming[i];
        final ic = current[i];
        if (ia.id != ic.id || (ia.order ?? ia.id) != (ic.order ?? ic.id)) {
          changed = true;
          break;
        }
      }
    }

    if (!changed) return;

    setState(() {
      _currentPages = incoming;
      _fetchedPageIds.clear();
      _createInnerTabController();
    });
    
    // Load components for the current tab after a brief delay to ensure controller is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentTabIfNeeded();
    });
  }

  void _attachTabListener() {
    if (_innerTabController == null || _listenerAttached) return;
    _innerTabController!.addListener(() {
      if (!_innerTabController!.indexIsChanging) {
        if (mounted) {
          setState(() {});
        }
        _loadCurrentTabIfNeeded();
      }
    });
    _listenerAttached = true;
  }

  void _loadCurrentTabIfNeeded() {
    if (_currentPages.isEmpty || _innerTabController == null) return;
    final int idx = _innerTabController!.index.clamp(0, _currentPages.length - 1);
    final home_page.Page page = _currentPages[idx];
    if (_fetchedPageIds.contains(page.id)) return;
    _fetchedPageIds.add(page.id);
    
    debugPrint('🔄 DynamicHomeTabWidget: Loading components for page ${page.id} (${page.name})');
    context.read<HomeBloc>().add(LoadPageComponents(
      componentId: page.id,
      page: 1,
      pageSize: 10,
      // When components are loaded as part of a full page refresh,
      // the cache will already have been cleared by the repo. Here
      // we keep `forceRefresh` false so normal tab switches can
      // still benefit from caching.
      forceRefresh: false,
    ));
  }

  Future<void> _refreshPages() async {
    // Clear fetched page IDs to force reload of all pages
    _fetchedPageIds.clear();
    
    // Reload pages data from the API, bypassing the local cache so that
    // pull‑to‑refresh always shows the latest content and then re‑caches it.
    const userId = 1; // In real app, get from auth state
    context.read<HomeBloc>().add(LoadPages(userId, forceRefresh: true));
    
    // Wait a bit for the pages to load
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeLoaded && state.pages.isNotEmpty) {
          _updateTabs(state.pages);
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // Listener above handles updates; avoid duplicating here

          if (_innerTabController == null) {
            // While the inner tab controller is initializing (or pages are
            // not yet available), show the same home skeleton used elsewhere.
            return const HomeSkeleton();
          }

          return RefreshIndicator(
            onRefresh: _refreshPages,
            child: DynamicTabWidget(
              innerTabController: _innerTabController!,
              outerTab: 'Logo',
              scrollController: widget.scrollController,
            ),
          );
        },
      ),
    );
  }
}

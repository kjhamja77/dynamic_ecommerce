import 'dart:async';

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
  final int userId;

  const DynamicHomeTabWidget({
    super.key,
    required this.outerTabController,
    required this.outerTabIndex,
    required this.userId,
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
        debugPrint(
          '🔁 DynamicHomeTabWidget:initState → dispatch LoadPages(userId=${widget.userId})',
        );
        context.read<HomeBloc>().add(LoadPages(widget.userId));
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
        if (ia.id != ic.id ||
            (ia.order ?? ia.id) != (ic.order ?? ic.id) ||
            ia.name != ic.name) {
          changed = true;
          break;
        }
      }
    }

    // Keep TabController.length in sync with pages even when the list content
    // is unchanged (e.g. Bloc skipped a duplicate emit, or a frame showed
    // truncated tabs before the controller was recreated).
    final desiredLen = incoming.isEmpty ? 1 : incoming.length;
    final controllerLen = _innerTabController?.length ?? 0;
    final needsControllerSync = controllerLen != desiredLen;

    debugPrint(
      '🧭 DynamicHomeTabWidget:_updateTabs userId=${widget.userId} '
      'incomingLen=${incoming.length} currentLen=${current.length} '
      'controllerLen=$controllerLen desiredLen=$desiredLen '
      'changed=$changed needsSync=$needsControllerSync '
      'incoming=[${incoming.map((p) => '${p.id}:${p.name}').join(', ')}]',
    );

    if (!changed && !needsControllerSync) return;

    setState(() {
      if (changed) {
        _currentPages = incoming;
        _fetchedPageIds.clear();
      }
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
    // Clear fetched page IDs so tab switches reload after pages list updates.
    _fetchedPageIds.clear();

    final bloc = context.read<HomeBloc>();
    final completer = Completer<void>();
    late final StreamSubscription<HomeState> sub;
    var sawFetching = false;
    sub = bloc.stream.listen((s) {
      if (s is HomeLoaded && s.isFetchingPages) {
        debugPrint(
          '🔄 DynamicHomeTabWidget:_refreshPages stream userId=${widget.userId} → isFetchingPages=true pages=${s.pages.length}',
        );
        sawFetching = true;
      } else if (sawFetching && s is HomeLoaded && !s.isFetchingPages) {
        debugPrint(
          '✅ DynamicHomeTabWidget:_refreshPages stream userId=${widget.userId} → isFetchingPages=false pages=${s.pages.length} names=[${s.pages.map((p) => p.name).join(', ')}]',
        );
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    debugPrint(
      '🔄 DynamicHomeTabWidget:_refreshPages → dispatch LoadPages(userId=${widget.userId}, forceRefresh=true)',
    );
    bloc.add(LoadPages(widget.userId, forceRefresh: true));

    try {
      await completer.future.timeout(const Duration(seconds: 15));
    } on TimeoutException {
      // Allow indicator to dismiss even if stream did not complete as expected.
    } finally {
      await sub.cancel();
      // Force tab controller sync even if the new pages equal the previous
      // state (Bloc may skip emit) or the UI was stuck with a short controller.
      if (mounted) {
        final s = bloc.state;
        if (s is HomeLoaded) {
          _updateTabs(s.pages);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        // Sync inner TabController whenever pages finish loading (including
        // empty or fewer tabs after API changes). Skip while fetch is in
        // flight so we don't apply stale pages mid-request.
        if (state is HomeLoaded && !state.isFetchingPages) {
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
              userId: widget.userId,
              scrollController: widget.scrollController,
              onTabCountMismatch: () {
                final s = context.read<HomeBloc>().state;
                if (s is HomeLoaded) {
                  _updateTabs(s.pages);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

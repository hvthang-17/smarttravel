import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'package:flutter/material.dart';
import '../providers/itinerary_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/core/theme/app_theme.dart';
import 'package:smarttravel_mobile/features/auth/data/models/user_model.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/itinerary/data/repositories/itinerary_repository.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/itinerary_guest_view.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/my_trip_card.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/my_trips_empty_state.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/itinerary/my_trips_summer_tip.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  bool _isLoading = true;
  bool _offline = false;
  bool _more = false;
  int _total = 0;
  int _page = 0;
  int _request = 0;
  String _period = 'ALL';
  String _query = '';
  final _search = TextEditingController();
  String? _errorMessage;
  List<ItineraryResponseModel> _trips = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = ref.read(authNotifierProvider);
      if (auth.isAuthenticated) {
        _loadTrips();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadTrips({bool append = false}) async {
    final token = ref.read(authNotifierProvider).token;
    if (token == null || (append && (_isLoading || !_more))) return;
    final request = ++_request;
    final page = append ? _page + 1 : 0;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(itineraryRepositoryProvider);
      final result = await repo.getSavedPage(_query, _period, page);
      if (mounted && request == _request && ref.read(authNotifierProvider).token == token) {
        setState(() {
          _trips = append
              ? {...{for (final trip in _trips) trip.id: trip},
                ...{for (final trip in result.items) trip.id: trip}}.values.toList()
              : result.items;
          _page = page;
          _more = result.hasNext;
          _total = result.total;
          _offline = result.cached || (append && _offline);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && request == _request && ref.read(authNotifierProvider).token == token) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _searchTrips(String value) {
    setState(() {
      _query = value.trim();
      _trips = [];
      _more = false;
    });
    _loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authNotifierProvider);
    ref.listen(tripListsRevisionProvider, (_, __) {
      if (ref.read(authNotifierProvider).isAuthenticated) _loadTrips();
    });

    ref.listen<UserState>(authNotifierProvider, (previous, next) {
      if (previous?.token == next.token) return;
      _request++;
      _search.clear();
      setState(() {
        _trips = [];
        _query = '';
        _period = 'ALL';
        _total = 0;
        _more = false;
        _offline = false;
        _errorMessage = null;
        _isLoading = next.isAuthenticated;
      });
      if (next.isAuthenticated) _loadTrips();
    });

    if (!userState.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppTheme.bgCanvas,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const AppText(
            'Lịch Trình',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ),
        body: const ItineraryGuestView(),
      );
    }

    final userName = userState.fullName?.isNotEmpty == true ? userState.fullName! : 'Minh';

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          'Lịch Trình',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: AppLanguage.text(context, 'Mở bản nháp'),
            icon: const Icon(Icons.edit_note),
            onPressed: () => context.push('/trip-drafts'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Semantics(
              label: 'Hồ sơ người dùng',
              button: true,
              child: InkWell(
                onTap: () => context.push('/profile'),
                borderRadius: BorderRadius.circular(16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryBlue,
                  child: AppText(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            maxLength: 255,
            onSubmitted: _searchTrips,
            decoration: InputDecoration(label: const AppText('Tìm theo tên chuyến đi'), counterText: '',
              prefixIcon: IconButton(tooltip: AppLanguage.text(context, 'Tìm kiếm'), icon: const Icon(Icons.search),
                onPressed: () => _searchTrips(_search.text)),
              suffixIcon: IconButton(tooltip: AppLanguage.text(context, 'Xóa tìm kiếm'), icon: const Icon(Icons.clear),
                onPressed: () { _search.clear(); _searchTrips(''); })),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(spacing: 8, children: [
            for (final (period, label) in [('ALL', 'Tất cả'), ('UPCOMING', 'Hiện tại / sắp tới'), ('HISTORY', 'Lịch sử')])
              ChoiceChip(label: AppText(label), selected: _period == period, onSelected: (_) {
                if (_period == period) return;
                setState(() => _period = period);
                _searchTrips(_query);
              }),
          ]),
        ),
        if (_isLoading) const LinearProgressIndicator(),
        Expanded(child: _errorMessage != null && _trips.isEmpty
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: () => _loadTrips(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      if (_offline)
                        const ListTile(dense: true, leading: Icon(Icons.cloud_off),
                          title: AppText('Đang xem danh sách tải gần nhất')),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                'Lịch trình của tôi',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                '$_total chuyến đi',
                                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                              ),
                            ],
                          )),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () => context.push('/trip-wizard'),
                            icon: const Icon(Icons.add, size: 16),
                            label: const AppText('Tạo mới', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (_trips.isEmpty && !_isLoading)
                        if (_period == 'ALL' && _query.isEmpty) const MyTripsEmptyState()
                        else const Padding(padding: EdgeInsets.symmetric(vertical: 24),
                          child: AppText('Không có chuyến đi phù hợp.'))
                      else
                        for (final trip in _trips) MyTripCard(key: ValueKey(trip.id), trip: trip),
                      if (_errorMessage != null)
                        AppText(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      if (_more)
                        OutlinedButton(onPressed: _isLoading ? null : () => _loadTrips(append: true),
                          child: const AppText('Tải thêm chuyến đi')),
                      const SizedBox(height: 12),
                      const MyTripsSummerTip(),
                      const SizedBox(height: 32),
                    ],
                  ),
                )),
      ]),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 18),
            const AppText(
              'Không thể tải lịch trình',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            AppText(
              _errorMessage ?? 'Đã có lỗi xảy ra trong quá trình kết nối tới máy chủ.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loadTrips,
              icon: const Icon(Icons.refresh, size: 18),
              label: const AppText('Thử lại', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

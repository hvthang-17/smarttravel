import 'package:smarttravel_mobile/core/localization/app_language.dart';
import 'dart:convert';
import 'dart:math';
import 'package:smarttravel_mobile/features/destination/data/models/destination_model.dart';
import '../../data/models/trip_dates.dart';
import '../widgets/wizard/wizard_constraints.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/favorite_provider.dart';
import '../widgets/wizard/wizard_favorites.dart';
import 'package:smarttravel_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:smarttravel_mobile/features/auth/data/models/traveler_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/itinerary/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/providers/itinerary_provider.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/wizard/wizard_step_1_duration.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/wizard/wizard_step_2_budget.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/wizard/wizard_step_3_preferences.dart';
import 'package:smarttravel_mobile/features/itinerary/presentation/widgets/wizard/wizard_step_4_details.dart';

class TripWizardScreen extends ConsumerStatefulWidget {
  const TripWizardScreen({super.key, this.initialFavoriteId});

  final int? initialFavoriteId;

  @override
  ConsumerState<TripWizardScreen> createState() => _TripWizardScreenState();
}

class _TripWizardScreenState extends ConsumerState<TripWizardScreen> {
  int _currentStep = 1;

  // Step 1: Duration
  int _selectedDays = 3;
  DateTime _startDate = planningToday().add(const Duration(days: 1));

  // Step 2: Budget & Travelers
  int _budgetVnd = 5000000;
  int _travelersCount = 2;

  // Step 3: Preferences
  Set<String> _selectedCategories = <String>{};
  String _selectedPace = 'balanced';
  Set<int> _favoriteIds = {};
  final _required = <int, DestinationModel>{};
  final _excluded = <int, DestinationModel>{};
  final _generationKeys = <String, String>{};
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  late final TextEditingController _budgetController;
  bool _submitting = false;
  String? _generationError;
  bool _hasAdvanced = false;
  int get _capacity => min(28, _selectedDays * (switch (_selectedPace) {
    'relaxed' => 5, 'packed' => 7, _ => 6,
  }));

  // Step 4: Details
  late final TextEditingController _titleController;
  late final TextEditingController _startingPointController;
  String _selectedTransport = 'motorbike';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Chuyến đi Đà Nẵng 3 ngày 2 đêm');
    _startingPointController = TextEditingController();
    final initialFavorite = widget.initialFavoriteId;
    if (initialFavorite != null && initialFavorite > 0) _favoriteIds.add(initialFavorite);
    _budgetController = TextEditingController();
    _applyProfile(ref.read(authNotifierProvider).travelerProfile);
  }

  void _applyProfile(TravelerProfile? profile) {
    _selectedCategories = profile?.preferredCategories.toSet() ?? {};
    _selectedPace = profile?.defaultPace ?? 'balanced';
    _budgetVnd = profile?.defaultBudgetVnd ?? 5000000;
    _selectedTransport = profile?.defaultTransport ?? 'motorbike';
    _budgetController.text = _budgetVnd.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startingPointController.dispose();
    _budgetController.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  void _onDaysChanged(int days) {
    setState(() {
      _selectedDays = days;
      final nights = days > 1 ? '${days - 1} đêm' : '';
      final durationStr = nights.isNotEmpty ? '$days ngày $nights' : '1 ngày';
      _titleController.text = 'Chuyến đi Đà Nẵng $durationStr';
    });
  }

  void _nextStep() {
    if (_submitting) return;
    if (_currentStep == 1 && !_validDates()) return;
    if (_currentStep == 2 && _budgetVnd <= 0) {
      _feedback('Nhập ngân sách lớn hơn 0.');
      return;
    }
    if (_currentStep < 4) {
      _hasAdvanced = true;
      setState(() => _currentStep++);
      if (_currentStep == 3) ref.read(favoritesProvider.notifier).reload();
    } else {
      _submitWizard();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      if (context.canPop()) context.pop();
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  bool _validDates() {
    final today = planningToday();
    final end = _startDate.add(Duration(days: _selectedDays - 1));
    if (!_startDate.isBefore(today) && !end.isAfter(today.add(const Duration(days: 365)))) return true;
    _feedback('Ngày chuyến đi phải nằm trong khoảng từ hôm nay đến 365 ngày tới.');
    return false;
  }

  void _feedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AppText(message)));
  }

  double? _parseCoordinate(String raw, int boundary) {
    final text = raw.trim().replaceAll(',', '.');
    if (!RegExp(r'^[+-]?\d+(?:\.\d{1,7})?$').hasMatch(text)) return null;
    final value = double.tryParse(text);
    return value != null && value.abs() <= boundary ? value : null;
  }

  String _newGenerationKey() {
    final random = Random.secure();
    return List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> _submitWizard() async {
    if (_submitting) return;
    if (!ref.read(authNotifierProvider).isAuthenticated) {
      _showLoginRequiredDialog();
      return;
    }
    if (!_validDates()) return;
    if (_budgetVnd <= 0) {
      _feedback('Nhập ngân sách lớn hơn 0 ở bước Ngân sách.');
      return;
    }
    final activeCodes = ref.read(profileCategoriesProvider).valueOrNull;
    if (_selectedCategories.isNotEmpty && (activeCodes == null || !_selectedCategories.every(activeCodes.contains))) {
      _feedback('Kiểm tra danh mục ở bước Sở thích trước khi tạo chuyến.');
      return;
    }
    if (_favoriteIds.isNotEmpty) {
      final available = ref.read(favoritesProvider).valueOrNull;
      if (available == null || !_favoriteIds.every((id) => available.any((item) => item.id == id))) {
        _feedback('Kiểm tra lại các điểm đã lưu ở bước Sở thích.');
        return;
      }
    }

    final lat = _parseCoordinate(_latitude.text, 90);
    final lon = _parseCoordinate(_longitude.text, 180);
    final hasCoordinateInput = _latitude.text.trim().isNotEmpty || _longitude.text.trim().isNotEmpty;
    if (hasCoordinateInput && (lat == null || lon == null)) {
      _feedback('Nhập đủ vĩ độ −90 đến 90 và kinh độ −180 đến 180, tối đa 7 số thập phân.');
      return;
    }

    final end = _startDate.add(Duration(days: _selectedDays - 1));
    final title = _titleController.text.trim();
    final origin = _startingPointController.text.trim();
    final input = ItineraryRequestModel(
      title: title.isEmpty ? 'Chuyến đi Đà Nẵng $_selectedDays ngày' : title,
      startDate: _formatDate(_startDate),
      endDate: _formatDate(end),
      travelersCount: _travelersCount,
      maxBudgetVnd: _budgetVnd,
      pace: _selectedPace,
      transport: _selectedTransport,
      originName: origin.isEmpty ? null : origin,
      originLatitude: lat,
      originLongitude: lon,
      preferredCategories: _selectedCategories.toList()..sort(),
      favoriteDestinationIds: _favoriteIds.toList(),
      requiredDestinationIds: _required.keys.toList()..sort(),
      excludedDestinationIds: _excluded.keys.toList()..sort(),
    );
    final key = _generationKeys.putIfAbsent(jsonEncode(input.toJson()), _newGenerationKey);
    setState(() {
      _submitting = true;
      _generationError = null;
    });
    try {
      final result = await ref.read(itineraryNotifierProvider.notifier)
          .generateItinerary(input.withGenerationKey(key));
      if (!mounted) return;
      if (result != null) {
        ref.invalidate(tripDraftsProvider);
        context.push('/itineraries/${result.id}');
      } else {
        final error = ref.read(itineraryNotifierProvider).errorMessage ?? 'Không thể tạo lịch trình. Hãy thử lại.';
        setState(() => _generationError = error);
        if (_favoriteIds.isNotEmpty) await ref.read(favoritesProvider.notifier).reload();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showLoginRequiredDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          title: const AppText('Yêu cầu đăng nhập'),
          content: const AppText(
            'Vui lòng đăng nhập tài khoản để lưu trữ và quản lý lịch trình cá nhân của bạn.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const AppText('Để sau', style: TextStyle(color: Color(0xFF64748B))),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0077B6),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push('/login');
              },
              child: const AppText('Đăng nhập ngay'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider.select((user) => user.travelerProfile), (_, profile) {
      if (!_hasAdvanced) setState(() => _applyProfile(profile));
    });
    final categories = ref.watch(profileCategoriesProvider);
    final progress = _currentStep / 4.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: _submitting ? null : _previousStep,
        ),
        title: AppText(
          'Bước $_currentStep / 4',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0077B6)),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey(_currentStep),
                padding: const EdgeInsets.all(16),
                child: _buildCurrentStep(categories),
              ),
            ),
            if (_currentStep == 4 && _generationError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Semantics(
                  liveRegion: true,
                  child: AppText(
                    _generationError!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(AsyncValue<List<String>> categories) {
    switch (_currentStep) {
      case 1:
        return WizardStep1Duration(
          selectedDays: _selectedDays,
          startDate: _startDate,
          onDaysChanged: _onDaysChanged,
          onDateChanged: (d) => setState(() => _startDate = d),
        );
      case 2:
        return WizardStep2Budget(
          budgetVnd: _budgetVnd,
          budgetController: _budgetController,
          travelersCount: _travelersCount,
          onBudgetChanged: (b) => setState(() => _budgetVnd = b),
          onTravelersChanged: (c) => setState(() => _travelersCount = c),
        );
      case 3:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          WizardStep3Preferences(
          selectedCategories: _selectedCategories,
          availableCategories: categories,
          selectedPace: _selectedPace,
          onCategoriesChanged: (cats) =>
              setState(() => _selectedCategories = cats),
          onPaceChanged: (p) => setState(() => _selectedPace = p),
          ),
          const SizedBox(height: 20),
          WizardFavorites(selected: _favoriteIds, excluded: _excluded.keys.toSet(), capacity: _capacity,
            onChange: (ids) => setState(() => _favoriteIds = ids)),
          const SizedBox(height: 20),
          WizardConstraints(
            requiredPoints: _required.values.toList(), excludedPoints: _excluded.values.toList(),
            favoriteIds: _favoriteIds,
            onPick: (required, point) => setState(() => (required ? _required : _excluded)[point.id!] = point),
            onRemove: (required, id) => setState(() => (required ? _required : _excluded).remove(id)),
          ),
        ]);
      case 4:
        return WizardStep4Details(
          titleController: _titleController,
          startingPointController: _startingPointController,
          latitudeController: _latitude,
          longitudeController: _longitude,
          selectedTransport: _selectedTransport,
          onTransportChanged: (t) => setState(() => _selectedTransport = t),
          totalDays: _selectedDays,
          travelersCount: _travelersCount,
          budgetVnd: _budgetVnd,
          pace: _selectedPace,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == 4;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: isLastStep ? 52 : 48,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor:
                isLastStep ? const Color(0xFFF77F00) : const Color(0xFF0077B6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _submitting ? null : _nextStep,
          child: AppText(
            _submitting ? 'Đang tạo bản nháp…' : isLastStep ? 'Tạo bản nháp' : 'Tiếp tục',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

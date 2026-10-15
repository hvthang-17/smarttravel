import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttravel_mobile/features/destination/data/models/itinerary_model.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/auth_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/providers/itinerary_provider.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/wizard/wizard_step_1_duration.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/wizard/wizard_step_2_budget.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/wizard/wizard_step_3_preferences.dart';
import 'package:smarttravel_mobile/features/destination/presentation/widgets/wizard/wizard_step_4_details.dart';

class TripWizardScreen extends ConsumerStatefulWidget {
  const TripWizardScreen({super.key});

  @override
  ConsumerState<TripWizardScreen> createState() => _TripWizardScreenState();
}

class _TripWizardScreenState extends ConsumerState<TripWizardScreen> {
  int _currentStep = 1;

  // Step 1: Duration
  int _selectedDays = 3;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));

  // Step 2: Budget & Travelers
  int _budgetVnd = 5000000;
  int _travelersCount = 2;

  // Step 3: Preferences
  Set<String> _selectedCategories = {'Tham quan', 'Ăn uống', 'Biển'};
  String _selectedPace = 'balanced';

  // Step 4: Details
  late final TextEditingController _titleController;
  late final TextEditingController _startingPointController;
  String _selectedTransport = 'Xe máy';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Chuyến đi Đà Nẵng 3 ngày 2 đêm');
    _startingPointController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startingPointController.dispose();
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
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _submitWizard();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submitWizard() async {
    final authState = ref.read(authNotifierProvider);
    if (authState.token == null || authState.token!.isEmpty) {
      _showLoginRequiredDialog();
      return;
    }

    final endDate = _startDate.add(Duration(days: _selectedDays - 1));
    final request = ItineraryRequestModel(
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'Chuyến đi Đà Nẵng $_selectedDays ngày',
      startDate: _formatDate(_startDate),
      endDate: _formatDate(endDate),
      travelersCount: _travelersCount,
      maxBudgetVnd: _budgetVnd,
      pace: _selectedPace,
      preferredCategories: _selectedCategories.toList(),
    );

    _showLoadingDialog();

    final result = await ref
        .read(itineraryNotifierProvider.notifier)
        .generateItinerary(request);

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading
      if (result != null) {
        _showSuccessDialog(result);
      } else {
        final err = ref.read(itineraryNotifierProvider).errorMessage ??
            'Không thể tạo lịch trình, vui lòng thử lại';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: const Color(0xFFE76F51),
          ),
        );
      }
    }
  }

  void _showLoadingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return const Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0077B6)),
                ),
                SizedBox(height: 20),
                Text(
                  'Đang tạo lịch trình...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Hệ thống đang phân tích điểm đến và tối ưu cung đường theo sở thích của bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLoginRequiredDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          title: const Text('Yêu cầu đăng nhập'),
          content: const Text(
            'Vui lòng đăng nhập tài khoản để lưu trữ và quản lý lịch trình cá nhân của bạn.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Để sau', style: TextStyle(color: Color(0xFF64748B))),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0077B6),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push('/login');
              },
              child: const Text('Đăng nhập ngay'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(ItineraryResponseModel itinerary) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF2A9D8F), size: 26),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tạo lịch trình thành công!',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itinerary.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text('• Thời lượng: ${itinerary.totalDays} ngày'),
              Text('• Số người: ${itinerary.travelersCount} người'),
              Text(
                '• Chi phí ước tính: ${(itinerary.totalEstimatedCost / 1000).toStringAsFixed(0)}.000 VNĐ',
              ),
              Text('• Số ngày lên kế hoạch: ${itinerary.days.length} ngày'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/');
              },
              child: const Text('Về trang chủ', style: TextStyle(color: Color(0xFF64748B))),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0077B6),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push('/itineraries/${itinerary.id}');
              },
              child: const Text('Xem lịch trình & Bản đồ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentStep / 4.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: _previousStep,
        ),
        title: Text(
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
                padding: const EdgeInsets.all(16),
                child: _buildCurrentStep(),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
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
          travelersCount: _travelersCount,
          onBudgetChanged: (b) => setState(() => _budgetVnd = b),
          onTravelersChanged: (c) => setState(() => _travelersCount = c),
        );
      case 3:
        return WizardStep3Preferences(
          selectedCategories: _selectedCategories,
          selectedPace: _selectedPace,
          onCategoriesChanged: (cats) =>
              setState(() => _selectedCategories = cats),
          onPaceChanged: (p) => setState(() => _selectedPace = p),
        );
      case 4:
        return WizardStep4Details(
          titleController: _titleController,
          startingPointController: _startingPointController,
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
          onPressed: _nextStep,
          child: Text(
            isLastStep ? 'Tạo lịch trình' : 'Tiếp tục',
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

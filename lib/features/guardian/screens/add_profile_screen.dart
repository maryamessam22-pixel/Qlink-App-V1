import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../services/providers.dart';
import '../../../services/supabase_service.dart';

class AddProfileScreen extends ConsumerStatefulWidget {
  const AddProfileScreen({super.key});

  @override
  ConsumerState<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends ConsumerState<AddProfileScreen> {
  int _step = 1;
  bool _loading = false;
  String? _createdProfileId;

  // Step 1 fields
  final _nameCtrl = TextEditingController();
  final _relCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _primaryPhoneCtrl = TextEditingController();
  final List<TextEditingController> _extraPhones = [];

  // Step 2 fields
  String? _bloodType;
  final _allergiesCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _safetyNotesCtrl = TextEditingController();

  // Step 3 fields
  String _deviceType = 'Qlink Bracelet';
  final _codeCtrl = TextEditingController();
  String? _deviceError;
  String? _deviceSuccess;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relCtrl.dispose();
    _yearCtrl.dispose();
    _primaryPhoneCtrl.dispose();
    for (final c in _extraPhones) c.dispose();
    _allergiesCtrl.dispose();
    _conditionsCtrl.dispose();
    _safetyNotesCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitStep1() async {
    if (!_step1Key.currentState!.validate()) return;
    setState(() { _loading = true; });
    try {
      final user = ref.read(currentUserProvider)!;
      final phones = [
        _primaryPhoneCtrl.text.trim(),
        ..._extraPhones.map((c) => c.text.trim()).where((p) => p.isNotEmpty),
      ];
      final profile = await ref.read(profilesNotifierProvider.notifier).addProfile(
        guardianId: user.id,
        name: _nameCtrl.text.trim(),
        relationship: _relCtrl.text.trim().isEmpty ? null : _relCtrl.text.trim(),
        birthYear: int.tryParse(_yearCtrl.text.trim()),
        emergencyPhones: phones,
      );
      _createdProfileId = profile.id;
      setState(() { _step = 2; });
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitStep2() async {
    if (_createdProfileId == null) return;
    setState(() { _loading = true; });
    try {
      await SupabaseService.updateProfile(_createdProfileId!, {
        if (_bloodType != null) 'blood_type': _bloodType,
        if (_allergiesCtrl.text.isNotEmpty) 'allergies': _allergiesCtrl.text.trim(),
        if (_conditionsCtrl.text.isNotEmpty) 'conditions': _conditionsCtrl.text.trim(),
        if (_safetyNotesCtrl.text.isNotEmpty) 'safety_notes': _safetyNotesCtrl.text.trim(),
      });
      setState(() { _step = 3; });
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _connectDevice() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _deviceError = 'Enter the bracelet code');
      return;
    }
    setState(() { _loading = true; _deviceError = null; _deviceSuccess = null; });
    try {
      final device = await SupabaseService.connectDevice(code, _createdProfileId!);
      if (device != null) {
        setState(() => _deviceSuccess = 'Bracelet connected successfully!');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) context.go('/guardian');
      } else {
        setState(() => _deviceError = 'Bracelet code not found. Check the box and try again.');
      }
    } catch (e) {
      setState(() => _deviceError = 'Connection failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => _step > 1 ? setState(() => _step--) : context.pop(),
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios_new, size: 16,
                  color: _step == 1 ? AppColors.error : AppColors.textPrimary),
              Text(_step == 1 ? 'Cancel' : 'Back',
                  style: TextStyle(
                      color: _step == 1 ? AppColors.error : AppColors.textPrimary)),
            ],
          ),
        ),
        leadingWidth: 90,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Generate Patient Profile', style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                StepProgressBar(currentStep: _step, totalSteps: 3),
                const SizedBox(height: 6),
                Text(
                  _step == 1
                      ? 'Step 1 of 3: Identity'
                      : _step == 2
                          ? 'Step 2 of 3: Medical'
                          : 'Step 3 of 3: Hardware Link',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _step == 1
                  ? _buildStep1()
                  : _step == 2
                      ? _buildStep2()
                      : _buildStep3(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: "Patient's Full Name",
            hint: 'e.g., Mohamed Saber',
            controller: _nameCtrl,
            validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Relationship to You',
            hint: 'e.g., Grandfather',
            controller: _relCtrl,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Birth Year',
            hint: 'e.g., 1945',
            controller: _yearCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Text('EMERGENCY CONTACT * (Primary Guardian Phone)',
              style: AppTextStyles.labelMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _primaryPhoneCtrl,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.bodyMedium,
            validator: (v) => (v == null || v.isEmpty) ? 'Primary contact required' : null,
            decoration: InputDecoration(hintText: 'e.g., 01119988299'),
          ),
          const SizedBox(height: 12),

          // Extra phones
          ..._extraPhones.asMap().entries.map((entry) {
            final i = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Additional Contact ${i + 1}',
                      style: AppTextStyles.labelMedium),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _extraPhones[i],
                          keyboardType: TextInputType.phone,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                              hintText: 'e.g., 01779998265'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error.withOpacity(0.4)),
                        ),
                        child: IconButton(
                          onPressed: () => setState(() {
                            _extraPhones[i].dispose();
                            _extraPhones.removeAt(i);
                          }),
                          icon: const Icon(Icons.close, color: AppColors.error, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          GestureDetector(
            onTap: () => setState(() => _extraPhones.add(TextEditingController())),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_box_outlined,
                      color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text('Add More Contact Number',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.primaryBlue)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          GradientButton(
            label: 'Continue to Medical Info',
            icon: Icons.arrow_forward,
            onTap: _submitStep1,
            isLoading: _loading,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Safety Notes',
            hint: 'e.g., Additional safety information',
            controller: _safetyNotesCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Allergies',
            hint: 'e.g., Penicillin, Peanuts, Shellfish',
            controller: _allergiesCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text('Blood Type', style: AppTextStyles.labelMedium),
          const SizedBox(height: 10),
          BloodTypeSelector(
            selected: _bloodType,
            onSelect: (t) => setState(() => _bloodType = t),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Medical Notes',
            hint: 'e.g., Diabetic',
            controller: _conditionsCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 32),

          GradientButton(
            label: 'Continue',
            icon: Icons.arrow_forward,
            onTap: _submitStep2,
            isLoading: _loading,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Text(
            'Find the activation card inside your Qlink bracelet box. Enter the credentials to link this hardware to the patient profile.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.5),
          ),
        ),
        const SizedBox(height: 20),

        Text('Device Type', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _deviceType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
          ),
          items: ['Qlink Bracelet', 'Qlink Smart Bracelet "Nova"',
                  'Qlink Smart Bracelet "Pulse"', 'Apple Watch', 'Smartwatch']
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _deviceType = v ?? 'Qlink Bracelet'),
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: 'Enter Code (Inside the bracelet box)',
          hint: 'QLINK-PULSE-8A3F2E',
          controller: _codeCtrl,
        ),

        if (_deviceError != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_deviceError!,
                style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        ],

        if (_deviceSuccess != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_deviceSuccess!,
                style: const TextStyle(color: AppColors.success, fontSize: 13)),
          ),
        ],

        const SizedBox(height: 32),

        GradientButton(
          label: 'Connect the Bracelet',
          onTap: _connectDevice,
          isLoading: _loading,
        ),
        const SizedBox(height: 12),
        OutlineAppButton(
          label: 'Skip this step for now',
          onTap: () => context.go('/guardian'),
          borderColor: AppColors.primaryNavy,
          textColor: AppColors.primaryNavy,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

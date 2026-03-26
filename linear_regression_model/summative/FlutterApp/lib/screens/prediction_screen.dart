import 'package:flutter/material.dart';
import '../models/student_input.dart';
import '../services/prediction_service.dart';
import '../widgets/numeric_card.dart';
import '../widgets/chip_selector.dart';
import '../widgets/result_card.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  int  _currentStep  = 0;
  bool _goingForward = true;

  // ── Numeric controllers ──────────────────────────────────────────────────
  final _hoursCtrl      = TextEditingController();
  final _attendanceCtrl = TextEditingController();
  final _sleepCtrl      = TextEditingController();
  final _prevScoreCtrl  = TextEditingController();
  final _tutoringCtrl   = TextEditingController();
  final _physicalCtrl   = TextEditingController();

  // ── Categorical state ────────────────────────────────────────────────────
  String _parentalInvolvement    = 'Medium';
  String _accessToResources      = 'Medium';
  String _extracurricular        = 'No';
  String _motivationLevel        = 'Medium';
  String _internetAccess         = 'Yes';
  String _familyIncome           = 'Medium';
  String _teacherQuality         = 'Medium';
  String _schoolType             = 'Public';
  String _peerInfluence          = 'Neutral';
  String _learningDisabilities   = 'No';
  String _parentalEducationLevel = 'College';
  String _distanceFromHome       = 'Near';

  double? _predictedScore;
  bool    _isLoading    = false;
  String? _errorMessage;

  static const _kNavy = Color(0xFF0F3460);

  static const _stepTitles = [
    'Academic Profile',
    'Learning Environment',
    'Prediction Result',
  ];

  static const _stepSubs = [
    'Enter your academic details below',
    'Describe your study environment',
    'Here is your predicted exam score',
  ];

  @override
  void dispose() {
    _hoursCtrl.dispose();
    _attendanceCtrl.dispose();
    _sleepCtrl.dispose();
    _prevScoreCtrl.dispose();
    _tutoringCtrl.dispose();
    _physicalCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  void _goTo(int step, {bool forward = true}) {
    setState(() {
      _goingForward = forward;
      _currentStep  = step;
    });
  }

  void _onNext() {
    if (_currentStep == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      _goTo(1, forward: true);
    } else if (_currentStep == 1) {
      _runPrediction();
    }
  }

  void _onBack() {
    if (_currentStep > 0) _goTo(_currentStep - 1, forward: false);
  }

  void _onReset() {
    _hoursCtrl.clear();
    _attendanceCtrl.clear();
    _sleepCtrl.clear();
    _prevScoreCtrl.clear();
    _tutoringCtrl.clear();
    _physicalCtrl.clear();
    setState(() {
      _parentalInvolvement    = 'Medium';
      _accessToResources      = 'Medium';
      _extracurricular        = 'No';
      _motivationLevel        = 'Medium';
      _internetAccess         = 'Yes';
      _familyIncome           = 'Medium';
      _teacherQuality         = 'Medium';
      _schoolType             = 'Public';
      _peerInfluence          = 'Neutral';
      _learningDisabilities   = 'No';
      _parentalEducationLevel = 'College';
      _distanceFromHome       = 'Near';
      _predictedScore         = null;
      _errorMessage           = null;
    });
    _goTo(0, forward: false);
  }

  // ── API call ─────────────────────────────────────────────────────────────

  Future<void> _runPrediction() async {
    setState(() {
      _isLoading      = true;
      _errorMessage   = null;
      _predictedScore = null;
    });
    _goTo(2, forward: true);

    try {
      final input = StudentInput(
        hoursStudied:              int.parse(_hoursCtrl.text),
        attendance:                int.parse(_attendanceCtrl.text),
        sleepHours:                int.parse(_sleepCtrl.text),
        previousScores:            int.parse(_prevScoreCtrl.text),
        tutoringSessions:          int.parse(_tutoringCtrl.text),
        physicalActivity:          int.parse(_physicalCtrl.text),
        parentalInvolvement:       _parentalInvolvement,
        accessToResources:         _accessToResources,
        extracurricularActivities: _extracurricular,
        motivationLevel:           _motivationLevel,
        internetAccess:            _internetAccess,
        familyIncome:              _familyIncome,
        teacherQuality:            _teacherQuality,
        schoolType:                _schoolType,
        peerInfluence:             _peerInfluence,
        learningDisabilities:      _learningDisabilities,
        parentalEducationLevel:    _parentalEducationLevel,
        distanceFromHome:          _distanceFromHome,
      );
      final score = await PredictionService.predict(input);
      setState(() => _predictedScore = score);
    } catch (e) {
      setState(() =>
          _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Step builders ─────────────────────────────────────────────────────────

  Widget _buildStep0() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _row(
            NumericCard(
              label: 'Hours Studied / Week',
              icon: Icons.menu_book_rounded,
              controller: _hoursCtrl,
              min: 1, max: 44,
            ),
            NumericCard(
              label: 'Attendance',
              icon: Icons.calendar_today_rounded,
              controller: _attendanceCtrl,
              min: 60, max: 100,
              unit: '%',
            ),
          ),
          const SizedBox(height: 14),
          _row(
            NumericCard(
              label: 'Sleep Hours / Day',
              icon: Icons.bedtime_rounded,
              controller: _sleepCtrl,
              min: 4, max: 10,
              unit: 'hrs',
            ),
            NumericCard(
              label: 'Previous Score',
              icon: Icons.assignment_rounded,
              controller: _prevScoreCtrl,
              min: 50, max: 100,
              unit: 'pts',
            ),
          ),
          const SizedBox(height: 14),
          _row(
            NumericCard(
              label: 'Tutoring / Month',
              icon: Icons.people_alt_rounded,
              controller: _tutoringCtrl,
              min: 0, max: 8,
            ),
            NumericCard(
              label: 'Physical Activity',
              icon: Icons.fitness_center_rounded,
              controller: _physicalCtrl,
              min: 0, max: 6,
              unit: 'hrs/wk',
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        ChipSelector(label: 'Parental Involvement',        icon: Icons.family_restroom_rounded,       value: _parentalInvolvement,    options: const ['Low', 'Medium', 'High'],                    onChanged: (v) => setState(() => _parentalInvolvement    = v)),
        ChipSelector(label: 'Access to Resources',         icon: Icons.library_books_rounded,         value: _accessToResources,       options: const ['Low', 'Medium', 'High'],                    onChanged: (v) => setState(() => _accessToResources       = v)),
        ChipSelector(label: 'Extracurricular Activities',  icon: Icons.sports_soccer_rounded,         value: _extracurricular,         options: const ['Yes', 'No'],                                onChanged: (v) => setState(() => _extracurricular         = v)),
        ChipSelector(label: 'Motivation Level',            icon: Icons.bolt_rounded,                  value: _motivationLevel,         options: const ['Low', 'Medium', 'High'],                    onChanged: (v) => setState(() => _motivationLevel         = v)),
        ChipSelector(label: 'Internet Access at Home',     icon: Icons.wifi_rounded,                  value: _internetAccess,          options: const ['Yes', 'No'],                                onChanged: (v) => setState(() => _internetAccess          = v)),
        ChipSelector(label: 'Family Income',               icon: Icons.account_balance_wallet_rounded, value: _familyIncome,           options: const ['Low', 'Medium', 'High'],                    onChanged: (v) => setState(() => _familyIncome            = v)),
        ChipSelector(label: 'Teacher Quality',             icon: Icons.stars_rounded,                 value: _teacherQuality,          options: const ['Low', 'Medium', 'High'],                    onChanged: (v) => setState(() => _teacherQuality          = v)),
        ChipSelector(label: 'School Type',                 icon: Icons.account_balance_rounded,       value: _schoolType,              options: const ['Public', 'Private'],                        onChanged: (v) => setState(() => _schoolType              = v)),
        ChipSelector(label: 'Peer Influence',              icon: Icons.group_rounded,                 value: _peerInfluence,           options: const ['Positive', 'Neutral', 'Negative'],          onChanged: (v) => setState(() => _peerInfluence           = v)),
        ChipSelector(label: 'Learning Disabilities',       icon: Icons.accessibility_new_rounded,     value: _learningDisabilities,    options: const ['Yes', 'No'],                                onChanged: (v) => setState(() => _learningDisabilities    = v)),
        ChipSelector(label: 'Parental Education',          icon: Icons.school_rounded,                value: _parentalEducationLevel,  options: const ['High School', 'College', 'Postgraduate'],   onChanged: (v) => setState(() => _parentalEducationLevel  = v)),
        ChipSelector(label: 'Distance from School',        icon: Icons.location_on_rounded,           value: _distanceFromHome,        options: const ['Near', 'Moderate', 'Far'],                  onChanged: (v) => setState(() => _distanceFromHome        = v)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStep2() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _kNavy, strokeWidth: 3),
            SizedBox(height: 20),
            Text(
              'Analysing student profile…',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 52),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    if (_predictedScore != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ResultCard(score: _predictedScore!),
      );
    }
    return const SizedBox();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _row(Widget a, Widget b) => Row(
        children: [
          Expanded(child: a),
          const SizedBox(width: 14),
          Expanded(child: b),
        ],
      );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── Dark gradient header ──────────────────────────────────────────
          _AppHeader(
            currentStep: _currentStep,
            titles: _stepTitles,
            subtitles: _stepSubs,
          ),

          // ── White content area (rounded top) ─────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F6FC),
                borderRadius: BorderRadius.only(
                  topLeft:  Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Step indicator
                  _StepIndicator(currentStep: _currentStep),
                  const SizedBox(height: 20),

                  // Animated step content
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                        child: SlideTransition(
                          position: Tween(
                            begin: Offset(_goingForward ? 0.07 : -0.07, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_currentStep),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          child: _currentStep == 0
                              ? _buildStep0()
                              : _currentStep == 1
                                  ? _buildStep1()
                                  : _buildStep2(),
                        ),
                      ),
                    ),
                  ),

                  // Navigation bar
                  _NavBar(
                    currentStep: _currentStep,
                    isLoading:   _isLoading,
                    onBack:  _onBack,
                    onNext:  _onNext,
                    onReset: _onReset,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App Header ───────────────────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  final int currentStep;
  final List<String> titles;
  final List<String> subtitles;

  const _AppHeader({
    required this.currentStep,
    required this.titles,
    required this.subtitles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App name row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white60,
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Student Score Predictor',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Animated step title + subtitle
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            ),
            child: SizedBox(
              key: ValueKey(currentStep),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titles[currentStep],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitles[currentStep],
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        children: [
          _StepDot(index: 0, current: currentStep, label: 'Academic'),
          _StepLine(filled: currentStep > 0),
          _StepDot(index: 1, current: currentStep, label: 'Environment'),
          _StepLine(filled: currentStep > 1),
          _StepDot(index: 2, current: currentStep, label: 'Result'),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int    index;
  final int    current;
  final String label;
  const _StepDot({required this.index, required this.current, required this.label});

  @override
  Widget build(BuildContext context) {
    final isCompleted = current > index;
    final isActive    = current == index;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          width:  isActive ? 38 : 30,
          height: isActive ? 38 : 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? const Color(0xFF0F3460)
                : Colors.white,
            border: Border.all(
              color: isCompleted || isActive
                  ? const Color(0xFF0F3460)
                  : const Color(0xFFCDD5F0),
              width: 2,
            ),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x440F3460),
                      blurRadius: 12,
                      spreadRadius: 3,
                    )
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 16)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFFB0B8D0),
                      fontWeight: FontWeight.bold,
                      fontSize: isActive ? 15 : 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? const Color(0xFF0F3460)
                : const Color(0xFFB0B8D0),
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool filled;
  const _StepLine({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 2,
          decoration: BoxDecoration(
            color: filled
                ? const Color(0xFF0F3460)
                : const Color(0xFFE2E8F5),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

// ─── Navigation Bar ───────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  final int          currentStep;
  final bool         isLoading;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onReset;

  const _NavBar({
    required this.currentStep,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 16),
      child: Row(
        children: [
          // Left: Back or Try Again
          if (currentStep == 1)
            _outlineBtn(
              icon: Icons.arrow_back_rounded,
              label: 'Back',
              onTap: onBack,
            ),
          if (currentStep == 2)
            _outlineBtn(
              icon: Icons.refresh_rounded,
              label: 'Try Again',
              onTap: onReset,
            ),

          const Spacer(),

          // Right: Next or Predict Score
          if (currentStep < 2)
            FilledButton.icon(
              onPressed: isLoading ? null : onNext,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      currentStep == 0
                          ? Icons.arrow_forward_rounded
                          : Icons.analytics_rounded,
                      size: 18,
                    ),
              label: Text(currentStep == 0 ? 'Next' : 'Predict Score'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F3460),
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _outlineBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        side: const BorderSide(color: Color(0xFF0F3460)),
        foregroundColor: const Color(0xFF0F3460),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

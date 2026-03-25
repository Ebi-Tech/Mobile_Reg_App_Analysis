import 'package:flutter/material.dart';
import '../models/student_input.dart';
import '../services/prediction_service.dart';
import '../widgets/slider_field.dart';
import '../widgets/chip_selector.dart';
import '../widgets/result_card.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  // --- Numeric state (driven by sliders) ---
  int _hoursStudied      = 20;
  int _attendance        = 80;
  int _sleepHours        = 7;
  int _previousScores    = 70;
  int _tutoringSessions  = 2;
  int _physicalActivity  = 3;

  // --- Categorical state (driven by chips) ---
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
  bool    _isLoading   = false;
  String? _errorMessage;

  Future<void> _predict() async {
    setState(() {
      _isLoading    = true;
      _errorMessage = null;
      _predictedScore = null;
    });

    try {
      final input = StudentInput(
        hoursStudied:              _hoursStudied,
        attendance:                _attendance,
        sleepHours:                _sleepHours,
        previousScores:            _previousScores,
        tutoringSessions:          _tutoringSessions,
        physicalActivity:          _physicalActivity,
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

  void _reset() {
    setState(() {
      _hoursStudied      = 20;
      _attendance        = 80;
      _sleepHours        = 7;
      _previousScores    = 70;
      _tutoringSessions  = 2;
      _physicalActivity  = 3;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Collapsing dark gradient header ────────────────────────────
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F3460),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: const Text(
                'Score Predictor',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Student Exam Score Predictor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Identify at-risk students early',
                      style: TextStyle(
                          color: Colors.white.withAlpha(180), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable content ──────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Academic Profile card ─────────────────────────────────
                _SectionCard(
                  title: 'Academic Profile',
                  icon: Icons.school_rounded,
                  children: [
                    SliderField(
                      label: 'Hours Studied / Week',
                      icon: Icons.menu_book_rounded,
                      value: _hoursStudied,
                      min: 1, max: 44,
                      onChanged: (v) => setState(() => _hoursStudied = v),
                    ),
                    SliderField(
                      label: 'Attendance',
                      icon: Icons.calendar_today_rounded,
                      value: _attendance,
                      min: 60, max: 100,
                      unit: '%',
                      onChanged: (v) => setState(() => _attendance = v),
                    ),
                    SliderField(
                      label: 'Sleep Hours / Day',
                      icon: Icons.bedtime_rounded,
                      value: _sleepHours,
                      min: 4, max: 10,
                      unit: 'hrs',
                      onChanged: (v) => setState(() => _sleepHours = v),
                    ),
                    SliderField(
                      label: 'Previous Exam Score',
                      icon: Icons.assignment_rounded,
                      value: _previousScores,
                      min: 50, max: 100,
                      unit: 'pts',
                      onChanged: (v) => setState(() => _previousScores = v),
                    ),
                    SliderField(
                      label: 'Tutoring Sessions / Month',
                      icon: Icons.people_alt_rounded,
                      value: _tutoringSessions,
                      min: 0, max: 8,
                      onChanged: (v) => setState(() => _tutoringSessions = v),
                    ),
                    SliderField(
                      label: 'Physical Activity / Week',
                      icon: Icons.fitness_center_rounded,
                      value: _physicalActivity,
                      min: 0, max: 6,
                      unit: 'hrs',
                      onChanged: (v) => setState(() => _physicalActivity = v),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Learning Environment card ──────────────────────────────
                _SectionCard(
                  title: 'Learning Environment',
                  icon: Icons.home_rounded,
                  children: [
                    ChipSelector(
                      label: 'Parental Involvement',
                      icon: Icons.family_restroom_rounded,
                      value: _parentalInvolvement,
                      options: const ['Low', 'Medium', 'High'],
                      onChanged: (v) => setState(() => _parentalInvolvement = v),
                    ),
                    ChipSelector(
                      label: 'Access to Resources',
                      icon: Icons.library_books_rounded,
                      value: _accessToResources,
                      options: const ['Low', 'Medium', 'High'],
                      onChanged: (v) => setState(() => _accessToResources = v),
                    ),
                    ChipSelector(
                      label: 'Extracurricular Activities',
                      icon: Icons.sports_soccer_rounded,
                      value: _extracurricular,
                      options: const ['Yes', 'No'],
                      onChanged: (v) => setState(() => _extracurricular = v),
                    ),
                    ChipSelector(
                      label: 'Motivation Level',
                      icon: Icons.bolt_rounded,
                      value: _motivationLevel,
                      options: const ['Low', 'Medium', 'High'],
                      onChanged: (v) => setState(() => _motivationLevel = v),
                    ),
                    ChipSelector(
                      label: 'Internet Access at Home',
                      icon: Icons.wifi_rounded,
                      value: _internetAccess,
                      options: const ['Yes', 'No'],
                      onChanged: (v) => setState(() => _internetAccess = v),
                    ),
                    ChipSelector(
                      label: 'Family Income',
                      icon: Icons.account_balance_wallet_rounded,
                      value: _familyIncome,
                      options: const ['Low', 'Medium', 'High'],
                      onChanged: (v) => setState(() => _familyIncome = v),
                    ),
                    ChipSelector(
                      label: 'Teacher Quality',
                      icon: Icons.stars_rounded,
                      value: _teacherQuality,
                      options: const ['Low', 'Medium', 'High'],
                      onChanged: (v) => setState(() => _teacherQuality = v),
                    ),
                    ChipSelector(
                      label: 'School Type',
                      icon: Icons.account_balance_rounded,
                      value: _schoolType,
                      options: const ['Public', 'Private'],
                      onChanged: (v) => setState(() => _schoolType = v),
                    ),
                    ChipSelector(
                      label: 'Peer Influence',
                      icon: Icons.group_rounded,
                      value: _peerInfluence,
                      options: const ['Positive', 'Neutral', 'Negative'],
                      onChanged: (v) => setState(() => _peerInfluence = v),
                    ),
                    ChipSelector(
                      label: 'Learning Disabilities',
                      icon: Icons.accessibility_new_rounded,
                      value: _learningDisabilities,
                      options: const ['Yes', 'No'],
                      onChanged: (v) =>
                          setState(() => _learningDisabilities = v),
                    ),
                    ChipSelector(
                      label: 'Parental Education',
                      icon: Icons.school_rounded,
                      value: _parentalEducationLevel,
                      options: const ['High School', 'College', 'Postgraduate'],
                      onChanged: (v) =>
                          setState(() => _parentalEducationLevel = v),
                    ),
                    ChipSelector(
                      label: 'Distance from School',
                      icon: Icons.location_on_rounded,
                      value: _distanceFromHome,
                      options: const ['Near', 'Moderate', 'Far'],
                      onChanged: (v) => setState(() => _distanceFromHome = v),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Action buttons ─────────────────────────────────────────
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _reset,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        side: const BorderSide(color: Color(0xFF0F3460)),
                        foregroundColor: const Color(0xFF0F3460),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _predict,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.analytics_rounded),
                        label: Text(
                            _isLoading ? 'Predicting…' : 'Predict Score'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3460),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Result / Error ─────────────────────────────────────────
                if (_predictedScore != null) ResultCard(score: _predictedScore!),
                if (_errorMessage != null) _ErrorCard(message: _errorMessage!),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section card wrapper ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0F3460), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F3460),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFFE8EDF8)),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ─── Error card ───────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        border: Border.all(color: const Color(0xFFEF9A9A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC62828)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFC62828)),
            ),
          ),
        ],
      ),
    );
  }
}

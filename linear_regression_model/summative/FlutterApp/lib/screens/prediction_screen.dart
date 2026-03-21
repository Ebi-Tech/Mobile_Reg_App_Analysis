import 'package:flutter/material.dart';
import '../models/student_input.dart';
import '../services/prediction_service.dart';
import '../widgets/numeric_field.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/result_card.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Numeric controllers ---
  final _hoursCtrl       = TextEditingController(text: '23');
  final _attendanceCtrl  = TextEditingController(text: '84');
  final _sleepCtrl       = TextEditingController(text: '7');
  final _prevScoreCtrl   = TextEditingController(text: '73');
  final _tutoringCtrl    = TextEditingController(text: '0');
  final _physicalCtrl    = TextEditingController(text: '3');

  // --- Dropdown state ---
  String _parentalInvolvement      = 'Low';
  String _accessToResources        = 'High';
  String _extracurricular          = 'No';
  String _motivationLevel          = 'Low';
  String _internetAccess           = 'Yes';
  String _familyIncome             = 'Low';
  String _teacherQuality           = 'Medium';
  String _schoolType               = 'Public';
  String _peerInfluence            = 'Positive';
  String _learningDisabilities     = 'No';
  String _parentalEducationLevel   = 'High School';
  String _distanceFromHome         = 'Near';

  double? _predictedScore;
  bool    _isLoading = false;
  String? _errorMessage;

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

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
      _predictedScore = null;
    });

    try {
      final input = StudentInput(
        hoursStudied:             int.parse(_hoursCtrl.text),
        attendance:               int.parse(_attendanceCtrl.text),
        sleepHours:               int.parse(_sleepCtrl.text),
        previousScores:           int.parse(_prevScoreCtrl.text),
        tutoringSessions:         int.parse(_tutoringCtrl.text),
        physicalActivity:         int.parse(_physicalCtrl.text),
        parentalInvolvement:      _parentalInvolvement,
        accessToResources:        _accessToResources,
        extracurricularActivities: _extracurricular,
        motivationLevel:          _motivationLevel,
        internetAccess:           _internetAccess,
        familyIncome:             _familyIncome,
        teacherQuality:           _teacherQuality,
        schoolType:               _schoolType,
        peerInfluence:            _peerInfluence,
        learningDisabilities:     _learningDisabilities,
        parentalEducationLevel:   _parentalEducationLevel,
        distanceFromHome:         _distanceFromHome,
      );

      final score = await PredictionService.predict(input);
      setState(() => _predictedScore = score);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    _hoursCtrl.text      = '';
    _attendanceCtrl.text = '';
    _sleepCtrl.text      = '';
    _prevScoreCtrl.text  = '';
    _tutoringCtrl.text   = '';
    _physicalCtrl.text   = '';
    setState(() {
      _parentalInvolvement    = 'Low';
      _accessToResources      = 'High';
      _extracurricular        = 'No';
      _motivationLevel        = 'Low';
      _internetAccess         = 'Yes';
      _familyIncome           = 'Low';
      _teacherQuality         = 'Medium';
      _schoolType             = 'Public';
      _peerInfluence          = 'Positive';
      _learningDisabilities   = 'No';
      _parentalEducationLevel = 'High School';
      _distanceFromHome       = 'Near';
      _predictedScore         = null;
      _errorMessage           = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Student Score Predictor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Mission banner ──────────────────────────────────────
                _MissionBanner(color: cs.primaryContainer),
                const SizedBox(height: 20),

                // ── Numeric inputs ──────────────────────────────────────
                _SectionHeader(label: 'Study & Lifestyle', icon: Icons.school),
                const SizedBox(height: 10),
                NumericField(
                  label: 'Hours Studied per Week',
                  hint: '1 – 44',
                  controller: _hoursCtrl,
                  min: 1, max: 44,
                ),
                NumericField(
                  label: 'Attendance (%)',
                  hint: '60 – 100',
                  controller: _attendanceCtrl,
                  min: 60, max: 100,
                ),
                NumericField(
                  label: 'Sleep Hours per Day',
                  hint: '4 – 10',
                  controller: _sleepCtrl,
                  min: 4, max: 10,
                ),
                NumericField(
                  label: 'Previous Exam Score',
                  hint: '50 – 100',
                  controller: _prevScoreCtrl,
                  min: 50, max: 100,
                ),
                NumericField(
                  label: 'Tutoring Sessions per Month',
                  hint: '0 – 8',
                  controller: _tutoringCtrl,
                  min: 0, max: 8,
                ),
                NumericField(
                  label: 'Physical Activity (hrs/week)',
                  hint: '0 – 6',
                  controller: _physicalCtrl,
                  min: 0, max: 6,
                ),

                const SizedBox(height: 20),

                // ── Categorical inputs ──────────────────────────────────
                _SectionHeader(label: 'Background & Environment', icon: Icons.home),
                const SizedBox(height: 10),
                DropdownField(
                  label: 'Parental Involvement',
                  value: _parentalInvolvement,
                  options: const ['Low', 'Medium', 'High'],
                  onChanged: (v) => setState(() => _parentalInvolvement = v!),
                ),
                DropdownField(
                  label: 'Access to Resources',
                  value: _accessToResources,
                  options: const ['Low', 'Medium', 'High'],
                  onChanged: (v) => setState(() => _accessToResources = v!),
                ),
                DropdownField(
                  label: 'Extracurricular Activities',
                  value: _extracurricular,
                  options: const ['Yes', 'No'],
                  onChanged: (v) => setState(() => _extracurricular = v!),
                ),
                DropdownField(
                  label: 'Motivation Level',
                  value: _motivationLevel,
                  options: const ['Low', 'Medium', 'High'],
                  onChanged: (v) => setState(() => _motivationLevel = v!),
                ),
                DropdownField(
                  label: 'Internet Access at Home',
                  value: _internetAccess,
                  options: const ['Yes', 'No'],
                  onChanged: (v) => setState(() => _internetAccess = v!),
                ),
                DropdownField(
                  label: 'Family Income Level',
                  value: _familyIncome,
                  options: const ['Low', 'Medium', 'High'],
                  onChanged: (v) => setState(() => _familyIncome = v!),
                ),
                DropdownField(
                  label: 'Teacher Quality',
                  value: _teacherQuality,
                  options: const ['Low', 'Medium', 'High'],
                  onChanged: (v) => setState(() => _teacherQuality = v!),
                ),
                DropdownField(
                  label: 'School Type',
                  value: _schoolType,
                  options: const ['Public', 'Private'],
                  onChanged: (v) => setState(() => _schoolType = v!),
                ),
                DropdownField(
                  label: 'Peer Influence',
                  value: _peerInfluence,
                  options: const ['Positive', 'Neutral', 'Negative'],
                  onChanged: (v) => setState(() => _peerInfluence = v!),
                ),
                DropdownField(
                  label: 'Learning Disabilities',
                  value: _learningDisabilities,
                  options: const ['Yes', 'No'],
                  onChanged: (v) => setState(() => _learningDisabilities = v!),
                ),
                DropdownField(
                  label: 'Parental Education Level',
                  value: _parentalEducationLevel,
                  options: const ['High School', 'College', 'Postgraduate'],
                  onChanged: (v) => setState(() => _parentalEducationLevel = v!),
                ),
                DropdownField(
                  label: 'Distance from Home to School',
                  value: _distanceFromHome,
                  options: const ['Near', 'Moderate', 'Far'],
                  onChanged: (v) => setState(() => _distanceFromHome = v!),
                ),

                const SizedBox(height: 28),

                // ── Action buttons ──────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _reset,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
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
                            : const Icon(Icons.analytics),
                        label: Text(_isLoading ? 'Predicting…' : 'Predict Score'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
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

                // ── Result / Error display ──────────────────────────────
                if (_predictedScore != null)
                  ResultCard(score: _predictedScore!),

                if (_errorMessage != null)
                  _ErrorCard(message: _errorMessage!),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Supporting private widgets ──────────────────────────────────────────────

class _MissionBanner extends StatelessWidget {
  final Color color;
  const _MissionBanner({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Enter a student's profile to predict their exam score "
              'and identify intervention opportunities early.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: cs.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: cs.primary.withAlpha(80))),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

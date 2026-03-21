class StudentInput {
  final int hoursStudied;
  final int attendance;
  final int sleepHours;
  final int previousScores;
  final int tutoringSessions;
  final int physicalActivity;

  final String parentalInvolvement;
  final String accessToResources;
  final String extracurricularActivities;
  final String motivationLevel;
  final String internetAccess;
  final String familyIncome;
  final String teacherQuality;
  final String schoolType;
  final String peerInfluence;
  final String learningDisabilities;
  final String parentalEducationLevel;
  final String distanceFromHome;

  const StudentInput({
    required this.hoursStudied,
    required this.attendance,
    required this.sleepHours,
    required this.previousScores,
    required this.tutoringSessions,
    required this.physicalActivity,
    required this.parentalInvolvement,
    required this.accessToResources,
    required this.extracurricularActivities,
    required this.motivationLevel,
    required this.internetAccess,
    required this.familyIncome,
    required this.teacherQuality,
    required this.schoolType,
    required this.peerInfluence,
    required this.learningDisabilities,
    required this.parentalEducationLevel,
    required this.distanceFromHome,
  });

  Map<String, dynamic> toJson() => {
        'Hours_Studied': hoursStudied,
        'Attendance': attendance,
        'Sleep_Hours': sleepHours,
        'Previous_Scores': previousScores,
        'Tutoring_Sessions': tutoringSessions,
        'Physical_Activity': physicalActivity,
        'Parental_Involvement': parentalInvolvement,
        'Access_to_Resources': accessToResources,
        'Extracurricular_Activities': extracurricularActivities,
        'Motivation_Level': motivationLevel,
        'Internet_Access': internetAccess,
        'Family_Income': familyIncome,
        'Teacher_Quality': teacherQuality,
        'School_Type': schoolType,
        'Peer_Influence': peerInfluence,
        'Learning_Disabilities': learningDisabilities,
        'Parental_Education_Level': parentalEducationLevel,
        'Distance_from_Home': distanceFromHome,
      };
}

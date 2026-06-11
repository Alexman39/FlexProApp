import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_el.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('el'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FlexPro Coaching'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navPrograms.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get navPrograms;

  /// No description provided for @navWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get navWorkout;

  /// No description provided for @navCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get navCoach;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @todaysWorkout.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S WORKOUT'**
  String get todaysWorkout;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// No description provided for @freeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Free Workout'**
  String get freeWorkout;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @estMin.
  ///
  /// In en, this message translates to:
  /// **'Est. min'**
  String get estMin;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommended;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noProgram.
  ///
  /// In en, this message translates to:
  /// **'No program active — log a freestyle session'**
  String get noProgram;

  /// No description provided for @activeProgramLabel.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE PROGRAM'**
  String get activeProgramLabel;

  /// No description provided for @weekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekLabel;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayLabel;

  /// No description provided for @programsTitle.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programsTitle;

  /// No description provided for @startProgram.
  ///
  /// In en, this message translates to:
  /// **'Start Program'**
  String get startProgram;

  /// No description provided for @activeProgram.
  ///
  /// In en, this message translates to:
  /// **'Active Program'**
  String get activeProgram;

  /// No description provided for @unlockProgram.
  ///
  /// In en, this message translates to:
  /// **'Unlock Program'**
  String get unlockProgram;

  /// No description provided for @searchPrograms.
  ///
  /// In en, this message translates to:
  /// **'Search programs...'**
  String get searchPrograms;

  /// No description provided for @programLibrary.
  ///
  /// In en, this message translates to:
  /// **'Program Library'**
  String get programLibrary;

  /// No description provided for @viewProgram.
  ///
  /// In en, this message translates to:
  /// **'View Program'**
  String get viewProgram;

  /// No description provided for @allSessions.
  ///
  /// In en, this message translates to:
  /// **'All Sessions'**
  String get allSessions;

  /// No description provided for @leaveProgram.
  ///
  /// In en, this message translates to:
  /// **'Leave Program'**
  String get leaveProgram;

  /// No description provided for @noProgramsFound.
  ///
  /// In en, this message translates to:
  /// **'No programs found'**
  String get noProgramsFound;

  /// No description provided for @workoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutTitle;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'REST'**
  String get rest;

  /// No description provided for @skipRest.
  ///
  /// In en, this message translates to:
  /// **'Skip Rest'**
  String get skipRest;

  /// No description provided for @tapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap ✓ to start'**
  String get tapToStart;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running…'**
  String get running;

  /// No description provided for @workoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Workout Complete!'**
  String get workoutComplete;

  /// No description provided for @workoutCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Great work! Rest well and fuel your body with clean nutrition.'**
  String get workoutCompleteSubtitle;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE'**
  String get exercise;

  /// No description provided for @techniqueCues.
  ///
  /// In en, this message translates to:
  /// **'TECHNIQUE CUES'**
  String get techniqueCues;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'← Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next →'**
  String get next;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get historyTitle;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get sessions;

  /// No description provided for @noWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get noWorkouts;

  /// No description provided for @noWorkoutsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your first workout to see it here'**
  String get noWorkoutsSubtitle;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @avgDuration.
  ///
  /// In en, this message translates to:
  /// **'Avg Duration'**
  String get avgDuration;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @coachNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'FROM YOUR COACH'**
  String get coachNoteLabel;

  /// No description provided for @readinessTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get readinessTitle;

  /// No description provided for @readinessSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get readinessSleep;

  /// No description provided for @readinessEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get readinessEnergy;

  /// No description provided for @readinessSoreness.
  ///
  /// In en, this message translates to:
  /// **'Soreness'**
  String get readinessSoreness;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @weeklyVolume.
  ///
  /// In en, this message translates to:
  /// **'Weekly Volume'**
  String get weeklyVolume;

  /// No description provided for @weeklyVolumeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Total weight lifted per week (kg)'**
  String get weeklyVolumeSubtitle;

  /// No description provided for @workoutFrequency.
  ///
  /// In en, this message translates to:
  /// **'Workout Frequency'**
  String get workoutFrequency;

  /// No description provided for @workoutFrequencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sessions completed per week'**
  String get workoutFrequencySubtitle;

  /// No description provided for @personalRecords.
  ///
  /// In en, this message translates to:
  /// **'Personal Records'**
  String get personalRecords;

  /// No description provided for @bodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Body Weight'**
  String get bodyWeight;

  /// No description provided for @bodyWeightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your weight over time'**
  String get bodyWeightSubtitle;

  /// No description provided for @logWeight.
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get logWeight;

  /// No description provided for @logBodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Log Body Weight'**
  String get logBodyWeight;

  /// No description provided for @noVolumeData.
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to see volume data'**
  String get noVolumeData;

  /// No description provided for @noFrequencyData.
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to see frequency data'**
  String get noFrequencyData;

  /// No description provided for @logWeightPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap + Log Weight to start tracking'**
  String get logWeightPrompt;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @progressTabTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get progressTabTraining;

  /// No description provided for @progressTabExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get progressTabExercise;

  /// No description provided for @progressTabBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get progressTabBody;

  /// No description provided for @exerciseHistory.
  ///
  /// In en, this message translates to:
  /// **'Exercise History'**
  String get exerciseHistory;

  /// No description provided for @selectExercise.
  ///
  /// In en, this message translates to:
  /// **'Select an exercise to view progression'**
  String get selectExercise;

  /// No description provided for @noExerciseData.
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to track exercise progress'**
  String get noExerciseData;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @myGoals.
  ///
  /// In en, this message translates to:
  /// **'My Goals'**
  String get myGoals;

  /// No description provided for @bodyStats.
  ///
  /// In en, this message translates to:
  /// **'Body Stats'**
  String get bodyStats;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @helpFaq.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFaq;

  /// No description provided for @contactTasos.
  ///
  /// In en, this message translates to:
  /// **'Contact Tasos'**
  String get contactTasos;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy (GDPR)'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since Jan 2025'**
  String get memberSince;

  /// No description provided for @athleteStats.
  ///
  /// In en, this message translates to:
  /// **'Athlete Stats'**
  String get athleteStats;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @experienceLevel.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experienceLevel;

  /// No description provided for @trainingDays.
  ///
  /// In en, this message translates to:
  /// **'Days / Week'**
  String get trainingDays;

  /// No description provided for @equipmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipmentLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your training'**
  String get signInSubtitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your premium training journey'**
  String get createAccountSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @unlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock FlexPro Premium'**
  String get unlockPremium;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access all 12 programs, unlimited custom builder,\nadvanced analytics, and auto-progression.'**
  String get premiumSubtitle;

  /// No description provided for @startTrial.
  ///
  /// In en, this message translates to:
  /// **'Start 7-Day Free Trial'**
  String get startTrial;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skip;

  /// No description provided for @skipStats.
  ///
  /// In en, this message translates to:
  /// **'Skip stats'**
  String get skipStats;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @getMyProgram.
  ///
  /// In en, this message translates to:
  /// **'Get My Program ✓'**
  String get getMyProgram;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'FlexPro — Workout Reminder'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'Time to train! Your workout is ready 💪'**
  String get notificationBody;

  /// No description provided for @notificationReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get notificationReminderTime;

  /// No description provided for @notificationOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get notificationOn;

  /// No description provided for @notificationOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get notificationOff;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in system settings to receive workout reminders.'**
  String get notificationPermissionDenied;

  /// No description provided for @setNumber.
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String setNumber(int number);

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get weightLabel;

  /// No description provided for @repsLabel.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get repsLabel;

  /// No description provided for @rpeLabel.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get rpeLabel;

  /// No description provided for @completeSet.
  ///
  /// In en, this message translates to:
  /// **'Complete Set'**
  String get completeSet;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @newPr.
  ///
  /// In en, this message translates to:
  /// **'NEW PR'**
  String get newPr;

  /// No description provided for @requestCoachFeedback.
  ///
  /// In en, this message translates to:
  /// **'Request Coach Feedback'**
  String get requestCoachFeedback;

  /// No description provided for @feedbackRequested.
  ///
  /// In en, this message translates to:
  /// **'Feedback Requested!'**
  String get feedbackRequested;

  /// No description provided for @backToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get backToToday;

  /// No description provided for @volLabel.
  ///
  /// In en, this message translates to:
  /// **'VOL'**
  String get volLabel;

  /// No description provided for @assignTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your First Program'**
  String get assignTitle;

  /// No description provided for @assignSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your goals, here are your best matches.'**
  String get assignSubtitle;

  /// No description provided for @browsePrograms.
  ///
  /// In en, this message translates to:
  /// **'Browse Programs'**
  String get browsePrograms;

  /// No description provided for @noActiveProgram.
  ///
  /// In en, this message translates to:
  /// **'No active program'**
  String get noActiveProgram;

  /// No description provided for @noActiveProgramHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a program from the library below to get started.'**
  String get noActiveProgramHint;

  /// No description provided for @coachNoNote.
  ///
  /// In en, this message translates to:
  /// **'No coach note for today'**
  String get coachNoNote;

  /// No description provided for @workoutDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get workoutDoneLabel;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @restDayLabel.
  ///
  /// In en, this message translates to:
  /// **'REST DAY'**
  String get restDayLabel;

  /// No description provided for @restDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery Day'**
  String get restDayTitle;

  /// No description provided for @restDayBody.
  ///
  /// In en, this message translates to:
  /// **'Use this time to recover and prepare for your next session.'**
  String get restDayBody;

  /// No description provided for @restDayTipSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep 8h'**
  String get restDayTipSleep;

  /// No description provided for @restDayTipHydration.
  ///
  /// In en, this message translates to:
  /// **'Stay Hydrated'**
  String get restDayTipHydration;

  /// No description provided for @restDayTipMobility.
  ///
  /// In en, this message translates to:
  /// **'Light Mobility'**
  String get restDayTipMobility;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get filterBeginner;

  /// No description provided for @filterIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get filterIntermediate;

  /// No description provided for @filterAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get filterAdvanced;

  /// No description provided for @filterHypertrophy.
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy'**
  String get filterHypertrophy;

  /// No description provided for @filterStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get filterStrength;

  /// No description provided for @filterFatLoss.
  ///
  /// In en, this message translates to:
  /// **'Fat Loss'**
  String get filterFatLoss;

  /// No description provided for @weeksLabel.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeksLabel;

  /// No description provided for @daysPerWeekShort.
  ///
  /// In en, this message translates to:
  /// **'Days/Wk'**
  String get daysPerWeekShort;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @usersLabel.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersLabel;

  /// No description provided for @secondsRemaining.
  ///
  /// In en, this message translates to:
  /// **'seconds remaining'**
  String get secondsRemaining;

  /// No description provided for @exerciseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get exerciseLibrary;

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchExercises;

  /// No description provided for @noExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get noExercisesFound;

  /// No description provided for @tryDifferentFilter.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter or search term'**
  String get tryDifferentFilter;

  /// No description provided for @checkInSent.
  ///
  /// In en, this message translates to:
  /// **'Check-in sent!'**
  String get checkInSent;

  /// No description provided for @coachUpdates.
  ///
  /// In en, this message translates to:
  /// **'Coach Updates'**
  String get coachUpdates;

  /// No description provided for @noCoachPosts.
  ///
  /// In en, this message translates to:
  /// **'No coach posts yet'**
  String get noCoachPosts;

  /// No description provided for @weeklyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Weekly Check-In'**
  String get weeklyCheckIn;

  /// No description provided for @coachFeedbackSection.
  ///
  /// In en, this message translates to:
  /// **'Coach Feedback'**
  String get coachFeedbackSection;

  /// No description provided for @noCoachFeedback.
  ///
  /// In en, this message translates to:
  /// **'No feedback yet'**
  String get noCoachFeedback;

  /// No description provided for @yourCoach.
  ///
  /// In en, this message translates to:
  /// **'Your Coach'**
  String get yourCoach;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @postTypeTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get postTypeTip;

  /// No description provided for @postTypeMotivation.
  ///
  /// In en, this message translates to:
  /// **'Motivation'**
  String get postTypeMotivation;

  /// No description provided for @postTypeProgramUpdate.
  ///
  /// In en, this message translates to:
  /// **'Program Update'**
  String get postTypeProgramUpdate;

  /// No description provided for @postTypeNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get postTypeNutrition;

  /// No description provided for @howWasYourWeek.
  ///
  /// In en, this message translates to:
  /// **'How was your week?'**
  String get howWasYourWeek;

  /// No description provided for @checkInPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Share your progress, how you\'re feeling, any questions...'**
  String get checkInPlaceholder;

  /// No description provided for @submitCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Submit Check-In'**
  String get submitCheckIn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['el', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

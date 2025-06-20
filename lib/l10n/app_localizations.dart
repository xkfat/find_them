import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Find Them'**
  String get appName;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @findThem.
  ///
  /// In en, this message translates to:
  /// **'FindThem'**
  String get findThem;

  /// No description provided for @whereHopeExists.
  ///
  /// In en, this message translates to:
  /// **'where hope exists!'**
  String get whereHopeExists;

  /// No description provided for @together.
  ///
  /// In en, this message translates to:
  /// **'Together'**
  String get together;

  /// No description provided for @togetherMessage.
  ///
  /// In en, this message translates to:
  /// **', we can bring missing loved ones back home.'**
  String get togetherMessage;

  /// No description provided for @joinOurCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join our community '**
  String get joinOurCommunity;

  /// No description provided for @joinOurCommunityMessage.
  ///
  /// In en, this message translates to:
  /// **'to make a difference.'**
  String get joinOurCommunityMessage;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @loginOrSignUp.
  ///
  /// In en, this message translates to:
  /// **'Login or sign up'**
  String get loginOrSignUp;

  /// No description provided for @loginOrSignUpMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred method\nto continue setting up your account'**
  String get loginOrSignUpMessage;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @loginToAccessAccount.
  ///
  /// In en, this message translates to:
  /// **'Log in to access your account'**
  String get loginToAccessAccount;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @wrongUsername.
  ///
  /// In en, this message translates to:
  /// **'Wrong username'**
  String get wrongUsername;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get enterLastName;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get enterUsername;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get enterPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordMustBe6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBe6Characters;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enterCode;

  /// No description provided for @enterCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 4 digit code sent to'**
  String get enterCodeMessage;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @codeExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Code expires in'**
  String get codeExpiresIn;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t receive a code'**
  String get didntReceiveCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have been successfully authenticated'**
  String get congratulations;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get mapView;

  /// No description provided for @reportingMissingPerson.
  ///
  /// In en, this message translates to:
  /// **'Reporting a missing person'**
  String get reportingMissingPerson;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @lastSeenDetails.
  ///
  /// In en, this message translates to:
  /// **'Last seen details'**
  String get lastSeenDetails;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get additionalInformation;

  /// No description provided for @enterFirstNameHere.
  ///
  /// In en, this message translates to:
  /// **'Enter first name of missing person here'**
  String get enterFirstNameHere;

  /// No description provided for @enterLastNameHere.
  ///
  /// In en, this message translates to:
  /// **'Enter last name of missing person here'**
  String get enterLastNameHere;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @lastSeenDate.
  ///
  /// In en, this message translates to:
  /// **'Last seen date'**
  String get lastSeenDate;

  /// No description provided for @lastSeenLocation.
  ///
  /// In en, this message translates to:
  /// **'Last seen location'**
  String get lastSeenLocation;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter location: zone, area, city, street...'**
  String get enterLocation;

  /// No description provided for @selectLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Select last seen location on map (optional)'**
  String get selectLocationOnMap;

  /// No description provided for @tapToSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to select last seen location on map'**
  String get tapToSelectLocation;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  /// No description provided for @noPhotoChosen.
  ///
  /// In en, this message translates to:
  /// **'No photo Chosen'**
  String get noPhotoChosen;

  /// No description provided for @contactPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact phone number'**
  String get contactPhoneNumber;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @provideDetails.
  ///
  /// In en, this message translates to:
  /// **'Provide details about circumstances of disappearance, clothing , etc.'**
  String get provideDetails;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get submitReport;

  /// No description provided for @pleaseSelectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please select a photo'**
  String get pleaseSelectPhoto;

  /// No description provided for @pleaseEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter first name'**
  String get pleaseEnterFirstName;

  /// No description provided for @pleaseEnterLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter last name'**
  String get pleaseEnterLastName;

  /// No description provided for @pleaseEnterAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter age'**
  String get pleaseEnterAge;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// No description provided for @pleaseEnterLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a location'**
  String get pleaseEnterLocation;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide a description'**
  String get pleaseEnterDescription;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @setLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get setLocation;

  /// No description provided for @searchForLocation.
  ///
  /// In en, this message translates to:
  /// **'Search for a location'**
  String get searchForLocation;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select last seen location'**
  String get selectLocation;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get saveLocation;

  /// No description provided for @reportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'We will look into your information as soon as possible.'**
  String get reportSuccessMessage;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission'**
  String get locationPermission;

  /// No description provided for @locationSharing.
  ///
  /// In en, this message translates to:
  /// **'Location sharing'**
  String get locationSharing;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get setNewPassword;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a new password. Ensure it differs from previous ones for security'**
  String get createNewPassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @pleaseConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmNewPassword;

  /// No description provided for @oldPasswordNotCorrect.
  ///
  /// In en, this message translates to:
  /// **'Old password is not correct'**
  String get oldPasswordNotCorrect;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @noProfileDataToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No profile data to display. Please try again.'**
  String get noProfileDataToDisplay;

  /// No description provided for @firstNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'First name must be at least 2 characters'**
  String get firstNameMinLength;

  /// No description provided for @lastNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Last name must be at least 2 characters'**
  String get lastNameMinLength;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @usernameInvalidCharacters.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers, underscores, or dots'**
  String get usernameInvalidCharacters;

  /// No description provided for @phoneNumberDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'Phone number must contain only digits'**
  String get phoneNumberDigitsOnly;

  /// No description provided for @passwordChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully.'**
  String get passwordChangeSuccess;

  /// No description provided for @invalidNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid new password'**
  String get invalidNewPassword;

  /// No description provided for @mySubmittedCases.
  ///
  /// In en, this message translates to:
  /// **'My submitted cases'**
  String get mySubmittedCases;

  /// No description provided for @noSubmittedCases.
  ///
  /// In en, this message translates to:
  /// **'No submitted cases'**
  String get noSubmittedCases;

  /// No description provided for @noSubmittedCasesMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t submitted any missing person reports yet.'**
  String get noSubmittedCasesMessage;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @submittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted on'**
  String get submittedOn;

  /// No description provided for @updatesTimeline.
  ///
  /// In en, this message translates to:
  /// **'Updates Timeline'**
  String get updatesTimeline;

  /// No description provided for @noUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No updates available yet.'**
  String get noUpdatesAvailable;

  /// No description provided for @locationSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Location sharing'**
  String get locationSharingTitle;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get addFriend;

  /// No description provided for @findFriends.
  ///
  /// In en, this message translates to:
  /// **'Find friends'**
  String get findFriends;

  /// No description provided for @searchByUsernameOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Search by username or phone number'**
  String get searchByUsernameOrPhone;

  /// No description provided for @findFriendsMessage.
  ///
  /// In en, this message translates to:
  /// **'Search by username or phone number to find\npeople you know and connect with them.'**
  String get findFriendsMessage;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different username or phone number'**
  String get tryDifferentSearch;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @locationRequest.
  ///
  /// In en, this message translates to:
  /// **'Location Request'**
  String get locationRequest;

  /// No description provided for @sharingWithYou.
  ///
  /// In en, this message translates to:
  /// **'Sharing with you'**
  String get sharingWithYou;

  /// No description provided for @notSharing.
  ///
  /// In en, this message translates to:
  /// **'Not sharing'**
  String get notSharing;

  /// No description provided for @canSeeYou.
  ///
  /// In en, this message translates to:
  /// **'Can see you'**
  String get canSeeYou;

  /// No description provided for @cannotSeeYou.
  ///
  /// In en, this message translates to:
  /// **'Cannot see you'**
  String get cannotSeeYou;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share location'**
  String get shareLocation;

  /// No description provided for @stopSharing.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing'**
  String get stopSharing;

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get removeFriend;

  /// No description provided for @sendAlert.
  ///
  /// In en, this message translates to:
  /// **'Send Alert'**
  String get sendAlert;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @noLocationSharingFriends.
  ///
  /// In en, this message translates to:
  /// **'No location sharing friends'**
  String get noLocationSharingFriends;

  /// No description provided for @tapToAddFriends.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add friends for location sharing'**
  String get tapToAddFriends;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get allCaughtUp;

  /// No description provided for @deleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Delete Notification'**
  String get deleteNotification;

  /// No description provided for @deleteNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notification? This action cannot be undone.'**
  String get deleteNotificationMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @viewDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetailsButton;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get viewOnMap;

  /// No description provided for @tapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap for details'**
  String get tapForDetails;

  /// No description provided for @liveLocation.
  ///
  /// In en, this message translates to:
  /// **'Live location'**
  String get liveLocation;

  /// No description provided for @recentLocation.
  ///
  /// In en, this message translates to:
  /// **'Recent location'**
  String get recentLocation;

  /// No description provided for @locationSuffix.
  ///
  /// In en, this message translates to:
  /// **'s Location'**
  String get locationSuffix;

  /// No description provided for @searchingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Searching your location...'**
  String get searchingYourLocation;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionRequiredFeature.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to use this feature'**
  String get locationPermissionRequiredFeature;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location service disabled'**
  String get locationServiceDisabled;

  /// No description provided for @addressNotFound.
  ///
  /// In en, this message translates to:
  /// **'Address not found'**
  String get addressNotFound;

  /// No description provided for @errorGettingAddress.
  ///
  /// In en, this message translates to:
  /// **'Error getting address'**
  String get errorGettingAddress;

  /// No description provided for @selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocation;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found. Try a different search term.'**
  String get noResultsFound;

  /// No description provided for @apiKeyError.
  ///
  /// In en, this message translates to:
  /// **'API Key error'**
  String get apiKeyError;

  /// No description provided for @invalidApiKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid API key'**
  String get invalidApiKey;

  /// No description provided for @noMatchingLocations.
  ///
  /// In en, this message translates to:
  /// **'No matching locations found. Try a different search term.'**
  String get noMatchingLocations;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @errorGettingPlaceDetails.
  ///
  /// In en, this message translates to:
  /// **'Error getting place details'**
  String get errorGettingPlaceDetails;

  /// No description provided for @enterLocationToSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter a location to search'**
  String get enterLocationToSearch;

  /// No description provided for @makeSurePlacesApiEnabled.
  ///
  /// In en, this message translates to:
  /// **'Make sure Places API is enabled in Google Cloud Console'**
  String get makeSurePlacesApiEnabled;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchCasesOrFriends.
  ///
  /// In en, this message translates to:
  /// **'Search cases or friends'**
  String get searchCasesOrFriends;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @cases.
  ///
  /// In en, this message translates to:
  /// **'Cases'**
  String get cases;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @filterSearching.
  ///
  /// In en, this message translates to:
  /// **'Filter searching'**
  String get filterSearching;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age Range'**
  String get ageRange;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectStartDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get selectEndDate;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply filter'**
  String get applyFilter;

  /// No description provided for @missing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get missing;

  /// No description provided for @investigating.
  ///
  /// In en, this message translates to:
  /// **'Investigating'**
  String get investigating;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get found;

  /// No description provided for @showAllCases.
  ///
  /// In en, this message translates to:
  /// **'Show All Cases'**
  String get showAllCases;

  /// No description provided for @noCasesFound.
  ///
  /// In en, this message translates to:
  /// **'No cases found matching your search'**
  String get noCasesFound;

  /// No description provided for @caseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Case not found'**
  String get caseNotFound;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @alertSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Alert sent successfully!'**
  String get alertSentSuccessfully;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @areYouSureRemoveFriend.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {friendName} from your friends list?'**
  String areYouSureRemoveFriend(Object friendName);

  /// No description provided for @searchingUsers.
  ///
  /// In en, this message translates to:
  /// **'Searching users...'**
  String get searchingUsers;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @missingFrom.
  ///
  /// In en, this message translates to:
  /// **'Missing from'**
  String get missingFrom;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get yearsOld;

  /// No description provided for @missingFor.
  ///
  /// In en, this message translates to:
  /// **'Missing for'**
  String get missingFor;

  /// No description provided for @investigatingFor.
  ///
  /// In en, this message translates to:
  /// **'Investigating for'**
  String get investigatingFor;

  /// No description provided for @foundAfter.
  ///
  /// In en, this message translates to:
  /// **'Found after'**
  String get foundAfter;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @caseInformation.
  ///
  /// In en, this message translates to:
  /// **'Case Information'**
  String get caseInformation;

  /// No description provided for @lastSeenDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Last seen date:'**
  String get lastSeenDateLabel;

  /// No description provided for @lastSeenLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Last seen location:'**
  String get lastSeenLocationLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get descriptionLabel;

  /// No description provided for @leaveInformation.
  ///
  /// In en, this message translates to:
  /// **'Report Sighting'**
  String get leaveInformation;

  /// No description provided for @pleaseProvideInformation.
  ///
  /// In en, this message translates to:
  /// **'Please provide any information you have about this missing person, and help us find other people loved ones.'**
  String get pleaseProvideInformation;

  /// No description provided for @writeMessageHere.
  ///
  /// In en, this message translates to:
  /// **'Write the information you know here...'**
  String get writeMessageHere;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @missingInformation.
  ///
  /// In en, this message translates to:
  /// **'Missing Information'**
  String get missingInformation;

  /// No description provided for @pleaseEnterSomeInformation.
  ///
  /// In en, this message translates to:
  /// **'Please enter some information'**
  String get pleaseEnterSomeInformation;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You!'**
  String get thankYou;

  /// No description provided for @forTryingToHelp.
  ///
  /// In en, this message translates to:
  /// **'for trying to help us.'**
  String get forTryingToHelp;

  /// No description provided for @submissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission Failed'**
  String get submissionFailed;

  /// No description provided for @failedToSubmitInformation.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit information. Please try again.'**
  String get failedToSubmitInformation;

  /// No description provided for @enterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get enterValidPhoneNumber;

  /// No description provided for @endDateCannotBeBeforeStartDate.
  ///
  /// In en, this message translates to:
  /// **'End date cannot be before start date'**
  String get endDateCannotBeBeforeStartDate;

  /// No description provided for @endDateCannotBeInFuture.
  ///
  /// In en, this message translates to:
  /// **'End date cannot be in the future'**
  String get endDateCannotBeInFuture;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @falseValue.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get falseValue;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingCaseDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading case details...'**
  String get loadingCaseDetails;

  /// No description provided for @errorLoadingDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading details'**
  String get errorLoadingDetails;

  /// No description provided for @unknownState.
  ///
  /// In en, this message translates to:
  /// **'Unknown state'**
  String get unknownState;

  /// No description provided for @invalidCaseId.
  ///
  /// In en, this message translates to:
  /// **'Invalid case ID'**
  String get invalidCaseId;

  /// No description provided for @cannotSubmitReport.
  ///
  /// In en, this message translates to:
  /// **'Cannot submit report: Invalid case ID'**
  String get cannotSubmitReport;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to use the map.'**
  String get locationPermissionRequired;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @errorWithRetry.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithRetry(String error);

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed. Please try again.'**
  String get logoutFailed;

  /// No description provided for @errorLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Error logging out'**
  String get errorLoggingOut;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

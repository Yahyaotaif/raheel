import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  ];

  /// appTitle
  ///
  /// In en, this message translates to:
  /// **'Raheel'**
  String get appTitle;

  /// appDescription
  ///
  /// In en, this message translates to:
  /// **'Ride Sharing App'**
  String get appDescription;

  /// welcome
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// login
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button label
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// confirmPassword
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// forgotPassword
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// resetPassword
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// english
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// arabic
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// success
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// noInternet
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// tryAgain
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// trips
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// bookTrip
  ///
  /// In en, this message translates to:
  /// **'Book a Trip'**
  String get bookTrip;

  /// myTrips
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTrips;

  /// createTrip
  ///
  /// In en, this message translates to:
  /// **'Create a Trip'**
  String get createTrip;

  /// searchTrips
  ///
  /// In en, this message translates to:
  /// **'Search Trips'**
  String get searchTrips;

  /// from
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// to
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// departure
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure;

  /// arrival
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrival;

  /// price
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// availableSeats
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get availableSeats;

  /// passengersCount
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengersCount;

  /// driverDetails
  ///
  /// In en, this message translates to:
  /// **'Driver Details'**
  String get driverDetails;

  /// vehicleDetails
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetails;

  /// confirmBooking
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// bookingConfirmed
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bookingConfirmed;

  /// bookingCancelled
  ///
  /// In en, this message translates to:
  /// **'Booking Cancelled'**
  String get bookingCancelled;

  /// cancelBooking
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// phoneNumber
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// aboutMe
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// emailOrUsername
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get emailOrUsername;

  /// enterEmailOrUsername
  ///
  /// In en, this message translates to:
  /// **'Enter email or username'**
  String get enterEmailOrUsername;

  /// loginFailed
  ///
  /// In en, this message translates to:
  /// **'Login failed. Check email or username and password.'**
  String get loginFailed;

  /// privacyPolicy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// changePassword
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// editProfile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// helpAndSupport
  ///
  /// In en, this message translates to:
  /// **'Help and Support'**
  String get helpAndSupport;

  /// manageBookings
  ///
  /// In en, this message translates to:
  /// **'Manage Bookings'**
  String get manageBookings;

  /// searchTrip
  ///
  /// In en, this message translates to:
  /// **'Search a Trip'**
  String get searchTrip;

  /// createNewTrip
  ///
  /// In en, this message translates to:
  /// **'Create a Trip'**
  String get createNewTrip;

  /// contactUs
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// copyEmail
  ///
  /// In en, this message translates to:
  /// **'Copy Email'**
  String get copyEmail;

  /// emailCopied
  ///
  /// In en, this message translates to:
  /// **'Email copied'**
  String get emailCopied;

  /// emailUsAt
  ///
  /// In en, this message translates to:
  /// **'You can email us at'**
  String get emailUsAt;

  /// No description provided for @newBookingFrom.
  ///
  /// In en, this message translates to:
  /// **'New booking from {name}'**
  String newBookingFrom(Object name);

  /// No description provided for @travelerFallback.
  ///
  /// In en, this message translates to:
  /// **'Traveler'**
  String get travelerFallback;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// ok
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @tripPublishSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip posted successfully'**
  String get tripPublishSuccessTitle;

  /// No description provided for @tripPublishSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your trip has been posted successfully. Please visit Manage Bookings in your account to review passengers and contact them.'**
  String get tripPublishSuccessBody;

  /// No description provided for @bookingSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking successful'**
  String get bookingSuccessTitle;

  /// No description provided for @bookingSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your trip has been booked successfully. Please visit Manage Bookings to review your driver and contact them.'**
  String get bookingSuccessBody;

  /// selectDate
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// noDateSelected
  ///
  /// In en, this message translates to:
  /// **'No date selected'**
  String get noDateSelected;

  /// selectedDate
  ///
  /// In en, this message translates to:
  /// **'Selected Date'**
  String get selectedDate;

  /// selectTime
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// destination
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// destinationYemen
  ///
  /// In en, this message translates to:
  /// **'Yemen'**
  String get destinationYemen;

  /// destinationBahrain
  ///
  /// In en, this message translates to:
  /// **'Bahrain'**
  String get destinationBahrain;

  /// destinationQatar
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get destinationQatar;

  /// destinationUae
  ///
  /// In en, this message translates to:
  /// **'United Arab Emirates'**
  String get destinationUae;

  /// destinationKuwait
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get destinationKuwait;

  /// destinationRiyadh
  ///
  /// In en, this message translates to:
  /// **'Riyadh'**
  String get destinationRiyadh;

  /// destinationJeddah
  ///
  /// In en, this message translates to:
  /// **'Jeddah'**
  String get destinationJeddah;

  /// destinationMakkah
  ///
  /// In en, this message translates to:
  /// **'Makkah'**
  String get destinationMakkah;

  /// destinationAbha
  ///
  /// In en, this message translates to:
  /// **'Abha'**
  String get destinationAbha;

  /// destinationJizan
  ///
  /// In en, this message translates to:
  /// **'Jizan'**
  String get destinationJizan;

  /// destinationDammam
  ///
  /// In en, this message translates to:
  /// **'Dammam'**
  String get destinationDammam;

  /// destinationJordan
  ///
  /// In en, this message translates to:
  /// **'Jordan'**
  String get destinationJordan;

  /// meetingPoint
  ///
  /// In en, this message translates to:
  /// **'Meeting Point'**
  String get meetingPoint;

  /// startingPoint
  ///
  /// In en, this message translates to:
  /// **'Starting Point'**
  String get startingPoint;

  /// departurePlace
  ///
  /// In en, this message translates to:
  /// **'Departure Place'**
  String get departurePlace;

  /// passengers
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengers;

  /// numberOfSeats
  ///
  /// In en, this message translates to:
  /// **'Number of Seats'**
  String get numberOfSeats;

  /// carType
  ///
  /// In en, this message translates to:
  /// **'Car Type'**
  String get carType;

  /// carPlate
  ///
  /// In en, this message translates to:
  /// **'Car Plate'**
  String get carPlate;

  /// carModel
  ///
  /// In en, this message translates to:
  /// **'Car Model'**
  String get carModel;

  /// firstName
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// lastName
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// username
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// createAccount
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// dontHaveAccount
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// alreadyHaveAccount
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// registerNow
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNow;

  /// requestHelp
  ///
  /// In en, this message translates to:
  /// **'Request Help'**
  String get requestHelp;

  /// bookingDetails
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// cancelBookingConfirm
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking?'**
  String get cancelBookingConfirm;

  /// paymentConfirmation
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmation'**
  String get paymentConfirmation;

  /// amount
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// enterCardDetails
  ///
  /// In en, this message translates to:
  /// **'Please enter card details'**
  String get enterCardDetails;

  /// cardholderName
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// cardNumber
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// cardNumberHint
  ///
  /// In en, this message translates to:
  /// **'Must be 16 digits'**
  String get cardNumberHint;

  /// expiryDate
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get expiryDate;

  /// expiryDateHint
  ///
  /// In en, this message translates to:
  /// **'12/25'**
  String get expiryDateHint;

  /// cvv
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// securePayment
  ///
  /// In en, this message translates to:
  /// **'Payment details are sent securely to Moyasar for processing.'**
  String get securePayment;

  /// pay
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// noBookingsFound
  ///
  /// In en, this message translates to:
  /// **'No bookings found'**
  String get noBookingsFound;

  /// upcomingTrips
  ///
  /// In en, this message translates to:
  /// **'Upcoming Trips'**
  String get upcomingTrips;

  /// pastTrips
  ///
  /// In en, this message translates to:
  /// **'Past Trips'**
  String get pastTrips;

  /// tripDetails
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// tripInfo
  ///
  /// In en, this message translates to:
  /// **'Trip Information'**
  String get tripInfo;

  /// driverName
  ///
  /// In en, this message translates to:
  /// **'Driver Name'**
  String get driverName;

  /// vehicleInfo
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInfo;

  /// rateTrip
  ///
  /// In en, this message translates to:
  /// **'Rate Trip'**
  String get rateTrip;

  /// reportIssue
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// arrivalPlace
  ///
  /// In en, this message translates to:
  /// **'Arrival Place'**
  String get arrivalPlace;

  /// bookings
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// newBookingRequest
  ///
  /// In en, this message translates to:
  /// **'New Booking Request'**
  String get newBookingRequest;

  /// noTripsOrBookings
  ///
  /// In en, this message translates to:
  /// **'No trips or bookings currently'**
  String get noTripsOrBookings;

  /// No description provided for @availableTrips.
  ///
  /// In en, this message translates to:
  /// **'Available Trips:'**
  String get availableTrips;

  /// errorLoadingTrips
  ///
  /// In en, this message translates to:
  /// **'Error loading trip data. Please try again'**
  String get errorLoadingTrips;

  /// tripDeletedSuccess
  ///
  /// In en, this message translates to:
  /// **'Trip deleted successfully'**
  String get tripDeletedSuccess;

  /// travelerDeleted
  ///
  /// In en, this message translates to:
  /// **'Traveler deleted'**
  String get travelerDeleted;

  /// cannotOpenPhone
  ///
  /// In en, this message translates to:
  /// **'Cannot open phone app'**
  String get cannotOpenPhone;

  /// confirmDeleteTrip
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete Trip'**
  String get confirmDeleteTrip;

  /// deleteTrip
  ///
  /// In en, this message translates to:
  /// **'Delete Trip'**
  String get deleteTrip;

  /// deleteThisTrip
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this trip? All associated bookings will be deleted'**
  String get deleteThisTrip;

  /// confirmDelete
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// deleteTraveler
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this traveler?'**
  String get deleteTraveler;

  /// contactDone
  ///
  /// In en, this message translates to:
  /// **'Contact Done'**
  String get contactDone;

  /// tripInfoLabel
  ///
  /// In en, this message translates to:
  /// **'Trip Information'**
  String get tripInfoLabel;

  /// tripDetailsLabel
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetailsLabel;

  /// date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// availableSeatsLabel
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get availableSeatsLabel;

  /// departingFrom
  ///
  /// In en, this message translates to:
  /// **'Departing From'**
  String get departingFrom;

  /// driverInfo
  ///
  /// In en, this message translates to:
  /// **'Driver Information'**
  String get driverInfo;

  /// driverInfoNotAvailable
  ///
  /// In en, this message translates to:
  /// **'Driver information not available'**
  String get driverInfoNotAvailable;

  /// deleteDriver
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this driver?'**
  String get deleteDriver;

  /// no
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// userNotFound
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// selectAccountType
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get selectAccountType;

  /// driver
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// passenger
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get passenger;

  /// vehicleDriver
  ///
  /// In en, this message translates to:
  /// **'Vehicle Driver'**
  String get vehicleDriver;

  /// traveler
  ///
  /// In en, this message translates to:
  /// **'Traveler'**
  String get traveler;

  /// carPlateNumber
  ///
  /// In en, this message translates to:
  /// **'Car Plate Number'**
  String get carPlateNumber;

  /// acceptPrivacyPolicy
  ///
  /// In en, this message translates to:
  /// **'I agree to the Privacy Policy'**
  String get acceptPrivacyPolicy;

  /// view
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// mustAcceptPrivacyPolicy
  ///
  /// In en, this message translates to:
  /// **'You must agree to the Privacy Policy before creating an account'**
  String get mustAcceptPrivacyPolicy;

  /// usernameValidation
  ///
  /// In en, this message translates to:
  /// **'Username must be 4-8 alphanumeric characters only'**
  String get usernameValidation;

  /// emailValidation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailValidation;

  /// phoneValidation
  ///
  /// In en, this message translates to:
  /// **'Phone number must be exactly 10 digits'**
  String get phoneValidation;

  /// passwordValidation
  ///
  /// In en, this message translates to:
  /// **'Password must contain four uppercase letters, four lowercase letters and a number'**
  String get passwordValidation;

  /// passwordsDoNotMatch
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// registrationSuccess
  ///
  /// In en, this message translates to:
  /// **'Registered Successfully'**
  String get registrationSuccess;

  /// accountCreatedSuccess
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully! Please login using your credentials.'**
  String get accountCreatedSuccess;

  /// accountAlreadyExists
  ///
  /// In en, this message translates to:
  /// **'This account is already registered. Please login or use different credentials'**
  String get accountAlreadyExists;

  /// phoneAlreadyUsed
  ///
  /// In en, this message translates to:
  /// **'Phone number is already used by another user.'**
  String get phoneAlreadyUsed;

  /// emailAlreadyUsed
  ///
  /// In en, this message translates to:
  /// **'Email is already used by another user.'**
  String get emailAlreadyUsed;

  /// weakPassword
  ///
  /// In en, this message translates to:
  /// **'Password is weak or invalid'**
  String get weakPassword;

  /// userAlreadyRegistered
  ///
  /// In en, this message translates to:
  /// **'User already registered'**
  String get userAlreadyRegistered;

  /// errorOccurred
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please check your data and try again'**
  String get errorOccurred;

  /// mobileNumber
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// emailAddress
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// reEnterPassword
  ///
  /// In en, this message translates to:
  /// **'Re-enter Password'**
  String get reEnterPassword;

  /// passwordHint
  ///
  /// In en, this message translates to:
  /// **'Four uppercase, four lowercase and a number'**
  String get passwordHint;

  /// recoverPassword
  ///
  /// In en, this message translates to:
  /// **'Recover Password'**
  String get recoverPassword;

  /// enterEmailToRecover
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password recovery link'**
  String get enterEmailToRecover;

  /// pleaseEnterEmail
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get pleaseEnterEmail;

  /// pleaseEnterValidEmail
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// resetLinkSent
  ///
  /// In en, this message translates to:
  /// **'Recovery link sent if account exists'**
  String get resetLinkSent;

  /// rateLimitError
  ///
  /// In en, this message translates to:
  /// **'You can request again after 15 seconds'**
  String get rateLimitError;

  /// errorOccurredMessage
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {message}'**
  String errorOccurredMessage(Object message);

  /// send
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;
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
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

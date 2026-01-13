import 'package:flutter/material.dart';

// ==================== LOCALIZATION ====================
class AppLocalization extends ChangeNotifier {
  static final AppLocalization _instance = AppLocalization._();
  static AppLocalization get instance => _instance;
  AppLocalization._();

  String _language = 'el'; // 'el' for Greek, 'en' for English
  String get language => _language;
  bool get isGreek => _language == 'el';

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  String get(String key) => _translations[_language]?[key] ?? key;

  // Sports list in current language
  List<String> get sports => isGreek
      ? ['Ποδόσφαιρο', 'Μπάσκετ', 'Τένις', 'Βόλεϊ', 'Yoga', 'Άλλο']
      : ['Football', 'Basketball', 'Tennis', 'Volleyball', 'Yoga', 'Other'];

  // Sport translation maps (for database storage and filtering)
  static const Map<String, String> _sportEnToEl = {
    'Football': 'Ποδόσφαιρο',
    'Basketball': 'Μπάσκετ',
    'Tennis': 'Τένις',
    'Volleyball': 'Βόλεϊ',
    'Yoga': 'Yoga',
    'Other': 'Άλλο',
  };
  static const Map<String, String> _sportElToEn = {
    'Ποδόσφαιρο': 'Football',
    'Μπάσκετ': 'Basketball',
    'Τένις': 'Tennis',
    'Βόλεϊ': 'Volleyball',
    'Yoga': 'Yoga',
    'Άλλο': 'Other',
  };

  // Convert sport to English (for database storage)
  String sportToEnglish(String s) => _sportElToEn[s] ?? s;

  // Convert sport to display language
  String sportToDisplay(String s) =>
      isGreek ? (_sportEnToEl[s] ?? s) : (_sportElToEn[s] ?? s);

  // Get English sport from any language
  String sportKey(String s) => _sportElToEn[s] ?? s;

  // Check if activity sport matches selected filter
  bool sportMatches(String? activitySport, String? filterSport) {
    if (filterSport == null) return true;
    if (activitySport == null) return false;
    final filterKey = sportKey(filterSport);
    final activityKey = sportKey(activitySport);
    return filterKey == activityKey;
  }

  static const Map<String, Map<String, String>> _translations = {
    'el': {
      // Login/Register
      'login': 'Σύνδεση',
      'register': 'Εγγραφή',
      'email': 'Email',
      'password': 'Κωδικός',
      'forgotPassword': 'Ξέχασες τον κωδικό;',
      'noAccount': 'Δεν έχεις λογαριασμό;',
      'hasAccount': 'Έχεις ήδη λογαριασμό;',
      'fillAllFields': 'Συμπλήρωσε όλα τα πεδία',
      'loginFailed': 'Αποτυχία σύνδεσης',
      'registerSuccess': 'Ο λογαριασμός δημιουργήθηκε! Συνδέσου.',
      'confirmPassword': 'Επιβεβαίωση Κωδικού',
      'birthDate': 'Ημερομηνία Γέννησης',
      'city': 'Πόλη',
      'fullName': 'Ονοματεπώνυμο',
      'back': 'Πίσω',
      'findTeam': 'Βρες την ομάδα σου για αθλητικές\nδραστηριότητες',
      'termsAgree': 'Με την εγγραφή συμφωνείς με τους',
      'termsOfUse': 'Όρους Χρήσης',
      'privacyPolicy': 'Πολιτική Απορρήτου',

      // Navigation
      'discover': 'Discover',
      'chat': 'Chat',
      'search': 'Search',
      'profile': 'Profile',

      // Discover
      'discoverActivities': 'Ανακάλυψε Δραστηριότητες',
      'findNextAdventure': 'Βρες την επόμενη αθλητική σου περιπέτεια',
      'noActivities':
          'Δεν υπάρχουν δραστηριότητες.\nΠάτα + για να δημιουργήσεις!',

      // Activity Card
      'joinTeam': 'Μπες στην ομάδα',
      'alreadyJoined': 'Έχεις δηλώσει συμμετοχή',
      'perPerson': 'ανά άτομο',
      'delete': 'Διαγραφή',
      'cancel': 'Άκυρο',
      'deleteConfirm': 'Αυτή η ενέργεια δεν μπορεί να αναιρεθεί.',

      // Create Activity
      'createActivity': 'Δημιούργησε Δραστηριότητα',
      'editActivity': 'Επεξεργασία',
      'createSubtitle':
          'Συμπλήρωσε τα στοιχεία για τη νέα αθλητική δραστηριότητα',
      'sport': 'Άθλημα',
      'selectSport': 'Επίλεξε άθλημα',
      'title': 'Τίτλος',
      'titleHint': 'π.χ. Ψάχνω ομάδα για 5x5',
      'date': 'Ημερομηνία',
      'dateHint': 'π.χ. Κυριακή 17/11',
      'time': 'Ώρα',
      'timeHint': 'π.χ. 10:00',
      'location': 'Τοποθεσία',
      'locationHint': 'π.χ. Γήπεδο Καλαμαριάς',
      'address': 'Διεύθυνση',
      'addressHint': 'π.χ. Λεωφ. Στρατού 45, Καλαμαριά',
      'cost': 'Τιμή (€)',
      'maxPlayers': 'Μέγιστα Άτομα',
      'description': 'Περιγραφή',
      'descriptionHint': 'Πες μας περισσότερα για τη δραστηριότητα...',
      'create': 'Δημιουργία',
      'tapToSelectLocation': 'Πάτα στον χάρτη για να επιλέξεις τοποθεσία',
      'join': 'Συμμετοχή',
      'leave': 'Αποχώρηση',

      // Search
      'searchTitle': 'Αναζήτηση',
      'searchSubtitle': 'Βρες τη δραστηριότητα που σου ταιριάζει',
      'searchHint': 'Αναζήτηση για άθλημα, τοποθεσία...',
      'results': 'αποτελέσματα',
      'noResults': 'Δεν βρέθηκαν αποτελέσματα',
      'filters': 'Φίλτρα',
      'selectSportFilter': 'Επίλεξε το άθλημα που σε ενδιαφέρει',
      'all': 'Όλα',

      // Chat
      'yourTeams': 'Οι Ομάδες σου',
      'chatSubtitle': 'Συνομιλίες με τις αθλητικές σου ομάδες',
      'joinToChat':
          'Μπες σε μια δραστηριότητα για να ξεκινήσεις να συνομιλείς!',
      'members': 'μέλη',
      'typeMessage': 'Γράψε μήνυμα...',
      'noMessagesYet': 'Δεν υπάρχουν μηνύματα ακόμα.\nΞεκίνα τη συνομιλία!',

      // Profile
      'editProfile': 'Επεξεργασία',
      'memberSince': 'Μέλος από',
      'participations': 'Συμμετοχές',
      'creations': 'Δημιουργίες',
      'connections': 'Συνδέσεις',
      'favoriteSports': 'Αγαπημένα Αθλήματα',
      'recentActivities': 'Πρόσφατες Δραστηριότητες',
      'upcoming': 'Επερχόμενο',
      'bio': 'Bio',
      'save': 'Αποθήκευση',
      'photoUploadComingSoon': 'Ανέβασμα φωτογραφίας σύντομα!',

      // Settings
      'settings': 'Ρυθμίσεις',
      'notifications': 'Ειδοποιήσεις',
      'newMessages': 'Νέα μηνύματα',
      'newMessagesDesc': 'Λάβε ειδοποιήσεις για νέα μηνύματα',
      'newActivities': 'Νέες δραστηριότητες',
      'newActivitiesDesc': 'Ειδοποιήσεις για νέες δραστηριότητες',
      'reminders': 'Υπενθυμίσεις',
      'remindersDesc': 'Υπενθύμιση πριν από τις δραστηριότητες',
      'preferences': 'Προτιμήσεις',
      'language': 'Γλώσσα',
      'languageDesc': 'Ελληνικά',
      'privacy': 'Απόρρητο',
      'privacyDesc': 'Διαχείριση δεδομένων',
      'support': 'Υποστήριξη',
      'helpFaq': 'Βοήθεια & FAQ',
      'helpFaqDesc': 'Απαντήσεις σε συχνές ερωτήσεις',
      'logout': 'Αποσύνδεση',
      'privacyMessage':
          'Τα δεδομένα σου προστατεύονται σύμφωνα με τον GDPR. Δεν μοιραζόμαστε τις πληροφορίες σου με τρίτους χωρίς τη συγκατάθεσή σου.',
    },
    'en': {
      // Login/Register
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot your password?',
      'noAccount': 'Don\'t have an account?',
      'hasAccount': 'Already have an account?',
      'fillAllFields': 'Please fill in all fields',
      'loginFailed': 'Login failed',
      'registerSuccess': 'Account created! Please login.',
      'confirmPassword': 'Confirm Password',
      'birthDate': 'Date of Birth',
      'city': 'City',
      'fullName': 'Full Name',
      'back': 'Back',
      'findTeam': 'Find your team for sports\nactivities',
      'termsAgree': 'By registering you agree to the',
      'termsOfUse': 'Terms of Use',
      'privacyPolicy': 'Privacy Policy',

      // Navigation
      'discover': 'Discover',
      'chat': 'Chat',
      'search': 'Search',
      'profile': 'Profile',

      // Discover
      'discoverActivities': 'Discover Activities',
      'findNextAdventure': 'Find your next sports adventure',
      'noActivities': 'No activities yet.\nTap + to create one!',

      // Activity Card
      'joinTeam': 'Join Team',
      'alreadyJoined': 'Already Joined',
      'perPerson': 'per person',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'deleteConfirm': 'This action cannot be undone.',

      // Create Activity
      'createActivity': 'Create Activity',
      'editActivity': 'Edit Activity',
      'createSubtitle': 'Fill in the details for your new sports activity',
      'sport': 'Sport',
      'selectSport': 'Select sport',
      'title': 'Title',
      'titleHint': 'e.g. Looking for 5v5 team',
      'date': 'Date',
      'dateHint': 'e.g. Sunday 17/11',
      'time': 'Time',
      'timeHint': 'e.g. 10:00',
      'location': 'Location',
      'locationHint': 'e.g. Central Park Field',
      'address': 'Address',
      'addressHint': 'e.g. 123 Main Street',
      'cost': 'Cost (€)',
      'maxPlayers': 'Max Players',
      'description': 'Description',
      'descriptionHint': 'Tell us more about the activity...',
      'create': 'Create',
      'tapToSelectLocation': 'Tap on the map to select location',
      'join': 'Join',
      'leave': 'Leave',

      // Search
      'searchTitle': 'Search',
      'searchSubtitle': 'Find the activity that suits you',
      'searchHint': 'Search for sport, location...',
      'results': 'results',
      'noResults': 'No results found',
      'filters': 'Filters',
      'selectSportFilter': 'Select the sport you\'re interested in',
      'all': 'All',

      // Chat
      'yourTeams': 'Your Teams',
      'chatSubtitle': 'Chat with your sports teams',
      'joinToChat': 'Join an activity to start chatting!',
      'members': 'members',
      'typeMessage': 'Type a message...',
      'noMessagesYet': 'No messages yet.\nStart the conversation!',

      // Profile
      'editProfile': 'Edit',
      'memberSince': 'Member since',
      'participations': 'Participations',
      'creations': 'Creations',
      'connections': 'Connections',
      'favoriteSports': 'Favorite Sports',
      'recentActivities': 'Recent Activities',
      'upcoming': 'Upcoming',
      'bio': 'Bio',
      'save': 'Save',
      'photoUploadComingSoon': 'Photo upload coming soon!',

      // Settings
      'settings': 'Settings',
      'notifications': 'Notifications',
      'newMessages': 'New messages',
      'newMessagesDesc': 'Get notifications for new messages',
      'newActivities': 'New activities',
      'newActivitiesDesc': 'Notifications for new activities',
      'reminders': 'Reminders',
      'remindersDesc': 'Reminder before activities',
      'preferences': 'Preferences',
      'language': 'Language',
      'languageDesc': 'English',
      'privacy': 'Privacy',
      'privacyDesc': 'Data management',
      'support': 'Support',
      'helpFaq': 'Help & FAQ',
      'helpFaqDesc': 'Answers to common questions',
      'logout': 'Logout',
      'privacyMessage':
          'Your data is protected according to GDPR. We do not share your information with third parties without your consent.',
    },
  };
}

// Shortcut for getting translations
String tr(String key) => AppLocalization.instance.get(key);

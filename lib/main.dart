import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Για τον χάρτη
import 'package:latlong2/latlong.dart';        // Για τις συντεταγμένες
import 'database_helper.dart';
import 'dart:developer' as developer;


void main() => runApp(const TribeApp());

class TribeApp extends StatelessWidget {
  const TribeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const LoginScreen(),
    );
  }
}

// --- ΣΤΑΘΕΡΑ ΧΡΩΜΑΤΑ & ΣΤΥΛ ---
const Color kBackgroundColor = Color(0xFF0F172A);
const Color kCardColor = Color(0xFF1E293B);
const Color kPrimaryBlue = Color(0xFF2563EB);
const Color kInputFillColor = Color(0xFF161F32);
const Color kIncomingChatColor = Color(0xFF262F3F);
const Color kFilterSheetColor = Color(0xFF121212);

BoxDecoration kCardDecoration = BoxDecoration(
  color: kCardColor,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: Colors.white10),
);

// ==========================================
// 1. ΚΥΡΙΑ ΠΛΟΗΓΗΣΗ (TABS)
// ==========================================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DiscoverTab(),
    const ChatTab(),
    const SearchTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: kCardColor,
        selectedItemColor: kPrimaryBlue,
        unselectedItemColor: Colors.white38,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. ΟΘΟΝΗ ΛΕΠΤΟΜΕΡΕΙΕΣ CHAT 
// ==========================================
class ChatDetailScreen extends StatelessWidget {
  final Activity activity; // Προσθήκη παραμέτρου

  const ChatDetailScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white10,
              child: Icon(Icons.groups, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title, // Δυναμικός τίτλος από τη δραστηριότητα
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${activity.currentPlayers}/${activity.maxPlayers} μέλη', // Δυναμικά μέλη
                    style: const TextStyle(fontSize: 12, color: Colors.white38),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                activity.sportCategory, // Δυναμικό άθλημα
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: kCardDecoration,
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: kPrimaryBlue),
                const SizedBox(width: 8),
                Text(
                  '${activity.date}, ${activity.time}', // Δυναμική ημερομηνία/ώρα
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const Spacer(),
                const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(
                  activity.location.split('(').first, // Δυναμική τοποθεσία
                  style: const TextStyle(fontSize: 13, color: Colors.white, decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
          const Expanded(child: Center(child: Text("Εδώ θα εμφανίζονται τα μηνύματα της ομάδας"))),
        ],
      ),
    );
  }
}

// ==========================================
// 3. CHAT TAB 
// ==========================================
class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: const Text(
          'Μηνύματα',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Αναζήτηση συνομιλιών...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: kInputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          _buildChatItem(
            context,
            'Παιχνίδι 3x3 στο κέντρο',
            'Μαρία: Θα φέρω μπάλα!',
            '14:23',
            true, 
          ),
          _buildChatItem(
            context,
            '5x5 Τετάρτης',
            'Νίκος: Ποιος λείπει;',
            'Χθες',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, String title, String subtitle, String time, bool isUnread) {
    return ListTile(
      onTap: () => Navigator.push(
       context,
    MaterialPageRoute(
    builder: (context) => ChatDetailScreen(
      // Στέλνουμε dummy δεδομένα για το παράδειγμα στη λίστα Chat
      activity: Activity(
        userName: 'Admin',
        sportCategory: 'Μπάσκετ',
        title: title, 
        date: 'Σήμερα',
        time: time,
        location: 'Γήπεδο',
        description: '',
        maxPlayers: 10,
        currentPlayers: 5,
      ),
    ),
  ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: const CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white10,
        child: Icon(Icons.groups, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          if (isUnread) ...[
            const SizedBox(height: 6),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: kPrimaryBlue,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================
// 4. DISCOVER TAB 
// ==========================================
class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  // Η λίστα με τις δραστηριότητες
  List<Activity> _activities = [];

  @override
  void initState() {
    super.initState();
    _refreshActivities(); // Φορτώνει τα δεδομένα μόλις ανοίξει η εφαρμογή
  }

  Future _refreshActivities() async {
  developer.log("DEBUG: Ξεκινάω φόρτωση...", name: 'DiscoverTab', level: 800); // Για να βλέπεις τι γίνεται
  try {
    final data = await DatabaseHelper.instance.getAllActivities();
    developer.log("DEBUG: Η βάση απάντησε με ${data.length} εγγραφές.", name: 'DiscoverTab', level: 800);
    
    if (mounted) { // Έλεγχος αν η οθόνη υπάρχει ακόμα
      setState(() {
        _activities = data.map((map) => Activity.fromMap(map)).toList();
      });
    }
  } catch (e, st) {
    developer.log('DEBUG: ΣΦΑΛΜΑ ΒΑΣΗΣ', name: 'DiscoverTab', level: 1000, error: e, stackTrace: st);
  }
} 
 void _showCreateActivity(BuildContext context) async {
  // 1. Περιμένουμε πρώτα να πάρουμε το αποτέλεσμα από τη φόρμα
  final Activity? newActivity = await showModalBottomSheet<Activity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreateActivitySheet(),
  );

  // 2. Ελέγχουμε αν όντως δημιουργήθηκε νέα δραστηριότητα
  if (newActivity != null) {
    // Αποθήκευση στη βάση δεδομένων
    await DatabaseHelper.instance.insertActivity(newActivity.toMap());
    
    // Ανανέωση της λίστας που βλέπουμε στην οθόνη από τη βάση
    _refreshActivities();
  }
}

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const SportsFiltersSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: const Text(
          'Tribe',
          style: TextStyle(
            color: kPrimaryBlue,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showCreateActivity(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ανακάλυψε\nΔραστηριότητες', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Βρες την επόμενη περιπέτεια', style: TextStyle(color: Colors.white60, fontSize: 13)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.tune, color: kPrimaryBlue),
                  onPressed: () => _showFilters(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final act = _activities[index];
                return ActivityCard(
                  userName: act.userName,
                  sportCategory: act.sportCategory,
                  title: act.title,
                  date: act.date,
                  time: act.time,
                  location: act.location,
                  price: 'Δωρεάν', 
                  description: act.description,
                  currentPlayers: act.currentPlayers,
                  maxPlayers: act.maxPlayers,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
// ==========================================
// WIDGET: ΤΑ ΦΙΛΤΡΑ (SportsFiltersSheet) - ΔΙΟΡΘΩΜΕΝΟ SCROLL
// ==========================================
class SportsFiltersSheet extends StatefulWidget {
  const SportsFiltersSheet({super.key});

  @override
  State<SportsFiltersSheet> createState() => _SportsFiltersSheetState();
}

class _SportsFiltersSheetState extends State<SportsFiltersSheet> {
  String selectedFilter = 'Όλα';
  
  final List<String> categories = [
    'Όλα',
    'Ποδόσφαιρο',
    'Μπάσκετ',
    'Τένις',
    'Βόλεϊ',
    'Yoga',
    'Crossfit',
    'Κολύμβηση',
    'Ποδηλασία',
    'Άλλα',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B), // kCardColor
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Φίλτρα',
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Text(
            'Επίλεξε το άθλημα που σε ενδιαφέρει',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 20),
          
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedFilter == category;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? kPrimaryBlue
                            : const Color(0xFF2A2A2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: () => setState(() => selectedFilter = category),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Εφαρμογή Φίλτρων',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ==========================================
// ΔΗΜΙΟΥΡΓΙΑ ΔΡΑΣΤΗΡΙΟΤΗΤΑΣ (ΔΙΟΡΘΩΜΕΝΟ)
// ==========================================
class CreateActivitySheet extends StatefulWidget {
  const CreateActivitySheet({super.key});

  @override
  State<CreateActivitySheet> createState() => _CreateActivitySheetState();
}

class _CreateActivitySheetState extends State<CreateActivitySheet> {
  // Controllers για να διαβάζουμε το κείμενο
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _playersController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  String? selectedSport;
  
  // Λίστα αθλημάτων
  final List<String> sports = [
    'Ποδόσφαιρο', 'Μπάσκετ', 'Τένις', 'Βόλεϊ', 'Yoga', 'Άλλα',
  ];

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryBlue,
              onPrimary: Colors.white,
              surface: kCardColor,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: kCardColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryBlue,
              onPrimary: Colors.white,
              surface: kCardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = "$hour:$minute";
      });
    }
  }

  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPicker()),
    );

    if (result != null) {
      setState(() {
        _locationController.text = "Τοποθεσία (${result.latitude.toStringAsFixed(3)}, ${result.longitude.toStringAsFixed(3)})";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: kFilterSheetColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Δημιουργήστε Δραστηριότητα',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            
            _buildLabel("Άθλημα *"),
            _buildDropdown(),
            
            const SizedBox(height: 16),
            // ΣΥΝΔΕΣΑΜΕ TON CONTROLLER
            _buildFormTextField(
              label: "Τίτλος *", 
              hint: "π.χ. Ψάχνω ομάδα για 5x5",
              controller: _titleController, 
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFormTextField(
                    label: "Ημερομηνία *",
                    hint: "Επίλεξε...",
                    controller: _dateController,
                    readOnly: true,
                    icon: Icons.calendar_today,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFormTextField(
                    label: "Ώρα *",
                    hint: "Επίλεξε...",
                    controller: _timeController,
                    readOnly: true,
                    icon: Icons.access_time,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            _buildFormTextField(
              label: "Τοποθεσία (Πάτησε για χάρτη) *",
              hint: "Επίλεξε στο χάρτη...",
              controller: _locationController,
              readOnly: true,
              icon: Icons.map,
              onTap: _pickLocation,
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFormTextField(
                    label: "Τιμή (€)",
                    hint: "0",
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // ΣΥΝΔΕΣΑΜΕ TON CONTROLLER ΓΙΑ ΤΑ ΑΤΟΜΑ
                  child: _buildFormTextField(
                    label: "Μέγιστα Άτομα *",
                    hint: "π.χ. 10",
                    controller: _playersController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            // ΣΥΝΔΕΣΑΜΕ TON CONTROLLER ΓΙΑ ΤΗΝ ΠΕΡΙΓΡΑΦΗ
            _buildFormTextField(
              label: "Περιγραφή",
              hint: "Πες μας περισσότερα...",
              controller: _descController,
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Ακύρωση", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    // === ΕΔΩ ΕΙΝΑΙ Η ΔΙΟΡΘΩΣΗ ===
                    onPressed: () {
                      // 1. Έλεγχος αν συμπληρώθηκαν τα βασικά
                      if (_titleController.text.isEmpty || selectedSport == null) {
                        return; // Ή δείξε ένα μήνυμα λάθους
                      }

                      // 2. Δημιουργία του αντικειμένου Activity
                      final newActivity = Activity(
                        userName: 'Εγώ', // Dummy όνομα χρήστη
                        sportCategory: selectedSport!,
                        title: _titleController.text,
                        date: _dateController.text.isEmpty ? 'Σήμερα' : _dateController.text,
                        time: _timeController.text.isEmpty ? '12:00' : _timeController.text,
                        location: _locationController.text.isEmpty ? 'Άγνωστη τοποθεσία' : _locationController.text,
                        description: _descController.text,
                        maxPlayers: int.tryParse(_playersController.text) ?? 10,
                        currentPlayers: 1, // Ξεκινάει με 1 άτομο (εσένα)
                      );

                      // 3. Επιστροφή των δεδομένων πίσω στην προηγούμενη οθόνη
                      Navigator.pop(context, newActivity);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Δημιουργία",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  );

  Widget _buildDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: kInputFillColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedSport,
        isExpanded: true,
        hint: const Text("Επίλεξε άθλημα", style: TextStyle(color: Colors.white30)),
        dropdownColor: kCardColor,
        items: sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: (val) => setState(() => selectedSport = val),
      ),
    ),
  );

  Widget _buildFormTextField({
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    bool readOnly = false,
    IconData? icon,
    VoidCallback? onTap,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel(label),
      TextField(
        controller: controller, // Σύνδεση του controller
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          filled: true,
          fillColor: kInputFillColor,
          prefixIcon: icon != null ? Icon(icon, color: kPrimaryBlue, size: 20) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _playersController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

// ==========================================
// LOCATION PICKER MAP (ΝΕΟ WIDGET)
// ==========================================
class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng _selectedPos = const LatLng(40.6401, 22.9444); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Επίλεξε Τοποθεσία"),
        backgroundColor: kBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: kPrimaryBlue),
            onPressed: () {
              Navigator.pop(context, _selectedPos);
            },
          )
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _selectedPos,
          initialZoom: 14.0,
          onTap: (tapPosition, point) {
            setState(() {
              _selectedPos = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.tribe_app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedPos,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on, 
                  color: Colors.red, 
                  size: 50,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryBlue,
        onPressed: () {
          Navigator.pop(context, _selectedPos);
        },
        label: const Text("Επιβεβαίωση", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}

// ==========================================
// 5. SEARCH TAB 
// ==========================================
class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const SportsFiltersSheet(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        toolbarHeight: 50, 
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Αναζήτηση',
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Βρες τη δραστηριότητα που σου ταιριάζει',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Αναζήτηση για άθλημα...',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.white54),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: () => _showFilters(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                const Text(
                  '5 αποτελέσματα',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                ActivityCard(
                  userName: 'Γιώργος Παπαδόπουλος',
                  sportCategory: 'Ποδόσφαιρο',
                  title: 'Ψάχνω ομάδα για 5x5',
                  date: 'Κυριακή 17/11',
                  time: '10:00',
                  location: 'Γήπεδο Καλαμαριάς\nΛεωφ. Στρατού 45, Καλαμαριά',
                  price: '5€ ανά άτομο',
                  description: 'Ψάχνουμε άτομα για φιλικό παιχνίδι. Όλα τα επίπεδα είναι ευπρόσδεκτα!',
                  currentPlayers: 3,
                  maxPlayers: 10,
                ),
                SizedBox(height: 20),
                ActivityCard(
                  userName: 'Μαρία Κωνσταντίνου',
                  sportCategory: 'Μπάσκετ',
                  title: 'Παιχνίδι 3x3 στο κέντρο',
                  date: 'Σάββατο 16/11',
                  time: '18:00',
                  location: 'Γήπεδο Αλεξάνδρου\nΠλατεία Αλεξάνδρας, Αθήνα',
                  price: 'Δωρεάν',
                  description: 'Χαλαρό μπασκετάκι το απόγευμα.',
                  currentPlayers: 5,
                  maxPlayers: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. PROFILE TAB (ΑΝΑΒΑΘΜΙΣΜΕΝΟ)
// ==========================================
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // Αρχικές τιμές που θα αντικατασταθούν από τη βάση
  String name = 'Φορτώνει...';
  String location = '...';
  String bio = '...';

  @override
  void initState() {
    super.initState();
    _loadProfile(); // Κλήση της μεθόδου για φόρτωση από τη βάση
  }

  // Μέθοδος που διαβάζει το προφίλ από τη βάση δεδομένων
  Future<void> _loadProfile() async {
    final profileData = await DatabaseHelper.instance.getProfile();
    if (profileData != null) {
      setState(() {
        name = profileData['name'] ?? 'Γιάννης Παπαδόπουλος';
        location = profileData['location'] ?? 'Θεσσαλονίκη, Ελλάδα';
        bio = profileData['bio'] ?? 'Λάτρης του αθλητισμού!';
      });
    } else {
      setState(() {
        name = 'Γιάννης Παπαδόπουλος';
        location = 'Θεσσαλονίκη, Ελλάδα';
        bio = 'Λάτρης του αθλητισμού!';
      });
    }
  } // <--- Εδώ κλείνει σωστά η _loadProfile

  // Η μέθοδος πρέπει να είναι ξεχωριστή μέσα στην κλάση
  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(
        currentName: name,
        currentLocation: location,
        currentBio: bio,
        onSave: (newName, newLoc, newBio) async {
          setState(() {
            name = newName;
            location = newLoc;
            bio = newBio;
          });
          await DatabaseHelper.instance.saveProfile({
            'id': 1,
            'name': newName,
            'location': newLoc,
            'bio': newBio,
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: const Text(
          'Tribe',
          style: TextStyle(
            color: kPrimaryBlue,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: kCardDecoration,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: kPrimaryBlue),
                        onPressed: () => _showEditProfile(context),
                      )
                    ],
                  ),
                  
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(location, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('24', 'Συμμετοχές'),
                      _buildStatColumn('8', 'Δημιουργίες'),
                      _buildStatColumn('47', 'Συνδέσεις'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Πρόσφατες Δραστηριότητες",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            _buildActivityItem(
              title: "Παιχνίδι 3x3 στο κέντρο",
              date: DateTime.now().add(const Duration(days: 2)),
              sport: "Μπάσκετ",
            ),
            _buildActivityItem(
              title: "Ψάχνω ομάδα για 5x5",
              date: DateTime.now().subtract(const Duration(days: 1)),
              sport: "Ποδόσφαιρο",
            ),
             _buildActivityItem(
              title: "Πρωινό Doubles",
              date: DateTime(2023, 11, 8),
              sport: "Τένις",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String val, String label) => Column(
    children: [
      Text(
        val,
        style: const TextStyle(
          color: kPrimaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
    ],
  );

  Widget _buildActivityItem({required String title, required DateTime date, required String sport}) {
    final now = DateTime.now();
    final isCompleted = date.isBefore(now);
    
    final dateStr = "${date.day}/${date.month}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // kCardColor
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(sport, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(dateStr, style: const TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.white12 : kPrimaryBlue.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted ? Colors.white24 : kPrimaryBlue,
              ),
            ),
            child: Text(
              isCompleted ? "Ολοκληρώθηκε" : "Επερχόμενο",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.white54 : kPrimaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// NEW: EDIT PROFILE SHEET
// ==========================================
class EditProfileSheet extends StatefulWidget {
  final String currentName;
  final String currentLocation;
  final String currentBio;
  final Function(String, String, String) onSave;

  const EditProfileSheet({
    super.key,
    required this.currentName,
    required this.currentLocation,
    required this.currentBio,
    required this.onSave,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _locController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _locController = TextEditingController(text: widget.currentLocation);
    _bioController = TextEditingController(text: widget.currentBio);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Επεξεργασία Προφίλ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildTextField("Όνομα", _nameController),
          const SizedBox(height: 12),
          _buildTextField("Τοποθεσία", _locController),
          const SizedBox(height: 12),
          _buildTextField("Βιογραφικό", _bioController, maxLines: 3),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue),
              onPressed: () {
                widget.onSave(_nameController.text, _locController.text, _bioController.text);
                Navigator.pop(context);
              },
              child: const Text("Αποθήκευση", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.black12,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}

// ==========================================
// ΡΥΘΜΙΣΕΙΣ 
// ==========================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _newMessages = true;
  bool _newActivities = true;
  bool _reminders = false;

  String _selectedPrivacy = 'Μόνο εγώ'; 
  String _selectedLanguage = 'Ελληνικά'; 

  final List<String> languages = [
    'Ελληνικά', 'English', 'Español', 'Français', 'Deutsch',
    'Italiano', 'Português', 'Русский', '中文', '日本語'
  ];

  final List<String> privacyOptions = [
    'Μόνο εγώ',
    'Άτομα της περιοχής μου',
    'Όλοι'
  ];

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Επιλογή Γλώσσας", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = _selectedLanguage == lang;

                  return ListTile(
                    title: Text(
                      lang, 
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                      )
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: kPrimaryBlue) : null,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang;
                      });
                      Navigator.pop(context); 
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Ποιος βλέπει τα στοιχεία μου;", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: privacyOptions.map((option) {
            final isSelected = _selectedPrivacy == option;
            return ListTile(
              title: Text(
                option, 
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, 
                color: kPrimaryBlue
              ),
              onTap: () {
                setState(() {
                  _selectedPrivacy = option;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Βοήθεια & FAQ", style: TextStyle(color: Colors.white)), 
            backgroundColor: kBackgroundColor,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: kBackgroundColor,
          body: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Πώς λειτουργεί το Tribe;", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text(
                  "Το Tribe σε βοηθάει να βρεις άτομα για αθλητικές δραστηριότητες κοντά σου.\n\n"
                  "1. Αναζήτησε αγώνες στην περιοχή σου.\n"
                  "2. Μπες στην ομάδα και μίλα στο chat.\n"
                  "3. Αξιολόγησε τους συμπαίκτες σου μετά τον αγώνα.\n\n"
                  "Για οποιοδήποτε πρόβλημα επικοινωνήστε στο support@tribe.gr",
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), 
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: const Text('Ρυθμίσεις', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          _buildSettingsHeader('Ειδοποιήσεις'),
          SwitchListTile(
            value: _newMessages,
            activeThumbColor: kPrimaryBlue,
            title: const Text('Νέα μηνύματα'),
            subtitle: const Text('Λάβε ειδοποιήσεις για νέα μηνύματα', style: TextStyle(fontSize: 12, color: Colors.white38)),
            onChanged: (val) => setState(() => _newMessages = val),
          ),
          SwitchListTile(
            value: _newActivities,
            activeThumbColor: kPrimaryBlue,
            title: const Text('Νέες δραστηριότητες'),
            subtitle: const Text('Ειδοποιήσεις για νέες δραστηριότητες', style: TextStyle(fontSize: 12, color: Colors.white38)),
            onChanged: (val) => setState(() => _newActivities = val),
          ),
          SwitchListTile(
            value: _reminders,
            activeThumbColor: kPrimaryBlue,
            title: const Text('Υπενθυμίσεις'),
            subtitle: const Text('Υπενθύμιση πριν από τις δραστηριότητες', style: TextStyle(fontSize: 12, color: Colors.white38)),
            onChanged: (val) => setState(() => _reminders = val),
          ),
          
          const Divider(color: Colors.white10),
          
          _buildSettingsHeader('Προτιμήσεις'),
          
          _buildNavTile(
            Icons.language, 
            'Γλώσσα', 
            _selectedLanguage, 
            onTap: _showLanguageSelector
          ),
          
          _buildNavTile(
            Icons.lock_outline, 
            'Απόρρητο', 
            _selectedPrivacy,
            onTap: _showPrivacySelector
          ),
          
          const Divider(color: Colors.white10),
          
          _buildSettingsHeader('Υποστήριξη'),
          _buildNavTile(Icons.help_outline, 'Βοήθεια & FAQ', 'Απαντήσεις στις συχνές ερωτήσεις', onTap: _showHelp),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: _handleLogout,
              child: const Text(
                'Αποσύνδεση',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Center(
            child: Text('Tribe v1.0.0', style: TextStyle(color: Colors.white24, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(
      title,
      style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );

  Widget _buildNavTile(IconData icon, String title, String sub, {required VoidCallback onTap}) => ListTile(
    leading: Icon(icon, color: Colors.white70),
    title: Text(title),
    subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white38)),
    trailing: const Icon(Icons.chevron_right, color: Colors.white24),
    onTap: onTap,
  );
}

// ==========================================
// 7. LOGIN & HELPER UI WIDGETS
// ==========================================
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 80),
            _buildLogoHeader(),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: kCardDecoration,
              child: Column(
                children: [
                  const Text(
                    'Σύνδεση',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildSimpleTextField('Email', 'email@example.com'),
                  const SizedBox(height: 16),
                  _buildSimpleTextField(
                    'Κωδικός',
                    '••••••••',
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),
                  _buildPrimaryButton(
                    'Σύνδεση',
                    () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigation(),
                      ),
                    ),
                  ),
                  _buildSecondaryButton(
                    'Εγγραφή',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: kCardDecoration,
          child: Column(
            children: [
              const Text(
                'Tribe',
                style: TextStyle(
                  fontSize: 40,
                  color: kPrimaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _buildIconTextField(
                'Ονοματεπώνυμο *',
                'Γιάννης Π.',
                Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildIconTextField(
                'Email *',
                'email@example.com',
                Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _buildIconTextField(
                'Κωδικός *',
                '••••••',
                Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 30),
              _buildPrimaryButton('Εγγραφή', () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}

// HELPER WIDGETS
Widget _buildLogoHeader() => const Center(
  child: Column(
    children: [
      Text(
        'Tribe',
        style: TextStyle(
          fontSize: 48,
          color: kPrimaryBlue,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      Text(
        'Join the game',
        style: TextStyle(color: Colors.white38, letterSpacing: 1.2),
      ),
    ],
  ),
);
Widget _buildSimpleTextField(
  String label,
  String hint, {
  bool isPassword = false,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
    const SizedBox(height: 8),
    TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: kInputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    ),
  ],
);
Widget _buildIconTextField(
  String label,
  String hint,
  IconData icon, {
  bool isPassword = false,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
    const SizedBox(height: 8),
    TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        hintText: hint,
        filled: true,
        fillColor: kInputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  ],
);
Widget _buildPrimaryButton(String text, VoidCallback onPressed) => SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ),
);
Widget _buildSecondaryButton(String text, VoidCallback onPressed) => TextButton(
  onPressed: onPressed,
  child: Text(
    text,
    style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold),
  ),
);

// ==========================================
// REAL MAP (OpenStreetMap)
// ==========================================
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A), 
        title: const Text('Τοποθεσία Γηπέδου'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(40.6401, 22.9444),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.tribe_app',
          ),
          const MarkerLayer(
            markers: [
              Marker(
                point: LatLng(40.6401, 22.9444), 
                width: 80,
                height: 80,
                child: Icon(
                  Icons.location_on, 
                  color: Colors.red, 
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// WIDGET: Η ΚΑΡΤΑ ΔΡΑΣΤΗΡΙΟΤΗΤΑΣ
// ==========================================
class ActivityCard extends StatefulWidget {
  final String userName;
  final String sportCategory;
  final String title;
  final String date;
  final String time;
  final String location;
  final String price;
  final String description;
  final int currentPlayers;
  final int maxPlayers;

  const ActivityCard({
    super.key,
    required this.userName,
    required this.sportCategory,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.description,
    required this.currentPlayers,
    required this.maxPlayers,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool isJoined = false;
  late int displayedPlayers; 

  @override
  void initState() {
    super.initState();
    displayedPlayers = widget.currentPlayers;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isJoined) {
          Navigator.push(
            context,
     MaterialPageRoute(
      builder: (context) => ChatDetailScreen(
        activity: Activity(
          userName: widget.userName,
          sportCategory: widget.sportCategory,
          title: widget.title,
          date: widget.date,
          time: widget.time,
          location: widget.location,
          description: widget.description,
          maxPlayers: widget.maxPlayers,
          currentPlayers: displayedPlayers,
        ),
      ),
    ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Πρέπει να μπεις στην ομάδα για να δεις το Chat!"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardColor, 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.sportCategory,
                    style: const TextStyle(
                      color: kPrimaryBlue, 
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            _buildDetailRow(Icons.calendar_today_outlined, widget.date),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time, widget.time),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.location_on_outlined, widget.location),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.euro, widget.price),
            
            const SizedBox(height: 16),
            
            Text(
              widget.description,
              style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
            ),
            
            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.people_outline, color: kPrimaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$displayedPlayers/${widget.maxPlayers}', 
                  style: const TextStyle(
                    color: kPrimaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: displayedPlayers / widget.maxPlayers, 
                backgroundColor: Colors.white10,
                color: kPrimaryBlue,
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isJoined = !isJoined;
                    if (isJoined) {
                      if (displayedPlayers < widget.maxPlayers) displayedPlayers++;
                    } else {
                      displayedPlayers--;
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isJoined ? Colors.grey[700] : kPrimaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isJoined ? "Έχεις μπει - Άνοιξε Chat" : "Μπες στην ομάδα",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.white54),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
// === Η ΜΟΝΑΔΙΚΗ ΚΛΑΣΗ ACTIVITY ===
class Activity {
  final int? id; 
  final String userName;
  final String sportCategory;
  final String title;
  final String date;
  final String time;
  final String location;
  final String description;
  final int maxPlayers;
  int currentPlayers;

  Activity({
    this.id,
    required this.userName,
    required this.sportCategory,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.maxPlayers,
    this.currentPlayers = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'sportCategory': sportCategory,
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'description': description,
      'maxPlayers': maxPlayers,
      'currentPlayers': currentPlayers,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      userName: map['userName'] ?? '',
      sportCategory: map['sportCategory'] ?? '',
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      maxPlayers: map['maxPlayers'] ?? 0,
      currentPlayers: map['currentPlayers'] ?? 1,
    );
  }
}
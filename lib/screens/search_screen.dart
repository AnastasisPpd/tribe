import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../localization.dart';
import '../../firebase_helper.dart';
import '../../widgets/activity_card.dart';
import '../../tribe_header.dart';
import 'settings_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSport; // Single selection like create activity

  List<String> get _allSports => AppLocalization.instance.sports;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Row: Tribe Logo + Settings Icon
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TribeHeader(),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white70,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ),
        // Title (Blue, no subtitle)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              tr('searchTitle'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kBlue,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
        // Search Bar & Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: tr('searchHint'),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        filled: true,
                        fillColor: kInputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFilterDialog,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _selectedSport != null ? kBlue : kInputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.filter_list,
                        color: _selectedSport != null
                            ? Colors.white
                            : Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedSport != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Chip(
                    label: Text(
                      AppLocalization.instance.sportToDisplay(_selectedSport!),
                    ),
                    backgroundColor: kBlue,
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                    onDeleted: () => setState(() => _selectedSport = null),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Results
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirebaseHelper.instance.streamUpcomingActivities(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: kBlue),
                );
              }

              final activities = snapshot.data!;
              final filtered = activities.where((data) {
                final title = (data['title'] ?? '').toString().toLowerCase();
                final sport = (data['sport'] ?? '').toString();

                final matchesSearch = title.contains(
                  _searchQuery.toLowerCase(),
                );

                final matchesSport =
                    _selectedSport == null ||
                    AppLocalization.instance.sportKey(sport) ==
                        AppLocalization.instance.sportKey(_selectedSport!);

                return matchesSearch && matchesSport;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    tr('noResults'),
                    style: const TextStyle(color: Colors.white38),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return ActivityCard(activity: filtered[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('filters'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedSport = null);
                          Navigator.pop(context);
                        },
                        child: Text(
                          tr('clear'),
                          style: const TextStyle(color: kBlue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('selectSportFilter'),
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  // Scrollable list of sports with checkmarks
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [tr('all'), ..._allSports].map((sport) {
                        final isAll = sport == tr('all');
                        final isSelected = isAll
                            ? _selectedSport == null
                            : _selectedSport == sport;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedSport = isAll ? null : sport;
                            });
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? kBlue : kInputFill,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left: Label
                                Text(
                                  isAll
                                      ? tr('all')
                                      : AppLocalization.instance.sportToDisplay(
                                          sport,
                                        ),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                                // Right: Checkmark
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/app_constants.dart' ;
import 'package:intl/intl.dart';

class ScheduleBottomSheetContent extends StatefulWidget {
  const ScheduleBottomSheetContent({super.key});

  @override
  State<ScheduleBottomSheetContent> createState() =>
      _ScheduleBottomSheetContentState();
}

class _ScheduleBottomSheetContentState extends State<ScheduleBottomSheetContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSlotIndex = 0;
  int _selectedTabIndex = 0;

  late List<DateTime> _dates;
  late List<List<String>> _timeSlotsPerDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
          _selectedSlotIndex = 0; // Reset selection on tab change
        });
      }
    });

    _generateDatesAndTimeSlots();
  }

  void _generateDatesAndTimeSlots() {
    final now = DateTime.now();
    _dates = [
      now,
      now.add(const Duration(days: 1)),
      now.add(const Duration(days: 2)),
    ];

    _timeSlotsPerDay = [
      _generateTimeSlotsForDate(_dates[0], isToday: true),
      _generateTimeSlotsForDate(_dates[1]),
      _generateTimeSlotsForDate(_dates[2]),
    ];
  }

  List<String> _generateTimeSlotsForDate(DateTime dt, {bool isToday = false}) {
    final slots = <String>[];

    int startHour = 0; // Default start time 12:00 AM (Whole day)
    int startMinute = 0;

    if (isToday) {
      final now = DateTime.now();
      int minutes = now.minute;
      startHour = now.hour;

      if (minutes < 30) {
        startMinute = 30;
      } else {
        startMinute = 0;
        startHour += 1;
      }
    }

    DateTime currentSlot = DateTime(
      dt.year,
      dt.month,
      dt.day,
      startHour,
      startMinute,
    );
    final endOfDay = DateTime(
      dt.year,
      dt.month,
      dt.day,
      23,
      30,
    ); // Last slot starts at 11:30 PM

    // If it's too late in the day
    if (currentSlot.isAfter(endOfDay)) {
      return ['No slots available'];
    }

    while (currentSlot.isBefore(endOfDay) ||
        currentSlot.isAtSameMomentAs(endOfDay)) {
      DateTime nextSlot = currentSlot.add(const Duration(minutes: 30));
      slots.add('${_formatTime(currentSlot)} – ${_formatTime(nextSlot)}');
      currentSlot = nextSlot;
    }

    return slots;
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  String _getTabLabel(int index) {
    if (index == 0) return 'Today';
    if (index == 1) return 'Tomorrow';
    return DateFormat('EEEE').format(_dates[index]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Select your delivery time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E3333),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF008D4C),
            indicatorWeight: 3,
            labelPadding: EdgeInsets.zero,
            labelColor: const Color(0xFF2E3333),
            unselectedLabelColor: const Color(0xFFA1A5A5),
            tabs: List.generate(3, (index) {
              return Tab(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('d MMM').format(_dates[index]),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _getTabLabel(index),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const Divider(height: 1, color: Color(0xFFE8E9E9)),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimeList(0),
                _buildTimeList(1),
                _buildTimeList(2),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008D4C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeList(int tabIndex) {
    final slots = _timeSlotsPerDay[tabIndex];

    if (slots.length == 1 && slots[0] == 'No slots available') {
      return Center(
        child: Text(
          slots[0],
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final isSelected =
            (_selectedTabIndex == tabIndex) && (_selectedSlotIndex == index);
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSlotIndex = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF2F4F7) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              slots[index],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF4A5568)
                    : const Color(0xFFA1A5A5),
              ),
            ),
          ),
        );
      },
    );
  }
}

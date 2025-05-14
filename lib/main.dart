import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Booking System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: const BookingPage(),
    );
  }
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _focusedDay = DateTime(2025, 5, 1); // Start with May 2025
  DateTime _selectedDay = DateTime(
    2025,
    5,
    14,
  ); // Highlight current date (May 14, 2025)
  List bookings = [];
  Map<DateTime, List<dynamic>> _events = {};
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    fetchBookings();
    // Initialize default values for date and time
    _startDate = DateTime(2025, 5, 14);
    _startTime = const TimeOfDay(hour: 0, minute: 0);
    _endDate = DateTime(2025, 5, 14);
    _endTime = const TimeOfDay(hour: 1, minute: 0);
  }

  // Show toast message
  void _showToast(
    String message, {
    Color backgroundColor = Colors.grey,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Fetch all bookings from the API and map them to dates
  Future<void> fetchBookings() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://calendar-booking-app-backend.onrender.com/bookings',
            ),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your network connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        final fetchedBookings = jsonDecode(response.body);
        setState(() {
          bookings = fetchedBookings;
          _events = {};
          for (var booking in bookings) {
            final startDate = DateTime.parse(booking['startTime']).toLocal();
            final eventDate = DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
            );
            if (_events[eventDate] == null) {
              _events[eventDate] = [];
            }
            _events[eventDate]!.add(booking);
          }
        });
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Failed to load bookings';
        _showToast(error, backgroundColor: Colors.red);
      }
    } catch (e) {
      final errorMessage =
          e.toString().contains('Failed host lookup')
              ? 'Network error: Please check your internet connection.'
              : 'Error fetching bookings: $e';
      _showToast(errorMessage, backgroundColor: Colors.red);
    }
  }

  // Create a new booking
  Future<void> createBooking() async {
    if (!_formKey.currentState!.validate()) {
      _showToast(
        'Please fill all required fields',
        backgroundColor: Colors.orange,
      );
      return;
    }

    // Combine date and time into ISO 8601 format
    final startDateTime =
        DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
          _startTime!.hour,
          _startTime!.minute,
        ).toUtc();
    final endDateTime =
        DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          _endTime!.hour,
          _endTime!.minute,
        ).toUtc();

    final newBooking = {
      'userId': _userIdController.text,
      'title': _titleController.text,
      'description': _descriptionController.text,
      'startTime': startDateTime.toIso8601String(),
      'endTime': endDateTime.toIso8601String(),
    };

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://calendar-booking-app-backend.onrender.com/bookings',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(newBooking),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your network connection.',
              );
            },
          );

      if (response.statusCode == 201) {
        _showToast(
          'Booking created successfully!',
          backgroundColor: Colors.green,
        );
        await fetchBookings(); // Refresh the list
        Navigator.of(context).pop(); // Close the dialog
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Failed to create booking';
        _showToast(error, backgroundColor: Colors.red);
      }
    } catch (e) {
      final errorMessage =
          e.toString().contains('Failed host lookup')
              ? 'Network error: Please check your internet connection.'
              : 'Error creating booking: $e';
      _showToast(errorMessage, backgroundColor: Colors.red);
    }
  }

  // Update an existing booking
  Future<void> updateBooking(int bookingId) async {
    if (!_formKey.currentState!.validate()) {
      _showToast(
        'Please fill all required fields',
        backgroundColor: Colors.orange,
      );
      return;
    }

    // Combine date and time into ISO 8601 format
    final startDateTime =
        DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
          _startTime!.hour,
          _startTime!.minute,
        ).toUtc();
    final endDateTime =
        DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          _endTime!.hour,
          _endTime!.minute,
        ).toUtc();

    final updatedBooking = {
      'userId': _userIdController.text,
      'title': _titleController.text,
      'description': _descriptionController.text,
      'startTime': startDateTime.toIso8601String(),
      'endTime': endDateTime.toIso8601String(),
    };

    try {
      final response = await http
          .put(
            Uri.parse(
              'https://calendar-booking-app-backend.onrender.com/bookings/$bookingId',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updatedBooking),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your network connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        _showToast(
          'Booking updated successfully!',
          backgroundColor: Colors.green,
        );
        await fetchBookings(); // Refresh the list
        Navigator.of(context).pop(); // Close the update dialog
        Navigator.of(context).pop(); // Close the meetings dialog
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Failed to update booking';
        _showToast(error, backgroundColor: Colors.red);
      }
    } catch (e) {
      final errorMessage =
          e.toString().contains('Failed host lookup')
              ? 'Network error: Please check your internet connection.'
              : 'Error updating booking: $e';
      _showToast(errorMessage, backgroundColor: Colors.red);
    }
  }

  // Delete a booking
  Future<void> deleteBooking(int bookingId) async {
    try {
      final response = await http
          .delete(
            Uri.parse(
              'https://calendar-booking-app-backend.onrender.com/bookings/$bookingId',
            ),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your network connection.',
              );
            },
          );

      if (response.statusCode == 204) {
        _showToast(
          'Booking deleted successfully!',
          backgroundColor: Colors.green,
        );
        await fetchBookings(); // Refresh the list
        Navigator.of(context).pop(); // Close the meetings dialog
      } else {
        final error =
            jsonDecode(response.body)['error'] ?? 'Failed to delete booking';
        _showToast(error, backgroundColor: Colors.red);
      }
    } catch (e) {
      final errorMessage =
          e.toString().contains('Failed host lookup')
              ? 'Network error: Please check your internet connection.'
              : 'Error deleting booking: $e';
      _showToast(errorMessage, backgroundColor: Colors.red);
    }
  }

  // Show dialog to create a new booking
  void _showNewBookingDialog() {
    _userIdController.clear();
    _titleController.clear();
    _descriptionController.clear();
    // Reset date and time to default values
    setState(() {
      _startDate = DateTime(2025, 5, 14);
      _startTime = const TimeOfDay(hour: 0, minute: 0);
      _endDate = DateTime(2025, 5, 14);
      _endTime = const TimeOfDay(hour: 1, minute: 0);
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create New Booking'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User ID
                      const Text(
                        'User ID',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      TextFormField(
                        controller: _userIdController,
                        decoration: const InputDecoration(
                          hintText: 'Enter user ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a User ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Title
                      const Text(
                        'Title',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Meeting title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description
                      const Text(
                        'Description (Optional)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Enter booking details',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // Start Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: _startDate!,
                                      firstDate: DateTime(2025),
                                      lastDate: DateTime(2026),
                                    );
                                    if (selectedDate != null) {
                                      setDialogState(() {
                                        _startDate = selectedDate;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'dd-MM-yyyy',
                                          ).format(_startDate!),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: _startTime!,
                                    );
                                    if (selectedTime != null) {
                                      setDialogState(() {
                                        _startTime = selectedTime;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _startTime!.format(context),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Icon(Icons.access_time, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // End Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: _endDate!,
                                      firstDate: DateTime(2025),
                                      lastDate: DateTime(2026),
                                    );
                                    if (selectedDate != null) {
                                      setDialogState(() {
                                        _endDate = selectedDate;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'dd-MM-yyyy',
                                          ).format(_endDate!),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'End Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: _endTime!,
                                    );
                                    if (selectedTime != null) {
                                      setDialogState(() {
                                        _endTime = selectedTime;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _endTime!.format(context),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Icon(Icons.access_time, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: createBooking,
                  child: const Text('Create Booking'),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        );
      },
    );
  }

  // Show dialog to update an existing booking
  void _showUpdateBookingDialog(Map<String, dynamic> booking) {
    _userIdController.text = booking['userId'];
    _titleController.text = booking['title'];
    _descriptionController.text = booking['description'];

    final startDateTime = DateTime.parse(booking['startTime']).toLocal();
    final endDateTime = DateTime.parse(booking['endTime']).toLocal();

    setState(() {
      _startDate = startDateTime;
      _startTime = TimeOfDay(
        hour: startDateTime.hour,
        minute: startDateTime.minute,
      );
      _endDate = endDateTime;
      _endTime = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Update Booking'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User ID
                      const Text(
                        'User ID',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      TextFormField(
                        controller: _userIdController,
                        decoration: const InputDecoration(
                          hintText: 'Enter user ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a User ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Title
                      const Text(
                        'Title',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Meeting title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description
                      const Text(
                        'Description (Optional)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Enter booking details',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // Start Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: _startDate!,
                                      firstDate: DateTime(2025),
                                      lastDate: DateTime(2026),
                                    );
                                    if (selectedDate != null) {
                                      setDialogState(() {
                                        _startDate = selectedDate;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'dd-MM-yyyy',
                                          ).format(_startDate!),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: _startTime!,
                                    );
                                    if (selectedTime != null) {
                                      setDialogState(() {
                                        _startTime = selectedTime;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _startTime!.format(context),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Icon(Icons.access_time, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // End Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: _endDate!,
                                      firstDate: DateTime(2025),
                                      lastDate: DateTime(2026),
                                    );
                                    if (selectedDate != null) {
                                      setDialogState(() {
                                        _endDate = selectedDate;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'dd-MM-yyyy',
                                          ).format(_endDate!),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'End Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: _endTime!,
                                    );
                                    if (selectedTime != null) {
                                      setDialogState(() {
                                        _endTime = selectedTime;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _endTime!.format(context),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Icon(Icons.access_time, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => updateBooking(booking['id']),
                  child: const Text('Update Booking'),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        );
      },
    );
  }

  // Show dialog with all meetings for the selected date
  void _showMeetingsDialog(DateTime selectedDay) {
    final eventsForDay = _events[selectedDay] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Meetings on ${DateFormat('MMMM d, yyyy').format(selectedDay)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // Fixed height to prevent overflow
            child:
                eventsForDay.isNotEmpty
                    ? ListView.builder(
                      itemCount: eventsForDay.length,
                      itemBuilder: (context, index) {
                        final event = eventsForDay[index];
                        final startTime =
                            DateTime.parse(event['startTime']).toLocal();
                        final endTime =
                            DateTime.parse(event['endTime']).toLocal();
                        final formattedStartTime = DateFormat(
                          'hh:mm a',
                        ).format(startTime);
                        final formattedEndTime = DateFormat(
                          'hh:mm a',
                        ).format(endTime);
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.event,
                              color: Colors.blue,
                            ),
                            title: Text(
                              event['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Time: $formattedStartTime - $formattedEndTime\n'
                              'User: ${event['userId']}\n'
                              'Booking ID: ${event['id']}\n'
                              '${event['description'].isNotEmpty ? 'Description: ${event['description']}' : ''}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Close the meetings dialog
                                    _showUpdateBookingDialog(event);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    deleteBooking(event['id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    : const Center(child: Text('No meetings on this day')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar Booking System',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Month', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Week', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Day', style: TextStyle(color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: _showNewBookingDialog,
              child: const Text('New Booking'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month - 1,
                        1,
                      );
                    });
                  },
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(2025, 5, 14);
                      _selectedDay = _focusedDay;
                    });
                  },
                  child: const Text(
                    'today',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                        1,
                      );
                    });
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TableCalendar(
              firstDay: DateTime(2025, 1, 1),
              lastDay: DateTime(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                // Show dialog with meetings for the selected day
                final eventDate = DateTime(
                  selectedDay.year,
                  selectedDay.month,
                  selectedDay.day,
                );
                _showMeetingsDialog(eventDate);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.yellow[100],
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: (day) {
                final eventDate = DateTime(day.year, day.month, day.day);
                return _events[eventDate] ?? [];
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class EventData {
  final String date;
  final String data_exist;
  final Color color;

  EventData({
    required this.date,
    required this.data_exist,
    required this.color,
  });
}

class ActivityData {
  final String lName;
  final String sName;
  final String? practice;
  final String? levels;
  final String? sections;
  final String? questions;
  final String? correctAnswers;
  final String? timeTaken;
  final String? averageTimeTaken;
  final String? accuracy;

  ActivityData({
    required this.lName,
    required this.sName,
    this.practice,
    this.levels,
    this.sections,
    this.questions,
    this.correctAnswers,
    this.timeTaken,
    this.averageTimeTaken,
    this.accuracy,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      lName: json['l_name'],
      sName: json['s_name'],
      practice: json['Activity'] ?? 'N/A',
      levels: json['levels'] ?? json['l_name'],
      sections: json['sections'] ?? json['s_name'],
      questions: json['questions'],
      correctAnswers: json['correct_answers'],
      timeTaken: json['time_taken'],
      averageTimeTaken: json['average_time_taken'],
      accuracy: json['accuracy'],
    );
  }
}

class TableBasicsExample extends StatefulWidget {
  final String token;

  TableBasicsExample({required this.token});

  @override
  _TableBasicsExampleState createState() => _TableBasicsExampleState();
}

class _TableBasicsExampleState extends State<TableBasicsExample> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _selectedDate;
  Map<DateTime, List<EventData>> _eventsMap = {};
  List<ActivityData> _selectedDayActivityData = [];
  List<String> trueDates = [];
  List<String>? fetchedTrueDates;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final apiURL = "https://bob-fms.trainingzone.in/api/user/stats-calendar";
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    try {
      final response = await http.get(
        Uri.parse(apiURL),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'];

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final List<Map<String, dynamic>> dataList =
              (data['data'] as List).cast<Map<String, dynamic>>();

          final List<String> fetchedTrueDates = dataList
              .where((dateData) => dateData['data_exist'] == true)
              .map<String>((dateData) => dateData['date'].toString())
              .toList();

          print('Dates with data_exist 1: true: $fetchedTrueDates');

          setState(() {
            trueDates = fetchedTrueDates;
            print('Dates with data_exist 2:  $trueDates');
          });
        } else {
          throw Exception('Unexpected data structure: $data');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  List<EventData> _getEventsFromApiResponse(dynamic jsonData) {
    return (jsonData['data'] as List).map((eventData) {
      final String date = eventData['date'];
      final bool dataExist = eventData['data_exist'];
      final Color eventColor =
          dataExist ? Colors.green : Colors.transparent;

      return EventData(
        date: date,
        data_exist: dataExist.toString(),
        color: eventColor,
      );
    }).toList();
  }

  Map<DateTime, List<EventData>> _buildEventsMap(List<EventData> events) {
    final Map<DateTime, List<EventData>> eventsMap = {};

    for (var event in events) {
      final DateTime dateTime = DateTime.parse(event.date);

      if (eventsMap.containsKey(dateTime)) {
        eventsMap[dateTime]!.add(event);
      } else {
        eventsMap[dateTime] = [event];
      }
    }

    return eventsMap;
  }

  Future<void> fetchActivityData(DateTime selectedDate) async {
    final apiURL = "https://bob-fms.trainingzone.in/api/user/stats-day";
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    var body = jsonEncode({
      'date': selectedDate.toIso8601String(),
    });

    try {
      final response = await http.post(
        Uri.parse(apiURL),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'];

        print('Data for $selectedDate: $data');

        setState(() {
          _selectedDayActivityData =
              _getActivityDataFromApiResponse(jsonData);
          _selectedDate = selectedDate; // Set the selected date
        });
      } else {
        throw Exception('Failed to load data for $selectedDate');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  List<ActivityData> _getActivityDataFromApiResponse(
      Map<String, dynamic> data) {
    List<ActivityData> activities = [];

    if (data.containsKey('data')) {
      var activityDataList = data['data'] as List;

      for (var activityData in activityDataList) {
        activities.add(ActivityData.fromJson(activityData));
      }
    }

    return activities;
  }

  Widget _buildActivityContainer(ActivityData activity) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Date: ${_selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : 'N/A'}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                'Activity: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Practice'),
            ],
          ),
          Row(
            children: [
              Text(
                'Level: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${activity.levels ?? 'N/A'}'),
            ],
          ),
          Row(
            children: [
              Text(
                'Section: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${activity.sections ?? 'N/A'}'),
            ],
          ),
          Row(
            children: [
              Text(
                'Questions: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${activity.questions }'),
            ],
          ),
          Row(
            children: [
              Text(
                'Correct Answers: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${activity.correctAnswers }'),
            ],
          ),
          Row(
            children: [
              Text(
                'Time Taken: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${activity.timeTaken }'),
            ],
          ),
          Row(
            children: [
              Text(
                'Average Time Taken: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${activity.averageTimeTaken }'),
            ],
          ),
          Row(
            children: [
              Text(
                'Accuracy: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${activity.accuracy }'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 20),
            color: const Color.fromARGB(255, 8, 78, 135),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) async {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  await fetchActivityData(selectedDay);
                }
              },
              eventLoader: (day) {
                return _eventsMap[day] ?? [];
              },
              calendarStyle: CalendarStyle(
                markersMaxCount: 1,
                outsideDaysVisible: false,
                defaultTextStyle: TextStyle(color: Colors.black),
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                leftChevronIcon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                rightChevronIcon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white),
                weekendStyle: TextStyle(color: Colors.white),
              ),
              calendarBuilders: CalendarBuilders(
                todayBuilder: (context, date, events) {
                  final bool isTrueDate =
                      _eventsMap[date]?.first.color == Colors.green;

                  // Check if the date is the current day
                  final bool isCurrentDay = isSameDay(date, DateTime.now());

                  print('Today - Date: $date, IsTrueDate: $isTrueDate');

                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                          color: isTrueDate
                              ? Colors.green
                              : (isCurrentDay ? Colors.blue : Colors.white),
                        ),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isTrueDate || isCurrentDay
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                defaultBuilder: (context, date, _) {
                  final formattedDate =
                      DateFormat('yyyy-MM-dd').format(date);

                  final bool isTrueDate =
                      trueDates.contains(formattedDate);

                  // Check if the date is the current day
                  final bool isCurrentDay = isSameDay(date, DateTime.now());

                  return GestureDetector(
                    onTap: () async {
                      if (!isSameDay(_selectedDay, date)) {
                        setState(() {
                          _selectedDay = date;
                          _focusedDay = date;
                        });

                        await fetchActivityData(date);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                        color: isTrueDate
                            ? Colors.green
                            : (isCurrentDay ? Colors.blue : Colors.white),
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isTrueDate || isCurrentDay
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_selectedDayActivityData.isNotEmpty)
                    Column(
                      children: _selectedDayActivityData
                          .map((activity) =>
                              _buildActivityContainer(activity))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: TableBasicsExample(token: ''),
      ),
    ),
  );
}

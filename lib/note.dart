import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Screen4 extends StatefulWidget {
  @override
  Screen4State createState() => Screen4State();
}

class Screen4State extends State<Screen4> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DateTime _selectedDate = DateTime.now();
  bool _isToday = false;

  @override
  void initState() {
    super.initState();
    _checkIfToday();
  }

  void _checkIfToday() {
    final now = DateTime.now();
    setState(() {
      _isToday = _selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _checkIfToday(); // Check if the selected date is today after updating it
      });
    }
  }

  void _addNote() async {
    if (_controller.text.isNotEmpty) {
      await _firestore.collection('daily_notes').add({
        'note': _controller.text,
        'timestamp': _selectedDate, // Save the note with the selected date
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Notes'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: const Text('Check Notes'),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('daily_notes')
                  .where('timestamp', isGreaterThanOrEqualTo: _selectedDate)
                  .where('timestamp', isLessThan: _selectedDate.add(const Duration(days: 1)))
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final notes = snapshot.data!.docs.map((doc) => doc['note'] as String).toList();
                return Column(
                  children: [
                    if (_isToday) // Only show the text field if the selected date is today
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your note...',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addNote,
                            ),
                          ],
                        ),
                      ),
                    if (notes.isEmpty) // Show a message if there are no notes for the selected date
                      const Center(
                        child: Text('No notes for selected date.'),
                      ),
                    for (final note in notes)
                      ListTile(
                        title: Text(note),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

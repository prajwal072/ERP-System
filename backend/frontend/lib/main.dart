import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color primaryColor = Color(0xFF1976D2);
const Color accentColor = Color(0xFF64B5F6);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College ERP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor, brightness: Brightness.light),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 4,
            shadowColor: accentColor.withOpacity(0.3),
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'userId': _idController.text,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => DashboardScreen(role: data['role'])),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error = data['message'] ?? 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo placeholder
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [primaryColor, accentColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.school,
                            size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text('College ERP',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontFamily: 'Roboto')),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: 'ID',
                          prefixIcon: Icon(Icons.badge),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter ID' : null,
                      ),
                      const SizedBox(height: 24),
                      if (_error != null)
                        Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            elevation: _loading ? 0 : 6,
                            shadowColor: accentColor.withOpacity(0.4),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Login'),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()),
                          );
                        },
                        child: const Text('Don\'t have an account? Sign Up'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  String _role = 'student';
  bool _loading = false;
  String? _error;
  String? _success;

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'userId': _idController.text,
          'role': _role,
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          _success = 'Sign up successful! Please log in.';
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error = data['message'] ?? 'Sign up failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo placeholder
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [primaryColor, accentColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.person_add,
                            size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text('Sign Up',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontFamily: 'Roboto')),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: 'ID',
                          prefixIcon: Icon(Icons.badge),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter ID' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _role,
                        items: const [
                          DropdownMenuItem(
                              value: 'student', child: Text('Student')),
                          DropdownMenuItem(
                              value: 'faculty', child: Text('Faculty')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _role = value!;
                          });
                        },
                        decoration: const InputDecoration(
                            labelText: 'Role', prefixIcon: Icon(Icons.school)),
                      ),
                      const SizedBox(height: 24),
                      if (_error != null)
                        Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      if (_success != null)
                        Text(_success!,
                            style: const TextStyle(color: Colors.green)),
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            elevation: _loading ? 0 : 6,
                            shadowColor: accentColor.withOpacity(0.4),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Sign Up'),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final String role;
  const DashboardScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dashboard ($role)'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome to the $role dashboard!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontFamily: 'Roboto')),
              const SizedBox(height: 32),
              // Horizontal scrollable cards layout
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _DashboardCard(
                      icon: Icons.check_circle_outline,
                      label: 'Attendance',
                      color: Colors.green,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AttendanceScreen(
                                  role: role, userId: 'YOUR_USER_ID_HERE'))),
                    ),
                    const SizedBox(width: 16),
                    _DashboardCard(
                      icon: Icons.attach_money,
                      label: 'Fees',
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FeesScreen())),
                    ),
                    const SizedBox(width: 16),
                    _DashboardCard(
                      icon: Icons.assignment,
                      label: 'Examination',
                      color: Colors.purple,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ExaminationScreen())),
                    ),
                    const SizedBox(width: 16),
                    _DashboardCard(
                      icon: Icons.assignment_turned_in,
                      label: 'Assignments',
                      color: Colors.teal,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AssignmentScreen(
                                  role: role, userId: 'YOUR_USER_ID_HERE'))),
                    ),
                    const SizedBox(width: 16),
                    _DashboardCard(
                      icon: Icons.people,
                      label: 'Students',
                      color: Colors.indigo,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StudentManagementScreen(
                                  role: role, userId: 'YOUR_USER_ID_HERE'))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _DashboardCard(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Card(
            elevation: _hovering ? 12 : 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            color: widget.color.withOpacity(_hovering ? 0.25 : 0.15),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 40, color: widget.color),
                  const SizedBox(height: 12),
                  Flexible(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AttendanceScreen extends StatefulWidget {
  final String role;
  final String userId;
  const AttendanceScreen({Key? key, required this.role, required this.userId})
      : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _status = 'present';
  String? _message;
  bool _loading = false;

  final List<Map<String, dynamic>> subjects = const [
    {'name': 'Mathematics', 'attendance': '92%'},
    {'name': 'Physics', 'attendance': '88%'},
    {'name': 'Chemistry', 'attendance': '95%'},
    {'name': 'English', 'attendance': '90%'},
    {'name': 'Computer Science', 'attendance': '98%'},
  ];

  Future<void> _submitAttendance() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/attendance/'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': widget.userId,
        },
        body: jsonEncode({
          'student': _studentIdController.text,
          'subject': _subjectController.text,
          'date': _selectedDate.toIso8601String(),
          'status': _status,
          'marks': int.tryParse(_marksController.text) ?? 0,
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          _message = 'Attendance marked successfully!';
        });
      } else {
        setState(() {
          _message =
              'Error: ' + jsonDecode(response.body)['message'].toString();
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Network error';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  void _showAttendanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Attendance'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(labelText: 'Student ID'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter student ID' : null,
                ),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter subject' : null,
                ),
                TextFormField(
                  controller: _marksController,
                  decoration: const InputDecoration(labelText: 'Marks'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'present', child: Text('Present')),
                    DropdownMenuItem(value: 'absent', child: Text('Absent')),
                  ],
                  onChanged: (v) => setState(() {
                    _status = v!;
                  }),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                Row(
                  children: [
                    const Text('Date: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() {
                            _selectedDate = picked;
                          });
                      },
                      child: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                    ),
                  ],
                ),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Text(_message!,
                      style: TextStyle(
                          color: _message!.contains('success')
                              ? Colors.green
                              : Colors.red)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: _loading ? null : _submitAttendance,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Submit')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                widget.role == 'faculty'
                    ? 'Faculty Attendance Panel'
                    : 'Your Attendance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                    fontFamily: 'Roboto')),
            const SizedBox(height: 24),
            if (widget.role == 'faculty')
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Mark Attendance'),
                onPressed: _showAttendanceDialog,
              ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: subjects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading:
                          Icon(Icons.book, color: Colors.green[700], size: 36),
                      title: Text(subject['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(subject['attendance'],
                            style: TextStyle(
                                color: Colors.green[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeesScreen extends StatefulWidget {
  @override
  _FeesScreenState createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  final List<String> castes = ['Open', 'OBC', 'EWS', 'ST', 'SC', 'NT'];
  String selectedCaste = 'Open';
  List<dynamic> fees = [];
  bool loading = false;
  String? error;

  // TODO: Replace with actual logged-in student ID
  final String studentId = 'YOUR_STUDENT_ID_HERE';

  @override
  void initState() {
    super.initState();
    fetchFees();
  }

  Future<void> fetchFees() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:5000/api/fees/student/$studentId?caste=$selectedCaste'));
      if (response.statusCode == 200) {
        setState(() {
          fees = jsonDecode(response.body);
        });
      } else {
        setState(() {
          error = 'Failed to fetch fees';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Fees'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Caste:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedCaste,
              items: castes
                  .map((caste) => DropdownMenuItem(
                        value: caste,
                        child: Text(caste),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCaste = value!;
                });
                fetchFees();
              },
            ),
            const SizedBox(height: 24),
            if (loading) const Center(child: CircularProgressIndicator()),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (!loading && error == null)
              Expanded(
                child: fees.isEmpty
                    ? const Center(child: Text('No fees found.'))
                    : ListView.separated(
                        itemCount: fees.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final fee = fees[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              leading: Icon(Icons.attach_money,
                                  color: Colors.orange, size: 36),
                              title:
                                  Text('Semester: ${fee['semester'] ?? '-'}'),
                              subtitle: Text('Status: ${fee['status'] ?? '-'}'),
                              trailing: Text('₹${fee['amount'] ?? '-'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class ExaminationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> subjects = const [
    {'name': 'Mathematics', 'status': 'Passed', 'score': 92},
    {'name': 'Physics', 'status': 'Passed', 'score': 88},
    {'name': 'Chemistry', 'status': 'Passed', 'score': 95},
    {'name': 'English', 'status': 'Passed', 'score': 90},
    {'name': 'Computer Science', 'status': 'Passed', 'score': 98},
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Passed':
        return Colors.purple[700]!;
      case 'Failed':
        return Colors.red[700]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Examination'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Exam Results',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                    fontFamily: 'Roboto')),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: subjects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Icon(Icons.assignment,
                          color: Colors.purple[700], size: 36),
                      title: Text(subject['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('Score: ${subject['score']}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        decoration: BoxDecoration(
                          color:
                              _statusColor(subject['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(subject['status'],
                            style: TextStyle(
                                color: _statusColor(subject['status']),
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignmentScreen extends StatefulWidget {
  final String role;
  final String userId;
  const AssignmentScreen({Key? key, required this.role, required this.userId})
      : super(key: key);

  @override
  _AssignmentScreenState createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String? _message;
  bool _loading = false;
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/assignments/'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          assignments = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      // Handle error silently for demo
    }
  }

  Future<void> _createAssignment() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/assignments/'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': widget.userId,
        },
        body: jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'subject': _subjectController.text,
          'dueDate': _selectedDate.toIso8601String(),
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          _message = 'Assignment created successfully!';
          _titleController.clear();
          _descriptionController.clear();
          _subjectController.clear();
        });
        _loadAssignments();
      } else {
        setState(() {
          _message =
              'Error: ' + jsonDecode(response.body)['message'].toString();
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Network error';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  void _showCreateAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Assignment'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter title' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter subject' : null,
                ),
                Row(
                  children: [
                    const Text('Due Date: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() {
                            _selectedDate = picked;
                          });
                      },
                      child: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                    ),
                  ],
                ),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Text(_message!,
                      style: TextStyle(
                          color: _message!.contains('success')
                              ? Colors.green
                              : Colors.red)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: _loading ? null : _createAssignment,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Create')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                widget.role == 'faculty'
                    ? 'Faculty Assignment Panel'
                    : 'Your Assignments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                    fontFamily: 'Roboto')),
            const SizedBox(height: 24),
            if (widget.role == 'faculty')
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Assignment'),
                onPressed: _showCreateAssignmentDialog,
              ),
            const SizedBox(height: 16),
            Expanded(
              child: assignments.isEmpty
                  ? const Center(
                      child: Text('No assignments available',
                          style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.separated(
                      itemCount: assignments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final assignment = assignments[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: Icon(Icons.assignment_turned_in,
                                color: Colors.teal[700], size: 36),
                            title: Text(assignment['title'] ?? 'Untitled',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(assignment['description'] ?? ''),
                                Text('Subject: ${assignment['subject'] ?? ''}'),
                                Text('Due: ${assignment['dueDate'] ?? ''}'),
                              ],
                            ),
                            trailing: widget.role == 'student'
                                ? ElevatedButton(
                                    onPressed: () {
                                      // Handle assignment submission
                                    },
                                    child: const Text('Submit'))
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentManagementScreen extends StatefulWidget {
  final String role;
  final String userId;
  const StudentManagementScreen(
      {Key? key, required this.role, required this.userId})
      : super(key: key);

  @override
  _StudentManagementScreenState createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  // Form controllers for student creation/editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();

  // Address controllers
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // Parent controllers
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _fatherPhoneController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _motherPhoneController = TextEditingController();

  // Emergency contact controllers
  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _emergencyRelationshipController =
      TextEditingController();

  // Form state variables
  DateTime _selectedDateOfBirth =
      DateTime.now().subtract(const Duration(days: 6570)); // 18 years ago
  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'A+';
  String _selectedCategory = 'General';
  String _selectedStatus = 'Active';

  // Data state
  List<Map<String, dynamic>> students = [];
  Map<String, dynamic>? selectedStudent;
  bool _loading = false;
  String? _message;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalStudents = 0;

  // Filter state
  String _selectedDepartment = '';
  String _selectedSemester = '';
  String _selectedStatusFilter = '';
  String _selectedCategoryFilter = '';

  final List<String> departments = [
    'Computer Science',
    'Information Technology',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
    'Chemical Engineering',
    'Biotechnology'
  ];

  final List<String> courses = [
    'B.Tech',
    'M.Tech',
    'B.Sc',
    'M.Sc',
    'BBA',
    'MBA',
    'BCA',
    'MCA'
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _loading = true;
    });

    try {
      String url =
          'http://localhost:3000/api/students/?page=$_currentPage&limit=10';

      // Add filters
      if (_searchController.text.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(_searchController.text)}';
      }
      if (_selectedDepartment.isNotEmpty) {
        url += '&department=${Uri.encodeComponent(_selectedDepartment)}';
      }
      if (_selectedSemester.isNotEmpty) {
        url += '&semester=$_selectedSemester';
      }
      if (_selectedStatusFilter.isNotEmpty) {
        url += '&status=${Uri.encodeComponent(_selectedStatusFilter)}';
      }
      if (_selectedCategoryFilter.isNotEmpty) {
        url += '&category=${Uri.encodeComponent(_selectedCategoryFilter)}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          students = List<Map<String, dynamic>>.from(data['students']);
          _totalPages = data['pagination']['totalPages'];
          _totalStudents = data['pagination']['totalStudents'];
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error loading students: $e';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  void _showAddStudentDialog() {
    _clearForm();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Student'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 16),
                _buildAcademicInfoSection(),
                const SizedBox(height: 16),
                _buildAddressSection(),
                const SizedBox(height: 16),
                _buildParentInfoSection(),
                const SizedBox(height: 16),
                _buildEmergencyContactSection(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _loading ? null : _createStudent,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Add Student'),
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(Map<String, dynamic> student) {
    selectedStudent = student;
    _populateForm(student);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 16),
                _buildAcademicInfoSection(),
                const SizedBox(height: 16),
                _buildAddressSection(),
                const SizedBox(height: 16),
                _buildParentInfoSection(),
                const SizedBox(height: 16),
                _buildEmergencyContactSection(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _loading ? null : _updateStudent,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Update Student'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Basic Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name *'),
          validator: (value) =>
              value?.isEmpty == true ? 'Name is required' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _rollNumberController,
          decoration: const InputDecoration(labelText: 'Roll Number *'),
          validator: (value) =>
              value?.isEmpty == true ? 'Roll number is required' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email *'),
          validator: (value) =>
              value?.isEmpty == true ? 'Email is required' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Phone *'),
          validator: (value) =>
              value?.isEmpty == true ? 'Phone is required' : null,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender *'),
                items: ['Male', 'Female', 'Other'].map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'Blood Group'),
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((bg) {
                  return DropdownMenuItem(value: bg, child: Text(bg));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedBloodGroup = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Date of Birth: '),
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateOfBirth,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDateOfBirth = picked);
                }
              },
              child: Text('${_selectedDateOfBirth.toLocal()}'.split(' ')[0]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(labelText: 'Category'),
          items: ['General', 'OBC', 'SC', 'ST', 'EWS', 'Other'].map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value!),
        ),
      ],
    );
  }

  Widget _buildAcademicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Academic Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _departmentController.text.isEmpty
              ? null
              : _departmentController.text,
          decoration: const InputDecoration(labelText: 'Department *'),
          items: departments.map((dept) {
            return DropdownMenuItem(value: dept, child: Text(dept));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _departmentController.text = value ?? '';
            });
          },
          validator: (value) =>
              value?.isEmpty == true ? 'Department is required' : null,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _courseController.text.isEmpty ? null : _courseController.text,
          decoration: const InputDecoration(labelText: 'Course *'),
          items: courses.map((course) {
            return DropdownMenuItem(value: course, child: Text(course));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _courseController.text = value ?? '';
            });
          },
          validator: (value) =>
              value?.isEmpty == true ? 'Course is required' : null,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _semesterController,
                decoration: const InputDecoration(labelText: 'Semester *'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty == true ? 'Semester is required' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _academicYearController,
                decoration: const InputDecoration(labelText: 'Academic Year *'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Academic year is required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          decoration: const InputDecoration(labelText: 'Status'),
          items: ['Active', 'Inactive', 'Graduated', 'Suspended'].map((status) {
            return DropdownMenuItem(value: status, child: Text(status));
          }).toList(),
          onChanged: (value) => setState(() => _selectedStatus = value!),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Address',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _streetController,
          decoration: const InputDecoration(labelText: 'Street Address'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pincodeController,
          decoration: const InputDecoration(labelText: 'Pincode'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildParentInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Parent Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fatherNameController,
                decoration: const InputDecoration(labelText: 'Father\'s Name'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _fatherPhoneController,
                decoration: const InputDecoration(labelText: 'Father\'s Phone'),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _motherNameController,
                decoration: const InputDecoration(labelText: 'Mother\'s Name'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _motherPhoneController,
                decoration: const InputDecoration(labelText: 'Mother\'s Phone'),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Emergency Contact',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _emergencyNameController,
                decoration:
                    const InputDecoration(labelText: 'Emergency Contact Name'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _emergencyRelationshipController,
                decoration: const InputDecoration(labelText: 'Relationship'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emergencyPhoneController,
          decoration:
              const InputDecoration(labelText: 'Emergency Contact Phone'),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  void _clearForm() {
    _nameController.clear();
    _rollNumberController.clear();
    _emailController.clear();
    _phoneController.clear();
    _departmentController.clear();
    _courseController.clear();
    _semesterController.clear();
    _academicYearController.clear();
    _streetController.clear();
    _cityController.clear();
    _stateController.clear();
    _pincodeController.clear();
    _fatherNameController.clear();
    _fatherPhoneController.clear();
    _motherNameController.clear();
    _motherPhoneController.clear();
    _emergencyNameController.clear();
    _emergencyPhoneController.clear();
    _emergencyRelationshipController.clear();

    setState(() {
      _selectedDateOfBirth =
          DateTime.now().subtract(const Duration(days: 6570));
      _selectedGender = 'Male';
      _selectedBloodGroup = 'A+';
      _selectedCategory = 'General';
      _selectedStatus = 'Active';
      selectedStudent = null;
    });
  }

  void _populateForm(Map<String, dynamic> student) {
    _nameController.text = student['name'] ?? '';
    _rollNumberController.text = student['rollNumber'] ?? '';
    _emailController.text = student['email'] ?? '';
    _phoneController.text = student['phone'] ?? '';
    _departmentController.text = student['department'] ?? '';
    _courseController.text = student['course'] ?? '';
    _semesterController.text = student['semester']?.toString() ?? '';
    _academicYearController.text = student['academicYear'] ?? '';

    // Address
    if (student['address'] != null) {
      _streetController.text = student['address']['street'] ?? '';
      _cityController.text = student['address']['city'] ?? '';
      _stateController.text = student['address']['state'] ?? '';
      _pincodeController.text = student['address']['pincode'] ?? '';
    }

    // Parent info
    if (student['parent'] != null) {
      _fatherNameController.text = student['parent']['fatherName'] ?? '';
      _fatherPhoneController.text = student['parent']['fatherPhone'] ?? '';
      _motherNameController.text = student['parent']['motherName'] ?? '';
      _motherPhoneController.text = student['parent']['motherPhone'] ?? '';
    }

    // Emergency contact
    if (student['emergencyContact'] != null) {
      _emergencyNameController.text = student['emergencyContact']['name'] ?? '';
      _emergencyPhoneController.text =
          student['emergencyContact']['phone'] ?? '';
      _emergencyRelationshipController.text =
          student['emergencyContact']['relationship'] ?? '';
    }

    setState(() {
      _selectedDateOfBirth = student['dateOfBirth'] != null
          ? DateTime.parse(student['dateOfBirth'])
          : DateTime.now().subtract(const Duration(days: 6570));
      _selectedGender = student['gender'] ?? 'Male';
      _selectedBloodGroup = student['bloodGroup'] ?? 'A+';
      _selectedCategory = student['category'] ?? 'General';
      _selectedStatus = student['status'] ?? 'Active';
    });
  }

  Future<void> _createStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final studentData = {
        'name': _nameController.text,
        'rollNumber': _rollNumberController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'dateOfBirth': _selectedDateOfBirth.toIso8601String(),
        'gender': _selectedGender,
        'bloodGroup': _selectedBloodGroup,
        'department': _departmentController.text,
        'course': _courseController.text,
        'semester': int.tryParse(_semesterController.text) ?? 1,
        'academicYear': _academicYearController.text,
        'category': _selectedCategory,
        'status': _selectedStatus,
        'address': {
          'street': _streetController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'pincode': _pincodeController.text,
        },
        'parent': {
          'fatherName': _fatherNameController.text,
          'fatherPhone': _fatherPhoneController.text,
          'motherName': _motherNameController.text,
          'motherPhone': _motherPhoneController.text,
        },
        'emergencyContact': {
          'name': _emergencyNameController.text,
          'phone': _emergencyPhoneController.text,
          'relationship': _emergencyRelationshipController.text,
        },
      };

      final response = await http.post(
        Uri.parse('http://localhost:3000/api/students/'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': widget.userId,
        },
        body: jsonEncode(studentData),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
        _loadStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully!')),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _message = data['message'] ?? 'Error creating student';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Network error: $e';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate() || selectedStudent == null) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final studentData = {
        'name': _nameController.text,
        'rollNumber': _rollNumberController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'dateOfBirth': _selectedDateOfBirth.toIso8601String(),
        'gender': _selectedGender,
        'bloodGroup': _selectedBloodGroup,
        'department': _departmentController.text,
        'course': _courseController.text,
        'semester': int.tryParse(_semesterController.text) ?? 1,
        'academicYear': _academicYearController.text,
        'category': _selectedCategory,
        'status': _selectedStatus,
        'address': {
          'street': _streetController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'pincode': _pincodeController.text,
        },
        'parent': {
          'fatherName': _fatherNameController.text,
          'fatherPhone': _fatherPhoneController.text,
          'motherName': _motherNameController.text,
          'motherPhone': _motherPhoneController.text,
        },
        'emergencyContact': {
          'name': _emergencyNameController.text,
          'phone': _emergencyPhoneController.text,
          'relationship': _emergencyRelationshipController.text,
        },
      };

      final response = await http.put(
        Uri.parse(
            'http://localhost:3000/api/students/${selectedStudent!['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': widget.userId,
        },
        body: jsonEncode(studentData),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        _loadStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student updated successfully!')),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _message = data['message'] ?? 'Error updating student';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Network error: $e';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _deleteStudent(String studentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text(
            'Are you sure you want to delete this student? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/students/$studentId'),
        headers: {
          'x-auth-token': widget.userId,
        },
      );

      if (response.statusCode == 200) {
        _loadStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted successfully!')),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Error deleting student')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Student Management'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.role == 'faculty' || widget.role == 'admin')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddStudentDialog,
              tooltip: 'Add New Student',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Student Management System',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                    fontFamily: 'Roboto',
                  ),
            ),
            const SizedBox(height: 24),

            // Search and Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _loadStudents(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _loadStudents,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedDepartment.isEmpty
                        ? null
                        : _selectedDepartment,
                    hint: const Text('Department'),
                    items: departments.map((dept) {
                      return DropdownMenuItem(value: dept, child: Text(dept));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value ?? '';
                      });
                      _loadStudents();
                    },
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedSemester.isEmpty ? null : _selectedSemester,
                    hint: const Text('Semester'),
                    items: List.generate(8, (index) => (index + 1).toString())
                        .map((sem) {
                      return DropdownMenuItem(value: sem, child: Text(sem));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSemester = value ?? '';
                      });
                      _loadStudents();
                    },
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedStatusFilter.isEmpty
                        ? null
                        : _selectedStatusFilter,
                    hint: const Text('Status'),
                    items: ['Active', 'Inactive', 'Graduated', 'Suspended']
                        .map((status) {
                      return DropdownMenuItem(
                          value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatusFilter = value ?? '';
                      });
                      _loadStudents();
                    },
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedCategoryFilter.isEmpty
                        ? null
                        : _selectedCategoryFilter,
                    hint: const Text('Category'),
                    items: ['General', 'OBC', 'SC', 'ST', 'EWS', 'Other']
                        .map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryFilter = value ?? '';
                      });
                      _loadStudents();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Total Students', _totalStudents.toString(),
                        Colors.blue),
                    _buildStatCard(
                        'Active',
                        students
                            .where((s) => s['status'] == 'Active')
                            .length
                            .toString(),
                        Colors.green),
                    _buildStatCard(
                        'Graduated',
                        students
                            .where((s) => s['status'] == 'Graduated')
                            .length
                            .toString(),
                        Colors.orange),
                    _buildStatCard(
                        'Inactive',
                        students
                            .where((s) => s['status'] == 'Inactive')
                            .length
                            .toString(),
                        Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Students List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : students.isEmpty
                      ? const Center(
                          child: Text(
                            'No students found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: students.length,
                                itemBuilder: (context, index) {
                                  final student = students[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            _getStatusColor(student['status']),
                                        child: Text(
                                          student['name']
                                                  ?.substring(0, 1)
                                                  .toUpperCase() ??
                                              '?',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      title: Text(
                                        student['name'] ?? 'Unknown',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Roll: ${student['rollNumber']} | ${student['department']}'),
                                          Text(
                                              'Email: ${student['email']} | Phone: ${student['phone']}'),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                      student['status'])
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              student['status'] ?? 'Unknown',
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                    student['status']),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: widget.role == 'faculty' ||
                                              widget.role == 'admin'
                                          ? PopupMenuButton(
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit),
                                                      SizedBox(width: 8),
                                                      Text('Edit'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete,
                                                          color: Colors.red),
                                                      SizedBox(width: 8),
                                                      Text('Delete',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              onSelected: (value) {
                                                if (value == 'edit') {
                                                  _showEditStudentDialog(
                                                      student);
                                                } else if (value == 'delete') {
                                                  _deleteStudent(
                                                      student['_id']);
                                                }
                                              },
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Pagination
                            if (_totalPages > 1)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: _currentPage > 1
                                        ? () {
                                            setState(() {
                                              _currentPage--;
                                            });
                                            _loadStudents();
                                          }
                                        : null,
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                  Text('Page $_currentPage of $_totalPages'),
                                  IconButton(
                                    onPressed: _currentPage < _totalPages
                                        ? () {
                                            setState(() {
                                              _currentPage++;
                                            });
                                            _loadStudents();
                                          }
                                        : null,
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ],
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Graduated':
        return Colors.orange;
      case 'Inactive':
        return Colors.red;
      case 'Suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/bottom_nav.dart';

class ReportEventScreen extends StatefulWidget {
  const ReportEventScreen({Key? key}) : super(key: key);

  @override
  State<ReportEventScreen> createState() => _ReportEventScreenState();
}

class _ReportEventScreenState extends State<ReportEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  final _picker = ImagePicker();

  String? _reason;
  XFile? _screenshot;

  final _reasons = const [
    'Inappropriate Content',
    'Spam or Advertising',
    'Harassment or Abuse',
    'Misleading Information',
    'Other',
  ];

  Future<void> _pickScreenshot() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _screenshot = file);
    }
  }

  void _submit() {
    if ((_reason == null || _reason!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for report')),
      );
      return;
    }

    // TODO: send payload to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted. Thank you.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Event')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Reason for Report',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                value: _reason,
                items: _reasons
                    .map((r) => DropdownMenuItem<String>(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _reason = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Additional Details',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickScreenshot,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.attach_file, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        _screenshot == null ? 'Upload Screenshot' : 'Selected: ${_screenshot!.name}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(selectedIndex: 1),
    );
  }
}
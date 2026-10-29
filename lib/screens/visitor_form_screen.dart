import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management_task/bloc/visitor_bloc.dart';
import 'package:visitor_management_task/bloc/visitor_event.dart';
import 'package:visitor_management_task/bloc/visitor_state.dart';
import 'package:visitor_management_task/models/visitor.dart';

class VisitorFormScreen extends StatefulWidget {
  const VisitorFormScreen({super.key, this.visitor});
  final Visitor? visitor;
  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name, _mobile, _email, _purpose;
  String _type = 'Customer', _project = 'Project A';
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    final v = widget.visitor;
    _name = TextEditingController(text: v?.name ?? '');
    _mobile = TextEditingController(text: v?.mobile ?? '');
    _email = TextEditingController(text: v?.email ?? '');
    _purpose = TextEditingController(text: v?.purpose ?? '');
    _type = v?.visitorType ?? 'Customer';
    _project = v?.project ?? 'Project A';
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _purpose.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required' : null;
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final old = widget.visitor;
    final visitor = Visitor(
      id: old?.id ?? '',
      name: _name.text.trim(),
      mobile: _mobile.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      visitorType: _type,
      project: _project,
      purpose: _purpose.text.trim(),
      status: old?.status ?? 'Registered',
      createdAt: old?.createdAt ?? DateTime.now(),
      checkInTime: old?.checkInTime,
      checkOutTime: old?.checkOutTime,
    );
    final bloc = context.read<VisitorBloc>();
    bloc.add(old == null ? VisitorCreated(visitor) : VisitorUpdated(visitor));
    await bloc.stream.firstWhere(
      (s) =>
          s.status == VisitorStatus.loaded || s.status == VisitorStatus.failure,
    );
    if (!mounted) return;
    final latest = bloc.state;
    setState(() => _saving = false);
    if (latest.status == VisitorStatus.loaded && latest.message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(latest.message!)));
      context.pop();
    } else if (latest.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(latest.message!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.visitor == null ? 'Register visitor' : 'Edit visitor'),
    ),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Visitor information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Visitor name *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) => _required(v, 'Visitor name'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile number *',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Mobile number is required';
                }
                if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                  return 'Enter exactly 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v != null &&
                    v.trim().isNotEmpty &&
                    !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Visitor type *',
                border: OutlineInputBorder(),
              ),
              items: const [
                'Customer',
                'Vendor',
                'Other',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _type = v ?? 'Customer'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _project,
              decoration: const InputDecoration(
                labelText: 'Project *',
                border: OutlineInputBorder(),
              ),
              items: const [
                'Project A',
                'Project B',
                'Project C',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _project = v ?? 'Project A'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _purpose,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Purpose of visit *',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (v) => _required(v, 'Purpose of visit'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save visitor'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            OutlinedButton(
              onPressed: _saving ? null : () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    ),
  );
}

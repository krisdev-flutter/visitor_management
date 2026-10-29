import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management_task/app/theme/app_theme.dart';
import 'package:visitor_management_task/core/widgets/common.dart';
import 'package:visitor_management_task/features/visitors/domain/entities/visitor.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_bloc.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_event.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_state.dart';

class VisitorFormScreen extends StatefulWidget {
  const VisitorFormScreen({super.key, this.visitor});
  final Visitor? visitor;

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _mobile;
  late final TextEditingController _email;
  late final TextEditingController _purpose;
  late String _type;
  late String _project;
  bool _saving = false;

  bool get _editing => widget.visitor != null;

  @override
  void initState() {
    super.initState();
    final visitor = widget.visitor;
    _name = TextEditingController(text: visitor?.name ?? '');
    _mobile = TextEditingController(text: visitor?.mobile ?? '');
    _email = TextEditingController(text: visitor?.email ?? '');
    _purpose = TextEditingController(text: visitor?.purpose ?? '');
    _type = visitor?.visitorType ?? 'Customer';
    _project = visitor?.project ?? 'Project A';
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
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final previous = widget.visitor;
    final visitor = Visitor(
      id: previous?.id ?? '',
      name: _name.text.trim(),
      mobile: _mobile.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      visitorType: _type,
      project: _project,
      purpose: _purpose.text.trim(),
      status: previous?.status ?? VisitorStatusValue.registered,
      createdAt: previous?.createdAt ?? DateTime.now(),
      checkInTime: previous?.checkInTime,
      checkOutTime: previous?.checkOutTime,
    );

    final bloc = context.read<VisitorBloc>();
    bloc.add(
      previous == null ? VisitorCreated(visitor) : VisitorUpdated(visitor),
    );
    try {
      await bloc.stream.firstWhere(
        (state) =>
            state.status == VisitorStatus.loaded ||
            state.status == VisitorStatus.failure,
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      return;
    }

    if (!mounted) return;
    setState(() => _saving = false);
    final latest = bloc.state;
    if (latest.status == VisitorStatus.loaded && latest.message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(latest.message!)));
      context.pop();
    } else if (latest.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(latest.message!),
          backgroundColor: const Color(0xFFC43D4B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_editing ? 'Edit visitor' : 'Register visitor'),
      leading: IconButton(
        onPressed: _saving ? null : () => context.pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    body: SafeArea(
      child: ResponsiveContent(
        maxWidth: 820,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 620 ? 2 : 1;
              final gap = 16.0;
              final fieldWidth = columns == 2
                  ? (constraints.maxWidth - gap) / 2
                  : constraints.maxWidth;

              Widget sizedField(Widget child) =>
                  SizedBox(width: fieldWidth, child: child);

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 22),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            _editing
                                ? Icons.edit_note_rounded
                                : Icons.person_add_alt_1_rounded,
                            color: brandColor,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _editing
                                    ? 'Update visitor details'
                                    : 'New visitor registration',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _editing
                                    ? 'Review the information and save your changes.'
                                    : 'Enter the visitor details below to create a secure visitor record.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const SectionHeading(
                    title: 'Personal information',
                    subtitle: 'Contact details used to identify the visitor.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: gap,
                    runSpacing: 16,
                    children: [
                      sizedField(
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Full name *',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) =>
                              _required(value, 'Visitor name'),
                        ),
                      ),
                      sizedField(
                        TextFormField(
                          controller: _mobile,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Mobile number *',
                            prefixIcon: Icon(Icons.phone_iphone_rounded),
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Mobile number is required';
                            }
                            if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                              return 'Enter exactly 10 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                      sizedField(
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email address (optional)',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (value) {
                            if (value != null &&
                                value.trim().isNotEmpty &&
                                !RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                ).hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const SectionHeading(
                    title: 'Visit information',
                    subtitle:
                        'Help the team understand where and why the visitor is arriving.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: gap,
                    runSpacing: 16,
                    children: [
                      sizedField(
                        DropdownButtonFormField<String>(
                          initialValue: _type,
                          decoration: const InputDecoration(
                            labelText: 'Visitor type *',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          items: const ['Customer', 'Vendor', 'Other']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _type = value ?? 'Customer'),
                        ),
                      ),
                      sizedField(
                        DropdownButtonFormField<String>(
                          initialValue: _project,
                          decoration: const InputDecoration(
                            labelText: 'Project *',
                            prefixIcon: Icon(Icons.apartment_rounded),
                          ),
                          items: const ['Project A', 'Project B', 'Project C']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _project = value ?? 'Project A'),
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth,
                        child: TextFormField(
                          controller: _purpose,
                          maxLines: 3,
                          minLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Purpose of visit *',
                            hintText:
                                'e.g. Project discussion, delivery, site inspection',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                          validator: (value) =>
                              _required(value, 'Purpose of visit'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDCE8FF)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 19,
                          color: brandColor,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'A unique visitor QR code will be available after the record is saved successfully.',
                            style: TextStyle(
                              color: Color(0xFF52627A),
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving ? null : () => context.pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_rounded, size: 18),
                          label: Text(
                            _saving
                                ? 'Saving record…'
                                : _editing
                                ? 'Save changes'
                                : 'Register visitor',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

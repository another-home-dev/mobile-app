import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/ui_components.dart';
import 'package:another_home/core/di/service_locator.dart';
import 'package:another_home/core/network/dtos/operations_models.dart';
import '../../../../operations/presentation/bloc/complaint/complaint_bloc.dart';
import '../../../../operations/presentation/bloc/complaint/complaint_event.dart';
import '../../../../operations/presentation/bloc/complaint/complaint_state.dart';

class NewComplaintPage extends StatefulWidget {
  const NewComplaintPage({super.key});

  @override
  State<NewComplaintPage> createState() => _NewComplaintPageState();
}

class _NewComplaintPageState extends State<NewComplaintPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  IncidentCategory _selectedCategory = IncidentCategory.other;
  String? _roomId;
  Uint8List? _imageBytes;
  String _imageMime = 'image/jpeg';

  // Must stay under the operations service's ~3 MB limit once base64-encoded.
  static const _maxImageBytes = 2 * 1024 * 1024;

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const IconTile(icon: Icons.photo_camera_rounded, size: 40),
                title: const Text('Take a photo', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const IconTile(icon: Icons.photo_library_rounded, size: 40),
                title: const Text('Choose from gallery', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    try {
      final file = await ImagePicker().pickImage(source: source, maxWidth: 1280, maxHeight: 1280, imageQuality: 70);
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.length > _maxImageBytes) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('That photo is too large. Please choose a smaller one.')));
        return;
      }

      final path = file.name.toLowerCase();
      setState(() {
        _imageBytes = bytes;
        _imageMime = path.endsWith('.png')
            ? 'image/png'
            : path.endsWith('.webp')
            ? 'image/webp'
            : 'image/jpeg';
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the camera or gallery. Check the app\'s permissions.')));
    }
  }

  @override
  void initState() {
    super.initState();
    ServiceLocator.instance.accommodationRepository.currentRoomId().then((id) {
      if (mounted) setState(() => _roomId = id);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  static const _categories = {
    IncidentCategory.plumbing: ('Plumbing', Icons.water_drop_rounded),
    IncidentCategory.electrical: ('Electrical', Icons.bolt_rounded),
    IncidentCategory.furniture: ('Furniture', Icons.chair_rounded),
    IncidentCategory.other: ('Other', Icons.handyman_rounded),
  };

  void _submit(BuildContext context) {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    if (_roomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need a room assigned before filing a maintenance request. Contact your hostel warden.')),
      );
      return;
    }
    context.read<ComplaintBloc>().add(
      SubmitComplaint(
        category: _selectedCategory,
        title: title,
        description: desc.isEmpty ? title : desc,
        roomId: _roomId!,
        imageData: _imageBytes == null ? null : 'data:$_imageMime;base64,${base64Encode(_imageBytes!)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ComplaintBloc(
        getIncidentsUseCase: ServiceLocator.instance.getIncidentsUseCase,
        reportIncidentUseCase: ServiceLocator.instance.reportIncidentUseCase,
      ),
      child: BlocConsumer<ComplaintBloc, ComplaintState>(
        listener: (context, state) {
          if (state is ComplaintSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint submitted successfully!')));
            Navigator.pop(context, true);
          } else if (state is ComplaintFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit complaint: ${state.message}')));
          }
        },
        builder: (context, state) {
          final isLoading = state is ComplaintLoading;
          return Scaffold(
            appBar: AppBar(title: const Text('Report an issue')),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + MediaQuery.of(context).viewInsets.bottom),
                child: PrimaryButton(
                  label: 'Submit request',
                  icon: Icons.send_rounded,
                  loading: isLoading,
                  onPressed: () => _submit(context),
                ),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                const Text(
                  'Tell us what needs fixing and the maintenance team will take it from there.',
                  style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 20),
                const FieldLabel('Category'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.entries.map((e) {
                    final selected = _selectedCategory == e.key;
                    return ChoiceChip(
                      selected: selected,
                      showCheckmark: false,
                      onSelected: isLoading ? null : (_) => setState(() => _selectedCategory = e.key),
                      avatar: Icon(e.value.$2, size: 18, color: selected ? AppColors.white : AppColors.primary),
                      label: Text(e.value.$1),
                      labelStyle: TextStyle(color: selected ? AppColors.white : AppColors.ink, fontWeight: FontWeight.w700),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const FieldLabel('Title'),
                TextField(
                  controller: _titleController,
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'e.g. Ceiling fan not working'),
                ),
                const SizedBox(height: 20),
                const FieldLabel('Description'),
                TextField(
                  controller: _descriptionController,
                  enabled: !isLoading,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Describe the issue in detail…'),
                ),
                const SizedBox(height: 20),
                const FieldLabel('Photo (optional)'),
                if (_imageBytes != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(_imageBytes!, height: 180, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton.filled(
                          onPressed: isLoading ? null : () => setState(() => _imageBytes = null),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          tooltip: 'Remove photo',
                          style: IconButton.styleFrom(backgroundColor: AppColors.ink.withValues(alpha: 0.7)),
                        ),
                      ),
                    ],
                  )
                else
                  AppCard(
                    onTap: isLoading ? null : _pickImage,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    color: AppColors.primarySoft.withValues(alpha: 0.5),
                    borderColor: AppColors.primary.withValues(alpha: 0.3),
                    child: const Column(
                      children: [
                        Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 30),
                        SizedBox(height: 8),
                        Text(
                          'Add a photo',
                          style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 2),
                        Text('Helps the team understand the problem', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

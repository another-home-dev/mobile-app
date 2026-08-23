import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_button.dart';
import 'package:another_home/core/theme/glass_background.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ComplaintBloc(
        getIncidentsUseCase: ServiceLocator.instance.getIncidentsUseCase,
        reportIncidentUseCase: ServiceLocator.instance.reportIncidentUseCase,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('New Complaint'),
          centerTitle: false,
        ),
        body: GlassBackground(
          child: BlocConsumer<ComplaintBloc, ComplaintState>(
            listener: (context, state) {
              if (state is ComplaintSubmitSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complaint submitted successfully!')),
                );
                Navigator.pop(context, true);
              } else if (state is ComplaintFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to submit complaint: ${state.message}')),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is ComplaintLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Describe the issue', style: TextStyle(color: AppColors.muted, fontSize: 14)),
                    const SizedBox(height: 24),
                    const Text('CATEGORY', style: TextStyle(color: AppColors.muted, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 22),
                    const Text('TITLE', style: TextStyle(color: AppColors.muted, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _titleController,
                      hintText: 'e.g. Ceiling fan not working',
                      maxLines: 1,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 22),
                    const Text('DESCRIPTION', style: TextStyle(color: AppColors.muted, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _descriptionController,
                      hintText: 'Describe the issue in detail...',
                      maxLines: 6,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 22),
                    const Text('ATTACH IMAGE', style: TextStyle(color: AppColors.muted, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Attach image tapped')),
                              );
                            },
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 26),
                        borderRadius: BorderRadius.circular(18),
                        color: AppColors.surfaceElevated.withValues(alpha: 0.35),
                        borderColor: AppColors.primary.withValues(alpha: 0.25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.upload_outlined, color: AppColors.cyan, size: 30),
                            SizedBox(height: 10),
                            Text('Tap to upload a photo', style: TextStyle(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    else
                      GlassButton(
                        onPressed: () {
                          final title = _titleController.text.trim();
                          final desc = _descriptionController.text.trim();
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a title')),
                            );
                            return;
                          }
                          final descriptionText = desc.isEmpty ? title : '$title - $desc';
                          context.read<ComplaintBloc>().add(
                                SubmitComplaint(
                                  category: _selectedCategory,
                                  description: descriptionText,
                                  roomId: '1-A', // Linked to user's room
                                ),
                              );
                        },
                        color: AppColors.primary,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Submit complaint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.send_rounded, size: 18),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      color: AppColors.surfaceElevated.withValues(alpha: 0.4),
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: DropdownButtonFormField<IncidentCategory>(
        initialValue: _selectedCategory,
        dropdownColor: AppColors.surfaceElevated,
        decoration: const InputDecoration(border: InputBorder.none),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.cyan),
        style: const TextStyle(color: AppColors.text),
        items: IncidentCategory.values
            .map((cat) => DropdownMenuItem<IncidentCategory>(
                  value: cat,
                  child: Text(
                    cat == IncidentCategory.plumbing
                        ? 'Plumbing'
                        : cat == IncidentCategory.electrical
                            ? 'Electrical'
                            : cat == IncidentCategory.furniture
                                ? 'Furniture'
                                : 'Other',
                  ),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedCategory = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
    required bool enabled,
  }) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      color: AppColors.surfaceElevated.withValues(alpha: 0.4),
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        enabled: enabled,
        style: const TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.muted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/initials_avatar.dart';
import 'package:another_home/core/theme/ui_components.dart';
import 'package:another_home/core/di/service_locator.dart';
import 'package:another_home/core/errors/student_not_registered_exception.dart';
import 'package:another_home/core/network/dtos/accommodation_models.dart';

class MyRoomPage extends StatefulWidget {
  const MyRoomPage({super.key});

  @override
  State<MyRoomPage> createState() => _MyRoomPageState();
}

class _MyRoomPageState extends State<MyRoomPage> {
  late Future<RoomModel?> _myRoomFuture;

  @override
  void initState() {
    super.initState();
    _myRoomFuture = _loadMyRoom();
  }

  Future<RoomModel?> _loadMyRoom() async {
    try {
      return await ServiceLocator.instance.getMyRoomUseCase();
    } on StudentNotRegisteredException {
      return null;
    }
  }

  void _retry() => setState(() => _myRoomFuture = _loadMyRoom());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My room')),
      body: FutureBuilder<RoomModel?>(
        future: _myRoomFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return MessageView.error(title: "Couldn't load your room", message: '${snapshot.error}', onAction: _retry);
          }
          final room = snapshot.data;
          if (room == null) {
            return const MessageView(
              icon: Icons.bed_outlined,
              title: 'No room allocated yet',
              message: 'Ask your hostel warden to assign you a room. It will show up here once they do.',
            );
          }
          final occupancy = room.capacity == 0 ? 0.0 : (room.occupiedBeds / room.capacity).clamp(0.0, 1.0);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 190,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=800&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primarySoft,
                          child: const Icon(Icons.bed_rounded, size: 64, color: AppColors.primary),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, AppColors.ink.withValues(alpha: 0.75)],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Room ${room.roomNumber}',
                                    style: const TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    'Floor ${room.floor} · ${room.gender}',
                                    style: TextStyle(color: AppColors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            StatusPill(
                              label: room.isAvailable ? 'Beds available' : 'Full',
                              color: room.isAvailable ? AppColors.success : AppColors.warning,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Occupancy',
                          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          '${room.occupiedBeds} of ${room.capacity} beds',
                          style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: occupancy,
                        minHeight: 10,
                        backgroundColor: AppColors.surfaceAlt,
                        color: AppColors.primary,
                      ),
                    ),
                    if (room.assignedStudents.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Roommates',
                        style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: room.assignedStudents
                            .map(
                              (s) => Chip(
                                avatar: InitialsAvatar(name: s.name, radius: 12),
                                label: Text(s.name),
                                backgroundColor: AppColors.surfaceAlt,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                                labelStyle: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle('Room details'),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Column(
                  children: [
                    InfoRow(icon: Icons.tag_rounded, label: 'Room number', value: room.roomNumber),
                    InfoRow(icon: Icons.stairs_rounded, label: 'Floor', value: room.floor.toString()),
                    InfoRow(icon: Icons.wc_rounded, label: 'Designation', value: room.gender),
                    InfoRow(icon: Icons.ac_unit_rounded, label: 'Air conditioning', value: room.airConditioning),
                    InfoRow(
                      icon: Icons.payments_outlined,
                      label: 'Rent / month',
                      value: 'Rs. ${room.rentPerMonth.toStringAsFixed(0)}',
                      showDivider: false,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

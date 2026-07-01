import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../data/models/schedule_model.dart';

/// Halaman detail jadwal minum obat.
class ScheduleDetailPage extends StatelessWidget {
  final ScheduleModel schedule;

  const ScheduleDetailPage({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent == true) {
          if (state is ScheduleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF0D9488),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, true);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Jadwal'),
          backgroundColor: const Color(0xFF0D9488),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/schedule/form',
                  arguments: schedule,
                );
                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Info
              const Text(
                'Informasi Obat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.medication, 'Nama Obat', schedule.medicine?.name ?? '-'),
              _buildInfoRow(Icons.category, 'Jenis', schedule.medicine?.typeLabel ?? '-'),
              _buildInfoRow(Icons.straighten, 'Dosis', '${schedule.medicine?.dosage ?? '-'} ${schedule.medicine?.unit ?? ''}'),

              const SizedBox(height: 24),

              // Schedule Info
              const Text(
                'Informasi Jadwal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.access_time, 'Waktu', schedule.times.join(', ')),
              _buildInfoRow(Icons.repeat, 'Frekuensi', schedule.frequencyLabel),
              _buildInfoRow(Icons.calendar_today, 'Tanggal Mulai', schedule.startDate),
              _buildInfoRow(Icons.event, 'Tanggal Selesai', schedule.endDate ?? 'Belum ditentukan'),

              if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Catatan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    schedule.notes!,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF0D9488), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Jadwal'),
        content: const Text('Jadwal ini akan dihapus. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ScheduleBloc>().add(ScheduleDelete(schedule.id!));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

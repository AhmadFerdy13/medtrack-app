import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../medicine/bloc/medicine_bloc.dart';
import '../../medicine/bloc/medicine_event.dart';
import '../../medicine/bloc/medicine_state.dart';
import '../../schedule/bloc/schedule_bloc.dart';
import '../../schedule/bloc/schedule_event.dart';
import '../../schedule/bloc/schedule_state.dart';
import '../../schedule/bloc/today_dose_bloc.dart';
import '../../schedule/bloc/today_dose_event.dart';
import '../../schedule/bloc/today_dose_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

/// Halaman dashboard — ringkasan data obat dan jadwal.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<MedicineBloc>().add(MedicineLoadAll());
    context.read<ScheduleBloc>().add(ScheduleLoadAll()); // still used for Schedule Tab
    context.read<TodayDoseBloc>().add(TodayDoseLoad()); // new for Dashboard & Today Doses
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardContent(),
          _buildMedicineNav(),
          _buildScheduleNav(),
          _buildProfileNav(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 0) _loadData();
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF0D9488),
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication_rounded),
              label: 'Obat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule_rounded),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  /// Tab navigasi ke halaman Obat.
  Widget _buildMedicineNav() {
    // Trigger load saat tab aktif
    return const _MedicineTabWrapper();
  }

  /// Tab navigasi ke halaman Jadwal.
  Widget _buildScheduleNav() {
    return const _ScheduleTabWrapper();
  }

  /// Tab navigasi ke halaman Profil.
  Widget _buildProfileNav() {
    return const _ProfileTabWrapper();
  }

  /// Konten utama dashboard.
  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      color: const Color(0xFF0D9488),
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0D9488),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D9488),
                      Color(0xFF0891B2),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final name = state is AuthAuthenticated
                                ? state.user.name
                                : 'User';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, $name! 👋',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pantau kesehatan Anda hari ini',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid
                  BlocBuilder<MedicineBloc, MedicineState>(
                    builder: (context, medicineState) {
                      return BlocBuilder<TodayDoseBloc, TodayDoseState>(
                        builder: (context, todayState) {
                          int totalMedicines = 0;
                          int pendingDoses = 0;
                          int completedDoses = 0;
                          int skippedDoses = 0;

                          if (medicineState is MedicineLoaded) {
                            totalMedicines = medicineState.medicines.length;
                          }
                          if (todayState is TodayDoseLoaded) {
                            for (var d in todayState.doses) {
                              switch (d.status) {
                                case 'pending':
                                  pendingDoses++;
                                  break;
                                case 'taken':
                                  completedDoses++;
                                  break;
                                case 'skipped':
                                  skippedDoses++;
                                  break;
                              }
                            }
                          }

                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.15,
                            children: [
                              _buildStatCard(
                                title: 'Total Obat',
                                value: totalMedicines.toString(),
                                icon: Icons.medication_rounded,
                                color: const Color(0xFF0891B2),
                                bgColor: const Color(0xFFECFEFF),
                              ),
                              _buildStatCard(
                                title: 'Menunggu',
                                value: pendingDoses.toString(),
                                icon: Icons.access_time_rounded,
                                color: const Color(0xFF059669),
                                bgColor: const Color(0xFFECFDF5),
                              ),
                              _buildStatCard(
                                title: 'Selesai',
                                value: completedDoses.toString(),
                                icon: Icons.check_circle_outline,
                                color: const Color(0xFF7C3AED),
                                bgColor: const Color(0xFFF5F3FF),
                              ),
                              _buildStatCard(
                                title: 'Dilewati',
                                value: skippedDoses.toString(),
                                icon: Icons.cancel_outlined,
                                color: const Color(0xFFEA580C),
                                bgColor: const Color(0xFFFFF7ED),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Quick Actions
                  const Text(
                    'Aksi Cepat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.add_circle_outline,
                          label: 'Tambah Obat',
                          color: const Color(0xFF0D9488),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/medicine/form');
                            if (mounted) _loadData();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.event_note_outlined,
                          label: 'Buat Jadwal',
                          color: const Color(0xFF0891B2),
                          onTap: () async {
                            await Navigator.pushNamed(context, '/schedule/form');
                            if (mounted) _loadData();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Wrappers (trigger load saat tab aktif) ──

class _MedicineTabWrapper extends StatelessWidget {
  const _MedicineTabWrapper();

  @override
  Widget build(BuildContext context) {
    // Redirect ke halaman daftar obat sebagai tab
    return const _InlineMedicineList();
  }
}

class _ScheduleTabWrapper extends StatelessWidget {
  const _ScheduleTabWrapper();

  @override
  Widget build(BuildContext context) {
    return const _InlineScheduleList();
  }
}

class _ProfileTabWrapper extends StatelessWidget {
  const _ProfileTabWrapper();

  @override
  Widget build(BuildContext context) {
    // Import halaman profil secara inline
    return const _InlineProfilePage();
  }
}

// ── Inline pages for tabs ──

class _InlineMedicineList extends StatefulWidget {
  const _InlineMedicineList();

  @override
  State<_InlineMedicineList> createState() => _InlineMedicineListState();
}

class _InlineMedicineListState extends State<_InlineMedicineList> {
  @override
  void initState() {
    super.initState();
    context.read<MedicineBloc>().add(MedicineLoadAll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Obat'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<MedicineBloc, MedicineState>(
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent == true) {
            if (state is MedicineSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFF0D9488),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is MedicineError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is MedicineLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
          }
          if (state is MedicineLoaded) {
            if (state.medicines.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medication_outlined, size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada data obat',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan obat pertama Anda',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<MedicineBloc>().add(MedicineLoadAll());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.medicines.length,
                itemBuilder: (context, index) {
                  final med = state.medicines[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.medication, color: Color(0xFF0D9488)),
                      ),
                      title: Text(
                        med.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${med.typeLabel} • ${med.dosage} ${med.unit}'),
                          if (med.usageInstruction != null && med.usageInstruction!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                med.usageInstruction!,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                        ],
                        onSelected: (val) async {
                          if (val == 'edit') {
                            await Navigator.pushNamed(context, '/medicine/form', arguments: med);
                            if (mounted) {
                              context.read<MedicineBloc>().add(MedicineLoadAll());
                            }
                          } else if (val == 'delete') {
                            _confirmDelete(context, med.id!);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/medicine/form');
          if (mounted) {
            context.read<MedicineBloc>().add(MedicineLoadAll());
          }
        },
        backgroundColor: const Color(0xFF0D9488),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Obat'),
        content: const Text('Obat dan semua jadwal terkait akan dihapus. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MedicineBloc>().add(MedicineDelete(id));
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

class _InlineScheduleList extends StatefulWidget {
  const _InlineScheduleList();

  @override
  State<_InlineScheduleList> createState() => _InlineScheduleListState();
}

class _InlineScheduleListState extends State<_InlineScheduleList> {
  @override
  void initState() {
    super.initState();
    context.read<TodayDoseBloc>().add(TodayDoseLoad());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey.shade600;
      case 'taken':
        return const Color(0xFF059669);
      case 'skipped':
        return const Color(0xFFEA580C);
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'taken':
        return 'Selesai';
      case 'skipped':
        return 'Terlewat';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Hari Ini'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<TodayDoseBloc, TodayDoseState>(
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent == true) {
            if (state is TodayDoseSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFF0D9488),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is TodayDoseError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is TodayDoseLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
          }
          if (state is TodayDoseLoaded) {
            if (state.doses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 72, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Belum ada jadwal hari ini', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    Text('Jadwal akan muncul sesuai pengaturan Anda', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TodayDoseBloc>().add(TodayDoseLoad());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.doses.length,
                itemBuilder: (context, index) {
                  final dose = state.doses[index];
                  final statusColor = _statusColor(dose.status);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                dose.time,
                                style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dose.medicine.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Dosis: ${dose.medicine.dosage} ${dose.medicine.unit}',
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _statusLabel(dose.status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              if (dose.status == 'pending' || dose.status == 'skipped')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.read<TodayDoseBloc>().add(TodayDoseConfirm(
                                        scheduleId: dose.scheduleId,
                                        time: dose.time,
                                        status: 'taken',
                                      ));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D9488),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                      minimumSize: const Size(0, 32),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Sudah Diminum', style: TextStyle(fontSize: 11)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/schedule/form');
          if (mounted) {
            context.read<ScheduleBloc>().add(ScheduleLoadAll());
          }
        },
        backgroundColor: const Color(0xFF0D9488),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _InlineProfilePage extends StatelessWidget {
  const _InlineProfilePage();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent == true) {
          if (state is AuthUnauthenticated) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profil Saya'),
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D9488),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(user.email, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _info(Icons.person_outline, 'Nama', user.name),
                        const SizedBox(height: 12),
                        _info(Icons.email_outlined, 'Email', user.email),
                        const SizedBox(height: 12),
                        _info(Icons.calendar_today_outlined, 'Bergabung', user.createdAt ?? '-'),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmLogout(context),
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFF0D9488).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF0D9488), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../medicine/bloc/medicine_bloc.dart';
import '../../medicine/bloc/medicine_event.dart';
import '../../medicine/bloc/medicine_state.dart';
import '../../medicine/data/models/medicine_model.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../data/models/schedule_model.dart';

/// Halaman tambah/edit jadwal minum obat.
class ScheduleFormPage extends StatefulWidget {
  final ScheduleModel? schedule; // null = tambah, non-null = edit

  const ScheduleFormPage({super.key, this.schedule});

  @override
  State<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends State<ScheduleFormPage> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedMedicineId;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _notesController;
  String _selectedFrequency = 'once_daily';

  final List<TextEditingController> _timeControllers = [];

  bool get _isEditing => widget.schedule != null;

  final List<Map<String, String>> _frequencies = [
    {'value': 'once_daily', 'label': 'Sekali Sehari'},
    {'value': 'twice_daily', 'label': 'Dua Kali Sehari'},
    {'value': 'three_times_daily', 'label': 'Tiga Kali Sehari'},
    {'value': 'as_needed', 'label': 'Sesuai Kebutuhan'},
  ];

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController(text: widget.schedule?.startDate ?? '');
    _endDateController = TextEditingController(text: widget.schedule?.endDate ?? '');
    _notesController = TextEditingController(text: widget.schedule?.notes ?? '');
    _selectedMedicineId = widget.schedule?.medicineId;
    _selectedFrequency = widget.schedule?.frequency ?? 'once_daily';

    _initTimeControllers();

    // Load daftar obat untuk dropdown
    context.read<MedicineBloc>().add(MedicineLoadAll());
  }

  void _initTimeControllers() {
    int count = _getExpectedTimeCount();

    if (widget.schedule != null && widget.schedule!.times.isNotEmpty) {
      for (var time in widget.schedule!.times) {
        _timeControllers.add(TextEditingController(text: time));
      }
      while (_timeControllers.length < count) {
        _timeControllers.add(TextEditingController());
      }
      if (_timeControllers.length > count) {
        _timeControllers.removeRange(count, _timeControllers.length);
      }
    } else {
      for (int i = 0; i < count; i++) {
        _timeControllers.add(TextEditingController());
      }
    }
  }

  void _updateTimeControllers() {
    int count = _getExpectedTimeCount();

    setState(() {
      if (_timeControllers.length < count) {
        while (_timeControllers.length < count) {
          _timeControllers.add(TextEditingController());
        }
      } else if (_timeControllers.length > count) {
        while (_timeControllers.length > count) {
          final ctrl = _timeControllers.removeLast();
          ctrl.dispose();
        }
      }
    });
  }

  int _getExpectedTimeCount() {
    if (_selectedFrequency == 'twice_daily') return 2;
    if (_selectedFrequency == 'three_times_daily') return 3;
    return 1;
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _notesController.dispose();
    for (var ctrl in _timeControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0D9488)),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickTime(int index) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0D9488)),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      _timeControllers[index].text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedMedicineId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pilih obat terlebih dahulu'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      List<String> times = _timeControllers.map((c) => c.text.trim()).toList();
      
      final schedule = ScheduleModel(
        medicineId: _selectedMedicineId!,
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim().isEmpty ? null : _endDateController.text.trim(),
        times: times,
        frequency: _selectedFrequency,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (_isEditing) {
        context.read<ScheduleBloc>().add(ScheduleUpdate(widget.schedule!.id!, schedule));
      } else {
        context.read<ScheduleBloc>().add(ScheduleCreate(schedule));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is ScheduleSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF0D9488),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is ScheduleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Jadwal' : 'Tambah Jadwal'),
          backgroundColor: const Color(0xFF0D9488),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pilih Obat
                _buildLabel('Pilih Obat *'),
                const SizedBox(height: 8),
                BlocBuilder<MedicineBloc, MedicineState>(
                  builder: (context, state) {
                    List<MedicineModel> medicines = [];
                    if (state is MedicineLoaded) {
                      medicines = state.medicines;
                    }

                    if (medicines.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade300),
                          color: Colors.orange.shade50,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Belum ada data obat. Tambahkan obat terlebih dahulu.',
                                style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return DropdownButtonFormField<int>(
                      initialValue: _selectedMedicineId,
                      decoration: _inputDecoration('Pilih obat'),
                      items: medicines.map((med) {
                        return DropdownMenuItem(
                          value: med.id,
                          child: Text('${med.name} (${med.dosage} ${med.unit})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedMedicineId = val),
                      validator: (v) => v == null ? 'Obat harus dipilih' : null,
                    );
                  },
                ),
                const SizedBox(height: 18),

                // Frekuensi
                _buildLabel('Frekuensi *'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedFrequency,
                  decoration: _inputDecoration('Pilih frekuensi'),
                  items: _frequencies.map((f) {
                    return DropdownMenuItem(value: f['value'], child: Text(f['label']!));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _selectedFrequency = val;
                      _updateTimeControllers();
                    }
                  },
                ),
                const SizedBox(height: 18),

                // Waktu (Dinamis berdasarkan Frekuensi)
                _buildLabel('Waktu Minum *'),
                const SizedBox(height: 8),
                ...List.generate(_timeControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: _timeControllers[index],
                      readOnly: true,
                      onTap: () => _pickTime(index),
                      decoration: _inputDecoration('Waktu ke-${index + 1} (HH:MM)').copyWith(
                        suffixIcon: const Icon(Icons.access_time, size: 20),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Waktu harus diisi' : null,
                    ),
                  );
                }),
                const SizedBox(height: 6),

                // Tanggal Mulai & Selesai
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Tanggal Mulai *'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _startDateController,
                            readOnly: true,
                            onTap: () => _pickDate(_startDateController),
                            decoration: _inputDecoration('YYYY-MM-DD').copyWith(
                              suffixIcon: const Icon(Icons.calendar_today, size: 20),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Tanggal Selesai'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _endDateController,
                            readOnly: true,
                            onTap: () => _pickDate(_endDateController),
                            decoration: _inputDecoration('Opsional').copyWith(
                              suffixIcon: const Icon(Icons.calendar_today, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Catatan
                _buildLabel('Catatan'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  decoration: _inputDecoration('Catatan tambahan (opsional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 28),

                // Submit Button
                BlocBuilder<ScheduleBloc, ScheduleState>(
                  builder: (context, state) {
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state is ScheduleLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: state is ScheduleLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _isEditing ? 'Perbarui' : 'Simpan',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

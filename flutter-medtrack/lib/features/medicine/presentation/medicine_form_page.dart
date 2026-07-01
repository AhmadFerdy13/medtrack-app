import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/medicine_bloc.dart';
import '../bloc/medicine_event.dart';
import '../bloc/medicine_state.dart';
import '../data/models/medicine_model.dart';

/// Halaman tambah/edit obat.
class MedicineFormPage extends StatefulWidget {
  final MedicineModel? medicine; // null = tambah, non-null = edit

  const MedicineFormPage({super.key, this.medicine});

  @override
  State<MedicineFormPage> createState() => _MedicineFormPageState();
}

class _MedicineFormPageState extends State<MedicineFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _unitController;
  late TextEditingController _usageController;
  late TextEditingController _notesController;
  String _selectedType = 'tablet';

  bool get _isEditing => widget.medicine != null;

  final List<Map<String, String>> _types = [
    {'value': 'tablet', 'label': 'Tablet'},
    {'value': 'capsule', 'label': 'Kapsul'},
    {'value': 'syrup', 'label': 'Sirup'},
    {'value': 'injection', 'label': 'Injeksi'},
    {'value': 'ointment', 'label': 'Salep'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine?.name ?? '');
    _dosageController = TextEditingController(text: widget.medicine?.dosage ?? '');
    _unitController = TextEditingController(text: widget.medicine?.unit ?? '');
    _usageController = TextEditingController(text: widget.medicine?.usageInstruction ?? '');
    _notesController = TextEditingController(text: widget.medicine?.notes ?? '');
    _selectedType = widget.medicine?.type ?? 'tablet';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _unitController.dispose();
    _usageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final medicine = MedicineModel(
        name: _nameController.text.trim(),
        type: _selectedType,
        dosage: _dosageController.text.trim(),
        unit: _unitController.text.trim(),
        usageInstruction: _usageController.text.trim().isEmpty ? null : _usageController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (_isEditing) {
        context.read<MedicineBloc>().add(MedicineUpdate(widget.medicine!.id!, medicine));
      } else {
        context.read<MedicineBloc>().add(MedicineCreate(medicine));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicineBloc, MedicineState>(
      listener: (context, state) {
        if (state is MedicineSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF0D9488),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is MedicineError) {
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
          title: Text(_isEditing ? 'Edit Obat' : 'Tambah Obat'),
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
                // Nama Obat
                _buildLabel('Nama Obat *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Masukkan nama obat'),
                  validator: (v) => v == null || v.isEmpty ? 'Nama obat harus diisi' : null,
                ),
                const SizedBox(height: 18),

                // Jenis Obat
                _buildLabel('Jenis Obat *'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: _inputDecoration('Pilih jenis obat'),
                  items: _types.map((t) {
                    return DropdownMenuItem(value: t['value'], child: Text(t['label']!));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 18),

                // Dosis & Satuan
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Dosis *'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dosageController,
                            decoration: _inputDecoration('Contoh: 500'),
                            validator: (v) => v == null || v.isEmpty ? 'Dosis harus diisi' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Satuan *'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _unitController,
                            decoration: _inputDecoration('mg'),
                            validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Instruksi Penggunaan
                _buildLabel('Instruksi Penggunaan'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usageController,
                  decoration: _inputDecoration('Contoh: Diminum setelah makan'),
                  maxLines: 2,
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
                BlocBuilder<MedicineBloc, MedicineState>(
                  builder: (context, state) {
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state is MedicineLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: state is MedicineLoading
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

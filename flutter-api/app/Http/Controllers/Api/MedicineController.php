<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Medicine;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MedicineController extends Controller
{
    /**
     * Menampilkan daftar obat milik user yang sedang login.
     */
    public function index()
    {
        $medicines = auth()->guard('api')->user()->medicines()->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar obat berhasil diambil',
            'data'    => $medicines,
        ]);
    }

    /**
     * Menyimpan data obat baru.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'              => 'required|string|max:255',
            'type'              => 'required|string|in:tablet,capsule,syrup,injection,ointment',
            'dosage'            => 'required|string|max:100',
            'unit'              => 'required|string|max:50',
            'usage_instruction' => 'nullable|string',
            'notes'             => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data'    => $validator->errors(),
            ], 422);
        }

        $medicine = auth()->guard('api')->user()->medicines()->create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Obat berhasil ditambahkan',
            'data'    => $medicine,
        ], 201);
    }

    /**
     * Menampilkan detail obat berdasarkan ID.
     */
    public function show($id)
    {
        $medicine = auth()->guard('api')->user()->medicines()->find($id);

        if (!$medicine) {
            return response()->json([
                'success' => false,
                'message' => 'Obat tidak ditemukan',
                'data'    => null,
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail obat berhasil diambil',
            'data'    => $medicine,
        ]);
    }

    /**
     * Mengubah data obat.
     */
    public function update(Request $request, $id)
    {
        $medicine = auth()->guard('api')->user()->medicines()->find($id);

        if (!$medicine) {
            return response()->json([
                'success' => false,
                'message' => 'Obat tidak ditemukan',
                'data'    => null,
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'name'              => 'sometimes|required|string|max:255',
            'type'              => 'sometimes|required|string|in:tablet,capsule,syrup,injection,ointment',
            'dosage'            => 'sometimes|required|string|max:100',
            'unit'              => 'sometimes|required|string|max:50',
            'usage_instruction' => 'nullable|string',
            'notes'             => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data'    => $validator->errors(),
            ], 422);
        }

        $medicine->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Obat berhasil diperbarui',
            'data'    => $medicine,
        ]);
    }

    /**
     * Menghapus data obat.
     */
    public function destroy($id)
    {
        $medicine = auth()->guard('api')->user()->medicines()->find($id);

        if (!$medicine) {
            return response()->json([
                'success' => false,
                'message' => 'Obat tidak ditemukan',
                'data'    => null,
            ], 404);
        }

        $medicine->delete();

        return response()->json([
            'success' => true,
            'message' => 'Obat berhasil dihapus',
            'data'    => null,
        ]);
    }
}

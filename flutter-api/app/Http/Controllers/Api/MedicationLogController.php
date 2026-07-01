<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MedicationLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MedicationLogController extends Controller
{
    /**
     * Konfirmasi minum obat.
     */
    public function confirm(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'schedule_id' => 'required|integer|exists:medication_schedules,id',
            'time'        => 'required|string',
            'status'      => 'required|string|in:taken,skipped',
            'date'        => 'nullable|date', // Default hari ini jika tidak dikirim
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data'    => $validator->errors(),
            ], 422);
        }

        $user = auth()->guard('api')->user();
        $date = $request->date ?? date('Y-m-d');

        // Pastikan jadwal milik user
        $schedule = $user->medicationSchedules()->find($request->schedule_id);
        if (!$schedule) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tidak ditemukan atau bukan milik Anda',
                'data'    => null,
            ], 404);
        }

        // Cek apakah log sudah ada untuk tanggal dan waktu ini
        $log = MedicationLog::where('user_id', $user->id)
            ->where('medication_schedule_id', $schedule->id)
            ->where('scheduled_date', $date)
            ->where('scheduled_time', $request->time)
            ->first();

        if ($log) {
            // Update status jika sudah ada (misal dari skipped menjadi taken)
            $log->update([
                'status' => $request->status,
                'taken_at' => $request->status == 'taken' ? now() : null,
            ]);
        } else {
            // Buat baru
            $log = MedicationLog::create([
                'user_id' => $user->id,
                'medication_schedule_id' => $schedule->id,
                'scheduled_date' => $date,
                'scheduled_time' => $request->time,
                'status' => $request->status,
                'taken_at' => $request->status == 'taken' ? now() : null,
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Status berhasil diperbarui',
            'data'    => $log,
        ]);
    }
}

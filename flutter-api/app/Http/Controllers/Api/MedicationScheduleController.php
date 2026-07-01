<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MedicationSchedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MedicationScheduleController extends Controller
{
    /**
     * Menampilkan daftar jadwal minum obat milik user yang sedang login.
     */
    public function index()
    {
        $schedules = auth()->guard('api')->user()
            ->medicationSchedules()
            ->with('medicine')
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar jadwal berhasil diambil',
            'data'    => $schedules,
        ]);
    }

    /**
     * Menyimpan jadwal minum obat baru.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'medicine_id' => 'required|integer|exists:medicines,id',
            'start_date'  => 'required|date',
            'end_date'    => 'nullable|date|after_or_equal:start_date',
            'times'       => 'required|array|min:1',
            'times.*'     => 'required|string', // time format "HH:mm"
            'frequency'   => 'required|string|in:once_daily,twice_daily,three_times_daily,as_needed',
            'notes'       => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data'    => $validator->errors(),
            ], 422);
        }

        // Validasi jumlah waktu sesuai frekuensi
        $times = $request->times;
        $freq = $request->frequency;
        $expectedCount = 1;
        if ($freq == 'twice_daily') $expectedCount = 2;
        if ($freq == 'three_times_daily') $expectedCount = 3;
        
        if ($freq != 'as_needed' && count($times) != $expectedCount) {
             return response()->json([
                'success' => false,
                'message' => "Frekuensi {$freq} membutuhkan {$expectedCount} input waktu.",
                'data'    => null,
            ], 422);
        }

        // Pastikan medicine_id milik user yang sedang login
        $medicine = auth()->guard('api')->user()->medicines()->find($request->medicine_id);
        if (!$medicine) {
            return response()->json([
                'success' => false,
                'message' => 'Obat tidak ditemukan atau bukan milik Anda',
                'data'    => null,
            ], 404);
        }

        $data = $request->all();

        $schedule = auth()->guard('api')->user()->medicationSchedules()->create($data);
        $schedule->load('medicine');

        return response()->json([
            'success' => true,
            'message' => 'Jadwal berhasil ditambahkan',
            'data'    => $schedule,
        ], 201);
    }

    /**
     * Menampilkan detail jadwal berdasarkan ID.
     */
    public function show($id)
    {
        $schedule = auth()->guard('api')->user()
            ->medicationSchedules()
            ->with('medicine')
            ->find($id);

        if (!$schedule) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tidak ditemukan',
                'data'    => null,
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail jadwal berhasil diambil',
            'data'    => $schedule,
        ]);
    }

    /**
     * Mengubah data jadwal.
     */
    public function update(Request $request, $id)
    {
        $schedule = auth()->guard('api')->user()->medicationSchedules()->find($id);

        if (!$schedule) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tidak ditemukan',
                'data'    => null,
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'medicine_id' => 'sometimes|required|integer|exists:medicines,id',
            'start_date'  => 'sometimes|required|date',
            'end_date'    => 'nullable|date|after_or_equal:start_date',
            'times'       => 'sometimes|required|array|min:1',
            'times.*'     => 'sometimes|required|string',
            'frequency'   => 'sometimes|required|string|in:once_daily,twice_daily,three_times_daily,as_needed',
            'notes'       => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data'    => $validator->errors(),
            ], 422);
        }

        // Validasi jumlah waktu sesuai frekuensi
        $times = $request->has('times') ? $request->times : $schedule->times;
        $freq = $request->has('frequency') ? $request->frequency : $schedule->frequency;
        $expectedCount = 1;
        if ($freq == 'twice_daily') $expectedCount = 2;
        if ($freq == 'three_times_daily') $expectedCount = 3;
        
        if ($freq != 'as_needed' && count($times) != $expectedCount) {
             return response()->json([
                'success' => false,
                'message' => "Frekuensi {$freq} membutuhkan {$expectedCount} input waktu.",
                'data'    => null,
            ], 422);
        }

        // Jika medicine_id diubah, pastikan milik user
        if ($request->has('medicine_id')) {
            $medicine = auth()->guard('api')->user()->medicines()->find($request->medicine_id);
            if (!$medicine) {
                return response()->json([
                    'success' => false,
                    'message' => 'Obat tidak ditemukan atau bukan milik Anda',
                    'data'    => null,
                ], 404);
            }
        }

        $schedule->update($request->all());
        $schedule->load('medicine');

        return response()->json([
            'success' => true,
            'message' => 'Jadwal berhasil diperbarui',
            'data'    => $schedule,
        ]);
    }

    /**
     * Menghapus jadwal.
     */
    public function destroy($id)
    {
        $schedule = auth()->guard('api')->user()->medicationSchedules()->find($id);

        if (!$schedule) {
            return response()->json([
                'success' => false,
                'message' => 'Jadwal tidak ditemukan',
                'data'    => null,
            ], 404);
        }

        $schedule->delete();

        return response()->json([
            'success' => true,
            'message' => 'Jadwal berhasil dihapus',
            'data'    => null,
        ]);
    }

    /**
     * Mengambil daftar jadwal (dosis) khusus untuk hari ini (real-time status).
     */
    public function todaySchedules()
    {
        $user = auth()->guard('api')->user();
        $today = date('Y-m-d');
        $currentTime = date('H:i');

        // Ambil semua jadwal aktif yang mencakup hari ini
        $schedules = $user->medicationSchedules()
            ->with('medicine')
            ->where('start_date', '<=', $today)
            ->where(function($query) use ($today) {
                $query->where('end_date', '>=', $today)
                      ->orWhereNull('end_date');
            })
            ->get();

        // Ambil semua log hari ini untuk user
        $logs = \App\Models\MedicationLog::where('user_id', $user->id)
            ->where('scheduled_date', $today)
            ->get()
            ->keyBy(function($item) {
                return $item->medication_schedule_id . '_' . $item->scheduled_time;
            });

        $todayDoses = [];

        foreach ($schedules as $schedule) {
            if (is_array($schedule->times)) {
                foreach ($schedule->times as $time) {
                    $logKey = $schedule->id . '_' . $time;
                    $log = $logs->get($logKey);

                    $status = 'pending';
                    if ($log) {
                        $status = $log->status; // 'taken'
                    } else {
                        // Jika belum ada log, cek apakah sudah lewat waktunya
                        if ($time < $currentTime) {
                            $status = 'skipped';
                        }
                    }

                    $todayDoses[] = [
                        'schedule_id' => $schedule->id,
                        'medicine'    => $schedule->medicine,
                        'time'        => $time,
                        'status'      => $status,
                        'frequency'   => $schedule->frequency,
                        'notes'       => $schedule->notes,
                    ];
                }
            }
        }

        // Urutkan berdasarkan waktu
        usort($todayDoses, function($a, $b) {
            return strcmp($a['time'], $b['time']);
        });

        return response()->json([
            'success' => true,
            'message' => 'Jadwal hari ini berhasil diambil',
            'data'    => $todayDoses,
        ]);
    }
}

<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MedicineController;
use App\Http\Controllers\Api\MedicationScheduleController;
use Illuminate\Support\Facades\Route;

// ── Auth Routes ─────────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);

    Route::middleware('auth:api')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
        Route::get('refresh', [AuthController::class, 'refresh']);
    });
});

// ── Protected Resource Routes ───────────────────────────
Route::middleware('auth:api')->group(function () {
    Route::apiResource('medicines', MedicineController::class);
    Route::get('/today-schedules', [\App\Http\Controllers\Api\MedicationScheduleController::class, 'todaySchedules']);
    Route::post('/medication-logs/confirm', [\App\Http\Controllers\Api\MedicationLogController::class, 'confirm']);
    Route::apiResource('medication-schedules', MedicationScheduleController::class);
});
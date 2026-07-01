<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MedicationSchedule extends Model
{
    protected $fillable = [
        'user_id',
        'medicine_id',
        'start_date',
        'end_date',
        'times',
        'frequency',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'start_date' => 'date',
            'end_date'   => 'date',
            'times'      => 'array',
        ];
    }

    /**
     * Jadwal dimiliki oleh satu User.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Jadwal terkait dengan satu Medicine.
     */
    public function medicine(): BelongsTo
    {
        return $this->belongsTo(Medicine::class);
    }
    public function logs()
    {
        return $this->hasMany(MedicationLog::class);
    }
}

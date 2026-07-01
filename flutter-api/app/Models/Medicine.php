<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Medicine extends Model
{
    protected $fillable = [
        'user_id',
        'name',
        'type',
        'dosage',
        'unit',
        'usage_instruction',
        'notes',
    ];

    /**
     * Medicine dimiliki oleh satu User.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Medicine memiliki banyak MedicationSchedule.
     */
    public function medicationSchedules(): HasMany
    {
        return $this->hasMany(MedicationSchedule::class);
    }
}

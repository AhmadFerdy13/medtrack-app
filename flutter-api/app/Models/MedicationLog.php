<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MedicationLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'medication_schedule_id',
        'scheduled_date',
        'scheduled_time',
        'status', // taken, skipped
        'taken_at'
    ];

    public function schedule()
    {
        return $this->belongsTo(MedicationSchedule::class, 'medication_schedule_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

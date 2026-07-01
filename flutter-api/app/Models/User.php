<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',

            // Password otomatis di-hash ketika disimpan.
            'password' => 'hashed',
        ];
    }

    // ── Relasi ──────────────────────────────────────────

    /**
     * User memiliki banyak Medicine.
     */
    public function medicines()
    {
        return $this->hasMany(Medicine::class);
    }

    /**
     * User memiliki banyak MedicationSchedule.
     */
    public function medicationSchedules()
    {
        return $this->hasMany(MedicationSchedule::class);
    }

    // ── JWT ─────────────────────────────────────────────

    public function getJWTIdentifier(): mixed
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims(): array
    {
        return [];
    }
}
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('medication_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('medication_schedule_id');
            $table->date('scheduled_date');
            $table->string('scheduled_time'); // "08:00"
            $table->string('status'); // taken, skipped
            $table->timestamp('taken_at')->nullable();
            $table->timestamps();

            $table->foreign('user_id')
                  ->references('id')->on('users')
                  ->onDelete('cascade');

            $table->foreign('medication_schedule_id')
                  ->references('id')->on('medication_schedules')
                  ->onDelete('cascade');
                  
            // Mencegah duplikasi log untuk jadwal, tanggal, dan waktu yang sama
            $table->unique(['medication_schedule_id', 'scheduled_date', 'scheduled_time'], 'med_log_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('medication_logs');
    }
};

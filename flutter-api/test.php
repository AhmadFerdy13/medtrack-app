<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$controller = new App\Http\Controllers\Api\MedicationScheduleController();
auth()->guard('api')->setUser(App\Models\User::first());
echo json_encode($controller->index()->getData(true));

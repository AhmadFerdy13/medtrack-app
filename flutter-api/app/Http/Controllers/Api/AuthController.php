<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    /**
     * Mendaftarkan pengguna baru.
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'     => 'required|string|max:255',
            'email'    => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|confirmed|min:8',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data'    => $validator->errors(),
            ], 422);
        }

        // Password otomatis di-hash oleh cast 'hashed' pada model User.
        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => $request->password,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'User registered successfully',
            'data'    => $user,
        ], 201);
    }

    /**
     * Login dan menghasilkan token JWT.
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|string|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data'    => $validator->errors(),
            ], 422);
        }

        $credentials = $request->only('email', 'password');
        $token = auth()->guard('api')->attempt($credentials);

        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah',
                'data'    => null,
            ], 401);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data'    => [
                'user'       => auth()->guard('api')->user(),
                'token'      => $token,
                'token_type' => 'bearer',
            ],
        ]);
    }

    /**
     * Logout dan membatalkan token.
     */
    public function logout()
    {
        auth()->guard('api')->logout();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
            'data'    => null,
        ]);
    }

    /**
     * Mengambil user yang sedang login.
     */
    public function me()
    {
        return response()->json([
            'success' => true,
            'message' => 'Profil pengguna berhasil diambil',
            'data'    => auth()->guard('api')->user(),
        ]);
    }

    /**
     * Mengganti token lama dengan token baru.
     */
    public function refresh()
    {
        $newToken = auth()->guard('api')->refresh();

        return response()->json([
            'success' => true,
            'message' => 'Token berhasil di-refresh',
            'data'    => [
                'user'       => auth()->guard('api')->user(),
                'token'      => $newToken,
                'token_type' => 'bearer',
            ],
        ]);
    }
}
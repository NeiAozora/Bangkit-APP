<?php

namespace App\Http\Controllers\SuperOperator;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use App\Models\Pengguna; // Pastikan model Pengguna sudah dibuat
use App\Http\Controllers\Controller;

class SuperAdminController extends Controller
{
    /**
     * @group Super Operator
     *
     * Buat operator baru (Super Operator)
     */
    public function store(Request $request)
    {
        try {
            // Validasi input
            $validator = Validator::make($request->all(), [
                'nama' => 'required|string|max:255',
                'email' => 'required|email|unique:pengguna,email',
                'password' => 'required|string|min:6',
                'nomor_telepon' => 'required|string|max:15'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Buat operator baru
            $operator = Pengguna::create([
                'nama' => $request->input('nama'),
                'email' => $request->input('email'),
                'password' => Hash::make($request->input('password')),
                'peran' => 'operator', // Harus operator sesuai dokumentasi
                'nomor_telepon' => $request->input('nomor_telepon'),
                'foto_profil' => null,
                'created_at' => now()
            ]);

            // Format response sesuai dokumentasi
            return response()->json([
                'message' => 'Operator created successfully',
                'operator' => [
                    'id' => $operator->id,
                    'nama' => $operator->nama,
                    'email' => $operator->email,
                    'peran' => $operator->peran,
                    'nomor_telepon' => $operator->nomor_telepon,
                    'created_at' => $operator->created_at
                ]
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to create operator',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * @group Super Operator
     *
     * Dapatkan semua operator (Super Operator)
     */
    public function get(Request $request)
    {
        try {
            // Ambil semua pengguna dengan peran operator
            $operators = Pengguna::where('peran', 'operator')->get([
                'id', 'nama', 'email', 'nomor_telepon', 'created_at'
            ]);

            // Format response sesuai dokumentasi
            return response()->json([
                'data' => $operators->map(function ($operator) {
                    return [
                        'id' => $operator->id,
                        'nama' => $operator->nama,
                        'email' => $operator->email,
                        'peran' => $operator->peran,
                        'nomor_telepon' => $operator->nomor_telepon,
                        'created_at' => $operator->created_at
                    ];
                })
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to retrieve operators',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

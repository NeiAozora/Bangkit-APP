<?php

namespace App\Http\Controllers\Operator;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use App\Models\Angkot;
use App\Models\Pengguna;

class AngkotController extends Controller {
    // GET /angkot
    public function index(Request $request) {
        $perPage = $request->input('per_page', 15);
        $angkots = Angkot::with(['rute', 'supir'])
            ->paginate($perPage);

        return response()->json([
            "data" => $angkots->items(),
            "pagination" => [
                "current_page" => $angkots->currentPage(),
                "per_page" => $angkots->perPage(),
                "total" => $angkots->total(),
                "last_page" => $angkots->lastPage()
            ]
        ]);
    }

    // GET /angkot/{id}
    public function show(Request $request, $id) {
        try {
            $angkot = Angkot::with(['rute', 'supir'])->findOrFail($id);
            return response()->json([
                "data" => $angkot
            ]);
        } catch (ModelNotFoundException $e) {
            return response()->json([
                "error" => "Angkot tidak ditemukan"
            ], 404);
        }
    }

    // POST /angkot
    public function store(Request $request) {
        // Validasi input
        $validator = Validator::make($request->all(), [
            'id_rute' => 'required|exists:rute,id',
            'id_supir' => 'required|exists:pengguna,id,peran,supir',
            'plat_nomor' => 'required|string|unique:angkot,plat_nomor',
            'kapasitas' => 'required|integer|min:1'
        ]);

        if ($validator->fails()) {
            return response()->json([
                "error" => $validator->errors()
            ], 422);
        }

        // Cek apakah pengguna benar-benar adalah supir
        $supir = Pengguna::find($request->id_supir);
        if (!$supir || $supir->peran !== 'supir') {
            return response()->json([
                "error" => "ID supir tidak valid"
            ], 400);
        }

        // Buat angkot baru
        $angkot = Angkot::create([
            'id_rute' => $request->id_rute,
            'id_supir' => $request->id_supir,
            'plat_nomor' => $request->plat_nomor,
            'kapasitas' => $request->kapasitas,
        ]);

        // Return hasil
        return response()->json([
            "message" => "Angkot berhasil dibuat",
            "data" => Angkot::with(['rute', 'supir'])->find($angkot->id)
        ], 201);
    }

    // PUT /angkot/{id}
    public function update(Request $request, $id) {
        try {
            $angkot = Angkot::findOrFail($id);

            // Validasi input
            $rules = [
                'id_rute' => 'exists:rute,id',
                'id_supir' => 'exists:pengguna,id,peran,supir',
                'plat_nomor' => 'unique:angkot,plat_nomor,'.$id,
                'kapasitas' => 'integer|min:1',
                'status_aktif' => 'boolean'
            ];

            $validator = Validator::make($request->all(), $rules);

            if ($validator->fails()) {
                return response()->json([
                    "error" => $validator->errors()
                ], 422);
            }

            // Update data
            $updateData = $request->only(['id_rute', 'id_supir', 'plat_nomor', 'kapasitas', 'status_aktif']);

            // Jika ada id_supir, cek apakah benar-benar supir
            if ($request->has('id_supir')) {
                $supir = Pengguna::find($request->id_supir);
                if (!$supir || $supir->peran !== 'supir') {
                    return response()->json([
                        "error" => "ID supir tidak valid"
                    ], 400);
                }
            }

            $angkot->update($updateData);

            // Return hasil
            return response()->json([
                "message" => "Angkot berhasil diupdate",
                "data" => Angkot::with(['rute', 'supir'])->find($id)
            ]);

        } catch (ModelNotFoundException $e) {
            return response()->json([
                "error" => "Angkot tidak ditemukan"
            ], 404);
        }
    }

    // DELETE /angkot/{id}
    public function destroy(Request $request, $id) {
        try {
            $angkot = Angkot::findOrFail($id);
            $angkot->delete();

            return response()->json([
                "message" => "Angkot berhasil dihapus"
            ]);
        } catch (ModelNotFoundException $e) {
            return response()->json([
                "error" => "Angkot tidak ditemukan"
            ], 404);
        }
    }
}

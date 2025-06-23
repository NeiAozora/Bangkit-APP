<?php

namespace App\Http\Controllers\Operator;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\PerubahanTarif; // Model ORM untuk tabel perubahan_tarif
use App\Models\Angkot; // Model untuk validasi foreign key
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class TarifController extends Controller
{
    /**
     * Update kebijakan tarif (Operator)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request)
    {
        // Validasi input
        $validator = Validator::make($request->all(), [
            'id_angkot' => 'required|exists:angkot,id',
            'tarif_baru' => 'required|numeric|min:0',
            'tgl_berlaku' => 'required|date'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => $validator->errors()
            ], 422);
        }

        try {
            // Validasi tambahan: Pastikan angkot dimiliki oleh operator
            $angkot = Angkot::findOrFail($request->input('id_angkot'));

            // Buat entri baru di perubahan_tarif
            $perubahan = new PerubahanTarif();
            $perubahan->id_operator = Auth::id(); // Operator yang login
            $perubahan->id_angkot = $request->input('id_angkot');
            $perubahan->tarif_baru = $request->input('tarif_baru');
            $perubahan->tgl_berlaku = $request->input('tgl_berlaku');

            // Simpan ke database
            $perubahan->save();

            // Format response sesuai dokumentasi
            return response()->json([
                "message" => "Tariff updated",
                "perubahan" => [
                    "id" => $perubahan->id,
                    "id_operator" => $perubahan->id_operator,
                    "id_angkot" => $perubahan->id_angkot,
                    "tarif_baru" => number_format($perubahan->tarif_baru, 2, '.', ''),
                    "tgl_berlaku" => $perubahan->tgl_berlaku,
                    "created_at" => $perubahan->created_at->toJSON()
                ]
            ], 201);

        } catch (\Exception $e) {
            // Penanganan error
            return response()->json([
                'error' => 'Gagal menyimpan perubahan tarif',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}

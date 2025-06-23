<?php

namespace App\Http\Controllers\Operator;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;
use App\Models\LaporanHarian;
use App\Models\Angkot;

class ReportController extends Controller
{
    /**
     * @group Laporan
     *
     * Dapatkan laporan harian (Operator)
     *
     * @queryParam tanggal date required Tanggal laporan (format YYYY-MM-DD). Example: 2023-10-01
     *
     * @response 200 {
     *   "tanggal": "2023-10-01",
     *   "data": [
     *     {
     *       "id_angkot": 1,
     *       "plat_nomor": "B 1234 ABC",
     *       "total_perjalanan": 5,
     *       "total_penumpang": 30,
     *       "total_pendapatan": 300000.00
     *     }
     *   ]
     * }
     *
     * @response 400 {
     *   "error": {
     *     "tanggal": ["Tanggal harus dalam format YYYY-MM-DD"]
     *   }
     * }
     */
    public function daily(Request $request)
    {
        // Validasi input
        $validator = Validator::make($request->query(), [
            'tanggal' => 'required|date|date_format:Y-m-d'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 400);
        }

        $tanggal = $request->query('tanggal');

        // Query data laporan dengan eager loading angkot
        $laporan = LaporanHarian::with('angkot')
            ->whereDate('tanggal', $tanggal)
            ->get();

        // Format data untuk response
        $formattedData = $laporan->map(function ($item) {
            return [
                'id_angkot' => $item->id_angkot,
                'plat_nomor' => $item->angkot->plat_nomor,
                'total_perjalanan' => $item->total_perjalanan,
                'total_penumpang' => $item->total_penumpang,
                'total_pendapatan' => (float)$item->total_pendapatan
            ];
        });

        // Return response sesuai format
        return response()->json([
            'tanggal' => $tanggal,
            'data' => $formattedData
        ]);
    }
}

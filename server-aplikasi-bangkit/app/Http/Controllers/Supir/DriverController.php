<?php

namespace App\Http\Controllers\Supir;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use App\Models\AktivitasSupir;
use App\Models\Pengguna;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class DriverController extends Controller
{
    /**
     * Mendapatkan status dan lokasi terakhir supir
     * Route: GET /driver/status
     */
    public function status()
    {
        // Ambil aktivitas supir berdasarkan ID pengguna yang login
        $aktivitas = AktivitasSupir::where('id_supir', Auth::id())->firstOrFail();

        return response()->json([
            'data' => [
                'id' => $aktivitas->id,
                'id_supir' => $aktivitas->id_supir,
                'status' => $aktivitas->status,
                'lokasi_terakhir' => $this->formatGeoJson($aktivitas->lokasi_terakhir),
                'terakhir_update' => $aktivitas->terakhir_update
            ]
        ]);
    }

    /**
     * Update status supir
     * Route: PUT /driver/status
     * Payload: { "status": "tersedia/dalam_perjalanan/istirahat/tidak_aktif" }
     */
    public function updateStatus(Request $request)
    {
        // Validasi input
        $validated = $request->validate([
            'status' => ['required', 'string', 'in:tersedia,dalam_perjalanan,istirahat,tidak_aktif']
        ]);

        // Update status supir
        $aktivitas = AktivitasSupir::firstOrNew(
            ['id_supir' => Auth::id()],
            ['status' => $validated['status'], 'lokasi_terakhir' => DB::raw('ST_GeomFromText("POINT(0 0)", 4326)')]
        );

        $aktivitas->status = $validated['status'];
        $aktivitas->save();

        return response()->json([
            'message' => 'Status supir berhasil diperbarui',
            'aktivitas_supir' => [
                'id' => $aktivitas->id,
                'status' => $aktivitas->status,
                'terakhir_update' => $aktivitas->terakhir_update
            ]
        ]);
    }

    /**
     * Update lokasi terakhir supir
     * Route: PUT /driver/location
     * Payload: { "lokasi": [106.1234, -6.1234] }
     */
    public function updateLocation(Request $request)
    {
        // Validasi koordinat
        $request->validate([
            'lokasi' => ['required', 'array', 'size:2'],
            'lokasi.0' => ['numeric', 'between:-180,180'],
            'lokasi.1' => ['numeric', 'between:-90,90']
        ]);

        // Buat POINT menggunakan raw SQL
        $point = "ST_GeomFromText('POINT({$request->lokasi[0]} {$request->lokasi[1]})', 4326)";

        // Update atau buat aktivitas supir
        $aktivitas = AktivitasSupir::updateOrCreate(
            ['id_supir' => Auth::id()],
            ['lokasi_terakhir' => DB::raw($point)]
        );

        return response()->json([
            'message' => 'Lokasi supir berhasil diperbarui',
            'aktivitas_supir' => [
                'id' => $aktivitas->id,
                'lokasi_terakhir' => $this->formatGeoJson($aktivitas->lokasi_terakhir),
                'terakhir_update' => $aktivitas->terakhir_update
            ]
        ]);
    }

    /**
     * Format geometri PostGIS ke GeoJSON
     */
    private function formatGeoJson($geometry)
    {
        if (!$geometry) return null;

        // Konversi dari WKB ke GeoJSON menggunakan raw query
        $result = DB::selectOne("
            SELECT ST_AsGeoJSON(ST_Transform(?, 4326)) as geojson
        ", [$geometry]);

        return $result ? json_decode($result->geojson) : null;
    }
}

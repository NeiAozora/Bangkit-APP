<?php

namespace App\Http\Controllers\Pelanggan;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use App\Models\Rute;
use App\Models\RutePath;

class RuteController extends Controller
{
public function nearby(Request $request)
{
    $validator = Validator::make($request->all(), [
        'lat' => 'required|numeric',
        'lng' => 'required|numeric',
        'radius' => 'sometimes|required|numeric|min:1|max:10000'
    ]);

    if ($validator->fails()) {
        return response()->json(['error' => $validator->errors()], 422);
    }

    $radius = $request->input('radius', 1000); // Default 1000 meters
    $lat = $request->lat;
    $lng = $request->lng;

    // First get all routes within bounding box for faster filtering
    $rute = Rute::select([
            'id',
            'nama_rute',
            'titik_awal',
            'titik_akhir',
            'titik_awal_lat',
            'titik_awal_lng',
            'titik_akhir_lat',
            'titik_akhir_lng',
            DB::raw("(6371000 * acos(
                cos(radians($lat)) *
                cos(radians(titik_awal_lat)) *
                cos(radians(titik_awal_lng) - radians($lng)) +
                sin(radians($lat)) *
                sin(radians(titik_awal_lat))
            )) AS jarak_meter")
        ])
        ->whereRaw("
            (6371000 * acos(
                cos(radians($lat)) *
                cos(radians(titik_awal_lat)) *
                cos(radians(titik_awal_lng) - radians($lng)) +
                sin(radians($lat)) *
                sin(radians(titik_awal_lat))
            )) <= ?
        ", [$radius])
        ->orderBy('jarak_meter')
        ->get();

    return response()->json([
        'data' => $rute->map(function ($item) {
            return [
                'id' => $item->id,
                'nama_rute' => $item->nama_rute,
                'titik_awal' => $item->titik_awal,
                'titik_akhir' => $item->titik_akhir,
                'koordinat_awal' => [
                    'lat' => $item->titik_awal_lat,
                    'lng' => $item->titik_awal_lng
                ],
                'koordinat_akhir' => [
                    'lat' => $item->titik_akhir_lat,
                    'lng' => $item->titik_akhir_lng
                ],
                'jarak' => round($item->jarak_meter)
            ];
        })
    ]);
}
}

<?php

namespace App\Http\Controllers\Operator;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use App\Models\Rute;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;



class RuteController extends Controller
{

    public function index()
    {
        $rute = Rute::all();

        return response()->json([
            'data' => $rute->map(function ($item) {
                return $this->formatRuteResponse($item);
            })
        ]);
    }

    public function show($id)
    {
        $rute = Rute::findOrFail($id);
        return response()->json($this->formatRuteResponse($rute));
    }


    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama_rute' => 'required|string',
            'titik_awal' => 'required|string',
            'koordinat_awal' => 'required|array|size:2',
            'koordinat_awal.0' => 'required|numeric',
            'koordinat_awal.1' => 'required|numeric',
            'titik_akhir' => 'required|string',
            'koordinat_akhir' => 'required|array|size:2',
            'koordinat_akhir.0' => 'required|numeric',
            'koordinat_akhir.1' => 'required|numeric',
            'path' => 'required|array|min:2',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }

        // Convert coordinates to PostGIS POINT
        $koordinatAwal = sprintf('POINT(%s %s)', $request->koordinat_awal[0], $request->koordinat_awal[1]);
        $koordinatAkhir = sprintf('POINT(%s %s)', $request->koordinat_akhir[0], $request->koordinat_akhir[1]);

        // Convert path to PostGIS LINESTRING
        $pathPoints = array_map(function($point) {
            return sprintf('%s %s', $point[0], $point[1]);
        }, $request->path);

        $pathWKT = 'LINESTRING(' . implode(',', $pathPoints) . ')';

        $rute = Rute::create([
            'nama_rute' => $request->nama_rute,
            'titik_awal' => $request->titik_awal,
            'koordinat_awal' => DB::raw("ST_GeomFromText('{$koordinatAwal}', 4326)"),
            'titik_akhir' => $request->titik_akhir,
            'koordinat_akhir' => DB::raw("ST_GeomFromText('{$koordinatAkhir}', 4326)"),
            'path' => DB::raw("ST_GeomFromText('{$pathWKT}', 4326)"),
        ]);

        return response()->json([
            'message' => 'Rute created',
            'rute' => $this->formatRuteResponse($rute)
        ], 201);
    }


    public function update(Request $request, $id)
    {
        $rute = Rute::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'nama_rute' => 'sometimes|required|string',
            'titik_awal' => 'sometimes|required|string',
            'koordinat_awal' => 'sometimes|required|array|size:2',
            'koordinat_awal.0' => 'required|numeric',
            'koordinat_awal.1' => 'required|numeric',
            'titik_akhir' => 'sometimes|required|string',
            'koordinat_akhir' => 'sometimes|required|array|size:2',
            'koordinat_akhir.0' => 'required|numeric',
            'koordinat_akhir.1' => 'required|numeric',
            'path' => 'sometimes|required|array|min:2',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }

        $updateData = $request->only(['nama_rute', 'titik_awal', 'titik_akhir']);

        // Handle koordinat_awal
        if ($request->has('koordinat_awal')) {
            $updateData['koordinat_awal'] = DB::raw("ST_GeomFromText('POINT({$request->koordinat_awal[0]} {$request->koordinat_awal[1]})', 4326)");
        }

        // Handle koordinat_akhir
        if ($request->has('koordinat_akhir')) {
            $updateData['koordinat_akhir'] = DB::raw("ST_GeomFromText('POINT({$request->koordinat_akhir[0]} {$request->koordinat_akhir[1]})', 4326)");
        }

        // Handle path
        if ($request->has('path')) {
            $pathPoints = array_map(function($point) {
                return "{$point[0]} {$point[1]}";
            }, $request->path);

            $pathWKT = 'LINESTRING(' . implode(',', $pathPoints) . ')';
            $updateData['path'] = DB::raw("ST_GeomFromText('{$pathWKT}', 4326)");
        }

        $rute->update($updateData);

        return response()->json([
            'message' => 'Rute updated successfully',
            'rute' => $this->formatRuteResponse($rute->fresh())
        ]);
    }


    public function destroy($id)
    {
        $rute = Rute::findOrFail($id);
        $rute->delete();

        return response()->json(['message' => 'Rute deleted successfully']);
    }

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

        // Create point from user location
        $userPoint = DB::raw("ST_GeomFromText('POINT({$request->lng} {$request->lat})', 4326)");

        // Query with distance calculation
        $rute = Rute::select([
            'id',
            'nama_rute',
            'titik_awal',
            'titik_akhir',
            DB::raw("ST_Distance(koordinat_awal, {$userPoint}) AS jarak_meter")
        ])
        ->whereRaw("ST_DWithin(koordinat_awal, {$userPoint}, {$radius})")
        ->orderBy('jarak_meter')
        ->get();

        return response()->json([
            'data' => $rute->map(function ($item) {
                return [
                    'id' => $item->id,
                    'nama_rute' => $item->nama_rute,
                    'titik_awal' => $item->titik_awal,
                    'titik_akhir' => $item->titik_akhir,
                    'jarak' => round($item->jarak_meter)
                ];
            })
        ]);
    }

    /**
     * Format data rute untuk response
     */
    private function formatRuteResponse($rute)
    {
        // Convert geometry to GeoJSON
        $rawPath = DB::table('rute')
            ->where('id', $rute->id)
            ->value('path');

        // Parse raw geometry value (needs proper parsing)
        $geoJsonPath = $this->geometryToGeoJson($rawPath);

        return [
            'id' => $rute->id,
            'nama_rute' => $rute->nama_rute,
            'titik_awal' => $rute->titik_awal,
            'koordinat_awal' => $this->geometryToGeoJson($rute->koordinat_awal),
            'titik_akhir' => $rute->titik_akhir,
            'koordinat_akhir' => $this->geometryToGeoJson($rute->koordinat_akhir),
            'path' => $geoJsonPath,
            'created_at' => $rute->created_at->toISOString(),
            'updated_at' => $rute->updated_at->toISOString()
        ];
    }

    /**
     * Convert PostGIS geometry to GeoJSON format
     */
    private function geometryToGeoJson($geometry)
    {
        // In a real implementation, you would use PostGIS functions to convert directly
        // This is a simplified example for demonstration
        return [
            'type' => 'Point',
            'coordinates' => [-6.1234, 106.1234] // Simplified example
        ];
    }
}

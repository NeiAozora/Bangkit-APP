<?php

namespace App\Http\Controllers\Operator;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\JadwalAngkot;
use App\Models\Angkot;
use App\Models\Rute;
use App\Models\Pengguna;

class JadwalController extends Controller
{
    // GET /jadwal (Operator)
    public function index(Request $request)
    {
        $query = JadwalAngkot::query()->with(['angkot', 'rute']);

        if ($request->filled('tanggal')) {
            $query->where('tanggal', $request->input('tanggal'));
        }

        if ($request->filled('id_rute')) {
            $query->where('id_rute', $request->input('id_rute'));
        }

        $jadwal = $query->get();

        return response()->json([
            "data" => $jadwal->map(function($item) {
                return $this->formatJadwal($item);
            })
        ]);
    }

    // GET /jadwal/{id} (Operator)
    public function show(Request $request, $id)
    {
        $jadwal = JadwalAngkot::with(['angkot', 'rute'])->findOrFail($id);
        return response()->json($this->formatJadwal($jadwal));
    }

    // POST /jadwal (Operator)
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_rute' => 'required|exists:rute,id',
            'id_angkot' => 'required|exists:angkot,id',
            'is_balik' => 'nullable|boolean',
            'tarif' => 'required|numeric',
            'tanggal' => 'required|date',
            'waktu_berangkat' => 'required|date_format:H:i:s',
            'estimasi_sampai' => 'required|date_format:H:i:s'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => $validator->errors()
            ], 422);
        }

        $jadwal = JadwalAngkot::create([
            'id_rute' => $request->input('id_rute'),
            'id_angkot' => $request->input('id_angkot'),
            'is_balik' => $request->boolean('is_balik', false),
            'tarif' => $request->input('tarif'),
            'tanggal' => $request->input('tanggal'),
            'waktu_berangkat' => $request->input('waktu_berangkat'),
            'estimasi_sampai' => $request->input('estimasi_sampai')
        ]);

        // Muat relasi untuk respons
        $jadwal->load(['angkot', 'rute']);

        return response()->json([
            "message" => "Jadwal created",
            "jadwal" => $this->formatJadwal($jadwal)
        ], 201);
    }

    // PUT /jadwal/{id} (Operator)
    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'id_rute' => 'exists:rute,id',
            'id_angkot' => 'exists:angkot,id',
            'is_balik' => 'boolean',
            'tarif' => 'numeric',
            'tanggal' => 'date',
            'waktu_berangkat' => 'date_format:H:i:s',
            'estimasi_sampai' => 'date_format:H:i:s'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => $validator->errors()
            ], 422);
        }

        $jadwal = JadwalAngkot::findOrFail($id);

        $jadwal->update($request->only([
            'id_rute', 'id_angkot', 'is_balik',
            'tarif', 'tanggal', 'waktu_berangkat',
            'estimasi_sampai'
        ]));

        $jadwal->refresh();
        $jadwal->load(['angkot', 'rute']);

        return response()->json([
            "message" => "Jadwal updated successfully",
            "jadwal" => $this->formatJadwal($jadwal)
        ]);
    }

    // DELETE /jadwal/{id} (Operator)
    public function destroy(Request $request, $id)
    {
        $jadwal = JadwalAngkot::findOrFail($id);
        $jadwal->delete();

        return response()->json([
            "message" => "Jadwal deleted successfully"
        ]);
    }

    // Fungsi helper untuk format respons
    private function formatJadwal($jadwal)
    {
        $data = [
            "id" => $jadwal->id,
            "id_rute" => $jadwal->id_rute,
            "id_angkot" => $jadwal->id_angkot,
            "is_balik" => (bool)$jadwal->is_balik,
            "tarif" => (float)$jadwal->tarif,
            "tanggal" => $jadwal->tanggal,
            "waktu_berangkat" => $jadwal->waktu_berangkat,
            "estimasi_sampai" => $jadwal->estimasi_sampai,
            "kursi_tersedia" => $jadwal->kursi_tersedia,
            "created_at" => $jadwal->created_at->toJSON(),
            "updated_at" => $jadwal->updated_at->toJSON(),
        ];

        // Tambahkan informasi relasi
        if ($jadwal->relationLoaded('rute') && $jadwal->rute) {
            $data['rute'] = [
                "id" => $jadwal->rute->id,
                "nama_rute" => $jadwal->rute->nama_rute
            ];
        }

        if ($jadwal->relationLoaded('angkot') && $jadwal->angkot) {
            $data['angkot'] = [
                "id" => $jadwal->angkot->id,
                "plat_nomor" => $jadwal->angkot->plat_nomor
            ];
        }

        return $data;
    }
}

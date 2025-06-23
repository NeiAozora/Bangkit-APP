<?php

namespace App\Http\Controllers\Pelanggan;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Models\Booking;
use App\Models\JadwalAngkot;



class BookingController extends Controller
{

    public function index(Request $request)
    {
        $user = Auth::user();

        // Filter berdasarkan status jika ada
        $query = Booking::where('id_pelanggan', $user->id);

        if ($request->has('status')) {
            $query->where('status', $request->input('status'));
        }

        $bookings = $query->with(['jadwal.rute', 'jadwal.angkot'])->get();

        return response()->json([
            'data' => $bookings->map(function ($booking) {
                return $this->formatBooking($booking);
            })
        ]);
    }


    public function show($id)
    {
        $booking = Booking::where('id', $id)
            ->where('id_pelanggan', Auth::id())
            ->with(['jadwal.rute', 'jadwal.angkot'])
            ->firstOrFail();

        return response()->json($this->formatBooking($booking));
    }


    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_jadwal' => 'required|exists:jadwal_angkot,id',
            'tanggal_booking' => 'required|date_format:Y-m-d',
            'waktu_booking' => 'required|date_format:H:i:s',
            'lokasi_jemput' => 'required|array|size:2',
            'lokasi_jemput.*' => 'numeric',
            'jumlah_kursi' => 'required|integer|min:1'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }

        return DB::transaction(function () use ($request) {
            $jadwal = JadwalAngkot::findOrFail($request->id_jadwal);

            if ($jadwal->kursi_tersedia < $request->jumlah_kursi) {
                return response()->json([
                    'error' => 'Tidak cukup kursi tersedia'
                ], 400);
            }

            $booking = Booking::create([
                'id_pelanggan' => Auth::id(),
                'id_jadwal' => $request->id_jadwal,
                'tanggal_booking' => $request->tanggal_booking,
                'waktu_booking' => $request->waktu_booking,
                'lokasi_jemput' => DB::raw("ST_SetSRID(ST_MakePoint({$request->lokasi_jemput[0]}, {$request->lokasi_jemput[1]}), 4326)"),
                'jumlah_kursi' => $request->jumlah_kursi
            ]);

            return response()->json([
                'message' => 'Booking created',
                'booking' => $this->formatBooking($booking)
            ], 201);
        });
    }


    public function cancel($id)
    {
        $booking = Booking::where('id', $id)
            ->where('id_pelanggan', Auth::id())
            ->where('status', 'menunggu_acc')
            ->firstOrFail();

        $booking->update(['status' => 'dibatalkan']);

        return response()->json([
            'message' => 'Booking canceled',
            'booking' => [
                'id' => $booking->id,
                'status' => $booking->status,
                'updated_at' => $booking->updated_at
            ]
        ]);
    }


    public function confirmPayment($id)
    {
        $booking = Booking::where('id', $id)
            ->where('id_pelanggan', Auth::id())
            ->where('status', '!=', 'dibatalkan')
            ->firstOrFail();

        $booking->update(['pembayaran_status' => 'sudah_bayar']);

        return response()->json([
            'message' => 'Payment confirmed',
            'booking' => [
                'id' => $booking->id,
                'pembayaran_status' => $booking->pembayaran_status,
                'updated_at' => $booking->updated_at
            ]
        ]);
    }

    // Helper untuk format data booking
    private function formatBooking($booking)
    {
        return [
            'id' => $booking->id,
            'id_jadwal' => $booking->id_jadwal,
            'tanggal_booking' => $booking->tanggal_booking,
            'waktu_booking' => $booking->waktu_booking,
            'lokasi_jemput' => $booking->lokasi_jemput ? [
                'type' => 'Point',
                'coordinates' => [$booking->lokasi_jemput->longitude, $booking->lokasi_jemput->latitude]
            ] : null,
            'jumlah_kursi' => $booking->jumlah_kursi,
            'status' => $booking->status,
            'pembayaran_status' => $booking->pembayaran_status,
            'created_at' => $booking->created_at,
            'jadwal' => $booking->jadwal ? [
                'id' => $booking->jadwal->id,
                'tarif' => $booking->jadwal->tarif,
                'tanggal' => $booking->jadwal->tanggal,
                'waktu_berangkat' => $booking->jadwal->waktu_berangkat,
                'estimasi_sampai' => $booking->jadwal->estimasi_sampai,
                'rute' => $booking->jadwal->rute ? [
                    'nama_rute' => $booking->jadwal->rute->nama_rute
                ] : null,
                'angkot' => $booking->jadwal->angkot ? [
                    'plat_nomor' => $booking->jadwal->angkot->plat_nomor
                ] : null
            ] : null
        ];
    }
}

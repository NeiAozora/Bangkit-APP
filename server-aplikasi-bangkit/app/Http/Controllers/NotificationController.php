<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use App\Models\Notifikasi; // Pastikan model ini sesuai dengan skema database
use Illuminate\Support\Facades\Validator;

class NotificationController extends Controller
{
    /**
     * Dapatkan semua notifikasi pengguna yang login
     * @group Notifikasi
     */
    public function index(Request $request)
    {
        try {
            // Validasi input (opsional)
            $validator = Validator::make($request->all(), [
                'jenis' => 'nullable|in:booking,pembayaran,promosi,system'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Validasi gagal',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Query dengan filter pengguna yang login
            $query = Notifikasi::where('id_pengguna', Auth::user()->id);

            // Filter berdasarkan jenis jika ada
            if ($request->has('jenis')) {
                $query->where('jenis', $request->input('jenis'));
            }

            $notifications = $query->get();

            return response()->json([
                'status' => 'success',
                'data' => $notifications
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengambil notifikasi',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Tandai notifikasi sebagai terbaca
     * @group Notifikasi
     */
    public function markAsRead(Request $request, $id)
    {
        try {
            // Cari notifikasi
            $notification = Notifikasi::find($id);

            if (!$notification) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Notifikasi tidak ditemukan'
                ], 404);
            }

            // Validasi kepemilikan notifikasi
            if ($notification->id_pengguna != Auth::user()->id) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Anda tidak berhak mengakses notifikasi ini'
                ], 403);
            }

            // Update status
            $notification->status_dibaca = true;
            $notification->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Notifikasi ditandai sebagai terbaca',
                'notification' => $notification
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal memperbarui notifikasi',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

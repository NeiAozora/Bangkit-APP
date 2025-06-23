<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Response;
use App\Http\Controllers\Controller;
use App\Models\Chat;
use App\Models\Booking;
use App\Models\Pengguna;
use Illuminate\Support\Facades\Auth;

class ChatController extends Controller
{


    public function index(Request $request, $bookingId)
    {
        try {
            // Validasi booking
            $booking = Booking::findOrFail($bookingId);

            // Validasi akses
            if (!self::isUserAuthorized($booking)) {
                return response()->json([
                    'error' => 'Forbidden',
                    'message' => 'You are not authorized to view this chat'
                ], 403);
            }

            // Ambil chat dengan relasi pengirim
            $chats = Chat::where('id_booking', $bookingId)
                ->with(['pengirim' => function($query) {
                    $query->select('id', 'nama', 'foto_profil');
                }])
                ->orderBy('waktu_kirim', 'asc')
                ->get();

            return response()->json([
                'data' => $chats
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'Booking not found'
            ], 404);
        }
    }


    public function send(Request $request, $bookingId)
    {
        // Validasi input
        $validator = Validator::make($request->all(), [
            'id_penerima' => 'required|exists:pengguna,id',
            'pesan' => 'required|string|min:1|max:500'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Validation Error',
                'message' => $validator->errors()
            ], 400);
        }

        try {
            // Validasi booking
            $booking = Booking::findOrFail($bookingId);

            // Validasi akses
            if (!self::isUserAuthorized($booking)) {
                return response()->json([
                    'error' => 'Forbidden',
                    'message' => 'You are not authorized to send messages to this booking'
                ], 403);
            }

            // Validasi penerima
            if (!self::isRecipientValid($booking, $request->id_penerima)) {
                return response()->json([
                    'error' => 'Validation Error',
                    'message' => 'Recipient is not part of this booking'
                ], 400);
            }

            // Buat chat baru
            $chat = new Chat();
            $chat->id_booking = $bookingId;
            $chat->id_pengirim = Auth::user()->id;
            $chat->id_penerima = $request->id_penerima;
            $chat->pesan = $request->pesan;
            $chat->save();

            return response()->json([
                'message' => 'Message sent',
                'chat' => $chat->load('pengirim')
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Not Found',
                'message' => 'Booking not found'
            ], 404);
        }
    }

    /**
     * Validasi apakah user memiliki akses ke chat
     */
    private static function isUserAuthorized(Booking $booking): bool
    {
        $userId = Auth::user()->id;
        $bookingUserId = $booking->id_pelanggan;

        // Cek apakah user adalah pelanggan yang memesan
        if ($userId === $bookingUserId) {
            return true;
        }

        // Cek apakah user adalah supir dari angkot ini
        if ($booking->jadwal->angkot->id_supir === $userId) {
            return true;
        }

        // Cek apakah user adalah operator atau super operator
        if (in_array(Auth::user()->peran, ['operator', 'super_operator'])) {
            return true;
        }

        return false;
    }

    /**
     * Validasi apakah penerima adalah bagian dari booking
     */
    private static function isRecipientValid(Booking $booking, int $recipientId): bool
    {
        // Penerima harus pelanggan yang memesan atau supir dari angkot
        $bookingUserId = $booking->id_pelanggan;
        $driverId = $booking->jadwal->angkot->id_supir;

        return $recipientId === $bookingUserId || $recipientId === $driverId;
    }
}

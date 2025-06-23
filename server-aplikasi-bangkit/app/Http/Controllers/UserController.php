<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use App\Models\User;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;
/**
 * @OA\Schema(
 *     schema="User",
 *     required={"id", "nama", "email", "peran", "created_at"},
 *     @OA\Property(property="id", type="integer", example=1),
 *     @OA\Property(property="nama", type="string", example="John Doe"),
 *     @OA\Property(property="email", type="string", format="email", example="john@example.com"),
 *     @OA\Property(property="peran", type="string", example="pelanggan"),
 *     @OA\Property(property="nomor_telepon", type="string", example="081234567890", nullable=true),
 *     @OA\Property(property="foto_profil", type="string", example="http://example.com/storage/profile.jpg", nullable=true),
 *     @OA\Property(property="created_at", type="string", format="date-time")
 * )
 */
class UserController extends Controller
{

    public function profile(Request $request)
    {
        // Kode method tetap sama
        $user = Auth::user();

        return response()->json([
            'id' => $user->id,
            'nama' => $user->nama,
            'email' => $user->email,
            'peran' => $user->peran,
            'nomor_telepon' => $user->nomor_telepon,
            'foto_profil' => $user->foto_profil ? asset('storage/'.$user->foto_profil) : null,
            'created_at' => $user->created_at
        ]);
    }


    public function updateProfile(Request $request)
    {
        // Kode method tetap sama
        $user = Auth::user();

        $validator = Validator::make($request->all(), [
            'nama' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:pengguna,email,'.$user->id.'|max:255',
            'password' => 'sometimes|min:6',
            'nomor_telepon' => 'sometimes|max:15',
            'foto_profil' => 'sometimes|image|mimes:jpeg,png,jpg|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 422);
        }

        $data = $request->only(['nama', 'email', 'nomor_telepon']);

        if ($request->hasFile('foto_profil')) {
            if ($user->foto_profil && Storage::exists('public/'.$user->foto_profil)) {
                Storage::delete('public/'.$user->foto_profil);
            }

            $path = $request->file('foto_profil')->store('profile_pictures', 'public');
            $data['foto_profil'] = $path;
        }

        if ($request->filled('password')) {
            $data['password'] = bcrypt($request->password);
        }

        $user->update($data);

        return response()->json([
            'message' => 'User updated successfully',
            'user' => [
                'id' => $user->id,
                'nama' => $user->nama,
                'email' => $user->email,
                'peran' => $user->peran,
                'nomor_telepon' => $user->nomor_telepon,
                'foto_profil' => $user->foto_profil ? asset('storage/'.$user->foto_profil) : null,
                'created_at' => $user->created_at
            ]
        ]);
    }
}

<?php

namespace Database\Seeders;

use App\Models\Pengguna;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class PenggunaSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $users = [
            [
                'nama' => 'Admin Sistem',
                'username' => 'admin_sistem',
                'email' => 'super_operator@angkotku.id',
                'password' => Hash::make('supersecret123'),
                'peran' => 'super_operator',
                'nomor_telepon' => '081234567890',
                'foto_profil' => null
            ],
            [
                'nama' => 'Operator Jakarta',
                'username' => 'operator',
                'email' => 'operator.jakarta@angkotku.id',
                'password' => Hash::make('operator123'),
                'peran' => 'operator',
                'nomor_telepon' => '082345678901',
                'foto_profil' => null
            ],
            [
                'nama' => 'Budi Supir',
                'username' => 'budi_supir',
                'email' => 'budi.supir@angkotku.id',
                'password' => Hash::make('supir123'),
                'peran' => 'supir',
                'nomor_telepon' => '083456789012',
                'foto_profil' => 'supir/budi.jpg'
            ],
            [
                'nama' => 'Ani Pelanggan',
                'username' => 'Ani',
                'email' => 'ani.pelanggan@gmail.com',
                'password' => Hash::make('pelanggan123'),
                'peran' => 'pelanggan',
                'nomor_telepon' => '084567890123',
                'foto_profil' => 'pelanggan/ani.jpg'
            ],
            [
                'nama' => 'Rudi Pelanggan',
                'username' => '',
                'email' => 'rudi.pelanggan@gmail.com',
                'password' => Hash::make('pelanggan123'),
                'peran' => 'pelanggan',
                'nomor_telepon' => '085678901234',
                'foto_profil' => null
            ]
        ];

        foreach ($users as $user) {
            Pengguna::create($user);
        }

        // // Generate 10 random pelanggan
        // Pengguna::factory()->count(10)->create([
        //     'peran' => 'pelanggan',
        //     'password' => Hash::make('pelanggan123')
        // ]);

        // // Generate 5 random supir
        // Pengguna::factory()->count(5)->create([
        //     'peran' => 'supir',
        //     'password' => Hash::make('supir123'),
        //     'foto_profil' => 'supir/'.fake()->uuid().'.jpg'
        // ]);
    }
}

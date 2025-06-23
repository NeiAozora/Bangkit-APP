<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class PenggunaFactory extends Factory
{
    public function definition()
    {
        return [
            'nama' => fake()->name(),
            'username' => fake()->unique()->userName(),
            'email' => fake()->unique()->safeEmail(),
            'password' => bcrypt('password'), // Default will be overridden
            'peran' => 'pelanggan', // Default will be overridden
            'nomor_telepon' => fake()->phoneNumber(),
            'foto_profil' => null,
        ];
    }
}

<?php

namespace Database\Seeders;

// use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Remove or comment out if you don't need default User factory
        // User::factory(10)->create();

        $this->call([
            PenggunaSeeder::class  // Changed from Pengguna::class to PenggunaSeeder::class
        ]);
    }
}

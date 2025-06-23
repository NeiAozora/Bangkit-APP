# FILE: app.py
# DEPENDENCIES: Flask, mysql-connector-python, Flask-Cors
# CARA MENJALANKAN: python app.py

import hashlib
import json
from flask import Flask, request, jsonify
from flask_cors import CORS
from mysql.connector import pooling

# --- Konfigurasi Aplikasi Flask ---
app = Flask(__name__)
# Mengaktifkan CORS untuk semua domain di semua rute.
# Ini penting agar aplikasi Flutter Web Anda bisa berkomunikasi dengan API ini.
CORS(app)

# --- Konfigurasi Koneksi Database ---
# Ganti dengan detail koneksi database Anda
DB_CONFIG = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': 'noxzan123',
    'database': 'bangkit',
}

# Membuat connection pool untuk efisiensi
try:
    db_pool = pooling.MySQLConnectionPool(pool_name="api_pool",
                                          pool_size=5,
                                          **DB_CONFIG)
    print("Pool koneksi database berhasil diinisialisasi.")
except Exception as e:
    print(f"Gagal menginisialisasi pool koneksi: {e}")
    exit()

# --- Fungsi Helper ---
def hash_password(password):
    """Menghasilkan hash SHA-256 dari string password."""
    return hashlib.sha256(password.encode('utf-8')).hexdigest()

def get_db_connection():
    """Mendapatkan koneksi dari pool."""
    try:
        return db_pool.get_connection()
    except Exception as e:
        print(f"Error mendapatkan koneksi dari pool: {e}")
        return None

# --- Rute (Endpoint) API ---

@app.route('/register', methods=['POST'])
def register_user():
    """Endpoint untuk mendaftarkan pengguna baru."""
    try:
        data = request.get_json()
        nama = data.get('nama')
        email = data.get('email')
        password = data.get('password')
        nomor_telepon = data.get('nomor_telepon')

        if not all([nama, email, password]):
            return jsonify({'error': 'Nama, email, dan password tidak boleh kosong.'}), 400

        db_conn = get_db_connection()
        if not db_conn:
            return jsonify({'error': 'Tidak bisa terhubung ke database.'}), 500

        cursor = db_conn.cursor(dictionary=True)

        # Cek apakah email sudah terdaftar
        cursor.execute("SELECT id FROM pengguna WHERE email = %s", (email,))
        if cursor.fetchone():
            cursor.close()
            db_conn.close()
            return jsonify({'error': 'Email sudah terdaftar.'}), 409 # 409 Conflict

        # Insert pengguna baru
        hashed_password = hash_password(password)
        query = """
            INSERT INTO pengguna (nama, email, password, peran, nomor_telepon)
            VALUES (%s, %s, %s, %s, %s)
        """
        cursor.execute(query, (nama, email, hashed_password, 'pelanggan', nomor_telepon))
        new_user_id = cursor.lastrowid
        db_conn.commit()

        # Ambil data pengguna yang baru dibuat untuk dikirim kembali
        cursor.execute("SELECT id, nama, email, peran, nomor_telepon, foto_profil FROM pengguna WHERE id = %s", (new_user_id,))
        new_user_data = cursor.fetchone()

        cursor.close()
        db_conn.close()

        if new_user_data:
            return jsonify(new_user_data), 200
        else:
            return jsonify({'error': 'Gagal mengambil data setelah registrasi.'}), 500

    except Exception as e:
        print(f"Error di /register: {e}")
        return jsonify({'error': f'Terjadi kesalahan pada server: {e}'}), 500


@app.route('/login', methods=['POST'])
def login_user():
    """Endpoint untuk login pengguna."""
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')

        if not all([email, password]):
            return jsonify({'error': 'Email dan password tidak boleh kosong.'}), 400

        db_conn = get_db_connection()
        if not db_conn:
            return jsonify({'error': 'Tidak bisa terhubung ke database.'}), 500

        cursor = db_conn.cursor(dictionary=True)

        hashed_password = hash_password(password)
        query = """
            SELECT id, nama, email, peran, nomor_telepon, foto_profil
            FROM pengguna WHERE email = %s AND password = %s
        """
        cursor.execute(query, (email, hashed_password))
        user_data = cursor.fetchone()

        cursor.close()
        db_conn.close()

        if user_data:
            return jsonify(user_data), 200
        else:
            return jsonify({'error': 'Email atau password salah.'}), 401 # 401 Unauthorized

    except Exception as e:
        print(f"Error di /login: {e}")
        return jsonify({'error': f'Gagal melakukan login: {e}'}), 500


# --- Menjalankan Server ---
if __name__ == '__main__':
    # host='0.0.0.0' membuat server bisa diakses dari luar jaringan lokal
    app.run(host='0.0.0.0', port=5000, debug=True)

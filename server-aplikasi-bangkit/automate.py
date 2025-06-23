import os
import re
from pathlib import Path

class LaravelRouteParser:
    def __init__(self, route_file_path, base_dir="app/Http/Controllers"):
        self.route_file_path = route_file_path
        self.base_dir = base_dir
        self.namespace_base = "App\\Http\\Controllers"
        self.controllers = {}

    def parse_routes(self):
        """Parsing file route untuk ekstrak informasi controller"""
        with open(self.route_file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Pola untuk mencocokkan definisi route
        route_pattern = r"Route::([a-z]+)\('([^']+)'\s*,\s*'(.*?)'(?:\s*,\s*.*?)*?\);"
        matches = re.finditer(route_pattern, content)

        for match in matches:
            http_method = match.group(1).upper()
            uri = match.group(2)
            controller_action = match.group(3)

            # Proses informasi controller
            if '@' in controller_action:
                controller_path, method = controller_action.split('@')
                self._process_controller(controller_path, method, http_method, uri)

    def _process_controller(self, controller_path, method_name, http_method, uri):
        """Proses informasi controller dan tambahkan ke struktur data"""
        # Tentukan namespace dan lokasi file
        parts = controller_path.split('/')
        controller_class = parts[-1]
        namespace_parts = parts[:-1] if len(parts) > 1 else []

        # Buat namespace relatif terhadap base namespace
        relative_namespace = "\\".join(namespace_parts) if namespace_parts else ""
        full_namespace = f"{self.namespace_base}\\{relative_namespace}".strip("\\")

        # Tentukan parameter dari URI
        parameters = []
        if '{' in uri:
            param_pattern = r'\{([^}/]+)'
            parameters = re.findall(param_pattern, uri)

        # Tambahkan ke struktur data
        key = f"{full_namespace}\\{controller_class}"
        if key not in self.controllers:
            self.controllers[key] = {
                'namespace': full_namespace,
                'class_name': controller_class,
                'methods': []
            }

        self.controllers[key]['methods'].append({
            'name': method_name,
            'http_method': http_method,
            'parameters': parameters,
            'uri': uri
        })

    def generate_controllers(self):
        """Hasilkan file controller berdasarkan hasil parsing"""
        for controller_key, controller_info in self.controllers.items():
            # Buat direktori berdasarkan namespace
            namespace_parts = controller_info['namespace'].replace(self.namespace_base, '').split('\\')
            if namespace_parts[0]:  # Jika ada subfolder
                controller_dir = os.path.join(self.base_dir, *namespace_parts)
            else:
                controller_dir = self.base_dir

            # Buat direktori jika belum ada
            os.makedirs(controller_dir, exist_ok=True)

            # Buat file controller
            file_path = os.path.join(controller_dir, f"{controller_info['class_name']}.php")

            if not os.path.exists(file_path):
                self._generate_controller_file(file_path, controller_info)
            else:
                self._update_controller_file(file_path, controller_info)

    def _generate_controller_file(self, file_path, controller_info):
        """Hasilkan file controller baru"""
        with open(file_path, 'w', encoding='utf-8') as f:
            # Tambahkan header PHP dan namespace
            f.write("<?php\n\n")
            f.write(f"namespace {controller_info['namespace']};\n\n")

            # Import dependencies
            f.write("use Illuminate\\Http\\Request;\n")
            f.write("use Illuminate\\Support\\Facades\\Validator;\n")
            f.write("use Illuminate\\Support\\Facades\\Response;\n")
            f.write("use App\\Http\\Controllers\\Controller;\n\n")

            # Deklarasi class
            f.write(f"class {controller_info['class_name']} extends Controller {{\n\n")

            # Tambahkan metode controller
            for method in controller_info['methods']:
                self._write_method(f, method)

            # Penutup class
            f.write("}\n")

    def _update_controller_file(self, file_path, controller_info):
        """Perbarui file controller yang sudah ada"""
        with open(file_path, 'r+', encoding='utf-8') as f:
            content = f.read()

            # Cari akhir class untuk menambahkan metode baru
            class_end_pos = content.rfind('}')

            if class_end_pos != -1:
                # Simpan isi sebelum akhir class
                new_content = content[:class_end_pos]

                # Tambahkan metode baru
                existing_methods = re.findall(r'public function (\w+)', content)
                for method in controller_info['methods']:
                    if method['name'] not in existing_methods:
                        new_content += "\n"
                        new_content += self._generate_method_string(method)

                # Tambahkan kembali akhir class
                new_content += "\n}"

                # Tulis konten baru
                f.seek(0)
                f.write(new_content)
                f.truncate()

    def _write_method(self, file_handle, method):
        """Tulis metode controller ke file"""
        file_handle.write(f"    // {method['uri']} [{method['http_method']}]\n")
        file_handle.write(f"    public function {method['name']}(Request $request")

        # Tambahkan parameter jika ada
        if method['parameters']:
            for param in method['parameters']:
                file_handle.write(f", ${param}")

        file_handle.write(") {\n")

        # Tambahkan badan metode dasar
        file_handle.write("        // TODO: Implement logic\n")
        file_handle.write("        return response()->json([\n")
        file_handle.write("            'status' => 'success',\n")
        file_handle.write("            'message' => 'Method implemented',\n")
        file_handle.write("        ]);\n")
        file_handle.write("    }\n\n")

    def _generate_method_string(self, method):
        """Hasilkan string metode controller"""
        method_str = f"\n    // {method['uri']} [{method['http_method']}]\n"
        method_str += f"    public function {method['name']}(Request $request"

        # Tambahkan parameter jika ada
        if method['parameters']:
            for param in method['parameters']:
                method_str += f", ${param}"

        method_str += ") {\n"
        method_str += "        // TODO: Implement logic\n"
        method_str += "        return response()->json([\n"
        method_str += "            'status' => 'success',\n"
        method_str += "            'message' => 'Method implemented',\n"
        method_str += "        ]);\n"
        method_str += "    }\n"

        return method_str

# Penggunaan
if __name__ == "__main__":
    parser = LaravelRouteParser("routes/api.php")  # Ganti dengan path file route Anda
    parser.parse_routes()
    parser.generate_controllers()

    print(f"Berhasil menghasilkan {len(parser.controllers)} controller")
    print(f"Struktur folder dan namespace telah dibuat di {parser.base_dir}")

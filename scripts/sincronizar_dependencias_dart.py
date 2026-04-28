import os
import subprocess

def run_command(command, cwd):
    print(f"Running '{command}' in '{cwd}'...")
    result = subprocess.run(command, cwd=cwd, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error in {cwd}:")
        print(result.stdout)
        print(result.stderr)
        return False
    print("Success.")
    return True

def sync_and_analyze_package(package_root):
    # Detectar si el paquete usa Flutter o es miembro de un workspace
    pubspec_path = os.path.join(package_root, 'pubspec.yaml')
    is_flutter = False
    is_workspace_member = False
    if os.path.exists(pubspec_path):
        with open(pubspec_path, 'r') as f:
            content = f.read()
            if 'sdk: flutter' in content:
                is_flutter = True
            if 'resolution: workspace' in content:
                is_workspace_member = True
    
    # Ejecutar pub get solo si NO es miembro de un workspace (el root se encarga)
    if not is_workspace_member:
        pub_cmd = "flutter pub get" if is_flutter else "dart pub get"
        if not run_command(pub_cmd, package_root):
            return False
    else:
        print(f"Skipping 'pub get' in {package_root} (Workspace member)")
    
    # Ejecutar analyze
    if not run_command("dart analyze .", package_root):
        return False
        
    return True

def process_all_packages(start_dir):
    for root, dirs, files in os.walk(start_dir):
        # Ignorar directorios de caché, ocultos y build
        dirs[:] = [d for d in dirs if not d.startswith('.') and d != 'build']
        if 'pubspec.yaml' in files:
            if not sync_and_analyze_package(root):
                exit(1)

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    projects_melos = ['binance_dart_sdk', 'AshCandleChart', 'CryptBot']
    project_flutter = 'Iron Widgets'

    # Iron Widgets
    print("\n=== Sincronizando Iron Widgets ===")
    iw_path = os.path.join(base_dir, project_flutter)
    if not run_command("flutter clean", iw_path): exit(1)
    process_all_packages(iw_path)

    # Melos projects
    for project in projects_melos:
        print(f"\n=== Sincronizando {project} ===")
        proj_path = os.path.join(base_dir, project)
        if not run_command("melos clean", proj_path): exit(1)
        if not run_command("melos bs", proj_path): exit(1)
        
        # Verificar si el proyecto tiene el script 'build' configurado antes de ejecutarlo
        pubspec_path = os.path.join(proj_path, "pubspec.yaml")
        if os.path.exists(pubspec_path):
            with open(pubspec_path, "r") as f:
                content = f.read()
                if "build:" in content:
                    if not run_command("melos run build --no-select", proj_path): exit(1)

        process_all_packages(proj_path)

    print("\n" + "="*50)
    print("ÉXITO: Todos los paquetes han ejecutado 'pub get' y 'analyze'.")
    print("="*50)

if __name__ == '__main__':
    main()

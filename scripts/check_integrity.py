import subprocess
import os
import sys
import re

# PROTECTED: No cambiar versiones ni flujos de CI sin justificacion en PR_JUSTIFICATION.md

def run_command(command, cwd=None):
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True, cwd=cwd)
        return result.stdout.strip()
    except Exception:
        return None

def get_modified_files(base_branch="origin/main"):
    # Intentar obtener archivos modificados respecto a la rama base
    files = run_command(["git", "diff", "--name-only", base_branch])
    if files is None:
        files = run_command(["git", "diff", "--name-only", "HEAD~1"])
    return files.split("\n") if files else []

def check_pubspec_versions(file_path, base_branch="origin/main"):
    diff = run_command(["git", "diff", base_branch, "--", file_path])
    if not diff:
        diff = run_command(["git", "diff", "HEAD~1", "--", file_path])
    
    if not diff: return False
    
    # Detectar cambios en líneas de versión (dependencies, dev_dependencies, overrides)
    version_pattern = re.compile(r"^[+-]\s+[\w_-]+:\s+[\^><=~\d]")
    lines = diff.split("\n")
    for line in lines:
        if version_pattern.match(line):
            return True
    return False

def main():
    print(f"--- [LOCAL] Chequeo de Integridad: {os.path.basename(os.getcwd())} ---")
    
    base_branch = os.environ.get("BASE_BRANCH", "origin/main")
    modified_files = get_modified_files(base_branch)
    
    violations = []
    justification_required = False
    
    for f in modified_files:
        if not f: continue
        
        if f.endswith("pubspec.yaml"):
            if check_pubspec_versions(f, base_branch):
                print(f"  [!] Cambio en versiones: {f}")
                justification_required = True
                violations.append(f)
        
        elif f.endswith("CHANGELOG.md"):
            # Regla de Vigilancia Temporal: No permitir años obsoletos
            with open(f, 'r') as jf:
                content = jf.read()
                if "2024-" in content or "2025-" in content:
                    print(f"  [!] ERROR TEMPORAL: Se detectaron fechas obsoletas (2024/2025) en {f}.")
                    justification_required = True
                    violations.append(f)

    if justification_required:
        justification_file = "PR_JUSTIFICATION.md"
        if not os.path.exists(justification_file):
            print(f"\n[ERROR] Se requieren justificaciones. Crea '{justification_file}' explicando los cambios.")
            sys.exit(1)
        else:
            with open(justification_file, "r") as jf:
                if len(jf.read().strip()) < 20:
                    print(f"[ERROR] '{justification_file}' es insuficiente (mínimo 20 caracteres).")
                    sys.exit(1)
            print(f"[OK] Cambios justificados en '{justification_file}'.")
    else:
        print("[OK] Integridad verificada.")

if __name__ == "__main__":
    main()

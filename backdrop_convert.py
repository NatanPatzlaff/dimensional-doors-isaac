"""
backdrop_convert.py — Conversor de arte para o formato de backdrop do StageAPI/Isaac

O StageAPI espera spritesheets no mesmo formato do jogo vanilla:
  - Um arquivo PNG de 468x468 pixels (igual ao 01_Basement.png do jogo)
  - Contém tanto paredes quanto chão no mesmo arquivo
  - O StageAPI usa WallBackdrop.anm2 e FloorBackdrop.anm2 internamente para
    fazer os crops corretos a partir desse formato

Não é necessário fatiar manualmente! Basta converter a arte para 468x468 RGBA.

Uso:
    python3 backdrop_convert.py <arquivo_de_entrada.png> <nome_da_dimensao>

Exemplos:
    python3 backdrop_convert.py minha_arte.png land_of_ooo
    python3 backdrop_convert.py castle_art.png infinity_castle
"""

import os
import sys
from PIL import Image

PROJECT_DIR = os.path.dirname(os.path.abspath(__file__))

# Dimensão exata esperada pelo StageAPI (mesmo formato do 01_Basement.png vanilla)
TARGET_SIZE = (468, 468)
TARGET_MODE = "RGBA"

def convert_backdrop(input_path: str, dimension_name: str):
    """
    Converte uma imagem de arte para o formato correto de backdrop do StageAPI.
    
    - Redimensiona para 468x468 (formato vanilla do Isaac)
    - Converte para RGBA (necessário para transparência e compatibilidade)
    - Salva como <dimension_name>_style.png na pasta correta
    """
    output_dir = os.path.join(PROJECT_DIR, "resources", "gfx", "backdrop", dimension_name)
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, f"{dimension_name}_style.png")

    if not os.path.exists(input_path):
        print(f"ERRO: Arquivo de entrada não encontrado: {input_path}")
        return False

    print(f"Carregando: {input_path}")
    with Image.open(input_path) as img:
        original_size = img.size
        print(f"  Tamanho original: {original_size}")

        # Converter para RGBA
        img = img.convert(TARGET_MODE)

        # Redimensionar para 468x468 se necessário
        if img.size != TARGET_SIZE:
            print(f"  Redimensionando de {img.size} para {TARGET_SIZE} (Lanczos)...")
            img = img.resize(TARGET_SIZE, Image.LANCZOS)

        img.save(output_path, "PNG")
        print(f"  Salvo em: {output_path}")
        print(f"  Tamanho final: {img.size}, modo: {img.mode}")
        return True


def list_dimensions():
    """Lista as dimensões disponíveis e seus arquivos de backdrop."""
    backdrop_dir = os.path.join(PROJECT_DIR, "resources", "gfx", "backdrop")
    if not os.path.exists(backdrop_dir):
        print("Pasta de backdrops não encontrada.")
        return

    print("\nDimensões disponíveis:")
    for name in sorted(os.listdir(backdrop_dir)):
        dim_dir = os.path.join(backdrop_dir, name)
        if os.path.isdir(dim_dir):
            files = [f for f in os.listdir(dim_dir) if f.endswith(('.png', '.jpg', '.jpeg'))]
            print(f"  {name}/")
            for f in sorted(files):
                path = os.path.join(dim_dir, f)
                with Image.open(path) as img:
                    marker = "✓" if img.size == TARGET_SIZE else "✗"
                    print(f"    [{marker}] {f} — {img.size}")
    print()
    print(f"  [✓] = Formato correto ({TARGET_SIZE[0]}x{TARGET_SIZE[1]})")
    print(f"  [✗] = Formato incorreto (precisa converter)")


def main():
    if len(sys.argv) == 1:
        print(__doc__)
        list_dimensions()
        return

    if len(sys.argv) != 3:
        print("Uso: python3 backdrop_convert.py <arquivo_de_entrada.png> <nome_da_dimensao>")
        sys.exit(1)

    input_path = sys.argv[1]
    dimension_name = sys.argv[2]

    success = convert_backdrop(input_path, dimension_name)
    if success:
        print()
        print(f"Pronto! Adicione ao main.lua:")
        print(f"  local {dimension_name}Backdrop = {{")
        print(f"      Walls  = {{\"gfx/backdrop/{dimension_name}/{dimension_name}_style.png\"}},")
        print(f"      Floors = {{\"gfx/backdrop/{dimension_name}/{dimension_name}_style.png\"}},")
        print(f"  }}")


if __name__ == "__main__":
    main()

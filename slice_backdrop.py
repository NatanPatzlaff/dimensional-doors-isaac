import os
from PIL import Image

def slice_and_generate():
    project_dir = r"c:\Program Files (x86)\Steam\steamapps\common\The Binding of Isaac Rebirth\mods\dimensional-doors-isaac"
    ooo_dir = os.path.join(project_dir, "resources", "gfx", "backdrop", "land_of_ooo")
    
    vanilla_path = os.path.join(ooo_dir, "vanilla_style.png")
    wall_path = os.path.join(ooo_dir, "wall.png")
    corner_path = os.path.join(ooo_dir, "corner.png")
    
    if not os.path.exists(vanilla_path):
        print(f"ERRO: {vanilla_path} não encontrado!")
        return
        
    print(f"Carregando {vanilla_path}...")
    with Image.open(vanilla_path) as vanilla:
        vanilla = vanilla.convert("RGBA")
        vw, vh = vanilla.size
        
        # 1. GERAR A IMAGEM DE PAREDE (wall.png) - 1024x512
        # Extrai a parede superior do cenário clássico. Em 468x468, a parede superior
        # com os detalhes de colinas/céu fica nos primeiros 128 pixels verticais.
        wall_texture = vanilla.crop((0, 0, vw, 128))
        wt_w, wt_h = wall_texture.size
        
        # Criar a imagem de destino para as paredes (1024x512)
        wall_img = Image.new("RGBA", (1024, 512))
        
        # Tilar (repetir) a textura de parede na imagem de 1024x512
        for y in range(0, 512, wt_h):
            for x in range(0, 1024, wt_w):
                wall_img.paste(wall_texture, (x, y))
                
        # Salvar a imagem de parede gerada
        wall_img.save(wall_path, "PNG")
        print(f"Sucesso: {wall_path} gerado! (1024x512)")
        
        # 2. GERAR A IMAGEM DE CANTO (corner.png) - 256x256
        # Extrai a seção de canto superior esquerdo do cenário clássico (128x128)
        corner_texture = vanilla.crop((0, 0, 128, 128))
        
        # Criar a imagem de destino para o canto (256x256)
        corner_img = Image.new("RGBA", (256, 256))
        
        # Tilar ou redimensionar para preencher o canto
        ct_w, ct_h = corner_texture.size
        for y in range(0, 256, ct_h):
            for x in range(0, 256, ct_w):
                corner_img.paste(corner_texture, (x, y))
                
        # Salvar a imagem de canto gerada
        corner_img.save(corner_path, "PNG")
        print(f"Sucesso: {corner_path} gerado! (256x256)")
        
        # 3. GERAR O CHÃO (nfloor.png) - 520x416 por espelhamento do nfloor_backup.png (260x208)
        nfloor_backup_path = os.path.join(ooo_dir, "nfloor_backup.png")
        if os.path.exists(nfloor_backup_path):
            print(f"Carregando {nfloor_backup_path} para gerar nfloor.png com espelhamento...")
            with Image.open(nfloor_backup_path) as backup_img:
                backup_img = backup_img.convert("RGBA")
                
                # Criar imagem nfloor de 520x416
                nfloor_img = Image.new("RGBA", (520, 416))
                
                # Obter as fatias espelhadas
                top_left = backup_img
                top_right = backup_img.transpose(Image.FLIP_LEFT_RIGHT)
                bottom_left = backup_img.transpose(Image.FLIP_TOP_BOTTOM)
                bottom_right = backup_img.transpose(Image.FLIP_LEFT_RIGHT).transpose(Image.FLIP_TOP_BOTTOM)
                
                # Colar nos quadrantes
                nfloor_img.paste(top_left, (0, 0))
                nfloor_img.paste(top_right, (260, 0))
                nfloor_img.paste(bottom_left, (0, 208))
                nfloor_img.paste(bottom_right, (260, 208))
                
                nfloor_path = os.path.join(ooo_dir, "nfloor.png")
                nfloor_img.save(nfloor_path, "PNG")
                print(f"Sucesso: {nfloor_path} gerado com espelhamento contínuo!")
        else:
            print(f"AVISO: {nfloor_backup_path} não encontrado, pulando nfloor.png")
            
        # 4. GERAR O OVERLAY DO CHÃO (lfloor.png) - 520x416 por espelhamento do lfloor_clean.png
        lfloor_clean_path = os.path.join(ooo_dir, "lfloor_clean.png")
        lfloor_path = os.path.join(ooo_dir, "lfloor.png")
        if os.path.exists(lfloor_clean_path):
            print(f"Carregando {lfloor_clean_path} para gerar versão espelhada...")
            with Image.open(lfloor_clean_path) as lfloor_orig:
                lfloor_orig = lfloor_orig.convert("RGBA")
                
                # Extrair quadrante superior esquerdo (260x208) como base
                lfloor_base = lfloor_orig.crop((0, 0, 260, 208))
                
                # Criar imagem lfloor de 520x416
                lfloor_img = Image.new("RGBA", (520, 416))
                
                # Obter fatias espelhadas
                top_left = lfloor_base
                top_right = lfloor_base.transpose(Image.FLIP_LEFT_RIGHT)
                bottom_left = lfloor_base.transpose(Image.FLIP_TOP_BOTTOM)
                bottom_right = lfloor_base.transpose(Image.FLIP_LEFT_RIGHT).transpose(Image.FLIP_TOP_BOTTOM)
                
                # Colar nos quadrantes
                lfloor_img.paste(top_left, (0, 0))
                lfloor_img.paste(top_right, (260, 0))
                lfloor_img.paste(bottom_left, (0, 208))
                lfloor_img.paste(bottom_right, (260, 208))
                
                lfloor_img.save(lfloor_path, "PNG")
                print(f"Sucesso: {lfloor_path} gerado com espelhamento contínuo!")
        else:
            print(f"AVISO: {lfloor_clean_path} não encontrado, pulando lfloor.png")

if __name__ == "__main__":
    slice_and_generate()

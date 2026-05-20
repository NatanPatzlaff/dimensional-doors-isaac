# 🚪 Dimensional Doors Isaac - Resumo de Transição

Este arquivo foi gerado para que você possa continuar o desenvolvimento perfeitamente do seu PC de casa. 

## 🛠️ O que foi feito até agora:
1. **Comandos de Spawn e Teste**: 
   - Criamos funções globais `lua DD.goto1()` (Land of Ooo) e `lua DD.goto2()` (Infinity Castle) para teletransportar o jogador direto para as dimensões sem precisar procurar os portais, facilitando muito o debug.
2. **Correção do Bug do StageAPI**: 
   - Movemos a inicialização do `CustomStage` e das `RoomsList` para fora do callback de início do jogo (para o escopo global do `main.lua`). Isso resolveu o problema do mod crashar quando a gente recarregava com `luamod dimensional-doors-isaac`.
   - Corrigimos o bug `table index is nil` que acontecia no `SetRoomGfx` passando explicitamente quais tipos de sala devem receber o visual customizado.
3. **Exemplos Vanillas Extraídos**: 
   - Usamos o `resource_extractor` nativo do Linux para puxar os gráficos originais compactados (`graphics.a`). 
   - Criamos a pasta `examples/` que agora contém os cenários clássicos originais (`01_basement.png`, `02_cellar.png`, etc.) com suas proporções perfeitas de `468x468` pixels. Você pode usar eles como referência milimétrica.
4. **Cenário de Hora de Aventura (Land of Ooo)**:
   - Identificamos que a imagem gerada por IA estava em alta resolução (`1024x1024`) mas mantinha a estrutura correta (clássica) do Isaac, em que paredes e chão ficam no mesmo arquivo.
   - Redimensionamos ela perfeitamente (usando o algoritmo *Lanczos*) para a proporção original do jogo base (`468x468`). 
   - A imagem ajustada está pronta para uso em: `resources/gfx/backdrop/land_of_ooo/vanilla_style.png`.

## 🚀 Próximos Passos (Para fazer em casa):
Quando você abrir o projeto no PC de casa, a próxima missão é aplicar a imagem `vanilla_style.png` no cenário do *Land of Ooo*. 

Você pode escolher uma de duas abordagens:
1. **Padrão Vanilla**: Mudar o arquivo `main.lua` para fazer o `StageAPI` carregar o arquivo único.
2. **Padrão Moderno (Fatiado)**: Usar o Aseprite ou Photoshop (ou me pedir para fazer isso via script) para recortar o `vanilla_style.png` nas 4 fatias que o StageAPI já está esperando (`nfloor.png`, `lfloor.png`, `wall.png`, `corner.png`).

---
**Bom descanso no trabalho e boa codificação em casa!** 🎮

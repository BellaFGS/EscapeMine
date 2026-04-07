# 🎮 EscapeMine

## 📌 Introdução
**EscapeMine** é um jogo 2D desenvolvido na Godot onde o jogador deve sobreviver em uma arena infestada de criaturas hostis enquanto busca uma forma de escapar. O foco do jogo está no combate, sobrevivência e progressão de dificuldade ao longo do tempo.

---

## 📖 História
Lucas, um engenheiro industrial, foi contratado para realizar a manutenção de um sistema em uma empresa. Durante o trabalho, ele acaba sofrendo um acidente e cai em um buraco desconhecido.

Ao recobrar a consciência, Lucas se encontra preso em uma mina abandonada, habitada por criaturas famintas. Sem saída aparente, ele descobre uma única porta trancada.

A única forma de escapar é encontrar a chave que abre essa porta — e para isso, será necessário enfrentar e derrotar os monstros que habitam o local.

---

## ⚙️ Engine e Mecânica
O jogo foi desenvolvido utilizando a engine **Godot 4.6.1**, com as seguintes características:

- Sistema de classes com herança (`Character`, `Player`, `Enemy`)
- Uso de **Singleton (GameManager)** para controle global
- Comunicação via **signals** entre HUD, Player e lógica do jogo
- Sistema de combate baseado em:
  - **Hitbox** (ataque do jogador)
  - **Hurtbox** (recebimento de dano)
- Sistema de **drop aleatório de itens**:
  - Poção de vida
  - Aumento de dano
  - Chave (item raro)
- **Dificuldade dinâmica**, aumentando com o tempo

---

## 🎯 Jogabilidade
- Controle o personagem em uma arena estática
- Enfrente inimigos que surgem continuamente
- Colete itens para sobreviver e evoluir
- O objetivo é encontrar a chave e escapar

### Condições de fim de jogo:
- ☠️ Derrota: jogador morre  
- ⏳ Progressão: inimigos ficam mais fortes com o tempo  
- 🗝️ Vitória: jogador pega a chave e abre a porta  

---

## 👥 Créditos
Desenvolvedora **BellaFGS**
Co-Desenvolvedor **Thomas-1610**
Animadora **https://www.instagram.com/tn.a7ex/**

Projeto desenvolvido como prática em desenvolvimento de jogos utilizando Godot.

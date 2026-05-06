# 🎮 EscapeMine

## 📌 Introdução
**EscapeMine** é um jogo 2D desenvolvido na Godot na qual o jogador em como objetivo, conseguir pegar a chave e escapar da mina enquanto enfrenar inimigos hostis e bombas!

---

## 📖 História
Lucas, um engenheiro industrial certo dia acordou com seu despertador e foi trabalhar. Porém, um tanto distraído, acabou caindo dentro de um buraco e agora se encontra em uma mina abandonada cercado por criauras... E sua unica saída é uma porta que está trancada.

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
Desenvolvedora e Gestora de projetos **BellaFGS**
Desenvolvedor e Desing **Thomas-1610**
Desenvolvedor **Oroboni (Matheus Cuero)**
Artista de animação **https://www.instagram.com/tn.a7ex/**

Projeto desenvolvido como prática em desenvolvimento de jogos utilizando Godot.

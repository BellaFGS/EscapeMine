class_name AttackStrategy
extends RefCounted

## Classe base do padrão Strategy para os ataques do boss.
## Cada ataque concreto (melee, dash, invocar minions...) deve
## herdar dessa classe e implementar executar().

var nome: String = "Estrategia Base"

## Distância mínima e máxima (em pixels) em que essa estratégia pode ser escolhida
var alcance_min: float = 0.0
var alcance_max: float = 999999.0

## Tempo de recarga (segundos) antes da estratégia poder ser usada de novo
var cooldown: float = 2.0

var _tempo_desde_uso: float = 999999.0


## Chamado todo _physics_process pelo Boss para avançar o cooldown
func atualizar_cooldown(delta: float) -> void:
	_tempo_desde_uso += delta


## Reseta o cooldown - chamar no início de executar()
func resetar_cooldown() -> void:
	_tempo_desde_uso = 0.0


## Diz se essa estratégia pode ser usada agora (distância + cooldown + estado do boss)
func pode_executar(boss, distancia: float) -> bool:
	if boss.esta_morto or boss.is_attack:
		return false
	if _tempo_desde_uso < cooldown:
		return false
	return distancia >= alcance_min and distancia <= alcance_max


## Executa o ataque. Deve ser sobrescrito pelas subclasses.
## É async (usa await) porque a maioria dos ataques tem janelas de tempo
## (tempo de "cast", ativar/desativar hitbox, duração da animação etc).
func executar(boss) -> void:
	push_error("BossAttackStrategy.executar() não implementado em: " + nome)

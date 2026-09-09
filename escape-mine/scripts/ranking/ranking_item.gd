extends HBoxContainer

@onready var data: Label = $BoxContainer/MarginContainer/HSplitContainer/Data
@onready var nome: Label = $BoxContainer/MarginContainer/HSplitContainer/Nome
@onready var pontuacao: Label = $BoxContainer/MarginContainer/HSplitContainer/Pontuacao
@onready var resultado: Label = $BoxContainer/MarginContainer/HSplitContainer/Resultado


func configurar(dados: Dictionary) -> void:
	nome.text = str(dados.get("nome", ""))
	data.text = str(dados.get("data", ""))
	pontuacao.text = str(dados.get("pontos", 0))
	resultado.text = str(dados.get("resultado", ""))

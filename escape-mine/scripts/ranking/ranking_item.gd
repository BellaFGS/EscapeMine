extends HBoxContainer

@onready var nome_label: Label = $Nome
@onready var data_label: Label = $Data
@onready var pontuacao_label: Label = $Pontuacao
@onready var resultado_label: Label = $Resultado


func configurar(dados: Dictionary) -> void:
	nome_label.text = str(dados.get("nome", ""))
	data_label.text = str(dados.get("data", ""))
	pontuacao_label.text = str(dados.get("pontos", 0))
	resultado_label.text = str(dados.get("resultado", ""))

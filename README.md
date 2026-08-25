# CineFavorite

Aplicativo Flutter para pesquisar filmes e séries, visualizar sinopses, criar perfis e manter uma lista pessoal de títulos para avaliar.

## Funcionalidades

- Busca de filmes e séries usando a API do TMDB.
- Grade de pôsteres com nota e imagem alternativa quando o pôster não está disponível.
- Sinopse ao tocar em um título.
- Minha Lista persistida em SQLite.
- Avaliação de títulos salvos de 0 a 10.
- Criação, troca e exclusão de perfis no estilo Netflix.
- Favoritos separados para cada perfil.
- Tema escuro inspirado em serviços de streaming, com vermelho e azul como cores de destaque.


Pré-requisitos:

Comandos:

```bash
flutter pub get
flutter analyze

## Configuração da API

A chave está configurada em `lib/services/tmdb_service.dart`, na constante `_apiKey`. Para publicar o aplicativo, mova essa chave para uma configuração segura e não a versiona em um repositório público.

## Estrutura principal

```text
lib/
	main.dart
	database/db_helper.dart
	models/movie.dart
	services/tmdb_service.dart
	views/
		favorites_screen.dart
		home_screen.dart
		login_screen.dart
		profiles_screen.dart
		search_screen.dart
test/
	widget_test.dart
```

## Banco de dados

O banco local é criado automaticamente na primeira execução. As atualizações de esquema são aplicadas pelo `DBHelper`, preservando os favoritos existentes durante as migrações.
# filmsc

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

	widget_test.dart

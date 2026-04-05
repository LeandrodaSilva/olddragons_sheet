# ods

OldDragons Sheet

## Inicialização do projeto

### Pré-requisitos

- Flutter SDK 3.22+ instalado e no `PATH`
- Dart SDK (incluído com Flutter)
- Android Studio e/ou Xcode (para rodar mobile)
- Chrome (para rodar web)

### 1) Instalar dependências

```bash
flutter pub get
```

### 2) Verificar ambiente Flutter

```bash
flutter doctor
```

### 3) Rodar o projeto

```bash
flutter run
```

> Dica: para rodar no Chrome use `flutter run -d chrome`.

### 4) Rodar testes

```bash
flutter test
```

## Comandos úteis com Makefile

Este repositório inclui um `Makefile` para facilitar a inicialização:

```bash
make init      # instala dependências e valida ambiente
make test      # executa testes
make run-web   # executa no Chrome
```

## Recursos Flutter

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Documentação oficial](https://docs.flutter.dev/)

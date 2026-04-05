.PHONY: init deps doctor test run run-web

deps:
	flutter pub get

doctor:
	flutter doctor

init: deps doctor

test:
	flutter test

run:
	flutter run

run-web:
	flutter run -d chrome

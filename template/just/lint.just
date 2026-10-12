# Run all linters, or a single one by its pre-commit hook id
[group('lint')]
lint hook="":
    pre-commit run --all-files {{ hook }}

---
paths:
  - "**/*.py"
---

# Python Development Rules

1. My testing framework is pytest
2. Don't modify any files in ARCHIVE/ or Archive/
3. When working in a project managed with `uv`, use it to manage dependencies and run tests. For example, set up a virtual environment with `uv sync --all-extras` and activate it with `source .venv/bin/activate`. Alternatively, you can run tests directly with `uv run` such as `uv run pytest`.
4. All python class, methods, and functions should have docstrings
5. Use type hints for all function parameters and return values
6. Use f-strings for string formatting
7. Use `rich` for console output
8. Imports should also be at the top of the file
9. Use python named expressions (:=) when appropriate

# colcon runs from the uv venv when there is one, so entry points use its interpreter
python := if path_exists(justfile_directory() / ".venv/bin/python") == "true" { justfile_directory() / ".venv/bin/python" } else { "python3" }

# Install the dependencies of the packages in src/
[group('ros')]
deps:
    sudo apt-get update
    rosdep update
    rosdep install --from-paths src --ignore-src -y
    if [ -f pyproject.toml ]; then uv sync; fi

# Build the workspace
[group('ros')]
build *args:
    {{ python }} -m colcon build --symlink-install {{ args }} --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# Run the workspace tests
[group('ros')]
test *args:
    {{ python }} -m colcon test --event-handlers console_direct+ {{ args }}
    {{ python }} -m colcon test-result --verbose

# Remove colcon build artifacts
[group('ros')]
clean:
    rm -rf build install log

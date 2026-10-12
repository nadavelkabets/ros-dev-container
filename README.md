# ros-dev-container

A [Copier](https://copier.readthedocs.io) template for ROS 2 development in a VS Code dev container.

What a generated project gets:

- A dev container for the ROS 2 distribution you choose: humble, jazzy, kilted, lyrical or rolling
- [just](https://just.systems) recipes to build, test and lint (`justfile` and `just/`)
- Linting through pre-commit: ruff, mypy, shellcheck, shfmt, hadolint, yamllint, actionlint, tombi and codespell
- Optional: an ArduPilot simulation (SITL at the Copter release you pick, Mission Planner and MAVROS containers)
- Optional: a Gazebo mode for the simulation through the ardupilot_gazebo plugin, with Ogre 1 rendering for VMs on Apple
  Silicon
- Optional: access to the host's docker from the container (always on with the ArduPilot simulation)
- Optional: a uv-managed `.venv` for pip-only Python dependencies that still sees the ROS packages
- Optional: Claude Code in the container, with its config kept in a docker volume
- Optional: a GitHub Actions workflow that lints, builds and tests inside the dev container
- Optional: the ros2-testing apt repository, and extra VS Code extensions

## Usage

Install Copier with `uv tool install copier` or `pipx install copier`, then generate a project:

```bash
copier copy gh:nadavelkabets/ros-dev-container my_project
```

Copier asks the template's questions (see `copier.yml`) and records the answers in `.copier-answers.yml`. To pull in
later template changes, or to change an answer, run this from the generated project:

```bash
copier update
```

The generated project's `README.md` covers working with it.

## Layout

- `copier.yml`: the questions
- `template/`: the files a project is generated from. Files ending in `.jinja` are rendered, and paths like
  `{% if ardupilot %}sim.just{% endif %}` are only generated when the condition holds.

## Testing the template

CI (`.github/workflows/ci.yml`) renders projects with several option combinations, lints them, and builds and tests
a ROS package inside their dev containers. The template repository's own files are linted with pre-commit.

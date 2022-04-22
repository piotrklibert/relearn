# pyright: strict

Lines = list[str]

pyproject = open("script.toml").readlines()


def clean(lines: Lines) -> Lines:
    return list(filter(lambda x: x and not x.startswith("#"), map(str.strip, lines)))

def rm_versions(lines: Lines) -> Lines:
    return [x.split(" = ")[0] for x in lines]

def show(lines: list[str]) -> None:
    for line in lines:
        print(line)


pyproject_lines = rm_versions(clean(pyproject))
deps_loc = pyproject_lines.index("[tool.poetry.dependencies]")
devdeps_loc = pyproject_lines.index("[tool.poetry.dev-dependencies]")
devdeps_end = pyproject_lines.index("[build-system]")

deps = pyproject_lines[deps_loc + 1:devdeps_loc - 1]
devdeps = pyproject_lines[devdeps_loc + 1:devdeps_end]

# show(deps)

requirements = clean(open("script.txt").readlines())
versions = {}

for ver in requirements:
    if "==" in ver:
        k, v = ver.split("==")
    elif "@" in ver:
        k, _ = ver.split("@")
        v = ""
    versions[k.lower().strip()] = v.strip()

for dep in sorted(devdeps):
    ver = versions.get(dep.lower())
    if not ver:
        print(dep)
    else:
        print(f"{dep}=={ver}")
# print(versions)

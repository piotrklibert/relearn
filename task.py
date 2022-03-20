# pyright: strict

Lines = list[str]

pyproject = open("pyproject.toml").readlines()


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

deps = pyproject_lines[deps_loc + 1:devdeps_loc - 1]
devdeps = pyproject_lines[devdeps_loc + 1:]

# show(deps)

requirements = clean(open("requirements.txt").readlines())
versions = {}

for ver in requirements:
    k, v = ver.split("==")
    versions[k.lower()] = v

for dep in devdeps:
    ver = versions.get(dep.lower())
    if not ver:
        print(dep)
    else:
        print(f"{dep}=={ver}")
# print(versions)

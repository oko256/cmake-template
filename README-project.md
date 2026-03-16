# x_PROJECT_NAME_x

## Setting up for development

Install the following tools:

```bash
sudo apt install build-essential cmake cppcheck clang-tidy-19 lcov pipx ninja-build
pipx install fastcov
```

> [!IMPORTANT]
> **Clang-tidy version 19 or newer is required!** The example above installs clang-tidy-19,
> but if your package repository has newer version, for example as `clang-tidy` (without version
> suffix), you can install that one instead.

Check `dependencies.cmake` for any extra dependencies that you should install before proceeding.

For development, you want to turn on the following CMake options:

- `x_NAME_x_DEVELOPER_MODE=ON`
- `x_NAME_x_BUILD_TESTING=ON`
- `x_NAME_x_COVERAGE=ON` (if you also want code coverage reporting, see details below)

It is recommended (but not required) to use *Ninja* (`apt install ninja-build`) generator with
CMake for faster builds. Also, interface like `ccmake` or `cmake-gui` is convenient for configuring
CMake options interactively.

```bash
mkdir build
cd build
# Then pick one of the following according to your preference:
# 1. Text-based interface:
ccmake -G Ninja ..
# 2. Graphical interface:
cmake-gui ..
# 3. Command line options:
cmake -Dx_NAME_x_DEVELOPER_MODE=ON -Dx_NAME_x_BUILD_TESTING=ON -Dx_NAME_x_COVERAGE=ON -G Ninja ..
# And depending if you used Ninja or not, build with:
ninja -jN
# or
make -jN
```

You can run unit tests (or run unit tests and create code coverage report if you enabled it in
CMake options) like so:

```bash
# Just run the unit tests:
ctest

# Or run unit tests and generate code coverage report:
ninja coverage
# or
make coverage
```

## Building a release

Install the following tools:

```bash
sudo apt install build-essential cmake ninja-build
```

Check `dependencies.cmake` for any extra dependencies that you should install before proceeding.

Easiest way to do this is to use CMake presets. You can check `CMakePresets.json` file to see
the exact options used for releases in this project.

Just run the following in the project root directory (make sure `build` directory does not exist
already):

```bash
cmake --preset release && cmake --build --preset release
```

You can also configure and build the release manually in the same way as above, just make sure
to set CMake options according to release preset in `CMakePresets.json`.

## Building documentation

After configuring your build, run the following commands in your build directory:

```bash
ninja doc
# or
make doc
# And then the documentation is generated to "html" directory:
xdg-open html/index.html
```

## CMake options

| Option                         | Description |
|--------------------------------|-------------|
| `x_NAME_x_BUILD_TESTING`       | Enable building unit tests
| `x_NAME_x_CCACHE`              | Enable ccache for faster rebuilds
| `x_NAME_x_COVERAGE`            | Enable code coverage reporting
| `x_NAME_x_COVERAGE_EXCLUDES`   | List of files/directories to exclude from code coverage reporting
| `x_NAME_x_CXX_EXTENSIONS`      | Enable C++ compiler extensions (like GNU extensions)
| `x_NAME_x_DEVELOPER_MODE`      | Enable developer mode (static analysis and warnings as errors)
| `x_NAME_x_HARDENING`           | Enable compiler hardening flags
| `x_NAME_x_HARDENING_GLOBALLY`  | Enable hardening flags for all targets
| `x_NAME_x_IPO`                 | Enable interprocedural optimization (IPO/LTO)
| `x_NAME_x_SANITIZER_ADDRESS`   | Enable AddressSanitizer dynamic analysis
| `x_NAME_x_SANITIZER_LEAK`      | Enable LeakSanitizer dynamic analysis
| `x_NAME_x_SANITIZER_THREAD`    | Enable ThreadSanitizer dynamic analysis
| `x_NAME_x_SANITIZER_UNDEFINED` | Enable UndefinedBehaviorSanitizer dynamic analysis
| `x_NAME_x_SA_CLANG_TIDY`       | Enable clang-tidy static analysis tool
| `x_NAME_x_SA_CPPCHECK`         | Enable cppcheck static analysis tool
| `x_NAME_x_SA_CPPCHECK_EXH`     | Enable exhaustive check level in cppcheck analysis
| `x_NAME_x_SA_IWYU`             | Enable include-what-you-use (IWYU) static analysis tool
| `x_NAME_x_UNITY_BUILD`         | Enable unity build to speed up compilation
| `x_NAME_x_WARNINGS_AS_ERRORS`  | Treat compiler and static analysis warnings as errors

## Troubleshooting

**Coverage report generation fails with
`lcov: ERROR: (version) Incompatible GCC/GCOV version found while processing ...`**

This error indicates that the version of `gcov` used to generate coverage data is different from
the version of `gcc` used to compile the code. If you are using multiple versions of `gcc` on your
system, ensure that `gcov` symlink points to the correct version that matches your `gcc` version.

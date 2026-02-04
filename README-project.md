# x_NAME_x

## Setting up for development

For development, it is usually more convenient to use `ccmake` or `cmake-gui` to configure CMake
options interactively. To do this, create a build directory and run one of the following commands:
```bash
mkdir build
cd build
ccmake ..
# or
cmake-gui ..
```
For development builds, it is recommended to enable developer mode and build testing. You can do this
by setting the following options in `ccmake` or `cmake-gui`:
- `x_NAME_x_DEVELOPER_MODE` to `ON`
- `x_NAME_x_BUILD_TESTING` to `ON`

Same options can be set when running CMake from command line as shown here:
```bash
mkdir build
cd build
cmake -Dx_NAME_x_DEVELOPER_MODE=ON -Dx_NAME_x_BUILD_TESTING=ON ..
make -jN
```
`*_DEVELOPER_MODE` is a shorthand for enabling **cppcheck** and **clang-tidy** static analysis
tools, and also **treating warnings as errors**. `*_BUILD_TESTING` enables building unit tests
for the project. The project defaults to debug build type if none is specified.

Optionally, code coverage reporting can be enabled with `*_ENABLE_COVERAGE`. See the
"Code Coverage Report" section below for more details.

## Building a release

To build the release version of the project, create a build directory and run CMake with the
following commands:
```bash
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -jN
```
Replace `N` with the number of parallel jobs to use (e.g., number of CPU cores).

## Building documentation

To build Doxygen documentation for the project, build the `doc` target and open the generated
HTML documentation in your web browser (inside the build directory):
```bash
make doc
xdg-open html/index.html
```

## CMake options

Below is a list of CMake options available for this project along with their descriptions:

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
| `x_NAME_x_WARNINGS_AS_ERRORS`  | Treat compiler warnings as errors

## Code coverage report

First, you must install `lcov` package to be able to generate code coverage reports
(e.g. `sudo apt install lcov`).

1. Set the following options in CMake to be able to generate code coverage reports:
    - `CMAKE_BUILD_TYPE=Debug`
    - `x_NAME_x_BUILD_TESTING=ON`
    - `x_NAME_x_ENABLE_COVERAGE=ON`
2. Build the coverage reporting target by running `make -jN coverage` (or equivalent) in your
   build directory (`N` is the number of parallel jobs to use, e.g. number of CPU cores).
3. Open the generated HTML report by opening `coverage/index.html` from the build directory in
   your web browser (e.g. `xdg-open coverage/index.html` in build directory).

You can also build the project normally using `make -jN` (or equivalent) and then build the
coverage report when needed by running `make coverage` (or equivalent).

**Troubleshooting:
`lcov: ERROR: (version) Incompatible GCC/GCOV version found while processing ...`**

This error indicates that the version of `gcov` used to generate coverage data is different from
the version of `gcc` used to compile the code. If you are using multiple versions of `gcc` on your
system, ensure that `gcov` symlink points to the correct version that matches your `gcc` version.

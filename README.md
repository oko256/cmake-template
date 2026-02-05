# CMake Template - User Guide

This CMake template grew out of the need to have a consistent and reusable project template
for C and C++ projects (both applications and libraries) that uses modern CMake features and
best practices. It has been incrementally updated and improved over time based on real-world usage,
and has taken inspiration from various existing templates.

Of course the default setup of the project is opinionated, but you can easily modify the rules
to suit your own needs. The template is designed to be easy to use and adapt. Please note that
you still need to have basic understanding of CMake to use this template effectively since you
will have to manually customize the build rules to fit your own project needs (setup script is
very basic).

The main features of this template include:

 - Support for both C and C++.
 - Support for building both applications and shared/static libraries (even within the same project).
 - Autogenerate export header for shared libraries and set hidden visibility by default.
 - Work nicely when used as a subproject via `add_subdirectory()`.
 - Reasonable default install rules (also for Systemd unit files if applicable).
 - All custom CMake options prefixed with project name to avoid conflicts.
 - Simple setup with one script that basically just does a search-replace through files.
 - Unit testing and code coverage reporting support.
 - Static analysis support with `clang-tidy`, `cppcheck`, and `include-what-you-use`.
 - Dynamic analysis support with AddressSanitizer, LeakSanitizer, ThreadSanitizer, and
   UndefinedBehaviorSanitizer.
 - Best practice compiler hardening flags enabled by default (with good bunch of warnings).
 - Support for speeding up building with `ccache` and unity builds, and option to easily enable
   interprocedural optimization (IPO/LTO).
 - Automatic generation of versioning functions and library versioning based on git tags.
 - Integration of Doxygen to build documentation.

## Platforms and compilers

It is important to note, that current this template is primarily focused on **Linux** systems and
**gcc and clang** compilers. Windows target or MSVC compiler support can be added pretty easily,
but is currently lacking. The template might work on MacOS, but this is also not well tested.

## Usage

1. Clone this repository (or download the zip file) as your new project directory:
   ```bash
   git clone https://github.com/oko256/cmake-template.git my-new-project
   ```
2. Open the `my-new-project` directory and run the provided `setup.sh` script:
   ```bash
    cd my-new-project
    ./setup.sh
    ```
    Follow the instruction of the script. This will set up the project name as the prefix in all
    of the files and delete traces of the cloned repository etc.
3. Start by opening the root `CMakeLists.txt` file and fill in the details marked with `TODO`.
4. Remember to initialize git repository in your new project directory if needed:
   ```bash
   git init
   ```
   If you don't want to use git, remember to also set `VERSION` in root `CMakeLists.txt` manually
   to ignore warnings about git versioning script. You can also use `VERSION` with git if you want
   to control versioning manually.
5. Next steps depend on what kind of project you are building. The template is an example of
   project that builds both an application and a shared library, so that it covers both use cases.
   Often you don't build both from one project, so see the sections below for more details.
6. You should also read the template of project README that is included. It contains
   descriptions of CMake options and instructions for building, testing, and installing the project.

### Configuring template for application-only projects

If your project only builds an application (no shared libraries), after setting up the project as
described above, you should slim down the template:

1. Remove unnecessary files related to the example library:
   ```bash
   rm -rf include/ src/examplelib/ test/examplelib/ examplelibConfig.cmake.in
   ```
2. Edit the root `CMakeLists.txt` file to remove the line that adds the example library:
   ```cmake
   add_subdirectory(src/examplelib)
   ```
3. For example purposes, the example application also uses the example library. Check the
   `src/CMakeLists.txt` for this line and remove `examplelib` from it:
   ```cmake
   target_link_libraries(apponly-exe PRIVATE spdlog::spdlog apponly::examplelib)
   ```
   The example also uses `spdlog` as dependency example, see the section below for adding dependencies.
4. For example purposes, the example unit tests also have tests for the shared library. Remove
   these mentions from `test/CMakeLists.txt`:
   ```cmake
   add_executable(apponly-test
       # ...
       examplelib/ExampleConcat.test.cpp
   )
   ...
   target_link_libraries(apponly-test PRIVATE apponly-common examplelib)
   ```
5. Remove `examplelib` parts from the code in `src/main.cpp`.
6. Build your project with CMake as usual and you should get an example application.
   Read `README.md` of the project for build options and so on.
7. If your project does not need to install Systemd unit files, you can delete the `systemd/`
   sub-directory which will cause all Systemd related installation rules to be skipped.

### Configuring template for library-only projects

If your project only builds a shared library (no applications), after setting up the project as
described above, you should slim down the template:

1. Remove unnecessary files related to the example application:
   ```bash
   rm src/*  # Removes just the files in src/, not the sub-directory inside!
   rm test/ExampleMultiplier.test.cpp
   rm -rf systemd/
   ```
2. Modify the root `CMakeLists.txt` file to remove the line that adds the example application:
   ```cmake
   add_subdirectory(src)
   ```
3. Modify the unit testing `test/CMakeLists.txt` file to remove references to example application,
   consider the following lines:
   ```cmake
   add_executable(apponly-test
       ExampleMultiplier.test.cpp
   )
   target_link_libraries(libonly-test PRIVATE libonly-common examplelib)
   ```
4. Build your project with CMake as usual and you should get an example shared library.
   Read `README.md` of the project for build options and so on.

### Adding dependencies

You should add all dependencies to `dependencies.cmake` file in the project root. This makes it
easy to figure out which external dependencies your project has. The template already includes an
example of how to add `spdlog` dependency using `find_package()`. You can also add subprojects
or use `FetchContent` to add dependencies if needed.

One exception is dependencies that are only needed for testing. These should be added to
`test/CMakeLists.txt` file instead. The template has example of this (Catch2 testing framework).

## Project structure

The (opinionated) default structure of the project created using this template is described
below. The main points of this structure are:

 - Root `CMakeLists.txt` adds sub-directories for sources of applications and libraries directly
   (as well as tests).
 - `dependencies.cmake` file is used to collect all external dependencies in one place
   (except that dependencies specifically for unit tests should be added to `test/CMakeLists.txt`).
 - Config file templates for each library should be in root (e.g. `examplelibConfig.cmake.in`).
 - Public headers for shared/static libraries are in `include/<libraryname>/`.
 - Sources and private headers for shared/static libraries are in `src/<libraryname>/`.
 - Application sources and headers are in `src/`.
 - CMake helper modules are in `cmake/`.
 - Systemd unit file templates and installation rules are in `systemd/`.

```
.
├── cmake
│   ├── version.c.in            <- C source and header for autogenerated versioning functions
│   ├── version.h.in
│   └── ...various other CMake helper modules...
├── CMakeLists.txt
├── dependencies.cmake          <- build rules for external dependencies
├── examplelibConfig.cmake.in   <- example CMake config file for the shared library
├── include
│   └── examplelib
│       └── ..._public_ headers for the shared library...
├── README.md
├── README-project.md
├── setup.sh
├── src
│   ├── CMakeLists.txt          <- build rules for the application
│   ├── examplelib
│   │   ├── CMakeLists.txt      <- build rules for the shared library
│   │   └── ...sources and _private_ headers for the shared library...
│   ├── main.cpp
│   └── ...sources and headers for the application...
├── systemd
│   ├── example.service.in
│   └── systemd.cmake           <- installation rules for systemd unit files
└── test
    ├── CMakeLists.txt          <- build rules for both application and library tests
    ├── examplelib
    │   └── ...test sources related to the shared library...
    ├── ...test sources related to the application...
    └── main.test.cpp           <- unit tests entry point
```

## Customizing the template

You obviously can customize this template for your own use cases. Some files that you likely
want to touch are at least:

 - `.clang-format` file for code formatting rules.
 - `.clang-tidy` file for clang-tidy static analysis rules.
 - `cmake/target-properties.cmake` file for *clang-tidy*, *cppcheck*, and *include-what-you-use*
   arguments.
 - `.gitignore` file to ignore files specific to your project.
 - The root `CMakeLists.txt` file contains also the Doxygen rules that you might want to customize.

## Using for C projects

By default the template is set up for C++ projects, but it can be easily adapted for C-only
projects. The CMake rules already support both C and C++, so you just need to remove C++ specific
parts from the code files and add your C files instead. You can change the Catch2 testing framework
to Unity for example and it should work fine.

## Additional considerations regarding own development setup and CI pipelines

 - Consider having clang-format running in your editor to immediately fix formatting issues.
   Also add a git pre-commit hook and/or CI step to check code formatting.
 - Consider having clang-tidy and/or cppcheck running in your editor to catch static analysis issues
   as you write code. Also add CI step to run unit tests with static and/or dynamic analysis enabled.
 - Consider having spellchecking in your editor to catch typos as you write code, and also as
   a CI step.
   For example [typos](https://github.com/crate-ci/typos/tree/master) is a good tool for this.

## Licensing

This template is licensed under the BSD 0-clause license.

`SPDX-License-Identifier: 0BSD`

Copyright (C) 2024-2026 by oko256

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

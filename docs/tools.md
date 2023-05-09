
# Using the tools

Here you can find a more detailed description of each tool and some tips on how to use them.
If you want practical examples on how to use them, check the tool documentation and the [CI workflows](docs/cicd.md).

## Code formatting tools
As the name suggests, these tools format the code to follow pre-configured standard rules, so there is no need to worry about spacing, line length, new lines, etc.
They perform very basic tests that should not alter the code that the compiler sees.
So, for example, these tools would not reorder the `#include` statements.
Because of that, ideally you should configure your IDE to apply the format upon saving.



### clang-format
The format rules are configured in the root file `.clang-format`. Currently, the Google style is being used.

Most IDEs will dected the `.clang-format` file and automatically format the code.
In `VS Code` this is done by the [C++ extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools). 
Just by having the extension it should work, but it can be configured in the `Formatting` section of the extension settings.
You can also run manually the command `Format Document` from the command palette to format the file.

## Static analysis tools
Static analysis tools perform more complex checks than formatting tools, but they also take longer to analyze and can yield many false positives.
I would recomment to run the analysis everytime upon saving or opening the files if your pc can handle it.

### clang-tidy
The checks are specified in the `.clang-tidy` file. Right now basically checking for everything except some specific rules for other projects
or annoying checks like using auto return trailing types. The `.clang-tidy` is also configured to enforce the naming conventions I prefer.
In `VS Code` clang-tidy is automatically available with the [C++ extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools). It is under the `Code Analysis` settings, and it can be run automatically when saving or for example invoked through the command palette through `Run Code Analysis` in the active or in all the files. In order for the extension to check your header files (very important in header-only libraries), VS Code should call `clang-tidy` with the `--header-filter="*"` option. Check the [Configuration for VS Code section](configuring.md) for more details.

There is also a custom option in CMake, and configurable through Conan, to create a CMake target to run clang-tidy. This target is only available in Linux (even when setting the option to True in Windows systems).
This is because in Windows it is a bit more difficult to configure the run, and in the end the tool is available through the VS Code C++ extension. You can check the `Tools.cmake` file to see how the target is
configured, and the `code-checks.yml` workflow to see how to create and invoke the target through the command line.
Because in the end it is another CMake target, it can be invoked directly from the CMake VS Code extension, and the code will be linted automatically. 

### cpplint
cpplint is in between a formatting and a static analysis tool. The rules are configured in the `CPPLINT.cfg` file.
In `VS Code` you can use it just by installing the [cpp-check-lint extension](https://marketplace.visualstudio.com/items?itemName=QiuMingGe.cpp-check-lint)
The extension will check and lint the code automatically when saving, but it can be configured. The extension also includes the `cppcheck` tool.

### cppcheck

cppcheck is a static analysis tool that detects errors and vulnerabilities in C and C++ code. It can identify memory leaks, buffer overruns, and other issues that might cause crashes or undefined behavior. In VS Code, you can use it by installing the [cpp-check-lint extension](https://marketplace.visualstudio.com/items?itemName=QiuMingGe.cpp-check-lint). The extension will check the code automatically when saving, but it can be configured. The extension also includes the cpplint tool.

Similar as with `clang-tidy` there is a `cppcheck` target for CMake to check all the relevant files of the library. The target is configured in the `CMakeLists.txt` file under the `test` directory. If you look at the target configuration, you can see that some files are excluded to avoid false positives. If you use `cppcheck` manually or through VS Code (see [Configuration for VS Code section](configuring.md)), you might want to exclude also those files.

### CodeQL
CodeQL is a code analysis engine developed by GitHub that can analyze source code to identify security vulnerabilities, bugs, and maintainability issues. CodeQL supports multiple languages, including C and C++. 
The CodeQL workflow is in the one responsible to do the test. In principle, I think it is not necessary to have a local CMake target or VS Code to run CodeQL. If the workflow fails in some commits, just fix the code.

## Testing tools

### Catch2
C++ library for unit testing. It integrates easily with CTest (CMake own test coordinator tool). In this template, everything related to the tests is under the `./test` folder. When the folder is included from the root `CMakeLists` using the `add_subdirectory` command, a `tests` target (and the clang-tidy and cppcheck targets if the options are activated) is made available. 

### Code coverage
Code coverage is a metric used in software testing to measure the extent to which the source code of a program has been executed by a test suite. It is expressed as a percentage, representing the ratio of the number of lines, branches, functions, or statements in the code that have been tested to the total number of lines, branches, functions, or statements.

Here, we use `gcov`, `lcov` and [Codecov](https://codecov.io/). Check the `coverage` workflow and the `coverage` CMake target for more info.


## Documentation

### Doxygen + graphviz + Doxygen Awesome CSS

Doxygen is a popular documentation generation tool for C++ code and it generates documentation from source code comments in a variety of formats, including HTML, LaTeX, and more. You can use it with `Graphviz` to also generate relationship diagrams of the classes. The default theme of doxygen is a bit outdated, so you can use CSS templates such as [Doxygen Awesome](https://github.com/jothepro/doxygen-awesome-css) to make it much better. 


## Package managers: Conan
I've decided to use `Conan` as the package manager for the library, see the note below on why. 
Conan can do many other things than just managing the external dependencies and because Conan is now a mandatory tool, it makes sense to use other features it can offer. Specifically, we are using Conan to manage external dependencies, setup the build chain, to set the package version, and to configure the package options.

The options related to the package itself and its dependencies is configured within the `conanfile.py`. 
The build tools (compiler, C++ standard, build type) are managed in conan using profiles.

### conanfile.py
There are many options configured in the `conanfile.py` file, here are some of them:

- version: This is the only place where the version is defined. The version defined here is propagated to CMake and from CMake to the source code.

- options and default_options: The options of the package that will be passed to CMake.


For more details check the `conanfile.py` file in the root directory and the [conan documentation](https://docs.conan.io/2/reference/conanfile.html). 

### Conan profiles
There are several files (profiles) under `.conan/profiles` that are used to configure the build for the CI/CD operations in the Github Workflows.
There are three types of profile files in that folder:
1. Profiles starting with the `os` name
    For example, `windows-msvc2022-amd64` or `ubuntu-gcc12-amd64`. These profiles specify the required operative system and compiler to build the package.
    They set the options `[buildenv]` so CMake will raise and error during the configuration stage if the specified compiler is not found. Otherwise it will try to use another.
    *Note:* Now msvc is configured with `dynamic` runtime. It also can be `static`.

2. Profiles starting with `build-`
    Set the `build-type` during the configuration and build stages. The name of the CMake build preset created by conan will match the build type.
    For example, if a `Release` build has been selecte, the build preset will be called `conan-release`.

    The name of the CMake configure preset is always `conan-default` despite of the build type. However, just in case, the `-DCMAKE_BUILD_TYPE=<build_type>` is passed to CMake.
    You can install the package for `Release` and `Debug` mode at the same time, and you will have two preset to build the library but only one configure preset. See Issue #26

3. Profiles starting with `options-`
    These are options to configure the package, for example to select if you want to build or not the docs.


When calling `conan install` or `conan create` you can specify several profiles that will be combined. In the CI/CD workflows I combine the three previous types depending on the workflow.
You are free to use those profiles as they are used in the CI workflows, but probably, the more convenient way build the package locally is to configure the `default` profile in you system.

To do so, use `conan profile detect --force` to generate the `default` profile. Then, open the generated file and change the options as you want. You should also add the options for the package.
This is explained in the  Check the 


For more info about the options in the profiles see:
https://docs.conan.io/2/reference/config_files/settings.html



### Note on vcpkg vs conan
The most standard package managers are [vcpkg](https://vcpkg.io) and [conan](https://conan.io/). 
At the begining I chose to use `vcpkg` because it seems easier to use and doesn't required additional dependencies.
You can use vcpkg directly from CMake by fetching the repository and setting it as the CMake toolchain before calling 
`projec()`. This approach works fine for building the executable/library directly without *consuming* it from another project. 

However, when trying to use `my_lib` from an external project (another C++ project or when building a `pybind11` module) with its dependencies managed by vcpkg, it turn out to be not so simple. There are several approaches to follow, I managed to make it work by setting the same dependencies in the *external project* as in `my_lib`, but that means duplicate dependencies definition and several obscure workarounds. In the end, if I understood how to use vcpkg correctly, you would need to create a proper package of `my_lib` and then consume it normally with `find_package()` with or without using vcpkg in the external project. 
And to properly do all of this, it is necessary to undertand how vcpkg works in detail, how `CMake` and the `install()` and  `find_package()` works in detail, and the advantage of managing everything from CMake is lost.

Because of that I went back to `conan`. I didn't try conan at the beginning because it seems more difficult, you need to set-up python and a python environment, cmake accesible from the command line and invoke all of this externally to CMake. Make it all of this to work automatically in windows and linux and in Github Workflows seems to me very difficult, but it was really not the case when looking at it. Set-up python is really easy in Github, and by using python you can do many other things easily, like running the formatting and analysis tools or install CMake using pip. And for building python extensions I need to set-up python anyway. But the most important thing for me, is that `conan` can be used to configure every aspect of the build and installation process from python with the 'conanfile.py'. Which in the end means that you can use high-level functions (many of them already built by conan) to configure CMake without writting cmake code. For me, that I find python *comfortable* but CMake seems really difficult to use, is the ideal package manager.

By using `conan` I've started to move build and installation logic from the `CMakeLists.txt` files and `*.cmake` scripts to the `conanfile.py`. If I find `conan` to work well, I will continue to move many of the packaging, build and compilation logic to the `conanfile.py`. The goal would be then to simplify CMake code and leave all the build and compilation stuff to conan.

TL;DR: `vcpkg` is easier to use for simple projects and doesn't requiere external dependencies besides CMake. `conan` needs python, but you can move build and packaging CMake code to python, which makes it easier for me.



# Configuration for VS Code
You can use your favourite IDE to follow the suggested [development workflow](workflow.md), but I recommend VS Code. Because there are many steps to setup the development environment, and is easy to forget some of them, here is a practical guide on how to do it. In a nutshell, what you need to do is:


1. **Installing the build tools:**
    - Compiler
    - CMake
    - Git
    - Python
    - VS Code
2. **Configure VS Code:**
    - Install `C++`, `Python` and `cpp-check-lint` extensions
    - Configure some settings for convenience
3. **Build the library:**
    - Clone the repo
    - Create a Python virtual environment
    - Install `conan`
    - Configure the conan build profile and the package options
    - Build the library with conan and start the development

The step-by-step guide starts below. I've tested all those steps in clean installations of Windows and Linux and they seems to work fine. If that were not the case, or if there is some missing step, feel free to open an Issue or create a Pull Request.

## 1. Installing the build tools
The idea is to use the same tools in Linux and Windows, with the only exception of the compiler. However, the installation process is different, so here we need to differenciate between Windows and Linux.

### Windows
The MSVC compiler is the easier choice for Windows, so here are the instructions for that.

Usually in Windows you would need to install each tool manually, going to the website, downloading the installer, and following the installer instructions. But, you can automate the installation process using a package manager like [Chocolatey](https://chocolatey.org/). So depending on what you choose, you should follow *1.a)* or *1.b)*. I would recommend to use `Chocolatey` as it is easier and faster. And if you have any problem with any of the installations, you can always check the manual section for that tool.


#### 1.a. Automatically using choco
To do that, first install the **Chocolatey** package manager, and then all the other tools through the `choco` command. Everything can be done through the command line. Open the Windows PowerShell with administrative rights and type:

```bash
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --includeRecommended"

choco install cmake --installargs 'ADD_CMAKE_TO_PATH=User' -y

choco install git -y

choco install python -y

choco install vscode -y
```

#### 1.b. Manually
You can skip the step if the tool is already installed.
1. [MSVC 2022](https://visualstudio.microsoft.com/vs/features/cplusplus/)
2. [CMake](https://cmake.org/download/)
    
    Although it can be installed automatically by Conan or using `pip`, it is better to have CMake installed in the system so VS Code can recognize it automatically. Additionally, it is necessary to have CMake in the path, so select that option during the installation. Otherwise the Conan installation will fail and you will need to add CMake manually to the path or install another CMake through `pip` in the same environment you are executing `Conan`. 

3. [git](https://git-scm.com/download/win)
4. `Python`. There are several ways to install python in windows:
    - Through the Microsoft Store. Just type `python` in the Terminal (cmd or PowerShell) and click install
    - Through the official [python website](https://www.python.org/downloads/)
    - Using [Anaconda distribution](https://www.anaconda.com/download/), with the advantage of having `conda` to manage virtual environments
5. [Visual Studio Code](https://code.visualstudio.com/download)

    The next step is to configure Visual Studio Code, installing some extensions and adding some custom rules to execute `clang-format`,  `clang-tidy`, etc.

### Linux
Install GCC or Clang, CMake and VS Code. That's all. In Ubuntu, for example, you can use `apt` to install GCC and CMake and `snap` for VS Code:
```
sudo apt update
sudo apt upgrade
sudo apt install build-essential
sudo apt install cmake
sudo snap install --classic code
```

## 2. Configure VS Code
There many extensions and settings you could tweak in VS Code to make you life easier. Here I gather what I consider the minimum to have a smooth experience.
1. **Extensions:**
    - [Microsoft C/C++ Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-extension-pack), which includes:
        - C/C++
        - C/C++ Themes
        - CMake
        - CMake Tools
    - [Microsoft Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
    - [cpp-check-lint](https://marketplace.visualstudio.com/items?itemName=QiuMingGe.cpp-check-lint)

2. **Settings:**
    - Configure PowerShell (for Windows) to execute Python environment activation script
    - clang-format working on saving
    - clang-tidy checking the library headers and working on saving
    - cpp-check excluded files (example, better tweak this setting on a repo basis )

Same as before, you can install the extensions and configure the settings manually or automatically.

### 2.a. Automatic configuration by importing a VS Code profile
In VS Code you can now use profiles to customize all the settings in an isolated profile. This makes really easy to share the whole configuration of VS Code. For convenience, I have created a [repo with two VS Code profiles for C++ and Python development](https://github.com/jpiqueras/vscode-profile-cpp-python). If you just want the settings mentioned above, import the `Minimal` profile by pasting the following url in the VS Code command `Profiles: Import Profile...`:

```
https://raw.githubusercontent.com/jpiqueras/vscode-profile-cpp-python/main/Cpp_Python_minimal.code-profile
```

You can also check the `Complete` profile for the complete set of settings and extensions I like. Even if you only want some of the extensions or settings, importing the profile is still convenient because during the import process you can check and customize what do you want to import.

### 2.b Manual configuration
First, install the extensions listed above and after that apply the settings by copying the following code in the `settings.json` file (in the command palette `Preferences: Open User Settings (JSON)`):

```json
"terminal.integrated.profiles.windows": {
    "PowerShell": {
        "source": "PowerShell",
        "icon": "terminal-powershell",
        "args": [
            "-ExecutionPolicy",
            "Bypass"
        ]
    }
},
"terminal.integrated.defaultProfile.windows": "PowerShell",
"C_Cpp.clang_format_fallbackStyle": "Google",
"editor.formatOnSave": true,
"C_Cpp.codeAnalysis.clangTidy.headerFilter": "*",
"C_Cpp.codeAnalysis.clangTidy.enabled": true,
"cpp-check-lint.cppcheck.-i ": [
    "test/mytest1.cpp"
],
``` 
For a detailed explanation of each option, check the description in VS Code `Preferences: Open User Settings` (the not JSON command).

## 3. Build the library

At this stage, you should have VS Code configured with the other tools working (git, cmake and python). From this point the idea is to use the built-in methods of VS Code to do the typical things you would do within the terminal (clone the repository, create python virtual environments, etc.).

### 3.1. Clone the repository

Open VS Code and clone the repository: 
1. Open the command palette (`ctrl+shift+p`)
2. Type `clone`, select `Git: clone` and follow the instructions.
3. Open the new cloned repository

\note You need to set the folder you just cloned as **Trusted** when the message pops up.

\warning The `CMake` extension will probably ask if you want to configure the project. You should **not** configure the project until you install the library with `conan`. Otherwise the configuration will fail, as the the dependencies and the package options are not yet configured.


### 3.2. Create a Python virtual environment and activate it in VS Code
Before installing `conan`, it is very recommendable to use a virtual environment. If you use `anaconda` to manage python, just follow the conda instructions to create and environment, VS Code should detect the new environment just fine. If you are using the regular Python distribution of your system, then it is easier to just use the python built-in `venv`, which can also be used directly from VS Code (when the Python extension is installed). To do so:
1. Open the command palette (`ctrl+shift+p`)
2. Type: `Create environment` and select `Python: Create Environment...`
3. Now select `Venv` (or `Conda` if you are using `anaconda` and prefer to create the environment directly from VS Code)
4. Select the base Python that will be used to create the environment.
5. The environment is created in the root of the package in the folder `.venv`.

Finally, you need to activate the environment within VS Code. To do so, in the command palette use the option `Python: Select Interpreter` and choose the one you just created. Now you can open a Terminal within VS Code (`Terminal: Create New Terminal`), and the python environment will be activated automatically.

### 3.3. Install conan
[Conan](https://conan.io/) can be installed through `pip`. You need the newer versions of conan ([Conan 2.X](https://docs.conan.io/2/)).
1. Open a terminal in VS Code (`Terminal: Create New Terminal` or the configure shorcut), check that the python environment has been activated and type:

```
pip install conan
```

That's all.

### 3.4. Configure conan build
Because conan is installed in a virtual environment, the most convenience way to use it is to set the `default` profile to the one we want to use to build the library.
You can also use directly the profiles saved in the repository that are used for the `ci` workflows (check the [Using the tools section](tools.md), the [CI/CD section](cicd.md) or [the Conan documentation](https://docs.conan.io/2/reference/config_files/profiles.html) ).

1. To set the default profile type: `conan profile detect --force`. This will create a new `default` profile using the compiler on your system. The profile is just a file called `default` similar to those in the repository under `.conan/profiles/ubuntu-xxx` or `.conan/profiles/windows-xxx`.

2. There should be nothing wrong with the default profile, except the C++ standard. This library is intended to use modern C++, so you need to set the C++ standard to C++20 or C++23. To do so you need to edit the just created `default` file. The path to the file can be consulted with conan using: `conan profile path default`. And to edit the file within VS Code, just type in the terminal:

    ```
    code $(conan profile path default)
    ```

3. Then edit the `compiler.cppstd=14` line and change 14 to 20 or 23.

Now the build system is configured in `conan`, but the options of the package (for example if you want to build the documentation, or if you want to use the compiler warning flags) are not set yet. If you call `conan install` at this stage, default options will be used for building the library (which might be perfectly fine). To see the default options, check the `conanfile.py` at the root of the repository and check the attribute `default_options`. 

The package options can be configured when calling conan through the command line, but there are many to type and would be tedious. There is a better way, which is to establish the package options also in the profile. Profiles can be reused and combined (check the [Using the tools section](tools.md) and [the Conan documentation](https://docs.conan.io/2/reference/config_files/profiles.html)), and for example, if you look at the `ci` workflow, you can see how we combine three profiles to install the package (one to set the compiler, another to set the build type and a last one to set the package options). This avoid to create new profiles just to change one option, which is useful to create multi-plattform builds in the Github workflows. 

But in you own system, you probably just want one configuration, and to do so, the simpler way is to edit the conan `default` profile with the options you want. The content you need to put in the `default` profile file is the same as in the files `.conan\profiles\options-xxx` with the options you want set to True or False. A good set of options to start would be those in the file `options-lib-warns`, that will enable only the library and standard compiler warnings.

4. So, edit again the `default` profile file and add the package options you want, for example just add:

```
# This is the content of the .conan/profiles/options-lib-warns file
[options]
LIB_OPTION_LIBRARY = True
LIB_OPTION_LTO = True
LIB_OPTION_DOCS = False
LIB_OPTION_WARNINGS = True
LIB_OPTION_WARNINGS_AS_ERRORS = False
LIB_OPTION_COVERAGE = False
LIB_OPTION_INCLUDE_WHAT_YOU_USE = False
LIB_OPTION_CLANG_TIDY = False
LIB_OPTION_CPPCHECK = False
LIB_OPTION_SANITIZE_ADDR = False
LIB_OPTION_SANITIZE_UNDEF = False

```
You can check what each option is intended for here in the root `CMakeList.txt` file.


### 3.5. Build the library with conan and start the development

Finally we are ready to build the package. In the terminal, type:

```
conan install . --build=missing
```

If everything goes well, conan should build the dependencies and set a preset to be used by CMake with everything configured.

Now, in VS Code, select the `conan-default` config of CMake through the bottom bar. If that configuration preset is not available you might need to restart VS Code.

After that you will be able to choose the build preset `conan-release` or `conan-debug` depending on the options you have chosen. 

You can test that the library work by running the `tests` target.


## E. Extra configuration


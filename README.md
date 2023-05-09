# Modern C++ template 
![C++](https://img.shields.io/badge/C%2B%2B-20%2F23-blue)
[![Code Checks](https://github.com/jpiqueras/modern-cpp-lib-template/actions/workflows/code-checks.yml/badge.svg)](https://github.com/jpiqueras/modern-cpp-lib-template/actions/workflows/code-checks.yml)
[![CodeQL](https://github.com/jpiqueras/modern-cpp-lib-template/actions/workflows/code-ql.yml/badge.svg)](https://github.com/jpiqueras/modern-cpp-lib-template/actions/workflows/code-ql.yml)
[![ci](https://github.com/jpiqueras/modern-cpp-lib-template/actions/workflows/ci.yml/badge.svg)](https://github.com/jpiqueras/modern-cpp-lib-template/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/jpiqueras/modern-cpp-lib-template/branch/main/graph/badge.svg?token=GYYUA28RL7)](https://codecov.io/gh/jpiqueras/modern-cpp-lib-template)
[![docs](https://img.shields.io/badge/doc-GitHub%20Pages-blue)](https://jpiqueras.github.io/modern-cpp-lib-template/)



In this template a lot of C++ tools are used for formatting, checking, testing and documenting the code:
- **Multiplatform build system** with [CMake](https://cmake.org/)
- **Packaging and dependencies management** with [Conan 2.0](https://docs.conan.io/) 

- **Code formatting** with [clang-format](https://clang.llvm.org/docs/ClangFormat.html) and [cpplint](https://github.com/cpplint/cpplint)
- **Code static analysis** with [clang-tidy](https://clang.llvm.org/extra/clang-tidy/), [cppcheck](https://github.com/danmar/cppcheck) and [GitHub CodeQL](https://github.com/github/codeql-action)
- **Unit testing** with [Catch2](https://github.com/catchorg/Catch2) and testing coverage with [Codecov](https://about.codecov.io/)
- **Continuous Integration and Deployment (CI/CD)** with [GitHub Actions](https://github.com/features/actions)
- **Up-to-date self-hosted documentation** with [doxygen](https://www.doxygen.nl/) and [GitHub Pages](https://pages.github.com/)


## Why?

Setting up the template is a tedious work, but once everything is configured the workflow is much smoother. Here are some reason why is important to use these tools:


1. Cross-platform support: `CMake` and `Conan` simplify build configuration and dependency management across different operating systems, enabling seamless cross-platform development and reducing platform-specific issues.

2. Code consistency and readability: `clang-format` and `cpplint` enforce style guidelines and formatting rules, improving code consistency and readability, and streamlining code reviews in team environments.

3. Early issue detection and analysis: `clang-tidy`, `cppcheck`, and `CodeQL` identify potential bugs, vulnerabilities, and performance issues early in the development process, enabling developers to address them before they reach production, leading to more robust software.

4. Testing: `Catch2` simplifies writing and running tests, encouraging developers to thoroughly test their code to catch bugs early and ensure software behaves as expected.

5. Documentation: `Doxygen` generates beautiful documentation from source code comments, making it easier for developers to maintain up-to-date documentation, which is essential for long-term project success.

6. Continuous integration and delivery: `GitHub CI` workflows automate building, testing, and deploying software, ensuring consistent quality and faster delivery of features and bug fixes.

7. Code coverage analysis: `Codecov` measures code coverage, helping developers identify areas of the code that may lack sufficient testing, ultimately leading to better-tested and more reliable software.


Using these tools in modern C++ multiplatform development helps ensure code quality, maintainability, consistency, and robustness. They facilitate collaboration within a team, improve the overall efficiency of the development process, and lead to more reliable, high-quality, and secure software. You can find more information on how these tools are integrated in this template in the documentation.






## References
This template is based on several references:
1. [Jan Schaffranek Template For C++ Projects](https://github.com/franneck94/CppProjectTemplate)
2. [Jason Turner C++ starter template](https://github.com/cpp-best-practices/gui_starter_template) 

3. [aminya C++ template (based on the Jason Turner's one)](https://github.com/aminya/cpp_vcpkg_project)


4. [New features VSCode C++ (CppCon 2022)](https://www.youtube.com/watch?v=iTaOCVzOenM)

5. [cmake-init](https://github.com/friendlyanon/cmake-init)

6. [Świdziński - 2022 - Modern CMake for C++](https://www.packtpub.com/product/modern-cmake-for-c/9781801070058)


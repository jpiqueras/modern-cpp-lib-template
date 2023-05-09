# CI/CD

At this moment, there are several workflows to build, test and deploy the package. They are stored under the `.github/workflows` folder. The workflows can be divided in those that are executed for every commit or pull request to `main` and those 

## Workflows for every commit/pull request to main 
These workflows are only checks. They do not create new commits or change the code.
### Code Checks
It is stored in the `code-checks.yml` file. This workflow checks that the code follow best practices standards. The badge `Code Checks` tracks if this workflow is passing or not. The following tools are used to check the code:

- cpplint
- clang-format
- cppcheck
- clang-tidy

### CodeQL
It is stored in the `code-ql.yml` file. This is also a workflow to check the code statically for bugs or vulnerabilities. It is also triggered every month. It uses [GitHub CodeQL](https://codeql.github.com/). The badge `CodeQL` tracks if this workflow is passing or not.

### CI
It is stored in the `ci.yml` file. This is the **Continuous Integration** workflow, where we check the library can be built and the test passes for different OS and compilers. In this workflow the compiler warnings are active and all the warnings are treated as errors. The process is done for `Release` and `Debug` configurations for the following combination of OS and compiler:

- Windows MSVC 2022
- Ubuntu GCC 12
- Ubuntu Clang 14

The badge `ci` tracks if this workflow is passing or not.

### Coverage
It is stored in the `coverage.yml` file. The workflow checks how much of the code is covered by the tests. It also upload the coverage report to `CodeCov`, where the coverage evolution over time can be checked. The badge `codecov` track the percentage of the code covered by the tests.

### Docs
It is stored in the `docs.yml` file. This workflow checks that the doxygen documentation can be built.

## Workflows for a Release

### Deploy
It is stored in the `deploy.yml` file. At the moment, because the library is header-only, there is no need to build binaries, so the workflow only build the documentation. After building the documentation, the html built files are uploaded to the `gh-pages` branch, which is used by GitHub Pages. The docs are build as usual, but the deployment is automatically handled by the GitHub Action GitHub Pages deploy.

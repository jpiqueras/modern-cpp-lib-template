
# Development workflow

Here I describe generally the intended workflow for this library using GitHub. The idea is to imitate what other project do but without adding too many complications, with the goal of having a `main` branch  **stable** and **up-to-date**.
So anyone that want to see the latest features and how the library evolves, just need to check the `main` branch. But to accomplish both, stability and up-to-date, it is necessary to follow some rules:

- Features and fixes should be added by a `pull request` to the `main` branch from a dedicated branch created for that feature or fix. Ideally, that branch would be associated to one and only one issue. By working in this way we have:

    - The work to be done on these feature or fix branches is limited, so the *lifespan*, or time between the creation of the branch and the merge to `main`, is short. By doing so, the `main` branch is maintained up-to-date with fixes and features.

    - When working on a feature/fix branch, you would want to make commits often, but you might not want to trigger the GitHub workflows everytime, so this is dissabled by default. But workflows are always triggered when a pull request is made. So the feature or fix should be merged only when all the tests passes. By doing so the `main` branch is always *stable*.

- Commits messages should follow a standard. It would help to automate in the future some tasks such as autmatic versioning, or generating release notes. For more info check:
    - [git-semantic-version](https://github.com/marketplace/actions/git-semantic-version)
    - [Conventional Commits](https://www.conventionalcommits.org/en/)


## Releases and versioning
For packages with binaries that need to be built, it is convenient for the users of the package to have access to the binaries directly without the need to build them by themselves. So that is where the release part of the package is for, and although by following the previous rules the `main` branch should be *stable*, we might not want to create a new release each time a commit to `main` is pushed or merged. Also, there might be some problems that are not captured by the tests or just we might want to avoid making several releases in the same day. 

One of the most common way of creating releases is by using Git tags. Tags are associated with specific commits and are used to highlight milestones, for example a release. The content of the tag is arbitrary, but for releases it is a good practice to follow the standard and use the [Semantic Versioning](https://semver.org).

If you have followed standard commit messages, it is easy to create and automated versioning and release system. However, here for now, releases are created **manually**. To create a new release in GitHub the strategy is the following:

- Check that the latest commit in the `main` branch passes all the tests. If not, first fix it.
- Bump the version of the package according to the changes. Here, the version is stored only in the `conanfile.py`, so it is only necessary to modify that. It can easily be done through the GitHub website. This will create a new commit.
- Check that the tests also pass in the new version.
- Go to GitHub releases and create the release and the release tag for that commit. 
- GitHub creates release notes automatically from the merged commits to `main`, so instead of configuring a complicated generator for the notes, is just easier to make good comments when merging a pull request.
- When the release is created, the deployment workflow starts.


## Documentation
Documentation is available through GitHub Pages. However, unlike other documentation hosting services like [Read the Docs](https://readthedocs.org/), where you can navigate through the documentation through different points in the history of the repository, in GitHub Pages, only one built is available.

The documentation is tested to be *buildable* with the `Documentation Workflow`[(see CI/CD Workflows)](docs/cicd.md), which is triggered for evey commit or pull request to the `main` branch. But to avoid incomplete documentation and version mismatching during the development, the documentation is only updated when a new release is set up, triggering the `Deployment Workflow`[(see CI/CD Workflows)](docs/cicd.md).

Because of that, the documentation will match the latest release, but it won't be up-to-date with the latest commit in `main`.

To contribute to the documentation or to see a previous build you should build it locally. To do that, check how to build the documentation in the [Building](docs/Building.md) page, and how Doxygen is configured for this project.


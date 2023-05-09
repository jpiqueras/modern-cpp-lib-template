from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout, CMakeDeps
from conan.tools.build import check_max_cppstd, check_min_cppstd
from conan.tools.files import copy
from conan.tools.env import VirtualBuildEnv
from conan.errors import ConanInvalidConfiguration

import os


class my_libRecipe(ConanFile):
    # Package info
    name = "my_lib"  # Migh be passed to CMake if required

    # This is the version used everywhere. Right now is set manually,
    # but it could be set automatically from the git tag for example.
    version = "0.1.0"

    # I've followed the instructions from https://docs.conan.io/2/tutorial/creating_packages/other_types_of_packages/header_only_packages.html
    # but without adding the "header-only" keyword to the recipe, it doesn't work. The use of the "header-only" is from here:
    # https://github.com/hobbeshunter/json2cpp/tree/conan-2-export-tool-and-lib
    package_type = "header-library"

    # Optional metadata
    license = "Unlicensed"
    author = "Javier Piqueras"
    url = "<Package recipe repository url here, for issues about the package>"
    description = "C++ template library"
    topics = ("C++", "Template", "conan", "doxygen")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"
    options = {
        "LIB_OPTION_LIBRARY": [True, False],
        "LIB_OPTION_LTO": [True, False],
        "LIB_OPTION_DOCS": [True, False],
        "LIB_OPTION_WARNINGS": [True, False],
        "LIB_OPTION_WARNINGS_AS_ERRORS": [True, False],
        "LIB_OPTION_COVERAGE": [True, False],
        "LIB_OPTION_INCLUDE_WHAT_YOU_USE": [True, False],
        "LIB_OPTION_CLANG_TIDY": [True, False],
        "LIB_OPTION_CPPCHECK": [True, False],
        "LIB_OPTION_SANITIZE_ADDR": [True, False],
        "LIB_OPTION_SANITIZE_UNDEF": [True, False],
    }

    default_options = {
        "LIB_OPTION_LIBRARY": True,
        "LIB_OPTION_LTO": False,
        "LIB_OPTION_DOCS": False,
        "LIB_OPTION_WARNINGS": False,
        "LIB_OPTION_WARNINGS_AS_ERRORS": False,
        "LIB_OPTION_COVERAGE": False,
        "LIB_OPTION_INCLUDE_WHAT_YOU_USE": False,
        "LIB_OPTION_CLANG_TIDY": False,
        "LIB_OPTION_CPPCHECK": False,
        "LIB_OPTION_SANITIZE_ADDR": False,
        "LIB_OPTION_SANITIZE_UNDEF": False,
    }

    # Sources are located in the same place as this recipe, copy them to the recipe
    exports_sources = "CMakeLists.txt", "my_lib/*", "cmake/*", "test/*"
    no_copy_source = True

    def requirements(self):
        # Dependencies can be defined also with a version range.
        # For now, hard-coding an specific version, so we know exactly what version is used in the build.

        # Library dependencies
        self.requires("eigen/3.4.0")

        # Test dependencies
        self.test_requires("catch2/3.3.2")

        # Conditional dependencies. Depending on the option selected
        if self.options.LIB_OPTION_DOCS:
            # This mean build doxygen!! It takes to long. Install it with other tool.
            # self.requires("doxygen/1.9.4")
            pass

    def validate(self):
        # Raise an error for non-supported configurations.
        check_min_cppstd(self, "20")

        if self.options.LIB_OPTION_INCLUDE_WHAT_YOU_USE:
            raise ConanInvalidConfiguration(
                "IWYU (Include what you use) is broken right now. Set to OFF."
            )

    def config_options(self):
        if self.settings.os == "Windows":
            self.options.rm_safe("fPIC")

    def configure(self):
        pass
        # if self.options.shared:
        #    self.options.rm_safe("fPIC")

    def layout(self):
        # Here, it is defined where the build files are placed.
        # Instead of defining it manually, we can use a predefined layout by conan for cmake.
        # See: https://docs.conan.io/2/tutorial/consuming_packages/the_flexibility_of_conanfile_py.html#use-the-layout-method
        cmake_layout(self)

    def generate(self):
        deps = CMakeDeps(self)
        deps.generate()
        tc = CMakeToolchain(self)

        # Variables passed to CMake. Conan has "variables" and "cache_variables".
        # See: https://docs.conan.io/2/reference/tools/cmake/cmaketoolchain.html#cache-variables
        # Pass the options to CMake
        for option, val in self.options.items():
            tc.cache_variables[option] = val

        # Not sure if needed, this will pass -DCMAKE_BUILD_TYPE=<build_type> to CMake
        # Multi-config generators (like Visual Studio or Ninja Multi-Config) set the build type at build time, not at generation time.
        # But just in case, we set it here also. And the build_type is controlled by conan (through the profile or the command line)
        build_type = self.settings.get_safe("build_type", default="Release")
        tc.cache_variables["CMAKE_BUILD_TYPE"] = build_type
        tc.cache_variables["CONAN_PROJECT_VERSION"] = self.version

        tc.generate()

        # With this, we tell conan to export the environment variables set in the profiles (eg: linux-gcc12-....)
        # In those variables we force CMake to use the specific version of the compiler, otherwise it chooses whatever he likes.
        ms = VirtualBuildEnv(self)
        ms.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

        # Runing the tests (not the package_test, which is run separately after this using the test method)
        # See: https://docs.conan.io/2/tutorial/creating_packages/build_packages.html
        if not self.conf.get("tools.build:skip_test", default=False):
            test_folder = os.path.join("test")
            if self.settings.os == "Windows":
                test_folder = os.path.join(test_folder, str(self.settings.build_type))
            self.run(os.path.join(test_folder, "tests"))

    def package(self):
        # Because my_lib is header only, we just need to copy the headers
        copy(self, "*.hpp", self.source_folder, self.package_folder)

        # Alternatively we could use the installation with cmake, but I don't know how to do it
        # For this to work, all the install() commands in the CMakeLists.txt must be defined correctly
        # cmake = CMake(self)
        # cmake.install()

    def package_info(self):
        # This line is necessary because the headers are not in the "include" folder. By default, conan will look for the headers in the "include" folder
        # See: https://docs.conan.io/2/tutorial/creating_packages/define_package_information.html?highlight=also%20copy%20include%20folder#define-information-for-consumers-the-package-info-method
        self.cpp_info.includedirs = ["my_lib/include"]

        self.cpp_info.libs = ["my_lib"]

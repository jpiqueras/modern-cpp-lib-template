// cppcheck -suppress *
#include <Eigen/Dense>
#include <catch2/catch_test_macros.hpp>

#include "my_lib/my_lib.hpp"

// Unit tests for the LinearSystemSolver class
TEST_CASE("LinearSystemSolver solves a simple 2x2 linear system") {
  Eigen::MatrixXd A(2, 2);
  A << 2, -1, -1, 3;

  LinearSystemSolver solver(A);
  A.setZero();

  Eigen::VectorXd b(2);
  b << 1, 3;

  Eigen::VectorXd x = solver.solve(b);

  Eigen::VectorXd expected_solution(2);
  expected_solution << 1.2, 1.4;

  REQUIRE(x.isApprox(expected_solution, 1e-12));
}

TEST_CASE("LinearSystemSolver throws an exception for a non-square matrix") {
  Eigen::MatrixXd A(2, 3);
  A << 1, 2, 3, 4, 5, 6;

  REQUIRE_THROWS_AS(LinearSystemSolver(A), std::invalid_argument);
}

TEST_CASE(
    "LinearSystemSolver throws an exception for a non-positive/negative "
    "semi definite matrix") {
  Eigen::MatrixXd A(3, 3);
  A << 9, 0, -8, 6, -5, -2, -9, 3, 3;

  REQUIRE_THROWS_AS(LinearSystemSolver(A), std::runtime_error);
}

TEST_CASE(
    "LinearSystemSolver throws an exception for a vector with mismatched "
    "size") {
  Eigen::MatrixXd A(2, 2);
  A << 2, -1, -1, 3;

  LinearSystemSolver solver(A);

  Eigen::VectorXd b(3);
  b << 3, 3, 7;

  REQUIRE_THROWS_AS(solver.solve(b), std::invalid_argument);
}

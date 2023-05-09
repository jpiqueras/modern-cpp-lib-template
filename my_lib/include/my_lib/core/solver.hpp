/**
 * @file solver.hpp
 * @brief Example of a class that solves a linear system of equations using
 * Eigen. Created with ChatGPT-4.
 */
#pragma once

#include <Eigen/Dense>
#include <iostream>

/**
 * @class LinearSystemSolver
 * @brief Class that stores an Eigen square matrix and solves linear systems of
 * equations.
 */
class LinearSystemSolver {
 public:
  /**
   * @brief Constructor that initializes and factorize the coefficient matrix.
   * @param matrix The square matrix to be used as the coefficient matrix.
   * @throws std::invalid_argument If the input matrix is not square.
   */
  explicit LinearSystemSolver(const Eigen::MatrixXd& matrix) {
    if (matrix.rows() != matrix.cols()) {
      throw std::invalid_argument("The matrix must be square.");
    }

    _ldlt = matrix.ldlt();

    auto result = _ldlt.info();
    if (!matrix.isApprox(matrix.transpose()) ||
        result == Eigen::NumericalIssue) {
      throw std::runtime_error("Possibly non semi-definitie matrix!");
    }
  }

  /**
   * @brief Solves the linear system of equations using the stored coefficient
   * matrix and a user-supplied vector.
   * @param rhs_vector The right-hand side vector of the linear system.
   * @return The solution vector.
   * @throws std::invalid_argument If the size of the rhs_vector doesn't match
   * the size of the coefficient matrix.
   */
  Eigen::VectorXd solve(const Eigen::VectorXd& rhs_vector) {
    if (rhs_vector.rows() != _ldlt.rows()) {
      throw std::invalid_argument(
          "The size of the vector must match the size of the matrix.");
    }
    return _ldlt.solve(rhs_vector);
  }

 private:
  Eigen::LDLT<Eigen::MatrixXd> _ldlt;  ///< The factorized matrix.
};

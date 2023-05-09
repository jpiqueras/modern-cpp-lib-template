/**
 * @file my_lib.hpp
 * @author Author Name
 * @date 2023-05-01
 * @brief A simple C++ header file containing two classes with a bidirectional
 * aggregation relationship. Created by ChatGPT-4.
 */
#pragma once

#include <iostream>
#include <memory>
#include <string>
#include <utility>
#include <vector>

#include "./core/solver.hpp"
#include "./utils/package_info.hpp"
#include "config.hpp"

/**
 * @class Course
 * @brief Represents a course with a collection of enrolled students.
 */
class Course;

/**
 * @class Student
 * @brief Represents a student with a collection of enrolled courses.
 */
class Student : public std::enable_shared_from_this<Student> {
 public:
  /**
   * @brief Constructor for a Student object.
   * @param name The name of the student.
   */
  explicit Student(std::string name) : _name(std::move(name)) {}

  /**
   * @brief Enroll the student in a course.
   * @param course A shared pointer to the Course object.
   */
  inline void enroll(const std::shared_ptr<Course>& course);

  /**
   * @brief Display the courses the student is enrolled in.
   */
  inline void display_courses() const;

  /**
   * @brief Get the list of courses the student is enrolled in.
   * @return A const reference to the vector of weak pointers to enrolled
   * courses.
   */
  const std::vector<std::weak_ptr<Course>>& get_courses() const {
    return _courses;
  }

  /**
   * @brief Get the student's name.
   * @return The student's name.
   */
  const std::string& get_name() const { return _name; }

 private:
  std::string _name;  ///< The name of the student
  std::vector<std::weak_ptr<Course>>
      _courses;  ///< A collection of weak pointers to enrolled courses
};

class Course {
 public:
  /**
   * @brief Constructor for a Course object.
   * @param title The title of the course.
   */
  explicit Course(std::string title) : _title(std::move(title)) {}

  /**
   * @brief Add a student to the course.
   * @param student A shared pointer to the Student object.
   */
  inline void add_student(const std::shared_ptr<Student>& student);

  /**
   * @brief Display the students enrolled in the course.
   */
  inline void display_students() const;

  /**
   * @brief Get the list of students enrolled in the course.
   * @return A const reference to the vector of weak pointers to enrolled
   * students.
   */
  [[nodiscard]] const std::vector<std::weak_ptr<Student>>& get_students()
      const {
    return _students;
  }

  /**
   * @brief Get the course's title.
   * @return The course's title.
   */
  [[nodiscard]] const std::string& get_title() const { return _title; }

 private:
  std::string _title;  ///< The title of the course
  std::vector<std::weak_ptr<Student>>
      _students;  ///< A collection of weak pointers to enrolled students
};

inline void Student::enroll(const std::shared_ptr<Course>& course) {
  _courses.push_back(course);
  course->add_student(shared_from_this());
}

inline void Student::display_courses() const {
  std::cout << _name << " is enrolled in the following courses:" << std::endl;
  for (const auto& course : _courses) {
    if (auto course_ptr = course.lock()) {
      std::cout << " - " << course_ptr->get_title() << std::endl;
    }
  }
}

inline void Course::add_student(const std::shared_ptr<Student>& student) {
  _students.push_back(student);
}

inline void Course::display_students() const {
  std::cout << "Students enrolled in " << _title << ":" << std::endl;
  for (const auto& student : _students) {
    if (auto student_ptr = student.lock()) {
      std::cout << " - " << student_ptr->get_name() << std::endl;
    }
  }
}

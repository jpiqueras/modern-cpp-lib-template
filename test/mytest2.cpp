#include <catch2/catch_test_macros.hpp>

#include "my_lib/my_lib.hpp"

TEST_CASE("Student and Course enrollment", "[Student][Course]") {
  auto student1 = std::make_shared<Student>("Alice");
  auto student2 = std::make_shared<Student>("Bob");
  auto student3 = std::make_shared<Student>("Charlie");

  auto course1 = std::make_shared<Course>("Math");
  auto course2 = std::make_shared<Course>("Physics");

  SECTION("Enroll students in courses") {
    student1->enroll(course1);
    student2->enroll(course1);
    student3->enroll(course2);

    REQUIRE(course1->get_students().size() == 2);
    REQUIRE(course2->get_students().size() == 1);

    REQUIRE(student1->get_courses().size() == 1);
    REQUIRE(student2->get_courses().size() == 1);
    REQUIRE(student3->get_courses().size() == 1);
  }

  SECTION("Bidirectional relationship") {
    student1->enroll(course1);
    student2->enroll(course1);
    student3->enroll(course2);

    auto course1_student1 = course1->get_students()[0].lock();
    auto course1_student2 = course1->get_students()[1].lock();
    auto course2_student1 = course2->get_students()[0].lock();

    REQUIRE(course1_student1->get_name() == "Alice");
    REQUIRE(course1_student2->get_name() == "Bob");
    REQUIRE(course2_student1->get_name() == "Charlie");

    auto student1_course1 = student1->get_courses()[0].lock();
    auto student2_course1 = student2->get_courses()[0].lock();
    auto student3_course1 = student3->get_courses()[0].lock();

    REQUIRE(student1_course1->get_title() == "Math");
    REQUIRE(student2_course1->get_title() == "Math");
    REQUIRE(student3_course1->get_title() == "Physics");
  }
}

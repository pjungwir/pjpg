load test_helper

@test "blank_to_null: null stays null" {
  result="$(query "SELECT blank_to_null(null)")";
  echo $result
  [ "$result" = "NULL" ]
}

@test "blank_to_null: text stays text" {
  result="$(query "SELECT blank_to_null('hi there')")";
  echo $result
  [ "$result" = "hi there" ]
}

@test "blank_to_null: empty string becomes null" {
  result="$(query "SELECT blank_to_null('')")";
  echo $result
  [ "$result" = "NULL" ]
}

@test "blank_to_null: just spaces becomes null" {
  result="$(query "SELECT blank_to_null('  ')")";
  echo $result
  [ "$result" = "NULL" ]
}

@test "blank_to_null: mixed whitespace becomes null" {
  result="$(query "SELECT blank_to_null(e' \\t\\n')")";
  echo $result
  [ "$result" = "NULL" ]
}

@test "in_tz: converts from UTC to Pacific Time" {
  result="$(query "SELECT in_tz('2017-04-13 18:03:04'::timestamp, 'UTC', 'America/Los_Angeles')")";
  echo $result
  [ "$result" = "2017-04-13 11:03:04" ]
}

@test "in_tz: converts from Pacific Time to UTC" {
  result="$(query "SELECT in_tz('2017-04-13 11:03:04'::timestamp, 'America/Los_Angeles', 'UTC')")";
  echo $result
  [ "$result" = "2017-04-13 18:03:04" ]
}

@test "in_tz: converts from Pacific Time to Eastern Time" {
  result="$(query "SELECT in_tz('2017-04-13 11:03:04'::timestamp, 'America/Los_Angeles', 'America/New_York')")";
  echo $result
  [ "$result" = "2017-04-13 14:03:04" ]
}

@test "beginning_of_day: before 5pm is the same day" {
  result="$(query "SELECT beginning_of_day('2017-04-13 11:03:04'::timestamp, 'America/Los_Angeles')")";
  echo $result
  [ "$result" = "2017-04-13 07:00:00" ]
}

@test "beginning_of_day: after 5pm is the same day" {
  # After 5pm (during DST) is the next day in UTC, so make sure that doesn't throw us off here.
  result="$(query "SELECT beginning_of_day('2017-04-13 20:03:04'::timestamp, 'America/Los_Angeles')")";
  echo $result
  [ "$result" = "2017-04-13 07:00:00" ]
}

@test "beginning_of_week_usa: Tuesday goes to Sunday" {
  result="$(query "SELECT beginning_of_week_usa('2017-04-11 11:03:04'::timestamp, 'America/Los_Angeles')")";
  echo $result
  [ "$result" = "2017-04-09 07:00:00" ]
}

@test "beginning_of_week_usa: Saturday goes to Sunday" {
  result="$(query "SELECT beginning_of_week_usa('2017-04-15 11:03:04'::timestamp, 'America/Los_Angeles')")";
  echo $result
  [ "$result" = "2017-04-09 07:00:00" ]
}

@test "beginning_of_week_usa: Sunday afternoon goes to itself" {
  result="$(query "SELECT beginning_of_week_usa('2017-04-09 14:03:04'::timestamp, 'America/Los_Angeles')")";
  echo $result
  [ "$result" = "2017-04-09 07:00:00" ]
}

@test "beginning_of_week_usa: Sunday early morning to itself" {
  result="$(query "SELECT beginning_of_week_usa('2017-04-09 08:03:04'::timestamp, 'America/Los_Angeles')")";
  echo $result
  [ "$result" = "2017-04-09 07:00:00" ]
}

@test "weekusa_range: constructs a 1-week range" {
  result="$(query "SELECT weekusa_range('2017-04-09 08:03:04'::timestamp, 'America/Los_Angeles', 1)")";
  echo $result
  [ "$result" = '["2017-04-09 07:00:00","2017-04-16 07:00:00")' ]
}


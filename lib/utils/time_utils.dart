
/// Compare two time strings for sorting
/// Time format: "HH:mm" (24-hour format, e.g., "14:30", "08:00")
/// Returns: -1 if t1 < t2, 0 if t1 == t2, 1 if t1 > t2
/// Example: compareTimeStrings("08:30", "14:30") returns -1
int compareTimeStrings(String t1, String t2) {
  return t1.compareTo(t2);
}

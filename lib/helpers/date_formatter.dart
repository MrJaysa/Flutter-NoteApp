String formatRelativeDate(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 60 && !difference.isNegative) {
    return 'Now';
  }

  if (difference.inHours >= 1 && difference.inHours <= 6) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  }

  final isToday =
      dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day;
  if (isToday) {
    return 'Today';
  }

  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final monthName = months[dateTime.month - 1];
  final day = dateTime.day;

  String suffix = 'th';
  if (day >= 11 && day <= 13) {
    suffix = 'th';
  } else {
    switch (day % 10) {
      case 1:
        suffix = 'st';
        break;
      case 2:
        suffix = 'nd';
        break;
      case 3:
        suffix = 'rd';
        break;
    }
  }

  return '$monthName, $day$suffix';
}

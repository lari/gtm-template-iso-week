___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "ISO Week Number",
  "description": "Get the current week number according to ISO 8601 standard. Supports different output formats for single and double digit week numbers, and for combinations of year, week number and day of week.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "format",
    "displayName": "Format",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "yyyyww",
        "displayValue": "YYYYww (year and week, e.g. 202201)"
      },
      {
        "value": "yyyy-ww",
        "displayValue": "YYYY-ww (year and week, e.g. 2022-01)"
      },
      {
        "value": "yyyywww",
        "displayValue": "YYYY\u0027W\u0027ww (year and week, e.g. 2022W01)"
      },
      {
        "value": "yyyy-www",
        "displayValue": "YYYY-\u0027W\u0027ww (year and week, e.g. 2022-W01)"
      },
      {
        "value": "ww",
        "displayValue": "ww (only week, e.g. 01)"
      },
      {
        "value": "w",
        "displayValue": "w (only week, no leading zero, e.g. 1)"
      },
      {
        "value": "yyyy-www-d",
        "displayValue": "YYYY-\u0027W\u0027ww-d (ISO Week Date)"
      },
      {
        "value": "yyyy-www-dd",
        "displayValue": "YYYY-\u0027W\u0027ww-dd (ISO Week Date with leading zero)"
      }
    ],
    "simpleValueType": true,
    "alwaysInSummary": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Enter your template code here.
const log = require('logToConsole');
const Math = require('Math');
const getTimestampMillis = require('getTimestampMillis');
const makeString = require('makeString');
log('data =', data);

// Return number as string with leading zeros
function zeroPad(num, places) {
    var str = makeString(num);
    while (str.length < places)
        str = '0' + str;
    return str;
}

// Returns true if the given year is a leap year.
// Every year that can be divided by 4 is a leap year, except the century changes,
// which are only leap years if they are a multiple of 400.
function isLeapYear(y) {
  if (y % 400 === 0) {
    return true;
  } else if (y % 100 === 0) {
    return false;
  } else if (y % 4 === 0) {
    return true;
  }
  return false;
}

// Get weekday of Jan 1st for a given year
// Following steps from http://www.henk-reints.nl/cal/gregcal.htm
// Return value:
// 0 = Sun, 1 = Mon, 2= Tue, 3 = Wed, 4 = Thu, 5 = Fri, 6 = Sat
function getWeekDayOfJan1st(year) {
  //log('getWeekDayOfJan1st()');
  //log('-- year=', year);
  let x;
  const c = Math.floor(year / 100); // century offset
  //log('-- c=', c);
  switch (c % 4) { // base value for the date's century
    case 0: x = 8;
      break;
    case 1: x = 6;
      break;
    case 2: x = 4;
      break;
    case 3: x = 2;
      break;
  }
  //log('-- x=', x);
  const y = year % 100; // 2-digit year within the century
  //log('-- y=', y);
  const z = Math.floor(y / 4); // no. of leap days since 1 March xx00
  //log('-- z=', z);
  const s = x + y + z; // base value + 2-digit year + leap days
  //log('-- s=', s);
  const d = s % 7; // the reference day
  //log('-- d=', d);
  // 0 = Mon, 1 = Tue, 2 = Wed, 3 = Thu, 4 = Fri, 5 = Sat, 6 = Sun
  
  // in "normal" year the reference day is January 31st
  // in leap year the reference day is February 1st
  // We can then calculate the week day of Jan 1st based on that:
  const jan1stDiff = isLeapYear(year) ? 3 : 2;
  //log('-- jan1stDiff=', jan1stDiff);
  
  let d2 = d - jan1stDiff;
  //log('-- d2=', d2);
  if (d2 < 0) {
    d2 = 7 + d2;
  }
  //log('-- d2=', d2);
  //log('-- return=', (d2 + 1) % 7);
  // Switch to Date.getDay() format where:
  // 0 = Sun, 1 = Mon, 2= Tue, 3 = Wed, 4 = Thu, 5 = Fri, 6 = Sat
  return (d2 + 1) % 7;
}

// Get weekday for a given day based on days since Jan 1st
// Return value:
// 0 = Sun, 1 = Mon, 2= Tue, 3 = Wed, 4 = Thu, 5 = Fri, 6 = Sat
function getWeekDay(year, daysSinceJan1st) {
  //log('getWeekDay()');
  const weekDayJan1st = getWeekDayOfJan1st(year);
  //log('-- weekDayJan1st=', weekDayJan1st);
  //log('-- daysSinceJan1st=', daysSinceJan1st);
  let d = weekDayJan1st + (daysSinceJan1st % 7);
  //log('-- d=', d);
  if (d > 6) d = d - 7;
  //log('-- return=', d);
  return d;
}

// ****************
// ----------------
// MAIN CODE START:

// Get current Epoch timestamp and convert it to number of days since 1970-01-01
const timestamp = getTimestampMillis();
let days = Math.floor(timestamp/(24*60*60*1000));
//log('days since 1970:', days);

let daysInYear;
let year = 1970;

// Start to count years/month since 1970-01-01...

// Find year
while (true) {
  daysInYear = isLeapYear(year) ? 366 : 365;
  if (days >= daysInYear) {
    days = days - daysInYear;
    year++;
  } else {
    break;
  }
}

//log('found year:', year);

// Store the number of days since beginnig of year
const daysSinceJan1st = days;

// Find month
const daysInFeb = isLeapYear(year) ? 29 : 28;
const daysInMonths = [31, daysInFeb, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
//log('daysInMonths=', daysInMonths);
let monthIndex = 0;
while (true) {
  if (days >= daysInMonths[monthIndex]) {
    days = days - daysInMonths[monthIndex];
    monthIndex++;
  } else {
    break;
  }
}
const month = monthIndex + 1;

//log('found month:', month);

// Add fractional days to get the current date's day:
const day = days + 1; 

//log('found day:', day);

// Get current weekday
let weekday = getWeekDay(year, daysSinceJan1st);

//log('weekday=', weekday);

// Thursday in current week decides the year, so get Thursday:
let thursdayThisWeekSinceJan1st = daysSinceJan1st + 3 - (weekday + 6) % 7;
//log('thursdayThisWeekSinceJan1st=', thursdayThisWeekSinceJan1st);

if (thursdayThisWeekSinceJan1st < 0) {
  // Go to previous year
  year = year - 1;
  daysInYear = isLeapYear(year) ? 366 : 365;
  thursdayThisWeekSinceJan1st = daysInYear + thursdayThisWeekSinceJan1st;
} else if (thursdayThisWeekSinceJan1st >= daysInYear) {
  // Go to next year
  year = year + 1;
  thursdayThisWeekSinceJan1st = thursdayThisWeekSinceJan1st - daysInYear;
}

// January 4 is always in week 1. Get Thursday from week that has Jan4th:
const jan4thWeekDay = getWeekDay(year, 3);
//log('jan4thWeekDay=', jan4thWeekDay);
const jan4thWeeksThursdaySinceJan1st = 3 + 3 - (jan4thWeekDay + 6) % 7;
//log('jan4thWeeksThursdaySinceJan1st=', jan4thWeeksThursdaySinceJan1st);

// Count difference in weeks
const weekNumber = 1 + Math.round((thursdayThisWeekSinceJan1st - jan4thWeeksThursdaySinceJan1st) / 7);
log('weekNumber=', weekNumber);
log('weekYear=', year);

// Convert from 0=Sunday...6=Saturday to 1=Monday...7=Sunday
weekday = 7 + ((weekday - 7) % 7);

// Return value in correct format
switch(data.format) {
  case "yyyyww":
    return year + zeroPad(weekNumber, 2);
  case "yyyy-ww":
    return year + '-' + zeroPad(weekNumber, 2);
  case "yyyywww":
    return year + 'W' + zeroPad(weekNumber, 2);
  case "yyyy-www":
    return year + '-W' + zeroPad(weekNumber, 2);
  case "ww":
    return zeroPad(weekNumber, 2);
  case "w":
    return makeString(weekNumber);
  case "yyyy-www-d":
    return year + '-W' + zeroPad(weekNumber, 2) + '-' + weekday;
  case "yyyy-www-dd":
    return year + '-W' + zeroPad(weekNumber, 2) + '-' + zeroPad(weekday, 2);
  default:
    // Default format "YYYY-'W'ww":
    return year + '-W' + zeroPad(weekNumber, 2);
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: 2019-12-30 to 2020-01-05 / format 01
  code: |+
    const mockData = {
      'format': "ww",
    };

    const monday = 1577679754000;
    const weekNumber = '01';

    mock('getTimestampMillis', monday);
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*2);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*3);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*4);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*5);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*6);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

- name: 2020-01-27 to 2020-02-02 / format 5
  code: |+
    const mockData = {
      'format': "w",
    };

    const monday = 1580083200000;
    const weekNumber = '5';

    mock('getTimestampMillis', monday);
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*2);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*3);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*4);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*5);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*6);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

- name: 2020-02-24 to 2020-03-01 / format 202009
  code: |+
    const mockData = {
      'format': "yyyyww",
    };

    const monday = 1582502400000;
    const weekNumber = '202009';

    mock('getTimestampMillis', monday);
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*2);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*3);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*4);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*5);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*6);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

- name: 2020-12-28 to 2021-01-03 / format 2020W53
  code: |+
    const mockData = {
      'format': "yyyywww",
    };

    const monday = 1609113600000;
    const weekNumber = '2020W53';

    mock('getTimestampMillis', monday);
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*2);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*3);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*4);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*5);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*6);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);



- name: 2021-12-27 to 2022-01-02 / format 202152
  code: |+
    const mockData = {
      'format': "yyyyww",
    };

    const monday = 1640563200000;
    const weekNumber = '202152';

    mock('getTimestampMillis', monday);
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*2);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*3);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*4);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*5);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*6);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

- name: 2022-11-14 to 2022-11-20 / format 2022-46
  code: |+
    const mockData = {
      'format': "yyyy-ww",
    };

    const monday = 1668421354000;
    const weekNumber = '2022-46';

    mock('getTimestampMillis', monday);
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*2);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*3);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*4);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*5);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*6);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

- name: 2022-01-03 to 2022-01-09 / format 2022-W01
  code: |+
    const mockData = {
      'format': "yyyy-www",
    };

    const monday = 1641248554000;
    const weekNumber = '2022-W01';

    mock('getTimestampMillis', monday);
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*2);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*3);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*4);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*5);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

    mock('getTimestampMillis', monday + 24*60*60*1000*6);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber);

- name: 2022-12-26 to 2023-01-01 / format 2022-W52-1
  code: |+
    const mockData = {
      'format': "yyyy-www-d",
    };

    const monday = 1672012800000;
    const weekNumber = '2022-W52-';

    mock('getTimestampMillis', monday);
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + 1);

    mock('getTimestampMillis', monday + 24*60*60*1000);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + 2);

    mock('getTimestampMillis', monday + 24*60*60*1000*2);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + 3);

    mock('getTimestampMillis', monday + 24*60*60*1000*3);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + 4);

    mock('getTimestampMillis', monday + 24*60*60*1000*4);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + 5);

    mock('getTimestampMillis', monday + 24*60*60*1000*5);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + 6);

    mock('getTimestampMillis', monday + 24*60*60*1000*6);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + 7);

- name: 2023-01-02 to 2023-01-08 / format 2023-W01-01
  code: |-
    const mockData = {
      'format': "yyyy-www-dd",
    };

    const monday = 1672617600000;
    const weekNumber = '2023-W01-';

    mock('getTimestampMillis', monday);
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + '01');

    mock('getTimestampMillis', monday + 24*60*60*1000);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + '02');

    mock('getTimestampMillis', monday + 24*60*60*1000*2);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + '03');

    mock('getTimestampMillis', monday + 24*60*60*1000*3);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + '04');

    mock('getTimestampMillis', monday + 24*60*60*1000*4);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + '05');

    mock('getTimestampMillis', monday + 24*60*60*1000*5);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + '06');

    mock('getTimestampMillis', monday + 24*60*60*1000*6);
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(weekNumber + '07');


___NOTES___

Created on 18/11/2022, 16:10:36



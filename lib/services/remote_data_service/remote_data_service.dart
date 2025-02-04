import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ecu_scholar/models/schedule_model.dart';
import 'package:ecu_scholar/models/student_model.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import '../../constants/secrets.dart';

class LMSUniversityApi {
  // Define the URL to request
  final String url = 'https://sis.ecu.edu.eg/UI/StudentView/Home.aspx';

  Future<List<Schedule>> fetchSchedules() async {
    final dio = Dio();
    final cookieJar = CookieJar();

    // Add the cookie manager to dio
    dio.interceptors.add(CookieManager(cookieJar));
    dio.options.headers['Cookie'] = SESSION_ID;

    try {
      // Make the GET request with cookies
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        String data = response.data;
        dom.Document html = dom.Document.html(data);
        final scheduleStringList = html
            .querySelectorAll('#ctl00_cntphmaster_Panel1 > div > ul > li > a')
            .map((element) => element.innerHtml.trim())
            .toList();
        List<Schedule> schedules =
            scheduleStringList.map((e) => Schedule.parseSchedule(e)).toList();

        debugPrint('Success: Schedules loaded successfully');
        return schedules;
      } else {
        debugPrint(
            'Failed to load schedules \n status code = ${response.statusCode}');
        throw Exception(
            'Failed to load schedules \n status code = ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to fetch data: $e');
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<Student> fetchStudentData() async {
    final dio = Dio();
    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    dio.options.headers['Cookie'] = SESSION_ID;

    try {
      var response = await dio.get(url);
      if (response.statusCode == 200) {
        dom.Document html = dom.Document.html(response.data);

        Map<String, String> selectors = {
          'Student Name': '#ctl00_cntphmaster_StudDataGeneralControl1_lblStud',
          'Student ID':
              '#ctl00_cntphmaster_StudDataGeneralControl1_lnkStudCode',
          'Degree': '#ctl00_cntphmaster_StudDataGeneralControl1_lblScDegree',
          'Faculty': '#ctl00_cntphmaster_StudDataGeneralControl1_lblFaculty',
          'Major': '#ctl00_cntphmaster_StudDataGeneralControl1_lblMajior',
          'Level': '#ctl00_cntphmaster_StudDataGeneralControl1_LblLvl',
          'Total Passed Hours':
              '#ctl00_cntphmaster_StudDataGeneralControl1_lblTotPassedCh',
          'CGPA': '#ctl00_cntphmaster_StudDataGeneralControl1_lbLCGPA',
        };

        Map<String, String> scrapedData = {};
        selectors.forEach((key, selector) {
          scrapedData[key] = html.querySelector(selector)?.text.trim() ?? 'Empty';
        });
        debugPrint(response.data);
        return Student.fromMap(scrapedData);

      } else {
        throw Exception(
            'Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('in file remote data service /// Error fetching data: $e');
    }
  }
}

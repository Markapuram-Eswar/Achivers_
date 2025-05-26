import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Student Login
  Future<Map<String, dynamic>> loginStudent(String rollNumber) async {
    try {
      final doc = await _firestore.collection('students').doc(rollNumber).get();
      
      if (!doc.exists) {
        throw 'Student with roll number $rollNumber not found';
      }
      
      return {
        'user': doc.data(),
        'role': 'student',
        'id': rollNumber,
      };
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
      rethrow;
    }
  }

  // Teacher Login
  Future<Map<String, dynamic>> loginTeacher(String employeeId) async {
    try {
      final doc = await _firestore.collection('teachers').doc(employeeId).get();
      
      if (!doc.exists) {
        throw 'Teacher with employee ID $employeeId not found';
      }
      
      return {
        'user': doc.data(),
        'role': 'teacher',
        'id': employeeId,
      };
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
      rethrow;
    }
  }

  // Parent Login
  Future<Map<String, dynamic>> loginParent(String rollNumber) async {
    try {
      // First find the student
      final studentDoc = await _firestore
          .collection('students')
          .doc(rollNumber)
          .get();
      
      if (!studentDoc.exists) {
        throw 'No student found with roll number $rollNumber';
      }
      
      // Find parent by child's roll number
      final parentQuery = await _firestore
          .collection('parents')
          .where('children', arrayContains: rollNumber)
          .limit(1)
          .get();
      
      if (parentQuery.docs.isEmpty) {
        throw 'No parent registered for student $rollNumber';
      }
      
      final parentData = parentQuery.docs.first.data();
      
      return {
        'user': parentData,
        'student': studentDoc.data(),
        'role': 'parent',
        'id': parentQuery.docs.first.id,
      };
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
      rethrow;
    }
  }
}

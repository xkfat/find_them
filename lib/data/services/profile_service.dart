import 'package:dio/dio.dart';
import 'package:find_them/data/models/user.dart';
import 'api_service.dart';
import 'package:find_them/core/constants/api_constants.dart';

class ProfileService {
  late Dio dio;

  ProfileService(ApiService apiService) {
    dio = apiService.dio;
  }

  Future<User?> getProfile() async {
    try {
      Response response = await dio.get(ApiConstants.profile);
      return User.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<User?> updateProfile(User user) async {
    try {
      var data = user.toJson();
      
      if (user.profilePhoto != null && user.profilePhoto!.startsWith('file://')) {
        final filePath = user.profilePhoto!.replaceFirst('file:', '');
        
        FormData formData = FormData.fromMap(data);
        formData.files.add(
          MapEntry('profile_photo', await MultipartFile.fromFile(filePath)),
        );
        
        Response response = await dio.patch(
          ApiConstants.profile,
          data: formData,
        );
        
        return User.fromJson(response.data['user']);
      } else {
        Response response = await dio.patch(
          ApiConstants.profile,
          data: data,
        );
        
        return User.fromJson(response.data['user']);
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    try {
      Response response = await dio.post(
        ApiConstants.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password2': confirmPassword,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
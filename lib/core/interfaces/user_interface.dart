import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/features/profile/model/user_model.dart';

abstract class UserInterface {
  Future<HttpResponseModel> login(
      {required String email, required String password});
  Future<HttpResponseModel> validate({required String token});
  Future<HttpResponseModel<dynamic>> create({
    required String name,
    required String email,
    required String password,
  });
  Future<HttpResponseModel> getById({required String id});
  Future<HttpResponseModel> update({required UserModel userModel});
  Future<HttpResponseModel> updatePassword(
      {required String userId, required String password});
  Future<HttpResponseModel> delete({required String id});
  Future<HttpResponseModel> check({required String email});
}

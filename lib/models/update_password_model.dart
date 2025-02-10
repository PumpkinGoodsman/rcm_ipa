import 'dart:convert';

UpdatePassModel updatePassModelFromJson(String str) => UpdatePassModel.fromJson(json.decode(str));

String updatePassModelToJson(UpdatePassModel data) => json.encode(data.toJson());

class UpdatePassModel {
  final String newPassword;
  final String confPassword;

  UpdatePassModel({
    required this.newPassword,
    required this.confPassword,
  });

  factory UpdatePassModel.fromJson(Map<String, dynamic> json) => UpdatePassModel(
    newPassword: json["NewPassword"],
    confPassword: json["ConfPassword"],
  );

  Map<String, dynamic> toJson() => {
    "NewPassword": newPassword,
    "ConfPassword": confPassword,
  };
}

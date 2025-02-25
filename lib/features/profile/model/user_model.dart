import 'dart:convert';

class LoginResponse {
  final bool success;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(String source) =>
      LoginResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  factory LoginResponse.fromMap(Map<String, dynamic> map) {
    return LoginResponse(
      success: map['success'] as bool,
      message: map['message'] as String,
      data: LoginData.fromMap(map['data'] as Map<String, dynamic>),
    );
  }
}

class LoginData {
  final UserModel user;
  final String token;

  LoginData({
    required this.user,
    required this.token,
  });

  factory LoginData.fromMap(Map<String, dynamic> map) {
    return LoginData(
      user: UserModel.fromMap(map['user'] as Map<String, dynamic>),
      token: map['token'] as String,
    );
  }
}

class UserModel {
  final int id;
  final String uuid;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? photo;
  final String? gender;
  final String? phone;
  final String nip;
  final int workingDays;
  final int jumlahCuti;
  final String? lokasiKerja;
  final String? tglMulai;
  final String? tglBerhenti;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? pendidikan;
  final String? gelar;
  final String? jurusan;
  final String? sekolahUniversitas;
  final int? tahunLulus1;
  final String? pendidikan2;
  final String? jurusanPendidikan2;
  final String? sekolahUniversitas2;
  final int? tahunLulus2;
  final String? alamat;
  final String? alamatEmail;
  final String? typePegawai;
  final String? statusPegawai;
  final String? ktpId;
  final String? keterangan;
  final String? noRek;
  final String? specialAdjustmentSa;
  final String? saDateStartActing;
  final String? kontrakMulai1;
  final String? kontrakSelesai1;
  final String? kontrakMulai2;
  final String? kontrakSelesai2;
  final int? gajiPokok;
  final String? ptt;
  final String? tJabatan;
  final String? tKehadiran;
  final String? tAnak;
  final String? bonusSanad;
  final String? diniyyah;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? photoUrl;
  final Schedule? schedule;
  final Department? department;
  final Part? part;

  UserModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.photo,
    this.gender,
    this.phone,
    required this.nip,
    required this.workingDays,
    required this.jumlahCuti,
    this.lokasiKerja,
    this.tglMulai,
    this.tglBerhenti,
    this.tempatLahir,
    this.tanggalLahir,
    this.pendidikan,
    this.gelar,
    this.jurusan,
    this.sekolahUniversitas,
    this.tahunLulus1,
    this.pendidikan2,
    this.jurusanPendidikan2,
    this.sekolahUniversitas2,
    this.tahunLulus2,
    this.alamat,
    this.alamatEmail,
    this.typePegawai,
    this.statusPegawai,
    this.ktpId,
    this.keterangan,
    this.noRek,
    this.specialAdjustmentSa,
    this.saDateStartActing,
    this.kontrakMulai1,
    this.kontrakSelesai1,
    this.kontrakMulai2,
    this.kontrakSelesai2,
    this.gajiPokok,
    this.ptt,
    this.tJabatan,
    this.tKehadiran,
    this.tAnak,
    this.bonusSanad,
    this.diniyyah,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.schedule,
    this.department,
    this.part,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      emailVerifiedAt: map['email_verified_at'] as String?,
      photo: map['photo'] as String?,
      gender: map['gender'] as String?,
      phone: map['phone'] as String?,
      nip: map['nip'] as String,
      workingDays: map['working_days'] as int,
      jumlahCuti: map['jumlah_cuti'] as int,
      lokasiKerja: map['lokasi_kerja'] as String?,
      tglMulai: map['tgl_mulai'] as String?,
      tglBerhenti: map['tgl_berhenti'] as String?,
      tempatLahir: map['tempat_lahir'] as String?,
      tanggalLahir: map['tanggal_lahir'] as String?,
      pendidikan: map['pendidikan'] as String?,
      gelar: map['gelar'] as String?,
      jurusan: map['jurusan'] as String?,
      sekolahUniversitas: map['sekolah_universitas'] as String?,
      tahunLulus1: map['tahun_lulus_1'] as int?,
      pendidikan2: map['pendidikan_2'] as String?,
      jurusanPendidikan2: map['jurusan_pendidikan_2'] as String?,
      sekolahUniversitas2: map['sekolah_universitas_2'] as String?,
      tahunLulus2: map['tahun_lulus_2'] as int?,
      alamat: map['alamat'] as String?,
      alamatEmail: map['alamat_email'] as String?,
      typePegawai: map['type_pegawai'] as String?,
      statusPegawai: map['status_pegawai'] as String?,
      ktpId: map['ktp_id'] as String?,
      keterangan: map['keterangan'] as String?,
      noRek: map['no_rek'] as String?,
      specialAdjustmentSa: map['special_adjustment_sa'] as String?,
      saDateStartActing: map['sa_date_start_acting'] as String?,
      kontrakMulai1: map['kontrak_mulai_1'] as String?,
      kontrakSelesai1: map['kontrak_selesai_1'] as String?,
      kontrakMulai2: map['kontrak_mulai_2'] as String?,
      kontrakSelesai2: map['kontrak_selesai_2'] as String?,
      gajiPokok: map['gaji_pokok'] as int?,
      ptt: map['ptt'] as String?,
      tJabatan: map['t_jabatan'] as String?,
      tKehadiran: map['t_kehadiran'] as String?,
      tAnak: map['t_anak'] as String?,
      bonusSanad: map['bonus_sanad'] as String?,
      diniyyah: map['diniyyah'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      photoUrl: map['photo_url'] as String?,
      schedule: map['schedule'] != null
          ? Schedule.fromMap(map['schedule'] as Map<String, dynamic>)
          : null,
      department: map['department'] != null
          ? Department.fromMap(map['department'] as Map<String, dynamic>)
          : null,
      part: map['part'] != null
          ? Part.fromMap(map['part'] as Map<String, dynamic>)
          : null,
    );
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Schedule {
  final int id;
  final String mondayStart;
  final String mondayEnd;
  final String tuesdayStart;
  final String tuesdayEnd;
  final String wednesdayStart;
  final String wednesdayEnd;
  final String thursdayStart;
  final String thursdayEnd;
  final String fridayStart;
  final String fridayEnd;
  final String saturdayStart;
  final String saturdayEnd;
  final String? sundayStart;
  final String? sundayEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedule({
    required this.id,
    required this.mondayStart,
    required this.mondayEnd,
    required this.tuesdayStart,
    required this.tuesdayEnd,
    required this.wednesdayStart,
    required this.wednesdayEnd,
    required this.thursdayStart,
    required this.thursdayEnd,
    required this.fridayStart,
    required this.fridayEnd,
    required this.saturdayStart,
    required this.saturdayEnd,
    this.sundayStart,
    this.sundayEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as int,
      mondayStart: map['monday_start'] as String,
      mondayEnd: map['monday_end'] as String,
      tuesdayStart: map['tuesday_start'] as String,
      tuesdayEnd: map['tuesday_end'] as String,
      wednesdayStart: map['wednesday_start'] as String,
      wednesdayEnd: map['wednesday_end'] as String,
      thursdayStart: map['thursday_start'] as String,
      thursdayEnd: map['thursday_end'] as String,
      fridayStart: map['friday_start'] as String,
      fridayEnd: map['friday_end'] as String,
      saturdayStart: map['saturday_start'] as String,
      saturdayEnd: map['saturday_end'] as String,
      sundayStart: map['sunday_start'] as String?,
      sundayEnd: map['sunday_end'] as String?,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

class Department {
  final int id;
  final String name;
  final String code;
  final int? headId;
  final String? location;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Department({
    required this.id,
    required this.name,
    required this.code,
    this.headId,
    this.location,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'] as int,
      name: map['name'] as String,
      code: map['code'] as String,
      headId: map['head_id'] as int?,
      location: map['location'] as String?,
      description: map['description'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

class Part {
  final int id;
  final String name;
  final int departmentId;
  final String code;
  final int? headId;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Part({
    required this.id,
    required this.name,
    required this.departmentId,
    required this.code,
    this.headId,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Part.fromMap(Map<String, dynamic> map) {
    return Part(
      id: map['id'] as int,
      name: map['name'] as String,
      departmentId: map['department_id'] as int,
      code: map['code'] as String,
      headId: map['head_id'] as int?,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

// Extension for converting models to/from JSON
extension LoginResponseJson on LoginResponse {
  Map<String, dynamic> toMap() => {
        'success': success,
        'message': message,
        'data': data.toMap(),
      };

  String toJson() => json.encode(toMap());
}

extension LoginDataJson on LoginData {
  Map<String, dynamic> toMap() => {
        'user': user.toMap(),
        'token': token,
      };

  String toJson() => json.encode(toMap());
}

extension UserModelJson on UserModel {
  Map<String, dynamic> toMap() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'email': email,
        'email_verified_at': emailVerifiedAt,
        'photo': photo,
        'gender': gender,
        'phone': phone,
        'nip': nip,
        'working_days': workingDays,
        'jumlah_cuti': jumlahCuti,
        'lokasi_kerja': lokasiKerja,
        'tgl_mulai': tglMulai,
        'tgl_berhenti': tglBerhenti,
        'tempat_lahir': tempatLahir,
        'tanggal_lahir': tanggalLahir,
        'pendidikan': pendidikan,
        'gelar': gelar,
        'jurusan': jurusan,
        'sekolah_universitas': sekolahUniversitas,
        'tahun_lulus_1': tahunLulus1,
        'pendidikan_2': pendidikan2,
        'jurusan_pendidikan_2': jurusanPendidikan2,
        'sekolah_universitas_2': sekolahUniversitas2,
        'tahun_lulus_2': tahunLulus2,
        'alamat': alamat,
        'alamat_email': alamatEmail,
        'type_pegawai': typePegawai,
        'status_pegawai': statusPegawai,
        'ktp_id': ktpId,
        'keterangan': keterangan,
        'no_rek': noRek,
        'special_adjustment_sa': specialAdjustmentSa,
        'sa_date_start_acting': saDateStartActing,
        'kontrak_mulai_1': kontrakMulai1,
        'kontrak_selesai_1': kontrakSelesai1,
        'kontrak_mulai_2': kontrakMulai2,
        'kontrak_selesai_2': kontrakSelesai2,
        'gaji_pokok': gajiPokok,
        'ptt': ptt,
        't_jabatan': tJabatan,
        't_kehadiran': tKehadiran,
        't_anak': tAnak,
        'bonus_sanad': bonusSanad,
        'diniyyah': diniyyah,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'photo_url': photoUrl,
        'schedule': schedule?.toMap(),
        'department': department?.toMap(),
        'part': part?.toMap(),
      };

  String toJson() => json.encode(toMap());
}

extension ScheduleJson on Schedule {
  Map<String, dynamic> toMap() => {
        'id': id,
        'monday_start': mondayStart,
        'monday_end': mondayEnd,
        'tuesday_start': tuesdayStart,
        'tuesday_end': tuesdayEnd,
        'wednesday_start': wednesdayStart,
        'wednesday_end': wednesdayEnd,
        'thursday_start': thursdayStart,
        'thursday_end': thursdayEnd,
        'friday_start': fridayStart,
        'friday_end': fridayEnd,
        'saturday_start': saturdayStart,
        'saturday_end': saturdayEnd,
        'sunday_start': sundayStart,
        'sunday_end': sundayEnd,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  String toJson() => json.encode(toMap());
}

extension DepartmentJson on Department {
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'code': code,
        'head_id': headId,
        'location': location,
        'description': description,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  String toJson() => json.encode(toMap());
}

extension PartJson on Part {
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'department_id': departmentId,
        'code': code,
        'head_id': headId,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  String toJson() => json.encode(toMap());
}

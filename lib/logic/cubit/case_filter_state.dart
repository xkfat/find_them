import 'package:equatable/equatable.dart';

class CaseFilterState extends Equatable {
  final String? name;
  final String? lastSeenLocation;
  final String? nameOrLocation;
  final int? ageMin;
  final int? ageMax;
  final String? gender;
  final String? status;
  final String? startDate;
  final String? endDate;

  const CaseFilterState({
    this.name,

    this.lastSeenLocation,
    this.nameOrLocation, 
    this.ageMin,
    this.ageMax,
    this.gender,
    this.status,
    this.startDate,
    this.endDate,
  });

  CaseFilterState copyWith({
    String? name,
    String? lastSeenLocation,
    String? nameOrLocation,
    int? ageMin,
    int? ageMax,
    String? gender,
    String? status,
    String? startDate,
    String? endDate,
    bool clearName = false,
    bool clearLastSeenLocation = false,
     bool clearNameOrLocation = false,
    bool clearAgeMin = false,
    bool clearAgeMax = false,
    bool clearGender = false,
    bool clearStatus = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return CaseFilterState(
      name: clearName ? null : (name ?? this.name),
      lastSeenLocation:
          clearLastSeenLocation
              ? null
              : (lastSeenLocation ?? this.lastSeenLocation), // Handle clearing
      nameOrLocation: clearNameOrLocation ? null : (nameOrLocation ?? this.nameOrLocation),  // Add this

      ageMin: clearAgeMin ? null : (ageMin ?? this.ageMin),
      ageMax: clearAgeMax ? null : (ageMax ?? this.ageMax),
      gender: clearGender ? null : (gender ?? this.gender),
      status: clearStatus ? null : (status ?? this.status),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  bool get hasFilters =>
      name != null ||
      lastSeenLocation != null ||
        nameOrLocation != null ||
      ageMin != null ||
      ageMax != null ||
      gender != null ||
      status != null ||
      startDate != null ||
      endDate != null;

  CaseFilterState clear() => const CaseFilterState();

  @override
  List<Object?> get props => [
    name,
    lastSeenLocation,
      nameOrLocation,
    ageMin,
    ageMax,
    gender,
    status,
    startDate,
    endDate,
  ];
}

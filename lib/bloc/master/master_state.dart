part of 'master_bloc.dart';

@immutable
sealed class MasterState {}

final class MasterInitial extends MasterState {}

class MasterProfileUpdated extends MasterState {}

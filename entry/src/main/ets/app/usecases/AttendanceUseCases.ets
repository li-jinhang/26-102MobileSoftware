import { repositories } from '../repositories/RepositoryProvider';
import { AttendanceRecord, AttendanceTodaySummary } from '../../models/AppModels';

export interface AttendanceOverviewData {
  todaySummary: AttendanceTodaySummary;
  records: AttendanceRecord[];
}

function sortAttendanceRecords(records: AttendanceRecord[]): AttendanceRecord[] {
  return records.slice().sort((left: AttendanceRecord, right: AttendanceRecord) => {
    return right.time.localeCompare(left.time);
  });
}

export async function loadAttendanceOverviewUseCase(): Promise<AttendanceOverviewData> {
  const todaySummary: AttendanceTodaySummary = await repositories.attendanceRepository.getTodaySummary();
  const records: AttendanceRecord[] = await repositories.attendanceRepository.getMyRecords();
  return {
    todaySummary,
    records: sortAttendanceRecords(records)
  };
}

export async function submitAttendanceCheckInUseCase(note: string, location: string): Promise<AttendanceOverviewData> {
  const todaySummary: AttendanceTodaySummary = await repositories.attendanceRepository.checkIn({
    location: location.trim(),
    note: note.trim()
  });
  const records: AttendanceRecord[] = await repositories.attendanceRepository.getMyRecords();
  return {
    todaySummary,
    records: sortAttendanceRecords(records)
  };
}

export async function submitAttendanceCheckOutUseCase(note: string, location: string): Promise<AttendanceOverviewData> {
  const todaySummary: AttendanceTodaySummary = await repositories.attendanceRepository.checkOut({
    location: location.trim(),
    note: note.trim()
  });
  const records: AttendanceRecord[] = await repositories.attendanceRepository.getMyRecords();
  return {
    todaySummary,
    records: sortAttendanceRecords(records)
  };
}

export function getAttendanceActionLabelUseCase(todaySummary: AttendanceTodaySummary): string {
  if (!todaySummary.checkedIn) {
    return '立即签到';
  }
  if (!todaySummary.checkedOut) {
    return '立即签退';
  }
  return '今日已完成';
}

export function canSubmitCheckInUseCase(todaySummary: AttendanceTodaySummary): boolean {
  return !todaySummary.checkedIn;
}

export function canSubmitCheckOutUseCase(todaySummary: AttendanceTodaySummary): boolean {
  return todaySummary.checkedIn && !todaySummary.checkedOut;
}
